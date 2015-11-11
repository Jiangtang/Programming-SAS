/*<pre><b>
/ Program      : unfmt2mvar.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 20-Apr-2013
/ Purpose      : To list distinct values of a variable to a macro variable but
/                without any variable format applied.
/ SubMacros    : none
/ Notes        : Using "select distinct" in proc sql to list the different
/                distinct values of a variable has the problem that the variable
/                format (if any) will be applied. This macro gets around that
/                problem by creating a temporary view with the format nullified
/                for the variable and then this view is used to access the
/                unformatted values from proc sql.
/
/                More than one variable can be specified. Each variable should
/                have a corresponding macro variable and vice versa. All macro
/                variables need to have been declared before this macro is 
/                called.
/
/ Usage        : %unfmt2mvar(test, race sex, mrace msex);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dset              (pos) Input dataset
/ vars              (pos) Variable(s) to return values for. Multiple variables
/                   should be separated by spaces.
/ mvars             (pos) Macro variable(s) to write the variable values to.
/                   Multiple variables should be separated by spaces. All the
/                   macro variables need to be defined before this macro is
/                   called.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Apr13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unfmt2mvar v1.0;

%macro unfmt2mvar(dset,vars,mvars);

  %local i err errflag var mvar savopts num;
  %let err=ERR%str(OR);
  %let errflag=0;


  %if not %length(&dset) %then %do;
    %let errflag=1;
    %put &err: (unfmt2mvar) No dataset specified as the first positional parameter;
  %end;

  %if not %length(&vars) %then %do;
    %let errflag=1;
    %put &err: (unfmt2mvar) No variable(s) specified as the second positional parameter;
  %end;

  %if not %length(&mvars) %then %do;
    %let errflag=1;
    %put &err: (unfmt2mvar) No Macro variable(s) specified as the third positional parameter;
  %end;

  %if &errflag %then %goto exit;

  %let i=1;
  %let var=%scan(&vars,&i,%str( ));
  %let mvar=%scan(&mvars,&i,%str( ));
  %do %while(%length(&var) or %length(&mvar));
    %if not %length(&var) %then %do;
      %let errflag=1;
      %put &err: (unfmt2mvar) No variable corresponding to macro variable &mvar;
    %end;
    %if not %length(&mvar) %then %do;
      %let errflag=1;
      %put &err: (unfmt2mvar) No macro variable corresponding to variable &var;
    %end;
    %else %if not %symexist(&mvar) %then %do;
      %let errflag=1;
      %put &err: (unfmt2mvar) Macro variable &mvar must already exist but does not;
    %end;
    %let i=%eval(&i+1);
    %let var=%scan(&vars,&i,%str( ));
    %let mvar=%scan(&mvars,&i,%str( ));
  %end;

  %if &errflag %then %goto exit;


  %let num=%eval(&i-1);

  %let savopts=%sysfunc(getoption(NOTES));
  options NONOTES;

  data _unfmt / view=_unfmt;
    set &dset;
    format &vars ;
    keep &vars;
  run;

  proc sql noprint;
  %do i=1 %to &num;
    %let var=%scan(&vars,&i,%str( ));
    %let mvar=%scan(&mvars,&i,%str( ));
    select distinct &var into :&mvar separated by ' ' from _unfmt;
  %end;
    drop view _unfmt;
  quit;


  options &savopts;

  %goto skip;
  %exit: %put &err: (unfmt2mvar) Leaving macro due to problem(s) listed;
  %skip:

%mend unfmt2mvar;
