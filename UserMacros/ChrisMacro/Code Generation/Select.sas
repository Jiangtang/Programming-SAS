%macro Select(ds,prefix=,exclude=) / des='Generate SQL select statement';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       Select
        Author:     Chris Swenson
        Created:    2011-04-15

        Purpose:    Generate a SQL select statement based on the columns in a dataset
                    and copy the list to the OS for pasting in code elsewhere.

        Arguments:  ds       - data set name
                    prefix=  - prefix to put in front of column names, used for
                               referencing the table or an alias
                    exclude= - exclude columns from the output

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
    %if %eval(%sysfunc(exist(&DS)) + %sysfunc(exist(&DS, VIEW)))>0 %then %do;
      %if %sysfunc(exist(&DS, VIEW))=0 %then %do;
        %put %str(E)RROR: The specified data set does not exist.;
        %return;
      %end;
    %end;

    /* Add a dot to the prefix */
    %if "&PREFIX" ne "" %then %let prefix=&PREFIX..;

    /* Output contents */
    proc contents data=&DS out=_contents_(keep=varnum name) noprint;
    run;

    /* Sort contents by variable number */
    proc sort data=_contents_;
        by varnum;
    run;

    /* Filter the excluded columns */
    %local i var;
    %if %superq(EXCLUDE) ne %str() %then %do;

        data _contents_;
            set _contents_;
            where upcase(name) not in (
        %do i=1 %to %sysfunc(countw(&EXCLUDE));
            %let var=%upcase(%scan(&EXCLUDE, &I, %str( )));
            "&VAR"
            %if &I ne %sysfunc(countw(&EXCLUDE)) %then %str(, );
        %end;
            );
        run;

    %end;

    /* Associate with clipboard */
    filename _cb_ clipbrd;

    /* Copy select statement to clipboard */
    data _null_;
        file _cb_;
        set _contents_;
        if _n_=1 then put "  &PREFIX" name;
        else put ", &PREFIX" name;
    run;

    /* Clear association with clipboard */
    filename _cb_ clear;

    /* Drop temporary table */
    proc sql;
        drop table _contents_;
    quit;

%mend Select;
