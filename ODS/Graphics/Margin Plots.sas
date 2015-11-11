/*

http://blogs.sas.com/content/graphicallyspeaking/2015/02/16/margin-plots/
*/

%let gpath='';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data heart_Box;
  label chol='Cholesterol';
  set sashelp.heart(keep=cholesterol deathcause);
  chol=.;
  if deathcause in ('Cancer', 'Coronary Heart Disease') and cholesterol < 300 and cholesterol > 200 and
     ranuni(2) < 0.7 then do;
    cholesterol=.;
        chol=10*ranuni(2);
  end;
run;

/*--Box plot with missing data--*/
ods graphics / reset antialiasmax=5300 width=5in height=3in imagename='Box_Missing';
title 'Cholesterol by Death Cause';
proc sgplot data=heart_Box noautolegend;
  vbox cholesterol / category=deathcause extreme;
  scatter x=deathcause y=chol / markerattrs=graphdata1(symbol=circlefilled) 
          transparency=0.5  name='s' jitter jitterwidth=0.5 legendlabel='Missing Data';
  keylegend 's' / location=inside position=topleft;
  xaxis display=(noticks nolabel);
  yaxis values=(100 to 500 by 100) min=0 valueshint;
run;

/*--Create data set with some missing values--*/
data heart_2D;
  label systBox='Systolic' cholA='Cholesterol';
  label cholBox='Cholesterol' systA='Systolic';
  length SystGrp $12 CholGrp $12;
  set sashelp.heart(keep=cholesterol systolic);

  chol=cholesterol; syst=systolic;
  systBox=systolic; cholBox=cholesterol;
  cholA=0; SystGrp='All Data';  
  systA=0; CholGrp='All Data';

  if ranuni(2) < 0.5 and systolic < 200 and systolic > 140 then do; 
     cholA=30; syst=.; SystGrp='Missing Data'; 
  end;

  if ranuni(2) < 0.5 and Cholesterol < 300 and Cholesterol > 200 then do; 
     systA=30; chol=.; cholGrp='Missing Data'; 
  end;

  systBox=ifn((cholA=30 and syst), ., systolic);
  cholBox=ifn((systA=30 and chol), ., Cholesterol);

run;

/*proc print;*/
/*var cholesterol CholA Systolic Syst SystBox Grp;*/
/*run;*/

/*--Systolic by Cholesterol with Box for Missing Cholesterol--*/
options debug=sassgplo;
ods graphics / reset antialiasmax=5300 width=5in height=3in imagename='Margin_Systolic_Box';
proc sgplot data=heart_2D noautolegend;
  scatter x=chol y=syst / name='s' markerattrs=graphdata1  legendlabel='Non Missing Data'
          markerattrs=graphdata1(symbol=circlefilled) transparency=0.7;
  vbox systBox / category=cholA extreme group=systgrp fill nooutliers name='b' boxwidth=1;
  keylegend 's' 'b';
  xaxis min=0 values=(100 to 500 by 100) valueshint grid label='Cholesterol';
  yaxis min=0 values=( 50 to 300 by 50) valueshint grid label='Systolic';
run;

/*--Systolic by Cholesterol with Markers for Missing Cholesterol--*/
ods graphics / reset antialiasmax=5300 width=5in height=3in imagename='Margin_Systolic_Scat';
proc sgplot data=heart_2D noautolegend;
  scatter x=chol y=syst / name='n' markerattrs=graphdata1  legendlabel='Non Missing Data'
          markerattrs=graphdata1(symbol=circlefilled) transparency=0.9;
  scatter y=systBox x=cholA / group=systgrp name='s' markerattrs=(symbol=circlefilled) 
          transparency=0.9 jitter;
  keylegend 'n' 's';
  xaxis min=0 values=(100 to 500 by 100) valueshint grid label='Cholesterol';
  yaxis min=0 values=( 50 to 300 by 50) valueshint grid label='Systolic';
run;

/*--Systolic by Cholesterol with Missing Systolic--*/
ods graphics / reset antialiasmax=5300 width=5in height=3in imagename='Margin_Cholesterol_Box';
proc sgplot data=heart_2D noautolegend;
/*  format systA misdata.;*/
  scatter x=chol y=syst / name='s' markerattrs=graphdata1  legendlabel='Non Missing Data'
          markerattrs=graphdata1(symbol=circlefilled) transparency=0.7;
  hbox cholBox / category=systA extreme group=cholgrp  fill nooutliers name='b' boxwidth=1;
  keylegend 's' 'b';
  xaxis min=0 grid;
  xaxis min=0 values=(100 to 500 by 100) valueshint grid label='Cholesterol';
  yaxis min=0 values=(50 to 300 by 50) valueshint grid reverse label='Systolic';
run;

/*--Systolic by Cholesterol with Markers for Missing Cholesterol--*/
ods graphics / reset antialiasmax=5300 width=5in height=3in imagename='Margin_Cholesterol_Scat';
proc sgplot data=heart_2D noautolegend;
  scatter x=chol y=syst / name='n' markerattrs=graphdata1  legendlabel='Non Missing Data'
          markerattrs=graphdata1(symbol=circlefilled) transparency=0.9;
  scatter x=cholBox y=systA / group=cholgrp name='s' markerattrs=(symbol=circlefilled) 
          transparency=0.9 jitter;
  keylegend 'n' 's';
  xaxis min=0 values=(100 to 500 by 100) valueshint grid label='Cholesterol';
  yaxis min=0 values=(50 to 300 by 50) valueshint grid label='Systolic';
run;


proc template;
  define statgraph Margin_Box;
    begingraph;
      entrytitle 'Systolic by Cholesterol';
      layout overlay / xaxisopts=(label='Cholesterol' linearopts=(viewmin=0 tickvaluelist=(100 200 300 400 500)))
                       yaxisopts=(abel='Systolic' linearopts=(viewmin=0 tickvaluelist=(50 100 150 200 250 300)));
            scatterplot x=chol y=syst / name='s' legendlabel='Non Missing Data' 
                markerattrs=graphdata1(symbol=circlefilled) datatransparency=0.5;
                boxplot x=cholA y=systbox / intervalboxwidth=10 group=systgrp extreme=true 
                display=(fill mean median) name='b1';
                boxplot x=systA y=cholbox / intervalboxwidth=10 orient=horizontal group=cholgrp extreme=true 
                display=(fill mean median) name='b2';
        discretelegend 's' 'b1';
          endlayout;
        endgraph;
  end;
run;

ods graphics / reset width=5in height=3in imagename='Margin_2D';
proc sgrender data=heart_2D template=Margin_Box;
run;
