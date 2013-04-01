/*<pre><b>
/ Program   : dir.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry (http://www.datasavantconsulting.com/roland/)
/ Date      : 26-Jun-2011
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
/             %put dirlist=%dir(a:\test);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dir               (pos) Directory path name (no quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jun11         Remove quotes if supplied (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dir v1.1;

%macro dir(dir);
  %unquote(%qreadpipe(dir /B %sysfunc(dequote(&dir))))
%mend dir;

