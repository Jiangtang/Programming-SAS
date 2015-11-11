%macro FreqLoop(ds,vars,by,out=) / des="Output frequencies for variables";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       FreqLoop
        Author:     Chris Swenson
        Created:    2010-07-09

        Purpose:    Output frequencies for variables in a data set

        Arguments:  ds   - input data set
                    vars - one or more variables to output frequencies for
                    by   - split by variable
                    out= - prefix for output data set(s)

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-01-26  CAS     Added capacity to output crosstab (e.g., year*quarter*var)
        2011-04-27  CAS     Added view to check of input data set

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if "&DS"="" %then %do;
        %put %str(E)RROR: No data set specified.;
        %return;
    %end;
    /* REVISION 2011-04-27 CAS: Added view to check */
    %if %eval(%sysfunc(exist(&ds)) + %sysfunc(exist(&ds, VIEW)))=0 %then %do;
        %put %str(E)RROR: The specified data set does not exist.;
        %return;
    %end;
    %if "&vars"="" %then %do;
        %put %str(E)RROR: No variables specified.;
        %return;
    %end;

    %if "&OUT" ne "" %then %do;
        %let out=&OUT._;
    %end;

    /* Obtain list of all variables */
    /* REVISION 2011-01-26 CAS: Modified scan of argument */
    %if %scan(%upcase(&vars), 1, %str( *))=_ALL_ %then %do;

        /* Manage scope */
        %local dsid cnt i rc;

        /* Open data set */
        %let dsid=%sysfunc(open(&ds));

        /* Obtain count of variables */
        %let cnt=%sysfunc(attrn(&dsid, nvars));

        /* For each variable, set to a macro variable */
        %do i=1 %to &cnt;
            %if &i=1 %then %let vars=;
            %let vars=&vars %sysfunc(varname(&dsid, &i));
        %end;

        %put NOTE: Variables = &vars;

        /* Close the data set */
        %let rc=%sysfunc(close(&dsid));

    %end;

    /* Manage macros */
    %local num var;

    /* Set initial scan */
    %let num=1;
    %let var=%scan(&vars, &num, %str( ));

    /* Sort if BY specified */
    %if "&BY" ne "" %then %do;
        proc sort data=&DS out=_temp_;
            by &BY;
        run;
    %end;

    %if "&BY" ne "" %then %do;
    proc freq data=_temp_ noprint;
        by &BY;
    %end;
    %else %do;
    proc freq data=&ds noprint;
    %end;

    /* Loop through each argument until blank */
    /* REVISION 2011-01-26 CAS: Added scan of argument to look at last var for output */
    %do %while("&var" ne "");

        table &var / out=&OUT%sysfunc(tranwrd(&VAR, %str(*), %str(_)));

        /* Increment scan */
        %let num=%eval(&num+1);
        %let var=%scan(&vars, &num, %str( ));

    %end;

    run;

    %if "&BY" ne "" %then %do;
        proc sql;
            drop table _temp_;
        quit;
    %end;

%mend FreqLoop;
