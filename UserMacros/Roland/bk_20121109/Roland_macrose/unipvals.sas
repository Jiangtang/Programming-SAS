/*<pre><b>
/ Program      : unipvals.sas
/ Version      : 1.19
/ Author       : Roland Rashleigh-Berry
/ Date         : 12-May-2008
/ Purpose      : Clinical reporting macro to calculate p-values for the
/                %unistats macro.
/ SubMacros    : %words %dequote
/ Notes        : This macro has no way of knowing if the p-values it gives you
/                are relevant or useful. It is up to the statistician to decide
/                upon this matter.
/
/                Calculates Chi-square or Fisher's exact for categorical data,
/                the ANOVA for parametric numeric data and Kruskal-Wallis
/                or Wilcoxon rank sum test for non-parametric numeric data.
/
/                For categorical data, unless you override the test selection
/                using usetest=, Chi-square statistics are the default but if
/                for 2x2 tables the expected cell count for any cell is less
/                than 5 or for larger tables a single expected cell count is
/                less than one or more than 20% of the expected cell counts are
/                less than 5, then the Fisher exact test is used (this rule
/                might be called "Cochran's Recommendation" but please check
/                in "Siegel, S. (1956) Non-parametric Statistics for the 
/                Behavioral Sciences" for confirmation).
/
/                For numeric data then the ANOVA is used by default but if
/                usetest=N then the non-parametric Kruskal-Wallis test is used
/                (but that will effectively be the Wilcoxon rank sum test if
/                there are only two treatment arms).
/
/                You should make sure that data for the total of all treatment
/                arms is not present in the input data or the p-values will be
/                incorrect. It is up to you to exclude observations you do not 
/                want to include in the analysis.
/
/                The variables kept in the output dataset are the by variables
/                (if any), _pvalue and _test which will be set to "CHISQ" or
/                "FISHER" for categorical analysis, "ANOVA" for continuous
/                numeric analysis or "NPAR1WAY" which applies to the
/                Kruskal-Wallis test and the Wilcoxon rank sum test (for only
/                two treatment arms). "ANOVA" will be replaced by "WELCH" if
/                the Welch test is used.
/
/ Usage        : %unipvals(dsin=means,dsout=out,trtvar=tmt,respvar=val,type=N)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ usetest           For categorical data, set to C (Chi-square) or F (Fisher's
/                   exact) to override decision of macro to select Chi-square or
/                   Fisher's exact test based on expected cell counts. For
/                   numeric data, set to N (non-parametric) to override 
/                   the ANOVA parametric test. Setting this for categorical
/                   variables will overrride use of CMH if adjcntrvar= is set.
/ exact=no          By default, do not use an exact test for variables that
/                   require a non-parametric test (setting it to yes can
/                   consume a very large amount of processing time).
/ dsout             Output dataset
/ trtvar            Treatment variable (make sure "total treatment" is not
/                   present in the input data).
/ respvar           Response variable
/ byvars            By variable(s) if used
/ byvars2           Extra by variables kept for convenience
/ type              Should be C for categorical or N for continuous-numeric
/ adjcntrvar        Variable representing the centre to be used in adjustment
/                   for centre effects in PROC GLM call. Only one variable
/                   allowed. Terms will be generated in the model statement
/                   for modelform=short as:
/                     model response=trtcd centre /ss1 ss2 ss3 ss4;
/                   or for modelform=long as:
/                     model response=trtcd centre trtcd*centre /ss1 ss2 ss3 ss4;
/                   You can use this parameter for a variable other than a
/                   centre but note that whatever variable you choose, if it is
/                   not a categorical or dichotomous variable suitable for use
/                   in the CLASS statement of a PROC GLM call then you will need
/                   to use the glmclass= parameter to supply the correct call.
/ cntrwarn=yes      By default, warn if a centre effect and/or centre-by-
/                   treatment effect is significant. For the short model as
/                   described for the adjcntrvar= parameter, use the centre term.
/                   For the long model, use the centre and centre-by-treatment
/                   effect term.
/ cntrcond=LE 0.05  Condition for significance to apply to the centre effect
/ intercond=LE 0.1  Condition for significance to apply to the treatment*centre
/                   interaction.
/ statsopdest         Default is not to write the glm output to any destination.
/                   You can set this to PRINT or a file such that PROC PRINTTO
/                   understands it. Note that setting it to LOG will not work.
/ errortype=3       Default is to select the error type 3 (Hypothesis type)
/                   treatment arm p-value from the ModelANOVA ODS dataset that
/                   is output from the GLM procedure.
/ modelform=short   Default is to generate the short form of the model statement
/                   as described in the adjcntrvar= parameter description.
/ dsmodelanova      Dataset to append the ModelANOVA datasets to generated by
/                   PROC GLM.
/ hovwarn=yes       Issue a warning message where the homogeneity of variances
/                   shows a significant difference. This will only be done for
/                   one-way ANOVA so if adjcntrvar= is set then the hov*=
/                   parameters will be ignored. A NOTE statement will be
/                   generated where appropriate if a warning is not issued.
/ hovcond=LE 0.05   Condition for meeting HoV significance
/ hovtest=Levene    HoV test to use. You can choose between OBRIEN, BF, Levene,
/                   Levene(type=square) and Levene(type=abs). Levene and
/                   Levene(type=square) are the same. The Bartlett test is not
/                   supported.
/ welch=no          By default, do not calculate ANOVA p-values using the Welch
/                   test for one-way ANOVA where the HoV condition for
/                   significance is met. If Welch is used then the hovtest
/                   defined to hovtest= will be employed in the MEANS statement.
/                   ---------------------------------------------------------
/                   For the following glm*= parameters it is possible to enclose
/                   your code in single quotes and then you can use &respvar 
/                   (the response variable) and &trtvar (the treatment variable)
/                   in your code without causing syntax errors.
/ glmclass          GLM CLASS statement used to override the generated form.
/                   The start word CLASS and ending semicolon will be generated.
/ glmmodel          GLM MODEL statement used to override the generated form.
/                   The start word MODEL and ending semicolon will be generated.
/ glmmeans          GLM MEANS statement used to override the generated form.
/                   The start word MEANS and ending semicolon will be generated.
/ glmweight         GLM WEIGHT statement that can be added as an extra. The
/                   start word WEIGHT and ending semicolon will be generated.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  10Jul06         "missing" option added to tables statements in proc freq
/                      calls so it can act on missing values passed to it by
/                      the %unistats macro.
/ rrb  14Jul06         Header tidy
/ rrb  23Sep06         Dummy datasets are created to avoid "dataset not found"
/                      messages when a stats procedure can not calculate a 
/                      p-value.
/ rrb  13Feb07         "macro called" message added
/ rrb  21Mar07         Cancel format on _pvalue variable throughout (v1.2)
/ rrb  28Mar07         Header tidy regarding "Cochran's Recommendation"
/ rrb  30Jul07         Header tidy
/ rrb  06Jan08         New parameters adjcntrvar= and statsopdest= added for
/                      adjustment for centre effects.
/ rrb  06Jan08         Added errortype= , modelform= and dsmodelanova= for
/                      adjustment for centre effects.
/ rrb  07Jan08         hovwarn=, hovcond=, hovtest= amd welch= added to test and
/                      warn for homogeneity of variances significant difference
/                      for one-way ANOVA and to calculate using Welch test.
/ rrb  08Jan08         Added cntrwarn=, cntrcond= and cntrerrtype= for centre
/                      effect warning.
/ rrb  08Jan08         cntrerrtype= removed. cntrcond= value changed and 
/                      intercond=0.1 added.
/ rrb  13Jan08         cntrwarn= processing changed.
/ rrb  13Jan08         CMH test added so that adjcntrvar= can be used with
/                      categorical variables.
/ rrb  14Jan08         glmclass=, glmmodel=, glmmeans= and glmweight= added so
/                      the user can override the statements generated by the
/                      macro for the main glm call.
/ rrb  19Jan08         %dequote macro used for glm* parameters to allow the user
/                      to put code in single quotes and thereby reference macro
/                      variables &respvar and &trtvar.
/ rrb  19Jan08         Keep all variables in input dataset
/ rrb  26Jan08         Fixed bug with wrong p-value displayed in log
/ rrb  26Jan08         Choosing Fisher or Chi-square now overrides adjcntrvar=
/ rrb  06Apr08         Fixed bug where "Source" variable in _ANOVA dataset was
/                      not in the expected lower case form.
/ rrb  07Apr08         Response variable name given for center effect warning.
/ rrb  13Apr08         glmopdest= replaced by statsopdest= plus made effective
/                      for CMH output.
/ rrb  12May08         byvars2= parameter added
/ rrb  12May08         ods listing close syntax fixed
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unipvals v1.19;

%macro unipvals(dsin=,
             usetest=,
               exact=no,
               dsout=,
              trtvar=,
             respvar=,
              byvars=,
             byvars2=,
                type=,
          adjcntrvar=,
            cntrwarn=yes,
            cntrcond=LE 0.05,
           intercond=LE 0.1,
         statsopdest=,
           errortype=3,
           modelform=short,
        dsmodelanova=,
             hovwarn=yes,
             hovcond=LE 0.05,
             hovtest=Levene,
               welch=no,
            glmclass=,
            glmmodel=,
            glmmeans=,
           glmweight=
              );

%local error dofisher testsel trtcount name1str hovpvalue hovsig;
%let error=0;


          /*-------------------------------------------------*
                   Check we have enough parameters set
           *-------------------------------------------------*/

