/*<pre><b>
/ Program      : fmtpath.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 13-Apr-2011
/ Purpose      : Function-style macro to get the full fmtsearch path
/ SubMacros    : %words
/ Notes        : All single-named catalogs will be completed with .FORMATS
/                and WORK.FORMATS and LIBRARY.FORMATS will be added if missing.
/                This macro will not check whether the catalogs actually exist.
/                It just prepares the list for later processing and it is at
/                that later stage that the existence of the catalogs must be
/                checked.
/ Usage        : %let path=%fmtpath;
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  22Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  13Apr11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: fmtpath v1.0;

%macro fmtpath;

  %local i cat cats catlist;

  %let cats=%sysfunc(compress(%sysfunc(getoption(fmtsearch)),%(%)));
  %let cats=%sysfunc(translate(%quote(&cats),%str( ),%str(,)));

  %do i=1 %to %words(&cats);
    %let cat=%qscan(&cats,&i,%str( ));
    %if not %index(&cat,.) %then %let cat=&cat..FORMATS;
    %let catlist=&catlist &cat;
  %end;

  %if not %index(&catlist,LIBRARY.FORMATS) %then %let catlist=LIBRARY.FORMATS &catlist;
  %if not %index(&catlist,WORK.FORMATS) %then %let catlist=WORK.FORMATS &catlist;

&catlist
%mend fmtpath;

