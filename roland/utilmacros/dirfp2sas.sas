/*<pre><b>
/ Program   : dirfp2sas.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 25-Apr-2013
/ Purpose   : To write a list of windows full path file names to a sas dataset
/ SubMacros : none
/ Notes     : Full path file names will be listed that fit the file pattern you
/             specify. The output dataset will contain a field "filename" that
/             is the full path file name as listed and "lcfname" which is a
/             lower case version of "filename" without the path prefix that is
/             convenient for checking purposes.
/ Usage     : %dirfp2sas(\\Client\C$\MYLIB\*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern (no quotes but if the file pattern
/                   contains "&" or "%" then enclose in %nrstr() ).
/ dsout             (pos) Output dataset name (defaults to _dirfp2sas)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  22Apr13         new (v1.0)
/ rrb  25Apr13         Disallow use of quotes to enclose filepattern and changed
/                      to cope with "&" and "%" in file pattern (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dirfp2sas v2.0;

%macro dirfp2sas(filepattern,dsout);

  %local savopts;
  %let savopts=%sysfunc(getoption(NOTES));

  %if not %length(&dsout) %then %let dsout=_dirfp2sas;

  options nonotes;

  filename _dirfp pipe
  "echo off & for %nrstr(%f) in (""&filepattern"") do echo %nrstr(%f)";

  data &dsout;
    length filename $ 300 lcfname $ 200;
    infile _dirfp;
    input;
    filename=trim(_infile_);
    lcfname=lowcase(scan(filename,-1,"\"));
  run;

  filename _dirfp CLEAR;

  options &savopts;

%mend dirfp2sas;