%if not %length(&dsin) %then %do;
  %let error=1;
  %put ERROR: (unipvals) No input dataset specified to dsin=;
%end;

%if not %length(&dsout) %then %do;
  %let error=1;
  %put ERROR: (unipvals) No output dataset specified to dsout=;
%end;

%if not %length(&trtvar) %then %do;
  %let error=1;
  %put ERROR: (unipvals) No treatment variable specified to trtvar=;
%end;

%if not %length(&respvar) %then %do;
  %let error=1;
  %put ERROR: (unipvals) No response variable specified to respvar=;
%end;

%if not %length(&type) %then %do;
  %let error=1;
  %put ERROR: (unipvals) No type (C)ategorical/(N)umeric specified to type=;
%end;

%if %length(&adjcntrvar) %then %do;
  %if %words(&adjcntrvar) GT 1 %then %do;
    %let error=1;
    %put ERROR: (unipvals) Only one variable allowed. You specified adjcntrvar=&adjcntrvar;
  %end;
%end;

%if &error %then %goto error;

%let type=%substr(%upcase(&type),1,1);
%if "&type" NE "C" and "&type" NE "N" %then %do;
  %let error=1;
  %put ERROR: (unipvals) Type= must be (C)ategorical or (N)umeric;
%end;

%if %length(&usetest) %then %do;
  %let usetest=%upcase(%substr(&usetest,1,1));
  %if "&usetest" NE "C"
  and "&usetest" NE "F"
  and "&usetest" NE "N" %then %do;
    %let error=1;
    %put ERROR: (unipvals) usetest= must be (C)hi-square, (F)isher or
