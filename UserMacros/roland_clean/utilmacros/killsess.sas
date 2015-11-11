/*<pre><b>
/ Program   : killsess.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Jul-2011
/ Purpose   : To kill a Windows SAS session
/ SubMacros : none
/ Notes     : This macro is for when your SAS session is running on a Windows
/             platform and you can not close it down so you use another session
/             to close it. This would be typical for SAS running on a Citrix
/             server. It assumes you have the "taskkill" utility. You might have
/             to tailor this macro if your windowtitle is shown differently.
/ Usage     : %killsess
/             %killsess(2)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ sessno            (pos) Session number (default 1)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jul11         Do not allow the user to close the sas session running
/                      this macro (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: killsess v1.1;

%macro killsess(sessno);
  %local err;
  %let err=ERR%str(OR);

  %if not %length(&sessno) %then %let sessno=1;
  %else %if %length(%sysfunc(compress(&sessno,1234567890))) %then %do;
    %put &err: (killsess) You must specify an integer for the session number sessno=&sessno;
    %goto exit;
  %end;

  x taskkill /f /fi "USERNAME eq &sysuserid" /fi "PID ne &sysjobid" /fi "WINDOWTITLE eq SAS Session &sessno.*";

  %goto skip;
  %exit: %put &err: (killsess) Leaving macro due to problem(s) listed;
  %skip:
%mend killsess;
