  /*------------------------------------------------------------------*
   | MACRO NAME  : criskcox
   | SHORT DESC  : Competing risk survival analysis with covariates
   *------------------------------------------------------------------*
   | CREATED BY  : Therneau, Terry               (03/25/2004 13:36)
   |             : Bergstralh, Erik
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Competing RISK survival analysis with covariates(COX).
   | Date:       5/7/1999
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Kremers, Walter               (03/09/2009 16:48)
   |             : Therneau, Terry
   |             : Bergstralh, Eric
   |
   | Revised to accept up to 20 different event types.
   | Output dataset is revised extensively.  See archived versions if you
   | need to rerun for an older project.
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
   | %criskcox(
   |            data= ,
   |            time= ,
   |            event= ,
   |            xvars= ,
   |            start= ,
   |            strata= ,
   |            pdata=_pdata,
   |            out=_crskcox,
   |            outdata= ,
   |            print1=Y,
   |            print2=Y,
   |            print= ,
   |            method=PL,
   |            ties=efron
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : SAS data set to use for competing risk analysis
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : follow-up time to event, pts can have only one
   |             event as defined below. Time must be >=0.
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : 0 if no event
   |             1 if event of type 1, typically event of interest
   |             2 if event of type 2, competing risk
   |             3 if event of type 3, competing risk
   |
   | Name      : xvars
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : list of x variables for Cox model
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : start
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : start follow-up time to event, pts can have only one event as defined
   |             below.  Required for start/stop intervals.  Leave blank for
   |             right-censored data.  If used, time intervals must be > 0.
   |
   | Name      : strata
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : stratification variable
   |
   | Name      : pdata
   | Default   : _pdata
   | Type      : Dataset Name
   | Purpose   : SAS data set containing one row for each set of
   |             "xvars" on which predicted curves are desired
   |             Default is _pdata which is within from the program and includes
   |             all combinations of XVARS in input dataset.
   |
   | Name      : out
   | Default   : _crskcox
   | Type      : Dataset Name
   | Purpose   : name of output dataset
   |             Data set contains cumulative incidence estimates for
   |             specified covariates (using pdata) for each event type.
   |             Number obs='rows of pdata' x 'unique event times' x 'number of strata'
   |             in input dataset.
   |
   | Name      : outdata
   | Default   :
   | Type      : Dataset Name
   | Purpose   : name of output dataset.  This parameter is kept to assure backward
   |             compatibility.  Use of OUT parameter is preferred.
   |
   | Name      : print1
   | Default   : Y
   | Type      : Text
   | Purpose   : N to suppress or Y to print Cox Regression results for individual
   |             parameters.
   |
   | Name      : print2
   | Default   : Y
   | Type      : Text
   | Purpose   : N to suppress or Y to print estimates of incidences for levels
   |             specified in PDATA
   |
   | Name      : print
   | Default   :
   | Type      : Text
   | Purpose   : N to suppress printout of all results, Y to
   |             force printout of all results. If missing, printing is determined by
   |             print1 and print2. Kept to assure backwards compatibilty with older
   |             macro versions.
   |
   | Name      : method
   | Default   : PL
   | Type      : Text
   | Purpose   : method for calculating baseline survival functions
   |             PL = Product Limit
   |             CH = Cumulative Hazard
   |             For (START, STOP) time format, program uses CH method only.
   |
   | Name      : ties
   | Default   : efron
   | Type      : Text
   | Purpose   : ties option for PHReg procedure, Efron recommended
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | Data set containing cumulative incidence estimates for
   | specified covariates for each event type.
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | Located at bottom of code.
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Reference: Cheng SC,Fine JB,Wei LJ. Prediction of cumulative
   | incidence function under the proportional hazards model. Biometrics
   | 54, 219-228, 1998.
   |
   *------------------------------------------------------------------*
   | Copyright 2009 Mayo Clinic College of Medicine.
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
 
%macro criskcox(data=, start=, time=, event=, xvars=, strata=,
                pdata=, out=_crskcox, print=, print1=Y, print2=Y,
                method=PL, ties=efron, outdata=);
 
 
/* Check for usernamed output dataset */
 %IF (&out^=_crskcox ) & (&out^= ) & (&outdata^= ) &
         (%UPCASE(&out)^=%UPCASE(&outdata)) %THEN %PUT
 "WARNING: Different output data sets were identified by the OUT and
