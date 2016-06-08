/*<pre><b>
/ Program      : adddecodevars.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : To add decode variables where a user format is specified
/ SubMacros    : %sysfmtlist
/ Notes        : This macro allows the programmer to better understand their
/                data by making a copy of a dataset with user-formatted
/                variables decoded as new variables placed after the user-
/                formatted variables which should have their user formats
/                removed so that both the raw values and formatted values can be
/                seen side by side.
/
/                Length of decode variable is determined from the format length.
/                Decode variable names will be same as the ones being decoded
/                but with the suffix defined to this macro added. The variables
/                will be reordered such that a decode variable will logically
/                follow the variable being decoded. System formats will not be
/                decoded and the list is maintained in the %sysfmtlist macro.
/
/ Usage        : %adddecodevars(dsin=ds1,dsout=ds2)
/ 
/===============================================================================
/ REQUIREMENTS SPECIFICATION:
/ --id--  ---------------------------description--------------------------------
/ REQ001: The variables that are the decode of the orginal user-formatted
/         variables should be positioned immediately after the corresponding 
/         coded variable.
/ REQ002: The decoded variables should have the same name as the coded variables
/         but with a general suffix added.
/ REQ003: It should be possible for the user to change the suffix for the
/         decoded variable names.
/ REQ004: The user should have the option of showing the coded variables as
/         originally formatted, if they so wish, but the default should be to
/         show these coded variables as unformatted in the output dataset.
/ REQ005: Whether a variable is user-formatted or system-formatted should be
/         determined by reference to the %sysfmtlist macro which contains a list
/         of system formats that might be encountered during normal use.
/ REQ006: The length of the decoded variables should be optimised to save space
/         while at the same time not showing truncated decoded values. The
/         length of each decoded variable will be the same as the format length
/         in the "formatl" variable obtained from a "proc contents" of the
/         original dataset.
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin=             Input dataset
/ dsout=            Output dataset (no modifiers)
/ suffix="__D"      Suffix to use for the decode variable. This will be added
/                   at the end of the name of the variable being decoded.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  24Mar09         requirements specification added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: adddecodevars v1.0;

%macro adddecodevars(dsin=,dsout=,suffix="__D",killusrfmts=yes);

  %local errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;


        /*----------------------------------*
            check that parameters are set
         *----------------------------------*/

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (adddecodevars) No input dataset defined to dsin=;
  %end;

  %if not %length(&dsout) %then %do;
    %let errflag=1;
    %put &err: (adddecodevars) No output dataset defined to dsout=;
  %end;

  %if not %length(&suffix) %then %do;
    %let errflag=1;
    %put &err: (adddecodevars) No characters defined to sufFix=;
  %end;

  %if &errflag %then %goto exit;


        /*----------------------------------*
              prepare parameter settings
         *----------------------------------*/

  %let suffix="%sysfunc(compress(&suffix,%str(%'%")))";

  %if not %length(&killusrfmts) %then %let killusrfmts=yes;
  %let killusrfmts=%upcase(%substr(&killusrfmts,1,1));


        /*----------------------------------*
             get contents of input dataset
         *----------------------------------*/

  *- Option "fmtlen" is used to get lengths of user formats. -;
  proc contents noprint fmtlen varnum data=&dsin mtype=data out=_adddecont;
  run;

  *- put in logical variable order -;
  proc sort data=_adddecont;
    by memname varnum;
  run;

        /*----------------------------------*
           create long strings of variables 
         *----------------------------------*/

  data _adddecont;
    *- long lists of retain, length and user variables -;
    length retlist lenlist usrlist $ 32767;
    retain retlist "retain" lenlist "length" usrlist "format";
    set _adddecont end=last;
    *- this is trying to identify non-user formats -;
    if format in (" " %sysfmtlist) then _fmt="SYS";
    else _fmt="USR";
    *- add to the retain list for future reordering of variables -;
    retlist=trim(retlist)||" "||trim(name);
    if _fmt="USR" then do;
      *- add decode variable to the length statement list -;
      lenlist=trim(lenlist)||" "||trim(name)||&suffix||" $ "||compress(put(formatl,4.));
      *- add decode variable to the retain statement list -;
      retlist=trim(retlist)||" "||trim(name)||&suffix;
      *- add original variable to the format kill list -;
      usrlist=trim(usrlist)||" "||name;
    end;
    if last then do;
      *- write the long lists out to local macro variables -;
      call symput('retlist',trim(retlist));
      call symput('lenlist',trim(lenlist));
      call symput('usrlist',trim(usrlist));
    end;
    keep name type _fmt;
  run;


        /*----------------------------------*
                generate call executes
         *----------------------------------*/

  data _null_;
    set _adddecont end=last;
    *- start of generated data step -;
    if _n_=1 then do;
      call execute('data &dsout;');
      call execute('&lenlist;');
      call execute('set &dsin;');
    end;
    *- generate the decoding code and the label statement -;
    if _fmt="USR" then do;
      if type=2 then do;
        *- variable type is character -;
        call execute(trim(name)||&suffix||"=putc("||trim(name)||",vformat("||trim(name)||"));");
      end;
      else do;
        *- variable type is numeric -;
        call execute(trim(name)||&suffix||"=putn("||trim(name)||",vformat("||trim(name)||"));");
      end;
      call execute("label "||trim(name)||&suffix||"='Decode of variable "||trim(name)||"';");
    end;
    *- end of data step followed by reordering data step -;
    if last then do;
      call execute('run;');
      call execute('data &dsout;');
      call execute('&retlist;');
      call execute('set &dsout;');
      %if "&killusrfmts" EQ "Y" %then %do;
        call execute('&usrlist;');
      %end;
      call execute('run;');
    end;
  run;


        /*----------------------------------*
                   tidy up and exit
         *----------------------------------*/

  proc datasets nolist;
    delete _adddecont;
  run;
  quit;

  %goto skip;
  %exit: %put &err: (adddecodevars) Leaving maco due to problem(s) listed;
  %skip:

%mend adddecodevars;