(N)on-parametric;
  %end;
%end;

%if not %length(&exact) %then %let exact=no;
%let exact=%upcase(%substr(&exact,1,1));

%if not %length(&errortype) %then %let errortype=3;

%if not %length(&modelform) %then %let modelform=short;
%let modelform=%upcase(%substr(&modelform,1,1));

%if not %length(&hovwarn) %then %let hovwarn=yes;
%let hovwarn=%upcase(%substr(&hovwarn,1,1));

%if not %length(&hovcond) %then %let hovcond=LE 0.05;

%if not %length(&hovtest) %then %let hovtest=Levene;

%if not %length(&welch) %then %let welch=no;
%let welch=%upcase(%substr(&welch,1,1));

%if not %length(&cntrwarn) %then %let cntrwarn=yes;
%let cntrwarn=%upcase(%substr(&cntrwarn,1,1));

%if not %length(&cntrcond) %then %let cntrcond=LE 0.05;

%if not %length(&intercond) %then %let intercond=LE 0.1;

%if &error %then %goto error;



    /*--------------------------------*
          Define CMH test macro
     *--------------------------------*/

%macro cmh(dsin=,dsout=);

  ods listing close;
  ods output close;

  *- create dummy p-value dataset -;
  data &dsout; 
    length Statistic 8 _test $ 8; 
    retain Prob . _test "CMH";  
    Statistic=2; 
  run;

  *- merge with by values if any -;
  data &dsout; 
    set _unibyvars; 
    do ptr=1 to nobsdummy; 
      set &dsout point=ptr nobs=nobsdummy; 
      output; 
    end; 
  run; 

  %if %length(&statsopdest) %then %do;
    ods listing;
    run;
    proc printto print=&statsopdest;
    run;
  %end;

  ods output CMH=&dsout;

  proc freq data=&dsin;
    by &byvars &byvars2 _test;
    tables &adjcntrvar*&trtvar*&respvar / cmh;
    format &trtvar;
  run;

  %if %length(&statsopdest) %then %do;
    proc printto;
    run;
  %end;

  data &dsout;
    set &dsout(keep=&byvars &byvars2 _test Statistic Prob
              where=(Statistic=2));
    drop Statistic;
    format Prob;
    rename Prob=_pvalue;
  run;
