/*
http://blogs.sas.com/content/graphicallyspeaking/2015/04/24/difference-can-be-misleading/
*/

%let gpath='.';
%let dpi=200;
ods html close;
ods listing gpath=&gpath image_dpi=&dpi;

/*--Fips data--*/
data premiums;
  format Claims Premium Difference dollar3.0;
  length label1 label2 $35;
  input Year Claims Premium;
  Difference=premium-claims;
  if year=1983 then do; 
    label1='Payments for, malpractice, claims';
        yl=1.4;
        grp='A';
  end;
  if year=1984 then do;
    label2='Malpractice, premiums';
        yl=5.8;
        grp='B';
  end;
  if year=1993 then do;
    label3='Figures adjusted, for Inflation';
        yl=5.5;
        grp='';
  end;
  datalines;
1974  .     .
1975  0.6   2.9
1976  0.5   3.8
1977  0.7   4.1
1978  0.9   3.9
1979  1.0   3.8
1980  1.2   3.7
1981  1.3   3.6
1982  1.5   3.8
1983  2.0   3.9
1984  2.05  4.0
1985  2.3   5.2
1986  2.6   7.0
1987  3.1   7.8
1988  3.2   8.0
1989  3.3   8.2
1990  3.2   7.5
1991  3.1   6.9
1992  3.7   6.7
1993  3.9   7.0
1994  4.0   7.3
1995  4.0   7.3
1996  4.1   7.0
1997  4.2   6.7
1998  4.4   6.8
1999  5.0   6.7
2000  5.3   6.7
2001  5.8   7.5
2002  6.0   8.8
2003  5.8  10.1
;
run;
/*proc print; run;*/

ods graphics / reset width=4in height=6in imagename='Premiums';
title h=20pt 'Ahead of the Curve';
footnote j=l 'Source:  A. M. Best';
proc sgplot data=premiums noborder noautolegend;
  styleattrs datasymbols=(triangleleftfilled trianglerightfilled);
  band x=year lower=premium upper=10.1 / y2axis fillattrs=(color=white);
  band x=year lower=claims upper=premium / y2axis 
       fillattrs=(color=lightgray transparency=0.7);
  series x=year y=claims / y2axis lineattrs=(thickness=3 color=darkgreen);
  series x=year y=premium / y2axis lineattrs=(thickness=3 color=olive);
  scatter x=year y=yl / y2axis group=grp markerattrs=(color=black) nomissinggroup;
  text x=year y=yl text=label1 / y2axis splitpolicy=splitalways splitchar=',' position=right
       contributeoffsets=none textattrs=(size=9);
  text x=year y=yl text=label2 / y2axis splitpolicy=splitalways splitchar=',' position=left
       contributeoffsets=none textattrs=(size=9);
  text x=year y=yl text=label3 / y2axis splitpolicy=splitalways splitchar=','
       contributeoffsets=none textattrs=(size=9 style=italic);
  xaxis minor minorcount=4 offsetmin=0 values=(1975 to 2003 by 5) min=1975 valueshint;
  y2axis display=(noticks noline) grid gridattrs=(color=gray) min=0 valueshint 
         offsetmin=0 values=(2 to 10 by 2)
         gridattrs=(pattern=dash) label='(Billions)' labelpos=top;
  inset 'Medical malpractice premiums' 'have soared in recent years,' 
        'outpacing the rise in payments' 'for malpractice claims.' / 
        position=topleft textattrs=(size=10);
  run;
title;
footnote;

