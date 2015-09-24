/*-------------------------------------------*/
/* This example panels both individual and   */
/* bygrouped charts, with titles outside     */
/* the cells.
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

ods tagsets.htmlpanel path="." (url=none) file="gpanelall.html";
goptions dev=javaimg xpixels=480 ypixels=320;

/* Some title stuff */
title1 "Health analysis"; 
title2 "using Gchart and Gplot";
footnote1 "A footnote";
footnote2 "A second footnote";

/* Turn on automatic paneling for ALL graphs */
ods tagsets.htmlpanel event=panel(start);

    proc gchart data=sashelp.class;
        vbar age / sumvar=height pattid=midpoint;
    run;
    quit;

    proc gchart data=sashelp.class;
        hbar age / sumvar=weight pattid=midpoint;
    run;
    quit;
    
    symbol1 c=red v=plus;
    proc gplot data=sashelp.class;
        plot weight*height;
    run;
    quit;
    
    symbol1 c=blue v=circle;
    proc gplot data=sashelp.class;
        plot height*weight;
    run;
    quit;

/* Close the automatic panel */
ods tagsets.htmlpanel event=panel(finish);

title1 "A PROC PRINT Table";
proc print data=sashelp.class;
run;

title1 "A by-group";
proc gchart data=one;
    by z;
    vbar x / sumvar=y pattid=midpoint discrete;
run;
quit;

ods _all_ close;