OUTDATA input parameters. &out (OUT) will be used.";
 
/* If &OUTDATA is entered and &OUT is _crskcox, then use &OUTDATA  */
 %IF ((&out=_crskcox ) or (&out= )) & (&outdata^= )
    %THEN %LET out=&outdata;
 
 
  ** Make a data set of the current footnotes *****;
%local F FNEW totalf fshow nxf1 nxf2
       footnote1 footnote2 footnote3 footnote4 footnote5
       footnote6 footnote7 footnote8 footnote9 footnote10;
 
  proc sql ;
    create table work._f as select * from dictionary.titles
       where type='F';
    reset noprint;
   quit;
  ** How many footnotes are being used? *****;
  proc sql;
     reset noprint;
     select nobs into :F from dictionary.tables
     where libname="WORK" & memname="_F";
   quit;
 
  **  Store footnotes in macro variables *****;
  %LET FOOTNOTE1= ; /* Initialize at least one footnote */
  data _null_;
    set _f;
    %IF (&F>=1) %THEN %DO I=1 %TO &F;
       if number=&I then call symput("FOOTNOTE&I", trim(left(text)));
       %END;
   run;
 
  ***  How many current footnotes can still be displayed? *****;
%LET FNEW = 3;
%LET TOTALF = %EVAL(&F + &FNEW);
%IF &TOTALF<=10 %THEN %LET FSHOW=&F;
   %ELSE %LET FSHOW = %EVAL(10 - &TOTALF + &F);
