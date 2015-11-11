%let gpath='.';
%let dpi=200;
ods html close;
ods listing style=listing gpath=&gpath image_dpi=&dpi;

data TallBar;
  input X $ Y;
  datalines;
A  10
B  15
C  12
D  17
E  400
;
run;

/*
http://blogs.sas.com/content/graphicallyspeaking/2015/09/02/broken-axis-redux/
*/
/*--Bar Chart--*/
ods graphics / reset width=5in height=3in imagename='Bar';
proc sgplot data=tallbar;
  vbar x / response=y nostatlabel fillattrs=graphdata1;
  run;

/*--Bar Chart with "Full" broken axis and values--*/
ods graphics / reset width=5in height=3in imagename='BarBrokenAxisFull';
proc sgplot data=tallbar;
  vbar x / response=y nostatlabel fillattrs=graphdata2 baselineattrs=(thickness=0);
  yaxis ranges=(min-44 384-max) values=(0 to 400 by 10);
  run;

/*--Scatter data--*/
data outOfRange;
  keep x y;
  do i=1 to 100;
    x=ranuni(2); y=ranuni(2) + 0.3*x; output;
  end;
   x=0.5; y=9.1; output;
run;
/*proc print;run;*/

/*--Scatter Plot with broken axis type "Bracket"--*/
ods listing style=analysis;
ods graphics / reset width=5in height=3in imagename='ScatterBrokenAxisBracket';
proc sgplot data=outOfRange;
  styleattrs axisbreak=bracket;
  reg x=x y=y / clm markerattrs=(size=5); 
  yaxis ranges=(min-1.5 8.9-max) values=(0 to 10 by 0.2) valueshint;
  run;

/*--Scatter Plot with broken axis type "Spark" and Axis Extents--*/
ods listing style=journal;
ods graphics / reset width=5in height=3in imagename='ScatterBrokenAxisSpark';
proc sgplot data=outOfRange nowall noborder;
  styleattrs axisbreak=spark axisextent=data ;
  reg x=x y=y / clm markerattrs=(size=5); 
  yaxis ranges=(min-1.5 8.9-max) values=(0 to 10 by 0.2) valueshint;
  run;
