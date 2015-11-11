/*<pre><b>
/ Program   : vartype.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return a variable type as either C or N
/ SubMacros : %attrv
/ Notes     : This is a shell macro that calls %attrv
/ Usage     : %let vartype=%vartype(dsname,varname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name
/ var               (pos) Variable name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: vartype v1.0;

%macro vartype(ds,var);
  %attrv(&ds,&var,vartype)
%mend vartype;
