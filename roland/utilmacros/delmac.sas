/*<pre><b>
/ Program   : delmac.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Jul-2012
/ Purpose   : Macro to delete macros from the work.sasmacr catalog based on an
/             SQL "find" pattern.
/ SubMacros : none
/ Notes     : Note that this expects a "like" pattern and this has syntax rules.
/             For example, the character "_" represents any character. You can
/             "escape" this character by placing a "\" in front. 
/             Any ":" in the "like" pattern will get replaced by "%".
/ Usage     : %delmac(m:);  *- delete all macros starting with "m" -;
/             %delmac(_:);  *- delete every single macro -;
/             %delmac(\_:); *- delete all macros starting with an underscore -;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ like              "like" pattern (no quotes) for macro deletion
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Jul12         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: delmac v1.0;

%macro delmac(like);
  %local delmac err savopts;

  %let err=ERR%str(OR);
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %if not %length(&like) %then %goto exit;

  %let like=%upcase(%sysfunc(translate(&like,%,:)));

  proc catalog catalog=work.sasmacr entrytype=macro;
    contents out=_listmac;
  quit;

  proc sql noprint;
    select name into :delmac separated by " " from _listmac
    where name like "&like" escape '\';
  quit;

  proc datasets nolist;
    delete _listmac;
  quit;

  %if %length(&delmac) %then %do;
    proc catalog catalog=work.sasmacr entrytype=macro;
      delete &delmac;
    quit;
  %end;

  %goto skip;
  %exit: %put &err: (delmac) No "like" string supplied;
  %skip:

  options &savopts;

%mend delmac;
