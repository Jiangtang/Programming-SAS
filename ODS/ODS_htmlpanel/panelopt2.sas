goptions dev=gif xpixels=480 ypixels=320;

ods tagsets.htmlpanel nogtitle file="printpanel2.html" 
                        options(panelcolumns='3'  
                                panelborder='2'   
                                embedded_titles='yes'   
                                bylabels='no');

/* start the panelling */

ods tagsets.htmlpanel event = panel(start);

title 'First proc Print';

proc print data=sashelp.class;run;

title 'Second proc Print';
proc print data=sashelp.class;run;

title 'Third proc Print';
proc print data=sashelp.class;run;


/* Stop the current Panel */
ods tagsets.htmlpanel event = panel(finish);


/* Change the panel settings */

ods tagsets.htmlpanel options(panelcolumns='2'  
                              embedded_titles='no');  

/* this bygroup get's a panel of it's own. */

title ;

proc sort data=sashelp.class out=foo;
    by age;
    
proc gchart data=foo;
    by age;
    hbar weight / sumvar=height;
run;
quit;

/* start a new, semi-automatic panel */
ods tagsets.htmlpanel event = panel(start);

title 'Fourth proc Print';
proc print data=sashelp.class;run;

title 'Fifth proc Print';
Footnote 'End of Fifth proc Print';
proc print data=sashelp.class;run;

ods tagsets.htmlpanel event = panel(finish);

ods _all_ close;
