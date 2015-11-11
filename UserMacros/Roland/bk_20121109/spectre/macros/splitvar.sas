/*<pre><b>
/ Program   : splitvar.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 07-Sep-2007
/ Purpose   : In-datastep macro to insert split characters in a string variable
/ SubMacros : none
/ Notes     : A split character will normally be placed in a blank space. If
/             there is no suitable space then it will be inserted after a hyphen.
/             But if there is no suitable space and no hyphen then it will be
/             inserted at the end. You must ensure there is enough room to do
/             this by ensuring the length of the variable is greater than the
/             length of any string.
/
/             This macro will only look back the floor of half the column width
/             to find a place to insert the split character.
/
/             Note that this is not a function-style macro. It must be used in a
/             data step as shown in the usage notes.
/
/ Usage     : data aaa;
/               set aaa;
/               %split(var,10,split='/');
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ var               (pos) Variable to split. The result is written to the same
/                   variable.
/ cols              (pos) Maximum number of columns allowed.
/ split='*'         Split character. Must be a single character exclosed in
/                   quotes. Default is an asterisk.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  07Sep07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: splitvar v1.0;

%macro splitvar(var,cols,split='*');

%local error;
%let error=0;

%if not %length(&var) %then %do;
  %let error=1;
  %put ERROR: (splitvar) No variable name supplied as first positional
parameter;
%end;

%if not %length(&cols) %then %do;
  %let error=1;
  %put ERROR: (splitvar) No column width supplied as second positional
parameter;
%end;
%else %if %sysfunc(verify(&cols,1234567890)) %then %do;
  %let error=1;
  %put ERROR: (splitvar) Cols parameter "&cols" not a valid number of columns;
%end;

%if not %length(&split) %then %let split='*';
%if %length(&split) EQ 1 %then %let split="&split";

%if %length(&split) NE 3 %then %do;
  %let error=1;
  %put ERROR: (splitvar) Split character &split is not a single character
enclosed in quotes;
%end;

%if &error %then %goto error;

_pos=0;
do while(length(substr(&var,_pos+1))>&cols);
  do _cols=(&cols+1) to floor(&cols/2) by -1;
    if substr(&var,_pos+_cols,1) EQ ' ' then do;
      substr(&var,_pos+_cols,1)=&split;
      _pos=_pos+_cols;
      _cols=1;
    end;
  end;
  *- if space character not found look for a hyphen -;
  if _cols>1 then do;
    do _cols=&cols to floor(&cols/2) by -1;
      if substr(substr(&var,_pos+1),_cols,1) EQ '-' then do;
        &var=substr(&var,1,_pos+_cols)||&split||substr(&var,_pos+_cols+1);
        _pos=_pos+_cols+1;
        _cols=1;
      end;
    end;
  end;
  *- if no hyphen found then split at end -;
  if _cols>1 then do;
    &var=substr(&var,1,_pos+&cols)||&split||substr(&var,_pos+&cols+1);
    _pos=_pos+&cols+1;
  end;
end;
drop _pos _cols;

%goto skip;
%error:
%put ERROR: (splitvar) Leaving splitvar macro due to error(s) listed;
%skip:
%mend;
