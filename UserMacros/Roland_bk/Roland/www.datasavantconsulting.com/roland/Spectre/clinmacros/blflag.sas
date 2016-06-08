/*<pre><b>
/ Program      : blflag.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 15-Jun-2013
/ Purpose      : Clinical reporting utility macro to flag baseline observations
/ SubMacros    : none
/ Notes        : This is a free utility macro that is placed in the clinical macro
/                library because it is the more appropriate place for it. You do
/                not need a licence to use this macro.
/
/                This macro can be used to flag baseline observations in the very
/                simple case of the last non-missing value for a grouping where
/                the timepoint is less than the treatment start. All required
/                variables need to be present in the input dataset including a
/                blank baseline flag variable.
/
/                To cover more varied cases you are free to amend this macro to
/                suit your needs.
/
/                All parameters must be given a value otherwise the macro will
/                exit with a diagnostic message.
/
/ Usage        : %blflag(dsin=test,dsout=flagged,blflagvar=blf,blset="Y",
/                        trtstartvar=start,tmptvar=tmpt,groupbyvars=pat labnm,
/                        valvar=val);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ dsout             Output dataset (modifiers allowed)
/ blflagvar         Baseline flag variable
/ blset             What to set the baseline flag variable to for observations
/                   identified as being baseline.
/ trtstartvar       Treatment start variable
/ tmptvar           Timepoint variable that will be compared to the variable
/                   defined to trtstartvar for the observations to be considered
/                   possible baseline candidates by having an earlier timepoint
/                   value. This and the above variable have to be compatible.
/ groupbyvars       Grouping variables separated by spaces (no quotes) such as:
/                   STUDY SUBJECT PARAMETER
/ valvar            Value variable (that will be tested for missing)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Jun13         New (v1.0)
/ rrb  15Jun13         Header tidy (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: blflag v1.0;

%macro blflag(dsin=,
              dsout=,
              blflagvar=,
              blset=,
              trtstartvar=,
              tmptvar=,
              groupbyvars=,
              valvar=,
              debug=n);

  %local err errflag;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dsin) %then %do;
    %put &err: (blflag) Nothing specified to dsin=;
    %let errflag=1;
  %end;

  %if not %length(&dsout) %then %do;
    %put &err: (blflag) Nothing specified to dsout=;
    %let errflag=1;
  %end;

  %if not %length(&blflagvar) %then %do;
    %put &err: (blflag) Nothing specified to blflagvar=;
    %let errflag=1;
  %end;

  %if not %length(&blset) %then %do;
    %put &err: (blflag) Nothing specified to blset=;
    %let errflag=1;
  %end;

  %if not %length(&trtstartvar) %then %do;
    %put &err: (blflag) Nothing specified to trtstartvar=;
    %let errflag=1;
  %end;

  %if not %length(&tmptvar) %then %do;
    %put &err: (blflag) Nothing specified to tmptvar=;
    %let errflag=1;
  %end;

  %if not %length(&groupbyvars) %then %do;
    %put &err: (blflag) Nothing specified to groupbyvars=;
    %let errflag=1;
  %end;

  %if not %length(&valvar) %then %do;
    %put &err: (blflag) Nothing specified to valvar=;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;


  %if not %length(&debug) %then %let debug=n;
  %let debug=%upcase(%substr(&debug,1,1));



  *- sort in groupby and timepoint order -;
  proc sort data=&dsin out=_blflag;
    by &groupbyvars &tmptvar;
  run;


  *- create a view of the last non-missing values per grouping -;
  data _bltmpt(keep=&groupbyvars &tmptvar) / view=_bltmpt;
    set _blflag;
    by &groupbyvars &tmptvar;
    where not missing(&valvar) and &tmptvar<&trtstartvar;
    if last.%scan(&groupbyvars,-1,%str( ));
  run;


  *- merge the view with the data and set the baseline flag -;
  data &dsout;
    merge _blflag _bltmpt(in=_bl);
    by &groupbyvars &tmptvar;
    if _bl then &blflagvar=&blset;
  run;


  *- tidy up -;
  %if &debug NE Y %then %do;
    proc datasets nolist;
      delete _bltmpt / memtype=view;
      delete _blflag / memtype=data;
    run;
    quit;
  %end;


  %goto skip;
  %exit; %put &err: (blflag) Leaving macro due to problem(s) listed;
  %skip:

%mend blflag;
