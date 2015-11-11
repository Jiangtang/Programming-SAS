/*<pre><b>
/ Program   : dirfpq.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 25-Apr-2013
/ Purpose   : Function-style macro to return a list of full-path quoted members
/             of a directory on a Windows platform according to the file pattern
/             you supply.
/ SubMacros : %qreadpipe
/ Notes     : Members are shown with the full path names in double quotes. If a
/             file name contains spaces then this will be correctly quoted. You
/             MUST give the full file pattern and not just the directory as this
/             does not use the DIR command to act on the directory but rather
/             expands the file pattern.
/ Usage     : %let dirlist=%dirfpq(C:\utilmacros);     %*- NO GOOD -;
/             %let dirlist=%dirfpq(C:\utilmacros\*);      %*- GOOD -;
/             %let dirlist=%dirfpq(C:\utilmacros\*.sas);  %*- GOOD -;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dir               (pos) Directory path name with file pattern (no quotes but
/                   if the file path contains "&" or "%" then enclose in
/                   %nrstr() ).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jun11         Remove quotes if supplied (v1.1)
/ rrb  25Apr13         Reinstate noquotes condition and allow for "%" and "&" in
/                      the directory name (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dirfpq v2.0;

%macro dirfpq(dir);
%unquote(%qreadpipe(echo off & for %nrstr(%f) in ("&dir") do echo "%nrstr(%f)"))
%mend dirfpq;
