/*<pre><b>
/ Program   : mkformat.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : To create a format out of a "coded" and "decoded" variable
/ SubMacros : %hasvars
/ Notes     : Use this to generate a format from a coded and decoded variable so
/             that you can report in coded order but have it displayed in its
/             decoded form.
/ Usage     : %mkformat(dsname,varcode,vardcode,fmtname,fmtcat);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Input dataset (no modifiers)
/ code              (pos) Coded variable
/ decode            (pos) Decoded variable
/ fmtname           (pos) Format name
/ lib               (pos) Catalog (defaults to work)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar07         Macro called message added plus header tidy
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mkformat v1.1;

%macro mkformat(ds,code,decode,fmtname,lib);
%local error;
%let error=0;

%if not %sysfunc(exist(&ds)) %then %do;
  %put ERROR: (mkformat) Dataset &ds does not exist;
  %let error=1;
%end;

%if not %length(&fmtname) %then %do;
  %put ERROR: (mkformat) You must supply a format name;
  %let error=1;
%end;


%if &error %then %goto error;

%if not %hasvars(&ds,&code &decode) %then %do;
  %put ERROR: (mkformat) Dataset &ds does not contain variable(s) &_nomatch_;
  %let error=1;
%end;

%if &error %then %goto error;



proc sort nodupkey data=&ds(keep=&code &decode)
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
%error: %put ERROR: (mkformat) Leaving mkformat macro due to error(s) listed.;
%skip:
%mend;
  