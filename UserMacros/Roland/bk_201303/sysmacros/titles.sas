/*<pre><b>
/ Program      : titles.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 30-Jul-2007
/ Purpose      : Spectre (Clinical) macro to create the titles and footnotes for
/                a standard report.
/ SubMacros    : %jobinfo %protinfo %proginfo %??titles %maxtitle
/ Notes        : This is the main macro for the reporting system. It will call
/                a client titles macro %??titles where "??" is the title style
/                identifier set up in "protocol.txt".
/ Usage        : Should be used with the %openrep and %closerep macros as below.
/ 
/ %allocr
/ %titles
/ %openrep
/ <reporting code>
/ %closerep
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ program=          (optional) Program name override
/ label=            (optional) Label (max two characters lower case) to identify
/                   the set of titles when there is multiple sets of titles per
/                   program.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar06         _figbkmark_ declared as global in case set later
/ rrb  13Feb07         "macro called" message added
/ rrb  23Feb07         Make sure xsync and noxwait options set as well
/ rrb  07Mar07         _popdone_ global macro variable added to indicate
/                      whether the population label has been included in the
/                      constructed header lines. 0=not done (default).
/ rrb  21Mar07         "center" option no longer enforced (v1.2)
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: titles v1.2;

%macro titles(program=,label=);

  *- fix options so Spectre can work correctly -;
  options noovp nodate nonumber xsync noxwait;

  %local err;
  %let err=ERR%str(OR);

  %*- abort check -;
  %global _abort_ _figbkmark_;
  %let _figbkmark_=;

  %if %length(&_abort_) %then %do;
    %put &err: (titles) There has been a problem in a previous macro so this macro will now exit;
    %goto exit;
  %end;


  %*- indicator so say whether population label has been output. -;
  %*- 0 = not done yet. -;
  %global _popdone_;
  %let _popdone_=0;


  %*- get job information and write to global macro variables -;
  %jobinfo


  %*- program name defaults to that set up in _prog_ -;
  %if not %length(&program) %then %let program=&_prog_;


  %*- label should be lower case if supplied -;
  %if %length(&label) %then %let label=%lowcase(&label);


  %*- call macros that write important information to global macro variables -;
  %protinfo
  %proginfo(program=&program,label=&label)


  %*- check for an abort alert in the previous macros -;
  %if %length(&_abort_) %then %do;
    %put &err: (titles) There has been a problem in a previous macro so this macro will now exit;
    %goto exit;
  %end;


  *- set linesize and pagesize options -;
  options ls=&_ls_ ps=&_ps_;



  %*- call the titles macro corresponding to the style to finish setting up the titles -;
  %&_titlestyle_.titles(program=&program,label=&label)



  %*- Call maxtitle so highest title number and footnote number are -;
  %*- displayed in the sas log. -;
  %maxtitle;


  %*- Create a dummy footnote if none were set up so that a single page -;
  %*- gets the full number of lines on a page. Do not increment _maxfoot_ -;
  %*- as the user is free to overwrite it. -;
  %if &_maxfoot_ EQ 0 %then %do;
    footnote1 "    ";
  %end;



  %goto skip;
  %exit: %put &err: (titles) Leaving macro due to problem(s) listed;
  %skip:

%mend titles;
