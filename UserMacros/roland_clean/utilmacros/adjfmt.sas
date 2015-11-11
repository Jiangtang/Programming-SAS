/*<pre><b>
/ Program      : adjfmt.sas
/ Version      : 1.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 29-Jan-2012
/ Purpose      : To create a format based on a current format that can be
/                adjusted by indenting the labels or by adding leading and
/                trailing underscores.
/ SubMacros    : %words %fmtpath %verifyb %varlen
/ Notes        : The informat will be called "adjfmt" by default but a leading
/                $ will be added for a character format. The name of the format
/                (corrected with a leading $ if needed and without a trailing
/                period) will also be written to the global macro variable
/                _adjfmt_ so that it can be resolved in your program code.
/ Usage        : %adjfmt(agernge,adjrnge,indent=4)
/                %adjfmt(agernge,adjrnge,underscore=yes)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ format            (pos) Format name to create adjusted format from
/ adjfmt=adjfmt     (pos) Name of the adjusted new format to create. Default is
/                   "adjfmt". A $ sign will be added for character formats if
/                   this is missing. This name will also be written to the
/                   global macro variable _adjfmt_ .
/                   ----- you must set one of the two following adjustments ----
/ indent=0          Number of spaces to indent the label
/ underscore=no     Whether to add leading and trailing underscores to the label
/                   (will override indent= usage if set to yes).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  21Dec11         New (v1.0)
/ rrb  02Jan12         Notes disabled (v1.1)
/ rrb  29Jan12         2nd parameter was not positional but is now (v1.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: adjfmt v1.2;

%macro adjfmt(format,
              adjfmt,
              indent=0,
          underscore=no);

  %global _adjfmt_;
  %let _adjfmt_=;
  %local ext i cat catlist gotit err fmtname len savopts;
  %let err=ERR%str(OR);

  %let savopts=%sysfunc(getoption(notes));
  options nonotes;

  %if not %length(&adjfmt) %then %let adjfmt=adjfmt;

  %if not %length(&indent) %then %let indent=0;

  %if not %length(&underscore) %then %let underscore=no;
  %let underscore=%upcase(%substr(&underscore,1,1));

  %*- drop the "." ending and any numbers immediately preceding it -;
  %let fmtname=%upcase(%substr(&format,1,%verifyb(&format,0123456789.)));
  %let format=&fmtname;
  %let adjfmt=%upcase(%substr(&adjfmt,1,%verifyb(&adjfmt,0123456789.)));

  %let ext=FORMAT;
  %if "%substr(&fmtname,1,1)" EQ "$" %then %do;
    %let ext=FORMATC;
    %let fmtname=%substr(&fmtname,2);
    %if "%substr(&adjfmt,1,1)" NE "$" %then %let adjfmt=$&adjfmt;
  %end;

  %let catlist=%fmtpath;

  %let gotit=0;
  %do i=1 %to %words(&catlist);
    %let cat=%scan(&catlist,&i,%str( ));
    %if %sysfunc(cexist(&cat..&fmtname..&ext)) %then %do;
      %let gotit=1;
      proc format lib=&cat cntlout=_adjfmt;
        select &format;
      run;
      quit;
      %let len=%eval(%varlen(_adjfmt,label,x)+%sysfunc(max(2,&indent)));
      data _adjfmt;
        length label $ &len;
        retain fmtname "&adjfmt";
        set _adjfmt(keep=start label rename=(label=xlabel));
        %if &underscore EQ Y %then %do;
          label="_"||trim(xlabel)||"_";
        %end;
        %else %if &indent GT 0 %then %do;
          label=repeat(" ",%eval(&indent-1))||xlabel;
        %end;
        %else %do;
          label=xlabel;
        %end;
        drop xlabel;
      run;
      proc format cntlin=_adjfmt;
      run;
      proc datasets nolist;
        delete _adjfmt;
      run;
      quit;
      %let i=99;
      %let _adjfmt_=&adjfmt;
    %end;
  %end;

  %if not &gotit %then %put &err: (adjfmt) Format "&format" not found;

  options &savopts;

%mend adjfmt;
