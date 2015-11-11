%macro SetVars(ds,mvar,type=MULTI,vtype=,where=) / des="Set variables to m. vars";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       SetVars
        Author:     Chris Swenson
        Created:    2010-10-18

        Purpose:    Create one or more macro variables from the variable names in a 
                    data set. The generated macro variable can either be a list 
                    within one macro variable or multiple macro variables named with 
                    the specified prefix and appended observation number.

        Arguments:  ds     - input data set
                    mvar   - macro variable to generate
                    type=  - either MULTI for multiple macro variables with a number
                             appended or LIST for for one macro variable that contains
                             a list of values
                    vtype= - variable type to set as macro variables, either C for
                             character or N for numeric
                    where= - additional filter criteria for a column

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
        2010-12-29  CAS     Modified the manner in which macro variables are reported.
        2011-05-20  CAS     Completely revised program to use normal DATA and PROC
                            steps instead of the I/O functions, which were causing
                            issues when used repeatedly for some unknown reason.
        2011-05-26  CAS     Added filter for variable type: either character or
                            numeric. Leave blank for both.
        2011-05-26  CAS     Added where option and filter step.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    %let mvar=%upcase(&MVAR);
    %let type=%upcase(&TYPE);

    /* Check arguments */
    %if "&DS"="" %then %do;
        %put %str(E)RROR: Missing data set argument.;
        %return;
    %end;
    %if %sysfunc(exist(&DS))=0 %then %do;
    %if %sysfunc(exist(&DS, VIEW))=0 %then %do;
        %put %str(E)RROR: Data set or view does not exist.;
        %return;
    %end;
    %end;
    %if "&MVAR"="" %then %do;
        %put %str(E)RROR: Missing macro variable name argument.;
        %return;
    %end;
    %if "&TYPE"="" %then %do;
        %put %str(E)RROR: No type specified. Please use MULTI or LIST.;
        %return;
    %end;
    %if %index(*LIST*MULTI*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid type specified. Please use MULTI or LIST.;
        %return;
    %end;
    %if "&VTYPE" ne "" %then %do;
        %let vtype=%substr(%upcase(&VTYPE), 1, 1);
        %if %index(*C*N*,*&VTYPE*)=0 %then %do;
            %put %str(E)RROR: %str(I)nvalid variable type (VTYPE) specified. Please use C or N.;
            %return;
        %end;
    %end;


    /********************************************************************************
       Delete Macro Variables
     ********************************************************************************/

    %put ;
    %put NOTE: Deleting macro variables that begin with "&MVAR".;
    %put ;

    /* Copy VMacro for specified variables */
    /* REVISION 2011-05-10 CAS: Added scope level to filter macro variables for deletion */
    proc sql;
        create table _delete_ as
        select * from sashelp.vmacro
        where substr(upcase(name), 1, length("&MVAR"))=("&MVAR")
          and scope='GLOBAL'
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
       Create New Macro Variables
     ********************************************************************************/

    /* Output contents */
    proc contents data=&DS out=_contents_
    %if %superq(WHERE)=%str() %then %do;
        (keep=name type)
    %end;
        noprint;
    run;

    /* Sort by variable number */
    proc sort data=_contents_;
        by varnum;
    run;

    /* REVISION 2011-05-26 CAS: Added filter step */
    %if "&VTYPE" ne "" 
     or %superq(WHERE) ne %str()
    %then %do;

        data _contents_;
            set _contents_;
            where 
        %if &VTYPE=C %then %do;
            type=2
        %end;
        %else %if &VTYPE=N %then %do;
            type=1
        %end;
        %if "&VTYPE" ne "" and %superq(WHERE) ne %str()
        %then %str( and )
        %if %superq(WHERE) ne %str() %then %do;
            &WHERE
        %end;
            ;
        run;

    %end;

    /* Declare global variables */
    %global &MVAR.CNT;

    %if &TYPE=MULTI %then %do;

        data _null_;
            set _contents_ end=end;
            call symputx(compress("&MVAR" || put(_n_, 8.)), name, 'G');
            if end then call symputx("&MVAR.CNT", put(_n_, 8.), 'G');
        run;

    %end;

    %else %if &TYPE=LIST %then %do;

        %global &MVAR;

        proc sql noprint;
            select name
            into :&MVAR separated by ' '
            from _contents_
            ;
        quit;

        %let &MVAR.CNT=1;

    %end;


    /********************************************************************************
       Report New Macro Variables
     ********************************************************************************/

    /* Obtain new macro variables */
    proc sql noprint;
        create table _mvars_ as
        select name, value
        from sashelp.vmacro
        where scope="GLOBAL"
          and substr(name, 1, length("&MVAR"))=upcase("&MVAR")

        /* Order the variables by the number on the variable */
        order by input(compress(name, '', 'kd'), 8.)
        ;
    quit;

    /* Write macro variables to log */
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

    /* Drop temporary table */
    %local user_notes user_mprint;
    %let user_notes=%sysfunc(getoption(notes));
    %let user_mprint=%sysfunc(getoption(mprint));
    option nomprint nonotes;
    proc sql;
        drop table _delete_ table _mvars_;
    quit;
    option &USER_NOTES;
    option &USER_MPRINT;

%mend SetVars;
