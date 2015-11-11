/*<pre><b>
/ Program   : age.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : In-datastep function-style macro to calculate the age of a person
/             on a date.
/ SubMacros : none
/ Notes     : Used in a data step it calculates the age of a person, given a
/             date and a date of birth, as an integer number of years.
/
/             Use this in a data step as shown in the usage notes.
/ Usage     : data test;
/               age=%age(dob,date);
/===============================================================================
/ REQUIREMENTS SPECIFICATION:
/ --id--  ---------------------------description--------------------------------
/ REQ001: To calculate the age as an integer number of years.
/ REQ002: Should be used within a data step.
/ REQ003: Macro parameters should be positional.
/ REQ004: This macro should be a function-style macro that returns a result to
/         a data step variable.
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dob               (pos) Date of birth
/ date              (pos) Date on which age is to be calculated
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  27Mar09         Requirements specification added to header
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: age v1.0;

%macro age(dob,date);
  year(&date)-year(&dob)-1+((month(&date)>month(&dob)) 
  or ((month(&date)=month(&dob)) and (day(&date)>=day(&dob))))
%mend age;
