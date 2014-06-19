/*<pre><b>
/ Program   : dosfdasize.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Nov-2011
/ Purpose   : Function-style macro to check a dataset size and obs count against
/             FDA guideline limits.
/ SubMacros : %dosfilesize %nlobs
/ Notes     : This is to check the dataset size before it gets converted to a
/             sas transport file for sending to the FDA. If the dataset is too
/             large then it will need to be split into smaller files. How you do
/             that is up to you but normally it will need to be split in a
/             logical fashion and the files numbered or named logically as well.
/
/             This is a function-style macro that returns "OK" or "NOTOK" and
/             optionally issues warnings if size limits are broken.
/
/             The limits are taken from guidelines but may not be up to date so
/             you should recode the defaults in this macro if need be.
/ Usage     : %if %dosfdasize(dset) EQ NOTOK %then %do;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) dataset to check
/ maxmb=50          Megabyte limit (defaults to 50)
/ maxobs=125999     Observations limit (defaults to 1259999)
/ warn=yes          Whether to issue warnings or not
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  15Nov11         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: dosfdasize v1.0;

%macro dosfdasize(ds,maxmb=50,maxobs=125999,warn=yes);
  %local wrn size obs bytes maxsize;
  %let wrn=WAR%str(NING);
  %let bytes=%eval(&maxmb*1024*1024);
  %let obs=%nlobs(&ds);
  %let size=%dosfilesize(&ds);
  %let maxsize=%eval(&maxmb*1024*1024);
  %if not %length(&warn) %then %let warn=yes;
  %let warn=%upcase(%substr(&warn,1,1));
  %if &size GT &maxsize or &obs GT &maxobs %then %do;
NOTOK
    %if &warn EQ Y %then %do;
      %if &size GT &maxsize %then
%put &wrn: (dosfdasize) &ds byte size &size exceeds maximum allowed size &maxsize;
      %if &obs GT &maxobs %then
%put &wrn: (dosfdasize) &ds obs count &obs exceeds maximum allowed obs &maxobs;
    %end;
  %end;
  %else %do;
OK
  %end;
%mend dosfdasize;
