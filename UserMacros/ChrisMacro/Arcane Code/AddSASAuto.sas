%macro AddSASAuto(ref) / des="Add a fileref to the SASAutos option";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       AddSASAuto
        Author:     Chris Swenson
        Created:    2010-10-18

        Purpose:    Add a fileref to the SAS autocall macro option (SASAUTOS)

        Arguments:  ref - one or more filerefs to add to the option

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let ref=%upcase(&ref);

    %if "&ref"="" %then %do;
        %put %str(E)RROR: No arguments specified.;
        %return;
    %end;

    %local count sasautos addref i current changed;
    %let count=%sysfunc(countw(ref, %str( )));

    %let sasautos=%sysfunc(getoption(sasautos));
    %if "%substr(&SASAUTOS, 1, 1)"="("
    %then %let sasautos=%substr(&SASAUTOS, 2, %length(&SASAUTOS)-2);

    %let addref=&ref;

    %do i=1 %to &count;

        %let current=%scan(&ref, &i, %str( ));

        %if %sysfunc(fileref(&current)) ne 0 %then %do;
            %put %str(E)RROR: Specified fileref &current does not exist.;
            %return;
        %end;

        %let changed=%sysfunc(tranwrd(&sasautos, %str( ), %str(*)));

        %if %index(*&CHANGED*,*&CURRENT*)>0 %then %do;
            %put NOTE: Specified fileref &current is already specified on the SASAUTOS option.;
            %let addref=%sysfunc(tranwrd(&addref, &current, %str()));
        %end;

    %end;

    option sasautos=(&addref &sasautos);

    %put NOTE: SAS Autocall Option (SASAutos) = %sysfunc(getoption(sasautos));

%mend AddSASAuto;
