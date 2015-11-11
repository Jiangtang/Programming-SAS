/*<pre><b>
/ Program   : fixvars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To "fix" variables in a library so they are consistent
/ SubMacros : none
/ Notes     : WARNING - USE OF THIS MACRO IN "WRITE" MODE COULD DAMAGE YOUR
/             DATASETS. YOU SHOULD BE VERY CAREFUL IN USING THIS MACRO.
/
/             This works in "read" mode and "write" mode. In "read" mode it
/             writes variable information to a flat file, highlighting any
/             inconsistencies. You can edit this file to remove these
/             inconsistencies. In "write" mode it will read this edited file
/             and apply the variable values to all the variables in the library.
/
/             YOU SHOULD BACK UP DATASETS BEFORE RUNNING THIS IN "WRITE" MODE
/             and carefully check that everything is correct before you delete
/             the backups.
/
/             Note that if you set a character variable length to a common
/             smaller length then you could be losing characters off the end of
/             the variable in some datasets.
/
/             You can not change a variable's name or type using this method.
/
/             Do not change the positioning of any fields in the flat file.
/
/             If a numeric variable has its format changed then an "F" might
/             appear in front of it. This is just a feature of "proc datasets"
/             and makes no difference and can be ignored.
/
/             Use the %clash macro if you need to know the source datasets of
/             some of the variables.
/
/             Variables will only be candidates for updating if the variable
/             name matches exactly (it is case sensitive) as does the variable
/             type.
/
/ Usage     : fixvars(mylib,w);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libname           (pos) Library name.
/ mode              (pos) Whether in "read" or "write" mode. W or R will do.
/ flatfile="fixvars.txt"   Name of the flat file.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: fixvars v1.0;

%macro fixvars(libname,mode,flatfile="fixvars.txt");

  %local errflag err user;
  %let err=ERR%str(OR);
  %let errflag=0;

  %let user=%upcase(%sysfunc(getoption(user)));
  %if not %length(&user) %then %let user=WORK;

  %if not %length(&libname) %then %let libname=&user;
  %else %let libname=%upcase(%sysfunc(compress(&libname,%str(%'%"))));

  %if not %length(&flatfile) %then %do;
    %let errflag=1;
    %put &err: (fixvars) No flatfile name specified;
  %end;
  %else %let flatfile="%sysfunc(compress(&flatfile,%str(%'%")))";

  %if not %length(&mode) %then %let mode=read;
  %let mode=%sysfunc(compress(&mode,%str(%'%")));
  %let mode=%upcase(%substr(&mode,1,1));

  %if %sysfunc(verify(&mode,RW)) %then %do;
    %let errflag=1;
    %put &err: (fixvars) Second positional "mode" parameter must be either R(ead) or W(rite);
  %end;

  %if &errflag %then %goto exit;



  %if "&mode" EQ "R" %then %do;

    /*----------------------------------------*
                    READ MODE
     *----------------------------------------*/

    *- get existing information about dataset variables -;
    proc sql noprint;
      create table _fixvars as
      select name, type, length, format, label from dictionary.columns
      where libname="&libname" and memtype='DATA';
    quit;

    *- get rid of duplicates -;
    proc sort nodupkey data=_fixvars;
      by name type length format label;
    run;

    *- write to flat file alerting where there is more than one entry per variable -;
    data _null_;
      file &flatfile;
      set _fixvars;
      by name;
      if not (first.name and last.name) then put @1 '+' @;
      put @3 name @36 type @41 length @45 format @62 label;
    run;

    *- tidy up -;
    proc datasets nolist;
      delete _fixvars;
    run;
    quit;

  %end;


  %else %if "&mode" EQ "W" %then %do;

    /*----------------------------------------*
                     WRITE MODE
     *----------------------------------------*/

    *- get existing information about dataset variables -;
    proc sql noprint;
      create table _fixvarsold as
      select name, type, memname, length as oldlength, format as oldformat, label as oldlabel
      from dictionary.columns
      where libname="&libname" and memtype='DATA'
      order by name, type;
    quit;

    *- read in the flat file containing corrected variable information -;
    data _fixvars;
      length name $ 32 type $ 4 length 8 format $ 16 label $ 256 newlabel $ 266;
      infile &flatfile;
      input;
      if _infile_ NE ' ' then do;
        name=substr(_infile_,3,32);
        type=substr(_infile_,36,4);
        if length(_infile_) GT 42 then length=input(substr(_infile_,41,3),3.);
        else length=input(substr(_infile_,41),3.);
        format=' ';
        if length(_infile_) GT 44 then do;
          if length(_infile_) GT 61 then format=substr(_infile_,45,16);
          else format=substr(_infile_,45);
        end;
        label=' ';
        if length(_infile_) GT 61 then label=substr(_infile_,62);
        *- replace single double quotes in label with double double quotes since -;
        *- we will be enclosing the label in double quotes when in proc datasets -;
        newlabel=tranwrd(label,'"','""');
        if name EQ ' ' then do;
          call symput('errflag','1');
          put '&err: (fixvars) Variable name missing in flat file';
        end;
        if type not in ('char' 'num') then do;
          call symput('errflag','1');
          put '&err: (fixvars) Type of "' type +(-1) '" not recognised in flat file for variable "' name +(-1) '"';
        end;
        if length EQ . then do;
          call symput('errflag','1');
          put '&err: (fixvars) Variable length not recognised in flat file for variable "' name +(-1) '"';
        end;
        output;
      end;
    run;
  
    *- sort just in case the order was changed -;
    proc sort data=_fixvars;
      by name type length format label;
    run;

    *- ensure there are no duplicates in this corrected list -;
    data _null_;
      set _fixvars;
      by name type;
      if not (first.type and last.type) then do;
        if first.type then do;
          put '&err: (fixvars) You have a duplicate entry for variable "' 
              name +(-1) '" type "' type +(-1) '"';
          call symput('errflag','1');
        end;
      end;
    run;

    *- if a duplicate was found then exit after tidying up -;
    %if &errflag %then %do;
      proc datasets nolist;
        delete _fixvarsold;
      run;
      quit;

      %goto exit;
    %end;

    *- merge corected and old variable information together -;
    data _fixvars;
      merge _fixvars(in=_fix) _fixvarsold(in=_old);
      by name type;
      if _fix and _old;
    run;


    /*----------------------------------------*
                    Fix labels
     *----------------------------------------*/

    *- sort into dataset name order for labels that need changing -;
    proc sort data=_fixvars(where=(label NE oldlabel)) out=_fixlabel;
      by memname name;
    run;

    *- generate "proc datasets" code to fix the labels -;
    data _null_;
      set _fixlabel;
      by memname;
      if _n_=1 then call execute("proc datasets nolist lib=&libname;");
      if first.memname then call execute('modify '||trim(memname)||'; label ');
      call execute(trim(name)||'="'||trim(newlabel)||'" ');
      if last.memname then call execute(';run;');
    run;


    /*----------------------------------------*
                    Fix formats
     *----------------------------------------*/

    *- Sort into dataset name order for formats that need changing. -;
    *- Missing formats must be last so that they are nullified.     -;
    proc sort data=_fixvars(where=(format NE oldformat)) out=_fixformat;
      by memname descending format;
    run;

    *- generate "proc datasets" code to fix the formats -;
    data _null_;
      set _fixformat;
      by memname;
      if _n_=1 then call execute("proc datasets nolist lib=&libname;");
      if first.memname then call execute('modify '||trim(memname)||'; format ');
      call execute(trim(name)||' '||trim(format)||' ');
      if last.memname then call execute(';run;');
    run;


    /*----------------------------------------*
                    Fix lengths
     *----------------------------------------*/

    *- sort into dataset name order for lengths that need changing -;
    proc sort data=_fixvars(where=(length NE oldlength)) out=_fixlength;
      by memname name;
    run;

    *- generate the data step code to fix the lengths -;
    data _null_;
      length dollar $ 1;
      set _fixlength;
      by memname;    
      if type='char' then dollar='$';
      else dollar=' ';
      if first.memname then call execute("data &libname.."||trim(memname)||';length ');
      call execute(trim(name)||' '||dollar||' '||put(length,3.)||' ');
      if last.memname then call execute(";set &libname.."||trim(memname)||';run;');
    run;


    *- tidy up -;
    proc datasets nolist;
      delete _fixvars _fixvarsold _fixlabel _fixformat _fixlength;
    run;
    quit;

  %end;


  %goto skip;
  %exit: %put &err: (fixvars) Leaving macro due to problem(s) listed;
  %skip:

%mend fixvars;
  