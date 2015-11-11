  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : mcstrat
   | SHORT DESC  : Analyze a matched case-control study
   *------------------------------------------------------------------*
   | CREATED BY  : Kosanke, Jon                  (04/07/2004 17:03)
   |             : Vierkant, Rob
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | ***Macro to analyze case-control studies where cases and controls
   | ***are matched.  Replacement for Version 5 PROC MCSTRAT
   |
   | *******
   | SAS MACRO MCSTRAT
   | This macro analyzes case-control studies where cases and controls
   | are matched.  It is a replacement for the SAS Version 5 procedure
   | PROC MCSTRAT.
   |
   | The following keyword macro parameters are used:
   |  * DATA       Name of input dataset.
   |    ID         Requests that a list of sets not included in
   |               the model be printed.  Values are YES and NO(default)
   |    COV        Requests that the covariance matrix be printed.
   |               Values are YES and NO(default).
   |    OUTDATA    Names a SAS dataset to be created which contains
   |               all observations used in the model.
   |    MAXITER    Specifies the maximum number of iterations to be
   |               performed.  Default is 10.
   |    EPSILON    Specifies the difference in log likelihood used to
   |               determine convergence.  Default is .000001.
   |    UNI        Requests that univariate statistics be printed for
   |               independent variables.  Values are YES(default) and NO
   |    MINCNTL    Specifies the minimum number of controls required in
   |               each matched set.  Default is 1.
   |    MINCASE    Specifies the minimum number of cases required in
   |               each matched set.  Default is 1.
   |  * SETID      Name of variable which identifies matched sets in
   |               the input dataset.  Default is SETID.
   |  * CASE       Name of the case-control indicator variable.  Values
   |               must be 1 for cases and 0 for controls.
   |  * INDVAR     Names of independent variables separated by blanks.
   |               ALL VARIABLE NAMES SHOULD BE 7 CHARACTERS OR LESS
   |    TABLES     List of independent variables for which you want
   |               frequency tables.  Separate variable names with
   |               blanks.  The variables should be 1/0 or 1/2
   |               indicators.  The tables show how many cases and
   |               controls had a 1 in each set.
   |    DIAG       Requests that output data sets containing regression
   |               diagnostics be created.  Values are YES(default)
   |               and NO.  Two data sets created:  one on an
   |               individual/subject level (SUBDIAG) and one on a
   |               matched set level (SETDIAG).
   |
   |  * Required parameters:  user must supply a value.
   |
   |
   | Contents of data sets created by specifying DIAG=YES:
   |    SUBDIAG    contains regression diagnostics on an individual
   |               level.  Number of observations is equal to the number
   |               of observations used to fit the logistic model.
   |
   |               all independent variables in the logistic model
   |               (specified in the INDVAR parameter)
   |
   |               the case variable (specified in the CASE parameter)
   |
   |               the set id variable (specified in the SETID parameter)
   |
   |               XI      -> model fitted values (interpreted as the
   |                          probability the individual is a case)*
   |
   |               DELTAX2 -> delta chi-square statistic assessing effect
   |                          of observation on overall model fit*
   |
   |               INFL    -> influence statistic assessing effect of
   |                          observation on overall model fit*
   |
   |               HAT     -> leverage value*
   |
   |               LD      -> likelihood displacement statistic assessing
   |                          effect of observation on overal model fit**
   |
   |               LMAX    -> LMAX statistic assessing effect of
   |                          observation on overall model fit**
   |
   |               D(var)  -> delta-beta (DFBETA) statistic assessing
   |                          effect of observation on a particular
   |                          covariate in the model.  (var) corresponds
   |                          to first seven characters in the variable
   |                          name for that particular covariate.  One
   |                          diagnostic for each variable in the model**
   |
   |               S(var)  -> scaled DFBETA statistics, created by
   |                          dividing original DFBETA by coefficient
   |                          standard error from the estimated
   |                          covariance matrix**
   |
   |
   |    SETDIAG    contains sums of values from SUBDIAG data set
   |               (summed over all observations in matched set).  Number
   |               of observations is equal to the number of matched sets
   |               used to fit logistic model.
   |
   |               the setid variable (specified in the SETID parameter)
   |
   |               DELTAX2 -> sum of DELTAX2 diagnostics from SUBDIAG
   |                          data set
   |
   |               INFL    -> sum of INFL diagnostics from SUBDIAG
   |                          data set
   |
   |               HAT     -> sum of leverage diagnostics from SUBDIAG
   |                          data set
   |
   |               LD      -> sum of LD diagnostics from SUBDIAG
   |                          data set
   |
   |               LMAX    -> sum of LMAX diagnostics from SUBDIAG
   |                          data set
   |
   |               D(var)  -> sum of DFBETA diagnostics for a
   |                          particular covariate from SUBDIAG data
   |                          set.  One diagnostic for each variable in
   |                          the model.
   |
   |  *   for more information see Hosmer DW and Lemeshow S.  Applied
   |      Logistic Regression.  New York: John Wiley and Sons, Inc., 1989.
   |
   |  **  for more information see SAS Institute Inc. SAS/STAT Software:
   |      Changes and Enhancements through Release 6.12.  Cary, NC:  SAS
   |      Institute, Inc., 1997, pp. 895-900 (the PHREG procedure).
   |
   |
   | Example:
   |    Low birth weight data set (LOWWGT).  Cases are mothers of
   |    low birth weight babies, controls are age-matched mothers of
   |    normal birth weight babies.  Three controls matched to each case.
   |    Variable CASE distinguishes cases from controls (cases have value
   |    of 1, controls 0).  Independent variables are SMOKE, UI, PTD, LWD.
   |    Set id variable is SET.  User wants descriptive statistics to be
   |    printed for each independent variable.  User wants data sets of
   |    diagnostics to be created.  User wants frequency tables for
   |    variables SMOKE and UI.  Macro call is as follows...
   |
   |    %mcstrat(data=lowwgt,
   |           setid=set,
   |           case=case,
   |           indvar=smoke ui ptd lwd,
   |           uni=yes,
   |           diag=yes,
   |           tables=smoke ui)
   |
   |
   | The following dataset names are reserved and should not be used
   | by the calling program:
   |    __badset  __caco  __dat  __dat1  __out1  __out2  __out3
   |    __out4  __out5  __tab  __xbeta  __hat
   |    subdiag setdiag
   |
   | The following variable names are reserved and should not be used
   | by the calling program:
   |    __case1  __cntl1  __del  __df1-__dfn (n=# of indep. variables)
   |    __sco1-__scon  __sch1-__schn
   |    __name  __ncase  __ncntl  __nobs  __nsets  __ratio  __tcase
   |    __tcntl  __time  __tused  n_case  n_cntl  __sumr  __suml __sumld
   |    __sumi __sumh  __sumd1-__sumdn  __sums1-__sumsn  lmax  ld deltax2
   |    infl hat xi
   |    any name which would be the first 7 characters of an independent
   |    variable name prefixed with the letter s
   |    any name which would be the first 7 characters of an independent
   |    variable name prefixed with the letter d
   |
   | Programmers:  Rob Vierkant   Jon Kosanke
   | December 6, 1999
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
 
%macro mcstrat(data=,id=no,cov=no,outdata=,maxiter=10,
             epsilon=.000001,uni=yes,mincntl=1,mincase=1,
             setid=setid,case=,indvar=,tables=,diag=yes);
 
   %****local macro parameters;
   %local i t ntab err nobsorig nobsused setsorig setsused ls
          name newname tabvar;
 
   %****adjusting macro parameters and checking for errors;
   %let id=%upcase(&id);
   %let cov=%upcase(&cov);
   %let uni=%upcase(&uni);
   %let setid=%upcase(&setid);
   %let case=%upcase(&case);
   %let indvar=%upcase(&indvar);
   %let tables=%upcase(&tables);
   %let diag=%upcase(&diag);
   %let err=0;
   %if %length(&data)=0 %then %do;
      %put 'ERROR: NO INPUT DATASET SUPPLIED';
      %let err=1;
   %end;
   %if &id ^= NO & &id ^= N & &id ^= YES & &id ^= Y %then %do;
      %put 'ERROR: ID MUST BE YES OR NO';
      %let err=1;
   %end;
   %if &cov ^= NO & &cov ^= N & &cov ^= YES & &cov ^= Y %then %do;
      %put 'ERROR: COV MUST BE YES OR NO';
      %let err=1;
   %end;
   %if &uni ^= NO & &uni ^= N & &uni ^= YES & &uni ^= Y %then %do;
      %put 'ERROR: UNI MUST BE YES OR NO';
      %let err=1;
   %end;
   %if &diag ^= NO & &diag ^= N & &diag ^= YES & &diag ^= Y %then %do;
      %put 'ERROR: DIAG MUST BE YES OR NO';
      %let err=1;
   %end;
   %if %length(&case)=0 %then %do;
      %put 'ERROR: NO CASE VARIABLE SUPPLIED';
      %let err=1;
   %end;
   %if %length(&indvar)=0 %then %do;
      %put 'ERROR: NO INDEPENDENT VARIABLES SUPPLIED';
      %let err=1;
   %end;
   %if %length(&setid)=0 %then %do;
      %put 'ERROR: NO SETID VARIABLE SUPPLIED';
      %let err=1;
   %end;
 
   %****small macro used later on in the program;
   %macro var;
      %do i=1 %to &numvars;
         &&var&i
      %end;
   %mend var;
 
   %****count independent vars and set up macro variables
        var1,var2,var3...;
   %let numvars=0;
   %do %until(%scan(&indvar,&numvars+1,' ')= );
      %let numvars=%eval(&numvars+1);
      %let var&numvars=%scan(&indvar,&numvars,' ');
      %local var&numvars varb&numvars;
   %end;
 
   %****create 7 character variable used to later name individual
        delta-betas and scaled delta-betas;
   %do i=1 %to &numvars;
      %if %length(&&var&i)=8 %then %do;
         %let varb&i=%substr(&&var&i,1,7);
      %end;
      %else %let varb&i=&&var&i;
   %end;
 
   ****determines title number to use in output;
   proc sql;
    reset noprint;
    select max(number) into:t from dictionary.titles where type='T';
   quit;
   %let t=%eval(&t+2);
   %if %eval(&t)>10 %then %let t=10;
 
   %****if no errors then produce output;
   %if &err=0 %then %do;
      %do i=1 %to &numvars;
         %local se&i;
      %end;
      %let ntab=0;
      %do %until(%scan(&tables,&ntab+1,' ')= );
         %let ntab=%eval(&ntab+1);
      %end;
 
      ****format for cases and controls;
      proc format;
         value x 0='Control'
                 1='Case';
 
      ****original data set;
      data __dat1; set &data;
      proc sort; by &setid &case;
 
      ****macro parameters for # of original observations and sets;
      data _null_; set __dat1 end=eof; by &setid;
         __nobs+1;
         if first.&setid then __nsets+1;
         if eof;
         call symput('nobsorig',trim(left(put(__nobs,6.))));
         call symput('setsorig',trim(left(put(__nsets,6.))));
 
      ****creating time variable, deleting observations with
          missing values;
      data __dat1; set __dat1;
         __time=1;
         %do i=1 %to &numvars;
            if &&var&i=. then delete;
         %end;
 
      ****finding numbers of cases and controls in each matched set,
          and determining if each least as many as required;
      data __badset; set __dat1; by &setid &case;
         keep &setid;
         retain __ncntl __ncase;
         if first.&setid then do;
            __ncntl=0;
            __ncase=0;
         end;
         __del=0;
         if &case ^in (0 1) then __del=1;
         if __del=0 & &case=0 then __ncntl+1;
         if __del=0 & &case=1 then __ncase+1;
         if last.&setid then do;
            if __ncntl<&mincntl | __ncase<&mincase then output;
         end;
 
      ****merging numbers of cases and controls back in with original
          data, and deleting sets without required number of cases
          and controls;
      data __dat;
         merge __dat1 __badset(in=inb); by &setid;
         if inb then delete;
 
      ****creates data set that includes all observations used in
          analysis (if data set name for outdata is specified);
      %if &outdata^= %then %do;
         data &outdata; set __dat;
          drop __time;
      %end;
 
      ****determines current linesize option;
      proc sql;
         reset noprint;
         select setting into:ls from dictionary.options
         where optname='LINESIZE';
 
      ****macro parameters of number of observations and sets used
          in analysis;
      data _null_; set __dat end=eof; by &setid;
         __nobs+1;
         if first.&setid then __nsets+1;
         if eof;
         call symput('nobsused',trim(left(put(__nobs,6.))));
         call symput('setsused',trim(left(put(__nsets,6.))));
 
      ****summarizing number of cases and controls in each set to
          be placed in table later;
      proc freq data=__dat noprint;
         tables &setid*&case/out=__out1;
      data __caco; set __out1 end=eof; by &setid;
         keep &setid __ncase __ncntl;
         retain __ncase __ncntl;
         if first.&setid then do;
            __ncase=.;
            __ncntl=.;
         end;
         if &case=0 then __ncntl=count;
         if &case=1 then __ncase=count;
         if last.&setid;
 
      ****printing table describing matched sets;
      proc freq noprint;
         tables __ncase*__ncntl/out=__out2;
      data _null_; set __out2 end=eof;
         file print;
         if _n_=1 then do;
            put @((&ls-60)/2)
      'MCSTRAT:  LINEAR LOGISTIC REGRESSION ANALYSIS FOR MATCHED SETS';
            put @((&ls-60)/2) 60*'=';
            put / @((&ls-14)/2)
            "SETID = &setid";
            put @((&ls-30)/2)
            "CASE/CONTROL INDICATOR = &case";
            put // @((&ls-30)/2)
            "# OF OBSERVATIONS READ = &nobsorig";
            put @((&ls-30)/2)
            "# OF OBSERVATIONS USED = &nobsused";
            put @((&ls-30)/2)
            "# OF MATCHED SETS READ = &setsorig";
            put @((&ls-30)/2)
            "# OF MATCHED SETS USED = &setsused";
            put /// @((&ls-32)/2)
            'SUMMARY OF MATCHED SETS ANALYZED';
            put @((&ls-32)/2) 32*'=';
            put / @((&ls-38)/2)
            '# CASES   # CONTROLS   # MATCHED SETS';
            put @((&ls-38)/2)
            '=======   ==========   ==============';
         end;
         put  @((&ls-38)/2)
         __ncase 7. +6 __ncntl 7. +10 count 7.;
         __tcase+__ncase*count;
         __tcntl+__ncntl*count;
         __tused+count;
         if eof then do;
            put @((&ls-38)/2)
            '=====================================';
            put @((&ls-38)/2) __tcase 7. +6 __tcntl 7. +10 __tused 7.;
         end;
 
      ****printing univariate statistics for matched sets, if requested;
      %if &uni=YES | &uni=Y %then %do;
         proc means data=__dat;
            class &case;
            var %var;
            format &case x.;
            title&t 'Univariate Statistics for Matched Sets Used';
      %end;
 
      ****creating additional tables of case and control data;
      %if not(&tables=) %then %do;
         %do i=1 %to &ntab;
            %let tabvar=%scan(&tables,&i);
            data __tab;
               merge __dat __caco; by &setid;
               retain __case1 __cntl1;
               if first.&setid then do;
                  __case1=0;
                  __cntl1=0;
               end;
               if &case=0 & &tabvar=1 then __cntl1+1;
               if &case=1 & &tabvar=1 then __case1+1;
               if last.&setid;
               __ratio=compbl(put(__ncase,5.) || ' : '
                       || put(__ncntl,5.));
            proc freq noprint;
               tables __ratio*__case1*__cntl1/out=__out3;
            proc tabulate format=12.;
               class __cntl1 __ratio __case1;
               var count;
               table __ratio*__case1,__cntl1*count;
               keylabel n=' ' sum=' ';
               label __ratio='Case-Control Ratio'
                     __case1='# Cases'
                     __cntl1='# Controls';
               title&t "# Cases vs. # Controls Per Matched Set Where &tabvar=1";
         %end;
      %end;
 
      ****PHREG procedure to fit discrete logistic model to data;
      proc phreg data=__dat nosummary
      %if &diag=YES | &diag=Y %then %do;
         covout outest=__out4
      %end;
      ;
       model __time*&case(0)=%var / ties=discrete itprint
             %if &cov^=NO & &cov ^=N %then %do;
                covb
             %end;
             maxiter=&maxiter convergelike=&epsilon risklimits;
       strata &setid;
       %if &diag=YES | &diag=Y %then %do;
 
              ****output data set containing diagnostics;
              output out=__out5(drop=__time)
              dfbeta=__df1-__df&numvars xbeta=xbeta lmax=lmax ld=ld
              ressco=__sco1-__sco&numvars resmart=resmart;
 
              title&t 'Results of Modeling';
 
          ****standard errors necessary for calculating scaled DFBETAs;
          data __out4; set __out4;
             if _type_='COV';
             drop _ties_ _type_ _name_ _lnlike_;
          data _null_; set __out4;
             array cov(&numvars) %var;
             __name='se' || left(put(_n_,5.));
             call symput(__name,sqrt(cov(_n_)));
 
      ****create fitted values and covariates centered about
          weighted-specific mean, to be used in Hosmer and Lemeshow
          diagnostics;
      proc sort data=__out5; by &setid &case;
      data __xbeta (drop=__df1-__df&numvars __sco1-__sco&numvars
                    lmax ld);
         set __out5 nobs=last;
         by &setid &case;
 
         ****fitted values xi;
         xi=&case-resmart;
 
         ****covariates centered about weighted-specific mean;
         %do i=1 %to &numvars;
            __sch&i=__sco&i/resmart;
         %end;
         call symput('nobs',trim(left(put(last,6.))));
 
      ****matrix manipulations in PROC IML;
      proc iml;
 
         ****create matrix of covariate vectors centered about
             weighted-specific mean;
         use __xbeta;
         read all var {
            %do i=1 %to &numvars;
               __sch&i
            %end;
         } into x;
         close __xbeta;
 
         ****create covariance matrix;
         use __out4;
         read all var {
            %do i=1 %to &numvars;
               &&var&i
            %end;
         } into h;
 
         ****create hat matrix and output diagonal elements to data
             set hat;
         hc=x*h*x`;
         hat=vecdiag(hc);
         create __hat var {hat};
         append from hat;
 
         close __hat __out4;
      quit;
 
 
      ****merge the xbeta data set and the hat data set together
          to create delta chi square, delta beta, leverage values,
          and fitted values as seen in Hosmer and Lemeshow;
      data subdiag (keep=&setid &case xbeta lmax ld xi deltax2 hat infl
         %do i=1 %to &numvars;
            &&var&i d&&varb&i s&&varb&i
         %end;
      );
         merge __out5 __xbeta __hat;
 
         ****leverage values;
         hat=hat*xi;
 
         ****square of standardized Pearson residual;
         deltax2=((&case-xi)/sqrt(xi*(1-hat)))**2;
 
         ****influence statistic;
         infl=deltax2*hat/(1-hat);
 
         label deltax2='delta chi-square'
               infl='overall influence statistic'
               lmax='LMAX global influence statistic'
               ld='likelihood displacement'
               hat='leverage value from hat matrix'
               xi='fitted values';
 
         ****individual regular and scaled influence statistics;
         %do i=1 %to &numvars;
            d&&varb&i=__df&i;
            s&&varb&i=__df&i/&&se&i;
            label d&&varb&i="delta beta for variable &&var&i"
                  s&&varb&i="scaled delta beta for variable &&var&i";
         %end;
 
      ****sum above variables over entire stratum;
      proc sort data=subdiag; by &setid; run;
      data setdiag (drop=__sumr __sumi __suml __sumld __sumh
                         xbeta xi &case
         %do i=1 %to &numvars;
            __sumd&i &&var&i s&&varb&i
         %end;
         );
         set subdiag; by &setid;
         if first.&setid then do;
            __sumr=0; __sumi=0; __suml=0; __sumld=0; __sumh=0;
            %do i=1 %to &numvars;
               __sumd&i=0;
            %end;
         end;
         __sumr=__sumr+deltax2;
         __sumi=__sumi+infl;
         __suml=__suml+lmax;
         __sumld=__sumld+ld;
         __sumh=__sumh+hat;
         %do i=1 %to &numvars;
            __sumd&i=__sumd&i+d&&varb&i;
         %end;
         retain __sumr __sumi __suml __sumld __sumh
         %do i=1 %to &numvars;
            __sumd&i
         %end;
         ;
         if last.&setid then do;
            deltax2=__sumr;
            infl=__sumi;
            lmax=__suml;
            ld=__sumld;
            hat=__sumh;
 
             %do i=1 %to &numvars;
               d&&varb&i=__sumd&i;
            %end;
 
            output;
 
            label deltax2='sum of delta chi-square'
                  infl='sum of overall influence statistic'
                  lmax='sum of LMAX values'
                  ld='sum of likelihood displacement'
                  hat='sum of leverage values'
 
                  %do i=1 %to &numvars;
                     d&&varb&i="sum of delta beta for &&var&i"
                  %end;
                  ;
         end;
      run;
 
      %end;
       %if &id=YES | &id=Y %then %do;
          ****prints out sets not used in model;
          proc print data=__badset;
          title&t 'Sets not included in model';
      %end;
      run;
      proc datasets lib=work;
       delete __badset __caco __dat __dat1 __out1 __out2 __out3 __out4
              __tab __xbeta __hat;
      run; quit;
      title&t;
   %end;
%mend mcstrat;
 

