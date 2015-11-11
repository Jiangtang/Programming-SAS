%macro ViewFormat(library,format,keep=start end label type) / des="Open a format for viewing";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ViewFormat
        Author:     Chris Swenson
        Created:    2010-09-29

        Purpose:    Open a format for viewing

        Arguments:  library - library that the format is in
                    format  - name of format
                    keep=   - variables to keep, defaulted to START, END, LABEL, and
                              TYPE

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if "&library"="" %then %do;
        %put %str(E)RROR: No LIBRARY argument specified.;
        %return;
    %end;
    %if %sysfunc(libref(&library)) ne 0 %then %do;
        %put %str(E)RROR: The specified library does not exist.;
        %return;
    %end;
    %if "&format"="" %then %do;
        %put %str(E)RROR: No FORMAT argument specified.;
        %return;
    %end;
    %if %eval( %sysfunc(cexist(&library..formats.&format..format)) + %sysfunc(cexist(&library..formats.&format..formatc)) )=0 %then %do;
        %put %str(E)RROR: The specified format does not exist.;
        %return;
    %end;

    proc format library=&library cntlout=&format
    %if "&keep" ne "" %then %do;
        (keep=&keep)
    %end;
    ;

    %if %sysfunc(cexist(&library..formats.&format..format))=1 %then %do;
        select &format;
    %end;
    %else %if %sysfunc(cexist(&library..formats.&format..formatc)) %then %do;
        select $&format;
    %end;
    run;

    %if %sysfunc(exist(&format))=1 %then %do;
        dm "vt %sysfunc(compress(&format))" vt;
    %end;

%mend ViewFormat;
