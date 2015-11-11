/*<pre><b>
/ Program   : combpath.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 18-Jun-2014
/ Purpose   : Function-style macro to append a path extension onto a base path
/             translating the slashes in the extension to the majority slash
/             direction in the base path.
/ SubMacros : none
/ Notes     : You might have to surround the base path or extension path or both
/             with %nrbquote() or mask special characters another way.
/ Usage     : %let path=aaa\bbb\cc\dhh/jj;
/             %let ext=/dd/ff;
/             %let newpath=%combpath(&path,&ext);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ base              (pos) Base path
/ ext               (pos) Extension path
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  18Jun14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: combpath v1.0;

%macro combpath(base,ext);
  %local goodslash badslash;
  %let goodslash=\;
  %let badslash=/;
  %if %length(%sysfunc(compress(&base,\)))
   GT %length(%sysfunc(compress(&base,/))) %then %do;
    %let goodslash=/;
    %let badslash=\;
  %end;
&base%sysfunc(translate(&ext,&goodslash,&badslash))
%mend combpath;
