%macro DatePart(dt,as,format=MMDDYY10,source=N,comma=N) 
    / des='Use the DATEPART function without generating issues when values are missing';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       DatePart
        Author:     Chris Swenson
        Created:    2011-08-23

        Purpose:    Use the DATEPART function without generating issues in the log
                    when datetimes are missing.

        Arguments:  dt      - the datetime variable to use in the datepart function
                    as      - the output variable name, defaulted to the same name
                              as the dt argument.
                    format= - output format, defaulted to MMDDYY10
                    source= - Y/N indicating whether to create a label that indicates
                              the source of the new column
                    comma=  - Y/N indicating whether to output a final comma

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check for blank arguments */
    %if %superq(DT)=%str() %then %do;
        %put %str(E)RROR: No argument specified for DT.;
        %return;
    %end;

    /* Check for argument values in (Y N) */
    %let COMMA=%substr(%upcase(&COMMA), 1, 1);
    %if %index(*Y*N*,*&COMMA*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for COMMA.;
        %put %str(E)RROR- Please use one of the following: Y or N.;
        %return;
    %end;
    %let SOURCE=%substr(%upcase(&SOURCE), 1, 1);
    %if %index(*Y*N*,*&SOURCE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for SOURCE.;
        %put %str(E)RROR- Please use one of the following: Y or N.;
        %return;
    %end;

    /* Check for the trailing period on the format name */
    %if %substr(%sysfunc(reverse(&FORMAT)), 1, 1) ne %str(.)
    %then %let format=&FORMAT..;

    /* Default AS to DT */
    %if %superq(AS)=%str() %then %let as=%unquote(%superq(DT));

    /* Use the DATEPART function with extra code */
    case when %superq(DT)=. then . else datepart(%superq(DT))
    end as %superq(AS) format=&FORMAT
  %if &SOURCE=Y %then %do;
    label="%superq(AS) from %scan(%superq(DT), -1, %str(.))"
  %end;
    %if &COMMA=Y %then %str(, );

%mend DatePart;
