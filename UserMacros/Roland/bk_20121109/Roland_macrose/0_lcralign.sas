/*<pre><b>
/ Program      : lcralign.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Write to a macro variable with the supplied text left, center
/                and right-aligned.
/ SubMacros    : none
/ Notes        : The text to align must be in quotes. The macro variable
/                to receive the output must have been declared either locally
/                or globally before calling this macro. If no macro variable
/                name is supplied then a global macro variable _lcralign_ is set
/                up and used. If no length is specified then the line size in
/                effect will be used.
/                This is NOT a function-style macro. See usage notes.
/ Usage        : %let macvar=;
/                %lcralign(macvar,50,"left bit","center bit","right bit")
/                %put macvar=*&macvar*;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ macvar            (pos) name of macro variable to receive aligned results
/                   (will create a global macro variable name _lcralign_ if no
/                    macro variable name specified).
/ len               (pos) number of columns to use (defaults to line size)
/ left              (pos) (in quotes) text to left-align  (optional)
/ center            (pos) (in quotes) text to center      (optional)
/ right             (pos) (in quotes) text to right-align (optional)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lcralign v1.0;

%macro lcralign(macvar,len,l,c,r);

  %local ls;

  %*- set up global macro variable _lcralign_ if no name supplied -;
  %if not %length(&macvar) %then %do;
    %global _lcralign_;
    %let macvar=_lcralign_;
  %end;


  %*- set len to same as line size if no length supplied -;
  %if not %length(&len) %then %do;
    %let ls=%sysfunc(getoption(linesize));
    %let len=&ls;
  %end;


  %*- set macvar contents to null in case data step fails -;
  %let &macvar=;


  *- align the text elements and symput out to macvar -;
  data _null_;
    length text $ &len;
    text=" ";
    %if %length(&l) %then %do;
      text=&l;
    %end;
    %if %length(&c) %then %do;
      substr(text,floor((&len-length(&c))/2)+1)=&c;
    %end;
    %if %length(&r) %then %do;
      substr(text,&len-length(&r)+1)=&r;
    %end;
    call symput("&macvar",text);
  run;

%mend lcralign;
