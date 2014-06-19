/*<pre><b>
/ Program   : lstlbls.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Jan-2012
/ Purpose   : To list variables and their labels to the log
/ SubMacros : none
/ Notes     : Variables will be listed in alphabetical order
/ Usage     : %lstlbls(dsname(keep=aa bb cc dd),16);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset (can have modifiers such as a keep list)
/ labcol            (pos) Column to position the label (defaults to 20)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Jan12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lstlbls v1.0;

%macro lstlbls(ds,labcol);

  %local savopts;
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %if not %length(&labcol) %then %let labcol=20;

  %PUT;

  proc contents noprint data=&ds out=_lstcont(keep=name label);
  run;

  data _null_;
    set _lstcont;
    put name @&labcol label;
  run;

  proc datasets nolist;
    delete _lstcont;
  run;
  quit;

  %PUT;

  options &savopts;

%mend lstlbls;