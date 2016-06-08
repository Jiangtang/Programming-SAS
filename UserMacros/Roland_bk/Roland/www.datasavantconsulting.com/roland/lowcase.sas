/*<pre><b>
/ Program   : lowcase.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : Function-style macro to return a lower-case version of a macro
/             variable's contents.
/ SubMacros : none
/ Notes     : This is a direct replacement for a SI-supplied autocall member of
/             the same name.
/ Usage     : %let lcase=%lowcase(&string);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ string            (pos) String to lower-case
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lowcase v1.0;

%macro lowcase(string);
%if %length(&string) %then %sysfunc(lowcase(&string));
%mend;
