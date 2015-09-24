%inc "htmlpanel.tpl";

%let panelcolumns = 2;

ods tagsets.htmlpanel file="printpanel.html" options(panelcolumns='3');

/* start the panelling */

ods tagsets.htmlpanel event = panel(start);

proc print data=sashelp.class;run;
proc print data=sashelp.class;run;
proc print data=sashelp.class;run;

ods tagsets.htmlpanel event = panel(finish);
