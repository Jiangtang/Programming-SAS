%macro DstCnt(ds,dstvar,outvar,where=) / des="Obtain distinct count of a variable";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       DstCnt
        Author:     Chris Swenson
        Created:    2009-11-25

        Purpose:    Obtain distinct count of a variable

        Arguments:  ds     - input data set
                    dstvar - variable to count distinct values
                    outvar - output macro variable containing count
                    where= - filter to apply to input data set

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check arguments */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: No data set specified.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&ds, %str(DATA))) + %sysfunc(exist(&ds, %str(VIEW))))=0 %then %do;
        %put %str(E)RROR: Data set or view does not exist.;
        %return;
    %end;
    %if "&dstvar"="" %then %do;
        %put %str(E)RROR: No distinct variable specified.;
        %return;
    %end;

    /* Set default for output variable */
    %if "&outvar"="" %then %let outvar=outvar;
    %else %do;
        %global &outvar;
    %end;

    /* Modify where criteria */
    %local addwhere;
    %if %superq(where)=%str() %then %do;
        %put NOTE: No where criteria specified.;
        %let addwhere=;
    %end;
    %else %let addwhere= and %superq(where);

    /* Obtain distinct count of specified variable */
    %local intovar;
    proc sql noprint;
        select count(distinct &dstvar)
        into :intovar
        from &ds
        where not missing(&dstvar) &addwhere
        ;
    quit;
    %let &outvar=&intovar;

    /* Output count */
    data _null_;
        format count comma20.;
        count=&intovar;
        put "NOTE: Distinct count of &dstvar in &ds: " count;
    run;

%mend DstCnt;
