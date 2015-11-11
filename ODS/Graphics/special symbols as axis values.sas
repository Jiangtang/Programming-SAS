/*
http://support.sas.com/kb/56/933.html
http://support.sas.com/kb/56/938.html

*/

proc format;
   value agefmt
   20-30 = "20 (*ESC*){unicode '2264'x} 30"
   31-40 = "31 (*ESC*){unicode '2264'x} 40"
   41-50 = "41 (*ESC*){unicode '2264'x} 50"
   51-60 = "51 (*ESC*){unicode '2264'x} 60"
   61-70 = "61 (*ESC*){unicode '2264'x} 70"
   ;
run;

proc sgplot data=sashelp.heart noautolegend;
   title1 "Cholesterol Level by Age Range";
   styleattrs datacolors=(red green purple orange cyan) backcolor=vpav wallcolor=pwh;
   vbox cholesterol / category=AgeAtStart group=AgeAtStart;
   format AgeAtStart agefmt.;
run;




/*GTL*/



proc format;
   value agefmt
   20-30 = "20 (*ESC*){unicode '2264'x} 30"
   31-40 = "31 (*ESC*){unicode '2264'x} 40"
   41-50 = "41 (*ESC*){unicode '2264'x} 50"
   51-60 = "51 (*ESC*){unicode '2264'x} 60"
   61-70 = "61 (*ESC*){unicode '2264'x} 70";
run;

proc template;
   define statgraph boxes;
   begingraph / datacolors=(red green purple orange cyan) backgroundcolor=vpav;
      entrytitle 'Cholesterol Level by Age Range';
      layout overlay / wallcolor=pwh;
         boxplot x=AgeAtStart y=cholesterol / group=AgeAtStart;
      endlayout;
   endgraph;
 end;
run;

proc sgrender data=sashelp.heart template=boxes;
   format AgeAtStart agefmt.;
run;
