/*<pre><b>
/ Program   : casestrmac.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to force mixed case forms of a string into
/             the string itself for a macro expression.
/ SubMacros : none
/ Notes     : This is a function-style macro. See usage notes. If the macro
/             expression contains equals signs then enclose in %str(). If it
/             contains commas then enclose in %quote().
/ Usage     : %let newtext=%casestrvar(&oldtext,Roland);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) Original string.
/ targ              (pos) Target string (unquoted).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: casestrmac v1.0;

%macro casestrmac(str,targ);

  %local pos res redo tempstr;
  %let tempstr=&str;

  %redo:
  %let redo=0;

  %let pos=%index(%qupcase(%quote(&tempstr)),%qupcase(&targ));
  %if &pos %then %do;
    %let redo=1;
    %if &pos GT 1 %then %let
      res=&res%qsubstr(%quote(&tempstr),1,%eval(&pos-1))&targ;
    %else %let res=&res&targ;
    %if %length(%quote(&tempstr)) GT %eval(&pos+%length(&targ)-1) 
      %then %let tempstr=%qsubstr(%quote(&tempstr),%eval(&pos+%length(&targ)));
    %else %let tempstr=;
  %end;

  %if &redo %then %goto redo;

&res&tempstr

%mend casestrmac;
