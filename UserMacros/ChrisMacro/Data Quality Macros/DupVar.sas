%macro DupVar(ds,by,test=N) / des='Find var(s) creating duplicate records';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       DupVar
        Author:     Chris Swenson
        Created:    2010-08-02

        Purpose:    Find variable(s) that may be involved in duplication of records

        Arguments:  ds    - intput data set
                    by    - variable(s) that should identify distinct records
                    test= - Y/N to indicate whether to test the macro

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2010-12-01  CAS     Replaced macro iteration with COUNTW function. Updated
                            output messages.
        2011-03-03  CAS     Modified output when no variables are identified.
                            Added test argument and processing.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let test=%upcase(%substr(&TEST, 1, 1));

    /* Check arguments */
    %if "&DS"="" %then %do;
        %put %str(E)RROR: Missing data set argument.;
        %return;
    %end;
    %if "&BY"="" %then %do;
        %put %str(E)RROR: Missing by variable(s) argument.;
        %return;
    %end;
    %if %index(*N*Y*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid TEST argument. Please use Y or N.;
        %return;
    %end;

    /** Set up additional macro variables **/

    %local firstvar count othervars equation1 equation2 user_notes user_mprint;

    /* First variable in by group */
    %let firstvar=%scan(&BY, 1);

    /* Identify how many by variables are specified */
    /* REVISION 2010-12-01 CAS: Replaced macro iteration with COUNTW function */
    %let count=%sysfunc(countw(&BY, %str( )));
    %put NOTE: Number of by variables specified: &COUNT;

    /****************************************************************************/

    /* Output contents dropping 'by' variables */
    proc contents
        data=&DS(drop=&BY)
        out=_contents_(keep=name varnum)
        noprint;
    run;

    proc sort data=_contents_;
        by varnum;
    run;

    /* Set other variables to macro variable list */
    proc sql noprint;
        select name
        into :othervars separated by ' '
        from _contents_
        order by varnum
        ;
    quit;
    %let othervars=&OTHERVARS;

    /* Add equation for select statement */
    data _contents_;
        set _contents_;
        format equation1 equation2 $1000.;
        equation1=compbl('count(distinct ' || name || ')') || ' as ' || name;
        equation2=compbl('max(' || name || ')') || ' as ' || name;
    run;

    /* Set equations to macro variable */
    proc sql noprint; 
        select equation1
        into :equation1 separated by ', '
        from _contents_
        order by varnum
        ;

        select equation2
        into :equation2 separated by ', '
        from _contents_
        order by varnum
        ;
    quit;

    /* Create new table with summary of other variables by 'by' variables */
    proc sql;
        create table _counts_ as
        select distinct
        &EQUATION1
        from &DS
        group by 
    %do i=1 %to &COUNT; 
        %scan(&BY, &I) %if &I ne &COUNT %then %str(,);
    %end;
        ;

        create table _max_ as
        select
        &EQUATION2
        from _counts_
        ;
    quit;

    /* Rotate data */
    proc transpose
            data=_max_
            out=_transpose_(rename=(_name_=Variable col1=Maximum))
    ;
        var &OTHERVARS;
    run;

    %nolabel(_transpose_);

    proc sort data=_transpose_;
        by descending Maximum;
    run;

    %if &TEST=N %then %do;

        %let user_notes=%sysfunc(getoption(notes));
        %let user_mprint=%sysfunc(getoption(mprint));
        option nomprint;
        option nonotes;

    %end;

    proc sql;
        drop table _contents_
             table _counts_
             table _max_
        ;
    quit;

    /* REVISION 2010-12-01 CAS: Updated output messages */
    data _results_;
        set _transpose_;
        where Maximum gt 1;
        if _n_=1 then do;
            put %str(" ");
            put "%str(E)RROR- The following variables are possible identifiers of distinct records,";
            put "%str(E)RROR- along with %sysfunc(catx(',', %upcase(&BY))):";
            put %str(" ");
        end;
        put "%str(E)RROR- " Variable Maximum= ;
    run;
    %put ;

    /* REVISION 2011-03-03 CAS: Modified output when no variables are identified. */
    %if %nobs(_results_)=0 %then %do;
        %put %str(W)ARNING- The data set %upcase(&DS) is either distinct by %sysfunc(catx(',', %upcase(&BY)));
        %put %str(W)ARNING- or there are repeats of the same distinct values.;
    %end;

    %if &TEST=N %then %do;

        proc sql;
            drop table _transpose_ table _results_;
        quit;

        option &USER_NOTES;
        option &USER_MPRINT;

    %end;

%mend DupVar;
