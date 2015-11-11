%macro LibTbl(ds) / des='Split library/table into macro vars';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       LibTbl
        Author:     Chris Swenson
        Created:    2009-03-31

        Purpose:    Split library/table into macro variables

        Arguments:  ds - either a library.dataset or dataset

        Output:     lib - library
                    tbl - table/data set

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Declare the macro variables globally */
    %global lib tbl;

    /* Clear the macro variables */
    %let lib=;
    %let tbl=;

    /* Scan ds argument for a word following a period, and set the table to that word */
    %let tbl=%scan(&ds, 2, %str(.));

    /* If the table is populated, scan the ds argument for a word preceding
       a period, and set the library to that word if available */
    %if &tbl ne  %then %let lib=%scan(&ds, 1, %str(.));

    /* If the table is blank, then set the table to the original argument */
    %if &tbl=  %then %let tbl=&ds;

    /* Set lib to work if blank */
    %if &lib=  %then %let lib=work;

    /* Write the macros to the log */
    /* The lib macro variable will be blank for ds arguments without a library. */
    %put lib=&lib tbl=&tbl;

%mend LibTbl;
