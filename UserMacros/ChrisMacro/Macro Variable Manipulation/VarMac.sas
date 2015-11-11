%macro VarMac(ds,namevar,valuevar,where=) / des="Create macro variables from two columns";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       VarMac
        Author:     Chris Swenson
        Created:    2010-06-14

        Purpose:    Create macro variables from two columns in a data set

        Arguments:  ds       - input data set
                    namevar  - variable containing the macro variable names
                    valuevar - variable containing the macro variable values
                    where=   - filter criteria for input data set

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

    %if "&DS"="" %then %do;
        %put %str(E)RROR: Missing data set argument.;
        %return;
    %end;
    %if "&NAMEVAR"="" %then %do;
        %put %str(E)RROR: Missing source variable argument.;
        %return;
    %end;
    %if "&VALUEVAR"="" %then %do;
        %put %str(E)RROR: Missing target variable argument.;
        %return;
    %end;


    /********************************************************************************
       Delete Macro Variables
     ********************************************************************************/

    data _null_;
        set &DS;
    %if %superq(where) ne %str() %then %do;
        where &WHERE;
    %end;
        call execute('%symdel ' || &NAMEVAR || ' / nowarn;');
    run;


    /********************************************************************************
       Create Macro Variables
     ********************************************************************************/

    /* Set variable in data set to macro variable */
    data _null_;
        set &DS end=end;
    %if %superq(where) ne %str() %then %do;
        where &WHERE;
    %end;
        call symputx(&NAMEVAR, &VALUEVAR, 'G');
        call symputx(compress(upcase('namevar') || put(_n_, 8.)), upcase(&NAMEVAR), 'L');
        if end then call symputx("&NAMEVAR.CNT", put(_n_, 8.), 'L');
    run;


    /********************************************************************************
       Report Created Macro Variables
     ********************************************************************************/

    /* Select macro variables */
    %local nv;
    proc sql;
        create table _mvars_ as
        select * from sashelp.vmacro
        where scope="GLOBAL"
          and name in (
    %do nv=1 %to &&&NAMEVAR.CNT;
        "&&NAMEVAR&NV"
    %end;
        )
        ;
    quit;

    proc sort data=_mvars_;
        by name;
    run;

    /* Write macro variables to log */
    data _null_;
        set _mvars_ end=end;
        if _n_=1 then do;
            put "NOTE: The following macro variables were created:";
            put " ";
            put "NOTE- Name" @40 "Value";
            put "NOTE- ----" @40 "-----";
        end;
        put "NOTE- " name @40 value;
        if end then put "NOTE-";
    run;

    /* Drop temporary table */
    %local user_notes user_mprint;
    %let user_notes=%sysfunc(getoption(notes));
    %let user_mprint=%sysfunc(getoption(mprint));
    option nomprint nonotes;
    proc sql;
        drop table _mvars_;
    quit;
    option &USER_NOTES;
    option &USER_MPRINT;

%mend VarMac;