%mend cmh;



    /*--------------------------------*
        Define Chi-square test macro
     *--------------------------------*/

%macro chisq(dsin=,dsout=);
  ods output close;

  *- create dummy p-value dataset -;
  data &dsout; 
    length Statistic $ 12 _test $ 8; 
    retain Prob . _test "CHISQ";  
    Statistic="Chi-Square"; 
  run;

  *- merge with by values if any -;
  data &dsout; 
    set _unibyvars; 
    do ptr=1 to nobsdummy; 
      set &dsout point=ptr nobs=nobsdummy; 
      output; 
    end; 
  run; 

  ods output ChiSq=&dsout;

  proc freq data=&dsin;
    by &byvars &byvars2 _test;
    tables &trtvar*&respvar / missing chisq;
    format &trtvar;
  run;
  data &dsout;
    set &dsout(keep=&byvars &byvars2 _test Statistic Prob
              where=(Statistic="Chi-Square"));
    drop Statistic;
    format Prob;
    rename Prob=_pvalue;
  run;
%mend chisq;



    /*--------------------------------*
       Define Fisher exact test macro
     *--------------------------------*/

%macro fisher(dsin=,dsout=);
  ods output close;

  *- create dummy p-value dataset -;
  data &dsout; 
    length Name1 _test $ 8 Label1 $ 15 cValue1 $ 6; 
    retain nValue1 . cValue1 Label1 " " _test "FISHER";  
    Name1="XP2_FISH"; 
  run;

  *- merge with by values if any -;
  data &dsout; 
    set _unibyvars; 
    do ptr=1 to nobsdummy; 
      set &dsout point=ptr nobs=nobsdummy; 
      output; 
    end; 
  run; 


  ods output FishersExact=&dsout;

  proc freq data=&dsin;
    by &byvars &byvars2 _test;
    tables &trtvar*&respvar / missing fisher;
    format &trtvar;
  run;
  data &dsout;
    set &dsout(keep=&byvars &byvars2 _test Name1 nValue1
              where=(Name1="XP2_FISH"));
    drop Name1;
    format nValue1;
    rename nValue1=_pvalue;
  run;
%mend fisher;







          /*-------------------------------------------------*
                               Process data
           *-------------------------------------------------*/           

*- in case input dataset has modifiers -;
data _pvaldsin;
  set &dsin;
run;


*- sort by by variables -;
%if %length(&byvars.&byvars2) %then %do;
  proc sort data=_pvaldsin;
    by &byvars &byvars2;
  run;
%end;


*- count how many treatment arms -;
proc sql noprint;
  select count(distinct(&trtvar)) into :trtcount 
    separated by " " from _pvaldsin;
quit;


*- Create a dataset with just the by values in -;
*- so that it can be merged in with the p-value -;
*- dummy datasets. -;
%if %length(&byvars.&byvars2) %then %do; 
  proc summary nway missing data=_pvaldsin; 
    class &byvars &byvars2; 
    output out=_unibyvars(drop=_type_ _freq_); 
  run; 
%end; 


%if "&type" EQ "N" 
 and "&usetest" EQ "N"
 and &trtcount GT 2
 and "&exact" EQ "Y" %then %do;
  %let exact=N;
  %put WARNING: (unipvals) Exact test requested but is not available for
&trtcount treatment;
  %put WARNING: (unipvals) arms (only 2 allowed) so exact test will not be
used.;
%end;






          /*-------------------------------------------------*
                             Categorical data
           *-------------------------------------------------*/ 

