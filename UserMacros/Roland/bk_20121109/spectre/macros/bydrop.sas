/*<pre><b>
/ Program   : bydrop.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Mar-2007
/ Purpose   : To drop by-group residuals
/ SubMacros : none
/ Notes     : If the output dataset name is missing then the dropping of the by-
/             group residuals will be applied to the input dataset.
/             You would typically use this macro to drop the end observations
/             for a previous day.
/ Usage     : %bydrop(dsin,by1 by2)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              (pos) Input dataset.
/ by                (pos) By group variables. If none specified then first
/                   "sortedby" variable assumed.
/ dsout             (pos) Output dataset. If not specified then defaults to same
/                   as input dataset.
/ fraction=0.1      If this fraction or less compared with maximum by-group
/                   observation count then drop residuals.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: bydrop v1.0;

%macro bydrop(dsin,by,dsout,fraction=0.1);

%local error bymax;
%let error=0;

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (bydrop) No input dataset specified;
%end;

%if &error %then %goto error;

%if not %length(&by) %then %let by=%scan(%sortedby(%scan(&dsin,1,%str(%())),1,%str( ));

%if not %length(&by) %then %do;
  %let error=1;
  %put ERROR: (bydrop) No "by" variables specified and none could be assumed;
%end;

%if &error %then %goto error;

%if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());

proc sort data=&dsin out=_bydrop;
  by &by;
run;

proc summary nway data=_bydrop(keep=&by);
  class &by;
  output out=_bydropa(drop=_type_ rename=(_freq_=_count));
run;
proc summary nway data=_bydropa;
  id _count;
  output out=_bydropb(drop=_type_ _freq_);
run;
data _null_;
  set _bydropb;
  call symput('bymax',compress(put(_count,11.)));
run;

data _bydropa;
  set _bydropa(where=((_count/&bymax)>&fraction));
  keep &by;
run;

data &dsout;
  merge _bydropa(in=_by) _bydrop;
  by &by;
  if _by;
run;

proc datasets nolist;
  delete _bydrop _bydropa _bydropb;
run;
quit;

%goto skip;
%error:
%put ERROR: (bydrop) Leaving bydrop macro due to error(s) listed;
%skip:
%mend;
