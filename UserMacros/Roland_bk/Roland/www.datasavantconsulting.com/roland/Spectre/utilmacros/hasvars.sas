/*<pre><b>
/ Program   : hasvars.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return true if a dataset has all the
/             variables defined to a list.
/ SubMacros : %match %varlist
/ Notes     : Non-matching variables will be returned in the global macro
/             variable _nomatch_ .
/ Usage     : %if not %hasvars(dsname,aa bb cc) %then %do ....
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset
/ varlist           (pos) Space-delimited list of variables to check
/ casesens=no       By default, case is not important
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar07         Macro called message added plus header tidy
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: hasvars v1.1;

%macro hasvars(ds,varlist,casesens=no);
  %local varmatch;
  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));

  %let varmatch=%match(%varlist(&ds),&varlist,casesens=&casesens);

  %if not %length(&_nomatch_) %then 1;
  %else 0;
%mend hasvars;



  