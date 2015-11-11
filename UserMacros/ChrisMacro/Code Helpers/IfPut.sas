%macro IfPut(criteria,thenput,elseput,issue) / des="If/then execution for %PUT statement";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       IfPut
        Author:     Chris Swenson
        Created:    2010-02-15

        Purpose:    If/then execution for a %PUT statement

        Arguments:  criteria - criteria to fulfill to output note
                    thenput  - note to output if criteria fulfilled
                    elseput  - note to output if criteria not fulfilled
                    issue    - type of issue to output the note in the THENPUT
                               argument as, either (E)RROR or (W)ARNING

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check arguments */
    %if %superq(criteria)=%str() %then %do;
        %put %str(E)RROR: Missing criteria argument.;
        %return;
    %end;
    %if %superq(thenput)=%str() %then %do;
        %put %str(E)RROR: Missing thenput argument (message only).;
        %return;
    %end;

    /* Determine issue type */
    %if %superq(issue) ne %str() %then %do;
        %let issue=%upcase(&issue);
        %if &issue=E %then %let thenput=%str(E)RROR: &thenput;
        %else %if &issue=W %then %let thenput=%str(W)ARNING: &thenput;
        %else %do;
            %put %str(E)RROR: %str(I)nvalid issue argument. Use E or W.;
            %return;
        %end;
    %end;

    /* Determine Type and Output */
    %if %superq(elseput)=%str() %then %do;
        %if %unquote(%superq(criteria)) %then %put %unquote(%superq(thenput));
    %end;
    %else %do;
        %if %unquote(%superq(criteria)) %then %put %unquote(%superq(thenput));
        %else %put %unquote(%superq(elseput));
    %end;

%mend IfPut;
