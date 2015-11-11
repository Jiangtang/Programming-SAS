/*<pre><b>
/ Program   : ratitle.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To right-align a title for a pure text output
/ SubMacros : %lratitle
/ Notes     : This is for pure text output listings and tables. For other types 
/             of output you can use j=right or .j=right in the title statement
/             to achieve right-alignment.
/ Usage     : %ratitle(5,"This title 5 will be right-aligned")
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ num               (pos) Number of title
/ text              (pos) Text of title (must be in quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ratitle v1.0;

%macro ratitle(num,text);
  %lratitle(&num,,&text)
%mend ratitle;
