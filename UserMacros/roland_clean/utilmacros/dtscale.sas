/*<pre><b>
/ Program   : dtscale.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To generate a date scale for sas/graph
/ SubMacros : none
/ Notes     : If you get the min and max date the wrong way round then the macro
/             will swap them over. Values will be written to the global macro
/             variables _from_, _to_ and _by_. They will be pure numbers. It is
/             up to you to use a suitable format.
/ Usage     : %dtscale(&min,&max);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ min               (pos) Minimum date (text numeric)
/ max               (pos) Maximum date (text numeric)
/ ticks=7           Number of major tick marks on the axis
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dtscale v1.0;

%macro dtscale(min,max,ticks=7);

  %global _from_ _to_ _by_;
  %local swap;

  %if %sysevalf(&max < &min) %then %do;
    %let swap=&max;
    %let max=&min;
    %let min=&swap;
  %end;

  data _null_;
    _to=&max;
    _by=ceil((&max-&min)/(&ticks-1));
    _from=_to-(_by*(&ticks-1));
    call symput('_from_',compress(put(_from,11.)));
    call symput('_to_',compress(put(_to,11.)));
    call symput('_by_',compress(put(_by,11.)));  
  run;

%mend dtscale;
