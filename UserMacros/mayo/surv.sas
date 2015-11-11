  /*------------------------------------------------------------------*
   | MACRO NAME  : surv
   | SHORT DESC  : General survival statistics, K-M estimates,
   |               log-rank test
   *------------------------------------------------------------------*
   | CREATED BY  : Offord, Jan                   (04/13/2004  9:34)
   |             : Harrell, Frank
   |             : Helms, Mike
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This macro will calculate the general survival statistics (p(t),
   | standard error, confidience limits, and median survival time. It
   | will also do the k-sample logrank and plotting upon request.
   |
   | For  "expected" or "normal"  survival calculations refer
   | to %SURVEXP.
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Christianson, Teresa          (10/17/2005 13:43)
   |
   | Clarify documentation regarding Confidence Intervals.
   *------------------------------------------------------------------*
   | MODIFIED BY : Christianson, Teresa          (10/18/2005 17:03)
   |
   | In version 9, will fail if all titles are null due to %Eval of .
   | Minor modification to allow for no titles.
   *------------------------------------------------------------------*
   | MODIFIED BY : Christianson, Teresa          (02/09/2006 13:14)
   |
   | Missing log rank p-values (due to only 1 class level or no events
   | in both classes) currently show up as PVALUE < .001 on the plots.
   | Changing so they are PVALUE = NA .  NOTE: macro variables that are
   | missing are stored differently in various versions of SAS.  Some
   | are stored as . and others as   (a blank).
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :
   | MVS SAS v8    :   YES
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %surv    (
   |            time= ,
   |            event= ,
   |            cen_vl=0,
   |            class= ,
   |            by= ,
   |            out=_survout,
   |            outsum=_survsum,
   |            data=_LAST_,
   |            printop=1,
   |            points= ,
   |            cl=3,
   |            alpha=0.05,
   |            logrank=1,
   |            medtype=1,
   |            plottype=1,
   |            plotop=1,
   |            scale=1,
   |            maxtime= ,
   |            xdivisor= ,
   |            laserprt= ,
   |            pvals=Y
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable containing time to event or last follow-up
   |             in any units
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Event variable as a numeric two-valued variable, (0,1),
   |             (1,2) etc.  The event value must be 1 larger than
   |             the censoring value.
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : cen_vl
   | Default   : 0
   | Type      : Number (Single)
   | Purpose   : Censoring value for the EVENT variable as 0,1 etc.
   |             Event = Cen_vl + 1.  (Default is 0)
   |
   | Name      : class
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : List of classification variables.  They may be either
   |             character or numeric.  Note - Any observations in the
   |             input dataset with  missing CLASS data, are not included
   |             in the results.  Using multiple class variables will
   |             cause a problem when plotting.
   |
   | Name      : by
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : List of "by" variables.  They may be either character or numeric.
   |
   | Name      : out
   | Default   : _survout
   | Type      : Dataset Name
   | Purpose   : Output dataset name
   |
   | Name      : outsum
   | Default   : _survsum
   | Type      : Dataset Name
   | Purpose   : Output summary dataset name
   |
   | Name      : data
   | Default   : _LAST_
   | Type      : Dataset Name
   | Purpose   : Input dataset name (Default is the last dataset created)
   |
   | Name      : printop
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : printing options (Default is 1):
   |             0 = print nothing
   |             1 = print summary table only
   |             2 = print one line per event
   |             3 = print one line per event and/or censor
   |             4 = print one line for each of a series of time points,
   |             as months, half-years, or years (see POINTS).
   |             5 = print one line per event and/or defined time points.
   |             6 = print one line per event and/or censor and/or time
   |             point.
   |
   | Name      : points
   | Default   :
   | Type      : Text
   | Purpose   : Specific time points at which survival statistics are
   |             needed, as months, half-years, years.  These points are
   |             specified by dividing time into intervals as:
   |             '0 to 36500 by 365'.
   |             The endpoint of each interval will be the time point to
   |             be reported.  If you have comas within your statement,
   |             enclose the entire parameter in quotes, as:
   |             '0 to 360 by 30, 0 to 3650 by 182.5'
   |             You may also specify specific points as well as
   |             groups of points as:
   |             '1,5,10,15,0 to 36500 by 182.5'
   |
   | Name      : cl
   | Default   : 3
   | Type      : Number (Single)
   | Purpose   : Type of confidence limits (Default is 3, 1 and 2 are not recommended)
   |             1 = Greenwood (simple)
   |             2 = Greenwood with modified lower limit
   |             3 = log-e transformation (log)
   |             4 = log-e transformation with modified lower limit
   |             5 = log(-log-e) transformation (log(-log))
   |             6 = log(log-e) transformation with modified lower limit
   |             7 = logit transformation (logit)
   |             8  =logit transformation with modified lowere limit
   |
   | Name      : alpha
   | Default   : 0.05
   | Type      : Number (Single)
   | Purpose   : Type I error rate for confidence limits
   |
   | Name      : logrank
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Option to compute the logrank k-sample test statistics
   |             for the groups defined by the variable CLASS.  Separate
   |             tests will be done for BY variable groupings.
   |             (Default is 1)
   |             1 = do not calculate
   |             2 = calculate
   |
   | Name      : medtype
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Type of median if there are several time points
   |             having probability=.5  (Default is 1)
   |             1 = use the midpoint between the times as the median
   |             2 = use the first time value as the median
   |
   | Name      : plottype
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Where to plot the graph(s) (Default is 1)
   |             1 = no plot
   |             2 = greenbar printer plot
   |             3 = graphics plot on unix laser printer
   |             4 = plot goes to graphics window
   |             (interactive processing)
   |
   | Name      : plotop
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : What to plot on the y-axis (Default is 1)
   |             1 = plot pt
   |             2 = plot 1-pt or pe
   |
   | Name      : scale
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : plotting scale (Default is 1)
   |             1 = arithmetic
   |             2 = 1-cycle log
   |             3 = 2-cycle log
   |
   | Name      : maxtime
   | Default   :
   | Type      : Number (Single)
   | Purpose   : the maximum time allowed for the x-axis (Default is the
   |             max time for all graphs per page). Specify MAXTIME in
   |             the same units as TIME, even if XDIVISOR used.
   |
   | Name      : xdivisor
   | Default   :
   | Type      : Number (Single)
   | Purpose   : the divisor used if you want the plotted x-axis in
   |             other units then TIME is in.
   |             Example:  XDIVISOR=365 would plot
   |             the x-axis as TIME/365.
   |
   | Name      : laserprt
   | Default   :
   | Type      : Text
   | Purpose   : the name of the HSR printer you want your plot to go to
   |             if different from your standard printer.
   |
   | Name      : pvals
   | Default   : Y
   | Type      : Text
   | Purpose   : print p values on plots (Default is Y)
   |             N = No p values
   |             Y = Print p_values
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | Output Dataset OUT:
   |
   |   Output Dataset (OUT) contains one observation for each event,
   |   censor, and extra time point specified by POINTS.  The variables
   |   in the output dataset are:
   |
   |   &by = the by-variable(s) (if defined).
   |
   |   &class = the class variable(s) (if defined).
   |
   |   &time = the time variable.
   |
   |   NRISK = the number at risk at &time.
   |
   |   NEVENT = the number of events from &time the next time
   |
   |   NCENSOR = the number of censors from &time the next time
   |
   |   CUM_EV = the cumulative number of events up to and including &time
   |
   |   CUM_CEN = The cumulative number of censors up to and including
   |             &time
   |
   |   PT = The probability of no event up to and including &time.
   |
   |   PE = 1-PT, or the probability of an event occcurring.
   |
   |   UPPER_CL = the upper confidience limit (based on the input
   |              parameters ALPHA and CL).
   |
   |   LOWER_CL = the lower confidience limit (based on the input
   |              parameters ALPHA and CL).
   |
   |   SE = the Greenwood Standard Error.
   |
   |   POINTFLG = the flag indicating points added to the output dataset
   |              because the of POINTS option.  (1=point added,
   |              missing otherwise).
   |
   |
   | Output Dataset OUTSUM:
   |
   |   Output  Summary Dataset (OUTSUM) contains one observation for
   |   each group processed. That is, the total group, or each BY
   |   and/or CLASS value.  The variables in the output dataset are:
   |
   |   &by = the by-variable(s) (if defined).
   |
   |   &class = the class variable(s) (if defined).
   |
   |   TOTAL = the total number of observations in this group.
   |
   |   CUM_EV = the total number of events in this group.
   |
   |   CUM_CEN = the total number of censors in this group.
   |
   |   TL_MISS = the total number of observations not included because
   |             of missing values.
   |
   |   MEDIAN = the median survival time (based on the input parameter
   |            MEDTYPE).
   |
   |   The following variables will be added if the LOGRANK test is
   |   specified:
   |
   |   OBSERVED = the calculated number of observed events.
   |
   |   EXPECTED = the calculated number of expected events.
   |
   |   RR = the Relative Risk (this group's observed/expected / group 1's
   |        observed/expected).
   |
   |   CHISQ = chi-square value.
   |
   |   DF = degrees of freedom.
   |
   |   PVALUE = pvalue (probability of a greater chi-square value).
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   |
   |  1.  If you are getting a message about VPOS not being large
   |      enough, try cutting down on the number of title lines you
   |      are using.  SAS does it's calculations for size based on
   |      1 title, so having 3 or 4 titles MAY cause a problem with
   |      the vertical spacing.
   |
   |  2.  If you are plotting the output dataset yourself, remember
   |      that you need a symbol statement as follows to get the steps
   |      correct:
   |
   |            symbol1 i=stepjl v=none l=1;
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   |
   | %surv(time=fu_time,event=fu_stat,cen_vl=1);
   |
   | %surv(time=fu_time,event=fu_stat,cen_vl=1,class=arm,
   |       out=two,data=one,printop=4,logrank=1,cl=6,
   |       points='0 to 36500 by 182.5');
   |
   | %surv(time=fu_time,event=fu_stat,cen_vl=1,class=arm,by=course,
   |       out=two,data=one,printop=6,logrank=2,plottype=2,xdivisor=365,
   |       points='0 to 360 by 30, 361 to 36500 by 365');
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | Copyright 2006 Mayo Clinic College of Medicine.
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
 
/* SAS MACRO  SURV
 
   This macro will calculate the general survival statistics (p(t),
   standard error, confidience limits, and median survival time. It
   will also do the k-sample logrank and plotting upon request.
 
 
   Note:  For  "expected" or "normal"  survival calculations refer
          to %SURVEXP.
 
 
   The Input Parameters are:
 
     TIME = Variable containing time to event or last follow-up
            in any units (Required)
 
     EVENT = Event variable as a numeric two-valued variable, (0,1),
             (1,2) etc.  The event value must be 1 larger than
             the censoring value. (Required)
 
     CEN_VL = Censoring value for the EVENT variable as 0,1 etc.
              Event = Cen_vl + 1.  (Default is 0)
 
     CLASS = List of classification variables.  They may be either
             character or numeric.  Note - Any observations in the
             input dataset with  missing CLASS data, are not included
             in the results.  Using multiple class variables will
             cause a problem when plotting.
 
     BY = List of "by" variables.  They may be either character or
          numeric.
 
     OUT = Output dataset name (Default is _SURVOUT)
 
     OUTSUM = Output summary dataset name (Default is _SURVSUM)
 
     DATA = Input dataset name (Default is the last dataset created)
 
     PRINTOP = printing options (Default is 1):
               0 = print nothing
               1 = print summary table only
               2 = print one line per event
               3 = print one line per event and/or censor
               4 = print one line for each of a series of time points,
                    as months, half-years, or years (see POINTS).
               5 = print one line per event and/or defined time points.
               6 = print one line per event and/or censor and/or time
                   point.
 
     POINTS = Specific time points at which survival statistics are
              needed, as months, half-years, years.  These points are
              specified by dividing time into intervals as:
                       '0 to 36500 by 365'.
              The endpoint of each interval will be the time point to
              be reported.  If you have comas within your statement,
              enclose the entire parameter in quotes, as:
                       '0 to 360 by 30, 0 to 3650 by 182.5'
              You may also specify specific points as well as
              groups of points as:
                       '1,5,10,15,0 to 36500 by 182.5'
 
     CL = Type of confidence limits (Default is 3, 1 and 2 are not recommended)
          1 = Greenwood (simple)
          2 = Greenwood with modified lower limit
          3 = log-e transformation (log)
          4 = log-e transformation with modified lower limit
          5 = log(-log-e) transformation (log(-log))
          6 = log(log-e) transformation with modified lower limit
          7 = logit transformation (logit)
          8  =logit transformation with modified lowere limit
 
     ALPHA= Type I error rate for confidence limits (Default is .05)
 
     LOGRANK = Option to compute the logrank k-sample test statistics
               for the groups defined by the variable CLASS.  Separate
               tests will be done for BY variable groupings.
               (Default is 1)
               1 = do not calculate
               2 = calculate
 
     MEDTYPE = Type of median if there are several time points
               having probability=.5  (Default is 1)
               1 = use the midpoint between the times as the median
               2 = use the first time value as the median
 
     PLOTTYPE = Where to plot the graph(s) (Default is 1)
                1 = no plot
                2 = greenbar printer plot
                3 = graphics plot on unix laser printer
                4 = plot goes to graphics window
                   (interactive processing)
 
     PLOTOP = What to plot on the y-axis (Default is 1)
              1 = plot pt
              2 = plot 1-pt or pe
 
     SCALE = plotting scale (Default is 1)
             1 = arithmetic
             2 = 1-cycle log
             3 = 2-cycle log
 
     MAXTIME = the maximum time allowed for the x-axis (Default is the
               max time for all graphs per page). Specify MAXTIME in
               the same units as TIME, even if XDIVISOR used.
 
     XDIVISOR = the divisor used if you want the plotted x-axis in
                other units then TIME is in.
                Example:  XDIVISOR=365 would plot
                          the x-axis as TIME/365.
 
     LASERPRT = the name of the HSR printer you want your plot to go to
                if different from your standard printer.
 
     PVALS = print p values on plots (Default is Y)
             N = No p values
             Y = Print p_values
 
   Output Dataset OUT:
 
     Output Dataset (OUT) contains one observation for each event,
     censor, and extra time point specified by POINTS.  The variables
     in the output dataset are:
 
     &by = the by-variable(s) (if defined).
 
     &class = the class variable(s) (if defined).
 
     &time = the time variable.
 
     NRISK = the number at risk at &time.
 
     NEVENT = the number of events from &time the next time
 
     NCENSOR = the number of censors from &time the next time
 
     CUM_EV = the cumulative number of events up to and including &time
 
     CUM_CEN = The cumulative number of censors up to and including
               &time
 
     PT = The probability of no event up to and including &time.
 
     PE = 1-PT, or the probability of an event occcurring.
 
     UPPER_CL = the upper confidience limit (based on the input
                parameters ALPHA and CL).
 
     LOWER_CL = the lower confidience limit (based on the input
                parameters ALPHA and CL).
 
     SE = the Greenwood Standard Error.
 
     POINTFLG = the flag indicating points added to the output dataset
                because the of POINTS option.  (1=point added,
                missing otherwise).
 
 
   Output Dataset OUTSUM:
 
     Output  Summary Dataset (OUTSUM) contains one observation for
     each group processed. That is, the total group, or each BY
     and/or CLASS value.  The variables in the output dataset are:
 
     &by = the by-variable(s) (if defined).
 
     &class = the class variable(s) (if defined).
 
     TOTAL = the total number of observations in this group.
 
     CUM_EV = the total number of events in this group.
 
     CUM_CEN = the total number of censors in this group.
 
     TL_MISS = the total number of observations not included because
               of missing values.
 
     MEDIAN = the median survival time (based on the input parameter
              MEDTYPE).
 
     The following variables will be added if the LOGRANK test is
     specified:
 
     OBSERVED = the calculated number of observed events.
 
     EXPECTED = the calculated number of expected events.
 
     RR = the Relative Risk (this group's observed/expected / group 1's
          observed/expected).
 
     CHISQ = chi-square value.
 
     DF = degrees of freedom.
 
     PVALUE = pvalue (probability of a greater chi-square value).
 
 
   Notes:
 
     1.  If you are getting a message about VPOS not being large
         enough, try cutting down on the number of title lines you
         are using.  SAS does it's calculations for size based on
         1 title, so having 3 or 4 titles MAY cause a problem with
         the vertical spacing.
 
     2.  If you are plotting the output dataset yourself, remember
         that you need a symbol statement as follows to get the steps
         correct:
 
               symbol1 i=stepjl v=none l=1;
 
 
   Examples:
 
   %surv(time=fu_time,event=fu_stat,cen_vl=1);
 
   %surv(time=fu_time,event=fu_stat,cen_vl=1,class=arm,
         out=two,data=one,printop=4,logrank=1,cl=6,
         points='0 to 36500 by 182.5');
 
   %surv(time=fu_time,event=fu_stat,cen_vl=1,class=arm,by=course,
         out=two,data=one,printop=6,logrank=2,plottype=2,xdivisor=365,
         points='0 to 360 by 30, 361 to 36500 by 365');
 
 
   Programmer:  Jan Offord (based on macro KMPL by Frank Harrell
                and Mike Helms)
   Date:  April, 1993
 
         */
 
 
 
