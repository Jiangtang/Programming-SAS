%macro TableInfo(ds,infotype) / des='Output info on table';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       TableInfo
        Author:     Chris Swenson
        Created:    2010-07-08

        Purpose:    Output info on table

        Arguments:  ds       - input data set
                    infotype - type of information to output

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

    /* Uppercase argument */
    %let infotype=%upcase(&infotype);

    /* Set default type as character */
    %let type=CHAR;

    /* Check for character type */
    %if %index(*CHARSET*ENCRYPT*ENGINE*LABEL*LIB*MEM*MODE*MTYPE*SORTEDBY*SORTLVL*SORTSEQ*TYPE*,*&INFOTYPE*)=0 %then %do;

        /* Set numeric type */
        %let type=NUM;

        /* Check for numeric type */
        /* Note: This is split in order to be more legible */
        /* Note: The word (e)rror is masked to avoid detection in log */
        %if %index(*ALTERPW*ANOBS*ANY*ARAND*ARWU*,*&INFOTYPE*)=0
        and %index(*AUDIT*AUDIT_DATA*AUDIT_BEFORE*AUDIT_%str(E)RROR*,*&INFOTYPE*)=0
        and %index(*CRDTE*ICONST*INDEX*ISINDEX*ISSUBSET*,*&INFOTYPE*)=0 
        and %index(*LRECL*LRID*MAXGEN*MAXRC*MODTE*NDEL*NEXTGEN*,*&INFOTYPE*)=0
        and %index(*NLOBS*NLOBSF*NOBS*NVARS*,*&INFOTYPE*)=0
        and %index(*PW*RADIX*READPW*TAPE*WHSTMT*WRITEPW*,*&INFOTYPE*)=0
        %then %do;

            %put %str(E)RROR: Infotype argument is %str(i)nvalid. Review the ATTRC and ATTRN functions in SAS help documentation for valid arguments.;
            %put %str(E)RROR- Or see the following spreadsheet: &CDIR.AttributeFunctions.xls;
            %return;

        %end;

    %end;

    /* Manage scope */
    %local arg dsid vid rc;

    /* Open data set */
    %let dsid=%sysfunc(open(&ds));

        /* Obtain character data set info */
        %if &TYPE=CHAR %then %do;
            %let info=%sysfunc(attrc(&dsid, &INFOTYPE));
        %end;

        /* Obtain numeric data set info */
        %else %if &TYPE=NUM %then %do;
            %let info=%sysfunc(attrn(&dsid, &INFOTYPE));
        %end;

        /* Convert number to date */
        %if %index(*CRDTE*MODTE*,*&INFOTYPE*)>0 %then %do;
            %let info=%sysfunc(putn(&info, datetime20.));
        %end;

    /* Close data set */
    %let rc=%sysfunc(close(&dsid));

    /* Output type */
    &info

%mend TableInfo;
