/*<pre><b>
/ Program   : lrafootnote.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To left and right-align a two part footnote for a pure text output
/ SubMacros : none
/ Notes     : This is for pure text output listings and tables. For other types 
/             of output you can use j=left, j=right or .j=left and .j=right in
/             the footnote statement to align elements of it.
/ Usage     : %lrafootnote(5,"Left aligned","Right-aligned")
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ num               (pos) Number of footnote
/ textl             (pos) Text for left alignment (must be in quotes)
/ textr             (pos) Text for right alignment (must be in quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lrafootnote v1.0;

%macro lrafootnote(num,textl,textr);

  %local ls lenl lenr lent rpt wrn;
  %let wrn=WAR%str(NING);

  %let lenl=0;
  %if %length(&textl) %then %let lenl=%eval(%length(&textl)-2);

  %let lenr=0;
  %if %length(&textr) %then %let lenr=%eval(%length(&textr)-2);

  %let ls=%sysfunc(getoption(linesize));

  %let lent=%eval(&lenl+&lenr);

  %if &lent GT &ls %then %do;
    %put &wrn: (lrafootnote) Your footnote text is longer than the current linesize of &ls;
    footnote&num &textl &textr;
  %end;
  %else %if &lent EQ &ls %then %do;
    footnote&num &textl &textr;
  %end;
  %else %do;
    %let rpt=%eval(&ls-&lent-1);
    footnote&num &textl "%sysfunc(repeat(%str( ),&rpt))" &textr;
  %end;

%mend lrafootnote;
