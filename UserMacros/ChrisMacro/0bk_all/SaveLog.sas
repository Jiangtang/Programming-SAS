%macro SaveLog(name,dir,format=) / des='Save the log';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       SaveLog
        Author:     Chris Swenson
        Revised:    2010-01-13

        Purpose:    Save the SAS log and output to a directory

        Arguments:  name    - name of log and output files
                    dir     - directory to save log and output
                    format= - format of optional date/time stamp (see below)

        Formats:    t - YYYYMMDD_HHMMSS
                    d - YYYYMMDD
                    m - YYYYMON
                    q - YYYYQ#
                    y - YYYY

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     *********************************************************************************
      END MACRO HEADER
     *********************************************************************************/


    /********************************************************************************
       Check Arguments
     ********************************************************************************/

    /* Check the name argument */
    %if "&name"="" %then %do;
        %put %str(E)RROR: No log name specified.;
        %return;
    %end;

    /* Check that the argument is populated */
    %if "&dir"="" %then %do;
        %put %str(E)RROR: No output directory specified.;
        %return;
    %end;

    /* Check for the backslash and add it if it is missing */
    %if %substr(&dir,%length(&dir),1) ne \ %then %do;

        %let dir=&dir.\;
        %put NOTE: There was no backslash at the end of the directory. It was added.;

    %end;

    /* Check that the specified directory exists, if not output message and end the macro */
    %if %sysfunc(fileexist(&dir)) %then %put NOTE: The specified directory exists.;
    %else %do;

        %put %str(E)RROR: The specified directory does not exist.;
        %return;

    %end;


    /********************************************************************************
       Set Date Format
     ********************************************************************************/

    %let format=%lowcase(&format);
    %local dtext;

    /* Set the format of the date */
    %if "&format"="" %then %do;
        %let dtext=;
        %put NOTE: No date format specified. No date will be appended to the output filename(s).;
    %end;
    %else %do;

        data _null_;
            format format $10.;
            format="&format";

            /* Set date according to specified format */
                 if format="t" then today=put(today(), yymmddn8.);
            else if format="d" then today=put(today(), yymmddn8.);
            else if format="m" then today=put(today(), yymmn.);
            else if format="q" then today=put(today(), yyq6.);
            else if format="y" then today=put(today(), year4.);

            /* Remove colon from time */
            time=compress(put(time(),hhmm5.),":");

            /* Combine date and time if specified */
            if format="t" then date="_"||today||"_"||time;
            else date="_"||today;

            /* Combine with underscore and set macro variable */
            call symputx("dtext",date);
            put "NOTE: The date extension is: " date;
        run;

    %end;


    /********************************************************************************
       Save Log and Output
     ********************************************************************************/

    %global log;
    %local fullname;
    %let fullname=&dir.&name.&dtext.;
    %let log=&fullname..log;

    /* Save log to specified path */
    dm log "file '&fullname..log' replace;" wpgm;

    /* Save output to specified path */
    dm output "file '&fullname..lst' replace;" wpgm;

    /* Messages */
    data _null_;
        put "NOTE: The log was saved to the following location:";
        put "NOTE- &fullname..log";
        if fileexist("&fullname..lst") then do;
            put "NOTE-";
            put "NOTE: The output was saved to the following location:";
            put "NOTE- &fullname..lst";
            put "NOTE-";
        end;
        else do;
            put "NOTE-";
            put "NOTE: The output was not saved since it was empty.";
            put "NOTE-";
        end;
    run;

%mend SaveLog;
