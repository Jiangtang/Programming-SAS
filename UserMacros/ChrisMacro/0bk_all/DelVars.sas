%macro DelVars(like,exclude=CDIR CLIB) / CMD des="Delete user macro variables";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       DelVars
        Author:     Chris Swenson
        Created:    2010-02-23

        Purpose:    Delete user macro variables, borrowed from SAS online

        Arguments:  like     - macro variables to delete that match the specified
                               prefix
                    exclude= - macro variables to exclude from deletion, currently
                               defaulted to my directory and library macro variables
                               (CDIR and CLIB), which should be modified for other
                               users

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-06-02  CAS     Added 'like' argument to only delete those variables
                            matching a specified prefix, using the SQL LIKE operator.

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let like=%unquote(%upcase(%superq(LIKE)));

    %local excludelist;
    %if %superq(exclude) ne %str() %then %let excludelist=%unquote(%seplist(&exclude, dlm=%str( ), nest=Q));

    proc sql;
        create table _vars_ as
        select * from sashelp.vmacro
    %if %superq(LIKE) ne %str() %then %do;
        where upcase(name) like %unquote(%str(%')&LIKE%nrbquote(%)%str(%'))
    %end;
        ;
    quit;

    data _null_;
        set _vars_;

        /* Exclude macro variables */
    %if %superq(exclude) ne %str() %then %do;
        where upcase(name) not in (&excludelist);
    %end;

        temp=lag(name);

        /* Only execute the delete statement if the macro variable is not a SYSTEM
           variable, the name is not the same as a prior variable (not sure why),
           and the scope is GLOBAL. */
        if scope='GLOBAL' 
           and substr(name,1,3) ne 'SYS' 
           and temp ne name
           then call execute('%symdel ' || trim(left(name)) || ';');
    run;

    /* Drop the temporary table */
    proc sql;
        drop table _vars_;
    quit;

%mend DelVars;
