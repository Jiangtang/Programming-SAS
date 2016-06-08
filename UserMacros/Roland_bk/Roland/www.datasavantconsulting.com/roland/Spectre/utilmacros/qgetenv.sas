/*<pre><b>
/ Program      : qgetenv.sas
/ Version      : 1.1
/ Author       : Roland Rashleigh-Berry
/ Date         : 04-May-2011
/ Purpose      : Function-style macro to get the contents of a system or user
/                environment variable and return the result MACRO QUOTED.
/ SubMacros    : %qreadpipe
/ Notes        : Works for Windows and Unix/Linux platforms. If not Windows then
/                a Unix style method of echoing the environment variable using a
/                dollar sign is assumed (i.e. echo $envvar is assumed to work).
/                The result is MACRO QUOTED. If you wish to use the results in
/                normal sas code then you must %unquote() the result. Note that
/                unlike the %sysget macro function, this macro will not give a
/                warning if the environment variable does not exist. Instead a 
/                null string is returned. In the case of Windows then if the
/                first character is a "%" then it is assumed that the
/                environment variable was not resolved and a null string is
/                returned.
/ Usage        : %let newvar=%qgetenv(uservar);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ envvar            (pos) Name of environment variable (unquoted)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Oct09         Macro renamed from getenv to qgetenv (v1.1)
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: qgetenv v1.1;

%macro qgetenv(envvar);
  %local tempres;
  %if "&sysscp" EQ "WIN" %then %do;
    %let tempres=%qreadpipe(echo %nrbquote(%str(%%)%superq(envvar)%str(%%)));
    %*- if it did not resolve then set to null -;
    %if "%qsubstr(%superq(tempres),1,1)" EQ "%" %then %let tempres=;
  %end;
  %else %let tempres=%qreadpipe(echo $&envvar);
&tempres
%mend qgetenv;
