/*

http://blogs.sas.com/content/graphicallyspeaking/2015/09/13/something-different-sas-9-40m3/
*/


%let gpath='.';
%let dpi=200;
ods html close;
ods listing style=listing gpath=&gpath image_dpi=&dpi;

data TrialProcess;
  input X Y Stage $12-50  Duration $55-75;
  datalines;
  0   0.4  
4.5   0.5  Animal and/or Laboratory Studies           About 4-1/2 years
7.0   0.6  Phase I 15-30 Patients
9.5   0.7  Phase II Fewer than 100 patients           About 8-12 years
12.0  0.8  Phase III 100s to 1000s of patients        
13.5  0.9  FDA Approval                               About .1-1/2. years
15.0  0.9  Phase IV (after approval)  
;
run;

/*--Add Status and Duration Labels and Arrows--*/
data process;
  retain xp 0;
  set trialprocess end=last;
  xs=(x+xp)/2;
  ys=y-0.3;
  yd=0;
  output;
  xp=x;
  if last then do;
  call missing (x, y, xs, ys, yd, Stage, Duration);
  y1=0; 
  x1=4.5;  x2=7.0; output;
  x1=12.0; x2=9.5; output;
  end;
run;

/*proc print;run;*/

/*--Clinical Trials Process--*/
ods graphics / reset width=5in height=3in imagename='ClinicalTrialsProcess';
proc sgplot data=TrialProcess;
  block x=x block=Stage / filltype=alternate nooutline novalues
        fillattrs=(color=cxcfd7f7) altfillattrs=(color=cxdfefe7);
  step x=x y=y / arrowheadpos=end lineattrs=(thickness=5 color=white) dataskin=matte;
  inset "Clinical Trials Process" / position=topleft;
  yaxis min=0 max=1 display=none;
  xaxis offsetmin=0.02 offsetmax=0.02 display=none;
  run;

/*--Clinical Trials Process with labels--*/
ods graphics / reset width=5in height=3in imagename='ClinicalTrialsProcessLabel';
proc sgplot data=process noautolegend;
  block x=x block=Stage / filltype=alternate nooutline novalues
        fillattrs=(color=cxcfd7f7) altfillattrs=(color=cxdfefe7);
  step x=x y=y / arrowheadpos=end lineattrs=(thickness=5 color=white) dataskin=matte;
  text x=xs y=ys text=Stage /  splitpolicy=split;
  text x=xs y=yd text=Duration / splitchar='.' splitpolicy=splitalways;
  vector x=x1 y=y1 / xorigin=x2 yorigin=y1;
  inset "Clinical Trials Process" / position=topleft; 
  yaxis min=0 max=1 display=none;
  xaxis offsetmin=0.02 offsetmax=0.02 display=none;
  run;

/*--Diagram Data--*/
data Diagram;
  length xn xl $10;
  ns=1;
  yn=10;

  /*--Nodes--*/
  do node='A', 'B', 'C', 'D', 'E';
    xn='Doctor'; yn=yn-2; output;
  end;

  yn=10;
  do node='1', '2', '3', '4', '5';
    xn='Patient'; yn=yn-2; output;
  end;

  call missing (xn, yn, node, ns);

  /*--Links--*/
  link=1; xl='Doctor';  yl=8; ls=1; output;
  link=1; xl='Patient'; yl=8; ls=1; output;
  link=2; xl='Doctor';  yl=8; ls=2; output;
  link=2; xl='Patient'; yl=6; ls=2; output;
  link=3; xl='Doctor';  yl=8; ls=3; output;
  link=3; xl='Patient'; yl=4; ls=3; output;
  link=4; xl='Doctor';  yl=8; ls=4; output;
  link=4; xl='Patient'; yl=2; ls=4; output;

  link=5; xl='Doctor';  yl=6; ls=1; output;
  link=5; xl='Patient'; yl=6; ls=1; output;
  link=6; xl='Doctor';  yl=6; ls=2; output;
  link=6; xl='Patient'; yl=4; ls=2; output;
  link=7; xl='Doctor';  yl=6; ls=3; output;
  link=7; xl='Patient'; yl=2; ls=3; output;

  link=8; xl='Doctor';  yl=4; ls=1; output;
  link=8; xl='Patient'; yl=4; ls=1; output;
  link=9; xl='Doctor';  yl=4; ls=2; output;
  link=9; xl='Patient'; yl=2; ls=2; output;
  
  link=10; xl='Doctor';  yl=2; ls=1; output;
  link=10; xl='Patient'; yl=2; ls=1; output;
  link=11; xl='Doctor';  yl=2; ls=1; output;
  link=11; xl='Patient'; yl=0; ls=1; output;

  link=12; xl='Doctor';  yl=0; ls=1; output;
  link=12; xl='Patient'; yl=0; ls=1; output;
