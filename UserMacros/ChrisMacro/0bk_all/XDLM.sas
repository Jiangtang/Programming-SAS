%macro XDLM(file,out,type=,case=,strip=N,linelen=20,textlen=1000) / des="Import a file without a delimiter";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       XDLM
        Author:     Chris Swenson
        Created:    2010-11-15

        Purpose:    Import a file without delimiting the file

        Arguments:  file     - directory and filename of the file to import
                    out      - output data set name
                    type=    - type of filename, defaulted to blank for normal files
                    case=    - whether to set the text of the file to upper case (U)
                               or lower case (L)
                    strip=   - Y/N whether to strip the text of leading and trailing
                               blanks, defaulted to N
                    linelen= - the length of the Line variable, which stores the 
                               observation number
                    textlen= - the length of the $varying format, defaulted to 1000

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if %superq(FILE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for FILE.;
        %return;
    %end;
    %if %superq(OUT)=%str() %then %do;
        %put %str(E)RROR: No argument specified for OUT.;
        %return;
    %end;
    %if %superq(STRIP)=%str() %then %do;
        %put %str(E)RROR: No argument specified for STRIP.;
        %return;
    %end;

    %let strip=%substr(%upcase(&STRIP), 1, 1);
    %if %index(*N*Y*,*&STRIP*)=%str() %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for STRIP. Please use Y or N.;
        %return;
    %end;

    %if &CASE ne %str() %then %let case=%substr(%upcase(&CASE), 1, 1);

    filename xdlm &TYPE "&FILE";

    %local ervar _EFIERR_;
    %let ervar=%str(_E)RROR_;

    data &OUT;
        format Line &LINELEN..;

        /* The following delimiter, the cedilla, should not be common in American
           English code or datasets. The intent is to not delimit the data at all. */
        infile xdlm length=linelength lrecl=32767;

        input Text $varying&TEXTLEN.. linelength;

        /* Format the text */
    %if &CASE=U %then %do;
        Text=compbl(upcase(Text));
    %end;
    %else %if &CASE=L %then %do;
        Text=compbl(lowcase(Text));
    %end;
    %if &STRIP=Y %then %do;
        Text=compbl(strip(text));
    %end;

        /* Set line number for each line */
        Line=_n_;

        /* set (E)RROR detection macro variable */
        if &ERVAR then call symputx('_EFIERR_','1');
    run;

    filename xdlm clear;

    %if &_EFIERR_=1 or &SYSERR>3 or %nobs(&OUT)=0 %then %put %str(E)rrors were encountered during import.;

%mend XDLM;
