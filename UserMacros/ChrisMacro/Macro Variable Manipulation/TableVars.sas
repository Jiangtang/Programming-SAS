%macro TableVars(libname,tablevar,name=,where=,test=N) / des="Set vars for tables from VTable";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       TableVars
        Author:     Chris Swenson
        Created:    2010-07-02

        Purpose:    Set macro variables for tables from SASHELP.VTable

        Arguments:  libname  - library to set tables for
                    tablevar - name of macro variables for tables
                    name=    - filter for the table name within the library
                    where=   - filter criteria for SASHELP.VTable
                    test=    - whether to test the macro program

        Family:     Macro Variable Generation Macro Program

                    IntoList  - Create a macro variable that is a list of values from
                                a column in a data set. Optionally define the
                                delimiter and filter the input data set.
                    ObsMac    - Create a macro variable that is a list of values from
                                a column in a data set. Optionally define the
                                delimiter and filter the input data set.
                    SetVars   - Create one or more macro variables from the variable
                                names in a data set. The generated macro variable
                                can either be a list within one macro variable or
                                multiple macro variables named with the specified
                                prefix and appended observation number.
                    TableVars - Create one or more macro variables from the variable
                                names in a data set. The generated macro variable can
                                either be a list within one macro variable or
                                multiple macro variables named with the specified
                                prefix and appended observation number.
                    VarMac    - Create macro variables from two columns, where one
                                column names the macro variable and another supplies
                                the value. Optionally filter the input data set.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    /* Uppercase arguments */
    %let libname=%upcase(&LIBNAME);
    %let tablevar=%upcase(&TABLEVAR);
    %let test=%upcase(&TEST);

    /* Check arguments */
    %if "&LIBNAME"="" %then %do;
        %put %str(E)RROR: Libname argument required.;
        %return;
    %end;
    %if %sysfunc(libref(&LIBNAME))>0 %then %do;
        %put %str(E)RROR: Library does not exist.;
        %return;
    %end;
    %if "&TABLEVAR"="" %then %do;
        %put %str(E)RROR: Table variable argument required.;
        %return;
    %end;
    %if %index(*Y*N*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: The test argument is %str(i)nvalid. Please use Y or N.;
        %return;
    %end;


    /********************************************************************************
       Delete Macro Variables
     ********************************************************************************/

    %put ;
    %put NOTE: Deleting macro variables that begin with "&TABLEVAR".;
    %put ;

    /* Copy VMacro for specified variables */
    proc sql;
        create table _delete_ as
        select * from sashelp.vmacro
        where substr(upcase(name), 1, length("&TABLEVAR"))=("&TABLEVAR")
           or upcase(name)=("&TABLEVAR.CNT")
        ;
    quit;

    /* Note: The next step needs to be separate, as the macro deletion needs to
       access SASHELP.VMACRO. If it is used in the step above, it is locked out
       from deleting records in the table. */
    data _null_;
        set _delete_;
        call execute('%symdel ' || name || ';');
    run;


    /********************************************************************************
       Create Macro Variables
     ********************************************************************************/

    %global &TABLEVAR.CNT;
    %local nameflag whereflag;
    %let &TABLEVAR.CNT=0;
    %let nameflag=0;
    %let whereflag=0;

    %put ;
    %put NOTE: Creating macro variables for tables in &LIBNAME.;
    %if %superq(NAME) ne %str() %then %do;
        %put NOTE- where the table name meets the following criteria: &NAME.;
        %let nameflag=1;
    %end;
    %if %superq(WHERE) ne %str() %then %do;
        %put NOTE- where the following criteria is met: &WHERE.;
        %let whereflag=1;
    %end;
    %put ;

    /* Copy vtable */
    proc sql;
        create table _tables_ as
        select * from sashelp.vtable
        where libname="&LIBNAME"
        ;
    quit;

    /* Filter for names */
    %if &NAMEFLAG=1 %then %do;
        data _tables_;
            set _tables_;
            where substr(upcase(memname), 1, %length(&NAME))=%upcase("&NAME");
        run;
    %end;

    /* Set variables */
    data _null_;
        set _tables_ end=end;

    /* Set filter if specified */
    %if &WHEREFLAG=1 %then %do;
        where &WHERE;
    %end;

        /* Declare variables globally then set value */
        call symputx(compress("&TABLEVAR" || put(_n_, 8.)), memname, 'G');

        /* Set count variable */
        if end then call symputx("&TABLEVAR.CNT", put(_n_, 8.), 'G');
    run;


    /********************************************************************************
       Report Created Macro Variables
     ********************************************************************************/

    /* Output created macro variables */
    proc sql noprint;
        create table _mvars_ as
        select name, value
        from sashelp.vmacro
        where scope="GLOBAL"
           and (substr(upcase(name), 1, length("&TABLEVAR"))=("&TABLEVAR")
                or upcase(name)=("&TABLEVAR.CNT"))

        /* Order the variables by the number on the variable */
        order by input(compress(name, '', 'kd'), 8.)
        ;
    quit;

    /* Print varibles to the log */
    data _null_;
        set _mvars_ end=end;
        if _n_=1 then do;
            put "NOTE: The following macro variables were created:";
            put " ";
            put "NOTE- Name " @40 "Value";
            put "NOTE- ---- " @40 "-----";
        end;
        put "NOTE- " name @40 value;
        if end then put "NOTE-";
    run;

    /********************************************************************************/

    /* Obtain option and temporarily turn off */
    %local user_mprint user_notes;
    %let user_mprint=%sysfunc(getoption(mprint));
    %let user_notes=%sysfunc(getoption(notes));
    option NOMPRINT;
    option NONOTES;
    option nomlogic nomfile nosymbolgen;

    /* Drop temporary tables */
    %if &TEST=N %then %do;
        proc sql;
            drop table _delete_
                 table _tables_
                 table _mvars_
            ;
        quit;
    %end;

    /* Reset mprint option to original setting */
    option &USER_NOTES;
    option &USER_MPRINT;

%mend TableVars;
