/*<pre><b>
/ Program   : nodata.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Mar-2013
/ Purpose   : Clinical reporting utility macro to produce a "No Data" report
/ SubMacros : %titlelen %titlegen %bytitle
/ Notes     : This is a free utility macro that is placed in the clinical macro
/             library because it is the more appropriate place for it. You do
/             not need a licence to use this macro.
/
/             This macro will see if a global macro variable _nodata_ has been
/             set up and will use any contents assigned to it for the message
/             for the report.
/
/             #byval/#byvar title lines wil be dropped and all footnotes dropped
/             but these will be fully restored at the end of the macro. 
/
/ Usage     : %if not %nobs(dset) %then %do;
/               %nodata
/               %goto skip;
/             %end;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------         
/ skip=10           Number of blank lines to throw before the "no data" message
/ msg=NO DATA FOUND TO MEET THIS CRITERION  Message to display (no quotes)
/                   unless global macro variable _nodata_ has been set.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb                  Logic changed so this macro does not check any datasets
/                      for zero observations any more.
/ rrb  13Feb07         "macro called" message added
/ rrb  19Mar08         "nowd" option added to "proc report" call
/ rrb  15Mar13         Header update to make it clear that this is a free macro
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: nodata v2.1;

%macro nodata(skip=10,msg=NO DATA FOUND TO MEET THIS CRITERION);

%global _nodata_;


%*- store all the titles and footnotes along with their true lengths -;
%titlelen

*- create a dummy dataset for producing the message -;
data _nodata;
  %if %length(&_nodata_) %then %do;
    length dummy $ %length(&_nodata_);
    do i=1 to &skip;
      dummy=' ';
      output;
    end;
    dummy="&_nodata_";
    output;
  %end;
  %else %do;
    length dummy $ %length(&msg);
    do i=1 to &skip;
      dummy=' ';
      output;
    end;
    dummy="&msg";
    output;
  %end;
run;

%*- remove any #byvar #byval last title -;
%bytitle

*- remove any footnotes -;
footnote1;

proc report nowd data=_nodata;
  columns dummy;
  define dummy / display ' ';  
run;

proc datasets nolist;
  delete _nodata;
run;
quit;

%titlegen(titlelen)
  

%mend;
