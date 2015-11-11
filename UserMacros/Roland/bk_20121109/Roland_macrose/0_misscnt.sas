/*<pre><b>
/ Program   : misscnt.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To create a list of variables and their missing value count
/ SubMacros : %nvarsc %nvarsn
/ Notes     : It is not possible to implement this as a function-style macro due
/             to the data step boundary so the results will be written out to a
/             global macro variable. What you do with the list created is
/             entirely up to you. The variable will be directly followed by an
/             equal sign followed directly by the missing value count. Variables
/             with zero missing values will not be shown. Note that this macro,
/             unlike its sister %missvars, has a drop list. You might want to
/             use the output from %missvars to ignore all-missing variables from
/             your analysis.
/ Usage     : %misscnt(dsname,droplist,globvar=_miss_);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset (pos) (must be pure dataset name and have no keep,
/                   drop, where or rename associated with it).
/ drop              List of variables (pos - unquoted and separated by spaces)
/                   to drop from the analysis.
/ globvar=_miss_    Name of the global macro variable to set up to contain the
/                   list of variables and their missing count.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: misscnt v1.0;

%macro misscnt(ds,drop,globvar=_miss_);

  %local dsname nvarsn nvarsc;
  %global &globvar;
  %let &globvar=;
  %let dsname=&ds;

  %if %length(&drop) GT 0 %then %do;
    %let dsname=_misscnt;
    data _misscnt;
      set &ds(drop=&drop);
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
    set &dsname end=last;
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
        if _char(i) EQ ' ' then _cmiss(i)=_cmiss(i)+1;
      end;
    %end;
    if last then do;
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


  %if %length(&drop) GT 0 %then %do;
    proc datasets nolist;
      delete _misscnt;
    run;
  %end;

%mend misscnt;
