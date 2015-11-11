  /*------------------------------------------------------------------*
   | MACRO NAME  : jitplot
   | SHORT DESC  : Produce SAS/Graph jitter plot (continuous
   |               vs. nominal)
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (03/30/2004 14:27)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Function:  Produce Gplot of continuous var(y-axis) vs a group var(x-
   |             axis) in such a way that no points are hidden.  Two types
   |             of plots may be requested as shown below:
   |
   |
   |
   |                       Left Justifed              Centered
   |                 |      .       .            |    .       .
   |                 |      ..      .            |   . .      .
   |             y   |      ...     ....      y  |   ...    .. ..
   |                 |      .       ..           |    .      . .
   |                 |      .       .            |    .       .
   |                 |                           |
   |                 |------|-------|-------     |----|-------|-----
   |                      level 1  level 2         level 1   level 2
   |                          Group                    Group
   |
   |             This type of plot is most effective when N is not large and
   |             you wish to display all of the data points.
   |
   |  Programmer:  E.  Bergstralh
   |
   |  Date:  February 9, 1993
   |
   | -----------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |         Jan 9, 1998     *added output dataset
   |         April 20, 1995  *created _wk dataset & sorted it
   |                         *deleted group levels not specifed
   |                         *deleted group levels with missing values
   |                         *specify mn_md=m, x or b for median, mean or both
   | ------------------------------------------------------------------------*
   | MACRO CALL
   |
   |               %jitplot(data=, y=, group=,
   |                        justify=l, space=1, sym=dot, ht=.1cm,
   |                        yaxis=, mn_md=n, outdata=);
   |
   | -------------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   |            data=name of input sas data set
   |
   |           group=variable name for group-var(x-axis). Macro assumes group
   |                 var has a maximum of 9 levels. Macro creates 2 linear
   |                 X-vars (gp2,gp3) scaled from 0 to 100 for plotting.
   |                 Group var levels are plotted at positions 10, 20,...,90.
   |                 Plotting positions vary by number of levels:
   |                   1=50, 2=30,70, 3=20,50,80, etc.
   |
   |               y=variable name for y-var
   |
   | ---------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   |         justify= L for left-justified plot, C for centered
   |                  N for no plot (the default)
   |
   |           space=horizontal distance between points with the same y-value.
   |                 The default value is 1, which allows up to 10 tied points
   |                 to be displayed if groups were plotted at x=10,20, etc.
   |                 Values from 0.5 to 2.0 seem to produce reasonable results.
   |
   |             sym=plotting symbol to use in the SYMBOL statement. Choices
   |                 are listed in Table 16.1 of the SAS/Graph(V6) manual
   |                 (Vol. 1, p.421).  Default is the dot symbol.
   |
   |              ht=plot symbol height to use in the SYMBOL statement.  Choices
   |                 are listed on page 410 of the SAS/Graph(V6) manual. Default
   |                 value is .3cm.
   |
   |           yaxis=vaxis, vref and vminor options from PROC GPLOT.  These
   |                 options will almost always have to be specified using the
   |                 %str(value) function as they contain special characters.
   |                 For example:
   |
   |                    yaxis=%str(vaxis=10 to 20 by 1 vref=15 vminor=1)  .
   |
   |                 Do NOT change the haxis settings.
   |
   |           mn_md=M if you want the median y-value noted on the plot.  Use
   |                 mn_md=X if you want the mean y-value and mn_md=B if you
   |                 want both the mean and the median.  Default is not to
   |                 print either statistic.
   |
   |           outdata= name of output dataset containing jittered values
   |                    default is _jitplot
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Eric              (08/29/2008 14:36)
   |
   | Changed to automatically use group variable label and automatically
   | define x-axis spacing for the plot. Added input checks and restore
   | user footnotes. Made as defaut justify=N and no plot.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | SAS graph jitter plot and output dataset used to create plot.
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | ***test example***;
   |    data one;
   |     y=2; x='';  x2=.; output; output; output;
   |     y=4; x='b'; x2=2; output; output; output;
   |     y=1; x='a'; x2=1; output; output; output;
   |     y=3; x='z'; x2=1; output; output;
   |     label x="Test group label" y="Yvar label";
   |     title"New Jitplot";
   |     %jitplot(data=one, y=y, yaxis=%str(vaxis=0 to 5 by 1),
   |              group=x, mn_md=x,outdata=xxx, justify=L);
   |
   |
   *------------------------------------------------------------------*
   | Copyright 2008 Mayo Clinic College of Medicine.
   |
   | This program is free software; you can redistribute it and/or
   | modify it under the terms of the GNU General Public License as
   | published by the Free Software Foundation; either version 2 of
   | the License, or (at your option) any later version.
   |
   | This program is distributed in the hope that it will be useful,
   | but WITHOUT ANY WARRANTY; without even the implied warranty of
   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   | General Public License for more details.
   *------------------------------------------------------------------*/
 
