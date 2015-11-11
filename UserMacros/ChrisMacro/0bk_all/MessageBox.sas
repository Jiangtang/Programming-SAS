%macro MessageBox(message,title=Message,buttons=O,default=,icon=,type=MACRO,lib=SHARE)
    / des="Use a Windows message box to communicate with user";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       MessageBox
        Author:     Chris Swenson
        Created:    2010-09-28

        Purpose:    Use a Windows message box

        Arguments:  message  - message to display
                    title=   - title of message
                    buttons= - argument to specify which buttons are available
                    default= - default button
                    icon=    - icon to display with message
                    type=    - type of processing, either a DATA step, which allows
                               for line breaks, or MACRO, which allows for setting
                               the output to a macro variable, for example:
                               %let response=%messagebox(Do you like pasta?, buttons=YN);
                    lib=     - libref of the location of the SASCBTBL code

        Usage:      The user must first compile and store the API in comments below.
                    Either run the macro with HELP specified as the first argument or
                    read the details below for the specific arguments that are
                    acceptable.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-07-19  CAS     Fixed an issue when quotes are involved in the message.
        2011-09-02  CAS     Re-fixed a quoting issue...

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Source of API */
    /*filename msgbox catalog 'work.winapi.msgbox.source';*/
    /*data _null_;*/
    /*  file msgbox;*/
    /*  input;*/
    /*  put _infile_;*/
    /*cards4;*/
    /*routine MessageBoxA minarg=4 maxarg=4*/
    /*   module=USER32*/
    /*   stackpop=called*/
    /*   returns=short*/
    /*;*/
    /*arg 1 input num  format=pib4. byvalue;  * Window parent, always use 0;*/
    /*arg 2 input char format=$cstr200.;      * Message ;*/
    /*arg 3 input char format=$cstr200.;      * Title;*/
    /*arg 4 input num  format=pib4. byvalue;  * Style;*/
    /** arg4 - style;*/
    /**    0   OK button only*/
    /**    1   OK and Cancel buttons*/
    /**    2   Abort, Retry and Ignore buttons*/
    /**    3   Yes, No, Cancel buttons*/
    /**    4   Yes, No buttons*/
    /**    5   Retry , cancel buttons*/
    /**   16   Icon=Stop sign (hand)*/
    /**   32   Icon=Question mark*/
    /**   48   Icon=Exclamation mark*/
    /**   64   Icon=i (info) symbol*/
    /**    0   Button 1 is default*/
    /**  256   Button 2 is default*/
    /**  512   Button 3 is default*/
    /*;*/
    /** return codes*/
    /**    0   Out of memory*/
    /**    1   OK pressed*/
    /**    2   Cancel pressed*/
    /**    3   Abort pressed*/
    /**    4   Retry pressed*/
    /**    5   Ignore pressed*/
    /**    6   Yes pressed*/
    /**    7   No pressed*/
    /*;;;;*/
    /*run;*/
    /*filename msgbox clear;*/
    /*filename sascbtbl catalog 'work.winapi.msgbox.source';*/

    /* Output help */
    /* REVISION 2011-07-19 CAS: Fixed an issue when quotes are involved. */
    /* REVISION 2011-09-02 CAS: Apparently I didn't fix it right the first time... */
    %if %qsubstr(&MESSAGE, 1, 1) ne %str(%")
    and %qsubstr(&MESSAGE, 1, 1) ne %str(%')
    %then %do;
      %if "%qupcase(&MESSAGE)"="HELP" %then %do;

        %help:

        %put ;
        %put NOTE: HELP INFORMATION FOR THE MESSAGEBOX MACRO ARGUMENTS;
        %put ;
        %put NOTE- Message (Required):;
        %put NOTE- Any text up to 200 characters to appear in the message;
        %put NOTE- Note: If "help" is typed, this menu will appear.;
        %put NOTE- Note: If using the DATA type, enclose message in quotes.;
        %put ;
        %put NOTE- Title (Optional):;
        %put NOTE- Any text up to 200 characters to appear in the title;
        %put NOTE- Default: "Message";
        %put ;
        %put NOTE- Buttons (Optional):;
        %put NOTE- O - OK button only (Default);
        %put NOTE- OC - OK and Cancel buttons;
        %put NOTE- YN - Yes and No buttons;
        %put NOTE- YNC - Yes, No, and Cancel buttons;
        %put NOTE- ARI - Abort, Retry, and Ignore buttons;
        %put NOTE- RC - Retry and Cancel buttons;
        %put ;
        %put NOTE- Default (Optional):;
        %put NOTE- 1 - Button 1 (Default);
        %put NOTE- 2 - Button 2;
        %put NOTE- 3 - Button 3;
        %put ;
        %put NOTE- Icon (Optional):;
        %put NOTE- E - Icon=Exclamation mark;
        %put NOTE- I - Icon=i (info) symbol;
        %put NOTE- Q - Icon=Question mark;
        %put NOTE- S - Icon=Stop sign;
        %put NOTE- Default: None;
        %put ;
        %put NOTE- Type (Optional):;
        %put NOTE- Macro - Execute only as a macro program;
        %put NOTE- Data - Execute within a data step, which allows for breaks in message;
        %put NOTE- Note: The Data type sets up a temporary variable 'break', which can be used in the message;
        %put NOTE- %str(      )argument to separate lines. For example:;
        %put NOTE- %str(      )"This is a message." || break || "Here is a new line.";
        %put ;

        %return;

      %end;
    %end;

    %let buttons=%upcase(&buttons);
    %let icon=%upcase(&icon);
    %let type=%upcase(&type);

    /* Check arguments */
    %if %superq(message)=%str() %then %do;
        %put %str(E)RROR: No MESSAGE argument specified.;
        %return;
    %end;

    %if %index(*DATA*MACRO*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid type argument specified. Please use MACRO or DATA.;
        %return;
    %end;

    %if &TYPE=DATA %then %do;
      %if %nrbquote(%substr(%superq(message), 1, 1)) ne %str(%") %then %do;
      %if %nrbquote(%substr(%superq(message), 1, 1)) ne %str(%') %then %do;
          %put %str(E)RROR: Please enclose message in qoutes.;
          %return;
      %end; %end;
      %if %nrbquote(%substr(%superq(message), %length(%superq(message)), 1)) ne %str(%") %then %do;
      %if %nrbquote(%substr(%superq(message), %length(%superq(message)), 1)) ne %str(%') %then %do;
          %put %str(E)RROR: Please enclose message in qoutes.;
          %return;
      %end; %end;
    %end;

    %if "&title"="" %then %do;
        %put %str(E)RROR: No TITLE argument specified.;
        %return;
    %end;
    %if "&buttons"="" %then %do;
        %put %str(E)RROR: No BUTTONS argument specified.;
        %goto help;
    %end;

    /* Check and convert arguments */
    %if "&buttons" ne "" %then %do;

        /* Check for valid values */
        %if %index(*O*OC*YN*YNC*ARI*RC*,*&buttons*)=0 %then %do;
            %put %str(E)RROR: %str(I)nvalid BUTTONS argument specified. Please use O, OC, YN, YNC, ARI, or RC.;
            %goto help;
        %end;

        /* Convert for API */
        /* Note: No need to remap 0 */
              %if &buttons=O   %then %let buttons=0;
        %else %if &buttons=OC  %then %let buttons=1;
        %else %if &buttons=YN  %then %let buttons=4;
        %else %if &buttons=YNC %then %let buttons=3;
        %else %if &buttons=ARI %then %let buttons=2;
        %else %if &buttons=RC  %then %let buttons=5;

    %end;

    %if "&default" ne "" %then %do;

        /* Check for valid values */
        %if %index(*1*2*3*,*&default*)=0 %then %do;
            %put %str(E)RROR: %str(I)nvalid DEFAULT argument specified. Please use 1, 2, or 3.;
            %goto help;
        %end;

        /* Convert for API */
              %if &default=1 %then %let default=0;
        %else %if &default=2 %then %let default=256;
        %else %if &default=3 %then %let default=512;

    %end;

    %if "&icon" ne "" %then %do;

        /* Check for valid values */
        %let icon=%substr(&icon, 1, 1);
        %if %index(*E*I*Q*S*,*&ICON*)=0 %then %do;
            %put %str(E)RROR: %str(I)nvalid ICON argument specified. Please use E (Exclamation), I (Info), Q (Question), or S (Stop).;
            %goto help;
        %end;

        /* Convert for API */
              %if &icon=E %then %let icon=48;
        %else %if &icon=I %then %let icon=64;
        %else %if &icon=Q %then %let icon=32;
        %else %if &icon=S %then %let icon=16;

    %end;

    /* Set defaults */
    %if "&default"="" %then %let default=0;
    %if "&icon"="" %then %let icon=0;

    /* Associate with the catalog that contains the configuration */
    %local fn SASCBTBL;
    %let SASCBTBL=SASCBTBL;
    %let fn=%sysfunc( filename(SASCBTBL, &LIB..winapi.msgbox.source, CATALOG) );
    %if &fn ne 0 %then %put %sysfunc(sysmsg());
    %if %sysfunc(fileref(sascbtbl))>0 %then %do;
        %put %str(E)RROR: SASCBTBL fileref assignment failed.;
        %return;
    %end;

    %if &TYPE=MACRO %then %do;

        /* Call the message box function */
        %local response;
        %let response=%sysfunc( modulen(MessageBoxA, 0, &message, &title, %eval(&buttons + &default + &icon)) );

    %end;

    %else %if &TYPE=DATA %then %do;

        data _null_;
            format response $15.;
            break=byte(13) || byte(10);
            response=put(modulen('MessageBoxA', 0
                      , &message
                      , "&title"
                      , %eval(&buttons + &default + &icon)
            ), 8.);
            call symputx('response', response, 'g');
        run;

    %end;

    /* Remap response to human-readable format */
          %if &response=0 %then %let response=OUT OF MEMORY;
    %else %if &response=1 %then %let response=OK;
    %else %if &response=2 %then %let response=CANCEL;
    %else %if &response=3 %then %let response=ABORT;
    %else %if &response=4 %then %let response=RETRY;
    %else %if &response=5 %then %let response=IGNORE;
    %else %if &response=6 %then %let response=YES;
    %else %if &response=7 %then %let response=NO;

    /* Output response */
    %if &TYPE=MACRO %then %do;
        &response
    %end;
    %else %if &TYPE=DATA %then %do;
        %put NOTE: Use the RESPONSE macro variable to incorporate the user input.;
        %put NOTE: User response: &response;
    %end;

%mend MessageBox;
