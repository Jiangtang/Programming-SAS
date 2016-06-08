/*<pre><b>
/ Program   : fixiso8601.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 27-Feb-2014
/ Purpose   : In-datastep macro to give ranges for partial ISO 8601 dates
/ SubMacros : none
/ Notes     : This accepts as a parameter the name of a text variable that
/             contains an ISO 8601 datetime of the form YYYY-MM-DDThh:mm:ss.ss
/             or an ISO 8601 date of the form YYYY-MM-DD . This is the only
/             pattern this macro can work with at present.
/
/             The macro has to be used as part of a data step. See usage notes.
/
/             This macro takes the ISO date string and creates the numeric
/             variables DATELO, DATEHI, TIMELO, TIMEHI, DTTMLO and DTTMHI which
/             have suitable formats that follow the pattern of the input ISO
/             date string. You must make sure that your input dataset does not
/             contain variables of the same name.
/
/             This macro uses the following working variables: _yy _mm _dd _hh
/             _min _ss _nmiss so you must make sure that your input dataset does
/             not contain variables of the same name. These working variables
/             will be dropped in the data step. A variable named _obsno which is
/             set equal to _n_ is also created and kept.
/
/             The main purpose of this macro is to fix partial dates. This is
/             reflected by the --LO and --HI variables. If the input date is not
/             partial then the --LO and --HI values will be the same. If the
/             input date is a pure date of the form YYYY-MM-DD and the date is
/             not partial then DATELO = DATEHI but since the time is not present
/             then this will be regarded as partial with the time missing and so
/             you will have a difference in the TIMELO, TIMEHI, DTTMLO and DTTMHI
/             values.
/
/             Where the input date or datetime is partial then this macro does
/             not impute a value but rather gives you the range of values that
/             is covered as the difference between the --LO and --HI values. You
/             use these as part of an algorithm to impute a "fixed" value if you
/             need to. You can also use these high and low values to match on
/             time periods if you need to. In this last case you might get
/             multiple matches on time period and you may need to select on one
/             of these.
/
/             If there is an overlap with a time period then the following
/             condition will be true, which you could use as part of a 
/             "left join", "on" condition using SQL:
/                   (a.start<=b.end) and (b.start<=a.end)
/
/             You can use date low and high values to compare with period low
/             and high values using the formula above to find overlapping
/             periods. If you are imputing a date then you would identify the
/             periods that are overlapped, choose which of those period is the
/             more important one and the imputed date would normally be the
/             highest of the two start values. You may also wish not to assign
/             to a period if there is more than one overlapping period.
/
/ Usage     : data mydset2;
/               set mydset;
/               %fixiso8601(isodtc);
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ datestr           (pos) Name of the character variable that contains the
/                   ISO 8601 date of the form YYYY-MM-DDThh:mm:ss.ss
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Aug13         New (v1.0)
/ rrb  27Feb14         Add _obsno variable (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: fixiso8601 v1.1;

%macro fixiso8601(datestr);

  *===== assign values to working variables =====;
  _yy=input(substr(&datestr,1,4),?? 4.);
  _mm=input(subpad(&datestr,6,2),?? 2.);
  _dd=input(subpad(&datestr,9,2),?? 2.);
  _hh=input(subpad(&datestr,12,2),?? 2.);
  _min=input(subpad(&datestr,15,2),?? 2.);
  _ss=input(subpad(&datestr,18),?? BEST5.);
  _obsno=_n_;

  *========= do the date part ==========;
  _nmiss=nmiss(_yy,_mm,_dd);
  if _nmiss=0 then do;
    datelo=mdy(_mm,_dd,_yy);
    datehi=datelo;
  end;
  else if missing(_dd) and not missing(_mm) then do;
    datelo=mdy(_mm,1,_yy);
    datehi=intnx('month',datelo,0,'end');
  end;
  else if missing(_mm) and not missing(_dd) then do;
    datelo=mdy(1,_dd,_yy);
    datehi=mdy(12,_dd,_yy);
  end;
  else if not missing(_yy) then do;
    datelo=mdy(1,1,_yy);
    datehi=intnx('year',datelo,0,'end');
  end;
  else do;
    datelo=.;
    datehi=.;
  end;

  *========= do the time part ==========;
  _nmiss=nmiss(_hh,_min,_ss);
  if _nmiss=0 then do;
    timelo=hms(_hh,_min,_ss);
    timehi=timelo;
  end;
  else if _nmiss=3 then do;
    timelo=hms(0,0,0);
    timehi=hms(23,59,59.9);
  end;
  else if missing(_hh) then do;
    if not missing(_min) and not missing(_ss) then do;
      timelo=hms(0,_min,_ss);
      timehi=hms(23,_min,_ss);
    end;
    else if not missing(_min) then do;
      timelo=hms(0,_min,0);
      timehi=hms(23,_min,59.9);
    end;
    else if not missing(_ss) then do;
      timelo=hms(0,0,_ss);
      timehi=hms(23,59,_ss);
    end;
  end;
  else if missing(_min) then do;
    if not missing(_hh) and not missing(_ss) then do;
      timelo=hms(_hh,0,_ss);
      timehi=hms(_hh,59,_ss);
    end;
    else if not missing(_hh) then do;
      timelo=hms(_hh,0,0);
      timehi=hms(_hh,59,59.9);
    end;
    else if not missing(_ss) then do;
      timelo=hms(_hh,0,_ss);
      timehi=hms(_hh,59,_ss);
    end;
  end;
  else if missing(_ss) then do;
    timelo=hms(_hh,_min,0);
    timehi=hms(_hh,_min,59.9);
  end;

  *==== create the datetime part ======;
  dttmlo=dhms(datelo,0,0,timelo);
  dttmhi=dhms(datehi,0,0,timehi);

  format datelo datehi yymmdd10. 
         timelo timehi time11.2
         dttmlo dttmhi E8601DT23.2
  ;
  drop _yy _mm _dd _hh _min _ss _nmiss;

%mend fixiso8601;
