/*<pre><b>
/ Program   : compress.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Jul-2007
/ Purpose   : Function-style macro to compress a macro string 
/ SubMacros : none
/ Notes     : This macro is in case you have a call to %compress() in some old
/             code. For new code use %sysfunc(compress()).
/ Usage     : %let str2=%compress(&str,1234567890.);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to compress
/ chars             (pos) Characters to compress out of the string
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: compress v1.0;

%macro compress(string,chars);
%sysfunc(compress(&string,&chars))
%mend;
