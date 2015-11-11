/*<pre><b>
/ Program   : agedec.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : In-datastep function-style macro to calculate the age of a person
/             on a date as a decimal age.
/ SubMacros : none
/ Notes     : Used in a data step to calculate the age of a person as a
/             fractional number of years. The fractional part of the age will be
/             based on the number of days since last birthday compared with the
/             number of days from the past birthday to the next birthday.
/
/             Note that an assumption being made in the code is that for people
/             born on the 29th Feb on leap years and with 29th Feb recorded on 
/             their birth certificates then they are legally a year older on
/             1st March on non-leap years. This is true in the UK, presumably in
/             the US as well, but for other countries, they might legally be a 
/             year older on the 28th Feb on non-leap years. If that is the case
/             then you can set the parameter to mar1=no and 28Feb will be used
/             as the birthday for non-leap years for those born on 29Feb.
/ Usage     : data test;
/               agedec=%agedec(dob,date);
/===============================================================================
/ REQUIREMENTS SPECIFICATION:
/ --id--  ---------------------------description--------------------------------
/ REQ001: The fractional part of the age will be calculated as the number of
/         day since last birthday divided by the number of days between the last
/         birthday and the next birthday.
/ REQ002: Should be used within a data step.
/ REQ003: Date parameters should be positional.
/ REQ004: This macro should be a function-style macro that returns a result to
/         a data step variable.
/ REQ005: The user be allowed to specify mar1=no so that people born on a leap
/         year on 29FEB celebrate their birthday on 28Feb rather than Mar01
/         which is the default.
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dob               (pos) Date of birth
/ date              (pos) Date on which age is to be calculated
/ mar1=yes          Whether those born on Feb29 on a leap year are legally a
/                   year older on Mar1 on non-leap years. If set to "no" (no
/                   quotes) then Feb28 is assumed for celebrating the birth date
/                   otherwise Mar01 is assumed. It is highly recommended you
/                   keep to the default of "yes" (i.e. Mar01 is assumed) unless
/                   you have sound knowledge otherwise.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  03Apr08         mar1=yes parameter added for version 2.0
/ rrb  27Mar09         Requirements specification added to header
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: agedec v2.0;

%macro agedec(dob,date,mar1=yes);

  %local age;

  %if not %length(&mar1) %then %let mar1=yes;
  %let mar1=%substr(%upcase(&mar1),1,1);

  %let age=(
  year(&date)-year(&dob)-(month(&date)<month(&dob) or (month(&date)=month(&dob) 
  and day(&date)<day(&dob)))
  );

  %if &mar1 NE N %then %do;
    &age + 
    (
    ( &date-(intnx('year',&dob-1,&age,'S')+1) ) / 
    (
    (intnx('year',&dob-1,&age+1,'S')+1) -
  
    (intnx('year',&dob-1,&age,'S')+1)
    )
    )
  %end;
  %else %do;
    &age + 
    (
    ( &date-intnx('year',&dob,&age,'S') ) / 
    (
     intnx('year',&dob,&age+1,'S') -
 
     intnx('year',&dob,&age,'S')
    )
    )
  %end;

%mend agedec;
