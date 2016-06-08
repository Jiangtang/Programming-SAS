/*<pre><b>
/ Program   : qcompress.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Sep-2011
/ Purpose   : Function-style macro to compress a macro variable string and
/             return the result MACRO QUOTED.
/ SubMacros : none
/ Notes     : 
/ Usage     : %let tidy=%qcompress(&string);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to compress.
/ ref               (pos) Reference characters to remove from the string.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  08May11         Code tidy
/ rrb  23Sep11         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: qcompress v1.0;

%macro qcompress(string,ref);
  %local i errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&string) %then %goto skip;

  %if not %length(&ref) %then %do;
    %put &err: (qcompress) No reference characters supplied to compress string with;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;

%qsysfunc(compress(&string,&ref))

  %goto skip;
  %exit: %put &err: (qcompress) Leaving macro due to problem(s) listed;
  %skip:
%mend qcompress;
  