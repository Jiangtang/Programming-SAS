/*<pre><b>
/ Program   : lsfp2sas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Apr-2013
/ Purpose   : To write a list of Unix/Linux full path file names to a dataset
/ SubMacros : none
/ Notes     : Full path file names will be listed that fit the file pattern you
/             specify. The output dataset will contain a field "filename" that
/             is the full path file name as listed and "lcfname" which is a
/             lower case version of "filename" without the path prefix that is
/             convenient for checking purposes.
/ Usage     : %lsfp2sas(./MYLIB/*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern
/ dsout             (pos) Output dataset name (defaults to _lsfp2sas)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  23Apr13         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lsfp2sas v1.0;

%macro lsfp2sas(filepattern,dsout);

  %local savopts;
  %let savopts=%sysfunc(getoption(NOTES));

  %if not %length(&dsout) %then %let dsout=_lsfp2sas;

  options nonotes;

  filename _lsfp pipe 
  "for fn in %sysfunc(dequote(&filepattern)) ; do echo $fn ; done";

  data &dsout;
    length filename $ 300 lcfname $ 200;
    infile _lsfp;
    input;
    filename=trim(_infile_);
    lcfname=lowcase(scan(filename,-1,"/"));
  run;

  filename _lsfp CLEAR;

  options &savopts;

%mend lsfp2sas;
