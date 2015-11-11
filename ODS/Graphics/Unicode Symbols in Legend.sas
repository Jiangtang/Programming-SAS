/*
http://blogs.sas.com/content/graphicallyspeaking/2015/01/19/displaying-unicode-symbols-in-legend/

*/


%let gpath='.';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Subset data--*/
data heart;
  set sashelp.heart(where=(ageAtStart ge 60) keep=ageAtStart systolic sex height weight);
  if systolic GE 160 then Status='GE160';
  else if systolic GE 140 then Status='GE140';
  else if systolic GE 120 then Status='GE120';
  else Status='LT120';
run;

/*--Restructure data into column format--*/
data heart_Cols;
  set heart;
  keep height ge160 ge140 ge120 lt120;
  label ge160='Weight';
  if status='GE160' then GE160=weight;
  else if status='GE140' then GE140=weight;
  else if status='GE120' then GE120=weight;
  else LT120=weight;
run;

/*ods html;*/
/*proc print data=heart(obs=4);*/
/*  var systolic status height weight;*/
/*run;*/
/*proc print data=heart_Cols(obs=4);*/
/*  var height ge160 ge140 ge120 lt120;*/
/*run;*/
/*ods html close;*/

/*--Use Legend Labels for including Unicode--*/
ods escapechar '~';
ods graphics / reset width=5in height=3in imagename='UnicodeinLegend_93';
title 'Blood Pressure by Weight by Height';
proc sgplot data=heart_cols;
  scatter x=height y=ge160 / legendlabel="160 ~{Unicode '2264'x} Systolic ";
  scatter x=height y=ge140 / legendlabel="140 ~{Unicode '2264'x} Systolic < 160";
  scatter x=height y=ge120 / legendlabel="120 ~{Unicode '2264'x} Systolic < 140";
  scatter x=height y=lt120 / legendlabel="Systolic < 120";
  keylegend / title='' location=inside position=topleft across=1;
  run;

/*--Align "Systolic" using nbsp '00A0'x --*/
ods escapechar '~';
ods graphics / reset width=5in height=3in imagename='UnicodeinLegend_Aligned_93';
title 'Blood Pressure by Weight by Height';
proc sgplot data=heart_cols;
  scatter x=height y=ge160 / legendlabel="160 ~{Unicode '2264'x} Systolic ";
  scatter x=height y=ge140 / legendlabel="140 ~{Unicode '2264'x} Systolic < 160";
  scatter x=height y=ge120 / legendlabel="120 ~{Unicode '2264'x} Systolic < 140";
  scatter x=height y=lt120 / legendlabel="~{Unicode '00a0'x}         Systolic < 120";
  keylegend / title='' location=inside position=topleft across=1;
  run;
