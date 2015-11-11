/*
http://blogs.sas.com/content/graphicallyspeaking/2015/06/24/bubble-plots/

*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Create Bubble Data--*/
/*--Areas of min and max bubble size is computed--*/
data bubble;
  format Area  4.1 size 2.0;
  format LinArea PropArea 4.0;
  pi=constant("pi");
  input X Y Size Type $ Cat $;
  /*--Area of bubble with Size as redius--*/
  Area=size*size*pi/4;

  /*--Min and max size of bubbles on screen and areas--*/
  maxR=3*7; minR=7;
  MaxArea=maxR*maxR*pi; 
  MinArea=minR*minR*pi;
  Max=15; Min=13;

  /*--Area of bubble using linear scaling--*/
  LinArea= MinArea+(Size-Min)*(maxArea-minArea)/(Max-Min); 

  /*--Area of bubble using Proportional scaling--*/
  PropArea= Size*maxArea/max;

  LinLbl='ValueArea=' || put (area, 4.0) || '-PixelArea=' || put(LinArea, 4.1);
  PropLbl='ValueArea=' || put (area, 4.0) || '-PixelArea=' || put(PropArea, 4.1);
 
  datalines;
 20   20   14  A  X
 50   10   13  B  Y
 80   60   15  A  Z
;
run;
ods html;
proc print;run;
ods html close;

/*--Bubble Chart with Linear scaling--*/
ods graphics / reset attrpriority=color width=4in height=2.8in imagename='Bubble_Linear_SG';
title 'Linear Bubble Size - SG'; 
proc sgplot data=bubble noautolegend aspect=0.7;
  bubble x=x y=y size=size / group=type datalabel=linlbl splitchar='-' 
         dataskin=gloss nooutline;
  text x=x y=y text=size / position=center;
  xaxis min=0 max=100 offsetmin=0 offsetmax=0.1 display=(nolabel) grid;
  yaxis min=0 max=70 offsetmin=0 offsetmax=0.1 display=(nolabel) grid;
  run;
title;

/*--Bubble Chart with Proportional scaling--*/
proc template;
  define statgraph Bubble;
    begingraph;
      entrytitle 'Proportional Bubble Size - GTL'; ;
      layout overlay /   aspectratio=0.7 xaxisopts=(display=(ticks tickvalues line) griddisplay=on 
                                    linearopts=(viewmin=0 viewmax=100) offsetmin=0 offsetmax=0.1)
                             yaxisopts=(display=(ticks tickvalues line) griddisplay=on
                                    linearopts=(viewmin=0 viewmax=70) offsetmin=0 offsetmax=0.1);
            bubbleplot x=x y=y size=size/ group=type datalabel=PropLbl relativescaletype=proportional 
                   datalabelsplit=true datalabelsplitchar='-' name='a' dataskin=sheen
                   display=(fill);
            textplot x=x y=y text=size / position=center;

      endlayout;
        endgraph;
  end;
run;

/*--Bubble Chart with Proportional scaling--*/
ods graphics / reset width=4in height=2.8in imagename='Bubble_Prop_GTL';
proc sgrender data=bubble template=bubble;
run;

/*--Bubble Chart with Absolute scaling--*/
ods graphics / reset attrpriority=color width=4in height=2.8in imagename='Bubble_Abs_SG';
title 'Absolute Bubble Size - SG'; 
proc sgplot data=bubble noautolegend aspect=0.7;
  bubble x=x y=y size=size / group=type datalabel=size datalabelpos=center 
         absscale dataskin=sheen nooutline datalabelattrs=(size=10);
  xaxis min=0 max=100 offsetmin=0.05 offsetmax=0.1 display=(nolabel) grid;
  yaxis min=0 max=70 offsetmin=0.05 offsetmax=0.1 display=(nolabel) grid;
  run;
title;
