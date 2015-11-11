%macro NoLabel(tables) / des='Remove labels from data set(s)';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       NoLabel
        Author:     Chris Swenson
        Created:    2009-10-22

        Purpose:    Remove labels from one or more data sets

        Arguments:  tables - one or more tables to remove labels from

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if "&tables"="" %then %do;
        %put %str(E)RROR: No tables specified.;
        %return;
    %end;

    %local num ds;

    %let num=1;
    %let ds=%scan(&tables, &num, %str( ));

    %do %while("&ds" ne "");

        %if %sysfunc(exist(&ds))>0 %then %do;

            %libtbl(&ds);

            /* Clear Labels on data set */
            proc datasets library=&lib memtype=data nolist;
            modify &tbl;
            attrib _all_ label='';
            run; quit;

        %end;
        %else %put NOTE: The table &ds does not exist.;

        %let num=%eval(&num+1);
        %let ds=%scan(&tables, &num, %str( ));

    %end;

%mend NoLabel;
