/*<pre><b>
/ Program   : env2sasw7.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To write system and user environment variables to a dataset for
/             the Windows 7 operating system.
/ SubMacros : %env2dsw7
/ Notes     : By default, the output dataset will be named _env2sas. The name of
/             the environment variables will be held in the variable "name" with
/             length 40 and the value will be held in the variable "value" with
/             length 1000. A temporary file reference is used named "_env2ds"
/             that will be cleared after use.
/
/             This is a version specifically written for the Windows 7 operating
/             system where using unnamed pipes does not work in the way %env2ds
/             (the non-specific operating system version) uses it. However, it
/             should work for all versions of the Windows operating system.
/
/             For later version of SAS software then this information might be
/             held in the sashelp library as a view in which case this macro
/             will be withdrawn.
/
/ Usage     : %env2sasw7;
/             %env2sasw7(OutputDatasetName);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsout             (pos) Name of output dataset (defaults to _env2sas)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: env2sasw7 v1.0;

%macro env2sasw7(dsout);
  %if not %length(&dsout) %then %let dsout=_env2sas;
  %env2dsw7(&dsout)
%mend env2sasw7;
