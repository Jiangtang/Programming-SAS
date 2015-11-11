/*http://blogs.sas.com/content/graphicallyspeaking/2015/04/12/conditional-highlighting-2/*/

%let gpath='.';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data sales;
  Length Status $5 Ribbon $3;
  input Name $ Gender $ Sales;

  status='Bad';
  if sales > 50 then status='Good';
  if sales >= 100 then status='Great';

  Ribbon=ifc(sales > 110, 'Yes', '');

  ys=sales-10;
  if ribbon='Yes' then yr=sales-35;

  datalines;
Pat   Female  100
Bob   Male     76
Cody  Male     50
Sue   Female  120
Val   Female   70
;
run;
proc print;run;

ods graphics / reset attrpriority=none width=5in height=3in imagename='Conditional';
title 'Sales and Status by Sales Person';
proc sgplot data=sales;
  symbolimage name=bad  image="C:\Sad_Tran.png" / scale=1;
  symbolimage name=good image="C:\Happy_Tran.png" / scale=1;
  symbolimage name=great image="C:\VeryHappy_Tran.png" / scale=1;
  styleattrs datasymbols=(great good bad) datacolors=(pink cx4f5faf);

  vbarparm category=name response=sales / group=gender dataskin=gloss 
           filltype=gradient groupdisplay=cluster;
  scatter x=name y=ys / group=status markerattrs=(size=30);
  yaxis offsetmin=0 offsetmax=0 grid;
  xaxis display=(nolabel) offsetmin=0.1 offsetmax=0.1;
run;

ods graphics / reset attrpriority=none width=5in height=3in imagename='Conditional2';
title 'Sales and Status by Sales Person';
proc sgplot data=sales;
  symbolimage name=bad  image="C:\Sad_Tran.png";
  symbolimage name=good image="C:\Happy_Tran.png";
  symbolimage name=great image="C:\VeryHappy_Tran.png";
  symbolimage name=rib  image="C:\Blue_Ribbon_Tran.png" / rotate=20;
  styleattrs datasymbols=(great good bad rib) datacolors=(pink cx4f5faf);

  vbarparm category=name response=sales / fillattrs=(color=white);
  vbarparm category=name response=sales / group=gender dataskin=gloss 
           filltype=gradient groupdisplay=cluster;
  scatter x=name y=ys / group=status markerattrs=(size=30);
  scatter x=name y=yr / markerattrs=graphdata4(size=75) discreteoffset=0.25;
  yaxis offsetmin=0 offsetmax=0 grid;
  xaxis display=(nolabel) offsetmin=0.1 offsetmax=0.1;
run;
