%inc "startpage.tpl";

options obs=1;

/* start it off with startpage=no. */
ods tagsets.startpage alias="no" file="startpage.html";
ods tagsets.short_map file="startpage.xml";

footnote "my footnote";

proc print data=sashelp.class;
run;

proc print data=sashelp.class;
run;

ods tagsets.startpage event=startpage(text="yes");

proc print data=sashelp.class;
run;

proc print data=sashelp.class;
run;

/* set it back to the default as defined by alias */
ods tagsets.startpage event=startpage;

proc print data=sashelp.class;
run;

proc print data=sashelp.class;
run;



ods _all_ close;


