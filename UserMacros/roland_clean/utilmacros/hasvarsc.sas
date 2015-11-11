/*<pre><b>
/ Program   : hasvarsc.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 21-Jun-2013
/ Purpose   : Function-style to return true if a dataset has all the character
/             variables defined to a list.
/ SubMacros : %match %varlistc
/ Notes     : Non-matching variables will be returned in the global macro
/             variable _nomatch_ .
/ Usage     : %if not %hasvarsc(dsname,aa bb cc) %then %do ....
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
/ rrb  21Jun13         Diagnostics added for when there are no character
/                      variables in the input dataset (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: hasvarsc v2.0;

%macro hasvarsc(ds,varlist,casesens=no);
  %local varmatch varlistc;
  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));
  %let varlistc=%varlistc(&ds);
  %if not %length(&varlistc) %then %do;
%put NOTE: (hasvarsc) There are no character variables in the input dataset therefore;
%put NOTE: (hasvarsc) the character variable(s) you are testing for will not be found.;
    %let varmatch=%match(,&varlist,casesens=&casesens);
0
  %end;
  %else %do;
    %let varmatch=%match(&varlistc,&varlist,casesens=&casesens);
    %if not %length(&_nomatch_) %then 1;
    %else 0;
  %end;
%mend hasvarsc;
