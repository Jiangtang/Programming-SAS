  /*------------------------------------------------------------------*
   | MACRO NAME  : schoen
   | SHORT DESC  : Returns Schoenfeld residuals (raw and scaled)
   |               from the Cox model.
   *------------------------------------------------------------------*
   | CREATED BY  : Therneau, Terry               (04/14/2004 11:50)
   |             : Bergstralh, Erik
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Function: Returns Schoenfeld residuals and scaled Schoenfeld residuals
   |           from the Cox model. The Schoenfeld residuals(r) are defined only
   |           at event times.  There is one residual for each covariate in
   |           the Cox model.  The scaled residuals(Bt) are defined as:
   |
   |                 Bt= B + D*cov(B)*r', B=cox model beta,
   |                                      D=total #events and
   |                                      r=Schoenfeld residuals.
   |
   |           Bt is an estimate of the hazard function at follow-up time t.
   |           Therefore a plot of Bt vs time can be used to assess whether
   |           the proportional hazards assumption is valid. As time is
   |           frequently skewed, plots of Bt vs rank time or '1-Kaplan-
   |           Meier' for the entire dataset(which is a monotone function of
   |           time) may be preferred.  The correlation of Bt with time
   |           provides a test of the proportional hazards assumption.
   |
   | Developers:   E. Bergstralh   and   T. Therneau
   |               Section of Biostatistics
   |               Mayo Clinic
   |               Rochester, Mn 55905
   |               e-mail:   bergstra@mayo.edu    therneau@mayo.edu
   |
   | Date:  May 6, 1993
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Lennon, Ryan                  (03/20/2009 13:59)
   |
   | Made the following changes
   | 1. Use PROC TRANSREG or PROC LOESS to fit smoothers to the plot, instead
   | of %DASPLINE and PROC GLM. User may choose between a spline or a loess
   | smoother, and may specify the degrees of freedom for the spline or the
   | smoothing parameter for the smoother. Thus, this version will not work
   | in SAS version 6.
   | 2. Added CEN_VL parameter for consistency with %SURV.
   | 3. Allow Y/N for Yes/No parameter inputs.
   | 4. Retains original titles and footnotes, instead of potentially
   | overwriting them.
   | 5. Aesthetic changes to the SAS/GRAPH output
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
   | MACRO CALL
   |
   | %schoen  (
   |            time= ,
   |            event= ,
   |            xvars= ,
   |            data=_last_,
   |            cen_vl=0,
   |            strata= ,
   |            outsch=schr,
   |            outbt=schbt,
   |            plot=r,
   |            vref=yes,
   |            points=yes,
   |            pvars= ,
   |            method=spline,
   |            df=4,
   |            smooth= ,
   |            alpha=.05,
   |            rug=no,
   |            ties=efron
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : time variable for survival
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : event variable for survival, 1=event, 0=censored
   |
   | Name      : xvars
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : list of covariates for Cox model
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : data
   | Default   : _last_
   | Type      : Dataset Name
   | Purpose   : name of analysis dataset.  Default is last dataset
   |             created.
   |
   | Name      : cen_vl
   | Default   : 0
   | Type      : Number (Range/List)
   | Purpose   : A number (or list) indicating the values of the EVENT variable which
   |             indicate right censoring.
   |
   | Name      : strata
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : stratification variable(one only) for stratifed Cox
   |             models.
   |
   | Name      : outsch
   | Default   : schr
   | Type      : Dataset Name
   | Purpose   : name of output data set containing Schoenfeld
   |             residuals.  One obs per each event time.  The
   |             variables containing the residuals have the same name
   |             as the covariates (xvars).  The data set also includes
   |             the time variable and the strata variable.
   |
   | Name      : outbt
   | Default   : schbt
   | Type      : Dataset Name
   | Purpose   : name of output data set containing the scaled
   |             Schoenfeld residuals(Bt).  One obs per each event
   |             time.  The variables containing the scaled residuals
   |             have the same name as the covariates (xvars).  The
   |             dataset also includes the time variable, the rank of
   |             the time(rtime) and a variable(probevt) which is equal
   |             to '1 - overall Kaplan-Meier' at the given time.
   |
   | Name      : plot
   | Default   : r
   | Type      : Text
   | Purpose   : t,r,k,n.  Indicates that SAS/Graph plots of Bt vs
   |             time(t), rank of time(r) or '1 - overall Kaplan-Meier'
   |             (k) are to be done.  Default is r.  For no plots use
   |             n.  The name of the graphics catalog is gschbt.
   |
   | Name      : vref
   | Default   : yes
   | Type      : Text
   | Purpose   : indicator to control plotting of a vertical reference
   |             line at y=0.  Values are yes(default) and no.
   |
   | Name      : points
   | Default   : yes
   | Type      : Text
   | Purpose   : yes,no.  Indicates whether to plot the actual data points.
   |
   | Name      : pvars
   | Default   :
   | Type      : Variable Name (List)
   | Purpose   : variables to plot.  Default is all xzvars.
   |
   | Name      : method
   | Default   : spline
   | Type      : Text
   | Purpose   : Choose which method will be used to plot a smoother on the residual
   |             plot. Options are SPLINE or LOESS.
   |
   | Name      : df
   | Default   : 4
   | Type      : Number (Single)
   | Purpose   : degrees of freedom for smoothing process  Possible
   |             values are 3 - 7.
   |
   | Name      : smooth
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Choose the smoothing parameter for the LOESS smoother. Values may be
   |             in the interval (0,1]. If no value is given, SAS determines the "best"
   |             smoothing parameter. See the PROC LOESS documentation for more
   |             information.
   |
   | Name      : alpha
   | Default   : .05
   | Type      : Number (Single)
   | Purpose   : confidence coefficient for plotting standard
   |             error bars.  Default is .05. A value of 0 means
   |             do not plot SE bars.
   |
   | Name      : rug
   | Default   : no
   | Type      : Text
   | Purpose   : indicator to control plotting of rug of x values.
   |             Values are yes and no(default).
   |
   | Name      : ties
   | Default   : efron
   | Type      : Text
   | Purpose   : method used to break ties in phreg. Values are
   |             efron(default), breslow, discrete, exact.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | The macro prints the PHREG output used to fit the Cox model,
   | correlation coefficients of Bt vs time and SAS/Graph plots of
   | Bt vs time.
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Schoenfeld, D. (1982). Partial residuals for the proportional
   | hazards regression model.  Biometrika 69, 239-41.
   |
   | Grambsch PM, Therneau TM (1993).  Proportional hazards tests
   | and diagnostics based on weighted residuals.  University of
   | Minnesota, Division of Biostatistics. Research Report 93-002.
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
 
%macro schoen(data=_last_,time=,event=,xvars=,cen_vl=0,vref=yes,
              strata=,outsch=schr,outbt=schbt,plot=r,points=yes,
              pvars=,method=spline, df=4, smooth=,
              alpha=.05,rug=no,ties=efron);
 
 
%LOCAL BAD BADALPHA DOALPHA BADSMOOTH NXS PLOTVARS NPLOTVAR PV FOUND
       FNEW I J TOTALF FSHOW NEXTF1 NEXTF2 TNEW TOTALT TSHOW THISX X
       NEXTT1 SMPAR;
 
   %let bad=0;
   %if &time= %then %do;
      %put ERROR: NO TIME VARIABLE GIVEN.;
      %let bad=1;
   %end;
   %if &event= %then %do;
      %put ERROR: NO EVENT VARIABLE GIVEN.;
      %let bad=1;
   %end;
   %if &xvars= %then %do;
      %put ERROR: NO XVARS GIVEN.;
      %let bad=1;
   %end;
   %if &cen_vl= %then %do;
      %put ERROR: NO CENSORING VALUE GIVEN.;
      %let bad=1;
   %end;
   %if %upcase(&METHOD)=LOWESS %THEN %LET METHOD=LOESS;
   %if %upcase(&METHOD)^=LOESS & %upcase(&METHOD)^=SPLINE %then %do;
      %put ERROR: METHOD MUST BE EITHER SPLINE OR LOESS;
      %let bad=1;
    %end;
   %if &df<3 | &df>7 %then %do;
      %put ERROR: DF MUST BE BETWEEN 3 AND 7.;
      %let bad=1;
   %end;
   %if %upcase(&points)^=YES & %upcase(&points)^=NO
     & %upcase(&points)^=Y & %upcase(&points)^=N %then %do;
      %put ERROR: POINTS MUST BE YES, Y, NO or N.;
      %let bad=1;
   %end;
   %IF  %upcase(&points)=Y %then %LET POINTS=YES;
   %if %upcase(&rug)^=YES & %upcase(&rug)^=NO
      & %upcase(&rug)^=Y & %upcase(&rug)^=N %then %do;
      %put ERROR: RUG MUST BE YES, Y, NO or N.;
      %let bad=1;
   %end;
   %IF  %upcase(&rug)=Y %then %LET RUG=YES;
   %if %upcase(&vref)^=YES & %upcase(&vref)^=NO
       & %upcase(&vref)^=Y & %upcase(&vref)^=N %then %do;
      %put ERROR: VREF MUST BE YES, Y, NO or N.;
      %let bad=1;
   %end;
   %if %upcase(&plot)^=T & %upcase(&plot)^=R & %upcase(&plot)^=K &
    %upcase(&plot)^=N %then %do;
      %put ERROR: PLOT MUST BE T, R, K, OR N.;
      %let bad=1;
   %end;
   %if %upcase(&ties)^=EFRON & %upcase(&ties)^=BRESLOW
   & %upcase(&ties)^=DISCRETE & %upcase(&ties)^=EXACT %then %do;
      %put ERROR: TIES MUST BE EFRON, BRESLOW, DISCRETE, EXACT.;
      %let bad=1;
   %end;
   %let badalpha=0;
   %let badsmooth=0;
   data _null_;
      a=symget('alpha');
      if a<0 | a>=1 then call symput('badalpha',1);
      if a=0 then doalpha=0;
      else doalpha=1;
      call symput('doalpha',doalpha);
      s=symget('smooth');
      if .<s<=0 | s>1 then call symput('badsmooth', 1);
   run;
   %if &badalpha=1 %then %do;
      %put ERROR: ALPHA MUST BE BETWEEN 0 AND 1;
      %let bad=1;
   %end;
   %if &badsmooth=1 %then %do;
      %put ERROR: SMOOTH MUST BE IN (0,1];
      %let bad=1;
    %end;
   %if %upcase(&METHOD)=SPLINE & (&SMOOTH^=) & &BADSMOOTH=0 %THEN %do;
       %put WARNING: METHOD=SPLINE - SMOOTH parameter is ignored.;
     %end;
 
 
   %let nxs=0;              %*count the number of x vars;
   %do %until(%scan(&xvars,&nxs+1,' ')= );
      %let nxs=%eval(&nxs+1);
   %end;
   %if &pvars^= %then %let plotvars=&pvars;
   %else %let plotvars=&xvars;
   %let nplotvar=0;
   %do %until(%scan(&plotvars,&nplotvar+1,' ')= );
      %let nplotvar=%eval(&nplotvar+1);
   %end;
   %do i=1 %to &nplotvar;
      %let pv=%scan(&plotvars,&i,' ');
      %let found=0;
      %do j=1 %to &nxs;
         %if &pv=%scan(&xvars,&j,' ') %then %let found=1;
      %end;
      %if &found=0 %then %do;
         %put ERROR: PLOT VARIABLE &PV NOT ON XVARS LIST.;
         %let bad=1;
      %end;
   %end;
 
   %DO I=1 %TO &NXS; %LOCAL EST&I;  %END;
 
 
   %if &bad=0 %then %do;
     proc sql ;
       create table work._f as select * from dictionary.titles
          where type='F';
       reset noprint;
       quit;
     proc sql;
        reset noprint;
        select nobs into :F from dictionary.tables
        where libname="WORK" & memname="_F";
       quit;
     %LET FOOTNOTE1= ; /* Initialize at least one footnote */
     data _null_;
       set _f;
       %IF (&F>=1) %THEN %DO I=1 %TO &F;
          %LOCAL FOOTNOTE&I;
          if number=&I then call symput("FOOTNOTE&I", trim(left(text)));
          %END;
      run;
     %IF (&F>=1) %THEN %DO I=1 %TO &F;
     footnote&I h=2pct "&&FOOTNOTE&I";
     %END;
     %LET FNEW = 2;
     %LET TOTALF = %EVAL(&F + &FNEW);
     %IF &TOTALF<=10 %THEN %LET FSHOW=&F;
        %ELSE %LET FSHOW = %EVAL(10 - &TOTALF + &F);
     %LET NEXTF1=%EVAL(&FSHOW+1);
     %LET NEXTF2=%EVAL(&FSHOW+2);
     footnote&NEXTF1 h=2pct f=swiss
        "schoen macro: event=&event time=&time strata=&strata";
     footnote&NEXTF2 h=2pct f=swiss
        "Xvars= &xvars";
 
     proc sql ;
       create table work._t as select * from dictionary.titles
          where type='T';
       reset noprint;
      quit;
     proc sql;
        reset noprint;
        select nobs into :T from dictionary.tables
        where libname="WORK" & memname="_T";
      quit;
 
     %LET TITLE1= ; /* Initialize at least one title */
     data _null_;
       set _t;
       %IF (&T>=1) %THEN %DO I=1 %TO &T;
          %LOCAL TITLE&I;
          if number=&I then call symput("TITLE&I", trim(left(text)));
          %END;
      run;
 
     %IF (&T>=1) %THEN %DO I=1 %TO &T;
     title&I h=2pct f=swiss "&&TITLE&I";
     %END;
     %LET TNEW = 1;
     %LET TOTALT = %EVAL(&T + &TNEW);
     %IF &TOTALT<=10 %THEN %LET TSHOW=&T;
        %ELSE %LET TSHOW = %EVAL(10 - &TOTALT + &T);
 
 
 
      data _setup; set &data;         %*delete obs with mising values;
         xmiss=0;
         %do i=1 %to &nxs;
            xx=%scan(&xvars,&i);
            if xx=. then xmiss=1;
      %end;
      if &event=. or &time=. or xmiss=1 then delete;
      if &event in(&CEN_VL) then ___event=0;
         else ___event=1;
                             %* run phreg and grab output datasets;
      proc phreg data=_setup covout outest=_est ;
       model &time*___event(0)= &xvars / ties=&ties ;
       %if &strata ^= %then %do;
          strata &strata;
       %end;
       output out=_sch xbeta=xbeta ressch=rsch1-rsch&nxs
              wtressch=wrsch1-wrsch&nxs;
 
      data _sch1; set _sch(keep=&strata &time ___event rsch1-rsch&nxs);
       drop ___event;
         if ___event=1;
         rename
         %do i=1 %to &nxs;
            %let thisx=%scan(&xvars,&i,' ');
            rsch&i=&thisx
         %end;
         ;
      proc sort; by &time;
 
      data &outsch; set _sch1;
      proc sort; by &strata &time;
                                ** calculate overall Kaplan-Meier;
      proc lifetest noprint data=_setup outs=_km;
       time &time*___event(0);
      data _km2; set _km;
       keep &time probevt;
         if _censor_=0; **keep event times;
         probevt=1-survival;
       label probevt='1-Overall Kaplan-Meier';
 
      data _null_;
       set _est;
       if _type_='PARMS' & upcase(_name_)=upcase("&time") ;
         %do i=1 %to &nxs;
            %let thisx=%scan(&xvars,&i,' ');
            call symput("est&i",&thisx);
         %end;
       run;
 
      data _sch2;
       set _sch(keep=&strata &time ___event wrsch1-wrsch&nxs);
       keep &strata &time &xvars;
         if ___event=1;
         %do i=1 %to &nxs;
            %let thisx=%scan(&xvars,&i,' ');
            &thisx=&&est&i + wrsch&i;
         %end;
      proc sort; by &time;
      data _bt;
       merge _sch2(in=ins) _km2(keep=&time probevt);
       by &time;
         if ins;
      proc sort; by &strata &time;
      run;
 
      symbol1 i=none v=dot h=0.3 c=grey50;
      symbol2 v=none i=join l=1 c=black w=5;
      symbol3 v=none i=join l=2 c=black w=2;
      symbol4 v=none i=join l=2 c=black w=2;
      %macro dovars(tvar);
 
         %do i=1 %to &nplotvar;
            %let x=%scan(&plotvars,&i,' ');
 
          ods listing close ;
            %IF %upcase(&METHOD)=SPLINE %THEN %DO;
            proc transreg data=&OUTBT alpha=&ALPHA;
               model identity(&X)=spline(&TVAR / nknots=%EVAL(&DF+1));
               output out=__temp1 predicted clm
                   pprefix=p_ cmuprefix=ucl_ cmlprefix=lcl_;
              run;
             %END;
 
            %ELSE %DO;
            proc loess data=&OUTBT;
               ods output scoreresults=__temp1
                          fitsummary=__temp2;
               model &X = &TVAR  / clm alpha=&ALPHA
                %IF (&SMOOTH^=) %THEN %DO; smooth=&SMOOTH %END; ;
               score / clm;
              run;
            data _null_;
               set __temp2;
               if Label1="Smoothing Parameter";
               call symput('SMPAR', trim(left(put(nValue1,5.3))));
              run;
              %END;
          ods listing;
 
            %if %upcase(&rug)=YES %then %do;
               data __anno;
                set __temp1;
                  x=&tvar;
                  y=0;
                  xsys='2';
                  ysys='1';
                  function='move';
                  output;
                  y=5;
                  function='draw';
                  output;
            %end;
            proc sort data=__temp1; by &tvar;
            proc gplot data=__temp1 gout=gschbt
            %if %upcase(&rug)=YES %then %do;
               annotate=__anno
            %end;
            ;
               plot
                    %if %upcase(&points)=YES %then %do;
                       &x*&tvar=1
                     %end;
                    p_&X*&tvar=2
                    %if &doalpha=1 %then %do;
                       lcl_&X*&tvar=3
                       ucl_&X*&tvar=4
                     %end;
                /overlay vaxis=axis1 haxis=axis2
                 %if %upcase(&vref)=YES %then %do;
                    vref=0 lvref=3
                 %end;
                 ;
 
            %if %upcase(&METHOD)=SPLINE %then %do;
            axis1 label=(r=0 a=90 f=swiss "&X (spline, df=&DF)")
                  value=(f=swiss);
             %end;
            %else %do;
            axis1 label=(r=0 a=90 f=swiss "&X (loess, smooth=&SMPAR)")
                  value=(f=swiss);
             %end;
 
            %if &tvar=&time %then %do;
               axis2 label=(f=swiss "&tvar") value=(f=swiss);
            %end;
            %if &tvar=rtime %then %do;
               axis2 label=(f=swiss "Rank for Variable &time")
                     value=(f=swiss);
            %end;
            %if &tvar=probevt %then %do;
               axis2 label=(f=swiss '1-Overall Kaplan-Meier')
                     value=(f=swiss);
            %end;
            run; quit;
         %end;
      %mend dovars;
      %LET NEXTT1=%EVAL(&TSHOW+1);
      title&NEXTT1 h=3pct f=swiss 'Scaled residuals(Bt) as a fcn of time.';
      proc rank data=_bt  out=&outbt; var &time; ranks rtime;
      proc corr pearson data=&outbt;
       with &xvars; var &time rtime probevt;
       label probevt='1 - Overall Kaplan-Meier';
       run;
 
      %if %upcase(&plot)=T %then %do;
         %dovars(&time)
      %end;
 
      %if %upcase(&plot)=R %then %do;
         %dovars(rtime)
      %end;
 
      %if %upcase(&plot)=K %then %do;
         %dovars(probevt)
      %end;
 
      run;
      quit;
      footnote1;
      %IF (&F>=1) %THEN %DO I=1 %TO &F;
        footnote&I "&&FOOTNOTE&I";
        %END;
      title1;
      %IF (&T>=1) %THEN %DO I=1 %TO &T;
        title&I "&&TITLE&I";
        %END;
 
      symbol;
      proc datasets nolist;
       delete _setup _est _sch _sch1 _sch2 _km _km2 _bt
        %if %upcase(&rug)=YES %then %do;
              __anno
        %end;
        %if %upcase(&method)=LOESS %then %do;
              __temp2
        %end;
        __temp1 _f _t;
      run;
      quit;
   %end;
%mend schoen;
 
 
