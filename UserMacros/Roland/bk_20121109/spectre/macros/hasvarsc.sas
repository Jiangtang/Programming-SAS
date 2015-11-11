/*<pre><b>
/ Program   : hasvarsc.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
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
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: hasvarsc v1.1;

%macro hasvarsc(ds,varlist,casesens=no);
%local varmatch;
%if not %length(&casesens) %then %let casesens=no;
%let casesens=%upcase(%substr(&casesens,1,1));

%let varmatch=%match(%varlistc(&ds),&varlist,casesens=&casesens);

%if not %length(&_nomatch_) %then 1;
%else 0;

%mend;