ods graphics / reset width=4in height=6in imagename='PremiumsHighLow';
title h=20pt 'Ahead of the Curve';
footnote j=l 'Source:  A. M. Best';
proc sgplot data=premiums noborder noautolegend;
  styleattrs datasymbols=(triangleleftfilled trianglerightfilled);
  highlow x=year low=claims high=premium / y2axis lineattrs=(color=verylightgray);
  band x=year lower=premium upper=10.1 / y2axis fillattrs=(color=white);
  band x=year lower=claims upper=premium / y2axis 
       fillattrs=(color=lightgray transparency=0.7);
  series x=year y=claims / y2axis lineattrs=(thickness=3 color=darkgreen);
  series x=year y=premium / y2axis lineattrs=(thickness=3 color=olive);
  scatter x=year y=yl / y2axis group=grp markerattrs=(color=black) nomissinggroup;
  text x=year y=yl text=label1 / y2axis splitpolicy=splitalways splitchar=',' position=right
       contributeoffsets=none textattrs=(size=9);
  text x=year y=yl text=label2 / y2axis splitpolicy=splitalways splitchar=',' position=left
       contributeoffsets=none textattrs=(size=9);
  text x=year y=yl text=label3 / y2axis splitpolicy=splitalways splitchar=','
       contributeoffsets=none textattrs=(size=9 style=italic);
  xaxis minor minorcount=4 offsetmin=0 values=(1975 to 2003 by 5) min=1975 valueshint;
  y2axis display=(noticks noline) grid gridattrs=(color=gray) min=0 valueshint 
         offsetmin=0 values=(2 to 10 by 2)
         gridattrs=(pattern=dash) label='(Billions)' labelpos=top;
  inset 'Medical malpractice premiums' 'have soared in recent years,' 
        'outpacing the rise in payments' 'for malpractice claims.' / 
        position=topleft textattrs=(size=10);
  run;


/*--Add the difference plot data--*/
data premiums2;
  set premiums;
  if year=1998 then do;
    label4='Profit';
        yl=2.5;
        grp='A';
  end;
run;

ods listing gpath=&gpath image_dpi=&dpi;
ods graphics / reset width=4in height=6in imagename='Difference';
title h=20pt 'Ahead of the Curve';
footnote j=l 'Source:  A. M. Best';
proc sgplot data=premiums2 noborder noautolegend;
  styleattrs datasymbols=(triangleleftfilled trianglerightfilled);
  highlow x=year low=claims high=premium / y2axis lineattrs=(color=verylightgray);
  band x=year lower=premium upper=10.1 / y2axis fillattrs=(color=white);
  band x=year lower=claims upper=premium / y2axis fillattrs=(color=lightgray transparency=0.7);
  band x=year lower=0 upper=difference / y2axis fillattrs=(color=lightgreen transparency=0.7);
  series x=year y=claims / y2axis lineattrs=(thickness=3 color=darkgreen);
  series x=year y=premium / y2axis lineattrs=(thickness=3 color=olive);
  scatter x=year y=yl / y2axis group=grp markerattrs=(color=black) nomissinggroup;
  text x=year y=yl text=label1 / y2axis splitpolicy=splitalways splitchar=',' position=right
       contributeoffsets=none textattrs=(size=9);
  text x=year y=yl text=label2 / y2axis splitpolicy=splitalways splitchar=',' position=left
       contributeoffsets=none textattrs=(size=9);
  text x=year y=yl text=label3 / y2axis splitpolicy=splitalways splitchar=','
       contributeoffsets=none textattrs=(size=9 style=italic);
  text x=year y=yl text=label4 / y2axis splitpolicy=splitalways position=right
       contributeoffsets=none textattrs=(size=9 style=italic);
  xaxis minor minorcount=4 offsetmin=0 values=(1975 to 2003 by 5) min=1975 valueshint;
  y2axis display=(noticks noline) grid gridattrs=(color=gray) min=0 valueshint 
         offsetmin=0 values=(2 to 10 by 2)
         gridattrs=(pattern=dash) label='(Billions)' labelpos=top;
  inset 'Medical malpractice premiums' 'have soared in recent years,' 
        'outpacing the rise in payments' 'for malpractice claims.' / 
        position=topleft textattrs=(size=10);
  run;
title;
footnote;
