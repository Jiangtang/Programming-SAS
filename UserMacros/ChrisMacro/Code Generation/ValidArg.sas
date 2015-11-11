%macro ValidArg(varlist,type=BLANK,list=) / des="Write code to validate macro arguments";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ValidArg
        Author:     Chris Swenson
        Created:    2010-08-19

        Purpose:    Write code to validate macro program arguments, including the
                    following checks (see below). The code is copied to the clipboard
                    for the user to paste within the macro code. This macro should 
                    not be referenced within a macro, since by itself it does not 
                    complete the check, but generates code that does so.

        Arguments:  varlist - The list of macro arguments to generate checks for, 
                              separated by spaces. Note that the specified validation
                              types will be generated for all specified arguments.
                    type=   - The type of check to generate, including the following:
                                - BLANK = Checks for blank arguments
                                - YN = Checks that the argument is either Y or N
                                - LIST = Checks that the argument is one of the
                                  values in the LIST argument
                    list=   - Valid values for the LIST type check, separated by
                              spaces

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Manage arguments */
    %if %superq(VARLIST)=%str() %then %do;
        %put %str(E)RROR: No argument specified for VARLIST.;
        %return;
    %end;

    %if %superq(TYPE)=%str() %then %do;
        %put %str(E)RROR: No argument specified for TYPE.;
        %return;
    %end;

    %let type=%upcase(&TYPE);
    %if "&TYPE"="YN" %then %do;
        %let type=LIST;
        %let list=Y N;
    %end;
    %if %index(*BLANK*LIST*,*&TYPE*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid argument specified for TYPE.;
        %put %str(E)RROR- Please use BLANK, LIST, or YN.;
        %return;
    %end;

    %if %index(*LIST*,*&TYPE*)>0 and %superq(LIST)=%str() %then %do;
        %put %str(E)RROR: No argument specified for LIST. This argument is required for the LIST type.;
        %return;
    %end;

    /* Set new variables */
    %local num b y l i var list_ind;
    %let num=%sysfunc(countw(&VARLIST));
    %put ;

    /* Associate with the clipboard */
    filename _cb_ clipbrd;

    /* Generate checks */
    data _null_;
        format temp temp0 temp1 temp2 temp3 $250.;
        file _cb_;

    /* Blanks */
    %if %index(*BLANK*,*&TYPE*) %then %do;

        temp='/* Check for blank arguments */';
        put temp;

      %do b=1 %to &NUM;

        %let var=%upcase(%scan(&VARLIST, &B, %str( )));

        temp0='';
        temp1='%if %superq(' || "&VAR" || ')=%str() %then %do;';
        temp2='%put %str(E)RROR: No argument specified for ' || "&VAR" || '.;';
        temp3='';

        put temp1;
        put '    ' temp2;
        put "    %return;";
        put "%end;";

      %end;
    %end;

    /* List or YN */
    %if %index(*LIST*YN*,*&TYPE*) %then %do;

        temp='/* Check for argument values in (' || "&LIST" || ') */';
        put temp;

      %do l=1 %to &NUM;

        %let var=%upcase(%scan(&VARLIST, &L, %str( )));
        %let list=%upcase(&LIST);

        /* Generate list for index */
        %let list_ind=%sysfunc(tranwrd(&LIST, %str( ), %str(*)));

        /* Generate list for report */
        %do r=1 %to %sysfunc(countw(&LIST));
            %if &R=1 %then 
              %let list_rep=%scan(&LIST, &R, %str( ));
            %else %if %sysfunc(countw(&LIST))=2 %then
              %let list_rep=&LIST_REP or %scan(&LIST, &R, %str( ));
            %else %if &R=%sysfunc(countw(&LIST)) %then
              %let list_rep=&LIST_REP, or %scan(&LIST, &R, %str( ));
            %else 
              %let list_rep=&LIST_REP, %scan(&LIST, &R, %str( ));
        %end;

        temp0='%let ' || "&VAR" || '=%upcase(&' || "&VAR" || ');';
        temp1='%if %index(*' || "&LIST_IND" || '*,*&' || "&VAR" || '*)=0 %then %do;';
        temp2='%put %str(E)RROR: %str(I)nvalid argument specified for ' || "&VAR" || '.;';
        temp3='%put %str(E)RROR- Please use one of the following: ' || "&LIST_REP" || '.;';

        put temp0;
        put temp1;
        put '    ' temp2;
        put '    ' temp3;
        put "    %return;";
        put "%end;";

      %end;
    %end;

    run;

    /* Clear clipboard association */
    filename _cb_ clear;

    %put ;
    %put NOTE: The generated code has been copied to the clipboard.;
    %put NOTE- Paste the code in the appropriate area.;

%mend ValidArg;
