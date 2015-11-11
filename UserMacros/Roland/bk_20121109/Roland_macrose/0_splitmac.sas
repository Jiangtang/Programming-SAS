/*<pre><b>
/ Program   : splitmac.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 08-May-2011
/ Purpose   : Function-style macro to insert split characters in a macro string
/ SubMacros : none
/ Notes     : This is the sister macro to %splitmac except it works on macro
/             values instead of SAS variables. It is a function-style macro.
/
/             A split character will normally be placed in a blank space. If
/             there is no suitable space then it will be inserted after a hyphen.
/             But if there is no suitable space and no hyphen then it will be
/             inserted at the end. 
/
/             This macro will only look back the floor of half the column width
/             to find a place to insert the split character.
/
/             If the input string has one or more equals signs in it then
/             enclose the string in %str(). If it has one or more commas in it
/             then enclose it in %quote().
/
/ Usage     : %let str=The quick brown fox jumped over the lazy dog;
/             %let splitstr=%splitmac(&str,10);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) Macro string to split.
/ cols              (pos) Maximum number of columns allowed.
/ split=*           Split character. Must be a single character, unquoted.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  08May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: splitmac v1.0;

%macro splitmac(str,cols,split=*);

  %local errflag err _cols tempstr res;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&str) %then %do;
    %let errflag=1;
    %put &err: (splitmac) No string supplied as first positional parameter;
  %end;

  %if not %length(&cols) %then %do;
    %let errflag=1;
    %put &err: (splitmac) No column width supplied as second positional parameter;
  %end;
  %else %if %sysfunc(verify(&cols,1234567890)) %then %do;
    %let errflag=1;
    %put &err: (splitmac) Cols parameter "&cols" not a valid number of columns;
  %end;

  %if not %length(&split) %then %let split=*;

  %if %length(&split) GT 1 %then %do;
    %let errflag=1;
    %put &err: (splitmac) Split character &split is not a single unquoted character;
  %end;

  %if &errflag %then %goto exit;

  %let tempstr=&str;

  %do %while(%length(&tempstr) GT &cols);
    %do _cols=(&cols+1) %to %eval(&cols/2) %by -1;
      %if "%qsubstr(%quote(&tempstr),&_cols,1)" EQ " " %then %do;
        %let res=&res%qsubstr(%quote(&tempstr),1,%eval(&_cols - 1))&split;
        %let tempstr=%qsubstr(%quote(&tempstr),%eval(&_cols+1));
        %let _cols=1;
      %end;
    %end;
    %*- if space character not found look for a hyphen -;
    %if &_cols GT 1 %then %do;
      %do _cols=&cols %to %eval(&cols/2) %by -1;
        %if "%qsubstr(%quote(&tempstr),&_cols,1)" EQ "-" %then %do;
          %let res=&res%qsubstr(%quote(&tempstr),1,&_cols)&split;
          %let tempstr=%qsubstr(%quote(&tempstr),%eval(&_cols+1));
          %let _cols=1;
        %end;
      %end;
    %end;
    %*- if no hyphen found then split at end -;
    %if &_cols GT 1 %then %do;
      %let res=&res%qsubstr(%quote(&tempstr),1,&cols)&split;
      %let tempstr=%qsubstr(%quote(&tempstr),&cols+1);
    %end;
  %end;

&res&tempstr

  %goto skip;
  %exit: %put &err: (splitmac) Leaving macro due to problem(s) listed;
  %skip:

%mend splitmac;
