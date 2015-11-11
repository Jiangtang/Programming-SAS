%macro AgeCalc(date,dob) / des='Calculate age';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       AgeCalc
        Author:     Chris Swenson
        Created:    2009-04-29

        Purpose:    Calculate age based on documentation found at 
                    http://support.sas.com/kb/24/808.html

        Arguments:  date - date to calculate the age from
                    dob  - date of birth of the person(s) in question

        Usage:      Use the macro as a function within a data step or procedure, 
                    for example: age=%AgeCalc(today(), DateOfBirth)

        Caution:    The formula will not work for people born on Feb 29 who celebrate
                    on Feb 28. This code handles the celebration day as Mar 01. The
                    code will also not work where/when the Gregorian calendar was not
                    in use. See the online documenation for futher details.

        Notes:      The intck function returns the number of months betweeen the DOB 
                    and the date. The day functions return a 0 or 1 if the day of the
                    DOB is greater than the day of the date to correct for leap
                    years. Dividing by 12 returns the number of years, and the floor
                    function rounds down for colloquial use.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    floor( (intck('month', &dob, &date) - ( day(&date) < day(&dob) )) / 12)

%mend AgeCalc;
