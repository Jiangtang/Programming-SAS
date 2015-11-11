%macro SelectStat(ds,by,var,stat=,out=) / des='Select record matching statistic';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       SelectStat
        Author:     Chris Swenson
        Created:    2010-11-18

        Purpose:    Select a record from a group of records that has the matching
                    statistic of a particular variable (e.g., line number, date).
                    This process can help with selecting distinct records, even if
                    it is necessary to run multiple times.

        Arguments:  ds    - input data set
                    by    - variables that identify a group of records (e.g., IDs)
                    var   - variable to select the min or max of
                    stat= - the statistic to select, currently only MIN or MAX
                    out=  - name of the output data set, defaulted to DS_STAT (e.g,
                            Test_min where DS=Test and Stat=Min)

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let stat=%upcase(&STAT);

    /* Check arguments */
    %if "&DS"="" %then %do;
        %put %str(E)RROR: No argument specified for DS.;
        %return;
    %end;
    %if %sysfunc(exist(&DS))=0 %then %do;
        %put %str(E)RROR: The specified data set does not exist.;
        %return;
    %end;
    %if "&BY"="" %then %do;
        %put %str(E)RROR: No argument specified for BY.;
        %return;
    %end;
    %if "&VAR"="" %then %do;
        %put %str(E)RROR: No argument specified for VAR.;
        %return;
    %end;
    %if "&STAT"="" %then %do;
        %put %str(E)RROR: No argument specified for STAT. Please use MIN or MAX.;
        %return;
    %end;
    %if %index(*MAX*MIN*,*&STAT*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid STAT argument. Please use MIN or MAX.;
        %return;
    %end;

    /* Set defaults */
    %if "&OUT"="" %then %do;
        %let out=%scan(&DS, -1, %str(.))_&STAT;
        %put NOTE: No output data set specified. Defaulting to &OUT..;
    %end;

    /* Set statistic name */
    %if &STAT=MIN %then %let statname=minimum;
    %else %if &STAT=MAX %then %let statname=maximum;

    /* Create SQL Statements */
    %local count sqlby sqlon comma and;
    %let count=%sysfunc(countw(&BY, %str( )));
    %put NOTE: Number of by variables specified: &COUNT;

    /* Set SQL by variables */
    %let sqlby=;
    %do b=1 %to &COUNT;
        %let comma=;
        %if &B ne &COUNT %then %let comma=%str(,);
        %local by&B;
        %let by&B=%scan(&BY, &B)%superq(COMMA);
        %let sqlby=&SQLBY &&BY&B;
    %end;

    /* Set SQL on statement */
    %let sqlon=;
    %do o=1 %to &COUNT;
        %let and=;
        %if &O ne &COUNT %then %let and=%str(and);
        %local on&O;
        %let on&O=a.%scan(&BY, &O)=b.%scan(&BY, &O) &AND;
        %let sqlon=&SQLON &&ON&O;
    %end;

    /* Select records */
    proc sql;
        create table _&STAT._ as
        select distinct &SQLBY, &STAT(&VAR) as &STAT format=%VarInfo(&DS, &VAR, format)
        from &DS
        group by &SQLBY
        order by &SQLBY
        ;

        create table &OUT as
        select distinct a.*
        from &DS a
        inner join _&STAT._ b
        on &SQLON
        and a.&VAR=b.&STAT
        ;

        drop table _&STAT._;
    quit;

    %put NOTE: %nobs(&OUT) records were selected,;
    %if %nobs(&DS, nowarn) ne -1 %then %put NOTE- from %nobs(&DS) records,;
    %put NOTE- based on the &STATNAME of %upcase(&VAR),;
    %put NOTE- output to %upcase(&OUT).;

%mend SelectStat;
