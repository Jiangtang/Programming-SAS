
/* Here is a composite graph example */

%let panelborder=1; /* panel border widith of 1 */
goptions reset=all dev=java;
ods tagsets.htmlpanel path="." (url=none) file="composite.html" style=default;

/* Standard title/footnote stuff */
title1 "This is a graph panel title"; 
title2 "with a sub-title below it";
footnote1 "This is a panel footnote"; 
footnote2 "along with a sub-footnote";
 
/* Start a row panel, with a column panel in the first cell */
ods tagsets.htmlpanel event=row_panel(start);

/* Cell 1 */
ods tagsets.htmlpanel event=column_panel(start);

goptions xpixels=240 ypixels=240;  /* Shrink to fit good */
proc gchart data=sashelp.class;
    pie age / sumvar=height;
run;
quit;

proc gchart data=sashelp.class;
    pie age / sumvar=weight;
run;
quit;

/* Close the column panel */
ods tagsets.htmlpanel event=column_panel(finish);

/* Cell 2 */
goptions xpixels=480 ypixels=480; /* Twice the height of a pie */
proc gmap map=maps.us data=maps.us;
    id state;
    choro state;
run;
quit;

/* Cell 3 */
ods tagsets.htmlpanel event=column_panel(start);
goptions xpixels=240 ypixels=240;
proc gchart data=sashelp.class;
    pie age / sumvar=height type=mean;
run;
quit;

proc gchart data=sashelp.class;
    pie age / sumvar=weight type=mean;
run;
quit;

/* Close the column panel */
ods tagsets.htmlpanel event=column_panel(finish);
/* Close the whole panel */
ods tagsets.htmlpanel event=row_panel(finish);


/*-------------------------------------------------------------*/

/* Here is an example with graphs and a table */
/* in a composite together.                   */

title1 "This is a table example"; 
goptions xpixels=340 ypixels=335; 
proc sort data=sashelp.class out=temp;
    by sex age;
run;

/* Start a row panel, with a column panel in the first cell */
ods tagsets.htmlpanel event=row_panel(start);

/* Cell 1 */
ods tagsets.htmlpanel event=column_panel(start);
proc gchart data=temp;
    by sex;
    hbar age / discrete sumvar=weight type=mean;
run;
quit;

/* Close the column panel */
ods tagsets.htmlpanel event=column_panel(finish);

/* Cell 2 */
proc print data=temp;
run;
quit;

/* Close the whole panel */
ods tagsets.htmlpanel event=row_panel(finish);

ods _all_ close;


    



 
