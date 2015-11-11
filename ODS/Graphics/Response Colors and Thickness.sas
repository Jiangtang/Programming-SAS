/*
http://blogs.sas.com/content/graphicallyspeaking/2015/09/21/response-colors-and-thickness/
*/

%let gpath='.';
%let dpi=200;
ods html close;
ods listing style=listing gpath=&gpath image_dpi=&dpi;

/*--Bar Chart--*/
ods graphics / reset width=5in height=3in imagename='VBarResponseColor';
title 'Frequency and Mean Cholesterol by Death Cause';
proc sgplot data=sashelp.heart noborder;
  vbar deathcause / colorresponse=cholesterol colorstat=mean barwidth=0.7
                    colormodel=(green gold red) datalabel dataskin=pressed
                    baselineattrs=(thickness=0);
  xaxis display=(noticks nolabel noline) valueattrs=(size=7);
  yaxis display=(noticks nolabel noline) grid valueattrs=(size=7);
  gradlegend /  titleattrs=(size=8);
  run;

/*--Group Series Data--*/ 
data seriesResp; 
format Date Date9.;
label Resp='Response' Val='Value'; 
do i=0 to 364; 
date='01jan2009'd+i; 
if mod (i, 30) =0 then freq=1; else freq=0; 
Drug='Drug A'; Val = 16+ 3*sin(i/90+0.5) + 1*sin(3*i/90+0.7); Resp=1; output; 
Drug='Drug B'; Val = 10+ 3*sin(i/90+0.5) + 1*cos(3*i/90+0.7); Resp=2; output; 
Drug='Drug C'; Val = 10+ 3*cos(i/90+0.5) + 1*sin(3*i/90+0.7); Resp=3; output; 
end; 
run;

/*--Series Plot with Color and Size response--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='SeriesResponseColorSize';
title 'Values and Response by Treatment';
footnote j=l 'Thickness by Response';
proc sgplot data=seriesResp noborder;
  series x=date y=val / group=drug colorresponse=resp colormodel=(green gold red)
         lineattrs=(thickness=5) thickresp=resp;
  xaxis display=(noticks nolabel noline) grid valueattrs=(size=7);
  yaxis display=(noticks noline) grid valueattrs=(size=7);
  gradlegend / titleattrs=(size=8);
  run;
footnote;

/*--Vector Plot with Color and Size response--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='VectorResponseColorSize';
title 'Blood Pressure Range by Cholesterol';
footnote j=l 'Thickness by Cholesterol';
proc sgplot data=sashelp.heart(where=(ageatstart > 61)) noborder;
  vector x=cholesterol y=systolic / xorigin=cholesterol yorigin=diastolic
         colorresponse=cholesterol colormodel=(green gold red)
         lineattrs=(thickness=5) thickresp=cholesterol;
  xaxis display=(noticks  noline) grid valueattrs=(size=7);
  yaxis display=(noticks  noline) grid valueattrs=(size=7) label='Blood Pressure';
  gradlegend / titleattrs=(size=8);
  run;
footnote;
