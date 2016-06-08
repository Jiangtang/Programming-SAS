/*<pre><b>
/ Program   : lslist2ds.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To read the output of the "ls -l" command into a sas dataset
/ SubMacros : %lslist2sas
/ Notes     : The "ls -l" command produces a listing that can be saved to a file
/             but gives problems in that the position of the fields depends on
/             the length of the fields and as such is unpredictable. The fields
/             "group" and "size" might have no gap between them if they are
/             both long so "scanning" for this can give the wrong result.
/             The file name might contains spaces so this should not be scanned
/             for and instead "call scan" needs to be used to find out the
/             position of the date (or time) that precedes the final file name
/             so that the file name can be read using substr() to the end. There
/             may be other instances of when adjacent columns have no gap
/             between them that will need to be catered for.
/
/             The listing is expected to have the following "ls -l" style:
/
/                /dir1/dir2/dir3:
/                total 111
/                drwxr-xr-x   2 root       root          1024 Jan 21  2000 xx_yy
/
/             Variables in the output dataset are, in this order: path, total,
/             permiss, links, owner, group, size, month, day, year, time, date,
/             datetime, filename.
/
/ Usage     : lslist2ds(my-text-file); 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ textfile          (pos) (no quotes) Enclose in %nrstr() if the file path 
/                   contains spaces or special characters.
/ dsout             (pos) Name of output dataset (defaults to "_lslist2ds")
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lslist2ds v1.0;

%macro lslist2ds(textfile,dsout);
  %if not %length(&dsout) %then %let dsout=_lslist2ds;
  %lslist2sas(&textfile,&dsout)
%mend lslist2ds;
