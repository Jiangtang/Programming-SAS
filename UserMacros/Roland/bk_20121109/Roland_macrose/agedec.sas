/*<pre><b>
/ Program   : agedec.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 03-Apr-2008
/ Purpose   : In-datastep function-style macro to calculate the age of a person
/             on a date as a decimal age.
/ SubMacros : none
/ Notes     : You use this in a data step as shown in the usage notes. The 
/             fractional part of the age will be based on the number of days
/             since last birthday compared with the number of days from the
/             next birthday to the last birthday. Use this macro if this matches
/             the definition for the calculation of age. There is no particular
/             merit of this strict method over using days-since-birth/365.25 
/             except it will always be correct on the integer number of years.
/
/             Note that an assumption being made in the code is that for people
/             born on the 29th Feb on leap years and with 29th Feb recorded on 
/             their birth certificates then they are legally a year older on
/             1st March on non-leap years. This is true in the UK, presumably in
/             the US as well, but for other countries, they might legally be a 
/             year older on the 28th Feb on non-leap years. If that is the case
/             then you can set the parameter to mar1=no and 28Feb will be used
/             as the birthday for non-leap years.
/ Usage     : data test;
/               agedec=%agedec(dob,date);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dob               (pos) Date of birth
/ date              (pos) Date on which age is to be calculated
/ mar1=yes          Whether those born on Feb29 on a leap year are legally a
/                   year older on Mar1 on non-leap years. If set to "no" (no
/                   quotes) then Feb28 is assumed. It is highly recommended you
/                   keep to the default of "yes" unless you have sound knowledge
/                   otherwise.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  03Apr08         mar1=yes parameter added for version 2.0
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

%mend;
