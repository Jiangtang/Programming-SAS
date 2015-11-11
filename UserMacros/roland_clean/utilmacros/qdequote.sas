/*<pre><b>
/ Program      : qdequote.sas
/ Version      : 1.3
/ Author       : Roland Rashleigh-Berry
/ Date         : 16-Nov-2011
/ Purpose      : Function-style macro to remove front and end matching quotes
/                from a macro string and return the result MACRO QUOTED.
/ SubMacros    : none
/ Notes        : This is a function-style macro. The resulting expression will
/                be MACRO QUOTED so you will have to use the %unquote() function
/                if you are using the results in sas code. See usage notes.
/ Usage        : %let str=%qdequote(%qreadpipe(echo '%username%'));
/                CLASS %unquote(%qdequote('&trtvar')) ;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  30Jul07         Header tidy
/ rrb  19Jan08         Note added in header about macro quoting
/ rrb  31Oct08         Purpose in header updated 
/ rrb  01Jan09         Use %qtrim() instead of %quote()
/ rrb  12Oct09         Macro renamed from dequote to qdequote (v1.2)
/ rrb  04May11         Code tidy
/ rrb  16Nov11         Bug when str is "" fixed (v1.3)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: qdequote v1.3;

%macro qdequote(str);
  %if (%qsubstr(&str,1,1) EQ %str(%') and %qsubstr(&str,%length(&str),1) EQ %str(%'))
  or (%qsubstr(&str,1,1) EQ %str(%") and %qsubstr(&str,%length(&str),1) EQ %str(%"))
  %then %do;
    %if %length(&str) LE 2 %then %qtrim();
    %else %qsubstr(&str,2,%length(&str)-2);
  %end;
  %else %qtrim(&str);
%mend qdequote;
