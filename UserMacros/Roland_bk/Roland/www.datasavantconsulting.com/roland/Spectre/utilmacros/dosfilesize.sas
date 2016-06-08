/*<pre><b>
/ Program      : dosfilesize.sas
/ Version      : 2.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 15-Nov-2011
/ Purpose      : Function-style macro to return a DOS file size or a sas dataset
/                size in bytes.
/ SubMacros    : %qdosfileinfo
/ Notes        : This is a shell macro for calling the %qdosfileinfo macro to
/                get a DOS file size (in bytes). See the %qdosfileinfo macro for
/                other information you can extract about a DOS file.
/
/                You can supply a one or two level dataset name in which case it
/                will construct the full path name internally before calling the
/                %qdosfileinfo macro.
/
/ Usage        : %let filesize=%dosfilesize(C:\spectre\unistats.html);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dosfile           (pos) DOS file full path name or one/two level dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Jul07         Header tidy
/ rrb  12Oct09         Call to %dosfileinfo changed to call to %qdosfileinfo due
/                      to macro renaming plus the %unquote() function used
/                      (v1.1)
/ rrb  04May11         Code tidy
/ rrb  15Nov11         Allow for a one or two level dataset name (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dosfilesize v2.0;

%macro dosfilesize(dosfile);
  %local lib ds filename;
  %if %length(%qscan(&dosfile,3,/\.)) %then %do;
%unquote(%qdosfileinfo(&dosfile,z))
  %end;
  %else %do;
    %if %length(%scan(&dosfile,2,.)) %then %do;
      %let lib=%scan(&dosfile,1,.);
      %let ds=%scan(&dosfile,2,.);
    %end;
    %else %do;
      %let ds=&dosfile;
      %let lib=%sysfunc(getoption(USER));
      %if not %length(&lib) %then %let lib=WORK;
    %end;
    %let filename=%sysfunc(pathname(&lib))\&ds..sas7bdat;
%unquote(%qdosfileinfo(&filename,z))
  %end;
%mend dosfilesize;
