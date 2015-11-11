%macro CopyData(in,out,select,delete=N,type=PROC,compress=N) / des='Copy data from one lib to another';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CopyData
        Author:     Chris Swenson
        Created:    2009-10-06

        Purpose:    Copy data from one library to another

        Arguments:  in        - input library
                    out       - output library
                    select    - data sets to copy
                    delete=   - whether to delete the data sets in the input library
                    type=     - type of copy to perform, either with PROC DATASETS or
                                the DATA step, which allows for compression
                    compress= - flag to indicate whether to compress the data sets or
                                the type of compression to perform (CHAR, BINARY)

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Upper case variables */
    %let select=%upcase(&select);
    %let delete=%substr(%upcase(&delete), 1, 1);
    %let type=%upcase(&type);
    %let compress=%substr(%upcase(&compress), 1, 1);

    /* Check arguments */
    %if "&in"="" %then %do;
        %put %str(E)RROR: No input data set specified.;
        %return;
    %end;
    %if "&out"="" %then %do;
        %put %str(E)RROR: No output data set specified.;
        %return;
    %end;
    %if %index(*Y*N*,*&DELETE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid DELETE argument. Please use Y or N.;
        %return;
    %end;
    %if %index(*PROC*DATA*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid TYPE argument. Please use PROC (proc datasets) or DATA (data step).;
        %return;
    %end;
    %if %index(*N*Y*B*C*,*&COMPRESS*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid COMPRESS argument. Please use N (No), Y (Yes), B (Yes: Binary), or C (Yes: Character).;
        %return;
    %end;
    %if &TYPE=PROC and &COMPRESS ne N %then %do;
        %put %str(E)RROR: The PROC type is not set up to also compress the data. Please use the type=DATA argument for compression.;
        %return;
    %end;

    /* Use PROC DATASETS */
    %if &type=PROC %then %do;

        /* Copy member types of data from IN to OUT */
        proc datasets library=&in memtype=data nolist;
            copy out=&out;
            %if "&select" ne "" %then %do;
                select &select;
            %end;
        run; quit;

    %end;

    /* Use DATA step */
    %else %if &type=DATA %then %do;

        proc sql;
            create table _vtable_ as
            select * from sashelp.vtable
            where libname=upcase("&IN")
            ;
        quit;

        /* Set variables */
        %let dscnt=0;
        data _null_;
            set _vtable_ end=end;
        %if "&select" ne "" %then %do;
            %let seplist=%seplist(&select, dlm=%str(" "));
            where upcase(memname) in ("&seplist");
        %end;

            /* Declare variables locally then set value */
            call symputx(compress("ds" || put(_n_, 8.)), memname, 'L');

            /* Set count variable */
            if end then call symputx("dscnt", put(_n_, 8.), 'L');
        run;

        %local i;
        %do i=1 %to &dscnt;

            %local opt;
            %if &COMPRESS=N %then %let opt=;
            %else %if &COMPRESS=Y %then %let opt=(compress=Y);
            %else %if &COMPRESS=B %then %let opt=(compress=BINARY);
            %else %if &COMPRESS=C %then %let opt=(compress=CHAR);

            data &out..&&ds&i &opt;
                set &in..&&ds&i;
            run;

        %end;

        proc sql;
            drop table _vtable_;
        quit;

    %end;

    /* Delete data in IN if specified */
    %if %upcase(&delete)=Y %then %do;

        /* If no select statement, then delete all datasets */
        %if "&select"="" %then %do;

            proc datasets library=&in memtype=data nodetails nolist kill;
            quit;

        %end;

        /* Otherwise, delete only the selected datasets */
        %else %do;

            proc datasets library=&in memtype=data nodetails nolist;
                delete &select;
            quit;

        %end;

    %end;

%mend CopyData;
