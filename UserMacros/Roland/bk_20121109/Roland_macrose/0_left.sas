/*<pre><b>
/ Program   : left.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to left-align the contents of a macro
/             variable.
/ SubMacros : %verify
/ Notes     : This is kept so that old code that calls the %left() macro can
/             work. For new code use %sysfunc(left()).
/ Usage     : %let macvar=%left(&macvar);
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
/ rrb  01May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: left v1.0;

%macro left(string);
  %if %length(%compress(&string,%str( ))) %then %substr(&string,%verify(&string,%str( )));
%mend left;
