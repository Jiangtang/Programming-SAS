/*<pre><b>
/ Program   : dir.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 25-Apr-2013
/ Purpose   : Function-style macro to return a list of members of a directory
/             on a WINDOWS platform according to the file pattern you supply.
/             If you supply just the directory name then all members are 
/             listed. This runs the MSDOS command in the form "dir /B mydir"
/ SubMacros : %qreadpipe
/ Notes     : Just the file names are returned unquoted. If you need the full
/             path name in double quotes then use the %dirfpq macro instead
/             which will correctly handle file names containing spaces.
/ Usage     : %let dirlist=%dir(C:\utilmacros);
/             %let dirlist=%dir(C:\utilmacros\*.sas);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dir               (pos) Directory path name (no quotes but if it contains "&"
/                   or "%" then enclose in %nrstr() ).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jun11         Remove quotes if supplied (v1.1)
/ rrb  25Apr13         Reinstate the noquotes condition and allow for spaces,
/                      "&" and "%" in the path name (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dir v2.0;

%macro dir(dir);
  %unquote(%qreadpipe(dir /B """&dir"""))
%mend dir;