%macro   jitplot(data=, group=, y=, yaxis=,
                  justify=N, space=1, sym=dot, ht=.3cm,
                  mn_md=n, outdata=_jitplot);
 
    *** Input checks ***;
  %let errorflg=0;
  %if &data=  %then %do;
    %put  ERROR - Variable <DATA> not defined;
   %LET  errorflg = 1;
  %end;
  %if &group=  %then %do;
    %put  ERROR - Variable <GROUP> not defined;
   %LET  errorflg = 1;
  %end;
  %if &y= %then %do;
   %put  ERROR - Variable <Y> not defined;
   %LET  errorflg = 1;
  %end;
  %IF &errorflg=1 %THEN %DO;
     %put ERROR: Macro JITPLOT not run due to input errors;
     %go to exit;
   %end;
 
 *** assign new macro vars as local ***;
   %local c1 c2 c3 c4 c5 c6 c7 c8 c9 glevels glabel;
 
   ***** Save current footnotes -- reset later *****;
  proc sql ;
    create table work._f as select * from dictionary.titles
     where type='F';
    reset noprint;
   quit;
  ***** How many footnotes are being used? *****;
  proc sql;
   reset noprint;
   select nobs into :F from dictionary.tables
   where libname="WORK" & memname="_F";
  quit;
  ***** Store footnotes in macro variables *****;
  %LET FOOTNOTE1= ; /* Initialize at least one footnote */
  data _null_;
    set _f;
    %IF (&F>=1) %THEN %DO I=1 %TO &F;
       if number=&I then call symput("FOOTNOTE&I", trim(left(text)));
       %END;
   run;
**********************************************;
 
 
data _wk; set &data;
 keep &group &y;
 
**number of group var levels**;
proc freq data=_wk; tables &group/noprint out=_g1;
run;
proc sql;
   reset noprint;
   select nobs into :glevels from dictionary.tables
   where libname="WORK" & memname="_G1";
 quit;
 %if &glevels >9 %then %do;
     %put ERROR: Macro JITPLOT stopped: &glevels groups, must be <=9;
     %go to exit;
 %end;
 
data _g1; set _g1 end=eof;
      cat="C"|| put(_n_, $z1.);
      call symput(cat,&group);
       /*
      if eof=1 then do;
      _gplevel=_n_; call symput("glevels",put (_gplevel,best3.));
      end;
     */
run;
 
 %put cat1=&C1 cat2=&C2 cat3=&C3 cat4=&c4 cat5=&c5
     cat6=&c6 cat7=&c7 cat8=&c8 cat9=&c9
     groups=&glevels;
 
** mean & median for each group **;
proc sort data=_wk; by &group;
proc univariate data=_wk noprint; by &group; var &y;
  output out=_mnmd   mean=mn median=md;
 
**save label for group var **;
proc contents noprint data=_wk out=_label;
data _null_;set _label;
        if name="&group";
        call symput("glabel",put (label,$char30.));
run;
**number of tied yvar values within each group**;
proc freq data=_wk; tables &group*&y/noprint out=_p1;
 
** append individual data with mean/median for plotting;
data _p2; set _p1 _mnmd; by &group;
run;
 
** add Group level counter (cat) to final plotting data;
data &outdata; merge _p2 _g1 (keep=cat &group); by &group;
 
 *** figure out x variables (gp,gp2,gp3);
 _gplevel=&glevels;
 if _gplevel=1 & cat="C1" then gp=50;
 if _gplevel=2 then do;
     if cat="C1" then gp=30;
     if cat="C2" then gp=70;
 end;
 if _gplevel=3 then do;
     if cat="C1" then gp=20;
     if cat="C2" then gp=50;
     if cat="C3" then gp=80;
 end;
 if _gplevel=4 then do;
     if cat="C1" then gp=10;
     if cat="C2" then gp=30;
     if cat="C3" then gp=50;
     if cat="C4" then gp=70;
 end;
 if _gplevel=5 then do;
     if cat="C1" then gp=20;
     if cat="C2" then gp=30;
     if cat="C3" then gp=40;
     if cat="C4" then gp=50;
     if cat="C5" then gp=60;
 end;
 if _gplevel=6 then do;
     if cat="C1" then gp=20;
     if cat="C2" then gp=30;
     if cat="C3" then gp=40;
     if cat="C4" then gp=50;
     if cat="C5" then gp=60;
     if cat="C6" then gp=70;
 end;
 if _gplevel=7 then do;
     if cat="C1" then gp=20;
     if cat="C2" then gp=30;
     if cat="C3" then gp=40;
     if cat="C4" then gp=50;
     if cat="C5" then gp=60;
     if cat="C6" then gp=70;
     if cat="C7" then gp=80;
 end;
 if _gplevel=8 then do;
     if cat="C1" then gp=10;
     if cat="C2" then gp=20;
     if cat="C3" then gp=30;
     if cat="C4" then gp=40;
     if cat="C5" then gp=50;
     if cat="C6" then gp=60;
     if cat="C7" then gp=70;
     if cat="C8" then gp=80;
 end;
 if _gplevel=9 then do;
     if cat="C1" then gp=10;
     if cat="C2" then gp=20;
     if cat="C3" then gp=30;
     if cat="C4" then gp=40;
     if cat="C5" then gp=50;
     if cat="C6" then gp=60;
     if cat="C7" then gp=70;
     if cat="C8" then gp=80;
     if cat="C9" then gp=90;
 end;
 gp2=gp; **x-var for left justifed plot;
 gp3=gp; **x-var for centered plot;
  %if &glabel^=  %then %do;
 label gp2="&glabel" gp3="&glabel";
  %end;
  %else %do;
 label gp2="&group" gp3="&group";
  %end;
 
 med=(count+1)/2;
 if count ne . then do; **individual points;
  do i=1 to count;
   gp2=gp+( (i-1)*&space);
   gp3=(gp2+1)-med*&space;
   output;
  end;
 end;
 else do; **for median & mean plotting**;
  gp2=gp-2*&space;
  gp3=gp-4*&space;
  output;
 end;
