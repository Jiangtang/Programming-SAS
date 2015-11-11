  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : phlev
   | SHORT DESC  : Returns leverage residuals for Cox PH model,
   |               used for correlated observations
   *------------------------------------------------------------------*
   | CREATED BY  : Therneau, Terry               (04/09/2004 16:33)
   |             : Kosanke, Jon
   |             : Bergstralh, Erik
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Returns the leverage residuals matrix L for a proportional
   | hazards model.  The returned residuals data set is n by p, where
   | n is the number of (non-missing) subjects used in the PHREG fit,
   | and p is the number of fitted covariates.  The leverage residuals
   | are an approximation to the jackknife; the i-th observation of the
   | data set contains the approximate change in beta if observation i
   | were dropped from the model.  These residuals will normally be
   | plotted as an aid to finding influential or "high leverage"
   | observations
   |
   | Some data sets, particularily those with recurring events, may
   | contain multiple observations for a single individual.  The macro
   | has the option of "collapsing" the matrix of leverage residuals
   | so that the output has only one observation per unique
   | individual.
   |
   | The procedure can also estimate the robust covariance estimate
   | L'L.  When there are multiple, possibly correlated, observations
   | per subject this option combined with the collapsing mentioned
   | above, gives an estimate of variance that is corrected for the
   | correlation.
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
   | %phlev   (
   |            data= ,
   |            time= ,
   |            event= ,
   |            xvars= ,
   |            strata= ,
   |            id= ,
   |            collapse=N,
   |            outlev=phlev,
   |            outvar=phvar,
   |            plot=N,
   |            scaled=N,
   |            ref=N,
   |            print=N,
   |            showlog=N,
   |            ties=breslow
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : input SAS data set name
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : time variable for survival.
   |             This may be a single variable or an interval expressed
   |             as (t1,t2).
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
   | Name      : strata
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : stratification variable(one only) for stratifed Cox
   |             models.
   |
   | Name      : id
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : name of id variable to be included in the output dataset.
   |             It must be numeric.
   |
   | Name      : collapse
   | Default   : N
   | Type      : Text
   | Purpose   : Y,N,T,F.  If yes(Y,T), then the residual matrix is
   |             collapsed (summed) based on unique values of the id
   |             variable. Default is  not to collapse(N).
   |
   | Name      : outlev
   | Default   : phlev
   | Type      : Dataset Name
   | Purpose   : name of the data set containing the leverage
   |             residuals.  The variables names will be the same as
   |             the covariate names in the Cox model.  The data set
   |             will also contain the ID variable, if one was
   |             specified.  Default data set name is "phlev".
   |
   | Name      : outvar
   | Default   : phvar
   | Type      : Dataset Name
   | Purpose   : name of the output data set containing the robust
   |             variance estimate.  There is one observation and
   |             one variable for each covariate. Default data set
   |             name is "phvar".
   |
   | Name      : plot
   | Default   : N
   | Type      : Text
   | Purpose   : Y,N,T,F. If yes(Y,T), a plot of residuals for each
   |             observation or ID value(if collapse=Y) is
   |             produced.  A separate plot is created for each
   |             covariate.  Default is N.
   |
   | Name      : scaled
   | Default   : N
   | Type      : Text
   | Purpose   : Y,N,T,F. If yes(Y,T), the scaled score residuals
   |             are plotted.  If N(default), the raw residuals
   |             are used.
   |
   | Name      : ref
   | Default   : N
   | Type      : Text
   | Purpose   : Y,N,T,F.  If yes(Y,T), reference lines are drawn
   |             on the plots at +-se(beta).  Default is N.
   |
   | Name      : print
   | Default   : N
   | Type      : Text
   | Purpose   : Y,N.  If N, the phreg printout is suppressed.
   |
   | Name      : showlog
   | Default   : N
   | Type      : Text
   | Purpose   : Y,N.  If N, the SAS log is suppressed.
   |
   | Name      : ties
   | Default   : breslow
   | Type      : Text
   | Purpose   : Breslow,Discrete,Efron,Exact.  Method to use for
   |             handling failure time ties.  Default is Breslow.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | The macro prints the PHREG output used to fit the Cox model and a
   | summary table including the Cox model betas, SE and chi-square
   | along with the robust SE and its associated chi-square. It also
   | includes the global Wald chi-square test based on the leverage
   | residuals.  The summary table is available as a SAS data set named
   | _b_se.
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | Located at the bottom of the code.
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | The leverage residuals are discussed in Cain and Lange, Biometrics
   | 40:, 493-9 (1984).
   |
   | The robust variance estimate L'L is derived in Lin and Wei, JASA
   | 84: 725-8 (1989).
   |
   | Extension of this to correlated data, using the collapsed leverage
   | matrix is developed in Wei, Lin, and Weissfeld, JASA 84: 1065-83,
   | amoung others.
   |
   | An overview of the methods is found in Mayo Clinic Tech Report 58.
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
 
%macro phlev(data=,time=,event=,xvars=,
              strata=, id=, collapse=N, outlev=phlev, outvar=phvar,
              plot=N, scaled=N, ref=N, print=N, showlog=N, ties=breslow);
 
 %if %upcase(&showlog)=N %then %do;
    %if &sysscpl=Solaris %then %do;
       proc printto log='/dev/null';
    %end;
    %if &sysscpl=MVS %then %do;
       filename dummy '&&temp' disp=(new,delete,delete);
       proc printto log=dummy;
    %end;
 %end;
%local t paren timeint timeint1 timeint2 i nxs sp;
 
%if %upcase(&collapse)=T %then %let collapse=Y;
%if %upcase(&collapse)=F %then %let collapse=N;
%if %upcase(&plot)=T %then %let plot=Y;
%if %upcase(&plot)=F %then %let plot=N;
%if %upcase(&scaled)=T %then %let scaled=Y;
%if %upcase(&scaled)=F %then %let scaled=N;
%if %upcase(&ref)=T %then %let ref=Y;
%if %upcase(&ref)=F %then %let ref=N;
%let paren=%str(%();
%if %index(&time,&paren)>0 %then %do;
   %let timeint=1;
   %let timeint1=%qscan(&time,1);
   %let timeint2=%qscan(&time,2);
%end;
%else %let timeint=0;
footnote"phlev macro: event=&event time=&time strata=&strata id=&id collapse=
&collapse ties=&ties";
footnote2"Xvars= &xvars";
 
 %let nxs=0;             %**count the number of x vars;
 %do i=1 %to 50;
   %if %scan(&xvars,&i)= %then %goto done;
   %let nxs=%eval(&nxs+1);
 %end;
 %done: %put &nxs;
 
 %macro xlist(prefix);    %**set-up var list code;
  %local j;
  %do j=1 %to &nxs; &prefix&j %end;
 %mend xlist;
 
data _setup; set &data;         **delete obs with missing values;
  keep &id
  %if &timeint=0 %then %do;
     &time
  %end;
  %if &timeint=1 %then %do;
     &timeint1 &timeint2
  %end;
       &event &strata &xvars;
  xmiss=0;
  %do i=1 %to &nxs;
  xx=%scan(&xvars,&i);
  if xx=. then xmiss=1;
  %end;
  if &event=.
  %if &timeint=0 %then %do;
     or &time=.
  %end;
  %if &timeint=1 %then %do;
     or &timeint1=. or &timeint2=.
  %end;
  or xmiss=1 then delete;
 
                                ** run phreg and grab output datasets;
proc phreg data=_setup noprint;
 model &time*&event(0)= &xvars / maxiter=0 ties=&ties;
 %if &strata ^= %then %do; strata &strata; %end;
 output out=_out1(keep=&id dfb1-dfb&nxs) dfbeta=dfb1-dfb&nxs;
 id &id;
 %if %upcase(&collapse)=Y %then %do;
proc sort data=_out1 ; by &id;        **collapse the dataset..sum within id;
 
proc means noprint; by &id;       var dfb1-dfb&nxs;
 output out=_out1  sum=dfb1-dfb&nxs;
run;
 %end;
proc means noprint;               var dfb1-dfb&nxs;
 output out=_out2  sum=sum1-sum&nxs;
run;
proc phreg data=_setup covout outest=_est
 %if %upcase(&print)=N %then %do;
    noprint
 %end;
 ;
 model &time*&event(0)= &xvars / ties=&ties;
 %if &strata ^= %then %do; strata &strata; %end;
 output out=_sch ressco=s1-s&nxs;
 id &id;
 
/* Check for bad model */
data _null_; set _est(where=(_type_='PARMS'));
   bad=0;
   %do i=1 %to &nxs;
      if %scan(&xvars,&i)=0 then bad=1;
   %end;
   call symput('getout',bad);
run;
%if &getout=1 %then %do;
   data _null_;
    file print;
      put 'Singular model - no robust solution produced';
      put '%phlev will stop processing';
   run;
%end;
%else %do;
   data _sch5 ; set _sch(keep=&id &strata
     %if &timeint=0 %then %do;
        &time
     %end;
     %if &timeint=1 %then %do;
        &timeint1 &timeint2
     %end;
    &event s1-s&nxs);
     keep &strata &id
     %if &timeint=0 %then %do;
        &time
     %end;
     %if &timeint=1 %then %do;
        &timeint1 &timeint2
     %end;
          &event &xvars;
 
     label
     %if &timeint=0 %then %do;
        &time=
     %end;
     %if &timeint=1 %then %do;
        &timeint1=
        &timeint2=
     %end;
          &event=  ;
     %do i=1 %to &nxs;            **rename scor_i  vars to xvars;
      %scan(&xvars,&i) =s&i;
     %end;
    *proc print data=_sch5 ;
    *title3'Crude score residuals';
   run;
 
    %if %upcase(&collapse)=Y %then %do;
   proc sort data=_sch5 ; by &id;        **collapse the dataset..sum within id;
 
   proc means noprint; by &id;       var &xvars;
    output out=_sch5  sum=&xvars;
    *title3"Crude score residuals..collapsed(summed) over &id";
    *proc print data=_sch5 ;
   run;
    %end;
 
   proc iml;                      **Invoke IML to get L..scaled residuals;
 
    use _sch5  ; setin _sch5  ;
    read all var{ &xvars      } into r;
      %if &id ^= %then %do;
    read all var{&id } into id_time;
      %end;
    use _est; setin _est;
    read all var{&xvars     } into covb where(_type_="COV  ");
    read var{&xvars     } into beta  where(_type_="PARMS");
 
    L=r*covb;                     **Scaled score residuals;
    LTL=L`*L;                     **Robust var matrix;
 
    se_cox=sqrt(vecdiag(covb));   **SE from Cox model;
    se_scr=sqrt(vecdiag(LTL ));   **SE based on L'*L;
    chisqcox=(beta` / se_cox)##2; **Chi-square Cox model;
    chisqrob=(beta` / se_scr)##2; **Chi-square based on L'*L;
 
    wald_x2=beta*ginv(LTL)*beta`; **Global Wald chi-square..robust;
    eigv=eigval(LTL);
    df=sum(eigv > .000000000001);        **Wald degrees freedom;
    p_wald= 1 - probchi(wald_x2,df); **Wald p-value;
 
    idl= %if &id ^= %then %do; id_time || %end;  L;
    b_se= beta` || se_cox || se_scr || chisqcox || chisqrob;
    wald= wald_x2 || df || p_wald;
    use _out1; setin _out1;
    read all var{%do i=1 %to &nxs; dfb&i %end; } into dzero;
    use _out2; setin _out2;
    read all var{%do i=1 %to &nxs; sum&i %end; } into temp;
    roblr=temp*inv(dzero`*dzero)*temp`;
    p_lr=1-probchi(roblr,df);
    rob_lr=roblr || df || p_lr;
    bl_1x5=j(1,5,.);
    bl_px3=j(&nxs,3,.);
    table= (b_se || bl_px3) // ( bl_1x5 || wald ) // ( bl_1x5 || rob_lr );
 
    %let sp=%str( );
    varn    ={ %if &id^= %then %do; "&id" %end;
               %do i=1 %to &nxs;
                 %let t= "%scan(&xvars,&i)" &sp ; &t
               %end;
              };
    xnames={
               %do i=1 %to &nxs;
                 %let t= "%scan(&xvars,&i)" &sp ; &t
               %end;
              };
    xname ={
               %do i=1 %to &nxs;
                 %let t= "%scan(&xvars,&i)" &sp ; &t
               %end;
              "wald" "robust score"
              };
    sen={ "b_cox" "se_cox" "se_robst" "chi_cox" "chi_rob"
          "chi_w_lr" "df" "p_w_lr" };
 
    create &outlev from  idl[colname=varn    ];
    append from idl;
    create &outvar  from  ltl[rowname=xnames colname=xnames];
    append from ltl[rowname=xnames];
    create _b_se     from  table[ rowname=xname  colname=sen   ];
    append from table[rowname=xname ];
    *show datasets;
    *show contents;
    quit;                        ** quit IML;
 
    title4"Comparison of Cox model Beta, SE and chi-square to robust estimates";
    title5"Wald chi-square is based on the robust estimates";
    %if %upcase(&collapse)=Y %then %do;
    title6"Robust SE is based on the collapsed(summed within &id) L matrix";
    %end;
    data _b_se; set _b_se;
       if _n_<=&nxs then p=1-probchi(chi_rob,1);
       if _n_>=&nxs+1 then p=p_w_lr;
     label xname='Variable'
           b_cox='Parameter/Estimate'
           se_cox='SE'
           se_robst='Robust/SE'
           chi_cox='Chi-Square'
           chi_rob='Robust/Chi-Square'
           chi_w_lr='Chi-Square';
       %if %upcase(&scaled)=Y %then %do i=1 %to &nxs;
          if _n_=&i then do;
             call symput("pvref&i",se_robst);
             call symput("nvref&i",-1*se_robst);
          end;
       %end;
 
    proc print data=_b_se label split='/';
    id xname;
    var b_cox se_cox se_robst chi_cox chi_rob chi_w_lr df p;
    format chi_cox chi_rob chi_w_lr 7.3 p 6.4;
    run;
 
    footnote; symbol; title4;
 
    %if %upcase(&plot)=Y %then %do;
       %if %upcase(&scaled)=N %then %do;
          %if &id= %then %do;
             data _sch5; set _sch5;
                obs=_n_;
             %let id=obs;
          %end;
          proc plot data=_sch5;
           plot (&xvars)*&id;
          title4 'Plot of Raw Residuals';
       %end;
       %if %upcase(&scaled)=Y %then %do;
          %if &id= %then %do;
             data &outlev; set &outlev;
                obs=_n_;
             %let id=obs;
          %end;
          proc plot data=&outlev;
          %do i=1 %to &nxs;
             %let xvble=%scan(&xvars,&i);
             plot &xvble*&id
             %if %upcase(&ref)=Y %then %do;
                /vref=&&pvref&i &&nvref&i
             %end;
             ;
          %end;
          title4 'Plot of Scaled Residuals';
       %end;
    %end;
    proc datasets nolist;
      delete _setup _est _sch _sch5 _out1 _out2;
    run;
    quit;
%end;
%if %upcase(&showlog)=N %then %do;
   proc printto; run;
%end;
 %mend phlev ;
 
 
 
 /**** sample code ****
 
%LET XX= RX1 RX2 RX3 RX4 NUMBER1 NUMBER2 NUMBER3 NUMBER4 SIZE1 SIZE2
         SIZE3 SIZE4;
 
%PHLEV(DATA=Bladder,TIME=time,EVENT=stat,
         XVARS= &XX, STRATA=enum, ID=id, COLLAPSE=Y);
 
 *********************/
 

