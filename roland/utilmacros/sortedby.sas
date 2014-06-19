/*<pre><b>
/ Program   : sortedby.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the variables a dataset is sorted
/             by, or null if not sorted.
/ SubMacros : %attrc
/ Notes     : This is a shell macro that calls %attrc
/ Usage     : %let sortedby=%sortedby(dsname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset name
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

%put MACRO CALLED: sortedby v1.0;

%macro sortedby(ds);
  %attrc(&ds,sortedby)
%mend sortedby;
