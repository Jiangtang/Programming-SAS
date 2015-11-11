/*<pre><b>
/ Program   : dir2ds.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To write a list of windows file names to a sas dataset
/ SubMacros : %dir2sas
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
/ Usage     : %dir2ds(\\Client\C$\MYLIB\*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern (no quotes but if it contains "&" or "%"
/                   then enclose in %nrstr() ).
/ dsout             (pos) Output dataset name (defaults to _dir2ds)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dir2ds v1.0;

%macro dir2ds(filepattern,dsout);
  %if not %length(&dsout) %then %let dsout=_dir2ds;
  %dir2sas(&filepattern,&dsout)
%mend dir2ds;
