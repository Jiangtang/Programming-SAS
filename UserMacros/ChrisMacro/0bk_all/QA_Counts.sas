%macro QA_Counts(base,compare,operator) / des="Compare record counts in two data sets";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       QA_Counts
        Author:     Chris Swenson
        Created:    2010-12-28

        Purpose:    Compare record counts between two data sets or numbers and output
                    a message noting whether the comparison specified was true or false.

        Arguments:  base     - base data set or number
                    compare  - comparison data set or number
                    operator - comparison type, using operator mnemonics:

                        EQ = equal to
                        GE = greater than or equal to
                        GT = greater than
                        LE = less than or equal to
                        LT = less than
                        NE = not equal

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let base=%upcase(&BASE);
    %let compare=%upcase(&COMPARE);
    %let operator=%upcase(&OPERATOR);

    /* Set default */
    %if "&OPERATOR"="" %then %let operator=EQ;

    /* Check arguments */
    %if "&BASE"="" %then %do;
        %put %str(E)RROR: No argument specified for BASE.;
        %return;
    %end;
    %if "&COMPARE"="" %then %do;
        %put %str(E)RROR: No argument specified for COMPARE.;
        %return;
    %end;

    /* Identify argument types */
    %local base_type compare_type;
    %let base_type=CHAR;
    %let compare_type=CHAR;

    %if %sysfunc( compress(%substr(&BASE, 1, 1), , %str(d)) )=%str()
    %then %let base_type=NUM;
    %if %sysfunc( compress(%substr(&COMPARE, 1, 1), , %str(d)) )=%str()
    %then %let compare_type=NUM;

    /* If character, the test whether the data set exists */
    %if &BASE_TYPE=CHAR %then %do;;
        %if %eval( %sysfunc(exist(&BASE, DATA)) + %sysfunc(exist(&BASE, VIEW)) )=0 %then %do;
            %put %str(E)RROR: The data set &BASE does not exist.;
            %return;
        %end;
    %end;
    %if &COMPARE_TYPE=CHAR %then %do;
        %if %eval( %sysfunc(exist(&COMPARE, DATA)) + %sysfunc(exist(&COMPARE, VIEW)) )=0 %then %do;
            %put %str(E)RROR: The data set &COMPARE does not exist.;
            %return;
        %end;
    %end;

    /* Set messages */
    %local msg1 msg2;
    %if %str(&OPERATOR)=%str(EQ) %then %let msg1=equal to;
    %else %if %str(&OPERATOR)=%str(GE) %then %let msg1=greater than or equal to;
    %else %if %str(&OPERATOR)=%str(GT) %then %let msg1=greater than;
    %else %if %str(&OPERATOR)=%str(LE) %then %let msg1=less than or equal to;
    %else %if %str(&OPERATOR)=%str(LT) %then %let msg1=less than;
    %else %if %str(&OPERATOR)=%str(NE) %then %let msg1=not equal to;
    %else %do;
        %put %str(E)RROR: %str(I)nvalid operator argument. Please use one of the following:;
        %put %str(E)RROR- EQ = equal to;
        %put %str(E)RROR- GE = greater than or equal to;
        %put %str(E)RROR- GT = greater than;
        %put %str(E)RROR- LE = less than or equal to;
        %put %str(E)RROR- LT = less than;
        %put %str(E)RROR- NE = not equal;
        %return;
    %end;

    %if %str(&OPERATOR)=%str(NE) %then %let msg2=equal to;
    %else %let msg2=not &MSG1;

    /* Obtain counts, if from a data set */
    %local n1 n2;
    %if &BASE_TYPE=CHAR %then %do;
        %let n1=(%nobs(&BASE));
        %let base_msg=the record count of &BASE;
    %end;
    %else %do;
        %let n1=&BASE;
        %let base_msg=;
    %end;
    %if &COMPARE_TYPE=CHAR %then %do;
        %let n2=(%nobs(&COMPARE));
        %let compare_msg=The record count of &COMPARE;
    %end;
    %else %do;
        %let n2=&COMPARE;
        %let compare_msg=;
    %end;

    /* Compare counts */
    %global qa_count;
    %if &N2 &OPERATOR &N1 %then %do;
        %put NOTE: %sysfunc(compbl(&COMPARE_MSG &N2 is &MSG1 &BASE_MSG &N1..));
        %let qa_count=OK;
    %end;
    %else %do;
        %put %str(W)ARNING: %sysfunc(compbl(&COMPARE_MSG &N2 is &MSG2 &BASE_MSG &N1!));
        %let qa_count=BAD;
    %end;

%mend QA_Counts;
