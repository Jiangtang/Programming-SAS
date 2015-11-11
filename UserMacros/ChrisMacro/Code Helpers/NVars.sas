%macro NVars(ds) / des='Number of vars';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       NVars
        Author:     Chris Swenson
        Created:    2010-07-20

        Purpose:    Output the number of variables in a data set

        Arguments:  ds - input data set to count variables

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check if the table exists */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: The data set argument is blank.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&ds, %str(DATA))) + %sysfunc(exist(&ds, %str(VIEW))))=0 %then %do;
        %put %str(W)ARNING: %sysfunc(compbl(The &ds data set does not exist)).;
        %return;
    %end;

    /* Manage scope */
    %local arg dsid vid rc;

    /* Open data set */
    %let dsid=%sysfunc(open(&ds));

        %let NVars=%sysfunc(attrn(&dsid, NVars));

    /* Close data set */
    %let rc=%sysfunc(close(&dsid));

    /* Output type */
    &NVars

%mend NVars;
