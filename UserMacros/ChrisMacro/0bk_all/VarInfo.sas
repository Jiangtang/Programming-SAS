%macro VarInfo(ds,var,infotype) / des='Output info on variable';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       VarInfo
        Author:     Chris Swenson
        Created:    2010-05-18

        Purpose:    Output info on a variable

        Arguments:  ds       - data set of variable in question
                    var      - variable to obtain information about
                    infotype - type of information to obtain

        Usage:      See the SAS documentation on the ATTRC and ATTRN functions for
                    valid values for the infotype argument

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check if the table exists */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: The data set argument is blank.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&ds, %str(DATA))) + %sysfunc(exist(&ds, %str(VIEW))))=0 %then %do;
        %put %str(W)ARNING: %sysfunc(compbl(The &ds data set does not exist)).;
        %return;
    %end;

    /* Check the var argument */
    %if "&var"="" %then %do;
        %put %str(E)RROR: The variable argument is blank.;
        %return;
    %end;

    /* Check infotype argument */
    %let infotype=%upcase(&infotype);
    %if "&infotype"="" %then %do;
        %put %str(E)RROR: The infotype argument is blank.;
        %return;
    %end;
    %if %index(*FORMAT*INFORMAT*LABEL*LENGTH*TYPE*,*&INFOTYPE*)=0 %then %do;
        %put %str(E)RROR: Infotype argument is %str(i)nvalid. Use one of the following: format, informat, label, length, or type.;
        %return;
    %end;

    /* Manage scope */
    %local arg dsid vid rc;

    /* Translate infotype argument to function */
    %if &infotype=FORMAT %then %let arg=varfmt;
    %else %if &infotype=INFORMAT %then %let arg=varinfmt;
    %else %if &infotype=LABEL %then %let arg=varlabel;
    %else %if &infotype=LENGTH %then %let arg=varlen;
    %else %if &infotype=TYPE %then %let arg=vartype;

    /* Open data set */
    %let dsid=%sysfunc(open(&ds));

        /* Obtain variable number */
        %let vid=%sysfunc(varnum(&dsid, %upcase(&var)));

        %if &vid>0 %then %do;

            /* Obtain variable info */
            %let info=%sysfunc(&arg(&dsid, &vid));

            %if &infotype=FORMAT and "&info"="" %then %do;
                %if %sysfunc(vartype(&dsid, &vid))=C %then %let info=$%sysfunc(varlen(&dsid, &vid)).;
                %else %if %sysfunc(vartype(&dsid, &vid))=N %then %let info=%sysfunc(varlen(&dsid, &vid)).;
            %end;

        %end;
        %else %do;
            %let rc=%sysfunc(close(&dsid));
            %put %str(W)ARNING: Variable &var does not exist on data set &ds..;
            %return;
        %end;

    /* Close data set */
    %let rc=%sysfunc(close(&dsid));

    /* Output type */
    &info

%mend VarInfo;
