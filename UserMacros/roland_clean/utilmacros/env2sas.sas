/*<pre><b>
/ Program   : env2sas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To write system and user environment variables to a dataset.
/ SubMacros : %env2ds
/ Notes     : By default, the output dataset will be named _env2sas. The name of
/             the environment variables will be held in the variable "name" with
/             length 40 and the value will be held in the variable "value" with
/             length 1000. A temporary file reference is used named "_env2ds"
/             that will be cleared after use.
/
/             This version is for non-specifc operating systems but might not
/             work on the Windows 7 operating system due to unnamed pipes not
/             working. If you are running on Windows 7 and this macro does not 
/             work then use %env2dsw7 instead.
/
/             For later version of SAS software then this information might be
/             held in the sashelp library as a view in which case this macro
/             will be withdrawn.
/
/ Usage     : %env2sas;
/             %env2sas(OutputDatasetName);
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

%put MACRO CALLED: env2sas v1.0;

%macro env2sas(dsout);
  %if not %length(&dsout) %then %let dsout=_env2sas;
  %env2ds(&dsout)
%mend env2sas;
