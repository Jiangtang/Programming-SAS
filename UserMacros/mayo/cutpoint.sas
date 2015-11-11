
  /*------------------------------------------------------------------*
   | MACRO NAME  : cutpoint
   | SHORT DESC  : Find the best cutpoint of a continuous variable
   |               for a binary outcome.
   |               
   *------------------------------------------------------------------*
   | CREATED BY  : Jason Vinar
   |             : Brent Williams
   |             : Alfred Furth                           (3/15/2003)
   *------------------------------------------------------------------*
   | PURPOSE
   |     
   | Investigator: Jay and Sumithra Mandrekar    
   | Programmer: Jason Vinar, Brent Williams, Alfred Furth
   | Date Created: 5/15/2006
   | 
   | This macro is designed to find a best cutpoint of a continous
   | variable based on a chi-square statistic for a binary outcome.
   | 
   *------------------------------------------------------------------*
   | DEPENDENCIES: None
   |
   |
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :   
   | MVS SAS v9    :   
   | PC SAS v8     :   
   | PC SAS v9     :   YES
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %cutpoint( 
   |           data=,                
   |           dvar=,
   |           endpoint=,
   |           trunc=round,
   |           type=integers,
   |           range=fifty,
   |           fe=on,
   |           plot=plot,
   |           ngroups=,
   |           padjust=,
   |           zoom=yes
   |           );
   | 
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : input data set name
   |
   | Name      : dvar 
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Continuous Variable to Dichotomize
   |
   | Name      : endpoint 
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Binary endpoint
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   | 
   | Name      : trunc
   | Default   : round
   | Type      : Text (list)
   | Purpose   : SELECT TYPE OF TRUNCATION ON A CONTINUOUS VARIABLE
   | Values    : * round - NORMAL ROUNDING 
   |             * int - MOVES TO THE INTEGER IN THE DIRECTION OF
   |                     ZERO ON THE NUMBER LINE
   |             * floor - MOVES TO THE NEXT LEFT INTEGER 
   |             * ciel - MOVES TO THE NEXT RIGHT INTEGER
   |             
   | Name      : type 
   | Default   : integers
   | Type      : Text (list)
   | Purpose   : SELECT TYPE OF ITERATION 
   | Values    : * integers - ITERATES TO THE NEXT INTEGER OF CONT. VAR.
   |             * tenths - ITERATES TO THE NEXT TENTH
   |             * hundredths - ITERATES TO THE NEXT HUNDREDTH
   |
   | Name      : range
   | Default   : fifty
   | Type      : Text (list)
   | Purpose   : RANGE OF CONTINUOUS VARIABLE
   | Values    : * fifty - INNER 50% OF CONT. VAR. USED FOR CUTPOINTS
   |             * eighty - INNER 80% OF CONT. VAR. USED FOR CUTPOINTS
   |             * ninety - INNER 90% OF CONT. VAR. USED FOR CUTPOINTS
   |
   | Name      : fe
   | Default   : on
   | Type      : Text (list)
   | Purpose   : PERFORM FISHER''S EXACT TEST WHEN EXPECTED CELL
   |             COUNTS ARE LESS THAN 5
   | Values    : * on - TURNS FE ON
   |             * off - TURNS FE OFF
   | 
   |
   | Name      : plot
   | Default   : plot
   | Type      : Text (list)
   | Purpose   : TYPE OF PLOT OUTPUT
   | Values    : * plot - REGULAR OUTPUT WINDOW PLOTS
   |             * gplot - GPLOT OUTPUT
   | 
   | Name      : ngroups
   | Default   : 
   | Type      : ANY INTEGER > 1 AND < N (TOTAL SAMPLE SIZE)
   | Purpose   : NUMBER OF GROUPS TO SPILT THE CONTINUOUS
   |             VARIABLE INTO
   |
   | Name      : padjust
   | Default   : miller
   | Type      : Text (list)
   | Purpose   : P-VALUE ADJUSTING TECHNIQUE
   | Values    : * miller - ADJUSTED P-VALUE USING MILLER''S TECHNIQUE
   |             * lausen - (UNVALIDATED - DO NOT USE!!!!!!!)
   |
   | Name      : zoom
   | Default   : yes
   | Type      : Text (list)
   | Purpose   : ZOOM INTO THE MINIMUM P-VALUE PLOT
   | Values    : * yes - ZOOMS INTO THE LOWER HALF OF THE P-VALUES
   |             * no - NO ZOOMING
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | (1) Graphs of Optimal Cutpoints by adjusted and unadjusted p-values
   | (2) Table of Optimal Cutpoints ordered a combined score of
   |     p-value ranking and odds ratio ranking.
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | + ENDPOINT VARIABLE MUST BE NUMERIC (0 FOR NO ENDPOINT, 
   |   1 FOR INDICATION OF ENDPOINT).                       
   | + ENDPOINT MUST NOT HAVE ANY MISSING VALUES             
   |   OBSERVATIONS WITH MISSING ENDPOINT WILL NOT BE      
   |   INCLUDED                                             
   | + CONTINUOUS VARIABLE MUST NOT HAVE ANY MISSING VALUES   
   |   OBSERVATIONS WITH MISSING CONTINUOUS VARIABLE WILL   
   |   NOT BE INCLUDED                                     
   | 
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | %cutpoint(dvar=aceilst2, endpoint=mhypo30, data=dat.anal2, trunc=round, type=integers,
   |          range=ninety, fe=on, plot=gplot, ngroups=10, padjust=miller, zoom=no);
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Altman DG, Lausen B, Sauerbrei W, Schumacher M. Dangers of using “optimal”
   | cutpoints in the evaluation of prognostic factors. Journal of the National Cancer Institute
   | 1994; 86: 829-835.
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
 
%macro cutpoint(dvar=,endpoint=,data=,trunc=round,type=integers,
                range=fifty,fe=on,plot=plot,ngroups=,padjust=,zoom=yes);
 
%let updvar = %upcase(&dvar);
%let exact=UNK;
%let perc=%substr(%sysevalf(100/&ngroups),1,2);
%let upendp=%upcase(&endpoint);
 
  proc sql;
    reset noprint;
    select setting into:_date from dictionary.options where optname='DATE';
    select setting into:_number from dictionary.options where optname='NUMBER';
  quit;
 
  data _cut_;
    set &data;
    %if %upcase(&type)=INTEGERS %then %do;
      &dvar = &dvar*1;
    %end;
      %else %if %upcase(&type)=TENTHS %then %do;
      &dvar = &dvar*10;
      %end;
        %else %if %upcase(&type)=HUNDREDTHS %then %do;
        &dvar = &dvar*100;
        %end;
    if &dvar = . then do;
      put "******************************************************";
      put "OBSERVATION " _n_ "WITH MISSING &updvar WILL NOT BE INCLUDED";
      put "******************************************************";
      delete;
    end;
    if &endpoint not in (0,1) then do;
      put "********************************************************";
      put "OBSERVATION " _n_ "WITH MISSING ENDPOINT WILL NOT BE INCLUDED";
      put "********************************************************";
      delete;
    end;
    keep &dvar &endpoint;
  run;
 
  title4 "OPTIMAL DICHOTOMIZATION OF CONTINUOUS VARIABLES";
  title5 "EXPLORATION OF CUTPOINT FOR &updvar IN EXPLANING &upendp";
 
  proc univariate data=_cut_ noprint;
    var &dvar;
    output out=_range_ min=min max=max n=n p5=p5 p10=p10 p90=p90 p95=p95 q1=q1 q3=q3;
  run;
 
  data _range_;
    set _range_;
    variable = "&updvar";
    %if %upcase(&trunc) = INT %then %do;
      min = int(min);
      max = int(max);
      p5 = int(p5);
      p10 = int(p10);
      p90 = int(p90);
      p95 = int(p95);
      q1 = int(q1);
      q3 = int(q3);
    %end;
      %else %if %upcase(&trunc) = FLOOR %then %do;
        min = floor(fuzz(min));
        max = floor(fuzz(max));
        p5 = floor(fuzz(p5));
        p10 = floor(fuzz(p10));
        p90 = floor(fuzz(p90));
        p95 = floor(fuzz(p95));
        q1 = floor(fuzz(q1));
        q3 = floor(fuzz(q3));
      %end;
      %else %if %upcase(&trunc) = CEIL %then %do;
        min = ceil(fuzz(min));
        max = ceil(fuzz(max));
        p5 = ceil(fuzz(p5));
        p10 = ceil(fuzz(p10));
        p90 = ceil(fuzz(p90));
        p95 = ceil(fuzz(p95));
        q1 = ceil(fuzz(q1));
        q3 = ceil(fuzz(q3));
      %end;
      %else %if %upcase(&trunc) = ROUND %then %do;
        min = round(min,1);
        max = round(max,1);
        p5 = round(p5,1);
        p10 = round(p10,1);
        p90 = round(p90,1);
        p95 = round(p95,1);
        q1 = round(q1,1);
        q3 = round(q3,1);
      %end;
  run;
 
  %if %upcase(&range)=FIFTY %then %do;
    data _null_;
      set _range_;
      call symput('_num',n);
      call symput('_lb_',q1);
      call symput('_ub_',q3);
    run;
    %let e_low=0.25;
    %let e_hgh=0.75;
  %end;
    %else %if %upcase(&range)=EIGHTY %then %do;
      data _null_;
        set _range_;
        call symput('_num',n);
        call symput('_lb_',p10);
        call symput('_ub_',p90);
      run;
      %let e_low=0.1;
      %let e_hgh=0.9;
    %end;
    %else %if %upcase(&range)=NINETY %then %do;
      data _null_;
        set _range_;
        call symput('_num',n);
        call symput('_lb_',p5);
        call symput('_ub_',p95);
      run;
      %let e_low=0.05;
      %let e_hgh=0.95;
    %end;
 
  proc univariate data=&data noprint;
    var &dvar;
    output out=_range2_ min=min max=max n=n p5=p5 p10=p10 p90=p90 p95=p95 q1=q1 q3=q3;
  run;
 
  data _range2_;
    set _range2_;
    variable = "&updvar";
  run;
 
  options formdlim=' ';
 
  proc print data=_range2_ split='*';
    id variable;
    var n min p5 p10 q1 q3 p90 p95 max;
    label variable='CONTINUOUS*VARIABLE'
          n       ='N'
          min     ='MINIMUM'
          p5      ='5-TH*PERCENTILE'
          p10     ='10-TH*PERCENTILE'
          Q1      ='25-TH*PERCENTILE'
          Q3      ='75-TH*PERCENTILE'
          p90     ='90-TH*PERCENTILE'
          p95     ='95-TH*PERCENTILE'
          max     ='MAXIMUM';
    title7 "RANGES FOR &updvar";
  run;
 
  proc sort data=_cut_ out=_group_;
    by &dvar;
  run;
 
  %let size = %sysevalf(&_num/&ngroups);
 
  %do r = 1 %to &ngroups;
    %let r_ = %eval(&r-1);
    %if &r=&ngroups %then %do;
      data _group_;
        set _group_;
        if &r_*&size < _n_ le &_num then group=&r;
      run;
    %end;
    %else %do;
      data _group_;
        set _group_;
        if &r_*&size < _n_ le &r*&size then group=&r;
      run;
    %end;
  %end;
 
  proc freq data=_group_ noprint;
    table &endpoint*group / nocum norow nopercent out=_gfreq_;
  run;
 
  proc freq data=_group_ noprint;
    table &endpoint / nocum norow nopercent out=_g2f_;
  run;
 
  data _g2f_;
    set _g2f_;
    group = 'ALL';
  run;
 
  proc sort data=_gfreq_;
    by group &endpoint;
  run;
 
  data _gfreq_;
    set _gfreq_;
    by group &endpoint;
    if first.group then do;
      count0 = .; count1 = .;
    end;
    if first.group and &endpoint = 0 then count0 = count;
      else if first.group and &endpoint = 1 then count1 = count;
    if last.group and &endpoint = 0 then count0 = count;
      else if last.group and &endpoint = 1 then count1 = count;
    retain count0 count1;
    if last.group then output;
    drop count percent;
  run;
 
  data _gfreq_;
    set _gfreq_;
    if count0 = . then count0 = 0;
    if count1 = . then count1 = 0;
    percent = (count1 / (count0 + count1))*100;
  run;
 
  proc sort data=_g2f_;
    by group &endpoint;
  run;
 
  data _g2f_;
    set _g2f_;
    by group &endpoint;
    if first.group then do;
      count0 = .; count1 = .;
    end;
    if first.group and &endpoint = 0 then count0 = count;
      else if first.group and &endpoint = 1 then count1 = count;
    if last.group and &endpoint = 0 then count0 = count;
      else if last.group and &endpoint = 1 then count1 = count;
    retain count0 count1;
    if last.group then output;
    drop count percent;
  run;
 
  data _g2f_;
    set _g2f_;
    if count0 = . then count0 = 0;
    if count1 = . then count1 = 0;
    percent = (count1 / (count0 + count1))*100;
  run;
 
  proc sort data=_gfreq_;
    by group;
  run;
 
  proc univariate data=_group_ noprint;
    by group;
    var &dvar;
    output out=_guni_ mean=mean median=median;
  run;
 
  proc univariate data=_group_ noprint;
    var &dvar;
    output out=_g2u_ mean=mean median=median;
  run;
 
  data _g2u_;
    set _g2u_;
    group = 'ALL';
  run;
 
  proc sort data=_guni_;
    by group;
  run;
 
  data _g1_;
    merge _gfreq_ _guni_;
    by group;
  run;
 
  data _g2_; length groupc $3.;
    merge _g2f_ _g2u_;
    by group;
    groupc = group;
    drop group;
  run;
 
  data _g3_; length groupc $3.;
    set _g1_;
    groupc = group;
    drop group;
  run;
 
  data _g_;
    set _g3_ _g2_;
  run;
 
  options nodate nonumber;
 
  proc print data=_g_ split='*';
    id groupc;
    var mean median count1 percent;
    label groupc  ="GROUP ""N""*IN &perc*PERCENTILES"
          mean    ="MEAN*&updvar"
          median  ="MEDIAN*&updvar"
          count1  ="NUMBER OF*EVENTS"
          percent ="PERCENT*WITH AN*EVENT";
    format mean 9.2 percent 5.2;
    title4 'ENDPOINT SUMMARY';
  run;
 
  options formdlim='' &_date &_number;
 
  title4 "OPTIMAL DICHOTOMIZATION OF CONTINUOUS VARIABLES";
  title5 "EXPLORATION OF CUTPOINT FOR &updvar IN EXPLANING &upendp";
 
  data _cut2_;
    set _cut_;
    if &dvar < &_lb_ then delete;
    if &dvar > &_ub_ then delete;
    %if %upcase(&trunc) = INT %then %do;
      &dvar = int(&dvar);
    %end;
      %else %if %upcase(&trunc) = FLOOR %then %do;
        &dvar = floor(fuzz(&dvar));
      %end;
      %else %if %upcase(&trunc) = CEIL %then %do;
        &dvar = ceil(fuzz(&dvar));
      %end;
      %else %if %upcase(&trunc) = ROUND %then %do;
        &dvar = round(&dvar,1);
      %end;
  run;
 
 
  **************************************************;
  ***  Jitter plot method based on the %jitplot  ***;
  ***  macro by E. Bergstralh                    ***;
  **************************************************;
 
  proc freq data=_cut2_ noprint;
    tables &endpoint*&dvar / out=_jit_;
  run;
 
  proc sql;
    reset noprint;
    select max(count) into:max_cnt
    from _jit_;
  quit;
 
  %let space = %sysevalf(0.8/&max_cnt);
 
  data _jit_;
    set _jit_;
    if &endpoint = . then delete;
    med = (count + 1) / 2;
    if count ne . then do;
      do i = 1 to count;
        gp = &endpoint + ((i - 1) * &space);
        gp2 = gp - med * &space + &space;
        output;
      end;
    end;
  run;
 
  data _jit_;
    set _jit_;
    &endpoint = gp2;
  run;
 
  proc sql;
    reset noprint;
    select max(&endpoint) into:max_ep
    from _jit_;
  quit;
 
  proc sql;
    reset noprint;
    select min(&endpoint) into:min_ep
    from _jit_;
  quit;
 
  **************************************************;
  ***  End of jitter plot method.                ***;
  **************************************************;
 
  data _list_;
     set _cut2_;
     keep &dvar;
  run;
 
  proc sort data=_list_ nodups;
    by &dvar;
  run;
 
  %nobs(dsn=_list_,macvar=_nlist_);
 
  %do j = 1 %to &_nlist_;
    data _null_; length n $4.;
      set _list_;
      if _n_ = &j;
      n = _n_;
      call symput('cp'||left(n),&dvar);
    run;
    data _cut_;
      set _cut_;
      if &dvar ge &&cp&j then high = 1;
        else high = 0;
    run;
    proc freq data=_cut_ noprint;
      table high*&endpoint / chisq relrisk nocum nopercent out=_f_;
    run;
 
/*
    %if %upcase(&padjust)=LAUSEN %then %do;
      data _f2_;
        set _cut_;
        if &dvar le &&cp&j then output;
      run;
      %nobs(dsn=_f2_,macvar=_obslow);
      data _l_;
        cutpoint = &&cp&j;
        pp = &_obslow/&_num;
      run;
      %if &j=1 %then %do;
        data _lausen_;
          set _l_;
        run;
      %end;
        %else %do;
          data _lausen_;
            set _l_ _lausen_;
        %end;
    %end;
*/
 
    data _f_;
      set _f_;
      if &endpoint = 0 and high = 0 then n00 = count;
      if &endpoint = 0 and high = 1 then n01 = count;
      if &endpoint = 1 and high = 0 then n10 = count;
      if &endpoint = 1 and high = 1 then n11 = count;
      retain n00 n01 n10 n11;
      if _n_ = 4 then output;
      keep n00 n01 n10 n11;
    run;
    data _f_;
      length exact $3.;
      set _f_;
      a00 = ((n00 + n01)*(n00 + n10))/(n00 + n01 + n10 + n11);
      a01 = ((n00 + n01)*(n01 + n11))/(n00 + n01 + n10 + n11);
      a10 = ((n00 + n01)*(n10 + n11))/(n00 + n01 + n10 + n11);
      a11 = ((n10 + n11)*(n01 + n11))/(n00 + n01 + n10 + n11);
      exact='NO';
      if a00 < 5 then do;
        exact='YES';
      end;
      if a01 < 5 then do;
        exact='YES';
      end;
      if a10 < 5 then do;
        exact='YES';
      end;
      if a11 < 5 then do;
        exact='YES';
      end;
      if _n_ = 1 then call symput('exact',exact);
    run;
    %if %upcase(&fe)=ON %then %do;
      %let fish = xp2_fish;
      %if &exact=YES %then %do;
        proc freq data=_cut_ noprint;
          table high*&endpoint / chisq exact relrisk nocum nopercent;
          output out=_p_ chisq exact relrisk;
        run;
      %end;
        %else %if &exact=UNK %then %do;
          proc freq data=_cut_ noprint;
            table high*&endpoint / chisq exact relrisk nocum nopercent;
            output out=_p_ chisq exact relrisk;
          run;
        %end;
        %else %if &exact=NO %then %do;
          proc freq data=_cut_ noprint;
            table high*&endpoint / chisq relrisk nocum nopercent;
            output out=_p_ chisq relrisk;
          run;
        %end;
    %end;
      %else %if %upcase(&fe)=OFF %then %do;
        %let fish = %str();
        proc freq data=_cut_ noprint;
          table high*&endpoint / chisq relrisk nocum nopercent;
          output out=_p_ chisq relrisk;
        run;
      %end;
    data _p_;
      set _p_;
      cutpoint = &&cp&j;
      exact = "&exact";
      keep n _pchi_ p_pchi _rror_ l_rror u_rror &fish cutpoint exact;
    run;
    %if &j = 1 %then %do;
      data _pval_;
        set _p_;
      run;
    %end;
      %else %do;
        data _pval_;
          set _p_ _pval_;
        run;
      %end;
  %end;
 
  data _pval_;
    set _pval_;
    if exact = 'UNK' then delete;
      else if exact = 'NO' then p_value = p_pchi;
        else if exact = 'YES' then p_value = xp2_fish;
    %if %upcase(&type)=INTEGERS %then %do;
      cutpoint = cutpoint/1;
    %end;
      %else %if %upcase(&type)=TENTHS %then %do;
        cutpoint = cutpoint/10;
      %end;
        %else %if %upcase(&type)=HUNDREDTHS %then %do;
          cutpoint = cutpoint/100;
        %end;
  run;
 
  proc univariate data=_pval_ noprint;
    var _rror_;
    output out=_max_ max=max;
  run;
 
  data _null_;
    set _max_;
    call symput('max_or',max);
  run;
 
  proc univariate data=_pval_ noprint;
    var p_value;
    output out=_max_ max=max median=med;
  run;
 
  data _null_;
    set _max_;
    max = 100*max; max = ceil(max); max = max/100;
    med = 100*med; med = ceil(med); med = med/100;
    do i = 1 to 100;
      j = i - 1;
      if j*0.01 lt med le i*0.01 then med = i*0.01;
    end;
    call symput('max_pv',max);
    call symput('med_pv',med);
  run;
 
 
  %if %upcase(&plot)=GPLOT %then %do;
    goptions reset=global ftext=centxiu gunit=pct border htitle=4 htext=3;
 
    symbol color=blue height=2;
 
    axis1 color = red
          label = ("&updvar")
          major = (height=0.5cm width=2)
          minor = (number=1 height=0.25cm width=1)
          offset= (1,1)
          length= 80
          width = 3;
 
    axis2 color = red
          order = (-1 0 1 2)
          label = (angle=90 "&upendp")
          major = (height=0.5cm width=2)
          minor = none
          offset= (1,1)
          width = 3;
 
    axis3 color = red
          label = ("MEDIAN &updvar OF EACH &perc % GROUPING")
          major = (height=0.5cm width=2)
          minor = (number=1 height=0.25cm width=1)
          offset= (1,1)
          length= 80
          width = 3;
 
    axis4 color = red
          label = (angle=90 "PERCENT WITH &upendp")
          major = (height=0.5cm width=2)
          minor = (number=1 height=0.25cm width=1)
          offset= (1,1)
          width = 3;
 
    axis5 color = red
          label = ("&updvar CUTPOINT")
          major = (height=0.5cm width=2)
          minor = (number=9 height=0.25cm width=1)
          offset= (1,1)
          length= 80
          width = 3;
 
    axis6 color = red
          order = (0 to &max_pv by 0.05)
          label = (angle=90 "P-VALUE")
          major = (height=0.5cm width=2)
          minor = (number=9 height=0.25cm width=1)
          offset= (1,1)
          width = 3;
 
    axis9  color = red
           label = ("&updvar CUTPOINT")
           major = (height=0.5cm width=2)
           minor = (number=9 height=0.25cm width=1)
           offset= (1,1)
           length= 80
           width = 3;
 
    axis10 color = red
           order = (0 to &med_pv by 0.01)
           label = (angle=90 "P-VALUE")
           major = (height=0.5cm width=2)
           minor = (number=9 height=0.25cm width=1)
           offset= (1,1)
           width = 3;
 
    axis7 color = red
          label = ("&updvar CUTPOINT")
          major = (height=0.5cm width=2)
          minor = (number=9 height=0.25cm width=1)
 
