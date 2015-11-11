/*<pre><b>
/ Program   : lscmd.sas
/ Version   : 1.2
/ Author    : Roland Rashleigh-Berry
/ Date      : 24-Aug-2013
/ Purpose   : Function-style macro to return a list of members of a directory
/             on a Unix platform according to the file pattern you supply.
/             If you supply just the directory name then all members are 
/             listed. This runs the Unix command in the form "ls -1 mydir" .
/ SubMacros : %qreadpipe
/ Notes     : Just the file names are returned unquoted. If you need the full
/             path name in double quotes then use the %lsfpq macro instead
/             which will correctly handle file names containing spaces.
/ Usage     : %let dirlist=%lscmd(/usr/utilmacros);
/             %let dirlist=%lscmd(/usr/utilmacros/*.sas);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dir               (pos) Directory path name (no quotes)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jun11         Remove quotes if supplied (v1.1)
/ rrb  24Aug13         Name of this macro changed from "ls" to "lscmd" so as not
/                      to be the same as a macro of that name in the sas
/                      autocall library (v1.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lscmd v1.2;

%macro lscmd(dir);
%unquote(%qreadpipe(ls -1 %sysfunc(dequote(&dir))))
%mend lscmd;

