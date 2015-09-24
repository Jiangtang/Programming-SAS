/*-------------------------------------------*/
/* This example panels both individual and   */
/* bygrouped charts, with titles inside each */
/* cell. This example also shows the effect  */
/* of not filling every column in the table. */
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

%let panelcolumns = 2;
%let panelborder = 1;
%let embedded_titles=yes;

ods tagsets.htmlpanel path="." (url=none) file="gtfpanel.html";
goptions dev=javaimg xpixels=480 ypixels=320;

/* Footnote stuff */
footnote1 "A footnote";
footnote2 "A second footnote";

/* Start automatic paneling of graphs */
ods tagsets.htmlpanel event=panel(start);

    title1 "Chart 1";
    proc gchart data=sashelp.class;
        vbar age;
    run;
    quit;

    title1 "Chart 2";
    proc gchart data=sashelp.class;
        hbar age;
    run;
    quit;

    title1 "Chart 3";
    proc gchart data=sashelp.class;
        vbar age / pattid=midpoint;
    run;
    quit;

    title1 "Chart 4";
    proc gchart data=sashelp.class;
        hbar age / pattid=midpoint;
    run;
    quit;

/* Stop the paneling */
ods tagsets.htmlpanel event=panel(finish);

title1 "A PROC PRINT Table";
proc print data=one;
run;

title1 'By-group title for z=#byval(z)';
footnote1 'By-group footnote for z=#byval(z)';

proc gchart data=one;
    by z;
    vbar x / sumvar=y pattid=midpoint discrete;
run;
quit;

%let embedded_titles=no;

ods _all_ close;

