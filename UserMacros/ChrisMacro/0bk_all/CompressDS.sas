%macro CompressDS(ds,type=CHAR,lib=WORK) / des='Compress specified data set(s)';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CompressDS
        Author:     Chris Swenson
        Created:    2010-02-23

        Purpose:    Compress specified data set(s)

        Arguments:  ds    - one or more data sets to compress
                    type= - type of compression, either CHAR (character) or BINARY
                    lib=  - library on which to process the data, defaulted to WORK

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-06-22  CAS     Removed dependency on sub-macro. Add LIB= argument to
                            specify where processing takes place.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let type=%upcase(&TYPE);

    /* Check type arguments */
    %if "&DS"="" %then %do;
        %put %str(E)RROR: No data set(s) specified.;
        %return;
    %end;
    %if %index(*CHAR*BINARY*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: Incorrect type argument. Use CHAR or BINARY.;
        %return;
    %end;

    /* Manage macros */
    %local num cur;

    /* Set initial scan */
    %let num=1;
    %let cur=%scan(&DS, &NUM, %str( ));

    /* Loop through each argument until blank */
    %do %while("&CUR" ne "");

        /* Split the table from the library */
        /* REVISION 2011-06-22 CAS: Removed dependency on sub-macro */
        %if %sysfunc(find(&DS, %str(.)))>0 %then %do;

            /* Clear the macro variables */
            %let inlib=;
            %let tbl=;

            /* Scan ds argument for a word following a period, and set the table to that word */
            %let tbl=%scan(&DS, -1, %str(.));

            /* If the table is populated, scan the ds argument for a word preceding
               a period, and set the library to that word if available */
            %if "&TBL" ne "" %then %let inlib=%scan(&DS, 1, %str(.));

            /* If the table is blank, then set the table to the original argument */
            %else %if "&TBL"="" %then %let tbl=&DS;

            /* Set lib to work if blank */
            %if "&INLIB"="" %then %let inlib=WORK;

            /* Write the macros to the log */
            /* The lib macro variable will be blank for ds arguments without a library. */
            %put inlib=&INLIB tbl=&TBL;

        %end;
        %else %do;
            %let inlib=WORK;
            %let tbl=&DS;
        %end;

        /****************************************************************************/

        /* Copy data set to work */
        data &LIB..&TBL._bu;
            set &CUR;
        run;
        %let tbl=&LIB..&TBL._bu;

        %if %sysfunc(exist(&TBL))=0 %then %do;
            %put %str(E)RROR: Backup failed: backup does not exist. Halting compression.;
            %return;
        %end;
        %else %if %nobs(&TBL)=0 %then %do;
            %put %str(E)RROR: Backup failed: backup has 0 records. Halting compression.;
            %return;
        %end;

        /* Drop table and re-write with compression */
        %put NOTE: Compressing &cur using the &type method.;

        proc sql;
            drop table &CUR;
        quit;

        %if %sysfunc(exist(&CUR))=1 %then %do;
            %put %str(E)RROR: Deletion failed. Halting compression.;
            %return;
        %end;

        data &CUR(compress=&type);
            set &TBL;
        run;

        /* Increment scan */
        %let num=%eval(&NUM+1);
        %let cur=%scan(&DS, &NUM, %str( ));

    %end;

    %put NOTE: Please review the compressed and backed-up data set(s).;
    %put NOTE- Delete the back-ups if no issues arose during compression.;

%mend CompressDS;
