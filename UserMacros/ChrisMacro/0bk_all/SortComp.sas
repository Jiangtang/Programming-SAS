%macro SortComp(base,compare,id,out=Comparison,lib=WORK,exclude=,expect=N,dup=Y,max=32767,test=N) / des='Sort and compare data sets';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       SortComp
        Author:     Chris Swenson
        Created:    2009-05-06

        Purpose:    Sort and compare two data sets

        Arguments:  base     - base data set
                    compare  - comparison data set
                    id       - ID to compare the data sets on
                    out=     - output data set name, defaulted to Compare
                    lib=     - output library, defaulted to WORK
                    exclude= - variables to exclude from the comparison
                    expect=  - Y/N whether differences are expected
                    dup=     - Y/N whether to check for duplicates
                    max=     - maximum number of comparison, defaulted to 32,767
                    test=    - Y/N whether to test the macro

        Output:     OUT        - output from the COMPARE procedure
                    OUT_differ - output from the COMPARE procedure for only records 
                                 in common
                    OUT_in_1   - output from the COMPARE procedure for only records
                                 in the BASE data set
                    OUT_in_2   - output from the COMPARE procedure for only records
                                 in the COMPARE data set

                    where OUT is the value of the OUT= argument, defaulted to Comparison

        To do:
            - Handle the Compare_differ data set better: sometimes it's rednundant
            - Add check to compare variable length/format - otherwise comparison
              will not work right

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-01-11  CAS     Revised handling of splitting data using dynamic SQL IDs.
                            Added new output that includes only data that differs
                            between the two source data sets.
        2011-02-25  CAS     Added EXPECT argument to suppress issue messages.
        2011-04-08  CAS     Added output library argument.
        2011-04-21  CAS     Added check for blank OUT argument.
        2011-04-22  CAS     Added override of SYSLAST.
        2011-06-03  CAS     Added override of check for duplicates with DUP option

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    /* REVISION 2011-02-25 CAS: Added expect argument */
    %let test=%upcase(%substr(&TEST, 1, 1));
    %let expect=%upcase(%substr(&EXPECT, 1, 1));

    %if %superq(BASE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for BASE.;
        %return;
    %end;
    %if %superq(COMPARE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for COMPARE.;
        %return;
    %end;
    %if %superq(ID)=%str() %then %do;
        %put %str(E)RROR: No argument specified for ID.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&BASE, %str(DATA))) + %sysfunc(exist(&BASE, %str(VIEW))))=0 %then %do;
        %put %str(E)RROR: The base data set does not exist.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&COMPARE, %str(DATA))) + %sysfunc(exist(&COMPARE, %str(VIEW))))=0 %then %do;
        %put %str(E)RROR: The compare data set does not exist.;
        %return;
    %end;
    %if %index(*N*Y*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid TEST argument. Please use Y or N.;
        %return;
    %end;
    %if %index(*N*Y*,*&EXPECT*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid EXPECT argument. Please use Y or N.;
        %return;
    %end;
    /* REVISION 2011-04-21 CAS: Added check for blank OUT argument */
    %if %superq(OUT)=%str() %then %do;
        %put %str(E)RROR: No argument specified for OUT.;
        %return;
    %end;

    /* Check for argument values in (Y N) */
    %let DUP=%upcase(&DUP);
    %if %index(*Y*N*,*&DUP*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for DUP.;
        %put %str(E)RROR- Please use one of the following: Y or N.;
        %return;
    %end;

    /* Message type */
    /* REVISION 2011-02-25 CAS: Added step for EXPECT processing */
    %local msgtyp;
    %if &EXPECT=N %then %let msgtyp=%str(W)ARNING;
    %else %if &EXPECT=Y %then %let msgtyp=NOTE;


    /********************************************************************************
       Sort and Compare
     ********************************************************************************/

    %put NOTE: Data sets: Base=&BASE | Compare=&COMPARE;

    %if &DUP=Y %then %do;

        /* Check for duplicates */
        %local base_dist comp_dist msg sqlon sqlmiss cnt1 cnt2 cnt3 i;
        %DupCheck(&BASE, &ID);
        %let base_dist=&DISTINCT;
        %if &BASE_DIST ne YES %then %do;
            %put %str(E)RROR: Data set &BASE is not distinct by &ID..;
            %return;
        %end;

        %DupCheck(&COMPARE, &ID);
        %let comp_dist=&DISTINCT;
        %if &COMP_DIST ne YES %then %do;
            %put %str(E)RROR: Data set &COMPARE is not distinct by &ID..;
            %return;
        %end;

    %end;

    /* Data set 1 Sort */
    proc sort data=&BASE out=&LIB.._sort_base_ %if "&EXCLUDE" ne "" %then %do; (drop=&EXCLUDE) %end; ;
        by &ID;
    run;

    /* Data set 2 Sort */
    proc sort data=&COMPARE out=&LIB.._sort_compare_ %if "&EXCLUDE" ne "" %then %do; (drop=&EXCLUDE) %end; ;
        by &ID;
    run;

    /* Comparison of the base and compare data sets. */
    proc compare
            base=&LIB.._sort_base_ compare=&LIB.._sort_compare_
            out=&LIB..&OUT outbase outcomp outnoequal
            noprint maxprint=&MAX;
        id &ID;
    run;

    /* If there are observations in the table with differences, output message */
    /* REVISION 2011-02-25 CAS: Modified message with new argument option */
    %if %nobs(&LIB..&OUT)>0 %then %let msg=&MSGTYP.: The data sets &BASE and &COMPARE differ! Please see data set &LIB..&OUT.!;

    /* Otherwise, output note and drop the tables made by the macro */
    %else %do;

        %let msg=NOTE: The data sets &BASE and &COMPARE are the same for records in common.;

        %if &TEST=N %then %do;

            proc sql;
                drop table &LIB..&OUT;
            quit;

        %end;

    %end;

    %if &TEST=N %then %do;

        proc sql;
            drop table &LIB.._sort_base_ table &LIB.._sort_compare_;
        quit;

    %end;


    /********************************************************************************
       Check for Differences in Records
     ********************************************************************************/

    /* Set SQL variables */
    /* REVISION 2011-01-11 CAS: Added more flexible SQL statement handling */
    %let sqlon=;
    %let sqlmiss=;
    %do i=1 %to %sysfunc(countw(&ID, %str( )));
        %let sqlon=&SQLON a.%scan(&ID, &I)=b.%scan(&ID, &I);
        %let sqlmiss=&SQLMISS missing(b.%scan(&ID, &I));
    %end;
    %let sqlon=%sysfunc(tranwrd(&SQLON, %str( ), %str( and )));
    %let sqlmiss=%sysfunc(tranwrd(&SQLMISS, %str( ), %str( and )));

    /* Compare the data sets for differences in members */
    proc sql;
        create table &LIB..&OUT._in_1 as
        select a.*
        from &BASE a

        left join &COMPARE b
        on &SQLON

        where &SQLMISS
        ;

        create table &LIB..&OUT._in_2 as
        select a.*
        from &COMPARE a

        left join &BASE b
        on &SQLON

        where &SQLMISS
        ;
    quit;

    /* Set observation count variables */
    %let cnt1=%nobs(&LIB..&OUT._in_1);
    %let cnt2=%nobs(&LIB..&OUT._in_2);

    /* Drop temporary tables */
    %if &TEST=N %then %do;

        proc sql;
        %if &CNT1=0 %then %do;
            drop table &LIB..&OUT._in_1;
        %end;

        %if &CNT2=0 %then %do;
            drop table &LIB..&OUT._in_2;
        %end;
        quit;

    %end;

    /* Remove remainder */
    /* REVISION 2011-01-11 CAS: Added process to split out only those that differ */
    %if %sysfunc(exist(&LIB..&OUT)) %then %do;

        proc sql;
        %if %sysfunc(exist(&LIB..&OUT._in_1)) %then %do;
            create table &LIB.._temp_ as
            select a.*
            from &LIB..&OUT a
            left join &LIB..&OUT._in_1 b
            on &SQLON
            where &SQLMISS
            ;
        %end;

        %if %sysfunc(exist(&LIB..&OUT._in_2)) %then %do;
            create table &LIB..&OUT._differ as
            select a.*

          %if %sysfunc(exist(&LIB.._temp_)) %then %do;
            from &LIB.._temp_ a
          %end;
          %else %do;
            from &LIB..&OUT a
          %end;

            left join &LIB..&OUT._in_2 b
            on &SQLON
            where &SQLMISS
            ;
        %end;

        %else %if %sysfunc(exist(_temp_)) %then %do;

            create table &LIB..&OUT._differ as
            select *
            from &LIB.._temp_
            ;

        %end;

        %if %sysfunc(exist(_temp_)) %then %do;
            drop table &LIB.._temp_;
        %end;
        quit;

        %if %sysfunc(exist(&OUT._differ)) %then %do;

            %let cnt3=%nobs(&LIB..&OUT._differ);

            /* REVISION 2011-03-04 CAS: Added a sort for the _differ data set */
            %if &CNT3 ne 0 %then %do;

                proc sort data=&LIB..&OUT._differ;
                    by &ID _type_;
                run;

            %end;

        %end;
        %else %let cnt3=0;

    %end;
    %else %let cnt3=0;

    /* Drop temporary table */
    %if &TEST=N %then %do;

        proc sql;
        %if &CNT3=0 and %sysfunc(exist(&LIB..&OUT._differ)) %then %do;
            drop table &LIB..&OUT._differ;
        %end;
        quit;

    %end;


    /********************************************************************************
       Report
     ********************************************************************************/

    /* REVISION 2011-04-22 CAS: Added output override */
    %if %sysfunc(exist(&OUT)) %then %let syslast=&OUT;
    %else %let syslast=COMPARE;

    /* REVISION 2011-02-25 CAS: Modified messages with new argument option */

    %put &MSG;

    %if &CNT1=0 %then %put NOTE: Data set &BASE does not include additional records.;
    %else %put &MSGTYP.: Data set &BASE includes additional records! See %upcase(&LIB..&OUT._IN_1).;

    %if &CNT2=0 %then %put NOTE: Data set &COMPARE does not include additional records.;
    %else %put &MSGTYP.: Data set &COMPARE includes additional records! See %upcase(&LIB..&OUT._in_2).;

    %if &CNT3=0 %then %put NOTE: Records in common do not differ.;
    %else %put &MSGTYP.: Records in common differ! See &LIB..&OUT._differ for details.;

%mend SortComp;
