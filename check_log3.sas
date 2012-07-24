
/*
http://sastricks.wikidot.com/base:checklog/
*/

%MACRO chklog;

  /* Zorgen dat deze code geen log genereerd */
    PROC PRINTTO log="h:\nolog.log";
    RUN;

  /* Actief log wegschrijven */
    dm log 'file "h:\saslog.log" replace';

  /* Log importeren */
    DATA work.saslog (drop=rec);
        INFILE "h:\saslog.log" TRUNCOVER;

        length logrij 5.;
        length srt $25.;
        length rec $200.;
        length melding $200.;

        INPUT 
          rec 1-200;

        *Error;
        IF upcase(substr(rec,1,5)) = 'ERROR' THEN DO;
          srt = '1. ERROR';
          melding = rec;
          logrij = _N_;
          OUTPUT; 
        END;

        *Warning;
        ELSE IF UPCASE(SUBSTR(rec,1,7)) = 'WARNING' THEN DO;
          srt = '2. WARNING';
          melding = rec;
          logrij = _N_; 
          OUTPUT;
        END;

        *Other;
        ELSE IF UPCASE(SUBSTR(rec,7,14)) = 'MISSING VALUES' OR 
                INDEX(UPCASE(rec),'UNINITIALIZED') NE 0 THEN DO;
          srt = '3. Other'; 
          melding = rec;
          logrij = _N_;
          OUTPUT;
        END;

    RUN;

    PROC SORT DATA=saslog;
      BY srt logrij;
    RUN;

    title 'Report LOG SCAN by Thierry Hennekes';
    *options pagesize=120 linesize=120;

    PROC PRINT DATA=saslog;
      BY srt;
    RUN;

    title 'The Sas System';

    PROC DATASETS LIBRARY=work NOLIST;
      DELETE saslog;
    QUIT;

  /* Log weer displayen in window */
    PROC PRINTTO log=log;
    RUN;

%MEND chklog;