/*<pre><b>
/ Program   : putvars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Jul-2007
/ Purpose   : To list variables in a dataset suffixed with an equals sign
/             suitable for a "put" statement written to the log.
/ SubMacros : %quotelst %varlist
/ Notes     : This uses %quotelst and %varlist to do all the work. You would
/             typically use this to list out all variables and their contents to
/             the log given an unexpected condition.
/ Usage     : put %putvars(ds);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset to list variables from.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: putvars v1.0;

%macro putvars(ds);
%quotelst(%varlist(&ds),quote=,delim=%str(= ))=
%mend putvars;
