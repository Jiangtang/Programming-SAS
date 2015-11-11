%macro COUNTW(args,dlm) / des='Uses COUNTW in SAS 9.2+, alternative in prior versions';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       CountW
        Author:     Chris Swenson
        Created:    2011-08-05

        Purpose:    Uses the COUNTW function in SAS 9.2+, but reverts to a different
                    process to do the same thing in prior versions.

        Usage:      Use as a function to assign a value to a macro variable or to
                    use within logic. Use only where functions would be used.

        Limitation: The macro only uses one delimiter at a time.

        Arguments:  args - Argument to pass to the COUNTW function or to count in the
                           alternative method
                    dlm  - Delimiter to use to separate arguments

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if "&DLM"="" %then %let dlm=%str( );

    %if %substr(&SYSVER, 1, 3)=9.1 %then %do;

        %local countw arg;
        %let countw=1;
        %let arg=%scan(%superq(ARGS), &COUNTW, &DLM);

        %do %while("&ARG" ne "");
            %let countw=%eval(&COUNTW+1);
            %let arg=%scan(&ARGS, &COUNTW, &DLM);
        %end;

        %let countw=%eval(&countw-1);

        &COUNTW

    %end;
    %else %do;
        %sysfunc(countw(&ARGS, &DLM))
    %end;

%mend COUNTW;
