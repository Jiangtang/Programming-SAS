/*<pre><b>
/ Program      : unipvals.sas
/ Version      : 7.1
/ Author       : Roland Rashleigh-Berry
/                Joachim Klinger
/ Date         : 29-Jul-2012
/ Purpose      : Clinical reporting macro to calculate statistics values and
/                p-values for the %unistats macro.
/ SubMacros    : %words %qdequote %nobs + internally defined macros
/ Notes        : Calculates Chi-square or Fisher's exact for categorical data,
/                the ANOVA or t Test Probability for parametric numeric data
/                and Kruskal-Wallis or Wilcoxon rank sum test for non-parametric
/                numeric data.
/
/                For categorical data, unless you override the test selection
/                using usetest=, Chi-square statistics, the Fisher Exact test
/                or no test are used (the latter for 2x1 or 1x2 tables where
/                calculation of a p-values is not appropriate). If, for 2x2
/                tables, the expected cell count for any cell is less than 5 or
/                for larger tables a single expected cell count is less than one
/                or more than 20% of the expected cell counts are less than 5,
/                then the Fisher exact test is used (this rule might be called
/                "Cochran's Recommendation" but please check in "Siegel, S.
/                (1956) Non-Parametric Statistics for the Behavioral Sciences"
/                for confirmation) otherwise the Chi-Square test is used.
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
/                The variables kept in the output dataset are the by variables,
/                _statvalue, _pvalue and _test, the latter of which will will
/                be set to "CHISQ" or "FISHER" for categorical analysis, "ANOVA"
/                for continuous numeric analysis or "NPAR1WAY" which applies to
/                the Kruskal-Wallis test and the Wilcoxon rank sum test (for
/                only two treatment arms). "ANOVA" will be replaced by "glmwelch"
/                if the glmwelch test is used.
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
/                   variables will overrride use of CMH if glmadjcntrvar= is set.
/ exact=no          By default, do not use an exact test for variables that
/                   require a non-parametric test (setting it to yes can
/                   consume a very large amount of processing time).
/ usettest=no       By default, do not use proc ttest for continuous numeric
/                   variables for two treatment arms but rather use proc glm
/                   ANOVA instead. Set this to yes to use proc ttest but none
/                   of the glm parameters will be accepted.
/ sattcond=<0.1     This applies to proc ttest and is the condition of the 
/                   Probability F test value for the equality of variances such
/                   that the Satterthwaite approximation T value and ProbT value
/                   get used instead of the Pooled T value and ProbT value.
/ dsout             Output dataset
/ trtvar            Treatment variable (make sure "total treatment" is not
/                   present in the input data).
/ respvar           Response variable
/ byvars            By variable(s) if used
/ byvars2           Extra by variables kept for convenience
/ type              Should be C for categorical or N for continuous-numeric
/                   ------------------------------------------------------------
/ freqsept1-20      Proc freq septuplet statements for the placement of values 
/                   from ods tables in the output report/dataset in the form:
/                      varname(s)#keyword#missing#dset#statno#statord#code
/                   where "varname(s)" is the variable name or list of variable
/                   names separated by spaces,
/                  "keyword" is the proc freq option name,
/                  "missing" is "Y" or "N" for whether to include missing values
/                   in the calculation,
/                  "dset" is the ods table name with the attached where clause
/                   (if you prefix this table name with "Tr" it will transpose
/                   the table so that Name1 will become the variable name and
/                   Value1 its value),
/                  "statno"=1-9 for the STAT column number (you can also specify
/                   a treatment arm such as TRT1, TRT2 etc.),
/                  "statord" is the order number in the list of descriptive
/                   statistics and
/                  "code" is the code to format the value(s) for variables in
/                   the ods table.
/                   ---------------------------------------------------------
/                   For the following glm*= parameters it is possible to enclose
/                   your code in single quotes and then you can use &respvar 
/                   (the response variable) and &trtvar (the treatment variable)
/                   in your code without causing syntax errors.
/ class             CLASS statement used to override the generated form.
/                   The start word CLASS and ending semicolon will be generated.
/ model             MODEL statement used to override the generated form.
/                   The start word MODEL and ending semicolon will be generated.
/ means             MEANS statement used to override the generated form.
/                   The start word MEANS and ending semicolon will be generated.
/ lsmeans           LSMEANS statement used to override the generated form.
/                   The start word LSMEANS and ending semicolon will be
/                   generated. Example: lsmeans=treat/cl pdiff adjust=t
/ odstables         ODS tablename statment to store a dataset; per default,
/                   _odstables will be used as output dataset name
/                   Example: odstables=LSMeanCL LSMeanDiffCL will create
/                   datasets named _LSMeanCL and _LSMEeanDiffCL .
/ quad1-9           quadruplet statements for the placement of values from
/                   ods tables in the output/report dataset in the form:
/                      dset#statno#statord#code
/                   where "dset" is the ods table name with the attached where
/                   clause, 
/                  "statno"=1-9 for the STAT column number (you can also
/                   specify a treatment arm such as TRT1, TRT2 etc.),
/                  "statord" is the order number in the list of descriptive
/                   statistics, and 
/                  "code" is the code to format the value(s) in the ods table.
/ weight            WEIGHT statement that can be added as an extra. The
/                   start word WEIGHT and ending semicolon will be generated.
/ adjcntrvar        Variable representing the centre to be used in adjustment
/                   for centre effects in PROC  call. Only one variable
/                   allowed. Terms will be generated in the model statement
/                   for modelform=short as:
/                     model response=trtcd centre /ss1 ss2 ss3 ss4;
/                   or for modelform=long as:
/                     model response=trtcd centre trtcd*centre /ss1 ss2 ss3 ss4;
/                   You can use this parameter for a variable other than a
/                   centre but note that whatever variable you choose, if it is
/                   not a categorical or dichotomous variable suitable for use
/                   in the CLASS statement of a PROC  call then you will need
/                   to use the class= parameter to supply the correct call.
/ errortype=3       Default is to select the error type 3 (Hypothesis type)
/                   treatment arm p-value from the ModelANOVA ODS dataset that
/                   is output from the  procedure.
/ modelform=short   Default is to generate the short form of the model 
/                   statement as described in the adjcntrvar= parameter
/                   description.
/ dsmodelanova      Dataset to append the ModelANOVA datasets to generated by
/                   PROC .
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
/ welch=no          By default, do not calculate ANOVA p-values using the welch
/                   test for one-way ANOVA where the HoV condition for
/                   significance is met. If welch is used then the hovtest
/                   defined to hovtest= will be employed in the MEANS 
/                   statement.
/ fisherid=^        Symbol to suffix formatted p-values for the Fisher exact
/                   test.
/ chisqid=~         Symbol to suffix formatted p-values for the Chi-square test
/ cmhid=$           Symbol to suffix formatted p-values for the CMH test
/ anovaid=#         Symbol to suffix formatted p-values for the ANOVA
/ welchid=&         Symbol to suffix formatted p-values for the Welch test
/ nparid=§          Symbol to suffix formatted p-values for the non-parametric
/                   Kruskal-Wallis test (or Wilcoxon rank sum test).
/ ttestid=$         Symbol to suffix formatted p-values for the Pooled ttest
/ sattid=&          Symbol to suffix formatted p-values for the Satterthwaite
/                   approximation of the ttest.
/ cntrwarn=yes      By default, warn if a centre effect and/or centre-by-
/                   treatment effect is significant. For the short model as
/                   described for the adjcntrvar= parameter, use the centre
/                   term. For the long model, use the centre and
/                   centre-by-treatment effect term.
/ cntrcond=LE 0.05  Condition for significance to apply to the centre effect
/ intercond=LE 0.1  Condition for significance to apply to the treatment*centre
/                   interaction.
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
/ rrb  06Jan08         New parameters glmadjcntrvar= and statsopdest= added for
/                      adjustment for centre effects.
/ rrb  06Jan08         Added glmerrortype= , glmmodelform= and glmdsmodelanova= 
/                      for adjustment for centre effects.
/ rrb  07Jan08         glmhovwarn=, glmhovcond=, glmhovtest= amd glmwelch= added 
/                      to test and warn for homogeneity of variances significant
/                      difference for one-way ANOVA and to calculate using
/                      glmwelch test.
/ rrb  08Jan08         Added glmcntrwarn=, glmcntrcond= and cntrerrtype= for 
/                      centre effect warn
/                      ng.
/ rrb  08Jan08         cntrerrtype= removed. glmcntrcond= value changed and 
/                      glmintercond=0.1 added.
/ rrb  13Jan08         glmcntrwarn= processing changed.
/ rrb  13Jan08         CMH test added so that glmadjcntrvar= can be used with
/                      categorical variables.
/ rrb  14Jan08         glmclass=, glmmodel=, glmmeans= and glmweight= added so
/                      the user can override the statements generated by the
/                      macro for the main glm call.
/ rrb  19Jan08         %qdequote macro used for glm* parameters to allow the user
/                      to put code in single quotes and thereby reference macro
/                      variables &respvar and &trtvar.
/ rrb  19Jan08         Keep all variables in input dataset
/ rrb  26Jan08         Fixed bug with wrong p-value displayed in log
/ rrb  26Jan08         Choosing Fisher or Chi-square now overrides glmadjcntrvar=
/ rrb  06Apr08         Fixed bug where "Source" variable in _ANOVA dataset was
/                      not in the expected lower case form.
/ rrb  07Apr08         Response variable name given for center effect warning.
/ rrb  13Apr08         glmopdest= replaced by statsopdest= plus made effective
/                      for CMH output.
/ rrb  12May08         byvars2= parameter added
/ rrb  12May08         ods listing close syntax fixed
/ rrb  10Feb09         Bug with use of _unibyvars causing both CHISQ and FISHER
/                      tests for the same BY values fixed.
/ rrb  11Feb09         Proc freq no longer called for 2x1 tables to calculate
/                      CHISQ and FISHER as this is meaningless.
/ rrb  12Feb09         Further limitations on calculating p-values for 2x1
/                      tables added for v1.22
/ rrb  19Feb09         A redesign on calculating p-values for 2x1 tables added
/                      for v1.23
/  JK  03Mar09         Model statement in proc glm only called if glmmeans
/                      statement is not empty. glmlsmeans= and odstables= 
/                      parameters added. glmwelch test omitted if GLMMODEL
/                      statement given.
/ rrb  05Mar09         Changes made to avoid putting out "uninitialized"
/                      messages (v1.25).
/ rrb  12Jun09         Incorrect variables in _dummypval fixed for v1.26
/ rrb  17Jun09         Call of stats procs avoided for categorical variables 
/                      where _respcnt not > 1 in all cases for v1.27
/  JK  06Jul09         Incorrect use of missing values corrected for v1.28 for
/                      p-values of Fisher- and Chi-square test. Re-route stat
/                      output for Fisher- and Chi-square test to statsopdest.
/                      Shorten print-out for CMH stat output
/  JK  10Jul09         Bug with CHI/Fisher test selection in case when missing 
/                      values are present fixed (v1.29)
/  JK  13Jul09         Bug with CHI/Fisher test selection fixed (v1.30)
/ rrb  15Jul09         Calculation of _trtcnt added. Call of stats procs
/                      avoided for categorical variables where _trtcnt not > 1
/                      in all cases (v1.31)
/  JK  21Aug09         Bug while using missing character response variables 
/                      with CHI/Fisher test fixed (v1.32)
/ rrb  23Aug09         statsopdest= parameter and processing removed from this
/                      macro. This will now be handled by %unistats (v1.33)
/ rrb  12Oct09         Calls to %dequote changed to calls to %qdequote due to
/                      macro renaming (v1.34)
/ rrb  01Nov10         Statistics value _statvalue now kept with pvalue _pvalue
/                      in output dataset. This statistics value is a regulatory
/                      requirement for China's SFDA (v1.35)
/ rrb  21Nov10         Variables TRT9998 and TRT9999 for the stats value and the
/                      p-value are now created in a submacro. odstables=
/                      renamed to glmodstables=. statvallbl= and pvallbl=
/                      parameters added to pass to %_uniquad. Major changes,
/                      hence (v2.0)
/ rrb  07Dec10         Bug with npar1way by variables fixed (v2.1)
/ rrb  13Mar11         Statistics column variables now renamed as STAT1, STAT2
/                      etc. (v3.0)
/ rrb  21Mar11         freqsept(1-20)= parameters added (v4.0)
/ rrb  28Mar11         Bug with omitting missing pvalues addressed. Parameters
/                      pvalfmt= and statvalfmt= added (v4.1)
/ rrb  08May11         Code tidy
/ rrb  26May11         Recoded merging of dummy pvalue datasets with less use of
/                      point= option (v4.2)
/ rrb  26Sep11         freqsept and glmquad statno processing changed so that
/                      instead of just specifying a STAT column number you can
/                      set it to the treatment variable name such as TRT1, TRT2
/                      etc. but if you assign a new _statord number using this
/                      method then you have to assign a label to _statlabel in a
/                      filtercode call. Major change hence (v5.0)
/ rrb  27Sep11         Header tidy
/ rrb  01Oct11         Tidied up description of glmquad= and freqsept=
/ rrb  10Oct11         "glm" prefix dropped from parameters since a different
/                      procedure can be declared to modelproc= parameter (v6.0)
/ rrb  05Nov11         usettest=, sattcond=, ttestid= and sattid= parameters
/                      added for "proc ttest" and the Satterthwaite
/                      approximation (v7.0)
/ rrb  18Jul12         Internally defined macro names now start with an 
/                      underscore (v7.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/
 
%put MACRO CALLED: unipvals v7.1;
 
%macro unipvals(dsin=,
             varname=,
             usetest=,
               exact=no,
            usettest=no,
            sattcond=<0.1,
               dsout=,
              trtvar=,
             respvar=,
              byvars=,
             byvars2=,
                type=,
             pvalfmt=p63val.,
          statvalfmt=6.2,
           npvalstat=MEAN,
           modelproc=GLM,
           errortype=3,
           modelform=short,
        dsmodelanova=,
             hovwarn=yes,
             hovcond=LE 0.05,
             hovtest=Levene,
               welch=no,
               class=,
               model=,
               means=,
             lsmeans=,
           odstables=,
               quad1=,
               quad2=,
               quad3=,
               quad4=,
               quad5=,
               quad6=,
               quad7=,
               quad8=,
               quad9=,
              weight=,
          adjcntrvar=,
            cntrwarn=yes,
            cntrcond=LE 0.05,
           intercond=LE 0.1,
             anovaid=#,
             ttestid=#,
             welchid=&,
              sattid=&,
             misspct=,
             pvalids=yes,
            fisherid=^,
             chisqid=~,
               cmhid=$,
              nparid=§,
           freqsept1=,
           freqsept2=,
           freqsept3=,
           freqsept4=,
           freqsept5=,
           freqsept6=,
           freqsept7=,
           freqsept8=,
           freqsept9=,
          freqsept10=,
          freqsept11=,
          freqsept12=,
          freqsept13=,
          freqsept14=,
          freqsept15=,
          freqsept16=,
          freqsept17=,
          freqsept18=,
          freqsept19=,
          freqsept20=
              );
 
  %local errflag err wrn dofisher testsel trtcount name1str hovpvalue hovsig odstable i;
  %let wrn=WAR%str(NING);
  %let err=ERR%str(OR);
  %let errflag=0;
 
 
          /*-------------------------------------------------*
                   Check we have enough parameters set
           *-------------------------------------------------*/
 
  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (unipvals) No input dataset specified to dsin=;
  %end;
 
  %if not %length(&dsout) %then %do;
    %let errflag=1;
    %put &err: (unipvals) No output dataset specified to dsout=;
  %end;
 
  %if not %length(&trtvar) %then %do;
    %let errflag=1;
    %put &err: (unipvals) No treatment variable specified to trtvar=;
  %end;
 
  %if not %length(&respvar) %then %do;
    %let errflag=1;
    %put &err: (unipvals) No response variable specified to respvar=;
  %end;
 
  %if not %length(&type) %then %do;
    %let errflag=1;
    %put &err: (unipvals) No type (C)ategorical/(N)umeric specified to type=;
  %end;
 
  %if %length(&adjcntrvar) %then %do;
    %if %words(&adjcntrvar) GT 1 %then %do;
      %let errflag=1;
      %put &err: (unipvals) Only one variable allowed. You specified adjcntrvar=&adjcntrvar;
    %end;
  %end;
 
  %if &errflag %then %goto exit;

  %if %sysfunc(cexist(&dsout)) %then %do;
    proc datasets nolist memtype=data;
      delete &dsout;
    run;
    quit;
  %end;

 
  %let type=%substr(%upcase(&type),1,1);
  %if "&type" NE "C" and "&type" NE "N" %then %do;
    %let errflag=1;
    %put &err: (unipvals) Type= must be (C)ategorical or (N)umeric;
  %end;
 
  %if %length(&usetest) %then %do;
    %let usetest=%upcase(%substr(&usetest,1,1));
    %if "&usetest" NE "C"
    and "&usetest" NE "F"
    and "&usetest" NE "N" %then %do;
      %let errflag=1;
      %put &err: (unipvals) usetest= must be (C)hi-square, (F)isher or (N)on-parametric;
    %end;
  %end;


  %let varname=%upcase(&varname);

  %if not %length(&modelproc) %then %let modelproc=GLM;
  %let modelproc=%upcase(&modelproc);

  %if not %length(&usettest) %then %let usettest=no;
  %let usettest=%upcase(%substr(&usettest,1,1));
  %if not %length(&sattcond) %then %let sattcond=<0.1;

  %if not %length(&pvalids) %then %let pvalids=yes;
  %let pvalids=%upcase(%substr(&pvalids,1,1));

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
 
  %if &errflag %then %goto exit;


      /*--------------------------------*
            Define UNIQUAD macro
       *--------------------------------*/ 
 
  %macro _uniquad(quad);

    %local statno statcol;
    %let statno=%scan(&quad,2,#);
    %if %length(%sysfunc(compress(&statno,0123456789))) EQ 0
      %then %let statcol=STAT&statno;
    %else %let statcol=&statno;

    data _uniquadupd;
      length &statcol $ 30 _statord 8 _test $ 8;
      set %scan(&quad,1,#);
      if _test=" " then _test=" ";
      _statord=%scan(&quad,3,#);
      &statcol=%scan(&quad,4,#);
      KEEP &byvars &byvars2 _statord _test &statcol;
    run;

    %if not %sysfunc(exist(&dsout)) %then %do;
      data &dsout;
        set _uniquadupd;
      run;
    %end;
    %else %do;
      data &dsout;
        update &dsout _uniquadupd;
        by &byvars &byvars2 _statord;
      run;
    %end;

    proc datasets nolist memtype=data;
      delete _uniquadupd;
    run;
    quit;
 
  %mend _uniquad; 



      /*--------------------------------*
            Define UNISEPT macro
       *--------------------------------*/ 
 
  %macro _unisept(sept);

    %local statno statcol odstab trodstab oneway usemiss keyword keyword2
           bytreat;
    %let statno=%scan(&sept,5,#);
    %if %length(%sysfunc(compress(&statno,0123456789))) EQ 0
      %then %let statcol=STAT&statno;
    %else %let statcol=&statno;

    %let usemiss=%upcase(%substr(%sysfunc(dequote(%scan(&sept,3,#))),1,1));
    %let odstab=%scan(%scan(&sept,4,#),1,%str( =%());
    %let trodstab=;
    %if "%upcase(%substr(&odstab,1,2))" = "TR" 
     and "%upcase(%sysfunc(subpad(&odstab,1,9)))" NE "TRENDTEST" %then %do;
      %let trodstab=&odstab;
      %let odstab=%substr(&odstab,3);
    %end;
    %let oneway=;
    %let bytreat=;
    %let keyword=%scan(&sept,2,#);
    %let keyword2=%upcase(%scan(&keyword,1,%str( =%()));
    %if %sysfunc(indexw(BINOMIAL TESTF TESTP,&keyword2))
      %then %let oneway=Y;
    %if &oneway = Y %then %let bytreat=&trtvar;

    %if %length(&bytreat) %then %do;
      proc sort data=_pvaldsin;
        by &bytreat &byvars &byvars2;
      run;
    %end;
 
    ods output &odstab=&odstab;

    proc freq data=_pvaldsin;
      by &bytreat &byvars &byvars2;
      where
      %if &usemiss NE Y %then %do;
        not missing(&respvar)
      %end;
      ;
      %if &oneway = Y %then %do;
        tables _statname / &keyword;
      %end;
      %else %do;
        tables &trtvar*&respvar / &keyword;
      %end;
      format &trtvar;
    run;


    %if %length(&trodstab) %then %do;
      proc sort data=&odstab out=&trodstab;
        by &bytreat &byvars &byvars2;
      run;

      proc transpose data=&trodstab(where=(Name1 NE " ")) out=&trodstab;
        by &bytreat &byvars &byvars2;
        var nvalue1;
        id Name1;
      run;
    %end;

    data _uniquadupd;
      length &statcol $ 30 _statord 8 _test $ 8;
      set %scan(&sept,4,#);
      by &bytreat &byvars &byvars2;
      if not last.%scan(&bytreat &byvars &byvars2,-1,%str( )) then do;
        put "&err: (unipvals) The unisept submacro has detected that you are trying";
        put "  to add more than one observation in each by group to the output for the";
        put "  by group: &bytreat &byvars &byvars2.";
        put "  You need to select only one observation for this by use of a where clause";
        put "  in your 4th sept parameter dataset segment: %scan(&sept,4,#)";
        put (_all_) (=);
        stop;
      end;
      if _test=" " then _test=" ";
      _statord=%scan(&sept,6,#);
      &statcol=%scan(&sept,7,#);
      KEEP &byvars &byvars2 _statord _test &statcol;
    run;

    %if not %sysfunc(exist(&dsout)) %then %do;
      data &dsout;
        set _uniquadupd;
      run;
    %end;
    %else %do;

      data &dsout;
        update &dsout _uniquadupd;
        by &byvars &byvars2 _statord;
      run;
    %end;

    proc datasets nolist memtype=data;
      delete _uniquadupd &odstab &trodstab;
    run;
    quit;
 
  %mend _unisept;


      /*--------------------------------*
            Define NOTEST macro
       *--------------------------------*/
 
  %macro _uninotest(dsin=,dsout=);
 
    *- create dummy p-value dataset -;
    data _dummypval; 
      retain _statvalue _pvalue . _test "NOTEST  ";  
    run;
 
    proc summary nway missing data=&dsin; 
      class &byvars &byvars2; 
      output out=_unibynone(drop=_type_ _freq_); 
    run; 
 
    *- merge with by values -;
    data &dsout;
      if _n_=1 then set _dummypval; 
      set _unibynone; 
    run;
 
    proc datasets nolist;
      delete _dummypval _unibynone;
    quit;
 
  %mend _uninotest;
 
 
    /*--------------------------------*
          Define CMH test macro
     *--------------------------------*/
 
  %macro _unicmh(dsin=,dsout=);
 
    ods output close;
 
    *- create dummy p-value dataset -;
    data _dummypval; 
      retain _statvalue _pvalue . _test "CMH     ";  
    run;
 
    proc summary nway missing data=&dsin; 
      class &byvars &byvars2; 
      output out=_unibycmh(drop=_type_ _freq_); 
    run; 
 
    *- merge with by values -;
    data _dummypval;
      if _n_=1 then set _dummypval; 
      set _unibycmh; 
    run;
 
    %if %nobs(&dsin(where=(_respcnt>1 and _trtcnt>1))) %then %do;
 
      ods output CMH=&dsout;
 
      proc freq data=&dsin(where=(_respcnt>1 and _trtcnt>1));
        by &byvars &byvars2 _test;
        tables &adjcntrvar*&trtvar*&respvar / cmh noprint;
        format &trtvar;
      run;
 
      data &dsout;
        set &dsout(keep=&byvars &byvars2 _test Value Statistic Prob
                  where=(Statistic=2));
        drop Statistic;
        format Value Prob;
        rename Value=_statvalue Prob=_pvalue;
      run;
 
      data &dsout;
        merge _dummypval &dsout;
        by &byvars &byvars2;
      run;
 
    %end;
    %else %do;
 
      data &dsout;
        set _dummypval;
      run;
 
    %end;
 
    proc datasets nolist;
      delete _dummypval _unibycmh;
    quit;
 
  %mend _unicmh;
 
 
 
    /*--------------------------------*
        Define Chi-square test macro
     *--------------------------------*/
 
  %macro _unichisq(dsin=,dsout=);
    ods output close;
 
    *- create dummy p-value dataset -;
    data _dummypval; 
      retain _statvalue _pvalue . _test "CHISQ   ";  
    run;
 
    proc summary nway missing data=&dsin; 
      class &byvars &byvars2; 
      output out=_unibychi(drop=_type_ _freq_); 
    run; 
 
    *- merge with by values -;
    data _dummypval;
      if _n_=1 then set _dummypval; 
      set _unibychi; 
    run;
 
    %if %nobs(&dsin(where=(_respcnt>1 and _trtcnt>1))) %then %do;
 
      ods output ChiSq=&dsout;
 
      %if "&misspct" EQ "Y" %then %do;
          proc freq data=&dsin(where=(_respcnt>1 and _trtcnt>1));
            by &byvars &byvars2 _test;
            tables &trtvar*&respvar / missing chisq;
            format &trtvar;
          run;
      %end;
      %else %do;
          proc freq data=&dsin(where=(_respcnt>1 and _trtcnt>1));
            by &byvars &byvars2 _test;
            tables &trtvar*&respvar / chisq;
            format &trtvar;
          run;
      %end;
 
      data &dsout;
        set &dsout(keep=&byvars &byvars2 _test Statistic Value Prob
                  where=(Statistic="Chi-Square"));
        drop Statistic;
        format Value Prob;
        rename Value=_statvalue Prob=_pvalue;
      run;
 
      data &dsout;
        merge _dummypval &dsout;
        by &byvars &byvars2;
      run;
 
    %end;
    %else %do;
 
      data &dsout;
        set _dummypval;
      run;
 
    %end;
 
    proc datasets nolist;
      delete _dummypval _unibychi;
    quit;
 
  %mend _unichisq;
 
 
 
      /*--------------------------------*
         Define Fisher exact test macro
       *--------------------------------*/
 
  %macro _unifisher(dsin=,dsout=);
    ods output close;
 
    *- create dummy p-value dataset -;
    data _dummypval; 
      length _test $ 8 ; 
      retain _statvalue _pvalue .  _test "FISHER";   
    run;
 
    proc summary nway missing data=&dsin; 
      class &byvars &byvars2; 
      output out=_unibyfish(drop=_type_ _freq_); 
    run; 
 
    *- merge with by values -;
    data _dummypval;
      if _n_=1 then set _dummypval; 
      set _unibyfish; 
    run;
 
    %if %nobs(&dsin(where=(_respcnt>1 and _trtcnt>1))) %then %do;
 
      ods output FishersExact=&dsout;
 
      %if "&misspct" EQ "Y" %then %do;
      proc freq data=&dsin(where=(_respcnt>1 and _trtcnt>1));
        by &byvars &byvars2 _test;
        tables &trtvar*&respvar / missing fisher;
        format &trtvar;
      run;
      %end;
      %else %do;
      proc freq data=&dsin(where=(_respcnt>1 and _trtcnt>1));
        by &byvars &byvars2 _test;
        tables &trtvar*&respvar / fisher;
        format &trtvar;
      run;
      %end;
 
      data &dsout;
        set &dsout(keep=&byvars &byvars2 _test Name1 nValue1
                  where=(Name1="XP2_FISH"));
        drop Name1;
        _statvalue=.;
        format nValue1;
        rename nValue1=_pvalue;
      run;
 
      data &dsout;
        merge _dummypval &dsout;
        by &byvars &byvars2;
      run;
 
    %end;
    %else %do;
 
      data &dsout;
        set _dummypval;
      run;
 
    %end;

    proc datasets nolist;
      delete _dummypval _unibyfish;
    quit;
 
  %mend _unifisher;
 
 
 
 
 
 
 
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

 
  %if &usettest EQ Y %then %do;
    %if &trtcount GT 2 %then %do;
      %put &wrn: (unipvals) Your request for "proc ttest" is not valid for &trtcount treatment arms and will not be used;
      %let usettest=N;
    %end;
    %else %do;
      %if %length(&class)   %then %put &wrn: (unipvals) You requested "proc ttest" so "class=&class" will be ignored;
      %if %length(&model)   %then %put &wrn: (unipvals) You requested "proc ttest" so "model=&model" will be ignored;
      %if %length(&means)   %then %put &wrn: (unipvals) You requested "proc ttest" so "means=&means" will be ignored;
      %if %length(&lsmeans) %then %put &wrn: (unipvals) You requested "proc ttest" so "lsmeans=&lsmeans" will be ignored;
    %end;
  %end;

 
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
    %put &wrn: (unipvals) Exact test requested but is not available for &trtcount treatment;
    %put &wrn: (unipvals) arms (only 2 allowed) so exact test will not be used.;
  %end;
 
 
 
 
 
 
          /*-------------------------------------------------*
                             Categorical data
           *-------------------------------------------------*/ 
 
  %if "&type" EQ "C" %then %do;
 
    
      /*--------------------------------*
            Count number of responses
       *--------------------------------*/
 
    *- Count the number of different responses because if less than 2 -;
    *- for a by group then there is no point in calculating a p-value. -;
    %if "&misspct" EQ "Y" %then %do;
      proc summary nway missing data=_pvaldsin;
        class &byvars &byvars2 &respvar;
        output out=_unirespcnt;
      run;
    %end;
    %else %do;
      proc summary nway missing data=_pvaldsin;
        where not missing(&respvar);
        class &byvars &byvars2 &respvar;
        output out=_unirespcnt;
      run;
    %end;
 
    proc summary nway missing data=_unirespcnt;
      class &byvars &byvars2;
      output out=_unirespcnt(drop=_type_ rename=(_freq_=_respcnt));
    run;
 
 
      /*--------------------------------*
            Count number of trt arms
       *--------------------------------*/
 
    *- Count the number of different treatment arms because if less than 2 -;
    *- for a by group then there is no point in calculating a p-value. -;
    %if "&misspct" EQ "Y" %then %do;
      proc summary nway missing data=_pvaldsin;
        class &byvars &byvars2 &trtvar;
       output out=_unitrtcnt;
      run;
    %end;
    %else %do;
      proc summary nway missing data=_pvaldsin;
        where not missing(&respvar);
        class &byvars &byvars2 &trtvar;
        output out=_unitrtcnt;
      run;
    %end;
 
    proc summary nway missing data=_unitrtcnt;
      class &byvars &byvars2;
      output out=_unitrtcnt(drop=_type_ rename=(_freq_=_trtcnt));
    run;
 
 
      /*--------------------------------*
          Merge counts in with original
       *--------------------------------*/
 
    data _pvaldsin;
      merge _unitrtcnt _unirespcnt _pvaldsin;
      by &byvars &byvars2;
    run;
 
    proc datasets nolist;
      delete _unirespcnt _unitrtcnt;
    run;
    quit;



 
    %if not %length(&usetest) and not %length(&adjcntrvar) %then %do;
 
 
        /*--------------------------------*
              Get expected cell counts
         *--------------------------------*/
 
      %if "&misspct" EQ "Y" %then %do;
        proc freq data=_pvaldsin noprint;
          by &byvars &byvars2 _respcnt _trtcnt;
          tables &trtvar*&respvar / missing sparse outexpect out=_expected(drop=percent);
          format &trtvar;
        run;
      %end;
      %else %do;
        proc freq data=_pvaldsin noprint;
        where not missing(&respvar);
          by &byvars &byvars2 _respcnt _trtcnt;
          tables &trtvar*&respvar / sparse outexpect out=_expected(drop=percent);
          format &trtvar;
        run;
      %end;
 
 
        /*--------------------------------*
              Determine test to be used
         *--------------------------------*/
 
      data _whichtest(keep=&byvars &byvars2 _test);
        length _test $ 8;
        retain _below1 _below5 _cells 0;
        set _expected(where=(_respcnt>1 and _trtcnt>1));
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
          else if _cells>4 and (_below1>0 or _below5>(_cells/5)) then _test="FISHER";
          output;
        end;
      run;
 
      data _notest(keep=&byvars &byvars2 _test);
        retain _test "NOTEST  ";
        set _expected(where=(_respcnt<2 or _trtcnt<2));
      run;
 
      data _whichtest;
        set _notest _whichtest;
        by &byvars &byvars2;
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
          merge _whichtest _pvaldsin;
          by &byvars &byvars2;
        run;   
        %_unifisher(dsin=_dofisher,dsout=_fisher)  
      %end;
    
      %else %if "&testsel" EQ "CHISQ" %then %do;
        %let dodsets=_dochisq;
        %let pvaldsets=_chisq;
 
        data _dochisq;
          merge _whichtest _pvaldsin;
          by &byvars &byvars2;
        run;   
        %_unichisq(dsin=_dochisq,dsout=_chisq)
      %end;
    
      %else %do;
        %let dodsets=;
        %let pvaldsets=;
 
        %if %index(&testsel,FISHER) %then %do;
          data _dofisher;
            merge _whichtest _pvaldsin;
            by &byvars &byvars2;
            if _test="FISHER";
          run;
          %let dodsets=_dofisher;
          %let pvaldsets=_fisher;
          %_unifisher(dsin=_dofisher,dsout=_fisher)
        %end;
 
        %if %index(&testsel,CHISQ) %then %do;
          data _dochisq;
            merge _whichtest _pvaldsin;
            by &byvars &byvars2;
            if _test="CHISQ";
          run;
          %let dodsets=&dodsets _dochisq;
          %let pvaldsets=&pvaldsets _chisq;
          %_unichisq(dsin=_dochisq,dsout=_chisq)
        %end;
 
        %if %index(&testsel,NOTEST) %then %do;
          data _donotest;
            merge _whichtest _pvaldsin;
            by &byvars &byvars2;
            if _test="NOTEST";
          run;
          %let dodsets=&dodsets _donotest;
          %let pvaldsets=&pvaldsets _notest;
          %_uninotest(dsin=_donotest,dsout=_notest)
        %end;
      %end;
 
 
 
        /*--------------------------------*
           Bring p-value datasets together
         *--------------------------------*/
 
      data _temp;
        set &pvaldsets;
        %if %length(&byvars.&byvars2) %then %do;
          by &byvars &byvars2;
        %end;
      run;
    
      proc datasets nolist;
        delete _expected _expectrespcnt _whichtest &pvaldsets &dodsets;
      run;
      quit;
 
    
    %end;  %*- of if not length(usetest) -;
 
 
 
    %else %if "&usetest" EQ "F" %then %do;     %*- Fisher exact -;
 
      data _pvaldsin;
        retain _test "FISHER  ";
        set _pvaldsin;
      run;
  
     %_unifisher(dsin=_pvaldsin,dsout=_temp);

    %end;   %*- of if usetest eq F -;
 
  
 
    %else %if "&usetest" EQ "C" %then %do;     %*- Chi-square -;
 
      data _pvaldsin;
        retain _test "CHISQ   ";
        set _pvaldsin;
      run;
    
      %_unichisq(dsin=_pvaldsin,dsout=_temp);

    %end;   %*- of if usetest eq C -;
 
 
    %else %if %length(&adjcntrvar) %then %do;     %*- CMH test -;
 
      data _pvaldsin;
        retain _test "CMH     ";
        set _pvaldsin;
      run;
    
      %_unicmh(dsin=_pvaldsin,dsout=_temp);
 
    %end;   %*- end of CMH test -;



      /*--------------------------------*
           Call the UNISEPT macro
       *--------------------------------*/

    %do i=1 %to 20;

      %if %length(&&freqsept&i) %then %do;
        %if %sysfunc(indexw(%upcase(%scan(&&freqsept&i,1,#)),&varname))
          %then %_unisept(&&freqsept&i);
      %end;

    %end;



    proc datasets nolist;
      delete _pvaldsin;
    run;
    quit;


    data _temp;
      length pvalid $ 1;
      set _temp;
      %if "&pvalids" NE "N" %then %do;
        if _test="FISHER" then pvalid="&fisherid";
        else if _test="CHISQ" then pvalid="&chisqid";
        else if _test="CMH" then pvalid="&cmhid";
        else if _test="NOTEST" then pvalid=" ";
      %end;
      %else %do;
        pvalid=" ";
      %end;
    run;

    %_uniquad(_temp#0#1#put(_statvalue,&statvalfmt));
    %_uniquad(_temp#1#1#trim(put(_pvalue,&pvalfmt))||pvalid);

 
  %end;  %*- of if type eq C -;
 
 
 
 
          /*-------------------------------------------------*
                     Numeric non-categorical data
           *-------------------------------------------------*/ 
 
  %else %if "&type" EQ "N" %then %do;
 
 
    %if "&usetest" EQ "N" %then %do;  %*- non-parametric test -;
  
      ods output close; 
 
      *- create dummy p-value dataset -;
      data _WILC (compress=no); 
        length Name1 $ 8 Label1 $ 15 cValue1 $ 6; 
        retain nValue1 . cValue1 Label1 " "; 
        Name1="P_KW"; 
        output; 
        Name1="XP2_WIL"; 
        output; 
        Name1="P2_WIL"; 
        output;
        Name1="Z_WIL"; 
        output;
        Name1="_KW_"; 
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
 
 
      data _temp;
        retain _test "NPAR1WAY" _statvalue _pvalue . nparid "&nparid";
        set _WILC(keep=&byvars &byvars2 Name1 nValue1 where=(Name1 IN
          %if &trtcount GT 2 %then %do;
            ("P_KW" "_KW_")
          %end;
          %else %do;
            %if "&exact" EQ "Y" %then %do;
              ("XP2_WIL" "Z_WIL")
            %end;
            %else %do;
              ("P2_WIL" "Z_WIL")
            %end;
          %end;
          ));
        by &byvars &byvars2;
        format nValue1;
        if Name1 IN ("_KW_" "Z_WIL") then _statvalue=nValue1;
        %if "&pvalids" EQ "N" %then %do;
          nparid=" ";
        %end; 
        else if Name1 IN ("P_KW" "XP2_WIL" "P2_WIL") then _pvalue=nValue1;
        if last.%scan(&byvars &byvars2,-1,%str( )) then output;
        drop Name1 nValue1;
      run;

      %_uniquad(_temp#0#input("%upcase(&npvalstat)",_stator.)#put(_statvalue,&statvalfmt));
      %_uniquad(_temp#1#input("%upcase(&npvalstat)",_stator.)#trim(put(_pvalue,&pvalfmt))||nparid);
 
      proc datasets nolist;
        delete _pvaldsin _WILC;
      run;
      quit;
 
 
    %end;
 
  
    %else %do;   


      %if &usettest EQ Y %then %do;

 
        /*----------------------------------------*
                         Proc Ttest
         *----------------------------------------*/
 
        ods output close;

        ods output Equality=_equality(keep=&byvars &byvars2 variable probf) 
                   TTests=_ttests(drop=variances);

        proc ttest data=_pvaldsin;
        %if %length(&byvars.&byvars2) %then %do;
          by &byvars &byvars2;
        %end;
          class &trtvar;
          var &respvar;
          format &trtvar ;
        run;


        data _temp;
          retain _test "TTEST   " ttestid "&ttestid" sattid "&sattid";
          merge _equality _ttests;
          by &byvars &byvars2 variable;
          if probf &sattcond and method=:"P" then delete;
          else if method=:"S" then delete;
          if method=:"P" then pvalid=ttestid;
          else pvalid=sattid;
        run;

        %_uniquad(_temp#0#input("%upcase(&npvalstat)",_stator.)#put(tValue,&statvalfmt));
        %_uniquad(_temp#1#input("%upcase(&npvalstat)",_stator.)#trim(put(Probt,&pvalfmt))||pvalid);
 
        proc datasets nolist;
          delete _equality _ttests;
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
 
        ods output close;
 
        %let hovpvalue=99.0;
        %let hovsig=0;
 
        /* JK: inserted 'and not %length(&model)' to avoid welch test if general model is applied */
        %if not %length(&adjcntrvar) and not %length(&model) %then %do;
    
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
            %put &wrn: (unipvals) p-value=&hovpvalue &hovcond for hovtest=&hovtest;
          %end;
          %else %put NOTE: (unipvals) p-value=&hovpvalue for hovtest=&hovtest;
 
         proc datasets nolist;
            delete _hovftest;
          run;
          quit;
 
        %end;
 
 
        *- create dummy _anova p-value dataset -;
        data _anova; 
          retain HypothesisType 3 Fvalue ProbF . Source "%lowcase(&trtvar)" ;  
        run;
 
        *- merge with by values if any -;
        data _anova;
          if _n_=1 then set _anova; 
          set _unibyvars; 
        run; 
 
        *- create dummy _welch p-value dataset -;
        data _welch;
          retain Fvalue ProbF . Source "%lowcase(&trtvar)" ;
        run;
 
        *- merge with by values if any -;
        data _welch;
          if _n_=1 then set _welch;
          set _unibyvars;
        run;
 
        ods output ModelANOVA=_anova;
   
        %if not %length(&adjcntrvar)  and not %length(&model) and "&welch" EQ "Y" and &hovsig %then %do;
          ods output welch=_welch;
        %end;
 
        /* JK statement added */
        %if %length(&odstables) %then %do;
          %do i=1 %to %words(&odstables);
            %let odstable=%scan(&odstables,&i,%str( ));
            ods output &odstable=&odstable;
          %end;
        %end;
 
 
        /* JK (comment added): Start 2-way ANOVA */

        proc &modelproc data=_pvaldsin;
          %if %length(&byvars.&byvars2) %then %do;
            by &byvars &byvars2;
          %end;
          %if %length(&class) %then %do;
            CLASS %unquote(%qdequote(&class)) ;
          %end;
          %else %do;
            CLASS &trtvar &adjcntrvar;
          %end;
          %if %length(&adjcntrvar) %then %do;
            %if "&modelform" EQ "L" %then %do;
              %if %length(&model) %then %do;
                MODEL %unquote(%qdequote(&model)) ;
              %end;
              %else %do;
                MODEL &respvar=&trtvar &adjcntrvar &trtvar*&adjcntrvar / ss1 ss2 ss3 ss4;
              %end;
            %end;
            %else %do;
              %if %length(&model) %then %do;
                MODEL %unquote(%qdequote(&model)) ;
              %end;
              %else %do;
                MODEL &respvar=&trtvar &adjcntrvar / ss1 ss2 ss3 ss4;
              %end;
            %end;
            %if %length(&means) %then %do;
              MEANS %unquote(%qdequote(&means)) ;
            %end;
    /* JK (means statement commented out) */
    /*        %else %do; */
    /*          MEANS &trtvar ; */
    /*        %end; */
            %if %length(&lsmeans) %then %do;
              LSMEANS %unquote(%qdequote(&lsmeans)) ;
            %end;
          %end;
          %else %do;
            %if %length(&model) %then %do;
              MODEL %unquote(%qdequote(&model)) ;
            %end;
            %else %do;
              MODEL &respvar=&trtvar ;
            %end;
            %if %length(&means) %then %do;
              MEANS %unquote(%qdequote(&means)) ;
            %end;
            %else %do;
              %if "&welch" EQ "Y" and &hovsig %then %do;
%put NOTE: (unipvals) PROC &modelproc will use means statement "means &trtvar / hovtest=&hovtest glmwelch;" %eqsuff(&byvars);
                MEANS &trtvar / hovtest=&hovtest glmwelch;
              %end;
            %if %length(&lsmeans) %then %do;
              LSMEANS %unquote(%qdequote(&lsmeans)) ;
            %end;
    /* JK (means statement commented out) */
    /*          %else %do; */
    /*            MEANS &trtvar; */
    /*          %end; */
            %end;
          %end;
          %if %length(&weight) %then %do;
            WEIGHT %unquote(%qdequote(&weight)) ;
          %end;
          format &trtvar ;
        run;
 
 
        %if %length(&dsmodelanova) %then %do;
          proc append force base=&dsmodelanova data=_anova;
          run;
        %end;
 
        %if not %length(&adjcntrvar) and not %length(&model) and "&welch" EQ "Y" and &hovsig %then %do;
          data _temp;
            retain _test "glmwelch   " pvalid "&welchid";
            set _welch(keep=&byvars &byvars2 Fvalue ProbF Source
                      where=(upcase(Source)="%upcase(&trtvar)")
                     rename=(Fvalue=_statvalue ProbF=_pvalue));
            drop Source;
            %if "&pvalids" EQ "N" %then %do;
              pvalid=" ";
            %end;
            format _statvalue _pvalue;
          run;

          %_uniquad(_temp#0#input("%upcase(&npvalstat)",_stator.)#put(_statvalue,&statvalfmt));
          %_uniquad(_temp#1#input("%upcase(&npvalstat)",_stator.)#trim(put(_pvalue,&pvalfmt))||pvalid);

        %end;
        %else %do;
          data _temp;
            retain _test "ANOVA   " pvalid "&anovaid";
            set _anova(keep=&byvars &byvars2 HypothesisType Fvalue ProbF Source
                      where=(HypothesisType=&errortype and upcase(Source)="%upcase(&trtvar)")
                     rename=(Fvalue=_statvalue ProbF=_pvalue));
            drop HypothesisType Source;
            %if "&pvalids" EQ "N" %then %do;
              pvalid=" ";
            %end;
            format _statvalue _pvalue;
          run;

          %_uniquad(_temp#0#input("%upcase(&npvalstat)",_stator.)#put(_statvalue,&statvalfmt));
          %_uniquad(_temp#1#input("%upcase(&npvalstat)",_stator.)#trim(put(_pvalue,&pvalfmt))||pvalid);

          %if "&cntrwarn" EQ "Y" and %length(&adjcntrvar) %then %do;
            %if "&modelform" EQ "L" %then %do;
              data _null_;
                set _anova(where=(HypothesisType=&errortype));
                if upcase(Source) EQ "%upcase(&trtvar*&adjcntrvar)" and ProbF &intercond then
put "&wrn: (unipvals) ANOVA p-value for %upcase(&adjcntrvar*&trtvar) = " ProbF "&intercond for %upcase(&respvar) " %eqsuff(&byvars);
                else if upcase(Source) EQ "%upcase(&adjcntrvar)" and ProbF &cntrcond then
put "&wrn: (unipvals) ANOVA p-value for %upcase(&adjcntrvar) = " ProbF "&cntrcond for %upcase(&respvar) " %eqsuff(&byvars) ;
              run;
            %end;
            %else %do;
              data _null_;
                set _anova(where=(HypothesisType=&errortype 
                                  and upcase(Source) EQ "%upcase(&adjcntrvar)"));
                if ProbF &cntrcond then
put "&wrn: (unipvals) ANOVA p-value for %upcase(&adjcntrvar) = " ProbF "&cntrcond for %upcase(&respvar) " %eqsuff(&byvars);
              run;
            %end;
          %end;
        %end;

        %do i=1 %to 9;
          %if %length(&&quad&i) %then %do;
            %if %sysfunc(exist(%scan(%scan(&&quad&i,1,#),1,%(%)))) %then %do;
              %_uniquad(&&quad&i);          
            %end;
          %end;
        %end;

        proc datasets nolist;
          delete _pvaldsin _anova _welch;
        run;
        quit;  
      
      %end;

    %end;   %*- end of if ttest is N -;
    
  %end;   %*- end of if type is N -;
 
 
  %if %length(&byvars.&byvars2) %then %do;
    proc datasets nolist;
      delete _unibyvars;
    run;
    quit;
  %end;
 
  %goto skip;
  %exit: %put &err: (unipvals) Leaving macro due to problem(s) listed;
  %skip:

%mend unipvals;




