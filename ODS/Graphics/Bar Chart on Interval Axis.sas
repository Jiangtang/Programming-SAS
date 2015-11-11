/*
http://blogs.sas.com/content/graphicallyspeaking/2015/08/12/bar-chart-on-interval-axis-sas-9-40m3/

*/

%let gpath='.';
%let dpi=200;

ods html close;
ods listing style=listing gpath=&gpath image_dpi=&dpi;

data Sales;
  format Date date7. Sales Target dollar6.0;
  do Date='01jan14'd, '07jan14'd, '15jan14'd, '01feb14'd, '01mar14'd, '01apr14'd;
    do Region='North', 'South', 'East', 'West';
          Sales=1000*(1+2*ranuni(2));
          Target=1000*(1+1.5*ranuni(2));
          output;
        end;
  end;
run;

ods html;
proc print data=sales(obs=4);
var date region sales target;
run;
ods html close;

/*--Interval Bar--*/
ods listing style=listing;
ods graphics / reset width=5in height=3in imagename='IntervalBar';
title 'Revenues by Date';
proc sgplot data=Sales noborder cycleattrs;
  vbar date / response=sales nostatlabel dataskin=pressed;
  xaxis type=time display=(nolabel noline);
  yaxis grid display=(nolabel);
run;

/*--Interval Stacked Bar--*/
ods listing style=listing;
ods graphics / reset width=5in height=3in imagename='IntervalStackedBar';
title 'Revenues by Date and Region';
proc sgplot data=Sales noborder cycleattrs;
  vbar date / response=sales nostatlabel dataskin=pressed group=region;
  xaxis type=time display=(nolabel noline);
  yaxis grid;
  keylegend / fillheight=3pct fillaspect=golden noborder;
run;

/*--Interval Clustered Bar--*/
ods graphics / reset width=5in height=3in imagename='IntervalClusterBar';
title 'Revenues by Date and Region';
proc sgplot data=Sales noborder;
  vbar date / response=sales nostatlabel dataskin=pressed group=region 
       groupdisplay=cluster clusterwidth=0.75;
  xaxis type=time display=(nolabel noline);
  yaxis grid display=(nolabel noticks noline);
  keylegend / fillheight=1.5pct fillaspect=4.0 noborder;
run;

/*--Interval Clustered BarLine--*/
ods listing style=analysis;
ods graphics / reset attrpriority=color width=5in height=3in imagename='IntervalClusterBarLine';
title 'Revenues by Date and Region';
proc sgplot data=Sales(where=(region in ('North' 'South')))noborder;
  vbar date / response=sales nostatlabel dataskin=pressed group=region 
       groupdisplay=cluster clusterwidth=0.75 name='a';
  vline date / response=target group=region groupdisplay=cluster clusterwidth=0.75
        lineattrs=(thickness=2);
  xaxis type=time display=(nolabel noline);
  yaxis grid display=(nolabel noticks noline);
  keylegend 'a' / fillheight=1.5pct fillaspect=4.0 noborder;
run;

/*--Interval Clustered Bar Target--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='IntervalClusterBarTarget';
title 'Revenues by Date and Region';
proc sgplot data=Sales(where=(region in ('North' 'South')))noborder;
  vbar date / response=sales nostatlabel dataskin=pressed group=region 
       groupdisplay=cluster clusterwidth=0.75 name='a';
  vline date / response=target group=region groupdisplay=cluster clusterwidth=0.75
        lineattrs=(thickness=0) markers markerattrs=(symbol=circlefilled size=7);
  xaxis type=time display=(nolabel noline);
  yaxis grid display=(nolabel noticks noline) offsetmin=0;
  keylegend 'a' / fillheight=1.5pct fillaspect=4.0 noborder;
run;

/*--Interval Clustered Bar Target--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='IntervalClusterBarTarget';
title 'Revenues and Target by Date and Region';
proc sgplot data=Sales(where=(region in ('North' 'South')))noborder;
  symbolchar name=line char='2012'x / voffset=0.08;
  vbar date / response=sales nostatlabel dataskin=pressed group=region 
       groupdisplay=cluster clusterwidth=0.75 name='a';
  vline date / response=target group=region groupdisplay=cluster clusterwidth=0.75
        lineattrs=(thickness=0) markers markerattrs=(symbol=line size=20) name='b';
  xaxis type=time display=(nolabel noline);
  yaxis grid display=(nolabel noticks noline) offsetmin=0;
  keylegend 'a' / fillheight=1.5pct fillaspect=4.0 noborder;
run;

/*--Grouped Needle--*/
ods graphics / reset attrpriority=color width=5in height=3in imagename='GroupedNeedle';
title 'Revenues and Target by Date and Region';
proc sgplot data=sashelp.class noborder;
  needle x=age y=height / group=sex name='a' groupdisplay=cluster;
  xaxis type=time display=(nolabel noline);
  yaxis grid display=(nolabel noticks noline) offsetmin=0;
  keylegend 'a' / fillheight=1.5pct fillaspect=4.0 noborder;
run;






