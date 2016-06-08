/*<pre><b>
/ Program   : mkordinfmt.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Oct-2011
/ Purpose   : To create a numeric informat to map character strings to an
/             ordering rank value.
/ SubMacros : none
/ Notes     : The value you assign to fmtname= must not end in a number. For
/             alphabetical order do not use the ordvar= parameter.
/ Usage     : %mkordinfmt(fmtname=lvl,dsin=test,var=str,ordvar=order)
/             %mkordinfmt(fmtname=lvl,dsin=test,var=str)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ fmtname           Format name (must not end in a number)
/ dsin              Input dataset
/ var               Character variable whose values will be mapped to a rank
/ ordvar            Existing ordering variable in the input dataset that defines
/                   the order of the "var" character variable (optional - do not
/                   use for alphabetical order).
/ other=9999        By default, values not mapped are given the rank of 9999
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Oct11         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: mkordinfmt v1.0;

%macro mkordinfmt(fmtname=,dsin=,var=,ordvar=,other=9999);
  %local savopts;
  %let savopts=%sysfunc(getoption(notes));
  options nonotes;
  %let fmtname=%sysfunc(compress(&fmtname,.));
  data _mkord;
    set &dsin;
    keep &ordvar &var;
  run;
  proc sort nodupkey data=_mkord;
    by &ordvar &var;
  run;
  data _mkord(rename=(&var=start));
    retain fmtname "&fmtname" type "I";
    set _mkord end=last;
    label=_n_;
    output;
    if last then do;
      label=&other;
      hlo="O";
      output;
    end;
  run;
  proc format cntlin=_mkord;
  run;
  proc datasets nolist;
    delete _mkord;
  run;
  quit;
  options &savopts;
%mend mkordinfmt;
