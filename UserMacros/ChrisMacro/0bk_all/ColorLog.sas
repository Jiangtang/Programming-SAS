%macro ColorLog(color,message) / des='Write message to log in color';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       ColorLog
        Author:     Chris Swenson
        Created:    2009-09-29

        Purpose:    Write message to log in color, using red, green, or blue

        Arguments:  Color   - Desired color, either R (Red), G (Green), or B (Blue)
                    Message - Message to appear in the log in the desired color

        Note:       This macro uses one of the strangest SAS code I've ever seen.

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    /* Set argument to upper case */
    %let color=%upcase(&color);

    /* Output message if no argument is specified */
    %if "&message"="" %then %put %str(E)RROR: No message specified.;

    %else %do;

        /* The dash (-) after the "issue" words remove them from the log, but retain the color */
              %if &color=R %then %put ER%str(ROR-)  &message;
        %else %if &color=G %then %put WA%str(RNING-)&message;
        %else %if &color=B %then %put NO%str(TE-)   &message;

        /* Output message if incorrect argument is specified */
        %else %put %str(E)RROR: Incorrect color argument specified. Use R (Red), G (Green), or B (Blue).;

    %end;

%mend ColorLog;
