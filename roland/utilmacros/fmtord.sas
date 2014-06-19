/*<pre><b>
/ Program      : fmtord.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : To create a numeric informat that maps a format label to its
/                order position.
/ SubMacros    : %words %fmtpath %verifyb
/ Notes        : The informat will be called fmtord. by default.
/ Usage        : %fmtord(agernge);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ format            (pos) format name to create informat from
/ infmtname=fmtord  Name of the informat created. Do not end with a period.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: fmtord v1.0;

%macro fmtord(format,infmtname=fmtord);

  %local ext i cat catlist gotit err fmtname;
  %let err=ERR%str(OR);

  %*- drop the "." ending and any numbers immediately preceding it -;
  %let fmtname=%upcase(%substr(&format,1,%verifyb(&format,0123456789.)));
  %let format=&fmtname;

  %let ext=FORMAT;
  %if "%substr(&fmtname,1,1)" EQ "$" %then %do;
    %let ext=FORMATC;
    %let fmtname=%substr(&fmtname,2);
  %end;

  %let catlist=%fmtpath;

  %let gotit=0;
  %do i=1 %to %words(&catlist);
    %let cat=%scan(&catlist,&i,%str( ));
    %if %sysfunc(cexist(&cat..&fmtname..&ext)) %then %do;
      %let gotit=1;
      proc format lib=&cat cntlout=_fmtord;
        select &format;
      run;
      quit;
      data _fmtord;
        length label $ 6;
        retain fmtname "&infmtname" type 'I';
        set _fmtord(keep=label rename=(label=start));
        label=left(put(_n_,6.));
      run;
      proc format cntlin=_fmtord;
      run;
      proc datasets nolist;
        delete _fmtord;
      run;
      quit;
      %let i=99;
    %end;
  %end;

  %if not &gotit %then %put &err: (fmtord) Format "&format" not found;

%mend fmtord;
