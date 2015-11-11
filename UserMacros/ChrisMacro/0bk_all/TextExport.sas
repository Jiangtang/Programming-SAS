%macro TextExport(ds,dir,out=) / des="Export data set to tab-delim text file";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       TextExport
        Author:     Chris Swenson
        Created:    2010-08-13

        Purpose:    Export data set to tab-delim text file

        Arguments:  ds   - data set to export
                    dir  - directory to export data set to
                    out= - name of output

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Check arguments */
    %if "&ds"="" %then %do;
        %put %str(E)RROR: No data set specified (first argument).;
        %return;
    %end;
    %if %sysfunc(exist(&ds))=0 %then %do;
        %put %str(E)RROR: Specified data set does not exist.;
        %return;
    %end;
    %if "&dir"="" %then %do;
        %put %str(E)RROR: No output directory specified (second argument).;
        %return;
    %end;

    /* Check for the backslash and add it if it is missing */
    %if %substr(&dir,%length(&dir),1) ne \ %then %do;
        %let dir=&dir.\;
        %put NOTE: There was no backslash at the end of the directory. It was added.;
    %end;

    %local out;
    %if "&out"="" %then %do;
        %let out=%scan(&ds, 2, %str(.));
        %if "&out"="" %then %let out=&ds;
    %end;

    proc export
        data=&ds
        outfile="&dir.&out..txt"
        dbms=tab replace;
    run;

    %if %sysfunc(fileexist("&dir.&out..txt"))=1 %then %put NOTE: Export succesful.;
    %else %put %str(W)ARNING: Export failed.;

%mend TextExport;
