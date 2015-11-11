%macro ObsMac(ds,invar,mvar,where=) / des="Convert observations to macro variables";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ObsMac
        Author:     Chris Swenson
        Created:    2010-06-14

        Purpose:    Convert observations to macro variables

        Arguments:  ds     - input data set
                    invar  - input variable(s)
                    mvar   - macro variable(s) to generate
                    where= - filter criteria for input data set

        NOTE:       The number of INVAR and MVAR arguments, separated by spaces,
                    should be the same.

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
        2011-02-01  CAS     Changed second argument to "invar" instead of "var", since
                            I keep using "var" for the third argument...
        2011-05-10  CAS     Added scope level to filter macro variables for deletion.
        2011-05-25  CAS     Updated the entire macro to handle the INVAR and MVAR
                            arguments as buffered arguments; that is, the arguments
                            now allow for multiple variables to be specified at once.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Internal Macro Program
     ********************************************************************************/

    %macro COUNTW(args, dlm) / des='Uses COUNTW in sas 9.2, alternative in prior versions';

        %if %substr(&SYSVER, 1, 3)=9.1 %then %do;

            %local countw arg;
            %let countw=1;
            %let arg=%scan(%superq(ARGS), &COUNTW, &DLM);

            %do %while("&ARG" ne "");
                %let countw=%eval(&COUNTW+1);
                %let arg=%scan(&ARGS, &COUNTW, &DLM);
            %end;

            %let countw=%eval(&countw-1);

            &COUNTW

        %end;
        %else %do;
            %sysfunc(countw(&ARGS, &DLM))
        %end;

    %mend COUNTW;


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    /* Upper case arguments */
    %let invar=%upcase(&INVAR);
    %let mvar=%upcase(&MVAR);

    /* Check arguments */
    %if "&DS"="" %then %do;
        %put %str(E)RROR: Missing data set argument.;
        %return;
    %end;
    %if %sysfunc(exist(&DS))=0 %then %do;
        %put %str(E)RROR: Data set does not exist.;
        %return;
    %end;
    %if "&INVAR"="" %then %do;
        %put %str(E)RROR: Missing variable argument.;
        %return;
    %end;
    %if "&MVAR"="" %then %do;
        %put %str(E)RROR: Missing argument for macro variable name.;
        %return;
    %end;

    /* Compare counts of INVAR and MVAR */
    %local invarcnt mvarcnt;
    %let invarcnt=%countw(&INVAR, %str( ));
    %let mvarcnt=%countw(&MVAR, %str( ));
    %if &INVARCNT ne &MVARCNT %then %do;
        %put %str(E)RROR: Please specify the same number of input and output variables.;
        %return;
    %end;

    /* Check specified input variable */
    proc contents data=&DS out=_contents_ noprint;
    run;

    %local check;
    %let check=0;
    data _null_;
        set _contents_ end=end;
        where upcase(name) in (
    %local v;
    %do v=1 %to &INVARCNT;
        "%upcase(%scan(&INVAR, &V, %str( )))"
        %if &V ne &INVARCNT %then %str(, );
    %end;
        );
        if end then call symputx('check', put(_n_, 8.));
    run;

    proc sql;
        drop table _contents_;
    quit;

    %if &CHECK ne &INVARCNT %then %do;
        %put %str(E)RROR: The specified input variable(s) do not exist in &DS..;
        %return;
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
        where (
    %local w;
    %do w=1 %to &MVARCNT;
        substr(upcase(name), 1, length("%upcase(%scan(&MVAR, &W, %str( )))"))="%upcase(%scan(&MVAR, &W, %str( )))"
        %if &W ne &MVARCNT %then %str( or );
    %end;
        )
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
       Create Macro Variables
     ********************************************************************************/

    /* Set variable in data set to macro variable */
    data _null_;
        set &DS end=end;
    %if %superq(WHERE) ne %str() %then %do;
        where &WHERE;
    %end;

    %local c;
    %do c=1 %to &INVARCNT;
        call symputx(compress("%scan(&MVAR, &C, %str( ))" || put(_n_, 8.)), %scan(&INVAR, &C, %str( )), 'G');
        if end then call symputx("%scan(&MVAR, &C, %str( ))cnt", put(_n_, 8.), 'G');
    %end;
    run;


    /********************************************************************************
       Report New Macro Variables
     ********************************************************************************/

    %local i cur;
    %do i=1 %to &INVARCNT;

        %let cur=%scan(&MVAR, &I, %str( ));

        /* Obtain new macro variables */
        proc sql noprint;
            create table _temp_ as
            select name, value
            from sashelp.vmacro
            where scope="GLOBAL"
              and substr(name, 1, length("&CUR"))=upcase("&CUR")

            /* Order the variables by the number on the variable */
            order by input(compress(name, '', 'kd'), 8.)
            ;
        quit;

        proc append base=_mvars_ data=_temp_;
        run;

        proc sql;
            drop table _temp_;
        quit;

    %end;

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

%mend ObsMac;
