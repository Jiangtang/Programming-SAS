/*<pre><b>
/ Program   : dirfp2ds.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To write a list of windows full path file names to a sas dataset
/ SubMacros : %dirfp2sas
/ Notes     : Full path file names will be listed that fit the file pattern you
/             specify. The output dataset will contain a field "filename" that
/             is the full path file name as listed and "lcfname" which is a
/             lower case version of "filename" without the path prefix that is
/             convenient for checking purposes.
/ Usage     : %dirfp2ds(\\Client\C$\MYLIB\*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern (no quotes but if the file pattern
/                   contains "&" or "%" then enclose in %nrstr() ).
/ dsout             (pos) Output dataset name (defaults to _dirfp2ds)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dirfp2ds v1.0;

%macro dirfp2ds(filepattern,dsout);
  %if not %length(&dsout) %then %let dsout=_dirfp2ds;
  %dirfp2sas(&filepattern,&dsout)
%mend dirfp2ds;
