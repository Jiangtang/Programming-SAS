/*
http://blogs.sas.com/content/graphicallyspeaking/2015/08/06/customize-legend-entries-sas-9-40m3/
*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Unicode Format--*/
proc format;
  value agegroupUnicode
    0  -< 40 = '< 40'
        40 -< 50 = '40 < 50'
        50 -< 60 = '50 < 60'
        60 - high = "(*ESC*){unicode '2265'x} 60"
        ;
run;

/*--Legend default--*/
ods graphics / reset width=5in height=3in imagename='LegendDefault';
title 'MSRP by Horsepower';
proc sgplot data=sashelp.cars(where=(type eq 'Sedan'));
  styleattrs axisextent=data;
  reg x=horsepower y=msrp / cli clm degree=2;
run;

/*--Legend Line Length--*/
ods graphics / reset width=5in height=3in imagename='LegendLine';
title 'MSRP by Horsepower';
proc sgplot data=sashelp.cars(where=(type eq 'Sedan'));
  styleattrs axisextent=data;
  reg x=horsepower y=msrp / cli clm degree=2;
  keylegend / linelength=32;
run;

/*--Legend Line Length and Swatch--*/
ods graphics / reset width=5in height=3in imagename='LegendLineScale';
title 'MSRP by Horsepower';
proc sgplot data=sashelp.cars(where=(type eq 'Sedan'));
  styleattrs axisextent=data;
  reg x=horsepower y=msrp / cli clm degree=2;
  keylegend / linelength=32 scale=1.2;
run;

/*--Legend Line Length and Swatch--*/
ods graphics / reset width=5in height=3in imagename='LegendLineAspect';
title 'MSRP by Horsepower';
proc sgplot data=sashelp.cars(where=(type eq 'Sedan'));
  styleattrs axisextent=data;
  reg x=horsepower y=msrp / cli clm degree=2;
  keylegend / linelength=32 fillheight=2.5pct fillaspect=golden;
run;

/*--Legend Swatch--*/
ods graphics / reset width=5in height=3in imagename='DeathsUnicode';
title 'Counts by Death Cause and Age Group';
proc sgplot data=sashelp.heart(where=(deathcause ne 'Unknown')) nocycleattrs noborder;
  format ageatdeath agegroupUnicode.;
  vbar ageatdeath  / group=deathcause groupdisplay=cluster fillattrs=(color=white);
  vbar ageatdeath  / group=deathcause groupdisplay=cluster nooutline
       baselineattrs=(thickness=0) dataskin=pressed filltype=gradient name='a';
  keylegend 'a' / location=inside across=1 title='' fillheight=2.5pct fillaspect=2.5 opaque;
  xaxis display=(nolabel noline);
  yaxis label='Count' grid display=(noline noticks);
run;




