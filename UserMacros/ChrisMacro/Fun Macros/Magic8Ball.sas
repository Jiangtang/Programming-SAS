%macro Magic8Ball / des="Ask a question, then use the macro";

    /* Temporarily turn the log off */
    %local user_mprint user_notes;
    %let user_mprint=%sysfunc(getoption(mprint));
    %let user_notes=%sysfunc(getoption(notes));
    option NOMPRINT;
    option NONOTES;
    filename junk dummy;
    proc printto log=junk; run;

    %local response;

    data Magic8Ball;
        format response $25.;
        response="As I see it, yes"; output;
        response="It is certain"; output;
        response="It is decidedly so"; output;
        response="Most likely"; output;
        response="Outlook good"; output;
        response="Signs point to yes"; output;
        response="Without a doubt"; output;
        response="Yes"; output;
        response="Yes - definitely"; output;
        response="You may rely on it"; output;
        response="Reply hazy, try again"; output;
        response="Ask again later"; output;
        response="Better not tell you now"; output;
        response="Cannot predict now"; output;
        response="Concentrate and ask again"; output;
        response="Don't count on it"; output;
        response="My reply is no"; output;
        response="My sources say no"; output;
        response="Outlook not so good"; output;
        response="Very doubtful"; output;
    run;

    data Magic8Ball;
        set Magic8Ball;
        random=RAND('UNIFORM')*1000000;
    run;

    proc sort data=Magic8Ball; by random; run;

    data Magic8Ball;
        set Magic8Ball(obs=1);
        call symput('response', response);
    run;

    dm "postmessage '&response'";

    proc sql; 
        drop table Magic8Ball; 
    quit;

    /* Turn the log back on */
    proc printto; run;
    option &user_notes;
    option &user_mprint;

%mend Magic8Ball;

/*
%Magic8Ball;
*/
