%macro NapTime(time,date,test=N) / des='Set date/time to execute code';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       NapTime
        Author:     Chris Swenson
        Created:    2010-04-19

        Purpose:    Set date/time to execute the SAS code that follows the macro.
                    Useful when the user cannot schedule tasks.

        Arguments:  time  - time to wake SAS
                    data  - date to wake SAS
                    test= - whether to test the macro or not, defaulted to No

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/

    %let test=%substr(%upcase(&TEST), 1, 1);

    /* Check arguments */
    %local dateinput;
    %if "&time"="" %then %do;
        %put %str(E)RROR: Missing time argument.;
        %return;
    %end;
    %if "&date"="" %then %do;
        %let dateinput=today();
        %put NOTE: Date argument blank. Setting to today.;
    %end;
    %else %do;
        %let dateinput="&date"d;
    %end;
    %if "&TEST"="" %then %do;
        %put %str(E)RROR: No argument specified for TEST.;
        %return;
    %end;
    %if %index(*N*Y*,*&TEST*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid TEST argument. Please use Y or N.;
        %return;
    %end;

    /* Check format and set combined macro variable */
    %local datetime;
    %let datetime=;
    data _null_;
        format date date9. time time8. datetime datetime19.;
        date=&dateinput;
        time="&time"t;

        datetime=input(compress(put(date, date9.) || ':' || put(time, time8.)), datetime19.);
        call symputx('datetime', put(datetime, datetime19.));

        /* Set date again in case it is not specified */
        call symputx('date', put(date, date9.));
    run;

    /* Check if datetime macro variable was populated */
    %if "&datetime"="" %then %do;
        %put %str(E)RROR: Datetime format incorrect. Check the arguments.;
        %return;
    %end;

    /* Check that the user wants to put SAS to sleep */
    %local rusure;
    %let rusure=;
    %window rusure
        //  @20 "The code timer is set to execute the code at &time on &date.."
        //  @20 "This will put SAS to sleep. Do you wish to continue?"
        //  @20 rusure 1 attr=rev_video required=yes
        //  @20 "Enter Y for Yes or N for No, then hit ENTER to continue.";
    %display rusure delete;

    /* Put SAS to sleep if yes from the user until the specified time */
    %if %upcase(&rusure)=Y %then %do;

        data _null_;
            format datetime datetime19.;
            datetime="&datetime"dt;
        %if &test=N %then %do;
            sleep=wakeup(datetime);
        %end;
        %else %do;
            put "NOTE: Test run. Sleep statement would be: sleep=wakeup(" datetime ");";
        %end;
        run;

        %if &test=N %then %do;
            dm log 'clear';
        %end;

    %end;

%mend NapTime;
