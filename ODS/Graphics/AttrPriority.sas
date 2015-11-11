/*
http://blogs.sas.com/content/graphicallyspeaking/2015/06/28/attributes-priority-for-the-inquiring-mind/

*/


%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Grouped Series--*/ 
data seriesGroup; 
format Date Date9.; 
do i=0 to 364; 
  date='01jan2009'd+i; 
  val2=.;

  Drug='Drug A'; Val = 16+ 3*sin(i/90+0.5) + 1*sin(3*i/90+0.7); 
  if mod (i, 30) =0 then val2=val; 
  output;
 
  Drug='Drug B'; Val = 10+ 3*sin(i/90+0.5) + 1*cos(3*i/90+0.7);
  if mod (i, 30) =0 then val2=val; 
  output;

  Drug='Drug C'; Val = 10+ 3*cos(i/90+0.5) + 1*sin(3*i/90+0.7);
  if mod (i, 30) =0 then val2=val; 
  output; 
end; 
run;

/*--Style=Listing--*/
ods listing style=listing;
ods graphics / reset width=5in height=3in imagename='AttrPriority_Listing';
title 'Style=Listing'; 
proc sgplot data=seriesGroup;
  styleattrs datasymbols=(circlefilled trianglefilled squarefilled);
  series x=date y=val / group=drug lineattrs=(thickness=2);
  scatter x=date y=val2 / group=drug filledoutlinedmarkers markerfillattrs=(color=white); 
  keylegend / title='' location=inside position=topright across=1;
  xaxis display=(nolabel);
  yaxis display=(nolabel) integer values=(4 to 20 by 4);
  run;
title;

/*--Style=HTMLBlue--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='AttrPriority_HTMLBlue';
title 'Style=HTMLBlue'; 
proc sgplot data=seriesGroup;
  styleattrs datasymbols=(circlefilled trianglefilled squarefilled);
  series x=date y=val / group=drug lineattrs=(thickness=2);
  scatter x=date y=val2 / group=drug filledoutlinedmarkers markerfillattrs=(color=white); 
  keylegend / title='' location=inside position=topright across=1 linelength=20;
  xaxis display=(nolabel);
  yaxis display=(nolabel) integer values=(4 to 20 by 4);
  run;
title;

/*--Style=HTMLBlue AttrPriority=None--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='AttrPriority_HTMLBlue_None'
               attrpriority=none;
title 'Style=HTMLBlue (Attrpriority=None)'; 
proc sgplot data=seriesGroup;
  styleattrs datasymbols=(circlefilled trianglefilled squarefilled);
  series x=date y=val / group=drug lineattrs=(thickness=2);
  scatter x=date y=val2 / group=drug filledoutlinedmarkers markerfillattrs=(color=white); 
  keylegend / title='' location=inside position=topright across=1;
  xaxis display=(nolabel);
  yaxis display=(nolabel) integer values=(4 to 20 by 4);
  run;
title;

/*--Style=Analysis AttrPriority=Color--*/
ods listing style=analysis;
ods graphics / reset width=5in height=3in imagename='AttrPriority_Analysis_Color'
               attrpriority=Color;
title 'Style=Analysis (Attrpriority=Color)'; 
proc sgplot data=seriesGroup;
  styleattrs datasymbols=(circlefilled trianglefilled squarefilled);
  series x=date y=val / group=drug lineattrs=(thickness=2);
  scatter x=date y=val2 / group=drug filledoutlinedmarkers markerfillattrs=(color=white); 
  keylegend / title='' location=inside position=topright across=1 linelength=20;
  xaxis display=(nolabel);
  yaxis display=(nolabel) integer values=(4 to 20 by 4);
  run;
title;

/*--Style=Analysis Pattern=Solid--*/
ods listing style=analysis;
ods graphics / reset width=5in height=3in imagename='AttrPriority_Analysis_Solid';
title 'Style=Analysis'; 
proc sgplot data=seriesGroup;
  styleattrs datasymbols=(circlefilled trianglefilled squarefilled);
  series x=date y=val / group=drug lineattrs=(thickness=2 pattern=solid);
  scatter x=date y=val2 / group=drug filledoutlinedmarkers markerfillattrs=(color=white); 
  keylegend / title='' location=inside position=topright across=1 linelength=20;
  xaxis display=(nolabel);
  yaxis display=(nolabel) integer values=(4 to 20 by 4);
  run;
title;


/*--Icon for Bubble Chart with Absolute scaling--*/
/*ods listing image_dpi=100;*/
/*ods graphics / reset attrpriority=color width=2.7in height=1.8in imagename='AttrPriority_Icon';*/
/*title 'Absolute Bubble Size'; */
/*proc sgplot data=bubble noautolegend aspect=0.7;*/
/*  run;*/
/*title;*/
