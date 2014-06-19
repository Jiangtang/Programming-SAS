/*<pre><b>
/ Program   : compvars.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 08-Nov-2011
/ Purpose   : To compare the differences in variables present in two datasets
/             and report the results to global macro variables.
/ SubMacros : none
/ Notes     : Two datasets are supplied to this macro as positional parameters.
/             They should be thought of as the "left" and "right" datasets. 
/             Variables in the left dataset that are not in the right dataset
/             are written to the global macro variable named _left_. Variables
/             in the right dataset that are not in the left dataset are written
/             to the global macro variables named _right_. Variables found in
/             both datasets are written to the global macro variable named
/             _both_. The contents of these global macro variables can be
/             reported after the comparison of the two datasets. See usage
/             notes.
/ Usage     : %let ds1=dataset1;
/             %let ds2=dataset2;
/             %compvars(&ds1,&ds2)
/             options nosource;
/             %put NOTE: Variables found in &ds1 but not &ds2:;
/             %put &_left_;
/             %put NOTE: Variables found in &ds2 but not &ds1:;
/             %put &_right_;
/             %put NOTE: Variables found in both &ds1 and &ds2:;
/             %put &_both_;
/             options source;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds1               (pos) "Left" dataset for comparison
/ ds2               (pos) "Right" dataset for comparison
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/ rrb  08Nov11         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: compvars v1.0;

%macro compvars(ds1,ds2);

  %global _left_ _right_ _both_;
  %let _left_=;
  %let _right_=;
  %let _both_=;

  proc contents noprint data=&ds1 out=_left(keep=name);
  proc sort data=_left;
    by name;
  run;

  proc contents noprint data=&ds2 out=_right(keep=name);
  proc sort data=_right;
    by name;
  run;
 
  data _null_;
    length _left _right _both $ 32767;
    retain _left _right _both " ";
    merge _left(in=_l) _right(in=_r) end=_last;
    by name;
    if _l and not _r then _left=trim(_left)||" "||trim(name);
    else if _r and not _l then _right=trim(_right)||" "||trim(name);
    else if _l and _r then _both=trim(_both)||" "||trim(name);
    if _last then do;
      call symput('_left_',left(trim(_left)));
      call symput('_right_',left(trim(_right)));
      call symput('_both_',left(trim(_both)));
    end;
  run;

  proc datasets nolist;
    delete _left _right;
  run;
  quit;

%mend compvars;