;
run;

/*proc print;run;*/

/*--Diagram--*/
ods graphics / reset width=4in height=3in imagename='Diagram';
proc sgplot data=Diagram noautolegend nowall noborder;
  series x=xl y=yl / group=link thickresp=ls thickmaxresp=5 thickmax=5 lineattrs=graphdatadefault x2axis;
  bubble x=xn y=yn size=ns / bradiusmin=15 bradiusmax=16 datalabel=node datalabelpos=center 
         x2axis dataskin=gloss;
  x2axis display=(nolabel noticks noline) offsetmin=0.2 offsetmax=0.2;
  yaxis display=none;
  run;

/*--Diagram Spline Data--*/
data DiagramSpline;
  length xn xl $10;
  ns=1;
  yn=10;

  /*--Nodes--*/
  do node='A', 'B', 'C', 'D', 'E';
    xn='Doctor'; yn=yn-2; output;
  end;

  yn=10;
  do node='1', '2', '3', '4', '5';
    xn='Mid'; yn=.; output;
  end;

  yn=10;
  do node='1', '2', '3', '4', '5';
    xn='Patient'; yn=yn-2; output;
  end;

  call missing (xn, yn, node, ns);

  /*--Links--*/
  link=1; xl='Doctor';  yl=8; ls=1; output;
  link=1; xl='Mid';     yl=8; ls=1; output;
  link=1; xl='Patient'; yl=8; ls=1; output;
  link=2; xl='Doctor';  yl=8; ls=2; output;
  link=2; xl='Mid';     yl=8; ls=2; output;
  link=2; xl='Patient'; yl=6; ls=2; output;
  link=3; xl='Doctor';  yl=8; ls=3; output;
  link=3; xl='Mid';     yl=8; ls=3; output;
  link=3; xl='Patient'; yl=4; ls=3; output;
  link=4; xl='Doctor';  yl=8; ls=4; output;
  link=4; xl='Mid';     yl=8; ls=4; output;
  link=4; xl='Patient'; yl=2; ls=4; output;

  link=5; xl='Doctor';  yl=6; ls=1; output;
  link=5; xl='Patient'; yl=6; ls=1; output;
  link=6; xl='Doctor';  yl=6; ls=2; output;
  link=6; xl='Patient'; yl=4; ls=2; output;
  link=7; xl='Doctor';  yl=6; ls=3; output;
  link=7; xl='Patient'; yl=2; ls=3; output;

  link=8; xl='Doctor';  yl=4; ls=1; output;
  link=8; xl='Patient'; yl=4; ls=1; output;
  link=9; xl='Doctor';  yl=4; ls=2; output;
  link=9; xl='Patient'; yl=2; ls=2; output;
  
  link=10; xl='Doctor';  yl=2; ls=1; output;
  link=10; xl='Patient'; yl=2; ls=1; output;
  link=11; xl='Doctor';  yl=2; ls=1; output;
  link=11; xl='Patient'; yl=0; ls=1; output;

  link=12; xl='Doctor';  yl=0; ls=1; output;
  link=12; xl='Patient'; yl=0; ls=1; output;
;
run;


/*--Diagram Spline--*/
ods graphics / reset width=4in height=3in imagename='DiagramSpline';
proc sgplot data=DiagramSpline noautolegend nowall noborder;
  spline x=xl y=yl / group=link thickresp=ls thickmaxresp=5 thickmax=5 lineattrs=graphdatadefault x2axis;
  bubble x=xn y=yn size=ns / bradiusmin=15 bradiusmax=16 datalabel=node datalabelpos=center 
         x2axis dataskin=gloss;
  x2axis display=(nolabel noticks noline) offsetmin=0.2 offsetmax=0.2 
         values=('Doctor' 'Mid' 'Patient') valuesdisplay=('Doctor' ' ' 'Patient');
  yaxis display=none;
  run;
