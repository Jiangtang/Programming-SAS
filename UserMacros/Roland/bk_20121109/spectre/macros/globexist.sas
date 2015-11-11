/*<pre><b>
/ Program   : globexist.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Jul-2007
/ Purpose   : Function-style macro to return true if all the global macro
/             variables listed exist.
/ SubMacros : %match %globlist
/ Notes     : Non-matching global macro variable names will be returned in the 
/             global macro variable _nomatch_ .
/ Usage     : %if %globexist(globvar) %then %do ....
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ globvars          (pos) List of global macro variables
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: globexist v1.0;

%macro globexist(globvars);
%local globmatch;
%let globmatch=%match(%globlist,%upcase(&globvars));
%if not %length(&_nomatch_) %then 1;
%else 0;
%mend;



  