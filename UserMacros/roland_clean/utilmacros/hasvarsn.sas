/*<pre><b>
/ Program   : hasvarsn.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 21-Jun-2013
/ Purpose   : Function-style macro to return true if a dataset has all the
/             numeric variables defined to a list.
/ SubMacros : %match %varlistn
/ Notes     : Non-matching variables will be returned in the global macro
/             variable _nomatch_ .
/ Usage     : %if not %hasvarsn(dsname,aa bb cc) %then %do ....
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
/ rrb  21Jun13         Diagnostics added for when there are no numeric
/                      variables in the input dataset (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: hasvarsn v2.0;

%macro hasvarsn(ds,varlist,casesens=no);
  %local varmatch varlistn;
  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));
  %let varlistn=%varlistn(&ds);
  %if not %length(&varlistn) %then %do;
%put NOTE: (hasvarsn) There are no numeric variables in the input dataset therefore;
%put NOTE: (hasvarsn) the numeric variable(s) you are testing for will not be found.;
    %let varmatch=%match(,&varlist,casesens=&casesens);
0
  %end;
  %else %do;
    %let varmatch=%match(&varlistn,&varlist,casesens=&casesens);
    %if not %length(&_nomatch_) %then 1;
    %else 0;
  %end;
%mend hasvarsn;
  