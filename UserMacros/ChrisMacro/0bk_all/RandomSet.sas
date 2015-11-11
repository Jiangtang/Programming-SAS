%macro RandomSet(ds,recs,type,out=RANDOM,multi=100000) / des='Obtain random data';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       RandomSet
        Author:     Chris Swenson
        Created:    2009-06-03

        Purpose:    Obtain random data using one of two methods

        Arguments:  ds     - input data set to obtain random data from
                    recs   - number of random records to obtain
                    type   - run type of macro, either 1 for using PROC SORT on the
                             input data set (good for small data sets) or 2 for only
                             selecting the random observations from the data set
                             (good for large data sets)
                    out=   - name of output data set, defaulted to RANDOM
                    multi= - multiplier applied to RAND('UNIFORM') function,
                             defaulted to 100,000

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %local i;

    /* Check arguments */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: No data set specified.;
        %return;
    %end;
    %if %sysfunc(exist(&DS))=0 %then %do;
        %put %str(E)RROR: The specified data set does not exist.;
        %return;
    %end;
    %if "&recs"="" %then %do;
        %put %str(E)RROR: No record count specified.;
        %return;
    %end;

    /* Drop the table if it already exists */
    %droptable(&OUT);

    /* Type 1 */
    %if &type=  or &type=1 %then %do;

        %Time(B);

        data &OUT;
            set &ds;
            random=RAND('UNIFORM')*&multi;
        run;

        proc sort data=&OUT;
            by random;
        run;

        data &OUT(drop=random);
            set &OUT(obs=&recs);
        run;

        %Time(E);

    %end;

    /* Type 2 */
    %if &type=2 %then %do;

        %Time(B);

        %local dsnobs keeprecs;

        /* Count Each Observation in the data set */
        proc sql noprint;
            select sum(1)
            into :dsnobs
            from &ds
            ;
        quit;

        %let dsnobs=&dsnobs;
        %put NOTE: Number of records in &ds: &dsnobs;

        /* Set the number of records with a random number */
        data &OUT;
            format i random 12.;
            do i=1 to &dsnobs;
                random=RAND('UNIFORM')*&multi;
                output;
            end;
        run;

        proc sort data=&OUT;
            by random;
        run;

        /* Keep the number of desired records */
        /* Note: These are the record numbers of the desired records */
        data &OUT(drop=random);
            set &OUT(obs=&recs);
        run;

        /* Put the record numbers into one macro variable */
        proc sql noprint;
            select i
            into :keeprecs separated by ' '
            from &OUT
            ;
        quit;

        proc sql;
            drop table &OUT;
        quit;

        /* Pull each record out one at a time */
        %do i=1 %to &recs;

            %put NOTE: Record - %scan(&keeprecs,&i);

            /* Note: The set statement with obs= and firstobs= set to the same number
               only pulls that one record out of the data set */
            data _temp_;
                set &ds(obs=%scan(&keeprecs,&i) firstobs=%scan(&keeprecs,&i));
            run;

            /* Append to final */
            proc append base=&OUT data=_temp_;
            run;

        %end;

        proc sql; drop table _temp_; quit;

        %Time(E);

    %end;

    %put ;
    %put NOTE: %nobs(&OUT) randomly-selected records output to &OUT..;

%mend RandomSet;
