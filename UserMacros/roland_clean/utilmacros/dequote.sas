/*<pre><b>
/ Program      : dequote.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Function-style macro to remove front and end matching quotes
/                from a macro string and return the result.
/ SubMacros    : %qdequote
/ Notes        : This is a function-style macro that calls %qdequote and uses
/                %unquote to remove the macro quoting so that you can use it in
/                ordinary sas code.
/ Usage        : %let str=%dequote(%qreadpipe(echo '%username%'));
/                
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) Macro string to dequote
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dequote v1.0;

%macro dequote(str);
%unquote(%qdequote(&str))
%mend dequote;
