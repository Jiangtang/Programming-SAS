/*<pre><b>
/ Program   : globlist.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return a list of current global macro
/             variable names.
/ SubMacros : %mvarlist
/ Notes     : All global macro variable names will be in uppercase.
/ Usage     : %let glist=%globlist;
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  10Jun09         Changed to a shell macro that calls %mvarlist for v2.0
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: globlist v2.0;

%macro globlist;
%mvarlist
%mend globlist;
