%macro BlankFind(varlist) / des="Write code to find blank arguments";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       BlankFind
        Author:     Chris Swenson
        Created:    2010-08-19

        Purpose:    Generate code the find blank macro program arguments. This can be
                    used to generate "argument checks" at the beginning of a macro
                    program to ensure that all arguments are populated. The code
                    cannot be used to do the check because it is best to avoid nested
                    macros.

        Arguments:  varlist - the list of macro arguments to generate checks for, 
                              separated by a space

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if "&VARLIST"="" %then %do;
        %put %str(E)RROR: No variable list specified.;
        %return;
    %end;

    %local num i var;

    %let num=%sysfunc(countw(&VARLIST));

    %put ;

    filename _cb_ clipbrd;

    data _null_;
        format temp1 temp2 $250.;
        file _cb_;

    %do i=1 %to &NUM;

        %let var=%upcase(%scan(&VARLIST, &I, %str( )));

        temp1='%if %superq(' || "&VAR" || ')=%str() %then %do;';
        temp2='%put %str(E)RROR: No argument specified for ' || "&VAR" || '.;';

        put temp1;
        put '    ' temp2;
        put "    %return;";
        put "%end;";

    %end;

    run;

    filename _cb_ clear;

    %put ;
    %put NOTE: The generated code has been copied to the clipboard.;
    %put NOTE- Paste the code in the appropriate area.;

%mend BlankFind;
