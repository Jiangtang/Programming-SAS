/*<pre><b>
/ Program   : ls2sas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Apr-2013
/ Purpose   : To write a list of Unix/Linux file names to a sas dataset
/ SubMacros : none
/ Notes     : The command "LS -1" is used to list the members that fit the file
/             pattern you specify. The output dataset will contain a field
/             "filename" that is the name of the file as listed and "lcfname"
/             which is a lower case version of "filename" that is convenient for
/             checking purposes.
/ Usage     : %ls2sas(./MYLIB/*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern
/ dsout             (pos) Output dataset name (defaults to _ls2sas)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  23Apr13         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ls2sas v1.0;

%macro ls2sas(filepattern,dsout);

  %local savopts;
  %let savopts=%sysfunc(getoption(NOTES));

  %if not %length(&dsout) %then %let dsout=_ls2sas;

  options nonotes;

  filename _ls2sas pipe "ls -1 %sysfunc(dequote(&filepattern))";

  data &dsout;
    length filename lcfname $ 200;
    infile _ls2sas;
    input;
    filename=trim(_infile_);
    lcfname=lowcase(scan(filename,-1,"/"));
  run;

  filename _ls2sas CLEAR;

  options &savopts;

%mend ls2sas;
