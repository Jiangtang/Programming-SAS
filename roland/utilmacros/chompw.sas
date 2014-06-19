/*<pre><b>
/ Program   : chompw.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to cut out a word from a macro string and
/             optionally cut out words before and/or after it.
/ SubMacros : %words %windex
/ Notes     : The search for the target in the string is only done once, even if
/             there are repeated instances of the target string. Note that this
/             is used as a function-style macro.
/ Usage     : %let str2=%chompw(&str1,&target,2,0,casesens=yes);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String to chomp a piece out of (unquoted)
/ target            (pos) Target string to chomp out
/ after             (pos) Number of words following target string found to chomp
/                    out. Must be an integer.
/ before            (pos) Number of words preceding target string found to chomp
/                    out. Must be an integer.
/ casesens=no       By default the matching on the target is not case sensitive.
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

%put MACRO CALLED: chompw v1.0;

%macro chompw(str,target,after,before,casesens=no);

  %local i w pos start stop;

  %if not %length(&str) %then %goto exit;
  %if not %length(&target) %then %goto exit;

  %if not %length(&after) %then %let after=0;
  %if not %length(&before) %then %let before=0;
  %if not %length(&casesens) %then %let casesens=no;
  %let casesens=%upcase(%substr(&casesens,1,1));

  %if "&casesens" EQ "Y" %then %let pos=%windex(&str,&target);
  %else %let pos=%windex(%upcase(&str),%upcase(&target));

  %if not &pos %then %do;
&str
    %goto exit;
  %end;

  %let w=%words(&str);

  %let start=%sysevalf(&pos-&before);
  %if %sysevalf(&start LT 0) %then %let start=1;

  %let stop=%sysevalf(&pos+&after);
  %if %sysevalf(&stop GT &w) %then %let stop=&w;

  %do i=1 %to &w;
    %if (&i LT &start) or (&i GT &stop) %then %do;
  %scan(&str,&i,%str( ))
    %end;
  %end;

  %exit:

%mend chompw;
