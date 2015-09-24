

* http://support.sas.com/rnd/base/ods/scratch/ods-from-sc-paper.pdf;

/* This program prints a sample report in HTML, PDF, and RTF */
/* in every style that is specified in ODS path.             */
ods listing close;
proc template;
define table vstyle;
   column libname memname style links;
   define links;
      header = ’Samples’;
      compute as ’<a href="’ || trim(style) || ’.html">HTML</a> ’ ||
                 ’<a href="’ || trim(style) || ’.pdf">PDF</a> ’ ||
                 ’<a href="’ || trim(style) || ’.rtf">RTF</a>’;
   end;
end;
run;
/* Print index of all styles. */
ods html file="index.html";
data _null_;
   set sashelp.vstyle;
   file print ods=(template=’vstyle’);
   put _ods_;
run;
ods html close;
%macro generateods();
   ods html file="&style..html" style=&style;
   ods pdf file="&style..pdf" style=&style;
   ods rtf file="&style..rtf" style=&style;
   proc contents data=sashelp.class; run;
   ods rtf close;
   ods pdf close;
   ods html close;
%mend;
/* Print a sample of each style.*/
data _null_;
   set sashelp.vstyle;
   call symput(’style’, trim(style));
   call execute(’%generateods’);
run;
ods listing;