%if "&type" EQ "C" %then %do;


  %if not %length(&usetest) and not %length(&adjcntrvar) %then %do;

    ods listing close;
    

      /*--------------------------------*
            Get expected cell counts
       *--------------------------------*/

    proc freq data=_pvaldsin noprint;
      by &byvars &byvars2;
      tables &trtvar*&respvar / missing sparse outexpect out=_expected(drop=percent);
      format &trtvar;
    run;


      /*--------------------------------*
            Determine test to be used
       *--------------------------------*/

    data _whichtest(keep=&byvars &byvars2 _test);
      length _test $ 8;
      retain _below1 _below5 _cells 0;
      set _expected;
      by &byvars &byvars2;
      if first.%scan(&byvars &byvars2,-1,%str( )) then do;
        _below1=0;
        _below5=0;
        _cells=0;
      end;
      _cells=_cells+1;
      if expected < 1 then _below1=_below1+1;
      if expected < 5 then _below5=_below5+1;
      if last.%scan(&byvars &byvars2,-1,%str( )) then do;
        _test="CHISQ";
        if _cells<5 and _below5>0 then _test="FISHER";
        else if _cells>4 and (_below1>0 or _below5>(_cells/5)) then
_test="FISHER";
        output;
      end;
    run;


      /*--------------------------------*
          Find out what tests selected
       *--------------------------------*/
  
    proc sql noprint;
      select distinct(_test) into :testsel
      separated by " " from _whichtest;
    quit;
  

      /*--------------------------------*
          Split data according to test
       *--------------------------------*/

    %if "&testsel" EQ "FISHER" %then %do;
      %let dodsets=_dofisher;
      %let pvaldsets=_fisher;

      data _dofisher;
        merge _whichtest &dsin;
        by &byvars &byvars2;
      run;   
      %fisher(dsin=_dofisher,dsout=_fisher)  
    %end;
    
    %else %if "&testsel" EQ "CHISQ" %then %do;
      %let dodsets=_dochisq;
      %let pvaldsets=_chisq;

      data _dochisq;
        merge _whichtest &dsin;
        by &byvars &byvars2;
      run;   
      %chisq(dsin=_dochisq,dsout=_chisq)
    %end;
    
    %else %do;   
      %let dodsets=_dofisher _dochisq;
      %let pvaldsets=_fisher _chisq;
      
      data _dofisher _dochisq;
        merge _whichtest &dsin;
        by &byvars &byvars2;
        if _test="FISHER" then output _dofisher;
        else if _test="CHISQ" then output _dochisq;
      run;
      %fisher(dsin=_dofisher,dsout=_fisher)
      %chisq(dsin=_dochisq,dsout=_chisq)
    %end;



      /*--------------------------------*
         Bring p-value datasets together
       *--------------------------------*/

    ods listing;

    data &dsout;
      set &pvaldsets;
      %if %length(&byvars.&byvars2) %then %do;
        by &byvars &byvars2;
      %end;
    run;
    
    proc datasets nolist;
      delete _expected _whichtest &pvaldsets &dodsets;
    run;
    quit;

    
  %end;  %*- of if not length(usetest) -;



  %else %if "&usetest" EQ "F" %then %do;     %*- Fisher exact -;

    ods listing close;
    
    data _pvaldsin;
      retain _test "FISHER  ";
      set _pvaldsin;
    run;
    
    %fisher(dsin=_pvaldsin,dsout=&dsout);

    ods listing;
    
    proc datasets nolist;
      delete _pvaldsin;
    run;
    quit;

  %end;   %*- of if usetest eq F -;


  

  %else %if "&usetest" EQ "C" %then %do;     %*- Chi-square -;

    ods listing close;
    
    data _pvaldsin;
      retain _test "CHISQ   ";
      set _pvaldsin;
    run;
    
    %chisq(dsin=_pvaldsin,dsout=&dsout);
 
    ods listing;

    proc datasets nolist;
      delete _pvaldsin;
    run;
    quit;
       
  %end;   %*- of if usetest eq C -;


  %else %if %length(&adjcntrvar) %then %do;     %*- CMH test -;

    ods listing close;
    
    data _pvaldsin;
      retain _test "CMH     ";
      set _pvaldsin;
    run;
    
    %cmh(dsin=_pvaldsin,dsout=&dsout);

    ods listing;
    
    proc datasets nolist;
      delete _pvaldsin;
    run;
    quit;

  %end;   %*- end of CMH test -;


%end;  %*- of if type eq C -;




          /*-------------------------------------------------*
                     Numeric non-categorical data
           *-------------------------------------------------*/ 

