/*<pre><b>
/ Program      : lafootnote.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : To create a left-aligned footnote
/ SubMacros    : none
/ Notes        : The footnote must be in quotes. Leading spaces are allowed.
/ Usage        : %lafootnote(2,"  second footnote indented two spaces")
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ num               (pos) footnote number
/ string            (pos) (in quotes) Footnote to left-align
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

%put MACRO CALLED: lafootnote v1.0;

%macro lafootnote(num,string);
  footnote&num &string "%sysfunc(repeat(%str( ),199)))";
%mend lafootnote;
