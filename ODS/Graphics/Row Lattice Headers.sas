/*
http://blogs.sas.com/content/graphicallyspeaking/2015/07/02/row-lattice-headers/
*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data heart;
  set sashelp.heart(where=(deathcause ne 'Unknown' and deathcause ne 'Other'));
run;

/*--Regular Row Lattice--*/
ods graphics / reset attrpriority=color width=4in height=4in imagename='RowLattice';
title 'Distribution of Cholesterol by Death Cause';
proc sgpanel data=heart noautolegend;
  panelby deathcause / layout=rowlattice onepanel novarname spacing=10;
  histogram cholesterol;
  density cholesterol;
  rowaxis offsetmin=0;
  colaxis max=420;
run;


/*--Row Lattice with Inset--*/
ods graphics / reset attrpriority=color width=4in height=4in imagename='RowLatticeInset';
title 'Distribution of Cholesterol by Death Cause';
proc sgpanel data=heart noautolegend;
  panelby deathcause / layout=rowlattice onepanel noheader spacing=10;
  inset deathcause / position=topleft nolabel;
  histogram cholesterol;
  density cholesterol;
  rowaxis offsetmin=0;
  colaxis max=420;
run;

/*--Row Lattice with Inset and background--*/
ods graphics / reset attrpriority=color width=4in height=4in imagename='RowLatticeInset2';
title 'Distribution of Cholesterol by Death Cause';
proc sgpanel data=heart noautolegend;
  panelby deathcause / layout=rowlattice onepanel noheader spacing=10;
  inset deathcause / position=topleft nolabel backcolor=silver;
  histogram cholesterol;
  density cholesterol;
  rowaxis offsetmin=0;
  colaxis max=420;
run;

/*--Lattice with Inset--*/
ods graphics / reset attrpriority=color width=4in height=4in imagename='LatticeInset';
title 'Distribution of Cholesterol by Death Cause';
proc sgpanel data=heart noautolegend;
  panelby  sex deathcause / layout=lattice onepanel noheader spacing=10;
  inset  deathcause sex / position=topleft nolabel;
  histogram cholesterol;
  density cholesterol;
  rowaxis offsetmin=0 offsetmax=0.15;
  colaxis max=420;
run;
