/*<pre><b>
/ Program   : ds2tabdlm.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To write the contents of a sas dataset to a tab-delimited file
/ SubMacros : %varlist %words %sas2tabdlm
/ Notes     : If a variable is formatted then that format is applied to the 
/             value.
/
/             If you do not specify a destination file then the contents will
/             be written to the log but the tab characters will not be seen.
/
/             You can use the %dlm2sas macro to convert the output file back
/             into a sas dataset but all columns will be treated as character.
/
/ Usage     : %ds2tabdlm(sashelp.cars,,yes)
/             %ds2tabdlm(sashelp.cars,C:\mylib\myfile.txt,yes)
/             %ds2tabdlm(sashelp.cars,"C:\mylib\myfile.txt",no)
/             %ds2tabdlm(sashelp.cars,"C:\mylib\myfile.txt")
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name (no modifiers)
/ dest              (pos) Destination file (quoted or unquoted)
/ varnames          (pos) By default, show the variable names in the first row.
/                   Set to no to suppress this.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: ds2tabdlm v1.0;

%macro ds2tabdlm(ds,dest,varnames);
  %sas2tabdlm(&ds,&dest,&varnames)
%mend ds2tabdlm;