%MACRO SURV  (TIME= ,EVENT= ,CEN_VL=0, PRINTOP=1,CLASS= ,BY= ,
              DATA=_LAST_, OUT=_SURVOUT, POINTS= ,CL=3,
              ALPHA=.05,PLOTTYPE=1,PLOTOP=1,SCALE=1,MAXTIME= ,
              XDIVISOR= ,LASERPRT= ,PVALS=Y ,LOGRANk=1,MEDTYPE=1,
              OUTSUM=_SURVSUM);
RUN;
 
 
proc sql;
reset noprint;
select max(number) into :t from dictionary.titles;
quit;
 
%if &t=. %then %let t= ;
%let t=%eval(&t+2);
%if &t > 10 %then %let t=10;
 
 
%local byword byclword lastby lastbycl dev errorflg j a b x cgrp
     cl_name indata;
%LET errorflg = 0;
%LET byword =  ;
%LET byclword = ;
%LET lastby = ;
%LET lastbycl = ;
%let p=.;
%LET dev = &SYSDEVIC;
%let a = %index(&points,%str(%'));
%if &a > 0 %then %do;
   %let b = %eval(%length(&points)-1);
   %let points = %substr(&points,%eval(&a+1),%eval(&b-1));
   %end;
 
%if &time=  %then %do;
   %put  ERROR - Variable <time> not defined;
   %LET  errorflg = 1;
   %end;
 
 %if &event=  %then %do;
   %put  ERROR - Variable <event> not defined;
   %LET  errorflg = 1;
   %end;
 
%if &cen_vl ^= 0 and &cen_vl ^= 1 %then %do;
   %put  ERROR - Variable <censoring value> not defined as 0 or 1;
   %LET  errorflg = 1;
   %end;
 
%if &printop < 0 or &printop > 6 %then %do;
   %put  ERROR - Variable <printop> not defined as 0-6;
   %LET  errorflg = 1;
   %end;
 
 %if &printop >= 4 and &printop <= 6 and &points =  %then %do;
   %put  ERROR - Variable <printop> = 4,5,6, but <points> missing;
   %LET  errorflg = 1;
   %end;
 
 %if &plottype<1 or &plottype>4  %then %do;
   %put  ERROR - Variable <plottype> not 1,2,3, or 4;
   %LET  errorflg = 1;
   %end;
 
 %if &plotop<1 or &plotop>2  %then %do;
   %put  ERROR - Variable <plotop> not 1 or 2;
   %LET  errorflg = 1;
   %end;
 
 %if &scale<1 or &scale>3  %then %do;
   %put  ERROR - Variable <scale> not 1, 2, or 3;
   %LET  errorflg = 1;
   %end;
 
 %if &laserprt^=  and &plottype^=3  %then %do;
   %put  ERROR - Variable <laserprt>  is present, but <plottype^=3;
   %LET  errorflg = 1;
   %end;
 
%if  &plottype=3 and &sysscp=OS  %then %do;
 %put  ERROR - Variable <plottype> = 3, but running on an IBM machine;
   %LET  errorflg = 1;
   %end;
 
 %if &plottype=4 and &sysenv=BACK  %then %do;
   %put  ERROR - Variable <plottype> = 4, but running in backgroupd;
   %LET  errorflg = 1;
   %end;
 
%if &logrank<1 or &logrank>2 %then %do;
   %put ERROR - Variable <logrank> not 1 or 2;
   %let errorflg = 1;
   %end;
 
 %if &logrank=2 and &class=  %then %do;
   %put ERROR - Logrank test requested, but no classes are defined;
   %let errorflg = 1;
   %end;
 
 %if &medtype<1 or &medtype>2  %then %do;
   %put ERROR - Variable <medtype> is not 1 or 2;
   %let errorflg = 1;
   %end;
 
 %if &cl<1 or &cl>8  %then %do;
   %put ERROR - Variable <cl> is not 1-8;
   %let errorflg = 1;
   %end;
 
%if &errorflg = 1 %then %do;
    data _null_;
    error 'ERROR - detected in the input data to the macro <surv>.';
    %go to exit;
    %end;
 
%IF &BY^=  %THEN %DO;
   %LET byword=BY;
   %LET byclword=BY;
   %DO J=1 %TO 50 %BY 1;    /*  find last BY variable  */
      %LET X=%SCAN(&BY,&J);
      %IF &X^=  %THEN %do;
         %LET lastby=&X;
         %LET lastbycl=&X;
         %end;
      %ELSE %GOTO NEXT1;
      %END;
   %NEXT1:  %END;
 
%IF &CLASS^=  %THEN %DO;
   %LET byclword=BY;
   %DO J=1 %TO 50 %BY 1;    /*  find last CLASS variable  */
      %LET X=%SCAN(&CLASS,&J);
       %IF &X^=  %THEN %do;
         %LET lastbycl=&X;
          %let V&j = &X;
          %let cgrp = &j;
          %local V&j;
          %end;
         %ELSE %GOTO NEXT2;
      %END;
   %NEXT2:
    %END;
 
data _tmp_;  set &data;
     keep &by &class &time &event;
 
   %if &class^=  %then %do;
    %do j=1 %to &cgrp %by 1;
      where &&v&j is  not missing;
      %end;
     %end;
 
  if &time=. or &time < 0 then do;
     error "ERROR - &time= " &time ' - not used.';
     &time = .;
     &event = .;
     end;
  if &event > &cen_vl+1 or &event < &cen_vl then do;
     error "ERROR - &event= " &event ' - not used.';
     &time = .;
     &event = .;
     end;
 
PROC SORT; BY  &BY &CLASS &TIME;
PROC MEANS NOPRINT DATA=_TMP_; VAR &TIME; &byclword &BY &CLASS;
    OUTPUT OUT=_COUNTS_ N=NRISK max=maxtime nmiss=tl_miss;
 
%IF &POINTS^=  %THEN %DO;
   data _TMP1_;    /*  add point observations  */
       set _COUNTS_;
       keep &by &class &time &event point;
       flag=0;
       do j=&POINTS;
         if flag=1 then return;
         if j>=maxtime then flag=1;
         if j>0 then do;
            &time = j;
            &event = .;
            point = 1;
            output;
            end;
         end;
 
   data _TMP_;  set _TMP_ _TMP1_;
   proc sort;  by &BY &CLASS &TIME;
   %END;
 
DATA &OUT (KEEP=&by &CLASS &TIME nrisk nevent ncensor cum_ev cum_cen
             pt pe upper_cl lower_cl se pointflg)
     &outsum (keep=&by &class total cum_ev cum_cen median tl_miss)
     _print_ (keep=&by &class &time years nrisk nevent pt ncensor
                lower_cl upper_cl se cum_ev cum_cen);
  SET _TMP_ nobs=nobs; BY &BY &CLASS &TIME;
   RETAIN pt nevent _kt_ ncensor nrisk _sv1_ cum_ev cum_cen total
      median firstmed pointflg laster loweradj;
   LABEL pt="Kaplan-Meier Survival Estimate"
      pe = "1-P(t)"
      se="Greenwold Standard Error"
      lower_cl  ="Lower Confidence Limit"
      upper_cl  ="Upper Confidence Limit"
      NRISK="Number at Risk at beginning of (t)"
      NEVENT="Number of Events at (t)"
      ncensor="Number Censored at (t)"
      cum_ev = "Cumulative events including (t)"
      cum_cen = "Cumulative censors including (t)"
      median = "Median Survival"
      tl_miss = "Total Missing"
      pointflg = "Added Times"
      ;
 
   _FT_=FIRST.&TIME;
   _LT_=LAST.&TIME;
 
   %if &points = %then %do;
      point=.;
      %end;
 
   %IF &lastbycl^=  %THEN %DO;
      IF FIRST.&lastbycl=0 THEN GO TO NOTFIRST;
     %END;
    %ELSE %DO;
      IF _N_>1 THEN GO TO NOTFIRST;
    %END;
 
    /* do if the first observation per by group */
 
  SET _COUNTS_;    /*  read observation from _counts_ */
   _THOLD_=&TIME;
   laster=nrisk;
   pointflg=.;
   &TIME=0;
   NEVENT=0;
   _KT_=0;
   ncensor=0;
   cum_ev=0;
   cum_cen=0;
   pt=1;
   pe=0;
   se=0;
   _sv1_=0;
   lower_cl=1;
   upper_cl=1;
   loweradj=.;
   years=0;
   OUTPUT &out;        /*  output an observation at time=0 */
   OUTPUT _print_;
   &TIME=_THOLD_;
   total = nrisk;     /*  set up summary dataset */
   median=.;
   firstmed=.;
 
 
    /*  do for each observation in the dataset */
 
  NOTFIRST:
 
   IF _FT_ THEN DO;    /*  do for the first obs. per time */
      NEVENT=0;
      _KT_=0;
      ncensor=0;
      pointflg=.;
      END;
 
   /*  for each observation */
 
   if point = 1 then pointflg = 1;
 
   if point ^= 1 and &time ^= . then do;
      if &event = &cen_vl+1 then NEVENT=NEVENT+1;
        else ncensor=ncensor+1;
      _KT_=_KT_+1;
      end;
 
   IF _LT_ then do;     /* do for the last observation per time */
 
     if _kt_=0 and pointflg ^=1 then go to next3;
                                         /* missing for this time*/
 
     if nrisk>0 then pt=pt*(1-NEVENT/NRISK);
            else pt=.;
     pe = 1 - pt;
     cum_ev = cum_ev + nevent;
     cum_cen = cum_cen + ncensor;
     if nevent>0 then laster=nrisk;  /*  nrisk at last event time */
 
     IF nrisk<=nevent THEN DO;
       se=.;
       lower_cl=.;
       upper_cl=.;
       END;
      ELSE DO;
       if _kt_>0 then loweradj=SQRT(laster/nrisk);
       _sv1_=_sv1_+nevent/nrisk/(nrisk-nevent);
       se=SQRT(pt*pt*_sv1_);
 
       %if &cl=1 %then %do;
          %let cl_name=Greenwood;
          lower_cl=pt-PROBIT(1-&alpha/2)*se;
          upper_cl=pt+PROBIT(1-&alpha/2)*se;
          %end;
       %if &cl=2 %then %do;
          %let cl_name=Green(adj);
          lower_cl=pt-PROBIT(1-&alpha/2)*loweradj*se;
          upper_cl=pt+PROBIT(1-&alpha/2)*se;
          %end;
 
       %if &cl=3 %then %do;
          %let cl_name=Log;
          _w_=PROBIT(1-&alpha/2)*sqrt(_sv1_);
          lower_cl=exp(log(pt)-_w_);
          upper_cl=exp(log(pt)+_w_);
          %end;
       %if &cl=4 %then %do;
          %let cl_name=Log(adj);
         _wl_=PROBIT(1-&alpha/2)*loweradj*sqrt(_sv1_);
          _w_=PROBIT(1-&alpha/2)*sqrt(_sv1_);
          lower_cl=exp(log(pt)-_wl_);
          upper_cl=exp(log(pt)+_w_);
          %end;
 
      %if &cl=5 %then %do;
          %let cl_name=Log(-log);
          if pt^=1 then do;
            _w_=PROBIT(1-&alpha/2)*sqrt(_sv1_)/log(pt);
            lower_cl=pt**exp(-_w_);
            upper_cl=pt**exp(_w_);
            end;
           else do;
            lower_cl=1;
            upper_cl=1;
            end;
          %end;
       %if &cl=6 %then %do;
          %let cl_name=Log(-log)adj;
          if pt^=1 then do;
            _wl_=PROBIT(1-&alpha/2)*loweradj*sqrt(_sv1_)/log(pt);
            _w_=PROBIT(1-&alpha/2)*sqrt(_sv1_)/log(pt);
            lower_cl=pt**exp(-_wl_);
            upper_cl=pt**exp(_w_);
            end;
           else do;
            lower_cl=1;
            upper_cl=1;
            end;
          %end;
 
      %if &cl=7 %then %do;
          %let cl_name=Logit;
          if pt^=1 then do;
             _w_=PROBIT(1-&alpha/2)*sqrt(_sv1_/(1-pt)**2);
             _zl_=exp(log(pt/(1-pt))-_w_);
             _zu_=exp(log(pt/(1-pt))+_w_);
             lower_cl=_zl_/(1+_zl_);
             upper_cl=_zu_/(1+_zu_);
            end;
           else do;
            lower_cl=1;
            upper_cl=1;
            end;
          %end;
       %if &cl=8 %then %do;
          %let cl_name=Logit(adj);
          if pt^=1 then do;
             _w_=PROBIT(1-&alpha/2)*sqrt(_sv1_/(1-pt)**2);
             _wl_=PROBIT(1-&alpha/2)*loweradj*sqrt(_sv1_/(1-pt)**2);
             _zl_=exp(log(pt/(1-pt))-_wl_);
             _zu_=exp(log(pt/(1-pt))+_w_);
             lower_cl=_zl_/(1+_zl_);
             upper_cl=_zu_/(1+_zu_);
            end;
           else do;
            lower_cl=1;
            upper_cl=1;
            end;
          %end;
        if lower_cl<0 then lower_cl=0;
        if upper_cl>1 then upper_cl=1;
        END;
 
     OUTPUT &out;
 
     years = round(&time/365,0.01);
      %if &printop = 2 %then %do;
          if nevent > 0 then output _print_;
          %end;
      %if &printop = 3 %then %do;
          if nevent > 0  or ncensor > 0 then output _print_;
          %end;
      %if &printop = 4 %then %do;
          if pointflg = 1 then output _print_;
          if &time=0 and (nevent>0 or ncensor>0) then output _print_;
          %end;
      %if &printop = 5 %then %do;
          if nevent > 0  or pointflg = 1 then output _print_;
          %end;
      %if &printop = 6 %then %do;
          output _print_;
          %end;
 
     NRISK=NRISK-_KT_;
 
     if _kt_ = 0 then go to next3;
     if ABS(pt-0.5)<=0.00001 then do;
        if firstmed = . then firstmed = &time;
        end;
     if median=. and round(pt,0.00001) < 0.5  THEN DO;
        if firstmed ^=. then
             %if &medtype=1 %then  %do;
                median = (&time + firstmed)/2.0;
                %end;
             %if &medtype=2 %then %do;
 
 
 
median = firstmed;
                 %end;
           else median = &time;
        end;
 
     next3:             /*  output summary data */
 
%IF &lastbycl^=  %THEN %DO;
        IF LAST.&lastbycl=1 THEN output &outsum;
        %END;
       %ELSE %DO;
         IF _N_=nobs THEN output &outsum;
         %END;
 
     end;
run;
 
 
 %if &logrank=2 %then %do;
 
   data &outsum;
      set &outsum end=last; &byword &by;
      retain ngroups;
 
      if _n_=1 then do;
         ngroups=1;
         end;
 
      line_num=put(_n_,3.);
 
      %if &by^=  %then %do;
         if first.&lastby and _n_^=1 then do;
         ngroups=ngroups+1;
         end;
         %end;
      if last then do;
         call symput('ngp',left(put(ngroups,2.)));
         end;
 
   data _tmp_;
    merge &outsum (in=in1) _tmp_(in=in2);  by &by &class;
    keep &by &class &time &event ngroups line_num;
    if in1 and in2;
    %if &points^=  %then %do;
      if point=1 then delete;
    %end;
 
   %do i=1 %to &ngp;
      data _tmp1_;
        set _tmp_;
        keep line_num &time &event;
        if ngroups=&i;
 
      %survlrk(data=_tmp1_,time=&time,death=&event,censor=&cen_vl,
              strata=line_num,out=_x&i);
 
      %end;
 
   data _tmp1_;  set
      %do i=1 %to &ngp;
        _x&i
        %end;
       ;
 
   data &outsum;
      merge _tmp1_(in=in1) &outsum(in=in2);  by line_num;
      format observed expected o_e 8.1 rr 5.3 chisq 8.2 pvalue 8.4;
      drop line_num ngroups;
      if in1 and in2;
      if chisq = 0 then pvalue=.N;
 
   proc sql;
   reset noprint;
   select round(pvalue*1000)/1000 format 4.4 into :p from &outsum;
   quit;
 
   %end;
 
 
%if &printop = 0 %then %goto plots;
 
proc print data=&outsum split='*'; &byword &by;
   id  &class;
   var total cum_ev cum_cen tl_miss median
   %if &logrank=2 %then %do;
       observed expected o_e rr chisq df pvalue
       %end;
           ;
   label total = Total*N
         tl_miss = Total*Missing
         cum_ev = Total*Events
         cum_cen = Total*Censors
         median = Median*Survival
    %if &logrank=2 %then %do;
         observed = "|----"*"| Obs"
         expected = "-----"*"Exp"
         o_e = "-------"*"Obs-Exp"
         rr = "   LOG"*"R.Risk"
         chisq = 'RANK  '*Chisq
         df = '--'*df
         pvalue = '-----------|'*'Prob>Chisq |'
        %end;
        ;
   sum total cum_ev cum_cen tl_miss
   %if &logrank=2 %then %do;
       observed expected o_e
       %end;
             ;
   title&t "Survival Summary Table for Variables <&time> and <&event>";
footnote1 "Input Parameters (TIME=&time ,EVENT=&event ,"
        "CEN_VL=&cen_vl,PRINTOP=&printop,CLASS=&class,BY=&by,";
footnote2 "DATA=&data,OUT=&out,"
        " POINTS=&points,CL=&cl,ALPHA=&alpha,";
footnote3 "PLOTTYPE=&plottype,PLOTOP=&plotop,SCALE=&scale,MAXTIME="
             "&maxtime,XDIVISOR=&xdivisor,LASERPRT=&laserprt,LOGRANK="
             "&logrank,MEDTYPE=&medtype,OUTSUM=&outsum)";
 
 
%if &printop = 1 %then %goto plots;
 
data _NUll_;
         y=put(100-&alpha*100,2.);
        call symput('percent',y);
 
 
 footnote1;
 footnote2;
 footnote3;
 
proc print data=_print_ split='*';  &byclword &by &class;
        id &time years;
   %if &printop = 2 %then %do;
        var nrisk nevent pt lower_cl upper_cl se;
        sum nevent;
        %end;
   %if &printop = 3 %then %do;
        var nrisk nevent ncensor pt lower_cl upper_cl se;
        sum nevent ncensor;
        %end;
   %if &printop = 4 %then %do;
        var nrisk cum_ev cum_cen pt lower_cl upper_cl se;
        %end;
   %if &printop = 5 %then %do;
        var nrisk nevent pt lower_cl upper_cl se;
        sum nevent;
        %end;
   %if &printop = 6 %then %do;
        var nrisk nevent ncensor pt lower_cl upper_cl se;
        sum nevent ncensor;
        %end;
        format pt lower_cl upper_cl se 5.3;
        label &time = *&time*(t)
              years = *&time*'/365'
              nrisk = Number*'at Risk'*'at (t)'
              cum_ev = Cumulative*'# Events'*'<= (t)'
              nevent = Number*'Events'*'at (t)'
              ncensor = Number*'Censors'*'at (t)'
              cum_cen = Cumulative*'# Censors'*'<= (t)'
              pt = Probability*'No Event'*'<= (t)'
              lower_cl = "Lower &percent%"*'C. Limit'*"(&cl_name)"
              upper_cl = "Upper &percent%"*'C. Limit'*"(&cl_name)"
              se = Greenwood*Standard*Error;
   %if &by ^= %then %do;
        pageby &lastby;
        %end;
 
   title&t "Kaplan-Meier Survival Estimates for <&time> and <&event>";
       run;
 
    /*  plotting  */
 
%plots:
title&t;
 
%if &plottype=1 %then %goto exit;
 
%if &plottype=2 %then %do;
 
%LET indata = &out;
 
PROC MEANS NOPRINT DATA=_counts_; &byword &by;
    VAR maxtime;
    OUTPUT OUT=_MAX_ max=maxt;
 
%if &maxtime ^=  %then %do;
  data _max_;  set _max_;
      if maxt>&maxtime then maxt=&maxtime;
  %end;
 
%if &xdivisor ^=  %then %do;
  data _max_;  set _max_;
      maxt=maxt/&xdivisor;
  data _tmp_;  set &out;
     &time=&time/&xdivisor;
  %let indata = _tmp_;
  %end;
 
data _tmp_;  set &indata;   &byword &by;
   keep &by x y symbol;
   retain maxt xtick ytick oldx oldy;
 
   label x = "&time";
   label y = 'Percent';
 
   %if &xdivisor ^=  %then %do;
       label x = "&time/&xdivisor";
       %end;
 
   %if &class ^=  %then %do;
      symbol=&class;
      label symbol = "&class";
      %end;
     %else %do;
      symbol='*';
      %end;
 
   %IF &lastby^=  %THEN %DO;
      IF FIRST.&lastby=0 THEN GO TO next4;
     %END;
    %ELSE %DO;
      IF _N_>1 THEN GO TO next4;
    %END;
 
  SET _Max_;
   xtick=maxt/100/2;
   ytick=1/30/2;
 
   %if  &sysscp=OS  %then %do;
       ytick=1/40/2;
       %end;
 
   oldx=.;
   oldy=.;
   pt=pt*100;
   go to next5;
 
 next4:
   pt=pt*100;
   if oldx ^=. and oldx > &time  then do;
                          /*  first obs for next class */
        oldx=.;
        oldy=.;
        go to next5;
        end;
 
   if &time>0 and nevent=0 and ncensor=0 then return;
 
   /*  horizonal dots */
 
   do i=oldx to &time-xtick by xtick while (i<=maxt);
        if i^=oldx then do;
           x=i;
           y=oldy;
           output;
           end;
        end;
 
    if oldy^=pt and &time<=maxt then do i=oldy to pt by -ytick;
           x=&time;
           y=i;
           output;
        end;
 
   next5:
   x=&time;
   y=pt;
 
   if x<=maxt then output;
   oldx=x;
   oldy=y;
 
%if &plotop = 2 %then %do;
    data _tmp_;  set _tmp_;  y=100-y;
    %end;
 
   proc plot data=_tmp_ nolegend uniform;  &byword &by;
       plot y*x=symbol
          /hzero hpos=100
       %if &sysscp=OS %then %do;
           vpos=40
           %end;
         %else %do;
            vpos=30
            %end;
       %if &scale=1 %then %do;
           vaxis=0 to 100 by 25;
           %end;
       %if &scale=2 %then %do;
           vaxis=10 17.78 31.62 56.233 100;
           %end;
       %if &scale=3 %then %do;
           vaxis=1 3.162 10 31.62 100;
           %end;
   footnote1 "TIME=&time, EVENT=&event,CLASS=&class";
     %if &p ne . and &by = and &pvals=Y %then %do;
        %if &p =  %then %do;
            footnote2 "PVALUE = NA";
           %end;
        %else %if &p lt .001 %then %do;
            footnote2 "PVALUE < .001";
           %end;
        %else %do;
            footnote2 "PVALUE=&p";
           %end;
     %end;
   run;
 
   %end;
 
%if &plottype = 3 %then %do;
 
  %if &laserprt ^=  %then %do;
     filename graphout pipe "cat | /usr/ucb/lpr -P&laserprt ";
     %end;
    %else %do;
     filename graphout pipe 'cat | /usr/ucb/lpr ';
     %end;
 
/*  libname gdevice0  '/people/statsys/kosanke/mydevices'; */
  goptions cback=white colors=(black) device=apple;
  %end;
 
%if &plottype >= 3 %then %do;
 
  data _tmp_;
      set &out;
      keep x y &class &by;
      retain lastpt lastx;
      label y = 'Percent';
 
      if &time=0 then do;
        lastx=.;
        lastpt=.;
        end;
 
      if &time>0 and nevent=0 and ncensor=0 then delete;
 
      %if &maxtime^=  %then %do;
         if &time>&maxtime then do;
           if lastx=1 then delete;
             else do;
              lastx=1;
              &time=&maxtime;
              pt=lastpt;
              end;
            end;
         %end;
 
      lastpt=pt;
      y=pt*100;
      %if &plotop = 2 %then %do;
        y=100-y;
        %end;
 
   %if &xdivisor ^=  %then %do;
       label x = "&time/&xdivisor";
       x = &time/&xdivisor;
       %end;
     %else %do;
      label x = "&time";
      x=&time;
      %end;
 
  proc gplot data=_tmp_;  &byword &by;
   %if &class ^= %then %do;
      plot y*x=&class
      %end;
     %else %do;
        plot y*x
      %end;
          /hzero
       %if &scale=1 %then %do;
           vaxis=0 to 100 by 10;
           %end;
       %if &scale=2 %then %do;
           vaxis=10 17.78 31.62 56.233 100;
           %end;
       %if &scale=3 %then %do;
           vaxis=1 3.162 10 31.62 100;
           %end;
       symbol1 i=stepjl v=none l=1;
       symbol2 i=stepjl v=none l=2;
       symbol3 i=stepjl v=none l=4;
       symbol4 i=stepjl v=none l=8;
       symbol5 i=stepjl v=none l=41;
       symbol6 i=stepjl v=none l=33;
       symbol7 i=stepjl v=none l=35;
       symbol8 i=stepjl v=none l=46;
       symbol9 i=stepjl v=none l=40;
     footnote1 "TIME=&time, EVENT=&event";
     %if &p ne . and &by = and &pvals=Y %then %do;
        %if &p =  %then %do;
            footnote2 "PVALUE = NA";
           %end;
        %else %if &p lt .001 %then %do;
            footnote2 "PVALUE < .001";
           %end;
        %else %do;
            footnote2 "PVALUE=&p";
           %end;
     %end;
     run;
 
    %end;
 
proc datasets nolist;
      %if &points ^=  %then %do;
            delete _tmp1_ _tmp_ _counts_ _print_;
            %end;
         %else %do;
            delete _tmp_ _counts_ _print_;
            %end;
    run;
    quit;
   footnote1;
%exit:
 
OPTIONS _LAST_=&out;
options notes;
 
%let SYSDEVIC = &dev;
 
%MEND SURV;
 
 
 
 
 
 
 
 
 