%LET NXF1=%EVAL(&FSHOW+1);
%LET NXF2=%EVAL(&FSHOW+2);
 
 
 
 footnote&nxf1 "Criskcox macro: data=&data "
    %if (&start ^= ) %then "start=&start " ; "time=&time
    event=&event xvars=&xvars" ;
 
 
 %if (&print > ) %then %do;
   %let print= %upcase(%substr(&print,1,1));
 
   %if (&print = N) %then %do ; %let print1 = N; %let print2 = N ; %end;
   %else
   %if (&print = Y) %then %do ; %let print1 = Y; %let print2 = Y ; %end;
 
 %end;
 
 %let print1= %upcase(%substr(&print1,1,1));
 %let print2= %upcase(%substr(&print2,1,1));
 
 
 %local type nxs i nlev i_ j_ comm_ errflag_;
 
 %let method = %upcase(&method) ;
 %if ((&method ^= CH) & (&method ^= PL)) %then %let method = CH ;
 %if (&start ^= ) %then %do ;
  %let method = CH ;
  %put ;
  %put %str(Warning: For Time Dependent Covariates SAS only calculates);
  %put %str(         baseline survival function using the CH method.  );
  %put ;
  %end ;
 
 **count the number of x vars ;
 %let nxs=0 ;
 %do i=1 %to 51 ;
   %if %scan(&xvars,&i)= & &i<=50 %then %goto done ;
   %if &i=51 %then %do; %put '> 50 x variables'; %goto exit ; %end;
   %let nxs=%eval(&nxs+1) ;
 %end ;
 %done: %put Number of predictors is &nxs;
 
 %if (&strata ^= ) %then %do ;
 proc contents data=&data out=_out01 noprint ;
 data _null_ ;
   set _out01 ;
   if (upcase(name) = "%upcase(&strata)") then
         call symput('type',trim(left(put(type,2.)))) ;
 run ;
 %put strata type = &type ;
  %end ;
 
 **remove bad event, start & time data, missing Xs ;
 data _one ;
   set &data ;
   keep evt %if (&start ^= ) %then start ; time &strata &xvars;
   evt=&event;
   %if (&start ^= ) %then %do ; start = &start ; %end ;
   time = &time ;
  ** omit records with negative times **;
   if (evt >= 0
      %if (&start ^= ) %then & (start >= 0) ; & (time > 0)) ;
   xmiss = 0 ;
   ** omit records with missing strata **;
   %if (&strata ^= ) %then %do;
     %if (&type = 1) %then %do; if (&strata = .) then xmiss = 1; %end;
     %if (&type = 2) %then %do; if (&strata = ' ') then xmiss = 1; %end;
     %end ;
   ** omit records with missing Xs;
   %do i=1 %to &nxs ;
     xx=%scan(&xvars,&i) ;
     if xx=. then xmiss=1 ;
     %end ;
   if xmiss=1 then delete ;
 
 ** get number of competing risks **;
 proc sort data=_one ;
   by evt ;
 %let errflag_=0;
 %let comm_=   ;
 data _null_ ;
   set _one end=eod ;
   by evt ;
   retain count_ ;
   if _n_=1 and evt in(0,1) then count_=evt;
    else if first.evt then count_ = count_ + 1 ;
   if eod then call symput('nlev',trim(left(put(count_,4.)))) ;
   if count_ ^= evt then do; call symput('errflag_','1');
     call symput('comm_',
      'Event types are not consecutive integers.');
     end;
   if count_ >20 then do; call symput('errflag_','1');
     call symput('comm_',
       'More than 20 competing risks -- check your event definition.');
     end;
 run ;
 %put Number of competing risks = &nlev ;
 %if ((&errflag_ =1) or (&nlev>20)) %then %do;
   %put &comm_ Macro will not execute.;
   %goto exit;
   %end;
 
 ***** if pdata not specified derive data set      *****;
 ***** with unique covariates in analysis data set *****;
 %if (&pdata = )%then %do ;
   %let pdata=_pdata ;
   proc sort data=_one out=_pdata ;
     by &xvars ;
   data _pdata ;
     set _pdata ;
     by &xvars ;
     if first.%scan(&xvars,&nxs) ;
   %end ;
 
 ******************************************************************;
 
 **** Overall survival estimates using method=&method *************;
 **** NOT used for calculations may serve for data inspection *****;
 proc phreg data=_one %if &print1^=Y %then %do; noprint %end ; ;
   model %if (&start ^= ) %then (start, time) * ;
         %else time * ; evt(0)=&xvars
         / %if (&ties ^= ) %then ties = &ties ; ;
   %if (&strata ^= ) %then strata &strata ; ;
   baseline covariates=&pdata out=_any survival=S_any
           / nomean method=&method ;
 
 **** Survival Cause Specific (SCS) estimates using method=&method ***;
 **** USED for derivation of crude cumulative incidences *****;
 %do i_ = 1 %to &nlev ;
   **** Cox for event type &i_ ;
   proc phreg data=_one %if &print1^=Y %then %do; noprint %end ; ;
     model %if (&start ^= ) %then (start, time) * ;
           %else time * ;
           evt(0 %do j_ = 1 %to &nlev ; %if &i_ ^= &j_ %then , &j_ ;
           %end ; )
           = &xvars / %if (&ties ^= ) %then ties = &ties ; ;
     %if (&strata ^= ) %then strata &strata ; ;
     baseline covariates=&pdata out=_cs&i_ survival=scs&i_
             / nomean method=&method ;
   %end ;
 
 ***************************************************************;
 
 proc sort data=_any ;  by &strata &xvars time ;
 %do i_ = 1 %to &nlev ;
   proc sort data=_cs&i_ ;  by &strata &xvars time ;
   %end ;
 
 ** merge output datasets, each has 1 obs/event time ;
 ** results in different n in each file ;
 ** carry forward LAST values of scs&i_ ;
 
 data &out ;
   merge _any %do i_ = 1 %to &nlev ; _cs&i_ %end ; ;
   by &strata &xvars time ;
   keep &strata &xvars &time s_any
        %do i_ = 1 %to &nlev ; scs&i_  %end ; ;
   retain %do i_ = 1 %to &nlev ; scs_&i_ %end ; ;
   if first.%scan(&xvars,&nxs) then do ;
     %do i_ = 1 %to &nlev ;
       scs_&i_   = scs&i_   ;
       %end ;
     end;
   %do i_ = 1 %to &nlev ;
     if (scs&i_ ne .) then scs_&i_ = scs&i_ ;
     scs&i_ = scs_&i_ ;
     %end ;
   &time=time;
 
