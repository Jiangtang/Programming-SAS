  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : survtd
   | SHORT DESC  : General survival statistics for left-truncated
   |               survival, time-dependent data
   *------------------------------------------------------------------*
   | CREATED BY  : Offord, Jan                   (04/28/2004 10:05)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | This macro will calculate the general survival statistics (p(t),
   |   standard error, confidence limits, and median survival time, for
   |   the following special cases:
   |
   |     1) Left-truncated survival
   |
   |     2) Time dependant calculations where a person can change state
   |        (CLASS) after time zero.
   |
   |   This macro does not do any testing.  Use Procedures phreg, cox,etc.
   |   This macro, also, does not support multiple event data.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %survtd  (
   |            strttime= ,
   |            stoptime= ,
   |            event= ,
   |            cen_vl=0,
   |            class= ,
   |            mintime=0,
   |            by= ,
   |            out=_SURVOUT,
   |            outsum=_SURVSUM,
   |            data=_LAST_,
   |            printop=1,
   |            points= ,
   |            cl=3,
   |            alpha=0.05,
   |            medtype=1,
   |            plottype=1,
   |            plotop=1,
   |            scale=1,
   |            maxtime= ,
   |            xdivisor= ,
   |            laserprt=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : strttime
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable containing the beginning time.  See examples.
   |
   | Name      : stoptime
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable containing the ending time.  See examples.
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable containing the event status at STOPTIME, as a
   |             numeric two-valued variable, (0,1),  (1,2) etc.
   |             The event value must be 1 larger than the censoring value.
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : cen_vl
   | Default   : 0
   | Type      : Number (Single)
   | Purpose   : Censoring value for the EVENT variable as 0,1 etc.
   |             Event = Cen_vl + 1.
   |
   | Name      : class
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Classification or state variable(s).  They may be
   |             either character or numeric.  Note - Any observations
   |             in the input dataset with  missing CLASS data, are not
   |             included in the results.
   |
   | Name      : mintime
   | Default   : 0
   | Type      : Number (Single)
   | Purpose   : The beginning time for the suvival calculations and
   |             x-axis of the graph.  Indicate MINTIME in the same units
   |             as STRTTIME, even if XDIVISOR is coded.
   |
   | Name      : by
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : List of "by" variables.  They may be either character or numeric.
   |
   | Name      : out
   | Default   : _SURVOUT
   | Type      : Dataset Name
   | Purpose   : Output dataset name
   |
   | Name      : outsum
   | Default   : _SURVSUM
   | Type      : Dataset Name
   | Purpose   : Output summary dataset name
   |
   | Name      : data
   | Default   : _LAST_
   | Type      : Dataset Name
   | Purpose   : Input dataset name
   |
   | Name      : printop
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : printing options (Default is 1):
   |             0 = print nothing
   |             1 = print summary table only
   |             2 = print one line per event
   |             3 = print one line per event, arrival, and/or censor
   |             4 = print one line for each of a series of time points,
   |             as months, half-years, or years (see POINTS).
   |             5 = print one line per event and/or defined time points.
   |             6 = print one line per event,arrival, censor, and/or
   |             time point.
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
   | Purpose   : Type of confidence limits (Default is 3)
   |             1 = Greenwood (actual)
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
   | Name      : medtype
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : Type of median if there are several time points
   |             having probability=.5
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
   | Purpose   : plotting scale
   |             1 = arithmetic
   |             2 = 1-cycle log
   |             3 = 2-cycle log
   |
   | Name      : maxtime
   | Default   :
   | Type      : Number (Single)
   | Purpose   : The maximum time allowed for the x-axis (Default is
   |             the max time for all graphs per page). Specify MAXTIME
   |             in the same units as STRTTIME, even if XDIVISOR used.
   |
   | Name      : xdivisor
   | Default   :
   | Type      : Number (Single)
   | Purpose   : The divisor used if you want the plotted x-axis in
   |             other units then TIME is in.
   |             Example:  XDIVISOR=365 would plot the x-axis as TIME/365.
   |
   | Name      : laserprt
   | Default   :
   | Type      : Text
   | Purpose   : The name of the HSR printer you want your plot to go
   |             to if different from your standard printer.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | Potentially, listing output, output data sets, and graphics.
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | If you have questions or concerns, please call Jan Offord (4-5630),
   |    Terry Therneau (4-3694) or Erik Bergstralh (4-5679).
   |
   |
   |  Output Dataset OUT:
   |
   |    Output Dataset (OUT) contains one observation for each event,
   |    censor, arrival, and extra time point specified by POINTS.
   |    The variables in the output dataset are:
   |
   |    &by = the by-variable(s) (if defined).
   |
   |    &class = the class variable(s) (if defined).
   |
   |    &stoptime = the stoptime variable.
   |
   |    NRISK = the number at risk at &stoptime.
   |
   |    NEVENT = the number of events from &stoptime the next stoptime
   |
   |    NCENSOR = the number of censors from &stoptime the next stoptime
   |
   |    NARRIVE = the number of arrivals during this time.
   |
   |    CUM_EV = the cumulative number of events up to and including
   |             &stoptime
   |
   |    CUM_CEN = The cumulative number of censors up to and including
   |              &stoptime
   |
   |    CUM_ARR = The cumulative number of arrivals up to and including
   |              this time.
   |
   |    PT = The probability of no event up to and including &stoptime.
   |
   |    PE = 1-PT, or the probability of an event occcurring.
   |
   |    UPPER_CL = the upper confidience limit (based on the input
   |               parameters ALPHA and CL).
   |
   |    LOWER_CL = the lower confidience limit (based on the input
   |               parameters ALPHA and CL).
   |
   |    SE = the Greenwood Standard Error.
   |
   |    POINTFLG = the flag indicating points added to the output dataset
   |               because the of POINTS option.  (1=point added,
   |               missing otherwise).
   |
   |
   |  Output Dataset OUTSUM:
   |
   |    Output  Summary Dataset (OUTSUM) contains one observation for
   |    each group processed. That is, the total group, or each BY
   |    and/or CLASS value.  The variables in the output dataset are:
   |
   |    &by = the by-variable(s) (if defined).
   |
   |    &class = the class variable(s) (if defined).
   |
   |    TOTAL = the total number of observations in this group.
   |
   |    CUM_EV = the total number of events in this group.
   |
   |    CUM_CEN = the total number of censors in this group.
   |
   |    CUM_ARR = the total number of arrivals in this group.
   |
   |    TL_MISS = the total number of observations not included because
   |              of missing values.
   |
   |    MEDIAN = the median survival time (based on the input parameter
   |             MEDTYPE).
   |
   |    The following variables will be added if the LOGRANK test is
   |    specified:
   |
   |    OBSERVED = the calculated number of observed events.
   |
   |    EXPECTED = the calculated number of expected events.
   |
   |    RR = the Relative Risk (this group's observed/expected /
   |         group 1's observed/expected).
   |
   |    CHISQ = chi-square value.
   |
   |    DF = degrees of freedom.
   |
   |    PVALUE = pvalue (probability of a greater chi-square value).
   |
   |
   |   Notes:
   |
   |     1. If you are getting a message about VPOS not being large enough,
   |        try cutting down on the number of title lines you are using.
   |        SAS does it's calculations for size based on 1 title, so having
   |        3 or 4 titles MAY cause a problem with the vertical spacing.
   |
   |     2. If you are plotting the output dataset yourself, remember that
   |        you need a symbol statement as follows to get the steps
   |        correct:
   |
   |              symbol1 i=stepjl v=none l=1;
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | Left-truncation:
   |
   |    An example of left-truncation is a study where surivial needs
   |    to be measured from initial diagnosis until death and there are
   |    several patients in the study diagnosed elsewhere prior to coming
   |    to Mayo.  Patients diagnosed at Mayo contribute to the survival
   |    curve from date of diagnosis (t(0)), but those "arriving" at Mayo
   |    years (t(a)) after diagnosis contribute to the curve starting
   |    after time t(a).
   |
   |    This macro will produce a survival curve using patients in
   |    the curve from the time they "arrive" until last
   |    follow-up.  To do this you need a dataset with one observation
   |    per person with the following variables:
   |
   |    STRTTIME = Variable containing the time (in any units) when
   |               the patient "arrives" measured from the time of initial
   |               interest (as initial diagnosis date in the above ex.)
   |               If the patient "arrives" at time t(0) (the patient was
   |               diagnosed in Rochester) STRTTIME would be 0.
   |
   |    STOPTIME = Variable containing the follow-up time measured from
   |               the time of initial interest (as initial diagnosis
   |               date in the above example).
   |
   |    *** Note - STRTTIME and STOPTIME cannot be the same value.
   |               In some cases you may need to add a small value
   |               (0.5) to either the strttime or stoptime values to
   |               make them different.
   |
   |    EVENT = variable containing the survival status at STOPTIME.
   |
   |
   |  Example:  A person diagnosed in Rochester then dying on day 35:
   |
   |             STRTTIME=0, STOPTIME=35, EVENT=1
   |
   |  Example:  A person diagnosed elsewhere, coming to Rochester on
   |            day 35 then dying on day 200:
   |
   |            STRTTIME=35, STOPTIME=200, EVENT=1
   |
   |  Example:  A person diagnosed in Rochester then dying very soon
   |            after:
   |
   |             STRTTIME=0.1, STOPTIME=0.9, EVENT=1
   |
   |
   |  Time Dependent Co-variates:
   |
   |    An example of a time dependent covariate is a study where a
   |    patient was in one state (CLASS) for a length of time (as without
   |    a transplant), then moves into another state (CLASS) (as
   |    transplant). Survival is measured from some initial time (as
   |    date placed on the waiting list for a transplant) until last
   |    follow-up or death.
   |
   |    This macro will produce a survival curve for each state of the
   |    time-dependent covariate (CLASS) (one for no transplant,and one
   |    for transplants, in the above example). Patients may, or may not,
   |    be in more than one of the curves, but they can only be in 1 curve
   |    at any given time (day, or day, hour and minute).  Any person
   |    transferring from one state to another would have two observations,
   |    one for time in state 1 and another for the time in state 2. The
   |    EVENT variable would always be censored in the first observation.
   |    There is no limit to the number of transfers a patient can make.
   |
   |    To do this you need a dataset with one observation per
   |    person per "state" with the following variables:
   |
   |    CLASS = Variable containing the state or value of the
   |            covariate from STRTTIME to STOPTIME.  In the above
   |            example CLASS will have 2 values, 0=no transplant and
   |            1=transplanted.
   |
   |    STRTTIME = Variable containing the starting time (in any units)
   |               for the patient in this state. If the patient is in
   |               this state at t(0) (date put on the transplant list)
   |               STRTTIME would be 0.
   |
   |    STOPTIME = Variable containing the ending time (in any units)
   |               for the patient in this state.  If the patient dies,
   |               or is censored this would be the last follow-up time.
   |
   |    *** Note - STRTTIME and STOPTIME cannot be the same value.
   |               In some cases you may need to add a small value
   |               (0.5) to either the strttime or stoptime values to
   |               make them different.
   |
   |    EVENT = variable containing the survival status at STOPTIME.
   |
   |
   |   Example:  A person on the transplant and never receiving a
   |             transplant and dying on day 35 would have one observation
   |             with:
   |
   |                CLASS=0, STRTTIME=0, STOPTIME=35, EVENT=1
   |
   |   Example:  A person on the transplant list, transplanted on day 15,
   |             an dying on day 45 would have two observations, one for
   |             each class or state:
   |
   |               CLASS=0, STRTTIME=0, STOPTIME=15, EVENT=0
   |               CLASS=1, STRTTIME=15.5, STOPTIME=45, EVENT=1
   |
   |
   |
   |   Note:  For both types of analysis, events occurring at t(0) should
   |           be recorded as STRTTIME=0.1 STOPTIME=0.9.
   |
   |   Note:  For both types of analysis, use the MINTIME variable to begin
   |          your survival calculations at some time later than t(0).
   |          This may be necessary if you have small numbers of people at
   |          risk in the first units of time.
   |
   |
   |  Examples:
   |
   |  %survtd(strttime=roch_dt, stoptime=fu_time,event=fu_stat,cen_vl=1);
   |
   |  %survtd(strttime=arrtime,stoptime=fu_time,event=fu_stat,cen_vl=1,
   |           out=two,data=one,printop=4,cl=6, mintime=30,
   |           points='0 to 36500 by 182.5');
   |
   |
   |  %survtd(strttime=arrtime,stoptime=fu_time,event=fu_stat,cen_vl=1,
   |            class=chf,out=two,data=one,printop=4,cl=6,
   |            points='0 to 36500 by 182.5');
   *------------------------------------------------------------------*
   | Copyright 2004 Mayo Clinic College of Medicine.
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
 
 
%MACRO SURVTD  (STRTTIME= ,STOPTIME= ,EVENT= ,CEN_VL=0, PRINTOP=1,
                CLASS= ,BY= , MINTIME=0,
                DATA=_LAST_, OUT=_SURVOUT,POINTS= ,CL=3,
                ALPHA=.05,PLOTTYPE=1,PLOTOP=1,SCALE=1,MAXTIME= ,
                XDIVISOR= ,LASERPRT= ,MEDTYPE=1,OUTSUM=_SURVSUM);
RUN;
 
proc sql;
reset noprint;
select max(number) into :t from dictionary.titles;
quit;
 
%let t=%eval(&t+2);
%if &t > 9 %then %let t=9;
%let u=%eval(&t+1);
 
 
%local byword byclword lastby lastbycl dev errorflg j a b x cgrp
     cl_name indata;
 
%LET errorflg = 0;
%LET byword =  ;
%LET byclword = ;
%LET lastby = ;
%LET lastbycl = ;
%LET dev = &SYSDEVIC;
%let a = %index(&points,%str(%'));
%if &a > 0 %then %do;
   %let b = %eval(%length(&points)-1);
   %let points = %substr(&points,%eval(&a+1),%eval(&b-1));
   %end;
 
%if &strttime=  %then %do;
   %put  ERROR - Variable <strttime> not defined;
   %LET  errorflg = 1;
   %end;
 
%if &stoptime=  %then %do;
   %put  ERROR - Variable <stoptime> not defined;
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
   %put
    ERROR - Variable <plottype> = 3, but running on an IBM machine;
   %LET  errorflg = 1;
   %end;
 
 %if &plottype=4 and &sysenv=BACK  %then %do;
   %put  ERROR - Variable <plottype> = 4, but running in backgroupd;
   %LET  errorflg = 1;
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
     keep &by &class &strttime &stoptime &event;
 
   %if &class^=  %then %do;
    %do j=1 %to &cgrp %by 1;
      where &&v&j is  not missing;
      %end;
     %end;
 
  if &strttime=. or &strttime < 0 then do;
     error "ERROR - &strttime= " &strttime ' - not used.';
     &strttime = .;
     &stoptime = .;
     &event = .;
     end;
 
%if &stoptime^=  %then %do;
  if &stoptime=. or &stoptime < 0 then do;
     error "ERROR - &stoptime= " &stoptime ' - not used.';
     &stoptime = .;
     &strttime = .;
     &event = .;
     end;
 
  if &strttime>=&stoptime then do;
     error "ERROR - &strttime>=&stoptime " ' - not used.';
     &strttime = .;
     &stoptime = .;
     &event = .;
     end;
 
  if &event > &cen_vl+1 or &event < &cen_vl then do;
     error "ERROR - &event= " &event ' - not used.';
     &strttime = .;
     &stoptime = .;
     &event = .;
     end;
   %end;
 
 
PROC SORT data=_tmp_; BY  &by &class &stoptime ;
PROC MEANS NOPRINT DATA=_TMP_; VAR  &stoptime ; &byclword &by &class;
    OUTPUT OUT=_COUNTS_ N=nrisk max=maxtime nmiss=tl_miss;
 
data _arrive_;
   set _tmp_;
   keep &by &class &stoptime arrival;
   &stoptime=&strttime;
   arrival=1;
data _tmp_;
   set _tmp_ _arrive_;
proc sort;  by &by &class &stoptime;
 
%IF &POINTS^=  %THEN %DO;
   data _TMP1_;    /*  add point observations  */
       set _COUNTS_;
       keep &by &class &stoptime  &event point narr;
       flag=0;
       do j=&points;
         if flag=1 then return;
         if j>=maxtime then flag=1;
         if j>0 then do;
             &stoptime  = j;
            &event = .;
            point = 1;
            output;
            end;
         end;
 
   data _TMP_;  set _TMP_ _TMP1_;
   proc sort;  by &BY &CLASS  &stoptime ;
   %END;
 
 
DATA &OUT (KEEP=&by &CLASS  &stoptime nrisk nevent ncensor narrive
             cum_ev cum_cen cum_arr
             pt pe upper_cl lower_cl se pointflg)
     &outsum (keep=&by &class total cum_ev cum_cen cum_arr median
              tl_miss)
     _print_ (keep=&by &class  &stoptime  years nrisk nevent pt
              ncensor narrive
              lower_cl upper_cl se cum_ev cum_cen cum_arr);
  SET _TMP_ nobs=nobs; BY &by &class  &stoptime ;
   RETAIN pt nevent _kt_ ncensor nrisk narrive _sv1_ cum_ev cum_cen
      total median firstmed pointflg laster loweradj cum_arr oldpt;
   LABEL pt="Kaplan-Meier Survival Estimate"
      pe = "1-P(t)"
      se="Greenwold Standard Error"
      lower_cl  ="Lower Confidence Limit"
      upper_cl  ="Upper Confidence Limit"
      NRISK="Number at Risk at beginning of (t)"
      NEVENT="Number of Events at (t)"
 
ncensor="Number Censored at (t)"
      narrive="Number of Arrivals at (t)"
      cum_ev = "Cumulative events including (t)"
      cum_cen = "Cumulative censors including (t)"
      cum_arr = "Cumulative arrivals including (t)"
      median = "Median Survival"
      tl_miss = "Total Missing"
      pointflg = "Added Times"
      ;
 
   _FT_=FIRST. &stoptime ;
   _LT_=LAST. &stoptime ;
 
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
 
   total = nrisk;
   nrisk=0;
   _thold_= &stoptime;
   laster=nrisk;
   pointflg=.;
   &stoptime =0;
   nevent=0;
   _kt_=0;
   ncensor=0;
   narrive=0;
   cum_ev=0;
   cum_cen=0;
   cum_arr=0;
   pt=1;
   oldpt = pt;
   pe=0;
   se=0;
   _sv1_=0;
   lower_cl=1;
   upper_cl=1;
   loweradj=.;
   years=0;
   OUTPUT &out;        /*  output an observation at time=0 */
   OUTPUT _print_;
    &stoptime =_THOLD_;
   median=.;
   firstmed=.;
 
    /*  do for each observation in the dataset */
 
  NOTFIRST:
 
   IF _FT_ then do;    /*  do for the first obs. per time */
      nevent=0;
      _kt_=0;
      ncensor=0;
      narrive=0;
      pointflg=.;
     end;
 
   /*  for each observation */
 
   if point = 1 then pointflg = 1;
 
   if point ^= 1 and arrival^=1 and  &stoptime  ^= . then do;
      if &event = &cen_vl+1 then NEVENT=NEVENT+1;
        else ncensor=ncensor+1;
      _KT_=_KT_+1;
      end;
   if arrival=1 then narrive = narrive + 1;
 
   IF _LT_ then do;     /* do for the last observation per time */
 
     if _kt_ = 0 and pointflg ^= 1 and narrive=0 then go to next3;
 
                         /* if time< mintime  */
     if &stoptime < &mintime then go to next3;
 
     if nrisk>0 then pt=pt*(1-NEVENT/NRISK);
            else pt=oldpt;
     oldpt = pt;
     pe = 1 - pt;
     cum_ev = cum_ev + nevent;
     cum_cen = cum_cen + ncensor;
     cum_arr = cum_arr + narrive;
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
 
     years = round( &stoptime /365,0.01);
      %if &printop = 2 %then %do;
          if nevent > 0 then output _print_;
          %end;
      %if &printop = 3 %then %do;
          if nevent > 0  or ncensor > 0  or narrive > 0 then
             output _print_;
          %end;
      %if &printop = 4 %then %do;
          if pointflg = 1 then output _print_;
          if  &stoptime =0 and (nevent>0 or ncensor>0) then
              output _print_;
          %end;
      %if &printop = 5 %then %do;
          if nevent > 0  or pointflg = 1 then output _print_;
          %end;
      %if &printop = 6 %then %do;
          output _print_;
          %end;
 
     next3:
     NRISK=NRISK-_KT_;
     nrisk=nrisk+narrive;
 
     if _kt_ = 0  or pt=. or &stoptime<&mintime then go to next4;
     if ABS(pt-0.5)<=0.00001 then do;
        if firstmed = . then firstmed =  &stoptime ;
        end;
     if median=. and round(pt,0.00001) < 0.5  THEN DO;
        if firstmed ^=. then
             %if &medtype=1 %then  %do;
                median = ( &stoptime  + firstmed)/2.0;
                %end;
             %if &medtype=2 %then %do;
                 median = firstmed;
                 %end;
           else median =  &stoptime ;
        end;
 
     next4:                             /*  output summary data */
     %IF &lastbycl^=  %THEN %DO;
        IF LAST.&lastbycl=1 THEN output &outsum;
        %END;
       %ELSE %DO;
         IF _N_=nobs THEN output &outsum;
         %END;
 
     end;
run;
 
%if &printop = 0 %then %goto plots;
 
proc print data=&outsum split='*'; &byword &by;
   id  &class;
   var total cum_ev cum_cen cum_arr  tl_miss median;
   label total = Total*N
         tl_miss = Total*Missing
         cum_ev = Total*Events
         cum_cen = Total*Censors
         cum_arr = Total*Arrivals
         median = Median*Survival
        ;
   sum total cum_ev cum_cen tl_miss;
title&t
 "Survival Summary Table for Variables < &stoptime > and <&event>";
   title&u "With Arrivals  - Calculations starting at t(&mintime)";
 
footnote1 "Input Parameters (STRTTIME=&strttime,STOPTIME=&stoptime,"
        "EVENT=&event,CEN_VL=&cen_vl,"
        "PRINTOP=&printop,CLASS=&class,BY=&by,";
footnote2 "DATA=&data,OUT=&out,"
        " POINTS=&points,CL=&cl,ALPHA=&alpha,";
footnote3 "PLOTTYPE=&plottype,PLOTOP=&plotop,SCALE=&scale,MAXTIME="
             "&maxtime,XDIVISOR=&xdivisor,LASERPRT=&laserprt,"
             "MEDTYPE=&medtype,OUTSUM=&outsum,MINTIME=&mintime)";
  run;
 
 
%if &printop = 1 %then %goto plots;
 
data _NUll_;
         y=put(100-&alpha*100,2.);
        call symput('percent',y);
 
 
 footnote1;
 footnote2;
 footnote3;
 
proc print data=_print_ split='*';  &byclword &by &class;
        id  &stoptime  years;
   %if &printop = 2 %then %do;
        var nrisk nevent pt lower_cl upper_cl se;
        sum nevent;
        %end;
   %if &printop = 3 %then %do;
        var nrisk narrive nevent ncensor pt lower_cl upper_cl se;
        sum narrive nevent ncensor;
        %end;
   %if &printop = 4 %then %do;
        var nrisk cum_arr cum_ev cum_cen pt lower_cl upper_cl se;
        %end;
   %if &printop = 5 %then %do;
        var nrisk nevent pt lower_cl upper_cl se;
        sum nevent;
        %end;
   %if &printop = 6 %then %do;
        var nrisk narrive nevent ncensor pt lower_cl upper_cl se;
        sum narrive nevent ncensor;
        %end;
        format pt lower_cl upper_cl se 5.3;
        label &stoptime  = * &stoptime *(t)
              years = * &stoptime *'/365'
              nrisk = Number*'at Risk'*'at (t)'
              cum_ev = Cumulative*'# Events'*'<= (t)'
              narrive = Number*'Arrivals'*'at (t)'
              cum_arr = Cumulative*'# Arrivals'*'<= (t)'
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
title&t
  "Kaplan-Meier Survival Estimates for < &stoptime > and <&event>";
   title&u "With Arrivals  - Calculations starting at t(&mintime)";
       run;
 
 
    /*  plotting  */
 
%plots:
title&t;
title&u;
 
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
      &stoptime = &stoptime /&xdivisor;
  %let indata = _tmp_;
  %end;
 
data _tmp_;  set &indata;   &byword &by;
   keep &by x y symbol;
   retain maxt xtick ytick oldx oldy;
   if pt=. then delete;
 
   label x = " &stoptime ";
   label y = 'Percent';
 
   %if &xdivisor ^=  %then %do;
       label x = " &stoptime /&xdivisor";
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
   if oldx ^=. and oldx >  &stoptime   then do;
                          /*  first obs for next class */
        oldx=.;
        oldy=.;
        go to next5;
        end;
 
   if  &stoptime >0 and nevent=0 and ncensor=0 then return;
 
   /*  horizonal dots */
 
   do i=oldx to  &stoptime -xtick by xtick while (i<=maxt);
        if i^=oldx then do;
           x=i;
           y=oldy;
           output;
           end;
        end;
 
    if oldy^=pt and  &stoptime <=maxt then do i=oldy to pt by -ytick;
           x= &stoptime ;
           y=i;
           output;
        end;
 
   next5:
   x= &stoptime ;
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
   footnote1 "TIME= &stoptime, EVENT=&event, CLASS=&class - "
           "With Arrivals  - Calculations starting at t(&mintime)";
 
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
 
      if  &stoptime =0 then do;
        lastx=.;
        lastpt=.;
        end;
 
      if  &stoptime >0 and nevent=0 and ncensor=0 then delete;
 
      %if &maxtime^=  %then %do;
         if  &stoptime >&maxtime then do;
           if lastx=1 then delete;
             else do;
              lastx=1;
               &stoptime =&maxtime;
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
       label x = " &stoptime /&xdivisor";
       x =  &stoptime /&xdivisor;
       %end;
     %else %do;
      label x = " &stoptime ";
      x= &stoptime ;
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
   footnote1 "TIME= &stoptime, EVENT=&event, CLASS=&class - "
           "With Arrivals  - Calculations starting at t(&mintime)";
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
 
%let SYSDEVIC = &dev;
 
%MEND SURVTD;
 
 
 
 

