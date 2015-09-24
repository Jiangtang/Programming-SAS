* http://support.sas.com/kb/36/900.html;

%let path=c:\temp;

%macro showstyle(style);

ods html path="&path"(url=none) file="&style..html"
    contents=temp(notop nobot) frame="frame.html" style=&style;
ods proclabel "Style name";

proc print data=sashelp.class contents="Styles.&style";
run;

ods html close;

%mend;

ods path work.templat(update) sashelp.tmplmst(read);

filename temp "&path\contents.html" mod;
ods html path="&path"(url=none) contents=temp(nobot);
ods html exclude stats;

ods output stats=styles(where=(type ne "Dir"));

proc template;
   list styles;
run;

proc sort data=styles;
   by path;
run;

data one;
   set styles;
   by path;
   if first.path then
      call execute('%showstyle('||path||')');
run;

data _null_;
   file temp;
   put "</body>";
   put "</html>";
run;

ods path reset;
