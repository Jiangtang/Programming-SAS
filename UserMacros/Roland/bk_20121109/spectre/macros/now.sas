/*<pre><b>
/ Program   : now.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 07-Sep-2007
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
/ fmt               Datetime format to use (default is datetime23.3)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: now v1.0;

%macro now(fmt=datetime23.3);
%sysfunc(datetime(),&fmt)
%mend;
