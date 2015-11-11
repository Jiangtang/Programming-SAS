/*<pre><b>
/ Program   : protinfo.sas
/ Version   : 1.3
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : Spectre (Clinical) macro to store important protocol information
/             in global macro variables.
/ SubMacros : none
/ Notes     : This reads the "protocol" dataset
/ Usage     : %protinfo
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  02Mar07         Use "&_ptlibref_.." instead of "der."
/ rrb  07Mar07         New _pagexofy_ global macro variable
/ rrb  25Jun07         New _pagemac_ global macro variable
/ rrb  30Jul07         Header tidy
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: protinfo v1.3;

%macro protinfo;

  %local err;
  %let err=ERR%str(OR);
  %global _drugname_ _protocol_ _report_ 
          _paper_ _margin_ _lmargin_ _rmargin_ _tmargin_ _bmargin_
          _abort_ _clean_ _pagexofy_ _pagemac_
          _dflayout_ _dfllayout_ _dfplayout _dfltlayout_ _dfptlayout_ _titlestyle_
          _pop1_ _poplabel1_ _pop2_ _poplabel2_ _pop3_ _poplabel3_
          _pop4_ _poplabel4_ _pop5_ _poplabel5_ _pop6_ _poplabel6_
          _pop7_ _poplabel7_ _pop8_ _poplabel8_ _pop9_ _poplabel9_
  ;

  %*- abort check -;
  %global _abort_;
  %if %length(&_abort_) %then %do;
    %put &err: (protinfo) There has been a problem in a previous macro so this macro will now exit;
    %goto exit;
  %end;


  %*- check the dataset we need is there -;
  %if not %sysfunc(exist(&_ptlibref_..protocol)) %then %do;
    %put &err: (protinfo) Protocol information dataset "&_ptlibref_..protocol" not found;
    %let _abort_=1;
    %goto exit;
  %end;


  *- write the values to global macro variables -;
  data _null_;
    set &_ptlibref_..protocol;
    call symput('_drugname_',trim(drugname));
    call symput('_protocol_',trim(protocol));
    call symput('_report_',trim(report));
  
    call symput('_paper_',trim(paper));
    call symput('_lmargin_',trim(lmargin));
    call symput('_rmargin_',trim(rmargin));
    call symput('_tmargin_',trim(tmargin));
    call symput('_bmargin_',trim(bmargin));
  
    call symput('_dflayout_',trim(dflayout));
    call symput('_dfllayout_',trim(dfllayout));
    call symput('_dfplayout_',trim(dfplayout));
    call symput('_dfltlayout_',trim(dfltlayout));
    call symput('_dfptlayout_',trim(dfptlayout));
    call symput('_titlestyle_',trim(titlestyle));
    call symput('_clean_',trim(clean));
    call symput('_pagexofy_',trim(pagexofy));
    call symput('_pagemac_',trim(pagemac));
  
    call symput('_pop1_',trim(pop1));
    call symput('_poplabel1_',trim(poplabel1));
    call symput('_pop2_',trim(pop2));
    call symput('_poplabel2_',trim(poplabel2));
    call symput('_pop3_',trim(pop3));
    call symput('_poplabel3_',trim(poplabel3));
    call symput('_pop4_',trim(pop4));
    call symput('_poplabel4_',trim(poplabel4));
    call symput('_pop5_',trim(pop5));
    call symput('_poplabel5_',trim(poplabel5));
    call symput('_pop6_',trim(pop6));
    call symput('_poplabel6_',trim(poplabel6));
    call symput('_pop7_',trim(pop7));
    call symput('_poplabel7_',trim(poplabel7));
    call symput('_pop8_',trim(pop8));
    call symput('_poplabel8_',trim(poplabel8));
    call symput('_pop9_',trim(pop9));
    call symput('_poplabel9_',trim(poplabel9));
  run;


  %*- check the title style was set -;
  %if not %length(&_titlestyle_) %then %do;
    %put &err: (protinfo) Title style not specified for output reports;
    %let _abort_=1;
    %goto exit;
  %end;


  %put;
  %put MSG: (protinfo) The following global macro variables have been set up;
  %put MSG: (protinfo) and can be resolved in your code. This information;
  %put MSG: (protinfo) is held in the file "protocol.txt".;
  %put _drugname_=&_drugname_;
  %put _protocol_=&_protocol_;
  %put _report_=&_report_;
  %put _paper_=&_paper_;
  %put _lmargin_=&_lmargin_;
  %put _rmargin_=&_rmargin_;
  %put _tmargin_=&_tmargin_;
  %put _bmargin_=&_bmargin_;
  %put _titlestyle_=&_titlestyle_;
  %put _dflayout_=&_dflayout_;
  %put _dfllayout_=&_dfllayout_;
  %put _dfplayout_=&_dfplayout_;
  %put _dfltlayout_=&_dfltlayout_;
  %put _dfptlayout_=&_dfptlayout_;
  %put _clean_=&_clean_;
  %put _pagexofy_=&_pagexofy_;
  %put _pagemac_=&_pagemac_;
  %put _pop1_=&_pop1_;
  %put _poplabel1_=&_poplabel1_;
  %put _pop2_=&_pop2_;
  %put _poplabel2_=&_poplabel2_;
  %put _pop3_=&_pop3_;
  %put _poplabel3_=&_poplabel3_;
  %put _pop4_=&_pop4_;
  %put _poplabel4_=&_poplabel4_;
  %put _pop5_=&_pop5_;
  %put _poplabel5_=&_poplabel5_;
  %put _pop6_=&_pop6_;
  %put _poplabel6_=&_poplabel6_;
  %put _pop7_=&_pop7_;
  %put _poplabel7_=&_poplabel7_;
  %put _pop8_=&_pop8_;
  %put _poplabel8_=&_poplabel8_;
  %put _pop9_=&_pop9_;
  %put _poplabel9_=&_poplabel9_;
  %put;


  %goto skip;
  %exit: %put &err: (protinfo) Leaving macro due to problem(s) listed;
  %skip:

%mend protinfo;
