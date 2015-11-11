/*<pre><b>
/ Program   : mkformat.sas
/ Version   : 1.2
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Jan-2011
/ Purpose   : To create a format out of a "coded" and "decoded" variable in a 
/             specified dataset.
/ SubMacros : %hasvars
/ Notes     : Use this to generate a format from a coded and decoded variable so
/             that you can report it in coded order but have it displayed in its
/             decoded form.
/ Usage     : %mkformat(dsname(where=(x>1)),varcd,vardcd,fmtname,fmtcat);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Input dataset
/ code              (pos) Coded variable
/ decode            (pos) Decoded variable
/ fmtname           (pos) Format name
/ lib               (pos) Catalog library (defaults to work)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar07         Macro called message added plus header tidy
/ rrb  30Jul07         Header tidy
/ rrb  19Jan11         Allow modifiers in input dataset specification (v1.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mkformat v1.2;

%macro mkformat(ds,code,decode,fmtname,lib);

  %local errflag err;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %sysfunc(exist(%scan(&ds,1,%str(%()))) %then %do;
    %put &err: (mkformat) Dataset &ds does not exist;
    %let errflag=1;
  %end;

  %if not %length(&fmtname) %then %do;
    %put &err: (mkformat) You must supply a format name;
    %let errflag=1;
  %end;


  %if &errflag %then %goto exit;


  data _mkfmt;
    set &ds;
  run;


  %if not %hasvars(_mkfmt,&code &decode) %then %do;
    %put &err: (mkformat) Dataset &ds does not contain variable(s) &_nomatch_;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;


  proc sort nodupkey data=_mkfmt(keep=&code &decode)
                      out=_mkfmt(rename=(&code=start &decode=label));
    by &code &decode;
  run;

  data _mkfmt;
    retain fmtname "&fmtname";
    set _mkfmt;
  run;

  proc format cntlin=_mkfmt
    %if %length(&lib) %then %do;
      library=&lib
    %end;
    ;
  run;

  proc datasets nolist;
    delete _mkfmt;
  run;
  quit;

  %goto skip;
  %exit: %put &err: (mkformat) Leaving macro due to problem(s) listed;
  %skip:

%mend mkformat;
  