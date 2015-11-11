%macro OpenProperties(table,style=MessageBox,test=N) / des="Open table(s)";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       OpenProperties
        Author:     Chris Swenson
        Created:    2011-10-18

        Purpose:    Open the properties of the specified table

        Arguments:  table  - the table to open the properties of, defaulted to last
                             table
                    style= - whether to use the MESSAGEBOX macro or the WINDOW
                             statement supplied by the OpenProperties macro when there
                             is no argument specified, the last table exists, and
                             the user has copied a table name. See below for details.
                    test=  - whether to test the macro

        Usage:      The OpenProperties macro can be set to a keyboard shortcut:

                    gsubmit '%OpenProperties;'

                    The macro will open the properties of the last table generated or
                    the copied table. If both exist, it asks the user which to open.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-10-18  CAS     Created macro based on OpenTable.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %put ;

    %let test=%upcase(&TEST);
    %let style=%substr(%upcase(&STYLE), 1, 1);

    /********************************************************************************/

    /* If the table is blank, check the clipboard */
    %if "&TABLE"="" %then %do;

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
        %let last=&SYSLAST;
        %let lastok=%eval(%sysfunc(exist(%superq(last), %str(DATA))) + %sysfunc(exist(%superq(last), %str(VIEW))));
        %let clip=;
        %let cber=0;
        %let cbok=0;


        /****************************************************************************
           Recent Table
         ****************************************************************************/

        /* If the table is blank, check the modified date of the last table */
        %if &LASTOK=1 %then %do;

            %let lastmodt=%tableinfo(&LAST, MODTE);

            /* Evaluate modified date of last table */
            %if &LASTMODT ne . %then %do;
                %if %eval( %scan(%sysfunc(datetime()), 1, %str(.)) - %sysfunc(inputn(&LASTMODT, datetime20.)) ) < 5
                %then %let table=&LAST;
            %end;

        %end;


        /****************************************************************************
           Clipboard
         ****************************************************************************/

        %if "&TABLE"="" %then %do;

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
            %put NOTE: Last modified: &SYSLAST;

            /* Evaluate the condition of the clipboard material */
            %if (%superq(clip) ne &SYSLAST) and &CBER<4 %then %do;

                %let cbok=%eval(%sysfunc(exist(%superq(clip), %str(DATA))) + %sysfunc(exist(%superq(clip), %str(VIEW))));

                /* If there is a conflict, ask the user */
                %if &CBOK=1 and &LASTOK=1 %then %do;

                    %if &STYLE=M %then %do;

                        %if %MessageBox(
                              Would you like to open the properties of the copied table? Otherwise select No to open the properties of the last table.
                            , title=OpenProperties Question, buttons=YN, default=1, icon=Q)=YES
                        %then %do;
                            %let table=%superq(clip);
                            %put NOTE: Opening the properties of the table from the clipboard.;
                        %end;
                        %else %do;
                            %let table=&SYSLAST;
                            %put NOTE: Opening the properties of the last table.;
                        %end;

                    %end;
                    %else %if &STYLE=W %then %do;

                        %let asktbl=;
                        %let wrong=;
                        %loop:
                        %window asktbl
                        #2 @5 "&WRONG" color=red
                        #3 @5 "OpenProperties: Select a Table: " asktbl 1 color=blue attr=rev_video required=yes " (C=Copied, L=Last)"
                        #5 @5 "Press ENTER to continue"
                        ;
                        %display asktbl delete;

                        %let asktbl=%upcase(&ASKTBL);

                        %if %index(*C*L*,*&ASKTBL*)=0 %then %do;
                            %let wrong=%str(I)NVALID ENTRY;
                            %goto loop;
                        %end;
                        %if &ASKTBL=C %then %do;
                            %let table=%superq(clip);
                            %put NOTE: Opening the properties of the table from the clipboard.;
                        %end;
                        %else %if &ASKTBL=L %then %do;
                            %let table=&SYSLAST;
                            %put NOTE: Opening the properties of the last table.;
                        %end;

                    %end;

                %end;

                /* If not, use clipboard or syslast */
                %else %if &CBOK=1 and &LASTOK=0 %then %let table=%superq(CLIP);
                %else %let table=&LAST;

            %end;
            %else %let table=&LAST;

        %end;

        /* Restore user options */
        %if &TEST ne Y %then %do;
            option %str(e)rrors=&USER_ERLVL;
            option &user_mprint &USER_NOTES;
        %end;

    %end;

    /********************************************************************************/

    /* Manage macros */
    %local num tbl;

    /* Set initial scan */
    %let num=1;
    %let tbl=%scan(&TABLE, &NUM, %str( )%str(,)%str(%()%str(%)));

    /* Loop through each argument until blank */
    %do %while("&TBL" ne "");

        /* Check if table exists */
        %if %eval(%sysfunc(exist(&TBL, %str(DATA))) + %sysfunc(exist(&TBL, %str(VIEW))))=1 %then %do;

            dm "VAR %sysfunc(compress(&TBL))" var;

        %end;

        /* Otherwise pop-up a message that it does not exist. */
        %else %do;

            dm 'postmessage "The specified table &TABLE does not exist."';

        %end;

        /* Increment scan */
        %let num=%eval(&NUM+1);
        %let tbl=%scan(&TABLE, &NUM, %str( )%str(,)%str(%()%str(%)));

    %end;

    %put ;

%mend OpenProperties;