%else %if "&type" EQ "N" %then %do;


  %if "&usetest" EQ "N" %then %do;  %*- non-parametric test -;
  
    ods listing close;

    ods output close; 

    *- create dummy p-value dataset -;
    data _WILC; 
      length Name1 $ 8 Label1 $ 15 cValue1 $ 6; 
      retain nValue1 . cValue1 Label1 " "; 
      Name1="P_KW"; 
      output; 
      Name1="XP2_WIL"; 
      output; 
      Name1="P2_WIL"; 
      output; 
    run;

    *- merge with by values if any -;
    data _WILC; 
      set _unibyvars; 
      do ptr=1 to nobswilc; 
        set _WILC point=ptr nobs=nobswilc; 
        output; 
      end; 
    run; 


    %if &trtcount GT 2 %then %do;
      ods output KruskalWallisTest=_WILC;
    %end;
    %else %do;
      ods output WilcoxonTest=_WILC;
    %end;

    proc npar1way data=_pvaldsin wilcoxon;
    %if %length(&byvars.&byvars2) %then %do;
      by &byvars &byvars2;
    %end;    
      class &trtvar;
      var &respvar;
    %if "&exact" EQ "Y" %then %do;
      exact;
    %end;
      format &trtvar ;
    run;

    ods listing;   

    data &dsout;
      retain _test "NPAR1WAY";
      set _WILC;
      if Name1=
        %if &trtcount GT 2 %then %do;
          "P_KW"
        %end;
        %else %do;
          %if "&exact" EQ "Y" %then %do;
            "XP2_WIL"
          %end;
          %else %do;
            "P2_WIL"
          %end;
        %end;
        ;
      format nValue1;
      rename nValue1=_pvalue;
      drop Name1 Label1 cValue1;
    run;

    proc datasets nolist;
      delete _pvaldsin _WILC;
    run;
    quit;


  %end;

  
  %else %do;   


    /*----------------------------------------*
                  Parameteric ANOVA
     *----------------------------------------*/

    /*-------------------*
       HoV test and warn  
     *-------------------*/

    ods listing close;
    ods output close;

    %let hovpvalue=99.0;
    %let hovsig=0;

    %if not %length(&adjcntrvar) %then %do;
    
      ods output HOVFTest=_hovftest;
  
      proc glm data=_pvaldsin;
      %if %length(&byvars.&byvars2) %then %do;
        by &byvars &byvars2;
      %end;
        class &trtvar;
        model &respvar=&trtvar;
        means &trtvar / hovtest=&hovtest;
        format &trtvar ;
      run;

      data _null_;
        set _hovftest(where=(upcase(Source)="%upcase(&trtvar)"));
        call symput('hovpvalue',put(ProbF,6.3));
      run;

      %if %sysevalf(&hovpvalue &hovcond) %then %let hovsig=1;

      %if "&hovwarn" EQ "Y" and &hovsig %then %do;
        %put WARNING: (unipvals) p-value=&hovpvalue &hovcond for hovtest=&hovtest;
      %end;
      %else %put NOTE: (unipvals) p-value=&hovpvalue for hovtest=&hovtest;

      proc datasets nolist;
        delete _hovftest;
      run;
      quit;

    %end;


    *- create dummy _anova p-value dataset -;
    data _anova; 
      retain HypothesisType 3 ProbF . Source "%lowcase(&trtvar)" ;  
    run;

    *- merge with by values if any -;
    data _anova; 
      set _unibyvars; 
      do ptr=1 to nobsdummy; 
        set _anova point=ptr nobs=nobsdummy; 
        output; 
      end; 
    run; 

    *- create dummy _welch p-value dataset -;
    data _welch;
      retain ProbF . Source "%lowcase(&trtvar)" ;
    run;

    *- merge with by values if any -;
    data _welch; 
      set _unibyvars; 
      do ptr=1 to nobsdummy; 
        set _welch point=ptr nobs=nobsdummy; 
        output; 
      end; 
    run;


    %if %length(&statsopdest) %then %do;
      ods listing;
      run;
      proc printto print=&statsopdest;
      run;
    %end;

    ods output ModelANOVA=_anova;

    %if not %length(&adjcntrvar) and "&welch" EQ "Y" and &hovsig %then %do;
      ods output Welch=_welch;
    %end;

    proc glm data=_pvaldsin;
    %if %length(&byvars.&byvars2) %then %do;
      by &byvars &byvars2;
    %end;
      %if %length(&glmclass) %then %do;
        CLASS %unquote(%dequote(&glmclass)) ;
      %end;
      %else %do;
        CLASS &trtvar &adjcntrvar;
      %end;
      %if %length(&adjcntrvar) %then %do;
        %if "&modelform" EQ "L" %then %do;
          %if %length(&glmmodel) %then %do;
            MODEL %unquote(%dequote(&glmmodel)) ;
          %end;
          %else %do;
            MODEL &respvar=&trtvar &adjcntrvar &trtvar*&adjcntrvar / ss1 ss2 ss3 ss4;
          %end;
        %end;
        %else %do;
          %if %length(&glmmodel) %then %do;
            MODEL %unquote(%dequote(&glmmodel)) ;
          %end;
          %else %do;
            MODEL &respvar=&trtvar &adjcntrvar / ss1 ss2 ss3 ss4;
          %end;
        %end;
        %if %length(&glmmeans) %then %do;
          MEANS %unquote(%dequote(&glmmeans)) ;
        %end;
        %else %do;
          MEANS &trtvar ;
        %end;
      %end;
      %else %do;
        %if %length(&glmmodel) %then %do;
          MODEL %unquote(%dequote(&glmmodel)) ;
        %end;
        %else %do;
          MODEL &respvar=&trtvar ;
        %end;
        %if %length(&glmmeans) %then %do;
          MEANS %unquote(%dequote(&glmmeans)) ;
        %end;
        %else %do;
          %if "&welch" EQ "Y" and &hovsig %then %do;
