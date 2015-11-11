%macro NObs(ds,nowarn) / des='Number of obs';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       NObs
        Author:     Chris Swenson
        Created:    2010-07-20

        Purpose:    Output the number of observations in a data set. Modified from
                    a macro found on the SAS website.

        Arguments:  ds     - input data set to count observations
                    nowarn - whether or not to warn the user if the observations
                             cannot be obtained

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

        %let anobs=%sysfunc(attrn(&dsid, ANOBS));
        %let nobs=%sysfunc(attrn(&dsid, NOBS));

    /* Close data set */
    %let rc=%sysfunc(close(&dsid));

    %if %upcase(&nowarn) ne NOWARN %then %do;
        %if &ANOBS=0 %then %put %str(W)ARNING: Unable to access the number of observations in &DS..;
    %end;

    /* Output type */
    &nobs

%mend NObs;