*======================================================================;
*--- get Crude (cumulative) Incidence (CI) ----------------------------;
 
 data &out ;
   set &out ;
   by &strata &xvars ;
   retain sall %do i_ = 1 %to &nlev ; ci&i_ %end ; ;
 
   if first.%scan(&xvars,&nxs) then do ;
     sall = 1 ;
     %do i_ = 1 %to &nlev ;  ci&i_ = 0 ;  %end ;
     end;
 
   %do i_ = 1 %to &nlev ;  lg_scs&i_ = lag(scs&i_  ) ;  %end ;
 
   if first.%scan(&xvars,&nxs) then do ;
     %do i_ = 1 %to &nlev ;  lg_scs&i_ = 1 ;  %end ;
     end;
 
   ***** overall survival & change in overall,  ***;
   ***** making some account for ties         *****;
   * get changes in CI - if S = 0 then assessing change of 0 ;
   %do i_ = 1 %to &nlev ;
     if (lg_scs&i_ <= 0) then dci&i_ = 0 ;
     else dci&i_ = sall*(1-scs&i_/lg_scs&i_) ;
     %end ;
 
   * Delta CI for all causes together ;
   dci_sum = dci1 %do i_ = 2 %to &nlev ; + dci&i_ %end ; ;
   * Note, this is open to debate. ;
   * One can also argue the overall survival should be the product of  ;
   * the individual survivals,  However, if ties are real the sum of   ;
   * the individual dcis should apply.  If continuous then overall     ;
   * survival should be derived for different possible sequences of    ;
   * events and this involves reduced set for second event ;
   * e.g. if SA = SB2 = 9/10 for a time point then :       ;
   * P(survive) = (9/10) * (8/9)                           ;
   * alternately consider the analogue to the Flemming-Harrington      ;
   * estimate (Thernaeau & Grambsch p.267). If all of n elements have  ;
   * same risk then for 2 events the incremental term in the estimate  ;
   * for baseline cumulative hazard is not 1/n + 1/n but (1/n + 1/(n-1))
   * which again is analogous to what one would observe in the case of ;
   * two subesquent events ;
 
   * this next bit of code is only expeceted to apply for extreme  ;
   * covarites where approximations may be too large of CI ;
   if (dci_sum > sall) then do ;
     %do i_ = 1 %to &nlev ;
       dci&i_ = dci&i_ * sall / dci_sum ;
       %end ;
     dci_sum = dci1 %do i_ = 2 %to &nlev ; + dci&i_ %end ; ;
     end ;
 
   * update ci&i_ *********;
   %do i_ = 1 %to &nlev ;
     ci&i_ = ci&i_ + dci&i_ ;
     %end ;
 
   sall = sall - dci_sum ;
  * sall may be < 0 only due to rounding error ;
 
   if (sall < 0) then sall = 0 ;    ci_sum  = 1 - sall ;
 
   label s_any    = "Naive Surv Any Risk &method"
         sall     = "Model Surv All Risk (&method)"
         ci_sum   = "Sum Crude Cum Inc"
         dci_sum  = "Delta Sum Cum Inc &method"
         %do i_ = 1 %to &nlev ;
           scs&i_ = "Surv Cause Spec &i_"
           ci&i_  = "Crude Cum Inc &i_"
           dci&i_ = "Delta Crude Cum Inc &i_"
           %end ; ;
 
 
 
    drop %do i_ = 1 %to &nlev ;  lg_scs&i_  %end ;;
    format s_any sall dci_sum ci_sum
          %do i_ = 1 %to &nlev ; scs&i_ dci&i_ ci&i_ %end ; 6.4 ;
run ;
*======================================================================;
*---- print crude cumulative incidences -------------------------------;
 
%if ((&print2 = Y) | (&print2 = B) | (&print2 = T) | (&print2 = L))
  %then %do;
  proc print data=&out label ;
    by &strata &xvars ;
    id &strata &xvars &time ;
    var s_any
        %do i_ = 1 %to &nlev ; scs&i_ %end ; sall
        %do i_ = 1 %to &nlev ; ci&i_  %end ; ci_sum ;
    footnote&nxf2
     "Competing Risks Crude Cumulative Incidences (method=&method)" ;
  %end ;
run ; footnote&nxf1 ;
 
proc datasets lib=work nofs;
  delete  _ONE _PDATA _ANY _f
         %do i_ = 1 %to &nlev ; _CS&i_  %end;
         %if (&strata ^= ) %then %do ; _out01 %end;;
run; quit;
 
 
%exit:
 
%IF (&F>=1) %THEN %DO I=1 %TO &F;
   footnote&i "&&footnote&I";
  %END;
 
 