%put NOTE: (unipvals) PROC GLM will use means statement "means &trtvar / hovtest=&hovtest welch;" %eqsuff(&byvars);
            MEANS &trtvar / hovtest=&hovtest welch;
          %end;
          %else %do;
            MEANS &trtvar;
          %end;
        %end;
      %end;
      %if %length(&glmweight) %then %do;
        WEIGHT %unquote(%dequote(&glmweight)) ;
      %end;
      format &trtvar ;
    run;

    ods listing;
    run;
    %if %length(&statsopdest) %then %do;
      proc printto;
      run;
    %end;

    %if %length(&dsmodelanova) %then %do;
      proc append force base=&dsmodelanova data=_anova;
      run;
    %end;

    %if not %length(&adjcntrvar) and "&welch" EQ "Y" and &hovsig %then %do;
      data &dsout;
        retain _test "WELCH   ";
        set _welch(keep=&byvars &byvars2 ProbF Source
                  where=(upcase(Source)="%upcase(&trtvar)")
                 rename=(ProbF=_pvalue));
        drop Source;
        format _pvalue;
      run;
    %end;
    %else %do;
      data &dsout;
        retain _test "ANOVA   ";
        set _anova(keep=&byvars &byvars2 HypothesisType ProbF Source
                  where=(HypothesisType=&errortype and upcase(Source)="%upcase(&trtvar)")
                 rename=(ProbF=_pvalue));
        drop HypothesisType Source;
        format _pvalue;
      run;
      %if "&cntrwarn" EQ "Y" and %length(&adjcntrvar) %then %do;
        %if "&modelform" EQ "L" %then %do;
          data _null_;
            set _anova(where=(HypothesisType=&errortype));
            if upcase(Source) EQ "%upcase(&trtvar*&adjcntrvar)" and ProbF &intercond then
put "WARNING: (unipvals) ANOVA p-value for %upcase(&adjcntrvar*&trtvar) = " ProbF "&intercond for %upcase(&respvar) " %eqsuff(&byvars);
            else if upcase(Source) EQ "%upcase(&adjcntrvar)" and ProbF &cntrcond then
put "WARNING: (unipvals) ANOVA p-value for %upcase(&adjcntrvar) = " ProbF "&cntrcond for %upcase(&respvar) " %eqsuff(&byvars) ;
          run;
        %end;
        %else %do;
          data _null_;
            set _anova(where=(HypothesisType=&errortype 
                              and upcase(Source) EQ "%upcase(&adjcntrvar)"));
            if ProbF &cntrcond then
put "WARNING: (unipvals) ANOVA p-value for %upcase(&adjcntrvar) = " ProbF "&cntrcond for %upcase(&respvar) " %eqsuff(&byvars);
          run;
        %end;
      %end;
    %end;

    proc datasets nolist;
      delete _pvaldsin _anova _welch;
    run;
    quit;  
    
    
  %end;
    
%end;   %*- end of if type is N -;


%if %length(&byvars.&byvars2) %then %do;
  proc datasets nolist;
    delete _unibyvars;
  run;
  quit;
%end;

%goto skip;
%error:
%put ERROR: (unipvals) Leaving macro due to error(s) listed;
%skip:
%mend;
