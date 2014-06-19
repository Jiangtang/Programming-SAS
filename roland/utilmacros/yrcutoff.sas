/*<pre><b>
/ Program   : yrcutoff.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To set the year cutoff option to a number of years previous to the
/             current year. 90 is the default which is suitable for clinical
/             reporting.
/ SubMacros : none
/ Notes     : none
/ Usage     : %yrcutoff
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ yearsago          (pos) Number of years ago to set yrcutoff option to. Will
/                   default to 90.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  28Sep08         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: yrcutoff v1.0;

%macro yrcutoff(yearsago);
  %if not %length(&yearsago) %then %let yearsago=90;
  options yearcutoff=%eval(%substr(&sysdate9,6)-&yearsago);
  %put NOTE: (yrcutoff) Year cutoff option has been changed to   %sysfunc(getoption(yearcutoff,keyword));
%mend yrcutoff;