run;
 
  %if &c1= %then %let c1=Missing;
 
  proc format;
      %if &glevels=1 %then %do;
    value gpf 50="&c1" other=" ";
      %end;
      %if &glevels=2 %then %do;
    value gpf 30="&c1" 70="&c2" other=" ";
     %end;
     %if  &glevels=3 %then %do;
    value gpf 20="&c1" 50="&c2" 80="&c3" other=" ";
     %end;
     %if  &glevels=4 %then %do;
    value gpf 10="&c1" 30="&C2" 50="&c3" 70="&c4" other=" ";
     %end;
     %if  &glevels=5 %then %do;
    value gpf 20="&c1" 30="&C2" 40="&c3" 50="&c4" 60="&c5" other=" ";
     %end;
     %if  &glevels=6 %then %do;
    value gpf 20="&c1" 30="&C2" 40="&c3" 50="&c4" 60="&c5" 70="&c6" other=" ";
     %end;
     %if  &glevels=7 %then %do;
    value gpf 20="&c1" 30="&C2" 40="&c3" 50="&c4" 60="&c5" 70="&c6"
        80="&c7" other=" ";
     %end;
     %if  &glevels=8 %then %do;
    value gpf 10="&c1" 20="&C2" 30="&c3" 40="&c4" 50="&c5" 60="&c6"
        70="&c7" 80="&c8" other=" ";
     %end;
     %if  &glevels=9 %then %do;
    value gpf 10="&c1" 20="&C2" 30="&c3" 40="&c4" 50="&c5" 60="&c6"
        70="&c7" 80="&c8" 90="&c9" other=" ";
     %end;
 
 symbol1 cv=black v=&sym h=&ht i=none;
 symbol2 cv=red v=X    h=&ht i=none; **mean;
 symbol3 cv=red v=PLUS h=&ht i=none; **median;
 run;
  %if %upcase(&justify)= C %then %do;  **centered plot;
proc gplot data=&outdata gout=_jit;
   plot &y*gp3=1
    %if %upcase(&mn_md)= X or %upcase(&mn_md)= B %then %do;
       mn*gp3=2
    %end;
    %if %upcase(&mn_md)= M or %upcase(&mn_md)= B %then %do;
       md*gp3=3
    %end;
   / overlay  hminor=0 &yaxis ;
  %end;
 
  %if %upcase(&justify)= L %then %do;  **left justified plot;
proc gplot data=&outdata gout=_jit;
  plot &y*gp2=1
    %if %upcase(&mn_md)= X or %upcase(&mn_md)= B %then %do;
       mn*gp2=2
    %end;
    %if %upcase(&mn_md)= M or %upcase(&mn_md)= B %then %do;
       md*gp2=3
    %end;
   / overlay  hminor=0 &yaxis ;
  %end;
 
   ** any type plot **;
  %if %upcase(&justify)= L or %upcase(&justify)= C %then %do;
     format gp2 gp3 gpf.;
    %if %upcase(&mn_md)= M %then %do;
     footnote .j=l .h=1 .c=red 'Note: + = median';
    %end;
    %if %upcase(&mn_md)= X %then %do;
     footnote .j=l .h=1 .c=red 'Note: X = mean ';
    %end;
    %if %upcase(&mn_md)= B %then %do;
     footnote .j=l .h=1 .c=red 'Note: X = mean,  + = median';
    %end;
 run; quit;
 %end;
***** Restore the previous footnotes *****;
  footnote1;
  %IF (&F>=1) %THEN %DO I=1 %TO &F;
   footnote&I "&&FOOTNOTE&I";
  %END;
 
 proc datasets nolist; delete _wk _g1  _p1 _p2 _mnmd;
 run; quit;
 %exit:
  run;
 %mend jitplot;
 
 
