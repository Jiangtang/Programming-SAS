%macro ViewLib(srclib,tgtlib,where=,target=) / des="Create a library of views";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ViewLib
        Author:     Chris Swenson
        Created:    2010-06-21

        Purpose:    Create a library that consists of views of the source library.
                    This is useful for the 'view' library to act as a reference for
                    the source library. The target= option can be used to rename
                    the data sets in the source library. For example, if a library
                    has 10,000 tables and 4,000 start with 'ZC_', you can set up a 
                    'ZC' view library, removing the 'ZC_' from the names:

                    %ViewLib(
                        Clarity, 
                        ZC,
                        where=substr(memname, 1, 3)='ZC_',
                        target=substr(memname, 4, length(memname)-3)
                    );

        Arguments:  srclib  - source library
                    tgtlib  - target library
                    where=  - filter criteria for source library
                    target= - function to modify the target name

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check arguments */
    %if "&srclib"="" %then %do;
        %put %str(E)RROR: Source library argument missing.;
        %return;
    %end;
    %if %sysfunc(libref(&srclib))>0 %then %do;
        %put %str(E)RROR: Source library does not exist.;
        %return;
    %end;
    %if "&tgtlib"="" %then %do;
        %put %str(E)RROR: Target library argument missing.;
        %return;
    %end;
    %if %sysfunc(libref(&tgtlib))>0 %then %do;
        %put %str(E)RROR: Target library does not exist.;
        %return;
    %end;

    /* Upcase arguments */
    %let srclib=%upcase(&srclib);
    %let tgtlib=%upcase(&tgtlib);

    /* Check 'where' macro variables */
    %let filter=1;
    %if %superq(where)=%str() %then %let filter=0;

    /* Copy SASHELP VTABLE */
    proc sql;
        create table _vtable_ as
        select * from sashelp.vtable
        where upcase(libname)="&SRCLIB"
        ;
    quit;

    /* Filter VTABLE for specified library and create macro variables */
    %let vwcnt=0;
    data _null_;
        set _vtable_ end=end;

        /* Filter for additional criteria */
    %if &filter=1 %then %do;
        where %unquote(%superq(where));
    %end;

        /* Create the target variable, with modifications if specified */
    %if "&target" ne "" %then %do;
        target=&target;
    %end;
    %else %do;
        target=memname;
    %end;

        /* Set macro variables for table names and total table count */
        call symputx(compress('source' || put(_n_, 8.)), memname);
        call symputx(compress('target' || put(_n_, 8.)), target);
        if end then call symputx('vwcnt', put(_n_, 8.));
    run;

    %if &vwcnt=0 %then %do;
        %put %str(W)ARNING: No records found to match specified criteria.;
        %return;
    %end;

    /* Create views in target library and drop VTABLE */
    proc sql;

    %local vw;
    %do vw=1 %to &vwcnt;

        create view &tgtlib..&&target&vw as
        select * from &srclib..&&source&vw
        ;

    %end;

        drop table _vtable_;
    quit;

%mend ViewLib;
