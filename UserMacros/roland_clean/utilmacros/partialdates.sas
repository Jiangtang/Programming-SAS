/*<pre><b>
/ Program   : partialdates.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : In-datastep macro to impute partial dates to a high or low value
/ SubMacros : none
/ Notes     : This macro will accept partial dates in a range of formats defined
/             to the pattern= parameter and impute the date either on the "low"
/             value or "high" value possible as defined to the lohi= parameter
/             given the partial information. Note that many internal variables
/             are created and dropped by this macro. You should ensure that
/             their names do not cause a conflict with existing dataset names.
/             You are free to change these variable names if you need to by
/             resetting the parameters.
/
/             If the year is missing then a missing date will be returned.
/
/ Usage     : data test;
/               datestr="--feb08";
/               %partialdates(datetext=datestr,datevar=date,pattern="ddmmmyy",
/                             lohi=high);
/               format date date9.;
/               put date= datestr=;
/             run;
/             29FEB2008
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ datetext          Name of variable or quoted string literal containing the
/                   date text.
/ datevar           Output SAS date variable (supply your own format)
/ pattern           (quoted) Pattern of the date. Year must be specified as YY
/                   or YYYY. Month specified as MMM for three letter character
/                   month or MM for two digit month. Day of month specified as
/                   MM for the two digit day of the month. Examples are 
/                   "ddmmmyy", "ddmmmyyyy", "dd/mm/yyyy", "dd/mm/yy" (case is
/                   not important). This can be an unquoted character variable
/                   instead for where the pattern varies.
/ lohi=low          (unquoted) Whether to take the lower or higher value of the
/                   possible range of dates. Defaults to "low". You should only
/                   use "low" or "high" (unquoted). Only the first character
/                   will be used for recognition.
/
/                   THE FOLLOWING ARE THE NAMES OF THE TEMPORARY VARIABLES THAT
/                   WILL BE USED IN THIS MACRO AND DROPPED. Change any that might
/                   conflict with your input dataset variable names. Other
/                   temporary variables used and dropped are "dummytext" and
/                   "dummydate".
/
/ yearvar=_year
/ monthvar=_month
/ dayvar=_day
/ yposvar=_ypos
/ ylenvar=_ylen
/ mposvar=_mpos
/ mlenvar=_mlen
/ dposvar=_dpos 
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  09Jul08         lohivar= and patternvar= parameters dropped. All retains
/                      dropped. Pattern can now be a variable as well as a
/                      quoted string for v2.0.
/ rrb  10Jul08         Bug in year length fixed
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: partialdates v2.1;

%macro partialdates(datetext=,
                     datevar=,
                     pattern=,
                        lohi=low,
                     yearvar=_year,
                    monthvar=_month,
                      dayvar=_day,
                     yposvar=_ypos,
                     ylenvar=_ylen,
                     mposvar=_mpos,
                     mlenvar=_mlen,
                     dposvar=_dpos               
                     );

  %local err;
  %let err=ERR%str(OR);

  %let lohi=%upcase(%substr(&lohi,1,1));


  *- set up and retain year, month and day positions and their lengths -;
  &yposvar=index(upcase(&pattern),"YYYY");
  &ylenvar=4;
  if &yposvar<1 then do;
    &yposvar=index(upcase(&pattern),"YY");
    &ylenvar=2;
  end;
  if &yposvar<1 then do;
    _ERROR_=1;
    put "&err: (partialdates) No YY or YYYY found in supplied date pattern " &pattern;
  end;
  &mposvar=index(upcase(&pattern),"MMM");
  &mlenvar=3;
  if &mposvar<1 then do;
    &mposvar=index(upcase(&pattern),"MM");
    &mlenvar=2;
  end;
  if &mposvar<1 then do;
    _ERROR_=1;
    put "&err: (partialdates) No MM or MMM found in supplied date pattern " &pattern;
  end;
  &dposvar=index(upcase(&pattern),"DD");
  if &dposvar<1 then do;
    _ERROR_=1;
    put "&err: (partialdates) No DD found in supplied date pattern " &pattern;
  end;


  *- get the year which might be a four digit or two digit year -;
  if &ylenvar=4 then &yearvar=input(substr(upcase(&datetext),&yposvar,4),?? 4.);
  else do;
    *- temporarily set to the raw two digit year -;
    &yearvar=input(substr(&datetext,&yposvar,2),?? 2.);
    *- now get the 4 digit year with yearcutoff applied if not missing -;
    if not missing(&yearvar) then do;
      dummytext="01JAN"||substr(&datetext,&yposvar,2);
      dummydate=input(dummytext,date7.);
      &yearvar=year(dummydate);
    end;
  end;

  *- if the year is missing then set the date to missing else carry on -;
  if missing(&yearvar) then &datevar=.;
  else do;

    *- get the month which might be 3 letters or a 2 digit number -;
    if &mlenvar=3 then do;
      dummytext="01"||substr(upcase(&datetext),&mposvar,3)||"99";
      dummydate=input(dummytext,?? date7.);
      if missing(dummydate) then do;
        if "&lohi"="L" then &monthvar=1;
        else &monthvar=12;
      end;
      else &monthvar=month(dummydate);
    end;
    else &monthvar=input(substr(&datetext,&mposvar,2),?? 2.);
    if missing(&monthvar) then do;
      if "&lohi"="L" then &monthvar=1;
      else &monthvar=12;
    end;

    *- get the day which will be a 2 digit number -;
    &dayvar=input(substr(&datetext,&dposvar,2),?? 2.);
    if missing(&dayvar) then do;
      if "&lohi"="L" then &dayvar=1;
      else &dayvar=day(intnx("month",mdy(&monthvar,1,&yearvar),1)-1);
    end;

    &datevar=mdy(&monthvar,&dayvar,&yearvar);

  end;

  drop &yposvar &ylenvar &mposvar &mlenvar &dposvar dummytext dummydate;

%mend partialdates;