offset= (1,1)
          length= 80
          width = 3;
 
    axis8 color = red
          order = (0 to &max_or by 0.5)
          label = (angle=90 "ODDS RATIO")
          major = (height=0.5cm width=2)
          minor = (number=1 height=0.25cm width=1)
          offset= (1,1)
          width = 3;
 
    proc gplot data=_jit_;
      plot &endpoint*&dvar='dot' / haxis=axis1 vaxis=axis2;
      title7 'ENDPOINT SUMMARY - BINARY OUTCOME JITTER PLOT';
    run;
    quit;
 
    proc gplot data=_g1_;
      plot percent*median='dot' / haxis=axis3 vaxis=axis4;
      title7 'ENDPOINT SUMMARY - GROUPED DATA PLOT';
    run;
    quit;
 
    proc gplot data=_pval_;
      plot p_value*cutpoint='dot' / haxis=axis5 vaxis=axis6;
      title7 'MINIMUM P-VALUE APPROACH';
      title8 'ALL P-VALUES';
    run;
    quit;
 
    %if %upcase(&zoom)=YES %then %do;
      proc gplot data=_pval_;
        plot p_value*cutpoint='dot' / haxis=axis9 vaxis=axis10;
        title7 'MINIMUM P-VALUE APPROACH';
        title8 'LOWEST HALF OF THE P-VALUES';
      run;
      quit;
    %end;
 
    proc gplot data=_pval_;
      plot _rror_*cutpoint='dot' / haxis=axis7 vaxis=axis8;
      title7 'MAXIMUM ODDS RATIO APPROACH';
    run;
    quit;
  %end;
 
  %else %if %upcase(&plot)=PLOT %then %do;
    proc plot data=_jit_ nolegend;
      plot &endpoint*&dvar='*';
      label gp3 = "&upendp"
            &dvar = "&updvar";
      title7 'ENDPOINT SUMMARY - BINARY OUTCOME JITTER PLOT';
    run;
 
    proc plot data=&data nolegend;
      plot &endpoint*&dvar='*';
      label &endpoint = "&upendp"
            &dvar = "&updvar";
      title7 'ENDPOINT SUMMARY - BINARY OUTCOME PLOT';
    run;
 
    proc plot data=_g1_ nolegend;
      plot percent*median='*';
      label percent = "PERCENT WITH &upendp"
            median  = "MEDIAN &updvar OF EACH &perc % GROUPING";
      title7 'ENDPOINT SUMMARY - GROUPED DATA PLOT';
    run;
 
    proc plot data=_pval_ nolegend;
      plot p_value*cutpoint='*' / vaxis=0 to &max_pv by 0.05;
      label cutpoint = "&updvar CUTPOINT"
            p_value  = "P-VALUE";
      title7 'MINIMUM P-VALUE APPROACH';
      title8 'ALL P-VALUES';
    run;
 
    %if %upcase(&zoom)=YES %then %do;
      proc plot data=_pval_ nolegend;
        plot p_value*cutpoint='*' / vaxis=0 to &med_pv by 0.01;
        label cutpoint = "&updvar CUTPOINT"
              p_value  = "P-VALUE";
        title7 'MINIMUM P-VALUE APPROACH';
        title8 'LOWEST HALF OF THE P-VALUES';
      run;
    %end;
 
    proc plot data=_pval_ nolegend;
      plot _rror_*cutpoint='*' / vaxis=0 to &max_or by 0.5;
      label cutpoint = "&updvar CUTPOINT"
            _rror_   = "ODDS RATIO";
      title7 'MAXIMUM ODDS RATIO APPROACH';
    run;
  %end;
 
  %if %upcase(&padjust)=MILLER %then %do;
    data _pval_;
      set _pval_;
      z = probit(1 - (p_value/2));
      phi_z = (1/sqrt(2*3.141592))*(exp((z**2)/(-2)));
      p_corr = phi_z*(z-(1/z))*(log((&e_hgh*(1-&e_low))/((1-&e_hgh)*&e_low)))+((4*phi_z)/z);
    run;
  %end;
 
