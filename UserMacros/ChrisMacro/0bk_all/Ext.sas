%macro Ext(file,name,case=UP) / des='Output the extension for a file';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       Ext
        Author:     Chris Swenson
        Created:    2011-02-09

        Purpose:    Output the extension for a specified file, either as a direct
                    output or as a macro variable.

        Arguments:  file - filename to output extension for
                    name - name of macro variable to output
                    case - up (default) or low for the output case

        Examples:   %if %ext(c:\test\text.txt)=txt %then %do; ... %end;

                    %ext(c:\test\text.txt, ext);
                    %if &EXT=TXT %then %do; ... %end;

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let case=%upcase(&CASE);

    /* Check for a blank file argument */
    %if %superq(FILE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for FILE.;
        %return;
    %end;
    %if %index(*LOW*LOWCASE*UP*UPCASE*,*&CASE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for CASE. Please use UP or LOW.;
        %return;
    %end;

    /* Find extension */
    %local _ext_;
    %let _ext_=%scan(%superq(FILE), -1, %str(.));

    /* Set case */
    %if %index(*UP*UPCASE*,*&CASE*)>0 %then %do;
        %let _ext_=%upcase(&_EXT_);
    %end;
    %else %if %index(*LOW*LOWCASE*,*&CASE*)>0 %then %do;
        %let _ext_=%lowcase(&_EXT_);
    %end;

    /* Output extension if no macro variable name specified */
    %if %superq(NAME)=%str() %then %do;
        &_EXT_
    %end;

    /* Output extension as macro variable */
    %else %do;

        %global &NAME;
        %let &NAME=&_EXT_;
        %put NOTE: The extension is &_EXT_ (macro variable %upcase(&NAME)).;

    %end;

%mend Ext;
