/*<pre><b>
/ Program   : dq2sq.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 27-May-2014
/ Purpose   : Function-style macro to translate double quotes to single quotes
/ SubMacros : none
/ Notes     : This assumes your quotes are balanced in the string you are
/             converting. Use this macro to ensure that any values you are
/             resolving within a double quoted string do not mess up the syntax
/             due to unknown double quotes being present in the values. A 
/             typical use of this would be to convert any possible double quotes
/             to single quotes in the sasautos option content when invoking a 
/             remote session as a double quoted string and passing your sasautos
/             option setting to that session. See usage notes.
/
/             If there might be commas in the string and you are happy to
/             convert those commas to spaces then use the %dq2sqnc macro which
/             is the ---nc = "no commas" equivalent of this macro. This will
/             also be applicable to the example in the usage notes since
/             sasautos libraries can be separated by commas.
/
/ Usage     : rsubmit wait=no process1 inheritlib=(work=lwork) 
/             sascmd="!sascmd -sasuser work -noautoexec 
/             -sasautos %dq2sq(%sysfunc(getoption(sasautos)))";
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (pos) String to translate double quotes to single quotes
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27May14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dq2sq v1.0;

%macro dq2sq(str);
%sysfunc(translate(&str,%str(%'),%str(%")))
%mend dq2sq;
