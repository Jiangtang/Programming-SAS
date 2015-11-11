%macro RenameVars(inds,outds,filter,test=N) / des='Rename variables in data set';

    /********************************************************************************
       BEGIN MACRO HEADER
     ********************************************************************************

        Name:       RenameVars.sas
        Author:     Chris Swenson
        Created:    2009-06-25

        Purpose:    Rename variables within a data set based on specifications. Please
                    note that this macro overwrites the specified data set. A backup is
                    created in work with "_backup" appended to the specified data set name.

        (W)ARNING:  This macro overwrites the specified data set in the first argument
                    with specified variables renamed.

        Arguments:  inds   - Any data set with variables matching those in the RenameVars
                             data set.
                    outds  - Output data set with renamed variables. The input can be used.
                    filter - Text to filter the RenameVars data set.
                    test   - Flag to indicate whether or not to test the macro.

        Dependency: A data set in work named "RenameVars" is required to exist. The
                    data set should have the following variables: Source, Target, Filter.
                    Source is the original variable name, Target is the name to be used
                    to rename the source variable, and Filter is the criteria to match
                    when using the macro.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2010-08-02  CAS     Heavy revisions to make the process more global and avoid
                            issues with overwriting data (unless desired).

        YYYY-MM-DD  III     Please use this format and insert new entries above

    /********************************************************************************
       END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Settings
     ********************************************************************************/

    %let test=%upcase(&test);

    /* Check Arguments */
    %if "&inds"="" %then %do;
        %put %str(E)RROR: No input data set specified (argument 1).;
        %return;
    %end;
    %if "&outds"="" %then %do;
        %put %str(E)RROR: No output data set specified (argument 2).;
        %return;
    %end;
    %if "&filter"="" %then %do;
        %put %str(E)RROR: No filter specified (argument 3).;
        %return;
    %end;
    %if %index(*Y*N*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid value for the test argument. Please use Y or N.;
        %return;
    %end;

    /* Check for RenamVars data set */
    %if %sysfunc(exist(renamevars))=0 %then %do;
        %put %str(E)RROR: The RenameVars data set does not exist.;
        %return;
    %end;


    /********************************************************************************
       Generate Remapping Code
     ********************************************************************************/

    /* Filter specifications based on system and table source */
    data _filter_;
        set RenameVars;
        /* Filter specs based on system and table */
        where upcase(filter)=upcase("&filter")
          and not missing(source)
          and not missing(target)
        ;
    run;

    /* Output the contents of the specified data set */
    proc contents data=&inds out=_contents_(keep=name) noprint varnum;
    run;

    proc sort data=_contents_;
        by name;
    run;

    /* Create mapping table by left joining the contents of the data set with the specifications */
    proc sql;
        create table _mapping_ as
        select distinct c.name as source, s.target
        from _contents_ c inner join _filter_ s
          on upcase(c.name)=upcase(s.source)
        ;
    quit;

    /* Create rename expression (rexpr), used to populate the PROC DATASETS rename statement */
    data _mapping_;
        set _mapping_;
        /* Concatenate the source variable with an equal sign and the target variable */
        rexpr=compress(source||'='||target);
        /* Clear the labels on all variables */
        attrib _all_ label='';
    run;

    /* Load rename expression into a macro variable */
    %local mapto;
    %let mapto=;

    proc sql noprint;
        select rexpr
        into :mapto separated by " "
        from _mapping_
        ;
    quit;

    /* Find the setting for quote length maximum */
    %let user_quotelenmax=%sysfunc(getoption(quotelenmax));

    /* Turn off quote length max message briefly */
    options noquotelenmax;

    /* Check the MapTo macro variable */
    %if "&mapto"="" %then %do;
        %put %str(W)ARNING: The table does not contain any variables listed in the RenameVars data set to rename.;
        %goto exit;
    %end;

    %put NOTE: MAPTO=&MAPTO;


    /********************************************************************************
       Output and Rename
     ********************************************************************************/

    /* Copy data set to destination */
    %if &inds ne &outds %then %do;
        data &outds;
            set &inds;
        run;
    %end;

    /* Drop temporary tables */
    %if &test=N %then %do;
        proc sql;
            drop table _filter_ table _mapping_ table _contents_;
        quit;
    %end;

    /* Rename variables to match specifications */
    proc datasets nolist nodetails;
        modify &outds;
            /* Rename variables */
            rename &mapto;
            /* Remove all labels - Note: The attrib statement works although it is red in the editor. -- CAS */
            attrib _all_ label='';
    run;
    quit;

    /* Reset options to original settings */
    %exit:
    options &user_quotelenmax;
    %put NOTE: Options changed to &user_quotelenmax..;

    /********************************************************************************
       END OF MACRO
     ********************************************************************************/

%mend RenameVars;
