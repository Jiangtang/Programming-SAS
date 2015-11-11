/*<pre><b>
/ Program   : printall.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To print every observation in a library where a variable satisfies
/             a specified condition.
/ SubMacros : none
/ Notes     : You can only use conditional operators =<>: and the conditional
/             must be bracketed with %str() to stop the macro thinking the
/             = sign refers to a parameter.
/ Usage     : %printall(work,%str(num>1))
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libname           (pos) Libref.
/ cond              (pos) Conditional statement. Variable must come first and be
/                   the only variable specified. Allowed operators are =<>: You
/                   must enclose this in a %str() declaration otherwise the =
/                   sign makes the macro think it is a parameter. Literals in
/                   character conditionals must be enclosed in single quotes.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26May03         Added local cond2 for compressing quotes out of character
/                      conditionals so title line works and added further
/                      instructions for cond= parameter.
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: printall v1.0;

%macro printall(libname,cond);

  %local var cond2 err;
  %let err=ERR%str(OR);
  %if not %length(&libname) %then %let libname=%sysfunc(getoption(user));
  %if not %length(&libname) %then %let libname=work;

  %if not %length(&cond) %then %do;
    %put &err: (printall) No conditional specified to cond parameter;
    %goto skip;
  %end;

  %let var=%scan(&cond,1,%str( =<>));
  %let cond2=%sysfunc(compress(&cond,%str(%'%")));

  options formdlim='-';

  data _null_;
    set sashelp.vcolumn(where=(libname="%upcase(&libname)" and name="&var"));
    call execute('proc print data='||trim(libname)||'.'||trim(memname)||
  "(where=(&cond));");
    call execute('title "WHERE &cond2 - ALL DATA IN '||
  trim(libname)||'.'||trim(memname)||'";run;');
  run;

  %skip:

%mend printall;
