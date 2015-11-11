%macro KeepList(ds,upper=Y,sort=Y) / des='Generate a list of variables and formats';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       KeepList
        Author:     Chris Swenson
        Created:    2011-05-16

        Purpose:    Output a list of variables to use in a keep statement.

        Arguments:  ds     - the data set to output variable formats from
                    upper= - y/n whether to set the variable names to upper case
                    sort=  - y/n whether to sort the variables by VARNUM

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check arguments */
    %if %superq(DS)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DS.;
        %return;
    %end;
    %if %sysfunc(exist(&DS))=0 %then %do;
        %put %str(E)RROR: The specified data set does not exist.;
        %return;
    %end;
    %if %superq(UPPER)=%str() %then %do;
        %put %str(E)RROR: No argument specified for UPPER.;
        %return;
    %end;
    %let upper=%upcase(&UPPER);
    %if %index(*N*Y*,*&UPPER*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument for UPPER. Please use Y or N.;
        %return;
    %end;
    %let sort=%substr(%upcase(&SORT), 1, 1);
    %if %index(*N*Y*,*&SORT*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument for SORT. Please use Y or N.;
        %return;
    %end;

    /* Output contents */
    proc contents data=&DS out=_contents_(keep=name varnum) noprint;
    run;

    /* Sort contents by variable number */
    %if &SORT=Y %then %do;
        proc sort data=_contents_;
            by varnum;
        run;
    %end;

    /* Associate with clipboard */
    filename _cb_ clipbrd;

    /* Copy select statement to clipboard */
    data _null_;
        file _cb_;
        set _contents_;
    %if &UPPER=Y %then %do;
        name=upcase(name);
    %end;
        put name;
    run;

    /* Clear association with clipboard */
    filename _cb_ clear;

    /* Drop temporary table */
    proc sql;
        drop table _contents_;
    quit;

%mend KeepList;
