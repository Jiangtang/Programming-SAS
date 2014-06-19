/*<pre><b>
/ Program   : mysasautos.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 28-May-2014
/ Purpose   : Function-style macro to return the user's SASAUTOS setting but
/             with any double quotes translated to single quotes.
/ SubMacros : none
/ Notes     : Use this macro to ensure that when you resolve your SASAUTOS
/             setting within a double quoted string that you do not mess up the
/             syntax due to unknown double quotes being present around file path
/             names. Double quotes are converted to single quotes. Any commas
/             will be kept as they are.
/
/ Usage     : rsubmit wait=no process1 inheritlib=(work=lwork) 
/             sascmd="!sascmd -sasuser work -noautoexec -sasautos %mysasautos";
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  28May14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mysasautos v1.0;

%macro mysasautos;
%sysfunc(translate(%sysfunc(getoption(sasautos)),%str(%'),%str(%")))
%mend mysasautos;
