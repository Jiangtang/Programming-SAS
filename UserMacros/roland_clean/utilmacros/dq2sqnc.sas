/*<pre><b>
/ Program   : dq2sqnc.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 27-May-2014
/ Purpose   : Function-style macro to translate double quotes to single quotes
/             after replacing commas in a string with spaces.
/ SubMacros : %dq2sq
/ Notes     : This assumes your quotes are balanced in the string you are
/             converting. Use this macro to ensure that any values you are
/             resolving within a double quoted string do not mess up the syntax
/             due to unknown double quotes being present in the values. A 
/             typical use of this would be to convert any possible double quotes
/             to single quotes in the sasautos option content when invoking a 
/             remote session as a double quoted string and passing your sasautos
/             option setting to that session. It also replaces all commas with
/             spaces which would be very applicable to the example in the usage
/             notes since sasautos libraries can be separated by commas when
/             they are not needed.
/
/             This macro should not use the parameter= convention. It should be
/             used with a purely positional parameter value only.
/
/ Usage     : rsubmit wait=no process1 inheritlib=(work=lwork) 
/             sascmd="!sascmd -sasuser work -noautoexec 
/             -sasautos %dq2sqnc(%sysfunc(getoption(sasautos)))";
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ str               (only positional) String to translate double quotes to
/                   single quotes after replacing commas with spaces.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27May14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: dq2sqnc v1.0;

%macro dq2sqnc/parmbuff;
%dq2sq(%qsubstr(%sysfunc(translate(&syspbuff,%str( ),%str(,))),2,%length(&syspbuff)-2))
%mend dq2sqnc;
