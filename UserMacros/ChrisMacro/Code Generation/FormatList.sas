%macro FormatList(ds,upper=Y,test=N) / des='Generate a list of variables and formats';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       FormatList
        Author:     Chris Swenson
        Created:    2011-04-21

        Purpose:    Output a list of variables and their formats for re-doing
                    placing in a format statement.

        Arguments:  ds     - The data set to output variable formats from
                    upper= - Y/N whether to set the variable names to upper case
                    test=  - Y/N whether to test the macro

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

    /* Check for argument values in (Y N) */
    %let TEST=%upcase(&TEST);
    %if %index(*Y*N*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for TEST.;
        %put %str(E)RROR- Please use one of the following: Y or N.;
        %return;
    %end;

    /* Output contents */
    proc contents data=&DS out=_contents_
    %if &TEST=N %then %do;
        (keep=name varnum format formatl formatd)
    %end;
        noprint;
    run;

    /* Sort contents by variable number */
    proc sort data=_contents_;
        by varnum;
    run;

    /* Associate with clipboard */
    filename _cb_ clipbrd;

    /* Copy select statement to clipboard */
    data _null_;
        file _cb_;
        set _contents_;
    %if &UPPER=Y %then %do;
        name=upcase(name);
    %end;
        if formatd=0 then varformat=compress(format || put(formatl, 8.) || '.');
        else varformat=compress(format || put(formatl, 8.) || '.' || put(formatd, 8.));
        put name varformat;
    run;

    /* Clear association with clipboard */
    filename _cb_ clear;

    /* Drop temporary table */
    %if &TEST=N %then %do;
        proc sql;
            drop table _contents_;
        quit;
    %end;

%mend FormatList;
