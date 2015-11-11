%macro VarCount(ds,out=,sort=ORDER) / des='Count populated variables in data set';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       VarCount
        Author:     Chris Swenson
        Created:    2010-06-04

        Purpose:    Count populated variables

        Arguments:  ds   - input data set to count populated variables
                    out  - output data set, defaults to ds_counts (without library)
                    sort - the variable to sort the final output by, either ORDER
                           (variable/column order), NAME (variable/column name),
                           COUNT, or PERCENT

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2010-08-19  CAS     Added percentage to output and sorted output by variable.
                            Also added scope argument to call symputx routine.
        2010-10-07  CAS     Added count for data sets outside of SAS. Converted to 
                            final step to SQL for joining with _contents_ and adding 
                            varnum to output. Added sort option.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check argument */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: No data set specified.;
        %return;
    %end;

    /* Set default for output */
    %if "&out"="" %then %let out=%scan(&ds, -1)_counts;
    %if %length(&out) gt 32 %then %do;
        %put %str(W)ARNING: Please specify an output data set name (e.g., out=Contents). The macro attempted to assign a name, but it was too long.;
        %return;
    %end;

    %let sort=%upcase(%substr(&sort, 1, 3));
    %if %index(*COU*NAM*ORD*PER*,*&SORT*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid SORT argument. Please use NAME or ORDER.;
        %return;
    %end;

    /* Obtain contents and sort by data set order */
    proc contents
        data=&ds
        out=_contents_(keep=name varnum)
        noprint;
    run;
    proc sort data=_contents_; by varnum; run;

    /* Create macro variables with variable names and count variables */
    /* Also count how many variables in data set */
    /* REVISION 2010-08-19 CAS: Added scope to call symputx routine */
    %local count;
    data _null_;
        set _contents_ end=end;

        call symputx(compress('var' || put(_n_, 8.)) , name, 'L');
        call symputx(compress('varcnt' || put(_n_, 8.)), compress('Count_' || name), 'L');

        if end then do;
            call symputx('count', put(_n_, 8.), 'L');
        end;
    run;

    /* Count variables in data set */
    %local i;
    data _counts_(keep=Count:);
        set &ds end=end;
        format Count_: 8.;

    %do i=1 %to &count;
        retain &&varcnt&i 0;
        if missing(&&var&i)=0 then &&varcnt&i+1;
    %end;

        if end then output;
    run;

    /* Transpose counts */
    proc transpose
        data=_counts_
        out=_trans_(rename=(col1=Count))
        name=Variable;
    run;
    %NoLabel(_trans_);

    /* Find number of observations */
    /* REVISION 2010-10-07 CAS: Added count for data sets outside of SAS */
    %let nobs=%nobs(&ds, nowarn);
    %if &nobs=-1 %then %do;

        proc sql noprint;
            select count(*) as count
            into :nobs from &ds;
        quit;

    %end;

    /* REVISION 2010-08-19 CAS: Added percentage */
    /* REVISION 2010-10-07 CAS: Converted to SQL for joining with _contents_ and 
       adding varnum to output */
    /*data &out;*/
    /*    set _trans_;*/
    /*    format Percent percent8.2;*/
    /*    Variable=substr(variable, 7, length(variable)-6);*/
    /*    Percent=Count/&nobs;*/
    /*run;*/

    proc sql;
        create table &out as
        select 
              substr(a.variable, 7, length(a.variable)-6) as Variable
            , b.Varnum as Order
            , a.Count
            , a.Count/&nobs as Percent length=10 format=percent8.2
        from _trans_ a

        left join _contents_ b
        on substr(a.variable, 7, length(a.variable)-6)=b.name

    %if &sort=NAM %then %do;
        order by a.variable
    %end;
    %else %if &sort=ORD %then %do;
        order by b.varnum
    %end;
    %else %if &sort=PER %then %do;
        order by a.Count/&nobs
    %end;
    %else %if &sort=COU %then %do;
        order by a.count
    %end;
        ;
    quit;

    %NoLabel(&out);

    proc sql;
        drop table _contents_ table _counts_ table _trans_;
    quit;

%mend VarCount;
