/*<pre><b>
/ Program   : sqlsamevars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Apr-2013
/ Purpose   : In-SQL macro to test if two datasets/tables have the same
/             variables (both names and type) and write the results as a 0 or 1
/             to a global macro variable.
/ SubMacros : none
/ Notes     : This macro assumes that you are already within a "proc sql" step.
/             It suits programmers who mix function-style macro code with SQL.
/
/             This macro relies on a one observation dataset/table named "dummy"
/             being present. It will not be used but must exist as a one obs
/             dataset/table to get around "proc sql" syntax restrictions.
/
/             This is not a function-style macro (unlike %samevars). See usage
/             notes.
/
/             %samevars is a function-style macro that does the same job as this
/             macro but is very limited as to the total number of columns it can
/             process efficiently. This is a non-function-style macro that is
/             not limited to the total number of columns.
/
/             A 0 (not true) or a 1 (true) is written to the global macro
/             variable _sqlsamevars_ depending on whether variables are
/             different (0) or the same (1).
/
/             No modifiers are allowed for the two datasets/tables compared.
/
/ Usage     : proc sql noprint;
/               %sqlsamevars(dset1,dset2);
/               %if &_sqlsamevars_ EQ 0 %then %do ....
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dset1             (pos) one or two level dataset for comparison (no modifiers)
/ dset2             (pos) one or two level dataset for comparison (no modifiers)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Apr13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: sqlsamevars v1.0;

%macro sqlsamevars(dset1,dset2);

  %local deflib err errflag;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dset1) %then %do;
    %let errflag=1;
    %put &err: (sqlsamevars) No dataset specified to first positional parameter;
  %end;

  %if not %length(&dset2) %then %do;
    %let errflag=1;
    %put &err: (sqlsamevars) No dataset specified to second positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %let deflib=%upcase(%sysfunc(getoption(user)));
  %if not %length(&deflib) %then %let deflib=WORK;

  %if not %length(%scan(&dset1,2,.)) %then %let dset1=&deflib..&dset1;
  %if not %length(%scan(&dset2,2,.)) %then %let dset2=&deflib..&dset2;

  %let dset1=%upcase(&dset1);
  %let dset2=%upcase(&dset2);

  %global _sqlsamevars_;
  %let _sqlsamevars_=0;

  select 1 into :_sqlsamevars_ separated by ' ' from dummy where not exists
  (select 1 from 
  (select name, type from dictionary.columns where libname="%scan(&dset1,1,.)" and     memname="%scan(&dset1,2,.)") as a
  full outer join
  (select name, type from dictionary.columns where libname="%scan(&dset2,1,.)" and     memname="%scan(&dset2,2,.)") as b
  on a.name=b.name and a.type=b.type
  where (a.name is null) or (b.name is null)
  );

  %goto skip;
  %exit: %put &err: (sqlsamevars) Leaving macro due to problem(s) listed;
  %skip:

%mend sqlsamevars;
