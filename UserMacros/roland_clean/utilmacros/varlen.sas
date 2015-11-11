/*<pre><b>
/ Program   : varlen.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return a variable length
/ SubMacros : %attrv %vartype
/ Notes     : This is a shell macro that calls %attrv.
/             Character variables will have the length preceded by a "$ " so you
/             can use it in a length statement in a data step. Set the nodollar
/             paremater to anything to suppress the dollar sign.
/ Usage     : %let varlen=%varlen(dsname,varname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name
/ var               (pos) Variable name
/ nodollar          (pos) If this is set to anything then the dollar shown for 
/                   character length will be suppressed
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  01Nov02         Added parameter to suppress the $
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: varlen v1.0;

%macro varlen(ds,var,nodollar);
  %local varlen;
  %let varlen=%attrv(&ds,&var,varlen);
  %if "%vartype(&ds,&var)" EQ "C" and %length(&nodollar) EQ 0 
    %then %let varlen=$ &varlen;
&varlen
%mend varlen;
