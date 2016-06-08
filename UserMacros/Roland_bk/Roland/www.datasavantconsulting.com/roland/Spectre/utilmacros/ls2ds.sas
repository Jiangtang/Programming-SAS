/*<pre><b>
/ Program   : ls2ds.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To write a list of Unix/Linux file names to a sas dataset
/ SubMacros : %ls2sas
/ Notes     : The command "LS -1" is used to list the members that fit the file
/             pattern you specify. The output dataset will contain a field
/             "filename" that is the name of the file as listed and "lcfname"
/             which is a lower case version of "filename" that is convenient for
/             checking purposes.
/ Usage     : %ls2ds(./MYLIB/*.txt);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepattern       (pos) File pattern
/ dsout             (pos) Output dataset name (defaults to _ls2ds)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ls2ds v1.0;

%macro ls2ds(filepattern,dsout);
  %if not %length(&dsout) %then %let dsout=_ls2ds;
  %ls2sas(&filepattern,&dsout)
%mend ls2ds;
