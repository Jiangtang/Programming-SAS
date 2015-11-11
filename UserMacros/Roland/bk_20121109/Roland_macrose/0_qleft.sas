/*<pre><b>
/ Program   : qleft.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Sep-2011
/ Purpose   : Function-style macro to left-align the contents of a macro
/             variable and return the result MACRO QUOTED.
/ SubMacros : %verify %qcompress
/ Notes     : 
/ Usage     : %let macvar=%qleft(&macvar);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string	    (pos) String to left-align
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/ rrb  23Sep11         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: qleft v1.0;

%macro qleft(string);
  %if %length(%qcompress(&string,%str( )))
    %then %qsubstr(&string,%verify(&string,%str( )));
%mend qleft;
