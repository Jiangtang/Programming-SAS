/*
http://blogs.sas.com/content/graphicallyspeaking/2015/07/15/big-data-visualization/
*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Heat Map--*/
ods graphics / reset width=4in height=3in imagename='HeatMap';
title 'Distribution of Blood Pressure';
proc sgplot data=sashelp.heart;
  heatmap x=systolic y=diastolic / colormodel=(white green yellow red)
          nxbins=40 nybins=30 name='a';
  reg x=systolic y=diastolic / nomarkers degree=2 legendlabel='Fit' lineattrs=(color=green);
  gradlegend 'a';
  keylegend / linelength=20 location=inside position=topright noborder;
run;

/*--Heat Map with Bands--*/
ods graphics / reset width=4in height=3in imagename='HeatMapCL';
title 'Distribution of Blood Pressure';
proc sgplot data=sashelp.heart;
  heatmap x=systolic y=diastolic / colormodel=(white green yellow red)
          nxbins=40 nybins=30 name='a';
  reg x=systolic y=diastolic / nomarkers degree=2 cli='Prediction' clm='95% Confidence' legendlabel='Fit' lineattrs=(color=green);
  gradlegend 'a';
  keylegend / linelength=20 location=inside 
              noborder across=1;
run;

/*--Num Heat Map with Response--*/
ods graphics / reset width=4in height=3in imagename='NumHeatMapResponse';
title 'Mean Cholesterol by Height and Weight';
proc sgplot data=sashelp.heart ;
  heatmap x=height y=weight / colormodel=(white green yellow red)
          nxbins=40 nybins=30 colorresponse=cholesterol colorstat=mean name='a';
  gradlegend 'a';
run;

/*--Discrete Heat Map with Response--*/
/*--Scatter Plot is used under the heatmap for formatting of legend values--*/
ods graphics / reset width=4in height=3in imagename='DiscreteHeatMapResponse';
title 'Mean MSRP by Type and Make';
proc sgplot data=sashelp.cars(where=(origin eq 'USA'));
  format msrp dollar12.0;
  scatter x=type y=make / colormodel=(white blue  purple red)
          colorresponse=msrp name='a';
  heatmap x=type y=make / colormodel=(white blue  purple red)
          colorresponse=msrp colorstat=mean
          outline outlineattrs=(color=white thickness=2);
  gradlegend 'a';
  xaxis display=(nolabel) valueattrs=(size=8);
  yaxis display=(nolabel) valueattrs=(size=8) discreteorder=formatted reverse;
run;





