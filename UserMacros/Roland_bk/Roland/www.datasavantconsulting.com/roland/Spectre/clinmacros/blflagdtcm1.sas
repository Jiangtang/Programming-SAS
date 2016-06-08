/*<pre><b>
/ Program      : blflagdtcm1.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 02-Jan-2015
/ Purpose      : Clinical reporting utility macro to flag baseline observations
/                where the datetimes for comparison are held in a 20 character
/                ISO 8601 format string.
/ SubMacros    : none
/ Notes        : This is a free utility macro that is placed in the clinical
/                macro library because it is the more appropriate place for it.
/                You do not need a licence to use this macro.
/
/                This macro compares two character datetime values having an
/                ISO 8601 form. These will have names like ----DTC in CDISC
/                data and that is why "dtc" makes up part of the name of this
/                macro.
/
/                This is a method 1 type of comparison which is why this macro
/                name ends with "m1". Each method has its own rules as will be
/                explained in this header. You can create your own "method"
/                macros based on this macro to satisfy your requirements.
/
/                This macro can be used to flag baseline observations in the
/                very simple case of the last non-missing value for a grouping
/                where the timepoint is less than the treatment start or, if
/                the timepoint is fully specified to include the time for both
/                timepoints being compared, then an exact match on timepoint is
/                also considered to be a baseline value (a method 1 requirement)
/
/                All variables need to be present in the input dataset,
/                including a blank baseline flag variable.
/
/                All parameters must be given a value, otherwise the macro will
/                exit with diagnostic message(s).
/
/                The output dataset sort order will be that defined to the
/                groupbyvars parameter with the missing or invalid date values
/                first followed by the pre-reference date(time) values followed
/                by the post-reference date(time) values in date(time) order.
/
/
/                METHOD 1 works as follows:
/                --------------------------
/                Missing values will not be flagged as baseline
/                If a datetime is partial and the datepart of that is not then
/                  the datepart will be used. If the datepart itself is partial
/                  then it will not be flagged as baseline.
/                If the timepart is missing for either date then a date
/                  comparison is done as detailed below.
/                For a date (not datetime) comparison then for a value to be
/                  baseline it has to occur before the reference date.
/                For a full datetime comparison then a baseline value must
/                  occur before or exactly at the reference datetime.
/
/
/ Usage        : %blflagdtcm1(dsin=test,dsout=flagged,blflagvar=blf,blset="Y",
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
/                   STUDY SUBJECT PARAMETER. These variables should exclude the
/                   date or datetime of the observation.
/ valvar            Value variable (that will be ignored for missing values)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Jan15         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: blflagdtcm1 v1.0;

%macro blflagdtcm1(dsin=,
                   dsout=,
                   blflagvar=,
                   blset=,
                   trtstartvar=,
                   tmptvar=,
                   groupbyvars=,
                   valvar=,
                   debug=n);

  %local err errflag savopts;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dsin) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to dsin=;
    %let errflag=1;
  %end;

  %if not %length(&dsout) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to dsout=;
    %let errflag=1;
  %end;

  %if not %length(&blflagvar) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to blflagvar=;
    %let errflag=1;
  %end;

  %if not %length(&blset) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to blset=;
    %let errflag=1;
  %end;

  %if not %length(&trtstartvar) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to trtstartvar=;
    %let errflag=1;
  %end;

  %if not %length(&tmptvar) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to tmptvar=;
    %let errflag=1;
  %end;

  %if not %length(&groupbyvars) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to groupbyvars=;
    %let errflag=1;
  %end;

  %if not %length(&valvar) %then %do;
    %put &err: (blflagdtcm1) Nothing specified to valvar=;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;


  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));


  %let savopts=%sysfunc(getoption(notes));

  %if &debug NE Y %then %do;
    options nonotes;
  %end;


  data _blflag;
    set &dsin;
    *- Assign temporary date and datetime variables for comparison -;
    *- (using '??' to prevent log messages for invalid values).    -;
    _dt=input(subpad(&tmptvar,1,10),?? yymmdd10.);
    _dtm=input(&tmptvar,?? E8601dt.);
    _dtref=input(subpad(&trtstartvar,1,10),?? yymmdd10.);
    _dtmref=input(&trtstartvar,?? E8601dt.);
    _preref=0;
    if not missing(&valvar) then do;
      if (.<_dtm<=_dtmref) OR (.<_dt<_dtref) then _preref=1;
      else if (.<_dtmref<_dtm) OR (.<_dtref<_dt) then _preref=2;
    end;
    format _dt _dtref date9. _dtm _dtmref datetime21.2 ;
  run;


  *- sort in groupby, _preref and date, datetime order -;
  proc sort data=_blflag;
    by &groupbyvars _preref _dt _dtm;
  run;


  options &savopts;


  *- merge the view with the data and set the baseline flag -;
  data &dsout;
    set _blflag;
    by &groupbyvars _preref;
    if last._preref and _preref=1 then &blflagvar=&blset;
    %if &debug NE Y %then %do;
      DROP _dt _dtm _dtref _dtmref _preref;
    %end;
  run;


  *- tidy up -;
  %if &debug NE Y %then %do;
    options nonotes;
    proc datasets nolist memtype=data;
      delete _blflag;
    quit;
  %end;


  options &savopts;

  %goto skip;
  %exit; %put &err: (blflagdtcm1) Leaving macro due to problem(s) listed;
  %skip:

%mend blflagdtcm1;
