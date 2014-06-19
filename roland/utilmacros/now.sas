/*<pre><b>
/ Program   : now.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Mar-2013
/ Purpose   : Function-style macro to return the current timestamp
/ SubMacros : none
/ Notes     : This macro is just a shorter way of writing what it contains
/             which is the syntax for resolving the current datetime as a macro
/             expression.
/ Usage     : %put Stage1: %now;
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ fmt               Datetime format to use (default is datetime21.2)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/ rrb  19Mar13         Changed default format to datetime21.2 (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: now v1.1;

%macro now(fmt=datetime21.2);
%sysfunc(datetime(),&fmt)
%mend now;
