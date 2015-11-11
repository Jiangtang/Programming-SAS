%macro ZeroCheck(ds,msg,type) / des='Write (e)rror or (w)arn if records in ds';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ZeroCheck
        Author:     Chris Swenson
        Created:    2009-04-10

        Purpose:    Write (e)rror or (w)arning if there are records in a data set

        Arguments:  ds   - input data set that should be empty
                    msg  - message to output if the data set is not empty
                    type - type of issue to output: (e)rror or (w)arning

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Turn off mprint */
    %local user_mprint;
    %let user_mprint=%sysfunc(getoption(mprint));
    options nomprint;

    /* Modify arguments */
    %let type=%upcase(&type);

    /* Check arguments */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: No data set specified.;
        %goto exit; /* Restore options and exit */
    %end;
    %if %sysfunc(exist(&ds))=0 %then %do;
        %put %str(E)RROR: Data set does not exist.;
        %goto exit; /* Restore options and exit */
    %end;
    %if "&msg"="" %then %do;
        %put %str(E)RROR: No message specified.;
        %goto exit; /* Restore options and exit */
    %end;
    %if %index(*E*W*,*&type*)=0 %then %do;
        %put %str(E)RROR: Incorrect message type specified. Use either E or W.;
        %goto exit; /* Restore options and exit */
    %end;

    /* (E)rror output */
    %if "&type"="E" %then %do;
        %if %nobs(&ds)>0 %then %put %str(E)RROR: &msg.;
        %else %put NOTE: Data set &ds contains no records.;
    %end;

    /* (W)arning output */
    %else %if "&type"="W" %then %do;
        %if %nobs(&ds)>0 %then %put %str(W)ARNING: &msg.;
        %else %put NOTE: Data set &ds contains no records.;
    %end;

    %exit:

    /* Restore mprint */
    options &user_mprint;

%mend ZeroCheck;
