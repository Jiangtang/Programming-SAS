/*<pre><b>
/ Program      : npctpvals.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 29-Jul-2012
/ Purpose      : Clinical reporting macro that calculates p-values for the
/                %npcttab macro.
/ SubMacros    : %attrn, %delmac + various internally defined macros
/ Notes        : This macro has no way of knowing if the p-values it gives you
/                are relevant or useful. It is up to the statistician to decide
/                upon this matter.
/
/                Calculates Chi-square, Fisher's exact or Cochran-Armitage
/                Trend test (two-sided, one-sided-left or one-sided-right)
/                p-values.
/
/                Unless you override the test selection using usetest=, 
/                Chi-square statistics are the default but if for 2x2 tables
/                the expected cell count for any cell is less than 5 or for
/                larger tables a single expected cell count is less than one
/                or more than 20% of the expected cell counts are less than 5
/                then the Fisher exact test is used instead.
/
/                Note that if you use usetest= to override the test selection
/                then you may get warning messages about cell counts for the
/                Chi-square test or warning messages about processing times 
/                for the Fisher's exact test.
/
/                You must supply a list of one or more by variables to this
/                macro. You will have to set up a fake one if there are none.
/                Input data must be sorted in the order of these by variables.
/
/                You need to specify a response variable that has the value 1
/                if an event occured and 0 if an event did not occur. You may
/                have to generate the 0 event observations in your input data
/                for this macro to work properly. Both types must be present
/                otherwise p-values can not be computed. If a treatment arm has
/                no occurences then you must still make sure the 0 event values
/                are present.
/
/                A count variable can be specified which will be the count for
/                the event occuring or not occuring. This allows you to work on
/                summary data. This count variable can be 0 for when no events
/                occured.
/
/                The output dataset (default name "_pvalues") will contain your
/                by variables with extra variables _pvalue (numeric - the
/                computed p-value), _pvalstr (8 byte character, the formatted
/                value followed by the chisqid= or fisherid= character) and _test
/                (8 byte character) which will have the value "FISHER", "CHISQ"
/                or "TREND" depending on which statistical test was used to
/                calculate the p-value. Variable names "_pvalue" and "_pvalstr"
/                can be changed by setting the pvalvar= and pvalstr= parameters.
/                Whatever format is used for the p-value must be 6 characters in
/                length.
/
/ Usage        : %npctpvals(dsin=data1,byvars=byvar1 byvar2,trtvar=trtgrp,
/                              respvar=resp,countvar=count,pvalstr=TRT9999)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ usetest           Set to C (Chi-square) or F (Fisher's exact) to override
/                   decision of macro to select Chi-square or Fisher's exact test
/                   based on expected cell counts. Can also be set to T2, T1L or
/                   T1R for the two-sided, one-sided-left or one-sided-right
/                   Cochran-Armitage Trend test.
/ byvars            One or more by variables separated by spaces
/ trtvar            Treatment variable
/ respvar           Response variable (0 for no event, 1 for an event)
/ countvar          Optional variable of event counts
/ pvalvar=_pvalue   Name of numeric p-value variable
/ pvalstr=_pvalstr  Name of character p-value variable
/ pvallbl="p-value" Label for numeric and character p-value variables (quoted)
/ pvalfmt=p63val.   Default format (created inside this macro) for formatting
/                   p-value statistic (6.3 unless <0.001 or >0.999).
/ pvalkeep=<0.05    Expression for p-value values to keep. If condition is not
/                   met then numeric and string values are set to missing.
/ chisqid=^         Character to use to identify the Chi-square test that is
/                   added at the end of the character p-value (no quotes)
/ fisherid=~        Character to use to identify the Fisher exact test that is
/                   added at the end of the character p-value (no quotes)
/ trendid           Character to use to identify the Cochran-Armitage Trend Test
/                   that is added at the end of the character p-value (no quotes)
/ dsout=_pvalues    Name of output dataset
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Jul06         Header tidy
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  08May11         Code tidy
/ rrb  16Nov11         Set line size to max to avoid BY line truncated messages
/                      written to the log and fixed p63val bug (v1.1)
/ rrb  18Jul12         Internally defined macro names now start with an
/                      underscore (v1.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: npctpvals v1.2;

%macro npctpvals(dsin=,
              usetest=,
               byvars=,
               trtvar=,
              respvar=,
             countvar=,
              pvalvar=_pvalue,
              pvalstr=_pvalstr,
              pvallbl="p-value",
              pvalfmt=p63val.,
             pvalkeep=<0.05,
              chisqid=^,
             fisherid=~,
              trendid=,
                dsout=_pvalues
                  );

  %local errflag err pvaldsets dodsets ls;
  %let err=ERR%str(OR);
  %let errflag=0;


      /*--------------------------------*
          Check all parameters are set
       *--------------------------------*/

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (npctpvals) dsin= not set for input data;
  %end;

  %if not %length(&byvars) %then %do;
    %let errflag=1;
    %put &err: (npctpvals) byvars= not set for by variables;
  %end;

  %if not %length(&trtvar) %then %do;
    %let errflag=1;
    %put &err: (npctpvals) trtvar= not set for treatment variable;
  %end;

  %if not %length(&respvar) %then %do;
    %let errflag=1;
    %put &err: (npctpvals) respvar= not set for response variable;
  %end;

  %if %length(&usetest) %then %do;
    %let usetest=%upcase(&usetest);
    %if "%substr(&usetest,1,1)" NE "T" %then %let usetest=%substr(&usetest,1,1);
    %if "&usetest" NE "F" 
    and "&usetest" NE "C"
    and "&usetest" NE "T1L"
    and "&usetest" NE "T1R"
    and  "&usetest" NE "T2" %then %do;
      %let errflag=1;
      %put &err: (npctpvals) usetest= must be set to C, F, T2, T1L or T1R;
    %end;
  %end;

  %if &errflag %then %goto exit;


  %if not %length(&dsout) %then %let dsout=_pvalues;

  %if not %length(&pvalvar) %then %let pvalvar=_pvalue;
  %if not %length(&pvallbl) %then %let pvallbl="p-value";

  %*- we need this to get round the "BY-line truncated" bug -;
  %let ls=%sysfunc(getoption(linesize));


       /*-----------------------------------------*
                  Create required formats 
        *-----------------------------------------*/

  proc format;
    value p63val (default=6)
    low-<0.001="<0.001"
    0.999<-high=">0.999"
    OTHER=[6.3]
    ;


      /*--------------------------------*
          Define Chi-square test macro
       *--------------------------------*/

  %macro _npctchisq;
    ods output close;
    ods output ChiSq=_chisq;

    *- fix for "BY line truncated" bug is to set linesize to max -;
    options ls=max;

    proc freq data=_dochisq;
      by &byvars _test;
      %if %length(&countvar) %then %do;
        weight &countvar;
      %end;
      tables &trtvar*&respvar / chisq;
    run;

    data _chisq;
      set _chisq(keep=&byvars _test Statistic Prob
                 where=(Statistic="Chi-Square"));
      drop Statistic;
      rename Prob=&pvalvar;
    run;

    *- reset linesize -;
    options ls=&ls;

  %mend _npctchisq;



    /*--------------------------------*
       Define Fisher exact test macro
     *--------------------------------*/

  %macro _npctfisher;
    ods output close;
    ods output FishersExact=_fisher;

    *- fix for "BY line truncated" bug is to set linesize to max -;
    options ls=max;

    proc freq data=_dofisher;
      by &byvars _test;
      %if %length(&countvar) %then %do;
        weight &countvar;
      %end;
      tables &trtvar*&respvar / exact;
    run;
    data _fisher;
      set _fisher(keep=&byvars _test Name1 nValue1
                  where=(Name1="XP2_FISH"));
      drop Name1;
      rename nValue1=&pvalvar;
    run;

    *- reset linesize -;
    options ls=&ls;

  %mend _npctfisher;



    /*---------------------------------*
       One-sided-left Trend test macro
     *---------------------------------*/

  %macro _npcttrend1l;
    ods output close;
    ods output TrendTest=_trend;

    proc freq data=_dotrend;
      by &byvars _test;
      %if %length(&countvar) %then %do;
        weight &countvar;
      %end;
      tables &trtvar*&respvar / trend;
    run;
    data _trend;
      set _trend(keep=&byvars _test Name1 nValue1
                  where=(Name1 in ("PL_TREND" "PR_TREND")));
      if Name1="PR_TREND" then nValue1=1-nValue1;
      drop Name1;
      rename nValue1=&pvalvar;
    run;
  %mend _npcttrend1l;



      /*---------------------------------*
         One-sided-right Trend test macro
       *---------------------------------*/

  %macro _npcttrend1r;
    ods output close;
    ods output TrendTest=_trend;

    proc freq data=_dotrend;
      by &byvars _test;
      %if %length(&countvar) %then %do;
        weight &countvar;
      %end;
      tables &trtvar*&respvar / trend;
    run;
    data _trend;
      set _trend(keep=&byvars _test Name1 nValue1
                  where=(Name1 in ("PL_TREND" "PR_TREND")));
      if Name1="PL_TREND" then nValue1=1-nValue1;
      drop Name1;
      rename nValue1=&pvalvar;
    run;
  %mend _npcttrend1r;



    /*---------------------------------*
      Define Two-sided Trend test macro
     *---------------------------------*/

  %macro _npcttrend2;
    ods output close;
    ods output TrendTest=_trend;

    proc freq data=_dotrend;
      by &byvars _test;
      %if %length(&countvar) %then %do;
        weight &countvar;
      %end;
      tables &trtvar*&respvar / trend;
    run;
    data _trend;
      set _trend(keep=&byvars _test Name1 nValue1
                  where=(Name1="P2_TREND"));
      drop Name1;
      rename nValue1=&pvalvar;
    run;
  %mend _npcttrend2;



   /*==================================*
       PROCESS FOR USETEST= NOT SET
    *==================================*/


  %if not %length(&usetest) %then %do;

      /*--------------------------------*
            Get expected cell counts
       *--------------------------------*/

    *- fix for "BY line truncated" bug is to set linesize to max -;
    options ls=max;

    proc freq data=&dsin noprint;
      by &byvars;
      %if %length(&countvar) %then %do;
        weight &countvar;
      %end;
      tables &trtvar*&respvar / sparse outexpect out=_expected(drop=percent);
    run;

    *- reset linesize -;
    options ls=&ls;


      /*--------------------------------*
            Determine test to be used
       *--------------------------------*/

    data _whichtest(keep=&byvars _test);
      length _test $ 8;
      retain _below1 _below5 _cells 0;
      set _expected;
      by &byvars;
      if first.%scan(&byvars,-1,%str( )) then do;
        _below1=0;
        _below5=0;
        _cells=0;
      end;
      _cells=_cells+1;
      if expected < 1 then _below1=_below1+1;
      if expected < 5 then _below5=_below5+1;
      if last.%scan(&byvars,-1,%str( )) then do;
        _test="CHISQ";
        if _cells<5 and _below5>0 then _test="FISHER";
        else if _cells>4 and (_below1>0 or _below5>(_cells/5)) then _test="FISHER";
        output;
      end;
    run;


    /*--------------------------------*
        Split data according to test
     *--------------------------------*/

    data _dofisher _dochisq;
      merge _whichtest &dsin;
      by &byvars;
      if _test="FISHER" then output _dofisher;
      else if _test="CHISQ" then output _dochisq;
    run;


    /*--------------------------------*
             Call p-value macros
     *--------------------------------*/

    ods listing close;
  
    %let dodsets=_dofisher _dochisq;
    %let pvaldsets=;
  
    %if %attrn(_dofisher,nobs) %then %do;
      %_npctfisher;
      %let pvaldsets=&pvaldsets _fisher;
    %end;
  
    %if %attrn(_dochisq,nobs) %then %do;
      %_npctchisq;
      %let pvaldsets=&pvaldsets _chisq;
    %end;


  %end;  %*- of if not length(usetest) -;



   /*==================================*
         PROCESS FOR USETEST= SET
    *==================================*/


  %else %do;  %*- usetest override in effect -;

    ods listing close;

    %if "&usetest" EQ "C" %then %do;
      data _dochisq;
        length _test $ 8;
        retain _test "CHISQ";
        set &dsin;
      run;
      %_npctchisq
      %let dodsets=_dochisq;
      %let pvaldsets=_chisq;
    %end;

    %if "&usetest" EQ "F" %then %do;
      data _dofisher;
        length _test $ 8;
        retain _test "FISHER";
        set &dsin;
      run;
      %_npctfisher
      %let dodsets=_dofisher;
      %let pvaldsets=_fisher;
    %end;
  
    %if "&usetest" EQ "T1L" %then %do;
      data _dotrend;
        length _test $ 8;
        retain _test "TREND";
        set &dsin;
      run;
      %_npcttrend1l
      %let dodsets=_dotrend;
      %let pvaldsets=_trend;
    %end;

    %if "&usetest" EQ "T1R" %then %do;
      data _dotrend;
        length _test $ 8;
        retain _test "TREND";
        set &dsin;
      run;
      %_npcttrend1r
      %let dodsets=_dotrend;
      %let pvaldsets=_trend;
    %end;
  
    %if "&usetest" EQ "T2" %then %do;
      data _dotrend;
        length _test $ 8;
        retain _test "TREND";
        set &dsin;
      run;
      %_npcttrend2
      %let dodsets=_dotrend;
      %let pvaldsets=_trend;
    %end; 

  %end;



   /*==================================*
            CARRY ON PROCESSING
    *==================================*/


  ods listing;


    /*--------------------------------*
          Combine p-value datasets
     *--------------------------------*/

  data &dsout;
    length &pvalstr $ 8;
    set &pvaldsets;
    by &byvars;
    if _test="CHISQ" then &pvalstr=trim(put(&pvalvar,&pvalfmt))||"&chisqid";
    else if _test="FISHER" then &pvalstr=trim(put(&pvalvar,&pvalfmt))||"&fisherid";
    else if _test="TREND" then &pvalstr=trim(put(&pvalvar,&pvalfmt))||"&trendid";
    %if %length(&pvalkeep) %then %do;
      if not (&pvalvar.&pvalkeep) then do;
        &pvalvar=.;
        &pvalstr=" ";
      end;
    %end;
    label &pvalvar=&pvallbl
          &pvalstr=&pvallbl
          ;
  run;


    /*--------------------------------*
              Tidy up and exit
     *--------------------------------*/

  proc datasets nolist;
    delete  &dodsets &pvaldsets
            %if not %length(&usetest) %then %do;
              _expected _whichtest
            %end;
            ;
  run;
  quit;


  %goto skip;
  %exit: %put &err: (npctpvals) Leaving macro due to problem(s) listed;
  %skip:

%mend npctpvals;
