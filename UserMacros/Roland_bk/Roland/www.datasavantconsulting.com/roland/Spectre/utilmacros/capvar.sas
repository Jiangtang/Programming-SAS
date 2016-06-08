/*<pre><b>
/ Program      : capvar.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : In-datastep macro to tidy case of text in a variable
/ SubMacros    : none
/ Notes        : Must be used inside a data step
/ Usage        : data lparmcd;
/                  set lparmcd;
/                  %capvar(put(lparmcd,lparmcd.),newvar,
/                  ignore="SGOT" "SGPT" "PTT" "LDH" "GGT" "BUN");
/                run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ invar             (pos) Input variable (but can be an expression - see usage)
/ outvar            (pos) Output variable name
/ outlen=80         Output variable length
/ ignore            List of strings to ignore (in quotes separated by spaces)
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

%put MACRO CALLED: capvar v1.0;

%macro capvar(invar,outvar,outlen=80,ignore=);

  length &outvar $ &outlen
         _capvar $ 40;

  _capvari=1;
  do while(scan(&invar,_capvari," ") NE " ");
    _capvari=_capvari+1;
  end;
  _capvarwords=_capvari-1;

  _capvari=1;
  &outvar=" ";
  do while(scan(&invar,_capvari," ") NE " ");
    _capvar=scan(&invar,_capvari," ");
    %if %length(&ignore) %then %do;
    if _capvar in (&ignore) then do;
      if &outvar=" " then &outvar=_capvar;
      else &outvar=trim(&outvar)||" "||_capvar;
      goto _done;
    end;
    %end;
    _capvar=lowcase(_capvar);
    if length(_capvar)=1 then do;
      if _capvari=1 then &outvar=upcase(_capvar);
      else if _capvar="a" then &outvar=trim(&outvar)||" a";
      else &outvar=trim(&outvar)||" "||upcase(_capvar);
    end;
    else do;
      *- always capitalise the first word -;
      if _capvari=1 then &outvar=upcase(substr(_capvar,1,1))||substr(_capvar,2);
      *- leave join words as lower text if not the last word -;
      else if _capvar in ("an" "and" "as" "at" "but" "by" "for" "in" "is" "it" "of"
                         "on" "or" "so" "that" "the" "to" "when" "with")
        and (_capvari < _capvarwords) then &outvar=trim(&outvar)||" "||_capvar;
      *- all other cases -;
      else &outvar=trim(&outvar)||" "||upcase(substr(_capvar,1,1))||substr(_capvar,2);
    end;
    %if %length(&ignore) %then %do;
  _done:
    %end;
    _capvari=_capvari+1;
  end;
  drop _capvari _capvar _capvarwords;

%mend capvar;
