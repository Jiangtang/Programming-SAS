%macro Reorder(ds,match,type=LIST,out=) / des='Reorder variables in a data set';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       Reorder
        Author:     Chris Swenson
        Created:    2010-08-02

        Purpose:    Reorder variables in a data set

        Arguments:  ds    - input data set name
                    match - variable list or data set to match
                    type= - specifies the type of data specified in the MATCH
                            argument, either LIST or DATASET
                    out=  - output data set name

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Capture user option */
    %let user_quotelenmax=%sysfunc(getoption(quotelenmax));

    /* Set option for quotelenmax */
    options noquotelenmax;

    /* Upper-case argument(s) */
    %let type=%upcase(&type);

    /* Check arguments */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: The data set argument is blank.;
        %goto exit;
    %end;
    %if "&match"="" %then %do;
        %put %str(E)RROR: The match argument is blank. Specify either a list of variables or a data set to match.;
        %goto exit;
    %end;
    %if %index(*LIST*DATASET*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: The type argument is %str(i)nvalid. Please specify either LIST or DATASET.;
        %goto exit;
    %end;
    %if &TYPE=DATASET %then %do;
        %if %sysfunc(exist(&match))=0 %then %do;
            %put %str(E)RROR: The data set specified in the match argument does not exist.;
            %goto exit;
        %end;
    %end;
    %if "&ds"="&match" %then %do;
        %put %str(E)RROR: The same data set was specified for the input and match arguments.;
        %goto exit;
    %end;
    %if "&out"="" %then %do;
        %put NOTE: The output argument was blank. Setting output to input data set.;
        %let out=&ds;
    %end;

    /* If the match argument is a data set, then reset match argument to a list of 
       variables from the data set */
    %if &TYPE=DATASET %then %do;

        /* Output contents of data set specified in match argument */
        proc contents data=&match out=_contents_ noprint;
        run;

        /* Sort the contents */
        /* Note: For whatever reason, specifying the VARNUM option in PROC CONTENTS
           does not sort the output data set, which is why this step is necessary. */
        proc sort data=_contents_;
            by varnum;
        run;

        /* Set variables to MATCH argument and drop temporary _CONTENTS_ data set */
        proc sql noprint;
            select name
            into :match separated by " "
            from _contents_
            ;

            drop table _contents_;
        quit;

        %put NOTE: Match=&Match;

    %end;

    /* Manage macro variable scope */
    %local num var;

    /* Set initial scan */
    %let num=1;
    %let var=%scan(&match, &num, %str( )%str(%()%str(%)));

    data &out;
        label

    /* Loop through each argument in MATCH until blank */
    %do %while("&var" ne "");

            /* Set label to blank */
            &var.=

        /* Increment scan */
        %let num=%eval(&num+1);
        %let var=%scan(&match, &num, %str( )%str(%()%str(%)));

    %end;
        ;
        set &ds;
    run;

    /* Exit */
    %exit:

    options &user_quotelenmax;

%mend Reorder;
