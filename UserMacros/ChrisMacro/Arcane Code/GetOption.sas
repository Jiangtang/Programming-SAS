%macro GetOption(option,global=N) / des="Find specified option";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       GetOption
        Author:     Chris Swenson
        Created:    2009-10-23

        Purpose:    Find a specified option

        Arguments:  option  - option to examine
                    global= - whether to output a global macro variable

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if %superq(OPTION)=%str() %then %do;
        %put %str(E)RROR: No option specified.;
        %return;
    %end;
    %if %index(*Y*N*,%upcase(*&GLOBAL*))=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid value for global argument. Please use Y or N.;
        %return;
    %end;

    %if %upcase(&GLOBAL)=Y %then %do;
        %global user_&option;
    %end;

    %if &option= %then %put NOTE: No argument specified.;
    %else %do;

        %let User_&option=%sysfunc(getoption(%unquote(%superq(OPTION))));
        %put NOTE: User_&option=&&User_&option;

    %end;

%mend GetOption;
