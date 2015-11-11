/*<pre><b>
/ Program   : var2mvar.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 09-Sep-2011
/ Purpose   : To write data in a variable to a global macro variable
/ SubMacros : none
/ Notes     : Values are written to the global macro variable _mvar_ .
/
/             This should only be used on a character variable where the
/             contents do not contain spaces between words. Using this macro is
/             just a shorthand way of writing the following SQL:
/               PROC SQL NOPRINT;
/                 SELECT &var into: _mvar_ separated by " " from &ds;
/               QUIT;
/             .... and is here just to save you some typing.
/
/             Loading values into a macro variable can make it easier to run
/             a macro call on each item. Normally the variable should contain
/             non-missing unique values. See the %doallitem macro which uses
/             such a value list for repeat processing on each item.
/
/ Usage     : %var2mvar(sashelp.class(where=(name=:"A")),name);
/             %put **&_mvar_**;
/             **Alfred Alice**
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name (modifiers are allowed)
/ var               (pos) Variable name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  09Sep11         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: var2mvar v1.0;

%macro var2mvar(ds,var);

  %local err errflag savopts;

  %let savopts=%sysfunc(getoption(notes));
  options nonotes;

  %global _mvar_;
  %let _mvar_=;

  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&ds) %then %do;
    %let errflag=1;
    %put &err: (var2mvar) No dataset specified as first positional parameter;
  %end;
  %else %do;
    %if not %sysfunc(exist(%scan(&ds,1,%str(%()))) %then %do;
      %let errflag=1;
      %put &err: (var2mvar) Dataset %scan(&ds,1,%str(%()) does not exist;
    %end;
  %end;

  %if not %length(&var) %then %do;
    %let errflag=1;
    %put &err: (var2mvar) No variable name specified as second positional parameter;
  %end;

  %if &errflag %then %goto exit;

  proc sql noprint;
    select &var into: _mvar_ separated by " " from &ds;
  quit;

  %goto skip;
  %exit: %put &err: (var2mvar) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend var2mvar;
