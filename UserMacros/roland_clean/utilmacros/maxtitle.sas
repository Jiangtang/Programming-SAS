/*<pre><b>
/ Program   : maxtitle.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To find the highest number title and footnote and output to global
/             macro variables.
/ SubMacros : none
/ Notes     : The global macro variables used to hold the maximum for titles and
/             footnotes will be _maxtitle_ and _maxfoot_ .
/ Usage     : %maxtitles
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ quiet             (pos) Set this to anything to stop message at end
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

%put MACRO CALLED: maxtitle v1.0;

%macro maxtitle(quiet);

  %global _maxtitle_ _maxfoot_;
  %let _maxtitle_=0;
  %let _maxfoot_=0;


  *- extract maximum title and footnote number from the vtitle view -;
  data _null_;
    retain maxtitle maxfoot 0;
    set sashelp.vtitle end=last;
    if type='T' then maxtitle=number;
    else if type='F' then maxfoot=number;
    if last then do;
      call symput('_maxtitle_',compress(put(maxtitle,2.)));
      call symput('_maxfoot_',compress(put(maxfoot,2.)));
    end;
  run;

  %if not %length(&quiet) %then %do;
    %put;
    %put MSG: (maxtitle) The following global macro variables have been set up;
    %put MSG: (maxtitle) and can be used in your code. ;
    %put _maxtitle_=&_maxtitle_;
    %put _maxfoot_=&_maxfoot_;
  %end;

%mend maxtitle;
