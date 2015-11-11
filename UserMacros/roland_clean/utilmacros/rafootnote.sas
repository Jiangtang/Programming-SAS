/*<pre><b>
/ Program   : rafootnote.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To right-align a footnote for a pure text output
/ SubMacros : %lrafootnote
/ Notes     : This is for pure text output listings and tables. For other types 
/             of output you can use j=right or .j=right in the footnote
/             statement to achieve right-alignment.
/ Usage     : %rafootnote(5,"This footnote 5 will be right-aligned")
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ num               (pos) Number of footnote
/ text              (pos) Text of footnote (must be in quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: rafootnote v1.0;

%macro rafootnote(num,text);
  %lrafootnote(&num,,&text)
%mend rafootnote;
