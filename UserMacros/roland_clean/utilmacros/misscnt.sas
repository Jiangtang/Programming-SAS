/*<pre><b>
/ Program   : misscnt.sas
/ Version   : 3.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 09-Apr-2013
/ Purpose   : To create a list of variables and their missing value count
/ SubMacros : %nvarsc %nvarsn
/ Notes     : Version 2.0 and beyond is not compatible with version 1.0 as it
/             uses named parameters keep= and drop= and no longer the positional
/             parameter "drop" that was used in version 1.0.
/
/             It is not possible to implement this as a function-style macro due
/             to the data step boundary so the results will be written to a
/             global macro variable which by default is named "_miss_". What you
/             do with the list created is entirely up to you. The variables with
/             a non-zero missing count will be listed directly followed by an
/             equals sign directly followed by the missing value count.
/             Variables with zero missing values are not listed.
/
/             You can define both a keep list of variables and a drop list of 
/             variables. If you define both then only the keep list will be used
/             and the drop list will have no effect.
/
/ Usage     : %misscnt(dsname,keep=&keeplist);
/             %misscnt(dsname,drop=&droplist);
/             %misscnt(dsname,dsout=_misscnt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset to analyze (unmodified)
/ keep=             List of variables to keep
/ drop=             List of variable to drop (gets overridden by keep= if
/                   keep= is specified)
/ globvar=_miss_    Name of the global macro variable to contain the list of
/                   variables with their missing count.
/ dsout=            Optional output dataset containing fields "name" and "count"
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/ rrb  03Dec12         Keep= and drop= named parameters added (v2.0)
/ rrb  06Dec12         NOTEs disabled and changed so that if a character
/                      variable equates to a single period when left aligned
/                      then it will also be regarded as a missing value (v2.1)
/ rrb  08Apr13         dsout= parameter added (v3.0)
/ rrb  09Apr13         Make the dsout= dataset a zero observation dataset if the
/                      missing count is zero for all variables (v3.1) 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: misscnt v3.1;

%macro misscnt(ds,
               keep=,
               drop=,
               globvar=_miss_,
               dsout=
              );

  %local i bit dsname nvarsn nvarsc savopts;

  %let savopts=%sysfunc(getoption(notes));
  options nonotes;

  %global &globvar;
  %let &globvar=;
  %let dsname=&ds;

  %if %length(&drop) or %length(&keep) %then %do;
    %let dsname=_misscnt;
    data _misscnt;
      set &ds
      %if %length(&keep) %then %do;
        (keep=&keep)
      %end;
      %else %if %length(&drop) %then %do;
        (drop=&drop)
      %end;
      ;
    run;
  %end;


  %let nvarsn=%nvarsn(&dsname);
  %let nvarsc=%nvarsc(&dsname);

  data _null_;
    %if &nvarsn GT 0 %then %do;
      array _nmiss {&nvarsn} 8 _temporary_ (&nvarsn*0);
    %end;
    %if &nvarsc GT 0 %then %do;
      array _cmiss {&nvarsc} 8 _temporary_ (&nvarsc*0);
    %end;
    SET &dsname END=LAST;
    %if &nvarsn GT 0 %then %do;
      array _num {*} _numeric_;
    %end;
    %if &nvarsc GT 0 %then %do;
      array _char {*} _character_;
    %end;
    %if &nvarsn GT 0 %then %do;
      do i=1 to &nvarsn;
        if _num(i) EQ . then _nmiss(i)=_nmiss(i)+1;
      end;
    %end;
    %if &nvarsc GT 0 %then %do;
      do i=1 to &nvarsc;
        if left(_char(i)) IN (' ' '.') then _cmiss(i)=_cmiss(i)+1;
      end;
    %end;
    if LAST then do;
      %if &nvarsn GT 0 %then %do;
        do i=1 to &nvarsn;
          if _nmiss(i) GT 0 then call execute('%let &globvar=&&&globvar '||
            trim(vname(_num(i)))||'='||compress(put(_nmiss(i),11.))||';');
        end;
      %end;
      %if &nvarsc GT 0 %then %do;
        do i=1 to &nvarsc;
          if _cmiss(i) GT 0 then call execute('%let &globvar=&&&globvar '||
            trim(vname(_char(i)))||'='||compress(put(_cmiss(i),11.))||';');
        end;
      %end;
    end;
  run;


  %if "&dsname" EQ "_misscnt" %then %do;
    proc datasets nolist;
      delete _misscnt;
    quit;
  %end;


  %if %length(&dsout) %then %do;
    data &dsout;
      length name $ 32 count 8;
      if 0=1 then output;
      %let i=1;
      %let bit=%scan(&&&globvar,&i,%str( ));
      %do %while(%length(&bit));
        name="%scan(&bit,1,=)";
        count=%scan(&bit,2,=);
        output;
        %let i=%eval(&i+1);
        %let bit=%scan(&&&globvar,&i,%str( ));
      %end;
    run;
  %end;

  options &savopts;

%mend misscnt;
