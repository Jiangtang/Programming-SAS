/*<pre><b>
/ Program   : missvars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 13-Feb-2007
/ Purpose   : To create a list of all-missing variables
/ SubMacros : %nvarsc %nvarsn
/ Notes     : It is not possible to implement this as a function-style macro due
/             to the data step boundary so the results will be written out to a
/             global macro variable. What you do with the list created is
/             entirely up to you. You might report them as errors or warnings or
/             you could drop the variables from a dataset as shown in the usage
/             notes below.
/ Usage     : %missvars(dsname,globvar=_miss_);
/             run;
/             data dsname;
/               set dsname(drop=&_miss_);
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset (pos) (must be pure dataset name and have no keep,
/                   drop, where or rename associated with it).
/ globvar=_miss_    Name of the global macro variable to set up to contain the
/                   list of all-missing variables.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: missvars v1.0;

%macro missvars(ds,globvar=_miss_);

%local nvarsn nvarsc;
%global &globvar;
%let &globvar=;

%let nvarsn=%nvarsn(&ds);
%let nvarsc=%nvarsc(&ds);

data _null_;
  %if &nvarsn GT 0 %then %do;
    array _nmiss {&nvarsn} $ 1 _temporary_ (&nvarsn*'1');
  %end;
  %if &nvarsc GT 0 %then %do;
    array _cmiss {&nvarsc} $ 1 _temporary_ (&nvarsc*'1');
  %end;
  set &ds end=last;
  %if &nvarsn GT 0 %then %do;
    array _num {*} _numeric_;
  %end;
  %if &nvarsc GT 0 %then %do;
    array _char (*) _character_;
  %end;
  %if &nvarsn GT 0 %then %do;
    do i=1 to &nvarsn;
      if _num(i) NE . then _nmiss(i)='0';
    end;
  %end;
  %if &nvarsc GT 0 %then %do;
    do i=1 to &nvarsc;
      if _char(i) NE ' ' then _cmiss(i)='0';
    end;
  %end;
  if last then do;
    %if &nvarsn GT 0 %then %do;
      do i=1 to &nvarsn;
        if _nmiss(i) EQ '1' then call execute('%let &globvar=&&&globvar '||
          trim(vname(_num(i)))||';');
      end;
    %end;
    %if &nvarsc GT 0 %then %do;
      do i=1 to &nvarsc;
        if _cmiss(i) EQ '1' then call execute('%let &globvar=&&&globvar '||
          trim(vname(_char(i)))||';');
      end;
    %end;
  end;
run;

%mend;
