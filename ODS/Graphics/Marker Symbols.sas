/*http://blogs.sas.com/content/graphicallyspeaking/2015/01/14/marker-symbols/*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

data cars;
  set sashelp.cars(where=(make in ('BMW', 'Porsche') and horsepower < 400));
  keep make horsepower mpg_city;
run;
proc print;run;

/*--Scatter Plot with AttrPriority=Color--*/
ods listing style=htmlblue;
ods graphics / reset width=5in height=3in imagename='Symbols_ColorOnly';
title 'Mileage by Horsepower by Make'; 
proc sgplot data=cars;
  scatter x=horsepower y=mpg_city / group=make markerattrs=(size=9);
  keylegend / location=inside position=topright;
  yaxis grid integer;
  xaxis grid;
  run;

/*--Scatter Plot with AttrPriority=None--*/
ods listing style=htmlblue;
ods graphics / reset attrpriority=none width=5in height=3in imagename='Symbols_ColorSymbol';
title 'Mileage by Horsepower by Make'; 
proc sgplot data=cars;
  scatter x=horsepower y=mpg_city / group=make markerattrs=(size=9);
  keylegend / location=inside position=topright;
  yaxis grid integer;
  xaxis grid;
  run;

/*--Scatter Plot with Other Built-in Symbols 9.4--*/
ods listing style=htmlblue;
ods graphics / reset attrpriority=none width=5in height=3in imagename='Symbols_BuiltIn_94';
title 'Mileage by Horsepower by Make'; 
proc sgplot data=cars;
  styleattrs datasymbols=(X Y);
  scatter x=horsepower y=mpg_city / group=make markerattrs=(size=9);
  keylegend / location=inside position=topright;
  yaxis grid integer;
  xaxis grid;
  run;

/*--Scatter Plot with Other Symbols 9.4--*/
ods listing style=htmlblue;
ods graphics / reset attrpriority=none width=5in height=3in imagename='Symbols_Other_94';
title 'Mileage by Horsepower by Make'; 
proc sgplot data=cars;
  symbolchar name=Alpha char='03b1'x / scale=1.8;
  symbolchar name=Beta char='03b2'x  / scale=1.8;
  styleattrs datasymbols=(Alpha Beta);
  scatter x=horsepower y=mpg_city / group=make markerattrs=(size=9);
  keylegend / location=inside position=topright;
  yaxis grid integer;
  xaxis grid;
  run;

/*--Scatter Plot with Image Symbols 9.4--*/
ods listing style=htmlblue;
ods graphics / reset attrpriority=none width=5in height=3in imagename='Symbols_Image_94';
title 'Mileage by Horsepower by Make'; 
proc sgplot data=cars noautolegend;
  symbolimage name=BMW image="C:\Work\Images\Logos\BMWTrans.png" / scale=1;
  symbolimage name=Porsche image="C:\Work\Images\Logos\PorscheTrans.png" / scale=1;
  styleattrs datasymbols=(BMW Porsche);
  scatter x=horsepower y=mpg_city / group=make markerattrs=(size=30);
  yaxis grid integer;
  xaxis grid;
  run;

/*--Scatter Icon--*/
ods listing style=htmlblue image_dpi=100;
ods graphics / reset attrpriority=none width=2.7in height=1.8in imagename='Symbols_Icon';
title 'Mileage by Horsepower by Make'; 
proc sgplot data=cars noautolegend;
  symbolimage name=BMW image="C:\Work\Images\Logos\BMWTrans.png" / scale=1;
  symbolimage name=Porsche image="C:\Work\Images\Logos\PorscheTrans.png" / scale=1;
  styleattrs datasymbols=(BMW Porsche);
  scatter x=horsepower y=mpg_city / group=make markerattrs=(size=20);
  yaxis grid integer;
  xaxis grid;
  run;
