%macro Lightsaber(color) / des="May the Force be with you";

    /* Turn off mprint momentarily */
    %let opmprint=%sysfunc(getoption(mprint));
    options nomprint;

    /* Set the argument to upper case */
    %let color=%upcase(&color);

    /* Check for a valid argument */
    %if %index(*R*G*B*,*&color*) %then %do;

        %local colorvar quote;

        %let colorvar=;
        %let quote=;

        %if &color=R %then %do;
            %let colorvar=%str(E)RROR;
            %let quote="If you only knew the power of the Dark Side!" - Darth Vader;
        %end;

        %else %if &color=G %then %do;
            %let colorvar=%str(W)ARNING;
            %let quote="Remember, a Jedi%str(%')s strength flows from the Force." - Yoda;
        %end;

        %else %if &color=B %then %do;
            %let colorvar=%str(N)OTE;
            %let quote="Your father wanted you to have this when you were old enough." - Obi-Wan;
        %end;

        %put &colorvar- ;
        %put &colorvar-                         \         \        \         /         /         /  ;
        %put &colorvar-        _________________ ________________________________________________   ;
        %put &colorvar-       (_____IIIIIII_@___(________________________________________________)  ;
        %put &colorvar-                                                                             ;
        %put &colorvar-                         /         /        /         \         \         \  ;
        %put &colorvar- ;
        %put &colorvar-       &quote;
        %put &colorvar- ;

    %end;

    /* If the argument is not valid, output message with options for argument */
    %else %put %str(E)RROR: Incorrect color argument. Use R (red), G (green), or B (blue).;

    /* Reset mprint option to original setting */
    options &opmprint;

%mend Lightsaber;
