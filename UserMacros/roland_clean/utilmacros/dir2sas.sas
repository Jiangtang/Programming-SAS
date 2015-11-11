/*<pre><b>
/ Program   : dir2sas.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 25-Apr-2013
/ Purpose   : To write a list of windows file names to a sas dataset
/ SubMacros : none
/ Notes     : The command "DIR /B" is used to list the members that fit the
/             file pattern you specify. The output dataset will contain a field
/             "filename" that is the name of the file as listed and "lcfname"
/             which is a lower case version of "filename" that is convenient for
/             checking purposes.
/
/             The file pattern must not be quoted.
/
/             If your file pattern contains "&" or "%" then enclose in %nrstr().
/
/ Usage     : %dir2sas(\\Client\C$\MYLIB\*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern (no quotes but if it contains "&" or "%"
/                   then enclose in %nrstr() ).
/ dsout             (pos) Output dataset name (defaults to _dir2sas)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  22Apr13         new (v1.0)
/ rrb  25Apr13         Code changed to allow for spaces, ampersands and percent
/                      signs in the path name and quoted pattern names no longer
/                      allowed (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dir2sas v2.0;

%macro dir2sas(filepattern,dsout);

  %local savopts;
  %let savopts=%sysfunc(getoption(NOTES));

  %if not %length(&dsout) %then %let dsout=_dir2sas;

  options nonotes;

  filename _dir2sas pipe "dir /B ""&filepattern"" ";

  data &dsout;
    length filename lcfname $ 200;
    infile _dir2sas;
    input;
    filename=trim(_infile_);
    lcfname=lowcase(scan(filename,-1,"\"));
  run;

  filename _dir2sas CLEAR;

  options &savopts;

%mend dir2sas;
