%macro Time(period,note,log=N,out=Log_time) / des='Insert current time';

    /********************************************************************************
      BEGIN MACRO HEADER
     ********************************************************************************

        Name:       Time
        Author:     Chris Swenson
        Created:    2010-09-16

        Purpose:    Insert and evaluate time variables

        Arguments:  period - Period, either B (Begin), M (Midpoint), or E (End)
                    note   - Note to output with period time
                    log=   - Y/N flag to indicate whether to maintain a log of the
                             periods and messages
                    out=   - name of log output data set, defaults to Log_time

        Revisions
        ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
        Date        Author  Comments
        ¯¯¯¯¯¯¯¯¯¯  ¯¯¯¯¯¯  ¯¯¯¯¯¯¯¯

        YYYY-MM-DD  III     Please use this format and insert new entries above

     ********************************************************************************
      END MACRO HEADER
     ********************************************************************************/


    /********************************************************************************
       Settings
     ********************************************************************************/

    /* Set to upper case */
    %if "&PERIOD" ne "" %then %let period=%substr(%upcase(&period), 1, 1);
    %let log=%substr(%upcase(&log), 1, 1);

    /* Check arguments */
    %if %index(*B*E*M*,*&PERIOD*)=0 %then %do;
        %put %str(E)RROR: %str(I)nvalid period specified. Please use B (Begin), M (Midpoint), or E (End).;
        %return;
    %end;
    %if "&log" ne "" %then %do;
        %if %index(*N*Y*,*&LOG*)=0 %then %do;
            %put %str(E)RROR: %str(I)nvalid log argument specified. Please use Y or N.;
            %return;
        %end;
    %end;

    /* Check for prior midpoint and retain */
    %local prior_mid;
    %if &period=M and %symexist(mid_datetime) %then %let prior_mid=&mid_datetime;

    /* Set the period argument to the expanded name */
    %if %upcase(&period)=B %then %do;
        %let period=Beg;
        %let period_long=Beginning;
    %end;
    %else %if %upcase(&period)=M %then %do;
        %let period=Mid;
        %let period_long=Mid Point;
    %end;
    %else %if %upcase(&period)=E %then %do;
        %let period=End;
        %let period_long=End;
    %end;

    /* Add "at" to note argument */
    %if "&note" ne "" %then %let dash=-;
    %else %let dash=;

    /* Manage scope */
    %global &period._datetime;


    /********************************************************************************
       Set Specified Period
     ********************************************************************************/

    /* Set the time and date macro variables and output to the log */
    %let &period._datetime=%sysfunc(datetime(), datetime20.);

    /*  Output note */
    %local time;
    %let time=NOTE: &period_long Time: &&&period._datetime &dash &note;


    /********************************************************************************
       Calculate Differences
     ********************************************************************************/

    %local flag_s flag_m flag_e dif_s dif_m;

    %macro TimeCalc(datetime1,datetime2,msgname) / des="";

        %if "&datetime1"="" %then %do;
            %put %str(E)RROR: ;
            %return;
        %end;
        %if "&datetime2"="" %then %do;
            %put %str(E)RROR: ;
            %return;
        %end;
        %if "&msgname"="" %then %do;
            %put NOTE: No message name specified. Defaulting to 'TimeDiff'.;
            %let msgname=TimeDiff;
        %end;

        %global &msgname;

        /* Calculate difference */
        %local calc dys hrs min sec;
        %let calc=%eval(%sysfunc(inputn(&datetime2, datetime20.))-%sysfunc(inputn(&datetime1, datetime20.)));

        /* Split differences */
        %let dys=%eval(&calc/86400);
        %let calc=%eval(&calc-(&dys*86400));
        %let hrs=%eval(&calc/3600);
        %let calc=%eval(&calc-(&hrs*3600));
        %let min=%eval(&calc/60);
        %let calc=%eval(&calc-(&min*60));
        %let sec=&calc;

        /* Set note */
        %let &msgname=&dys days, &hrs hours, &min minutes, and &sec seconds;

    %mend TimeCalc;

    %if &period=Mid %then %do;

        %if "&prior_mid" ne "" %then %do;
            %TimeCalc(&prior_mid, &mid_datetime);
            %let dif_m=NOTE: &timediff since the last mid point.;
            %let flag_m=1;
        %end;

        %if %symexist(beg_datetime) %then %do;
            %TimeCalc(&beg_datetime, &mid_datetime);
            %let dif_s=NOTE: &timediff since the beginning.;
            %let flag_s=1;
        %end;

        %symdel timediff;

    %end;

    %else %if &period=End %then %do;

        %if %symexist(mid_datetime) %then %do;
            %TimeCalc(&mid_datetime, &end_datetime);
            %let dif_m=NOTE: &timediff since the last mid point.;
            %let flag_m=1;
        %end;

        %if %symexist(beg_datetime) %then %do;
            %TimeCalc(&beg_datetime, &end_datetime);
            %let dif_s=NOTE: &timediff since the beginning.;
            %let flag_s=1;
        %end;

        %symdel timediff;

    %end;


    /********************************************************************************
       Output Log
     ********************************************************************************/
    %if &log=Y %then %do;

        data _period_;
            format Datetime datetime20. Type $10. Note $100.;
            Datetime="&&&period._datetime"dt;
            Type="&period_long";
            Note="&note";
        run;

        /* Append to master */
        proc append base=&out data=_period_;
        run;

        /* Drop temporary table */
        proc sql;
            drop table _period_;
        quit;

    %end;

    %put ;
    %if &flag_m=1 %then %put &dif_m;
    %if &flag_s=1 %then %put &dif_s;
    %put &time;
    %put ;

%mend Time;
