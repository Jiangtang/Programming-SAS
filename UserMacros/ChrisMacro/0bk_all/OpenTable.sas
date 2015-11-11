%macro OpenTable(table,style=MessageBox,test=N) / des="Open table(s)";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       OpenTable
        Author:     Chris Swenson
        Created:    2010-05-07

        Purpose:    Open specified table(s)

        Arguments:  table  - one or more tables to open, defaulted to last table
                    style= - whether to use the MESSAGEBOX macro or the WINDOW
                             statement supplied by the OpenTable macro when there
                             is no argument specified, the last table exists, and
                             the user has copied a table name. See below for details.
                    test=  - whether to test the macro

        Usage:      The OpenTable macro can be set to a keyboard shortcut:

                    gsubmit '%opentable;'

                    The macro will open the last table generated or the copied table.
                    If both exist, it asks the user which to open.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %put ;

    %let test=%upcase(&TEST);
    %let style=%substr(%upcase(&STYLE), 1, 1);

    /********************************************************************************/

    /* If the table is blank, check the clipboard */
    %if "&table"="" %then %do;

        /* Temporarily turn off specific options */
        %if &TEST ne Y %then %do;

            %let user_mprint=%sysfunc(getoption(mprint));
            %let user_notes=%sysfunc(getoption(notes));
            %let user_erlvl=%sysfunc(getoption(%str(e)rrors));

            option nomprint;
            option nonotes;
            option %str(e)rrors=0;

        %end;

        /* Manage scope and set defaults */
        %local lastok lastmodt clip cber cbok asktbl wrong;
        %let last=&syslast;
        %let lastok=%eval(%sysfunc(exist(%superq(last), %str(DATA))) + %sysfunc(exist(%superq(last), %str(VIEW))));
        %let clip=;
        %let cber=0;
        %let cbok=0;


        /****************************************************************************
           Recent Table
         ****************************************************************************/

        /* If the table is blank, check the modified date of the last table */
        %if &lastok=1 %then %do;

            %let lastmodt=%tableinfo(&last, MODTE);

            /* Evaluate modified date of last table */
            %if &lastmodt ne . %then %do;
                %if %eval( %scan(%sysfunc(datetime()), 1, %str(.)) - %sysfunc(inputn(&lastmodt, datetime20.)) ) < 5
                %then %let table=&last;
            %end;

        %end;


        /****************************************************************************
           Clipboard
         ****************************************************************************/

        %if "&table"="" %then %do;

            /* Access clipboard */
            filename _cb_ clipbrd;

                /* Set clipboard value to macro variable */
                data _null_;
                    infile _cb_ truncover;
                    input content $50.;
                    call symputx('clip', content);
                run;

                /* Retain (e)rror variable */
                %let cber=&SYSERR;

            /* Clear clipboard filename */
            filename _cb_ clear;

            %let clip=%upcase(%superq(clip));
            %if %sysfunc(compress(%superq(clip), %str(.), %str(k))) ne %str(.) %then %let clip=WORK.%superq(clip);

            %put NOTE: Copied value: %superq(clip);
            %put NOTE: Last modified: &syslast;

            /* Evaluate the condition of the clipboard material */
            %if (%superq(clip) ne &SYSLAST) and &cber<4 %then %do;

                %let cbok=%eval(%sysfunc(exist(%superq(clip), %str(DATA))) + %sysfunc(exist(%superq(clip), %str(VIEW))));

                /* If there is a conflict, ask the user */
                %if &cbok=1 and &lastok=1 %then %do;

                    %if &STYLE=M %then %do;

                        %if %MessageBox(
                              Would you like to open the copied table? Otherwise select No to open the last table.
                            , title=OpenTable Question, buttons=YN, default=1, icon=Q)=YES
                        %then %do;
                            %let table=%superq(clip);
                            %put NOTE: Opening table from clipboard.;
                        %end;
                        %else %do;
                            %let table=&syslast;
                            %put NOTE: Opening last table.;
                        %end;

                    %end;
                    %else %if &STYLE=W %then %do;

                        %let asktbl=;
                        %let wrong=;
                        %loop:
                        %window asktbl
                        #2 @5 "&wrong" color=red
                        #3 @5 "OpenTable: Select a Table: " asktbl 1 color=blue attr=rev_video required=yes " (C=Copied, L=Last)"
                        #5 @5 "Press ENTER to continue"
                        ;
                        %display asktbl delete;

                        %let asktbl=%upcase(&asktbl);

                        %if %index(*C*L*,*&ASKTBL*)=0 %then %do;
                            %let wrong=%str(I)NVALID ENTRY;
                            %goto loop;
                        %end;
                        %if &asktbl=C %then %do;
                            %let table=%superq(clip);
                            %put NOTE: Opening table from clipboard.;
                        %end;
                        %else %if &asktbl=L %then %do;
                            %let table=&syslast;
                            %put NOTE: Opening last table.;
                        %end;

                    %end;

                %end;

                /* If not, use clipboard or syslast */
                %else %if &cbok=1 and &lastok=0 %then %let table=%superq(CLIP);
                %else %let table=&last;

            %end;
            %else %let table=&last;

        %end;

        /* Restore user options */
        %if &test ne Y %then %do;
            option %str(e)rrors=&user_erlvl;
            option &user_mprint &user_notes;
        %end;

    %end;

    /********************************************************************************/

    /* Manage macros */
    %local num tbl;

    /* Set initial scan */
    %let num=1;
    %let tbl=%scan(&table, &num, %str( )%str(,)%str(%()%str(%)));

    /* Loop through each argument until blank */
    %do %while("&tbl" ne "");

        /* Check if table exists */
        %if %eval(%sysfunc(exist(&tbl, %str(DATA))) + %sysfunc(exist(&tbl, %str(VIEW))))=1 %then %do;

            dm "vt %sysfunc(compress(&tbl))" vt;

        %end;

        /* Otherwise pop-up a message that it does not exist. */
        %else %do;

            dm 'postmessage "The specified table &table does not exist."';

        %end;

        /* Increment scan */
        %let num=%eval(&num+1);
        %let tbl=%scan(&table, &num, %str( )%str(,)%str(%()%str(%)));

    %end;

    %put ;

%mend OpenTable;
