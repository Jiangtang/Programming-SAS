/*<pre><b>
/ Program   : age.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : In-datastep function-style macro to calculate the age of a person
/             on a date.
/ SubMacros : none
/ Notes     : You use this in a data step as shown in the usage notes. The age
/             will be an integer. 
/ Usage     : data test;
/               age=%age(dob,date);
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
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: age v1.0;

%macro age(dob,date);
year(&date)-year(&dob)-1+((month(&date)>month(&dob)) 
or ((month(&date)=month(&dob)) and (day(&date)>=day(&dob))))
%mend;
