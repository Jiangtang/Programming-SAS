%macro LastContents / des="Print the contents of the last table";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       LastContents
        Author:     Chris Swenson
        Created:    2010-10-07

        Purpose:    Print the contents of the last table

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if %eval(%sysfunc(exist(&syslast, %str(DATA))) + %sysfunc(exist(&syslast, %str(VIEW))))=1 %then %do;;

        proc contents data=&syslast varnum;
        run;

    %end;
    %else %put NOTE: The last data set does not exist.;

%mend LastContents;
