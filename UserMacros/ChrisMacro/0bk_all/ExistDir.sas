%macro ExistDir(dir) / des="Check if directory exists";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ExistDir
        Author:     Chris Swenson
        Created:    2009-10-23

        Purpose:    Check if directory exists

        Arguments:  dir - directory to check

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %local user_mprint;
    %let user_mprint=%sysfunc(getoption(mprint));
    options nomprint;

    /* Assume Directory Exists */
    %global nodir;
    %let nodir=0;

    /* Check for argument */
    %if "&dir"="" %then %do;
        %let nodir=1;
        %put %str(E)RROR: Please specify a directory.;
        %goto exit; /* Restore options and exit */
    %end;

    /* Check for the backslash and add it if it is missing */
    %if %substr(&dir,%length(&dir),1) ne \ %then %do;
        %let dir=&dir.\;
        %put NOTE: There was no backslash at the end of the directory. It was added.;
    %end;

    /* Check that the specified directory exists, if not change nodir */
    %if %sysfunc(fileexist("&dir"))=1 %then %put NOTE: The specified directory exists.;
    %else %do;
        %let nodir=1;
        %put %str(E)RROR: The specified directory does not exist.;
    %end;

    %exit:

    options &user_mprint;

%mend ExistDir;
