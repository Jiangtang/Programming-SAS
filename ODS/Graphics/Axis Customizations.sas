/*
http://blogs.sas.com/content/graphicallyspeaking/2015/10/16/axis-customizations/
*/

%let gpath='.';
%let dpi=200;
ods html close;
ods listing style=listing gpath=&gpath image_dpi=&dpi;

/*--Bar Chart Default--*/
ods graphics / reset width=4.2in height=3in imagename='VBarDefault';
title 'Height by Name';
proc sgplot data=sashelp.class(where=(sex='F')) noborder;
  vbar name / response=height nostatlabel baselineattrs=(thickness=0);
  xaxis display=(nolabel);
  run;

/*--Bar Chart Stagger--*/
ods graphics / reset width=4.2in height=3in imagename='VBarStagger';
title 'Height by Name';
proc sgplot data=sashelp.class(where=(sex='F')) noborder;
  vbar name / response=height nostatlabel baselineattrs=(thickness=0);
  xaxis display=(nolabel) fitpolicy=stagger;
  run;

/*--Bar Chart Vertical--*/
ods graphics / reset width=4.2in height=3in imagename='VBarVertical';
title 'Height by Name';
proc sgplot data=sashelp.class noborder;
  vbar name / response=height nostatlabel baselineattrs=(thickness=0) fillattrs=graphdata1;
  xaxis display=(nolabel) valuesrotate=vertical;
  run;


/*--Bar Chart None--*/
ods graphics / reset width=4.2in height=3in imagename='VBarNone';
title 'Height by Name';
proc sgplot data=sashelp.class(where=(sex='F')) noborder;
  vbar name / response=height nostatlabel baselineattrs=(thickness=0)
       filltype=gradient dataskin=pressed fillattrs=graphdata2;
  xaxis display=(nolabel) fitpolicy=none;
  run;

/*--HBar Chart--*/
ods graphics / reset width=4.2in height=3in imagename='HBarDefault';
title 'Height by Name';
proc sgplot data=sashelp.class noborder;
  hbar name / response=height nostatlabel baselineattrs=(thickness=0);
  yaxis display=(nolabel);
  run;

/*--HBar Chart None--*/
ods graphics / reset width=4.2in height=3in imagename='HBarNone';
title 'Height by Name';
proc sgplot data=sashelp.class noborder;
  hbar name / response=height nostatlabel baselineattrs=(thickness=0);
  yaxis display=(nolabel) fitpolicy=none;
  run;

/*--HBar Chart HAlign--*/
ods graphics / reset width=4.2in height=3in imagename='HBarHAlignLeft';
title 'Height by Name';
proc sgplot data=sashelp.class noborder;
  hbar name / response=height nostatlabel baselineattrs=(thickness=0) 
       filltype=gradient dataskin=pressed fillattrs=graphdata3;
  yaxis display=(nolabel noline noticks) fitpolicy=none valueshalign=left;
  xaxis display=(noline);
  run;

/*--HBar Chart HAlign--*/
ods graphics / reset width=4.2in height=3in imagename='HBarHAlignCenter';
title 'Height by Name';
proc sgplot data=sashelp.class noborder;
  hbar name / response=height nostatlabel baselineattrs=(thickness=0) 
       filltype=gradient dataskin=pressed fillattrs=graphdata4;
  yaxis display=(nolabel noline noticks) fitpolicy=none valueshalign=center;
  xaxis display=(noline);
  run;

