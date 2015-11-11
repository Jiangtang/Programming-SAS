/*<pre><b>
/ Program      : unimap.sas
/ Version      : 2.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 27-Jan-2008
/ Purpose      : Clinical reporting macro to map proc univariate labels to the
/                actual stats keyword names.
/ SubMacros    : %words %windex %remove
/ Notes        : You can put footnote characters after the labels such as Max.~
/                for unpaired stats labels and it should still find a match. 
/                Paired stats labels such as Min;Max are allowed but no footnote
/                characters should be used for these. Do not use underscores
/                unless you are accessing the STD_* keyword statistics.
/ Usage        : %let stats=%unimap(&labels);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ labels            (pos) List of labels separated by spaces
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  21Mar07         Map "SEM" and "STDERR" to "STDMEAN"
/ rrb  30Jul07         Header tidy
/ rrb  30Dec07         Map "MISSING" to "NMISS"
/ rrb  31Dec07         unilist expanded to match those in v9.1.3 release doc
/ rrb  31Dec07         "IANCE" dropped from label items
/ rrb  31Dec07         Allow for underscore in statistics label so that the
/                      STD_* keywords can be mapped to.
/ rrb  27Jan08         Paired stats keywords such as Min;Max now allowed. New
/                      global macro variable _statlabs_ set up to match stats
/                      keywords to their original labels.
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: unimap v2.0;

%macro unimap(labels);

%local junk unilist i j chomp bit error statlist label;
%let error=0;

%global _statlabs_;
%let _statlabs_=;

%*- This list is taken from the proc univariate output statement  -;
%*- documentation for sas version 9.1.3 and is in the same order. -;
%let unilist=CSS CV KURTOSIS MAX MEAN MIN MODE N NMISS NOBS RANGE SKEWNESS 
STD STDMEAN SUM SUMWGT USS VAR P1 P5 P10 Q1 MEDIAN Q3 P90 P95 P99 QRANGE 
GINI MAD QN SN STD_GINI STD_MAD STD_QN STD_QRANGE STD_SN MSIGN NORMALTEST 
SIGNRANK PROBM PROBN PROBS PROBT T;

%do i=1 %to %words(&labels);
  %let label=%scan(&labels,&i,%str( ));
  %let chomp=%upcase(&label);
  %let junk=%sysfunc(compress(&chomp,0123456789ABCDEFGHIJKLNMOPQRSTUVWXYZ_%str( )));
  %let chomp=%sysfunc(translate(&chomp,%str( ),&junk));
  %do j=1 %to %words(&chomp);
    %let _statlabs_=&_statlabs_ &label;
    %let bit=%scan(&chomp,&j,%str( ));
    %let bit=%remove(&bit,IMUM);
    %let bit=%remove(&bit,IANCE);
    %if %length(&bit) GT 3 %then %do;
      %if %substr(&bit,1,4) EQ SUMW %then %let bit=SUMWGT;
    %end;
    %if %length(&bit) GT 2 %then %do;
      %if %substr(&bit,1,3) EQ KUR %then %let bit=KURTOSIS;
      %else %if %substr(&bit,1,3) EQ MED %then %let bit=MEDIAN;
    %end;
    %if %length(&bit) GT 1 %then %do;
      %if %substr(&bit,1,2) EQ QR %then %let bit=QRANGE;
      %else %if %substr(&bit,1,2) EQ SK %then %let bit=SKEWNESS;
      %else %if &bit EQ P25 %then %let bit=Q1;
      %else %if &bit EQ P75 %then %let bit=Q3;
      %else %if &bit EQ SD %then %let bit=STD;
      %else %if &bit EQ STDERR %then %let bit=STDMEAN;
      %else %if &bit EQ SEM %then %let bit=STDMEAN;
      %else %if &bit EQ MISSING %then %let bit=NMISS;
    %end;
    %if not %windex(&unilist,&bit) %then %do;
      %let error=1;
      %if &j EQ 1 %then
      %put ERROR: (unimap) Label "%scan(&labels,&i,%str( ))" can not be mapped to
a descriptive or quantile statistics keyword;
      %else
      %put ERROR: (unimap) Label "%scan(&labels,&i,%str( ))" part &j can not be mapped
to a descriptive or quantile statistics keyword;
    %end;
    %else %let statlist=&statlist &bit;
  %end;
%end;

%if not &error %then %do;
  %put MSG: (unimap) Global macro variable _statlabs_ has been set up to;
  %put MSG: (unimap) show the source stats label for each stats keyword.;
  %put statlist=&statlist;
  %put _statlabs_=&_statlabs_;
  %put;
%end;

%if not &error %then &statlist;

%mend;
