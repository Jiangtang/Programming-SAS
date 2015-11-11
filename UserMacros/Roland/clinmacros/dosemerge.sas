/*<pre><b>
/ Program   : dosemerge.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Mar-2013
/ Purpose   : Clinical reporting utility macro to merge dose by date
/ SubMacros : %lookahead %commas %nlobs
/ Notes     : This is a free utility macro that is placed in the clinical macro
/             library because it is the more appropriate place for it. You do
/             not need a licence to use this macro.
/
/             You should not use this macro blindly. You will need to review the
/             parameter setting to ensure this is working according to your site
/             standards.
/ Usage     : 
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin=             Input dataset (usually an AE dataset)
/ date=             Name of the date variable in the input dataset
/ subject=          Name of the variable containing the unique subject
/                   identifier in the input dataset.
/ id=               Further identifier in the input dataset that distinguishes
/                   observations having the same date.
/ dsout=            Name of the output dateset with the dose added
/ dsdose=           Dose dataset
/ doselevel=        Name of the numeric variable containing the dose level
/ dosestart=        Date variable for start of dose
/ dosestop=         Date variable for stop of dose. 
/ dosesubject=      Name of the variable containing the unique subject
/                   identifier in the dose dataset. If left blank it will
/                   default to what was defined to subj=.
/ fixgaps=yes       By default, fix any dose gaps by changing the stop date to
/                   the day before the following start date.
/ fixoverlaps=yes   By default, fix any overlaps between a stop date and the 
/                   following start date by changing the stop date to the day
/                   before the following start date. If this is set to "no" then
/                   the lowest non-zero dose will be used.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  28Sep08         This is now classed as a "Clinical reporting" macro
/ rrb  08May11         Code tidy
/ rrb  15Mar13         Header update to make it clear that this is a free macro
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dosemerge v1.0;

%macro dosemerge(dsin=,
                 date=,
              subject=,
                   id=,
                dsout=,
               dsdose=,
            doselevel=,
            dosestart=,
             dosestop=,
          dosesubject=,
              fixgaps=yes,
          fixoverlaps=yes
               );

  %local errflag err nobs nobs2;
  %let err=ERR%str(OR);
  %let errflag=0;


       /*-------------------------------------------------*
          Check we have enough parameters set to continue
        *-------------------------------------------------*/

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) dsin= parameter not set;
  %end;

  %if not %length(&date) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) date= parameter not set;
  %end;

  %if not %length(&subject) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) subject= parameter not set;
  %end;

  %if not %length(&dsout) %then %let dsout=%scan(&dsin,1,%str(%());

  %if not %length(&dsdose) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) dsdose= parameter not set;
  %end;

  %if not %length(&doselevel) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) doselevel= parameter not set;
  %end;

  %if not %length(&dosestart) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) dosestart= parameter not set;
  %end;

  %if not %length(&dosestop) %then %do;
    %let errflag=1;
    %put &err: (dosemerge) dosestop= parameter not set;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&dosesubject) %then %let dosesubject=&subject;

  %if not %length(&fixgaps) %then %let fixgaps=yes;
  %let fixgaps=%upcase(%substr(&fixgaps,1,1));

  %if not %length(&fixoverlaps) %then %let fixoverlaps=yes;
  %let fixoverlaps=%upcase(%substr(&fixoverlaps,1,1));



     /*-------------------------------------------------*
                  Start processing the data
      *-------------------------------------------------*/

  proc sort data=&dsdose out=_dose;
    by &subject &dosestart &dosestop;
  run;

  %lookahead(dsin=_dose,bygroup=&subject,vars=&dosestart,lookahead=1)

  data _dose;
    set _dose;
    %if "&fixgaps" EQ "Y" %then %do;
      if &dosestop<(&dosestart.1-1) then &dosestop=&dosestart.1-1;
    %end;
    %if "&fixoverlaps" EQ "Y" %then %do;
      if (&dosestart.1 NE .) and (&dosestop>=&dosestart.1)
        then &dosestop=&dosestart.1-1;
    %end;
    %else %do;
      if &doselevel=0 then &doselevel=99999;
    %end;
    drop &dosestart.1;
  run;


  %let nobs=%nlobs(%scan(&dsin,1,%str(%()));

  proc sql noprint;
    create table _doseout as
    select a.*, d.&doselevel from &dsin as a
    left join _dose as d
    on a.&subject=d.&dosesubject
    and d.&dosestart<=a.&date<=d.&dosestop
    order by %commas(a.&subject &id a.&date d.&doselevel);
  quit;

  data &dsout;
    set _doseout;
    by &subject &id &date;
    if first.&date;
    if &doselevel=99999 then &doselevel=0;
  run;

  %let nobs2=%nlobs(%scan(&dsout,1,%str(%()));

  %if &nobs2 NE &nobs %then 
  %put &err: (dosemerge) Input dataset had &nobs observations but 
output dataset has &nobs2 observations.;


     /*-------------------------------------------------*
                       Tidy up and exit
      *-------------------------------------------------*/

  proc datasets nolist;
    delete _dose _doseout;
  run;
  quit;


  %goto skip;
  %exit: %put &err: (dosemerge) Leaving macro due to problem(s) listed;
  %skip:

%mend dosemerge;
