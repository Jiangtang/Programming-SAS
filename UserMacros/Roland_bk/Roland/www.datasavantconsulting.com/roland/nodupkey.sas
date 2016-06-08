/*<pre><b>
/ Program   : nodupkey.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 28-Sep-2008
/ Purpose   : To sort "nodupkey" but list observations being dropped so that
/             they can be investigated and accounted for.
/ SubMacros : %sortedby %attrn
/ Notes     : This is for where all observations that are dropped will need to
/             be accounted for.
/ Usage     : %nodupkey(ds,var1 var2 var3)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Dataset to be sorted.
/ by                (pos) List of "by" variables to sort by.
/ dsout             (pos) Output dataset. Will default to input dataset if not
/                   specified.
/ msg=WARNING       Message to put out with the listed duplicates
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  28Sep08         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: nodupkey v1.0;

%macro nodupkey(dsin,by,dsout,msg=WARNING);

%local error;
%let error=0;

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (nodupkey) No parameter define to dsin=;
%end;

%if &error %then %goto error;

%if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());
%if not %length(&by) %then %let by=%sortedby(%scan(&dsin,1,%str(%()));

%if not %length(&by) %then %do;
  %let error=1;
  %put ERROR: (nodupkey) No parameter define to by=;
%end;

%if &error %then %goto error;

proc sort data=&dsin out=_nodup;
  by &by;
run;

data &dsout _nodup;
  set _nodup;
  by &by;
  if first.%scan(&by,-1,%str( )) then output %scan(&dsout,1,%str(%());
  else output _nodup;
run;

data _null_;
  set _nodup;
  if _n_=1 then put "&msg: (nodupkey) The following %attrn(_nodup,nobs)
observations were dropped after a nodup sort by ""&by"" ";
  put (_all_) (=);
run;

proc datasets nolist;
  delete _nodup;
run;
quit;


%goto skip;
%error:
%put ERROR: (nodupkey) Leaving macro due to error(s) listed.;
%skip:
%mend;
