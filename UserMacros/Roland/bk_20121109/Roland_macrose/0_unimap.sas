/*<pre><b>
/ Program      : unimap.sas
/ Version      : 2.3
/ Author       : Roland Rashleigh-Berry
/ Date         : 28-Aug-2011
/ Purpose      : Function-style clinical reporting macro to map proc univariate
/                labels to the actual stats keyword names.
/ SubMacros    : %words %windex %remove
/ Notes        : You can put footnote characters after the labels such as Max.~
/                for unpaired stats labels and it should still find a match. 
/                Paired stats labels such as Min;Max are allowed but no footnote
/                characters should be used for these. Do not use underscores
/                unless you are accessing the STD_* keyword statistics.
/
/                You are allowed to amend this macro to change the mapping of
/                labels to keywords. If you do you should change the "MACRO
/                CALLED" message to say you are running a local version. You
/                might want to put your own copy of the macro in a folder
/                defined to the sasautos path such that it takes precedence
/                over the original version.
/
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
/ rrb  05Dec09         Header tidy
/ rrb  07Nov10         Keywords LCLMnn, UCLMnn, LCLnn, UCLnn allowed where n is
/                      75, 90, 95 or 99 and LCLM, UCLM are the confidence limits
/                      of the mean and LCL, UCL are the confidence limits of the
/                      spread of values (v2.1)
/ rrb  09Nov10         More nn values accepted for confidence limits plus better
/                      diagnostics on mismatches (v2.2)
/ rrb  08May11         Code tidy
/ rrb  08Jun11         Header tidy
/ rrb  28Aug11         Map S.D. to STD (v2.3)
/===============================================================================
/ Copyright (C) 2011, Roland Rashleigh-Berry. Use of this software is by license
/ only commencing 01 Jan 2012 although permission is granted to use these macros
/ for educational or demonstration purposes and by drug regulatory agencies.
/
/ Users should ensure this software is suitable for the purpose to which it is 
/ put and to provide adequate checks on the accuracy of any values produced as
/ no guarantee can be given that the results displayed by this software are as
/ expected and no liability is accepted for any damage caused through use of any
/ incorrect output produced. Only use this software if you agree to these terms.
/=============================================================================*/
 
%put MACRO CALLED: unimap v2.3;
%*-- Note that if you have amended this macro then you should change the --;
%*-- above line to make it clear you are running a local version such as --;
%*-- change it to "unimap (local) v1.0" --;
 
%macro unimap(labels);
 
  %local junk unilist i j chomp bit errflag err statlist label numparts;
  %let err=ERR%str(OR);
  %let errflag=0;
 
  %global _statlabs_;
  %let _statlabs_=;
 
  %*- This list is taken from the proc univariate output statement  -;
  %*- documentation for sas version 9.1.3 and is in the same order  -;
  %*_ but with confidence limits added at the end.                  -;
  %let unilist=CSS CV KURTOSIS MAX MEAN MIN MODE N NMISS NOBS RANGE SKEWNESS 
  STD STDMEAN SUM SUMWGT USS VAR P1 P5 P10 Q1 MEDIAN Q3 P90 P95 P99 QRANGE 
  GINI MAD QN SN STD_GINI STD_MAD STD_QN STD_QRANGE STD_SN MSIGN NORMALTEST 
  SIGNRANK PROBM PROBN PROBS PROBT T 
  LCL75 LCL90 LCL92 LCL95 LCL97 LCL98 LCL99 
  UCL75 UCL90 UCL92 UCL95 UCL97 UCL98 UCL99
  LCLM75 LCLM90 LCLM92 LCLM95 LCLM97 LCLM98 LCLM99 
  UCLM75 UCLM90 UCLM92 UCLM95 UCLM97 UCLM98 UCLM99
  ;
 
  %do i=1 %to %words(&labels);
    %let label=%scan(&labels,&i,%str( ));
    %let chomp=%upcase(&label);
    %let junk=%sysfunc(compress(&chomp,0123456789ABCDEFGHIJKLNMOPQRSTUVWXYZ_%str( )));
    %let chomp=%sysfunc(compbl(%sysfunc(translate(&chomp,%str( ),&junk))));
    %if "&chomp" EQ "S D" %then %let chomp=SD;
    %else %if "&chomp" EQ "MEAN S D" %then %let chomp=MEAN SD;
    %let numparts=%words(&chomp);
    %do j=1 %to &numparts;
      %let _statlabs_=&_statlabs_ &label;
      %let bit=%scan(&chomp,&j,%str( ));
      %let bit=%remove(&bit,IMUM);
      %let bit=%remove(&bit,IANCE);
      %if %substr(&bit.XXX,1,4) EQ SUMW %then %let bit=SUMWGT;
      %if %substr(&bit.XX,1,3) EQ KUR %then %let bit=KURTOSIS;
      %else %if %substr(&bit.XX,1,3) EQ MED %then %let bit=MEDIAN;
      %if %substr(&bit.XX,1,3) EQ LCL or %substr(&bit.XX,1,3) EQ UCL %then %do;
        %if %length(&bit) EQ %length(%sysfunc(compress(&bit,1234567890))) %then %let bit=&bit.95;
      %end;
      %if %substr(&bit.X,1,2) EQ QR %then %let bit=QRANGE;
      %else %if %substr(&bit.X,1,2) EQ SK %then %let bit=SKEWNESS;
      %else %if &bit EQ PRM %then %let bit=PROBM;
      %else %if &bit EQ PRN %then %let bit=PROBN;
      %else %if &bit EQ PRS %then %let bit=PROBS;
      %else %if &bit EQ PRT %then %let bit=PROBT;
      %else %if &bit EQ P25 %then %let bit=Q1;
      %else %if &bit EQ P75 %then %let bit=Q3;
      %else %if &bit EQ SD %then %let bit=STD;
      %else %if "&bit" EQ "S D" %then %let bit=STD;
      %else %if &bit EQ STDERR %then %let bit=STDMEAN;
      %else %if &bit EQ SEM %then %let bit=STDMEAN;
      %else %if &bit EQ MISSING %then %let bit=NMISS;
      %if not %windex(&unilist,&bit) %then %do;
        %let errflag=1;
        %if &numparts GT 1 %then %do;
          %put &err: (unimap) Label "%scan(&labels,&i,%str( ))" part &j can not be mapped
to a descriptive or quantile statistics keyword;
        %end;
        %else %do;
          %put &err: (unimap) Label "%scan(&labels,&i,%str( ))" can not be mapped to
a descriptive or quantile statistics keyword;
        %end;
      %end;
      %else %let statlist=&statlist &bit;
    %end;
  %end;
 
  %if not &errflag %then %do;
    %put MSG: (unimap) Global macro variable _statlabs_ has been set up to;
    %put MSG: (unimap) show the source stats label for each stats keyword.;
    %put statlist=&statlist;
    %put _statlabs_=&_statlabs_;
    %put;
  %end;
 
  %if not &errflag %then &statlist;
 
%mend unimap;
