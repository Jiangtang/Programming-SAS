%macro Sonnets(value,library=,test=N) / des="Write sonnets by Shakespeare to the log";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       Sonnets
        Author:     Chris Swenson
        Created:    2011-01-18

        Purpose:    Output sonnets by Shakespeare to the log

        Arguments:  value    - either the number or roman numeral for the sonnet, or
                               'random' for a random sonnet
                    library= - library to output sonnets data set
                    test=    - flag to indicate testing

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    %if "&VALUE"="" %then %do;
        %put %str(E)RROR: No number or numeral specified. "RANDOM" may be specified.;
        %return;
    %end;

    %if "&LIBRARY"="" %then %do;
        %put NOTE: Defaulting sonnets library to WORK.;
        %let library=%sysfunc(pathname(work));
    %end;

    %if %index(*N*Y*,%upcase(*&TEST*))=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid value. Please use Y or N.;
        %return;
    %end;

    %let value=%upcase(&VALUE);
    %let test=%upcase(&TEST);


    /********************************************************************************
       Settings
     ********************************************************************************/

    /* Store and turn off options */
    %if &TEST=N %then %do;
        %local user_notes user_mprint;
        %let user_notes=%sysfunc(getoption(notes));
        %let user_mprint=%sysfunc(getoption(mprint));
        option nomprint;
        option nonotes;
    %end;


    /********************************************************************************
       Random Value
     ********************************************************************************/

    /* If random then select random number */
    %if &VALUE=%upcase(RANDOM) %then %do;

        data random;
            format number random 8.;
            do number=1 to 154;
                random=rand('UNIFORM')*100000;
                output;
            end;
        run;

        proc sort data=random;
            by random;
        run;

        data _null_;
            set random(obs=1);
            call symputx('value', number);
        run;

        proc sql;
            drop table random;
        quit;

    %end;


    /********************************************************************************
       Storage
     ********************************************************************************/

    /* Check sonnets library directory argument */
    %if %sysfunc(fileexist(&LIBRARY))=0 %then %do;
        %put %str(E)RROR: The specified library directory does not exist.;
        %return;
    %end;

    /* Assign sonnets library if necessary */
    %if %sysfunc(libref(Sonnets)) ne 0 %then %do;
        libname Sonnets "&LIBRARY";
    %end;


    %if %sysfunc(exist(Sonnets.Sonnets))=0 %then %do;

        /********************************************************************************
           Define Roman Format
         ********************************************************************************/

        data roman;
            retain fmtname 'roman' type 'i';
            do label=-9999 to 9999;
                start=put(label, roman32.);
                output;
            end;
            hlo='o';
            label=.;
            output;
        run;

        proc format cntlin=roman;
        run;

        proc sql;
            drop table roman;
        quit;


        /********************************************************************************
           Download Sonnets
         ********************************************************************************/

        /* Set (E)RROR detection macro variables */
        %let _EFIERR_ = 0;
        %let ervar=%str(_E)RROR_;

        /* Associate with text file */
        filename Sonnets URL "http://dl.dropbox.com/u/13629095/Sonnets.txt";

        /* Import data from text file */
        data Sonnets;
            infile Sonnets delimiter='09'x MISSOVER DSD lrecl=32767 firstobs=1;
            informat Number 8. Numeral $15. Line 8. Title $50. Text $250.;
            format Number 8. Numeral $15. Line 8. Title $50. Text $250.;
            input Text $;

            /* Convert Roman numeral to number */
            if countw(text, ' ')=1 then do;
                Number=input(text, roman.);
                Numeral=text;
                retain number numeral;
                delete;
            end;

            /* Keep only non-missing text */
            if missing(text) then delete;

            /* Set defaults */
            Line=.;
            Title='';

            /* Set (E)RROR detection macro variable */
            if &ERVAR then call symputx('_EFIERR_',1);
        run;

        filename Sonnets clear;

        %if &_EFIERR_ eq 1 %then %put %str(W)ARNING: Import failed!;
        %else %put NOTE: Import success!;


        /********************************************************************************
           Modify Sonnets
         ********************************************************************************/

        /* Update line number and add extra spaces for last two lines */
        data Sonnets.Sonnets(drop=count);
            set Sonnets end=end;
            by number;

            format Count 8.;
            retain Count 0;
            if first.number then do;
                Count=1;
                Title=compbl('Sonnet ' || numeral || ' ' || compress('(' || put(number, 8.) || ')'));
            end;
            else Count=Count+1;
            Line=Count;
        run;

    %end;


    /********************************************************************************
       Output Sonnet
     ********************************************************************************/

    data _null_ / nolist;
        set Sonnets.Sonnets;
    %if %sysfunc(compress(&VALUE, %str(), %str(kd))) ne %str() %then %do;
        where number=&VALUE;
    %end;
    %else %do;
        where numeral="&VALUE";
    %end;
        by number;

        if _n_=1 then do;
            put ' ';
            put '  ' title;
            put ' ';
            put '  ' text;
        end;

        else if number=99 then do;
            if _n_<14 then put '  ' text;
            else put '    ' text;
        end;
        else if number=126 then do;
            if _n_<11 then put '  ' text;
            else put '    ' text;
        end;

        else if _n_<13 then put '  ' text;
        else put '    ' text;
    run;

    %put ;

    /* Restore user options */
    %if &TEST=N %then %do;
        option &USER_NOTES;
        option &USER_MPRINT;
    %end;

%mend Sonnets;
