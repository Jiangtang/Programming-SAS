%macro CompCon(base,compare,id=VARNUM,out=Contents_differ,lib=WORK,exclude=INFORMAT INFORML,max=32767) / des='Compare contents of data sets';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CompCon
        Author:     Chris Swenson
        Created:    2009-03-31

        Purpose:    Compare the contents (CompCon) of two data sets that should be
                    the same format.

        Arguments:  base     - base data set
                    compare  - comparison data set
                    id=      - ID to compare the contents with, either NAME or
                               VARNUM, defaulted to VARNUM
                    out=     - output data set name, defaulted to Contents_differ
                    lib=     - output library
                    exclude= - variables to exclude from the analysis, defaulted to
                               INFORMAT INFORML, which usually differ greatly
                    max=     - maximum number of records to compare, defaulted to
                               maximum of 32,767

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Testing variables:
        %let base=;
        %let compare=;
        %let max=32767;
    */

    %let id=%upcase(&id);

    /* Check arguments */
    %if &base= or &compare= %then %do;
        %put %str(E)RROR: The macro call is missing arguments: Base=&base | Compare=&Compare;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&base, %str(DATA))) + %sysfunc(exist(&base, %str(VIEW))))=0 %then %do;
        %put %str(E)RROR: The base data set does not exist.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&compare, %str(DATA))) + %sysfunc(exist(&compare, %str(VIEW))))=0 %then %do;
        %put %str(E)RROR: The compare data set does not exist.;
        %return;
    %end;
    %if "&id"="" %then %do;
        %put %str(E)RROR: No ID argument specified.;
        %return;
    %end;
    %else %if %index(*NAME*VARNUM*,*&id*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid ID argument specified. Please use NAME or VARNUM.;
        %return;
    %end;
    %if %superq(LIB)=%str() %then %do;
        %put %str(E)RROR: No argument specified for LIB.;
        %return;
    %end;

    /* Modify the exclusion argument */
    %local excludelist;
    %let excludelist=;
    %if "&exclude" ne "" %then %do;
        %let exclude=%upcase(&exclude);
        %let exclude=%sysfunc(compbl(&exclude));
        %let exclude=%sysfunc(tranwrd(&exclude, %str( ), %str(*)));
        %let excludelist=, %sysfunc(tranwrd(&exclude, %str(*), %str(, )));
    %end;

    %put NOTE: Data sets to compare on contents: Base=&base | Compare=&compare;

    /* Data set 1 Contents */
    proc contents data=&base out=&LIB..contents_base noprint;
    run;

    data &LIB..contents_base;
        set &LIB..contents_base;
        name=upcase(name);
    run;

    proc sort data=&LIB..contents_base;
        by &id;
    run;

    /* Data set 2 Contents */
    proc contents data=&compare out=&LIB..contents_compare noprint;
    run;

    data &LIB..contents_compare;
        set &LIB..contents_compare;
        name=upcase(name);
    run;

    proc sort data=&LIB..contents_compare;
        by &id;
    run;

    /* Comparison of the contents of the base and compare data sets. */
    proc compare
            base=&LIB..contents_base compare=&LIB..contents_compare
            out=&LIB..&out outbase outcomp outnoequal
            noprint maxprint=&max;

        /*  These variables will not be compared:
            COMPRESS - Compression will not differ
            CRDATE - Creation date of contents will differ
            ENGINE - Engine may differ
            LABEL - Label should not differ in contents
            LIBNAME - Library could differ
            MEMNAME - Memname will differ
            MODATE - Modified date of contents will differ
            NOBS - NOBS may differ and should be checked separately
            NPOS - Position in buffer should not matter
         */

        id &id;
        var
    %if %index(*&EXCLUDE*,*CHARSET*)=0 %then %do;
            CHARSET
    %end;
    %if %index(*&EXCLUDE*,*COLLATE*)=0 %then %do;
            COLLATE
    %end;
    %if %index(*&EXCLUDE*,*DELOBS*)=0 %then %do;
            DELOBS
    %end;
    %if %index(*&EXCLUDE*,*ENCRYPT*)=0 %then %do;
            ENCRYPT
    %end;
    %if %index(*&EXCLUDE*,*FLAGS*)=0 %then %do;
            FLAGS
    %end;
    %if %index(*&EXCLUDE*,*FORMAT*)=0 %then %do;
            FORMAT
    %end;
    %if %index(*&EXCLUDE*,*FORMATD*)=0 %then %do;
            FORMATD
    %end;
    %if %index(*&EXCLUDE*,*FORMATL*)=0 %then %do;
            FORMATL
    %end;
    %if %index(*&EXCLUDE*,*GENMAX*)=0 %then %do;
            GENMAX
    %end;
    %if %index(*&EXCLUDE*,*GENNEXT*)=0 %then %do;
            GENNEXT
    %end;
    %if %index(*&EXCLUDE*,*GENNUM*)=0 %then %do;
            GENNUM
    %end;
    %if %index(*&EXCLUDE*,*IDXCOUNT*)=0 %then %do;
            IDXCOUNT
    %end;
    %if %index(*&EXCLUDE*,*IDXUSAGE*)=0 %then %do;
            IDXUSAGE
    %end;
    %if %index(*&EXCLUDE*,*INFORMAT*)=0 %then %do;
            INFORMAT
    %end;
    %if %index(*&EXCLUDE*,*INFORMD*)=0 %then %do;
            INFORMD
    %end;
    %if %index(*&EXCLUDE*,*INFORML*)=0 %then %do;
            INFORML
    %end;
    %if %index(*&EXCLUDE*,*JUST*)=0 %then %do;
            JUST
    %end;
    %if %index(*&EXCLUDE*,*LENGTH*)=0 %then %do;
            LENGTH
    %end;
    %if %index(*&EXCLUDE*,*MEMLABEL*)=0 %then %do;
            MEMLABEL
    %end;
    %if %index(*&EXCLUDE*,*MEMTYPE*)=0 %then %do;
            MEMTYPE
    %end;
    %if %index(*&EXCLUDE*,*NAME*)=0 %then %do;
            NAME
    %end;
    %if %index(*&EXCLUDE*,*NODUPKEY*)=0 %then %do;
            NODUPKEY
    %end;
    %if %index(*&EXCLUDE*,*NODUPREC*)=0 %then %do;
            NODUPREC
    %end;
    %if %index(*&EXCLUDE*,*POINTOBS*)=0 %then %do;
            POINTOBS
    %end;
    %if %index(*&EXCLUDE*,*PROTECT*)=0 %then %do;
            PROTECT
    %end;
    %if %index(*&EXCLUDE*,*REUSE*)=0 %then %do;
            REUSE
    %end;
    %if %index(*&EXCLUDE*,*SORTED*)=0 %then %do;
            SORTED
    %end;
    %if %index(*&EXCLUDE*,*SORTEDBY*)=0 %then %do;
            SORTEDBY
    %end;
    %if %index(*&EXCLUDE*,*TYPE*)=0 %then %do;
            TYPE
    %end;
    %if %index(*&EXCLUDE*,*TYPEMEM*)=0 %then %do;
            TYPEMEM
    %end;
        ;
    run;

    /* Note: The following list includes a macro variable reference appended at 
       the end without an extra space. This is okay, since the EXCLUDELIST macro
       variable contains the extra comma to extend the list. */
    %put NOTE: The following variables were NOT compared:;
    %put NOTE- COMPRESS, CRDATE, ENGINE, LABEL, LIBNAME, MEMNAME, MODATE, NOBS, NPOS&EXCLUDELIST;

    /* If there are observations in the table with differences, output message */
    %if %nobs(&LIB..&out)>0 %then %do;
        %put %str(W)ARNING: The data sets &base and &compare differ!;
        %put %str(W)ARNING- Please see data set &out.!;
    %end;

    /* Otherwise, output a note and drop the tables made by the macro */
    %else %do;

        proc sql;
            drop table &LIB..&out 
                 table &LIB..contents_base 
                 table &LIB..contents_compare
            ;
        quit;

        %put NOTE: The data sets &base and &compare have the same structure.;

    %end;

%mend CompCon;
