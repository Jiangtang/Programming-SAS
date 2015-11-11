/*<pre><b>
/ Program   : ls.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Jun-2011
/ Purpose   : Function-style macro to return a list of members of a directory
/             on a Unix platform according to the file pattern you supply.
/             If you supply just the directory name then all members are 
/             listed. This runs the Unix command in the form "ls -1 mydir" .
/ SubMacros : %qreadpipe
/ Notes     : Just the file names are returned unquoted. If you need the full
/             path name in double quotes then use the %lsfpq macro instead
/             which will correctly handle file names containing spaces.
/ Usage     : %let dirlist=%ls(/usr/utilmacros);
/             %let dirlist=%ls(/usr/utilmacros/*.sas);
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

%put MACRO CALLED: ls v1.1;

%macro ls(dir);
%unquote(%qreadpipe(ls -1 %sysfunc(dequote(&dir))))
%mend ls;

