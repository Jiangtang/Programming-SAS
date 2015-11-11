%macro FindTable(lib,terms) / des="Find a table in a library";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       FindTable
        Author:     Chris Swenson
        Created:    2010-06-14

        Purpose:    Find a table in a library

        Arguments:  lib   - library to search
                    terms - one or more terms to search for, separted by spaces

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let lib=%upcase(&lib);
    %let terms=%upcase(&terms);

    /* Check arguments */
    %if "&lib"="" %then %do;
        %put %str(E)RROR: Missing library argument.;
        %return;
    %end;
    %if %sysfunc(libref(&lib)) ne 0 %then %do;
        %put %str(W)ARNING: Specified library does not exist.;
        %return;
    %end;
    %if "&terms"="" %then %do;
        %put %str(E)RROR: Missing terms argument.;
        %return;
    %end;

    /* Identify how many by variables are specified */
    %local count next i msg;
    %let count=1;
    %let next=%scan(&terms, &count);

    %do %until("&next"="");

        %let count=%eval(&count+1);
        %let next=%scan(&terms, &count);

    %end;

    %let count=%eval(&count-1);
    %put NOTE: Number of by variables specified: &count;

    /****************************************************************************/

    /* Copy VTable */
    proc sql;
        create table _vtable_ as
        select * from sashelp.vtable
        where upcase(libname)="&LIB"
        ;
    run;

    %let user_mprint=%sysfunc(getoption(mprint));
    option nomprint;

    /* Set default message */
    %let msg=%str(E)RROR- No matches found in &lib for &terms..;

    /* Search for variable */
    data _null_;
        set _vtable_ end=end;

        where 
        (
    %do i=1 %to &count;
        index(upcase(memname), "%scan(&terms, &i)")
        %if &i ne &count %then %do;
        or
        %end;
    %end;
        )
        ;

        if _n_=1 then put "NOTE: Possible matches:";
        put "%str(W)ARNING- " memname;
        if end then do;
            put "NOTE-";
            call symputx('msg', "%str(W)ARNING- Matches found in &lib for &terms.. See above.");
        end;
    run;

    proc sql;
        drop table _vtable_;
    quit;

    %put &msg;

    option &user_mprint;

%mend FindTable;
