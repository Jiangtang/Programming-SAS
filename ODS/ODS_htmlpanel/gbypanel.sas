/*-------------------------------------------*/
/* This example only panels bygrouped charts */
/*-------------------------------------------*/


data one;
    input x y z;
    cards;
1 10 1 
2 20 1
3 30 1
1 40 2
2 50 2
3 60 2
1 10 3 
2 20 3
3 30 3
1 40 4
2 50 4
3 60 4
;
run;

ods tagsets.htmlpanel path="." (url=none) file="gbypanel.html";
goptions dev=javaimg xpixels=480 ypixels=320;

title1 "A by-group test";
title2 "with a second title";
footnote1 "A Footnote";
footnote2 "A Second Footnote";

proc gchart data=one;
    by z;
    vbar x / sumvar=y pattid=midpoint discrete;
run;
quit;

/* table stops the paneling */
proc print data=sashelp.class;
run;

proc gchart data=one;
    by z;
    hbar x / sumvar=y pattid=midpoint discrete;
run;
quit;

/* This graph stops the paneling */
goptions dev=javaimg xpixels=640 ypixels=480;
title1 "A Gchart Output";
footnote1 "with a footnote";
proc gchart data=sashelp.class;
    hbar age / sumvar=height;
run;
quit;

title1 "A PROC PRINT Table";
proc print data=sashelp.class;
run;

ods _all_ close;

