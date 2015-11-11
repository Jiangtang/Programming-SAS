%macro PM / pbuff des="Post a message using a pop-up";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       PM
        Author:     Chris Swenson
        Created:    2010-08-24

        Purpose:    Post a message using a pop-up

        Arguments:  Message to display

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %local msg;
    %let msg=%substr(%bquote(&syspbuff), 2, %length(%bquote(&syspbuff))-2);

    /* Check for quotes */
    %if %index(*%str(%')*%str(%")*, *%bquote(%substr(%bquote(&msg), 1, 1)*))>0
    and %index(*%str(%')*%str(%")*, *%bquote(%substr(%bquote(&msg), %length(%bquote(&msg)), 1)*))>0
    %then %let msg=%substr(%bquote(&msg), 2, %length(%bquote(&msg))-2);

    dm "postmessage %bquote(')&MSG%bquote(')";

%mend PM;
