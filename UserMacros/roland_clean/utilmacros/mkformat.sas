/*<pre><b>
/ Program   : mkformat.sas
/ Version   : 2.3
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Jun-2013
/ Purpose   : To create a format out of "coded" and "decoded" variables for the 
/             specified dataset.
/ SubMacros : %hasvars %varlen %nobs %dequote
/ Notes     : Use this to generate a format from a coded and decoded variable so
/             that you can report it in coded order but have it displayed in its
/             decoded form by applying the generated format.
/
/             Your code and decode variables should not have the name "start" or
/             "label".
/
/             If your input dataset has zero observations then it will generate
/             a single obseration of missing values as input. You will receive
/             no warning in this situation. "Other" processing will still apply
/             in these cases.
/
/             You have to correctly choose your format name which should start
/             with a dollar sign for character formats, should not be more than
/             eight characters long (including the dollar) and should not end in
/             a number as ending in a number is invalid.
/
/ Usage     : %mkformat(dsname(where=(x>1)),varcd,vardcd,fmtname,fmtcat);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Input dataset (one or two level)
/ code              (pos) Coded variable name
/ decode            (pos) Decoded variable name
/ fmtname           (pos) Format name to generate
/ lib               (pos) Catalog library libref for writing the generated
/                   format to (defaults to work).
/ notes=no          By default, do not write NOTEs to the log
/ fmtnotes=yes      By default, write notes to the log about whether the format
/                   was created or not.
/ other=            Set to a value (quoted or unquoted) as the label for OTHER
/ indent=0          Number of spaces to indent the label
/ underscore=no     Whether to use underscore characters before and after the
/                   label (will override indent= if set to yes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Mar07         Macro called message added plus header tidy
/ rrb  30Jul07         Header tidy
/ rrb  19Jan11         Allow modifiers in input dataset specification (v1.2)
/ rrb  30Nov11         indent= parameter added (v1.3)
/ rrb  21Dec11         underscore= processing added (v1.4)
/ rrb  02Jan12         Notes disabled (v1.5)
/ rrb  01Aug12         New version (compatible with the old version) which
/                      allows you to show notes in the log, adds "other"
/                      processing and allows for empty input datasets (v2.0)
/ rrb  28Mar13         Parameter fmtnotes=yes added to activate "notes" just for
/                      the proc format step no matter what the setting for
/                      notes= so the user can see whether the format was created
/                      or not (v2.1)
/ rrb  04Jun13         Check for repeats and warn of any found and just use
/                      the first one (v2.2)
/ rrb  19Jun13         Test for the existence of a VIEW as well (v2.3)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mkformat v2.3;

%macro mkformat(ds,
                code,
                decode,
                fmtname,
                lib,
                notes=no,
                fmtnotes=yes,
                other=,
                indent=,
                underscore=no);

  %local errflag err wrn len savopts;
  %let err=ERR%str(OR);
  %let wrn=WAR%str(NING);

  %let errflag=0;
  %if not %length(&notes) %then %let notes=no;
  %let notes=%upcase(%substr(&notes,1,1));

  %let savopts=%sysfunc(getoption(notes));
  %if &notes NE Y %then %do;
    options nonotes;
  %end;

  %if not %length(&fmtnotes) %then %let fmtnotes=yes;
  %let fmtnotes=%upcase(%substr(&fmtnotes,1,1));

  %if not %sysfunc(exist(%scan(&ds,1,%str(%()))) 
  and not %sysfunc(exist(%scan(&ds,1,%str(%()),VIEW)) %then %do;
    %put &err: (mkformat) Dataset or view &ds does not exist;
    %let errflag=1;
  %end;

  %let fmtname=%sysfunc(compress(&fmtname,.));
  %if not %length(&fmtname) %then %do;
    %put &err: (mkformat) You must supply a format name;
    %let errflag=1;
  %end;
  %else %if %sysfunc(prxmatch('\d$',&fmtname)) %then %do;
    %put &err: (mkformat) Format name must not end in a number fmtname=&fmtname;
    %let errflag=1;    
  %end;

  %if &errflag %then %goto exit;


  %if not %length(&indent) %then %let indent=0;

  %if not %length(&underscore) %then %let underscore=no;
  %let underscore=%upcase(%substr(&underscore,1,1));

  data _mkfmt;
    *-- force an obs if dataset is empty --;
    %if %nobs(&ds) EQ 0 %then output;;
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


  *- warn if there are repeats -;
  data _null_;
    set _mkfmt;
    by start;
    if not (first.start and last.start) then 
put "&wrn: (mkformat) Repeats found - only the first will be used " start= label=;
  run;


  *- keep only the first if there is a repeat -;
  data _mkfmt;
    set _mkfmt;
    by start;
    if first.start;
  run;



  %let len=%varlen(_mkfmt,label,x);
  %if &underscore EQ Y or &indent GT 0 
   %then %let len=%eval(&len+%sysfunc(max(2,&indent)));

  data _mkfmt;
    length label $ &len;
    retain fmtname "&fmtname";
    set _mkfmt 
    %if %length(&other) %then %do;
         end=last
    %end;
    ;
    %if &underscore EQ Y %then %do;
      label="_"||trim(label)||"_";
    %end;
    %else %if &indent GT 0 %then %do;
      label=repeat(" ",%eval(&indent-1))||label;
    %end;
    output;
    *--- if user put in a value for other, compile this block ---*;
    %if %length(&other) %then %do;
      if last then do;
        hlo='O';
        label="%dequote(&other)";
        output;
      end;
    %end;
  run;

  %if &fmtnotes NE N %then %do;
    options notes;
  %end;

  proc format cntlin=_mkfmt
    %if %length(&lib) %then %do;
      library=&lib
    %end;
    ;
  run;

  %if &notes NE Y %then %do;
    options nonotes;
  %end;

  proc datasets nolist;
    delete _mkfmt;
  run;
  quit;

  %goto skip;
  %exit: %put &err: (mkformat) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend mkformat;
