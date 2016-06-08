/*<pre><b>
/ Program   : killsas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Jul-2011
/ Purpose   : To kill any user's SAS session except the one running this macro
/ SubMacros : none
/ Notes     : This will close all other sas sessions for a user except the one
/             running this macro. This is a slightly easier macro to call than
/             %killsess where you have only two sas session and you need to
/             close the other one due to some problem. It only closes sas
/             sessions run by the user - not other peoples. It works on a
/             Windows platform only.
/ Usage     : %killsas
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: killsas v1.0;

%macro killsas;
x taskkill /f /fi "IMAGENAME eq sas.exe" /fi "USERNAME eq &sysuserid" /fi "PID ne &sysjobid" ;
%mend killsas;

