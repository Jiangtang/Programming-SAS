%macro Ghost / des="SAS Ghost";

    %let opmprint=%sysfunc(getoption(mprint));
    options nomprint;

    %put %str(E)RROR- ;

    %do i=1 %to 6;
        %put %str(E)RROR- run;
    %end;

    %put %str(E)RROR- ;

    %do i=1 %to 2;
        %put %str(E)RROR- N.o... e.s.c.a.p.e...!;
    %end;

    %put %str(E)RROR- ;

    %do i=1 %to 3;
        %put %str(E)RROR- You can%str(%')t escape... Nowhere to run... Nowhere to hide...;
    %end;

    %put %str(E)RROR- ;

    %do i=1 %to 6;
        %put %str(E)RROR- run;
    %end;

    %put %str(E)RROR- ;
    %put %str(E)RROR- The SAS Ghost is coming!;
    %put %str(E)RROR- ;

    options &opmprint;

%mend Ghost;
