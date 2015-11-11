%macro IntoList(ds,var,listname,sepby=BLANK,where=,distinct=Y) / des="Create a macro var list from a column";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       IntoList
        Author:     Chris Swenson
        Created:    2010-10-07

        Purpose:    Create a macro variable list from a column

        Arguments:  ds        - input data set
                    var       - input variable
                    listname  - name of macro variable to store list
                    sepby=    - identifies the separator between items (see below)
                    where=    - criteria to filter the input data set
                    distinct= - whether to pull a distinct list, defaulted to Y

        Family:     Macro Variable Generation Macro Program

                    IntoList  - Create a macro variable that is a list of values from
                                a column in a data set. Optionally define the
                                delimiter and filter the input data set.
                    ObsMac    - Create a macro variable that is a list of values from
                                a column in a data set. Optionally define the
                                delimiter and filter the input data set.
                    SetVars   - Create one or more macro variables from the variable
                                names in a data set. The generated macro variable
                                can either be a list within one macro variable or
                                multiple macro variables named with the specified
                                prefix and appended observation number.
                    TableVars - Create one or more macro variables from the variable
                                names in a data set. The generated macro variable can
                                either be a list within one macro variable or
                                multiple macro variables named with the specified
                                prefix and appended observation number.
                    VarMac    - Create macro variables from two columns, where one
                                column names the macro variable and another supplies
                                the value. Optionally filter the input data set.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-01-03  CAS     Added flag to change whether the list is distinct. This
                            can affect the order of the values and it may be
                            necessary to leave the values in the natural order.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Internal Macro Program
     ********************************************************************************/

    %macro COUNTW(args, dlm) / des='Uses COUNTW in sas 9.2, alternative in prior versions';

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


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    /* REVISION 2011-01-03 CAS: Added check of distinct flag */
    %if "&DISTINCT" ne "" %then %let distinct=%substr(%upcase(&DISTINCT), 1, 1);

    %if "&DS"="" %then %do;
        %put %str(E)RROR: No argument specified for DS.;
        %return;
    %end;
    %if %eval(%sysfunc(exist(&DS, %str(DATA))) + %sysfunc(exist(&DS, %str(VIEW))))=0 %then %do;
        %put %str(E)RROR: The specified data set does not exist.;
        %return;
    %end;
    %if "&VAR"="" %then %do;
        %put %str(E)RROR: No argument specified for VAR.;
        %return;
    %end;
    %if "&LISTNAME"="" %then %do;
        %put %str(E)RROR: No argument specified for LISTNAME.;
        %return;
    %end;
    %if "&SEPBY"="" %then %do;
        %put %str(E)RROR: No argument specified for SEPBY.;
        %goto sephelp;
    %end;
    %if %index(*N*Y*,*&DISTINCT*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid DISTINCT value. Please use Y or N.;
        %return;
    %end;


    /********************************************************************************
       Determine Separator
     ********************************************************************************/

    %local separator;
    %let sepby=%lowcase(&SEPBY);
    %if %length(&SEPBY)>3 %then %do;
        %let sepby=%substr(&SEPBY, 1, 3);
    %end;

    /* Common: space, comma, and parentheses */
          %if %index(*bla*spa*,*&SEPBY*)>0  %then %let separator=' ';
    %else %if %index(*com*,*&SEPBY*)>0      %then %let separator=', ';
    %else %if %index(*par*,*&SEPBY*)>0      %then %let separator=') (';

    /* Quotes */
    %else %if %index(*q*,*&SEPBY*)>0        %then %let separator="' '";
    %else %if %index(*qc*,*&SEPBY*)>0       %then %let separator="', '";
    %else %if %index(*qq*,*&SEPBY*)>0       %then %let separator='" "';
    %else %if %index(*qqc*,*&SEPBY*)>0      %then %let separator='", "';

    /* Misc */
    %else %if %index(*bra*,*&SEPBY*)>0      %then %let separator='] [';
    %else %if %index(*cur*,*&SEPBY*)>0      %then %let separator='} {';
    %else %if %index(*pip*,*&SEPBY*)>0      %then %let separator=' | ';
    %else %if %index(*dot*per*,*&SEPBY*)>0  %then %let separator='. ';
    %else %if %index(*has*,*&SEPBY*)>0      %then %let separator='#';
    %else %if %index(*ast*sta*,*&SEPBY*)>0  %then %let separator='*';
    %else %if %index(*das*hyp*,*&SEPBY*)>0  %then %let separator='-';
    %else %if %index(*lin*und*,*&SEPBY*)>0  %then %let separator='_';
    %else %if %index(*sla*,*&SEPBY*)>0      %then %let separator='/';
    %else %if %index(*bac*,*&SEPBY*)>0      %then %let separator='\';
    %else %do;
        %put %str(E)RROR: %str(I)nvalid SEPBY argument.;
        %sephelp:
        %put ;
        %put %str(E)RROR- Please use one of the following:;
        %put %str(E)RROR- ASTERISK (*);
        %put %str(E)RROR- BACKSLASH (\);
        %put %str(E)RROR- BLANK ( );
        %put %str(E)RROR- BRACKET ([]);
        %put %str(E)RROR- COMMA (,);
        %put %str(E)RROR- CURLY BRACKET ({});
        %put %str(E)RROR- DOT (. );
        %put %str(E)RROR- DASH (-);
        %put %str(E)RROR- HASH (#);
        %put %str(E)RROR- HYPHEN (-);
        %put %str(E)RROR- LINE (_);
        %put %str(E)RROR- PARENTHESES;
        %put %str(E)RROR- PERIOD (. );
        %put %str(E)RROR- PIPE ( | );
        %put %str(E)RROR- Q (single quotes: ' ');
        %put %str(E)RROR- QC (single quotes and commas: ', ');
        %put %str(E)RROR- QQ (double quotes: " ");
        %put %str(E)RROR- QQC (double quotes and commas: ", ");
        %put %str(E)RROR- SLASH (/);
        %put %str(E)RROR- SPACE ( );
        %put %str(E)RROR- STAR (*);
        %put %str(E)RROR- UNDERSCORE (_);
        %put ;
        %put %str(E)RROR- Note: It is only necessary to specify 3 characters for the above arguments.;
        %put ;
        %return;
    %end;


    /********************************************************************************
       Count Arguments
     ********************************************************************************/

    %local varnum listnum;
    %let varnum=%countw(&VAR, %str( ));
    %let listnum=%countw(&LISTNAME, %str( ));

    %if &VARNUM ne &LISTNUM %then %do;
        %put %str(E)RROR: The count of variables does not match the count of lists.;
        %return;
    %end;


    /********************************************************************************
       Create List
     ********************************************************************************/

    %local i;
    %do i=1 %to &VARNUM;

        /* Set current variable and list */
        %local varcur listcur;
        %let varcur=%scan(&VAR, &I, %str( ));
        %let listcur=%scan(&LISTNAME, &I, %str( ));

        /* Delete macro variable if it exists */
        %symdel &LISTCUR / nowarn;

        %global &LISTCUR;

        /* REVISION 2011-01-03 CAS: Added distinct flag processing */
        proc sql noprint;
        %if &DISTINCT=Y %then %do;
            select distinct &VARCUR
        %end;
        %else %do;
            select &VARCUR
        %end;
            into :&LISTCUR separated by &SEPARATOR
            from &DS
        %if %superq(where) ne %str() %then %do;
            where &WHERE
        %end;
            ;
        quit;

        /* Finalize list */
              %if %index(*par*,*&SEPBY*)>0    %then %let &LISTCUR=%unquote((%superq(&LISTCUR)));
        %else %if %index(*bra*,*&SEPBY*)>0    %then %let &LISTCUR=%unquote([%superq(&LISTCUR)]);
        %else %if %index(*cur*,*&SEPBY*)>0    %then %let &LISTCUR=%unquote({%superq(&LISTCUR)});
        %else %if %index(*q*qc*,*&SEPBY*)>0   %then %let &LISTCUR=%unquote(%str(%')%superq(&LISTCUR)%str(%'));
        %else %if %index(*qq*qqc*,*&SEPBY*)>0 %then %let &LISTCUR=%unquote("%superq(&LISTCUR)");
        %else %let &LISTCUR=%unquote(%superq(&LISTCUR));

    %end;


    /********************************************************************************
       Report Created Lists
     ********************************************************************************/

    %put NOTE: The following macro variables were created:;
    %put ;

    /* Obtain new macro variables */
    proc sql;
        create table _mvars_ as
        select name, value
        from sashelp.vmacro
        where scope="GLOBAL"
          and name in (
    %local l;
    %do l=1 %to &VARNUM;
        %upcase("%scan(&LISTNAME, &L, %str( ))")
    %end;
        )
        ;
    quit;

    /* Write macro variables to log */
    data _null_;
        set _mvars_ end=end;
        if _n_=1 then do;
            put "NOTE: The following macro variables were created:";
            put " ";
            put "NOTE- Name " @40 "Value";
            put "NOTE- ---- " @40 "-----";
        end;
        put "NOTE- " name @40 value;
        if end then put "NOTE-";
    run;

    /* Drop temporary table */
    %local user_notes user_mprint;
    %let user_notes=%sysfunc(getoption(notes));
    %let user_mprint=%sysfunc(getoption(mprint));
    option nomprint nonotes;
    proc sql;
        drop table _mvars_;
    quit;
    option &USER_NOTES;
    option &USER_MPRINT;

%mend IntoList;
