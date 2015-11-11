%macro JunkLog(switch) / des="Turn off/on log";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       JunkLog
        Author:     Chris Swenson
        Created:    2009-10-23

        Purpose:    Turn off/on log

        Arguments:  switch - either ON or OFF to toggle the status of the log

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯
        2011-05-24  CAS     Added check for fileref before attempting to clear it

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Find mprint option and turn it off */
    %local user_mprint;
    %let user_mprint=%sysfunc(getoption(mprint));
    options nomprint;

    /* Check that the argument specified is valid */
    %if not %index(*ON*OFF*,*%upcase(&switch)*) %then %put %str(E)RROR: %str(I)nvalid or no argument specified.;
    %else %do;

        /* Set the log to a dummy file */
        %if %lowcase(&switch)=off %then %do;
            %put NOTE: The log will be turned off.;
            filename junk dummy;
            proc printto log=junk; run;
        %end;

        /* Restore Log */
        /* REVISION 2011-05-24 CAS: Added check for fileref */
        %if %lowcase(&switch)=on %then %do;
            proc printto; run;
          %if %sysfunc(fileref(JUNK))<1 %then %do;
            filename junk clear;
          %end;
            %put NOTE: The log is now on.;
        %end;

    %end;

    /* Restore mprint option */
    options &user_mprint;

%mend JunkLog;
