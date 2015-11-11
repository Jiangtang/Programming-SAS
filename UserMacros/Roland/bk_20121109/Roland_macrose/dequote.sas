/*<pre><b>
/ Program      : dequote.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 19-Jan-2008
/ Purpose      : Function-style macro to remove front and end matching quotes
/                from a macro string.
/ SubMacros    : none
/ Notes        : This is a function-style macro. The resulting expression will
/                be MACRO QUOTED so you will have to use the %unquote() function
/                if you are using the results in sas code. See usage notes.
/ Usage        : %let str=%dequote(%readpipe(echo '%username%'));
/                CLASS %unquote(%dequote('&trtvar')) ;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Jul07         Header tidy
/ rrb  19Jan08         Note added in header about macro quoting
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dequote v1.0;

%macro dequote(str);

%if (%qsubstr(&str,1,1) EQ %str(%') and %qsubstr(&str,%length(&str),1) EQ %str(%'))
 or (%qsubstr(&str,1,1) EQ %str(%") and %qsubstr(&str,%length(&str),1) EQ %str(%"))
 %then %qsubstr(&str,2,%length(&str)-2);
%else %quote(&str);

%mend;