%mend criskcox;
 
 
***********************************************************************;
***** Example Calls                                               *****;
***********************************************************************;
 
 /*
data one ;
  input obs t evt z;
  all=1 ;
  cards ;
1 2 1 0
2 3 0 0
3 4 1 0
4 5 2 0
5 6 0 0
6 7 2 0
7 8 0 0
8 9 0 0
9 10 0 0
10 11 0 0
11 1  1 1
12 2  2 1
13 3  1 1
14 4  2 1
15 5  1 1
16 6  1 1
17 7  0 1
18 8  2 1
19 9  0 1
20 10 0 1
run;
 
data two ;
  input obs t evt z;
  all=1 ;
  cards ;
1 1 1 0
2 2 1 0
3 3 0 0
4 4 2 0
5 5 1 0
6 6 2 0
7 7 0 0
8 8 1 0
9 9 0 0
10 10 0 0
11 1  0 1
12 2  0 1
13 3  1 1
14 4  0 1
15 5  0 1
16 6  0 1
17 7  1 1
18 8  0 1
19 9  2 1
20 10 0 1
run ;
 
data fiv ;
  input obs t_ evt z_ ;
  all=1 ;
cards ;
1 2 1 0
2 3 0 0
3 4 1 0
4 5 1 0
5 6 0 0
6 7 1 0
7 8 0 0
8 9 0 0
9 10 0 0
10 11 1 0
10 12 1 0
10 13 0 0
11 1  1 1
12 2  0 1
13 3  1 1
14 4  1 1
15 5  1 1
16 6  1 1
17 7  0 1
18 8  1 1
19 9  0 1
20 11 1 1
21 11 1 1
22 12 1 1
23 13 1 1
24 14 1 1
25 15 1 1
26 16 1 1
run ;
 
data onex ; set one ; if (t > 10.5) then evt = 1 ;
 
data pred ; **define z0 ;
  z=0  ; output ;
  z=0.3; *output ;
  z=0.6; output ;
  z=1  ; output ;
data pred2 ; all=1 ; output ; run ;
 
data predfiv ;
  z_ = 0  ; output ;
  z_ = 1  ; output ;
run ;
  */;
 
  /*
options mprint ps=56 ls=132;
options mprint ps=50 ls=132;
title1 "Data set one--tied events of different types";
proc print data=one; run ;
%criskcox(data=one,pdata=pred,time=t,event=evt,
           xvars=z, print1=N, print2=L);
title2 "Longest obs time with event" ;
%criskcox(data=onex,pdata=pred,time=t,event=evt,
           xvars=z, print1=N, print2=L);
 
title "Data set two---no ties of any type";
proc print data=two;
%criskcox(data=two,pdata=pred,time=t,event=evt,
           xvars=z, print1=N, print2=L) ;
*%comprisk(data=two,time=t,event=evt,print=Y) ;
options nomprint ;
  */
 
  /*
** example of plots from macro output **;
title1 "Data set one" ;
%criskcox(data=one,pdata=pred,time=t,event=evt,
           xvars=z, print1=N, print2=L);
 symbol1 i=steplj v=none l=1;
 symbol2 i=steplj v=none l=2;
 symbol3 i=steplj v=none l=5;
 symbol4 i=steplj v=none l=7;
 
 proc gplot data=_crskcox ;
   by z ;
   plot ci_sum*time=1 ci1*time=2 ci2*time=3
        / overlay vaxis=0 to 1 by .2 haxis=0 to 12 by 2 ;
 run ; quit ;
 
 proc gplot data=_crskcox ;
   plot sall*time=z scs1*time=z scs2*time=z
       / vaxis=0 to 1 by .2 haxis=0 to 12 by 2 ;
 run ; quit ;
options ls=80 ps=56 ;
  */;
 
  /*
options mprint ps=56 ls=132;
title1 "Data Set one" ;
title2
 "In presence of ties naive ovarall survival may not be same as sum CIs";
%criskcox(data=one,pdata=pred,time=t,event=evt,
           xvars=z, print1=N, print2=L);
data onea ;
    set one ;
    if (evt = 1) then t = t+0.00 ;
    if (evt = 2) then t = t+0.01 ;
    if (evt = 0) then t = t+0.02 ;
title1 "Data Set onea" ;
title2 "Even in absence of ties naive ovarall survival may not be same";
title3 "as sum CIs due to imbalance of different underlying risks";
title4 "through time and different effects of predictors on HRs" ;
%criskcox(data=onea,pdata=pred,time=t,event=evt,
           xvars=z, print1=Y, print2=L);
*%comprisk(data=onea,time=t,event=evt,group=all,print=Y);
options ls=80 ps=56 ;
title1 ;
  */;
 
 
 
