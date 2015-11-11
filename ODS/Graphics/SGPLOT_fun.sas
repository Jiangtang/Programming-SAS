/*
http://blogs.sas.com/content/sgf/2015/10/16/proc-sgplot-it-isnt-just-for-plots-anymore/
*/


data blocks;
  input x y letter $ xcen ycen;
  datalines;
10 10 B 15 15
10 20 B 15 15
20 20 B 15 15
20 10 B 15 15
16 20.5 A 21 25.5
26 20.5 A 21 25.5
26 30.5 A 21 25.5
16 30.5 A 21 25.5
22 10 C 27 15
32 10 C 27 15
32 20 C 27 15
22 20 C 27 15
;
run;

proc sgplot data=blocks noautolegend noborder;
  polygon x=x y=y id=letter / outline lineattrs=(thickness=6px )
            fill  dataskin=matte FILLATTRS=(color=cxEDE3BB) group=letter;
  scatter x=xcen y=ycen / markerchar=letter markercharattrs=(size=80)
group=letter; 
  yaxis display=none;
  xaxis display=none;
run;




data board;
  input x y part $;
  datalines;
9.5 9.5 frame
9.5 40.5 frame
50.5 40.5 frame
50.5 9.5 frame
10 10 board
10 40 board
50 40 board
50 10 board
15 10.2 chalk
15 10.75 chalk
18 10.75 chalk
18 10.2 chalk
30 10.2 eraser
30 11.5 eraser
35 11.5 eraser
35 10.2 eraser
;
run;


data sganno;
  function='text';
  x1=50; y1=50;
  drawspace='wallpercent';
  label='1 + 2 = 3';
  textcolor='white';
  width=100;
  anchor='center';
  textweight='bold';
  textfont='Albany AMT';
  textsize=50;
  transparency=0.15;
run;


data attrmap;
   id='board';
   input value $ fillcolor $;
   datalines;
frame cxBFA40B
board delg
chalk white
eraser black
;
run;


proc sgplot data=board sganno=sganno dattrmap=attrmap
      noautolegend noborder nosubpixel;
  polygon x=x y=y id=id / group=id fill outline dataskin=matte
      attrid=board;
  xaxis display=none;
  yaxis display=none;
run;




data school;
  input x y part $;
  x1=44.25; y1=20;
  datalines;
40 10 building
40 60 building
45 75 building
50 60 building
50 10 building
44 10 door
44 35 door
46 35 door
46 10 door
45 75 roof
40 60 roof
39 59 roof
45 78 roof
51 59 roof
50 60 roof
41 30 windowl
41 50 windowl
43 50 windowl
43 30 windowl
47 30 windowr
47 50 windowr
49 50 windowr
49 30 windowr
;
run;
 
data attrmap;
  id='school';
  input value $ fillcolor $;
  datalines;
building cxF52707
door cxc4a854
roof black
windowl white
windowr white
;
run;
 
data panes;
  drawspace='datavalue';
  function='line';
  linecolor='black'; linethickness=5;
  x1=41; y1=40; x2=43; y2=40; output;
  x1=42; y1=50; x2=42; y2=30; output;
  x1=47; y1=40; x2=49; y2=40; output;
  x1=48; y1=50; x2=48; y2=30; output;
  function='text'; width=25;
  x1=45; y1=38; label='SCHOOL';
  textcolor='black'; textsize=20; textweight='bold';
  output;
run;
 
proc sgplot data=school dattrmap=attrmap sganno=panes noborder noautolegend;
  polygon x=x y=y id=part / outline lineattrs=(thickness=4px color=black )
     fill  dataskin=matte group=part attrid=school;
  scatter x=x1 y=y1 / markerattrs=(color=black symbol=circlefilled);
  xaxis display=none;
  yaxis display=none;
run;
