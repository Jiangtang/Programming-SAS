%macro Email(from=,to=,cc=,subject=,attach=,message=) / des="Send email with attachment";

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       Email
        Author:     Chris Swenson
        Created:    2010-09-22

        Purpose:    Send an email with an attachment

        Arguments:  to       - e-mail address of the addressee
                    cc       - e-mail address of the addressee for copy
                    subject  - e-mail subject
                    attach   - name, path, and extension of the attached file
                    contents - e-mail contents

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %if %superq(to)=%str() %then %do;
        %put %str(E)RROR: No TO address specified.;
        %return;
    %end;
    %if %superq(subject)=%str() %then %do;
        %put %str(E)RROR: No SUBJECT specified.;
        %return;
    %end;
    %if %superq(message)=%str() %then %do;
        %put %str(E)RROR: No MESSAGE specified.;
        %return;
    %end;

    %if %nrbquote(%substr(%superq(message), 1, 1)) ne %str(%") %then %do;
    %if %nrbquote(%substr(%superq(message), 1, 1)) ne %str(%') %then %do;
        %put %str(E)RROR: Please enclose message in qoutes.;
        %return;
    %end; %end;
    %if %nrbquote(%substr(%superq(message), %length(%superq(message)), 1)) ne %str(%") %then %do;
    %if %nrbquote(%substr(%superq(message), %length(%superq(message)), 1)) ne %str(%') %then %do;
        %put %str(E)RROR: Please enclose message in qoutes.;
        %return;
    %end; %end;

    %if %superq(from) ne %str() %then %do;
        %if %sysfunc(countw(%superq(from), %str( )))>1 %then %do;;
            %put %str(E)RROR: Only 1 from address allowed.;
            %return;
        %end;
    %end;

    /* Determine count of arguments */
    %local tocount cccount attachcount tonext ccnext attachnext toc ccc attachc;
    %let tocount=%sysfunc(countw(%superq(to), %str( )));
    %if %superq(cc) ne %str() %then %let cccount=%sysfunc(countw(%superq(cc), %str( )));
    %if %superq(attach) ne %str() %then %let attachcount=%sysfunc(countw(%superq(attach), %str( )));

    filename mymail email "NULL"

    %if %superq(from) ne %str() %then %do;
        from="%superq(from)"
    %end;

        to=(
    %do toc=1 %to &tocount;
        %let tonext=%scan(%superq(to), &toc, %str( ));
        "%superq(tonext)"
    %end;
        )

    %if %superq(CC) ne %str() %then %do;
        cc=(
        %do ccc=1 %to &cccount;
            %let ccnext=%scan(%superq(cc), &ccc, %str( ));
            "%superq(ccnext)"
        %end;
        )
    %end;

        subject="%superq(subject)"

    %if %superq(attach) ne %str() %then %do;
        attach=(
        %do attachc=1 %to &attachcount;
            %let attachnext=%scan(%superq(attach), &attachc, %str( ));
            "%superq(attachnext)"
        %end;
        )
    %end;
    ;

    data _null_;
        file mymail;
        put &MESSAGE;
    run;

    filename mymail clear;

%mend Email;
