/*

http://blogs.sas.com/content/graphicallyspeaking/2015/01/31/cancer-deaths-averted/
*/

%let gpath='';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Create Data Set--*/
data mortality;
  input Year Actual Projected;
  label actual='Number of Deaths' projected='Number of Deaths';
  Diff=ifn (projected, projected-actual, 0);
  Zero=0;
  datalines;
1975  200000 .
1980  225000 .
1985  245000 .
1990  270000 .
1991  274000 .
1992  280000 280000
1993  280000 285000
1994  281000 290000
1995  283000 295000
1996  283000 300000 
1997  283000 305000 
1998  282000 311000 
1999  282000 317500 
2000  282000 324500
2001  283000 332000
2002  285000 339000
2003  285000 346500
2004  286000 354000 
2005  287000 363000
2006  289000 372000
2007  291000 381500
2008  292000 391000
2009  294000 400000 
2010  297000 410000 
;
run;

/*--Count deaths averted and create label--*/
data mortality2;
  set mortality end=last;
  retain total 0;
  total+diff;
  output;
  if last then do;
    call missing (actual, projected, diff);
        xlbl=2005; ylbl=30000; label=put(total, comma10.) || " Deaths Averted"; output;
    call symput("Total", total);
  end;
run;
proc print;run;

/*--Actual and Projected with difference--*/
ods listing style=listing;
ods graphics / reset width=4in height=5in imagename='Mortality_Diff';
title 'Cancer Deaths';
proc sgplot data=mortality nocycleattrs nowall noborder;
  styleattrs datalinepatterns=(solid);
  highlow x=year low=actual high=projected / type=line lineattrs=graphoutlines;
  series x=year y=projected / lineattrs=graphdata2(thickness=3) smoothconnect 
         name='b' legendlabel='Projected';
  series x=year y=actual / lineattrs=graphdata1(thickness=3) name='a' legendlabel='Actual';
  keylegend 'a' 'b' / location=inside position=topleft across=1 linelength=20;
  xaxis values=(1975 to 2010 by 5) grid;
  yaxis values=(0 to  450000 by 50000) grid;
  run;

/*--Actual and Projected with difference plot--*/
ods listing style=listing;
ods graphics / reset width=4in height=5in noscale imagename='Mortality_Averted_Label';
title 'Cancer Deaths';
proc sgplot data=mortality2 nocycleattrs nowall noborder;
  styleattrs datalinepatterns=(solid);
  highlow x=year low=actual high=projected / type=line lineattrs=graphoutlines;
  series x=year y=projected / lineattrs=graphdata2(thickness=3) smoothconnect 
         name='b' legendlabel='Projected';
  series x=year y=actual / lineattrs=graphdata1(thickness=3) name='a' legendlabel='Actual';
  band x=year upper=diff lower=zero / fillattrs=graphdata3(transparency=0.5)
       name='d' legendlabel='Deaths Averted';
  series x=year y=diff  / lineattrs=graphdata3(thickness=3);
  text x=xlbl y=ylbl text=label / textattrs=(size=7) splitpolicy=splitalways
       contributeoffsets=none;
  keylegend 'a' 'b' 'd' / location=inside position=topleft across=1 linelength=20 opaque;
  xaxis values=(1975 to 2010 by 5) grid;
  yaxis values=(0 to  450000 by 50000) grid;
  run;

