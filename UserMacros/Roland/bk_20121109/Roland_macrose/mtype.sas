/*<pre><b>
/ Program   : mtype.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the member type of a dataset
/             (i.e. whether DATA or VIEW).
/ SubMacros : %attrc
/ Notes     : This is a shell macro that calls %attrc
/ Usage     : %let mtype=%mtype(dsname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: mtype v1.0;

%macro mtype(ds);
%attrc(&ds,mtype)
%mend mtype;
