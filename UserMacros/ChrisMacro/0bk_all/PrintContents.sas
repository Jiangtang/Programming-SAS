%macro PrintContents(table,short=N,style=MessageBox,test=N) / des="Print the contents of the specified table(s)";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       PrintContents
        Author:     Chris Swenson
        Created:    2010-05-07

        Purpose:    Print the contents of the last table

        Arguments:  table  - one or more tables to print the contents of, defaulted
                             to last table
                    short= - Y/N as to the length of the output, where Y excludes
                             the data set label
                    style= - whether to use the MESSAGEBOX macro or the WINDOW
                             statement supplied by the PrintContents macro when there
                             is no argument specified, the last table exists, and
                             the user has copied a table name. See below for details.
                    test=  - whether to test the macro

        Usage:      The PrintContents macro can be set to a keyboard shortcut:

                    gsubmit '%PrintContents;'

                    The macro will print the contents of the last table generated or
                    the copied table. If both exist, it asks the user which to print.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-07-26  CAS     Added processing on clipboard content in order to avoid
                            issues with the macro execution and to check the validity
                            of the contents as a SAS name.
        2011-09-07  CAS     Added new argument short to leave off label.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %put ;

    %let test=%upcase(&TEST);
    %let style=%substr(%upcase(&STYLE), 1, 1);
    %let short=%substr(%upcase(&SHORT), 1, 1);

    /* Check for argument values in (Y N) */
    %if %index(*Y*N*,*&SHORT*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for SHORT.;
        %put %str(E)RROR- Please use one of the following: Y or N.;
        %return;
    %end;

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
                /* REVISION 2011-07-26 CAS: Added processing on clipboard content */
                data _null_;
                    infile _cb_ truncover;
                    input content $50.;
                    content=compress(content, '_.', 'kad');
                    rc=nvalid(scan(content, -1, '.'));
                    if rc=0 then do;
                        content='';
                        call symputx('clip', content);
                    end;
                    else do;
                        call symputx('clip', content);
                    end;
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
                              Would you like to print the copied table? Otherwise select No to print the last table.
                            , title=PrintContents Question, buttons=YN, default=1, icon=Q)=YES
                        %then %do;
                            %let table=%superq(clip);
                            %put NOTE: Printing table from clipboard.;
                        %end;
                        %else %do;
                            %let table=&syslast;
                            %put NOTE: Printing last table.;
                        %end;

                    %end;
                    %else %if &STYLE=W %then %do;

                        %let asktbl=;
                        %let wrong=;
                        %loop:
                        %window asktbl
                        #2 @5 "&wrong" color=red
                        #3 @5 "PrintContents: Select a Table: " asktbl 1 color=blue attr=rev_video required=yes " (C=Copied, L=Last)"
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
                            %put NOTE: Printing table from clipboard.;
                        %end;
                        %else %if &asktbl=L %then %do;
                            %let table=&syslast;
                            %put NOTE: Printing last table.;
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

            proc contents data=&TBL 
            %if &SHORT=Y %then %do;
                out=test noprint
            %end;
                varnum;
            run;

            %if &SHORT=Y %then %do;

                proc sort data=test;
                    by varnum;
                run;

                proc print data=test noobs;
                    var varnum name type length format informat;
                run;

            %end;

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

%mend PrintContents;