/*
  %else %if %upcase(&padjust)=LAUSEN %then %do;
    proc sort data=_lausen_;
      by cutpoint;
    run;
    data _lausen_;
      set _lausen_;
      cutpoint=lag1(cutpoint);
      pp_1 = lag1(pp);
      if cutpoint = . then delete;
    run;
    data _lausen_;
      set _lausen_;
      _a_ = sqrt(1-((pp_1*(1-pp))/(pp*(1-pp_1))));
    proc sql;
      create table _lausen_ as
      select a.*,b._a_
      from _pval_ a full join _lausen_ b on a.cutpoint = b.cutpoint
      ;
    quit;
    data _lausen_;
      set _lausen_;
      z = probit(1 - (p_value/2));
      _d_ = (exp((z**2)/(-2)))*(1/3.141592)*(_a_ - (((z**2)/4) - 1)*((_a_**3)/6));
    run;
    proc univariate data=_lausen_ noprint;
      var _d_;
      output out=_l2_ sum=sum;
    run;
    data _null_;
      set _l2_;
      call symput('_sumd',sum);
    run;
    data _pval_;
      set _pval_;
      p_corr = p_value + &_sumd;
    run;
  %end;
*/
 
  proc sort data=_pval_;
    by p_value;
  run;
 
  data _pval_;
    set _pval_;
    if _n_ le 10;
  run;
 
  proc sort data=_pval_;
    by descending p_value;
  run;
 
  data _pval_;
    set _pval_;
    p_score = _n_;
    adj_rr = _rror_;
    if adj_rr > 1 then adj_rr = 1/adj_rr;
  run;
 
  proc sort data=_pval_;
    by descending adj_rr;
  run;
 
  data _pval_; length test $3.;
    set _pval_;
    rr_score = _n_;
    score = p_score + rr_score;
    if exact='YES' then test='FE';
      else if exact='NO' then test='CHI';
  run;
 
  proc sort data=_pval_;
    by descending score descending p_score;
  run;
 
  proc print data=_pval_ split='*';
    id cutpoint;
    var p_value test p_corr _rror_ l_rror u_rror score p_score rr_score;
    label cutpoint='PROPOSED*CUTPOINT'
          p_value ='P-VALUE'
          test    ='TEST*STATISTIC'
          p_corr  ='CORRECTED*P-VALUE'
          _rror_  ='ODDS*RATIO'
          l_rror  ='LOWER CI*LIMIT'
          u_rror  ='UPPER CI*LIMIT'
          score   ='TOTAL*SCORE'
          p_score ='P-VALUE*SCORE'
          rr_score='ODDS RATIO*SCORE';
    format p_value 8.6;
    title7 'TEN BEST CUTPOINTS';
  run;
 
  proc datasets lib=work;
    delete _cut_ _f_ _g2f_ _g2u_ _gfreq_ _group_ _guni_
           _g1_ _g2_ _g3_ _g_ _list_ _p_ _range2_ _range_;
  run;
  quit;
 
%mend cutpoint;
 
 
