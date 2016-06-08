/*<pre><b>
/ Program   : env2ds.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 25-Jul-2011
/ Purpose   : To write system and user environment variables to a dataset.
/ SubMacros : none
/ Notes     : By default, the output dataset will be named _env2ds. The name of
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
/ Usage     : %env2ds;
/             %env2ds(OutputDatasetName);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsout             (pos) Name of output dataset (defaults to _env2ds)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  25Jul11         Test for missing value added (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: env2ds v1.1;

%macro env2ds(dsout);

  %if not %length(&dsout) %then %let dsout=_env2ds;

  filename _env2ds pipe 'set';

  data &dsout;
    length name $ 40 value $ 1000;
    infile _env2ds;
    input;
    name=scan(_infile_,1,"=");
    if scan(_infile_,2,"=") NE " " then value=substr(_infile_,index(_infile_,"=")+1);
    label name="Environment Variable Name"
         value="Environment Variable Value"
    ;
  run;

  filename _env2ds clear;
  run;

%mend;
