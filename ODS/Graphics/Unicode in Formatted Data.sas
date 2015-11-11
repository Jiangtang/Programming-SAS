/*
http://blogs.sas.com/content/graphicallyspeaking/2015/07/29/unicode-in-formatted-data-sas-9-40m3/
*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Regular Format--*/
proc format;
  value agegroup
    0  -< 40 = '< 40'
        40 -< 50 = '40 < 50'
        50 -< 60 = '50 < 60'
        60 -< high = '>= 60'
        ;
run;

data annoAxis;
  Function='Oval'; X1Space='WallPercent'; Y1Space='WallPercent'; Display='Outline';
  width=20; height=10; widthUnit='Percent'; X1=87.5; Y1=-5; LineColor='Red'; output;
  run;

/*--Regular Format--*/
ods graphics / reset width=5in height=3in imagename='Deaths';
title 'Counts by Age Group and Death Cause';
proc sgplot data=sashelp.heart(where=(deathcause ne 'Unknown')) sganno=annoAxis;
  format ageatdeath agegroup.;
  vbar ageatdeath / group=deathcause groupdisplay=cluster nooutline
       baselineattrs=(thickness=0) dataskin=pressed filltype=gradient;
  keylegend / location=inside across=1 title='';
  xaxis display=(nolabel noticks);
  yaxis label='Count' grid;
run;

/*--Unicode Format--*/
proc format;
  value agegroupUnicode
    0  -< 40 = '< 40'
        40 -< 50 = '40 < 50'
        50 -< 60 = '50 < 60'
        60 -< high = "(*ESC*){unicode '2265'x} 60"
        ;
run;

/*--Unicode Format--*/
ods graphics / reset width=5in height=3in imagename='DeathsUnicode';
title 'Counts by Age Group and Death Cause';
proc sgplot data=sashelp.heart(where=(deathcause ne 'Unknown')) nocycleattrs sganno=annoAxis;
  format ageatdeath agegroupUnicode.;
  vbar ageatdeath  / group=deathcause groupdisplay=cluster fillattrs=(color=white);
  vbar ageatdeath / group=deathcause groupdisplay=cluster nooutline name='a'
       baselineattrs=(thickness=0) dataskin=pressed filltype=gradient;
  keylegend 'a' / location=inside across=1 title='';
  xaxis display=(nolabel noticks);
  yaxis label='Count' grid;
run;

data annoLegend;
  Function='Oval'; X1Space='WallPercent'; Y1Space='WallPercent'; Display='Outline';
  width=15; height=8; widthUnit='Percent'; X1=93; Y1=78; LineColor='Red'; output;
  run;

/*--Unicode Format--*/
ods graphics / reset width=5in height=3in imagename='DeathsUnicode2';
title 'Counts by Death Cause and Age Group';
proc sgplot data=sashelp.heart(where=(deathcause ne 'Unknown')) nocycleattrs sganno=annoLegend;
  format ageatdeath agegroupUnicode.;
  vbar deathcause  / group=ageatdeath groupdisplay=cluster fillattrs=(color=white);
  vbar deathcause  / group=ageatdeath groupdisplay=cluster nooutline
       baselineattrs=(thickness=0) dataskin=pressed filltype=gradient name='a';
  keylegend 'a' / location=inside position=topright across=1 title='';
  xaxis display=(nolabel noticks);
  yaxis label='Count' grid;
run;


