/*<pre><b>
/ Program   : commas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to separate the elements of a list with
/             commas.
/ SubMacros : %quotelst
/ Notes     : This uses %quotelst to do all the work. You would typically use 
/             this to delimit a list of variables with commas for proc sql where
/             it is not known if resolved values equate to anything.
/ Usage     : order by %commas(&var1 &var2 &var3);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               String elements to delimit with commas (pos)
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

%put MACRO CALLED: commas v1.0;

%macro commas(str);
%quotelst(&str,quote=%str(),delim=%str(, ))
%mend commas;
