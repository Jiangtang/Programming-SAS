/*<pre><b>
/ Program   : cmd2ds.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To run a local system command and write the output to a dataset
/ SubMacros : none
/ Notes     : This is suitable where multiple lines of output are returned. For
/             single line output you can use %qreadpipe to write the output to a
/             macro variable stored locally.
/
/ Usage     : %cmd2ds(ls /root/usr/mylib)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ cmd               (pos) Command you want to run in the local session
/ dsout             (pos) Output dataset name (defaults to _cmd2ds)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: cmd2ds v1.0;


%macro cmd2ds(cmd,dsout);
  %if not %length(&dsout) %then %let dsout=_cmd2ds;
  filename _cmd2ds pipe "&cmd";
  data &dsout;
    length str $ 256;
    infile _cmd2ds;
    input;
    str=_infile_;
  run;
  filename _cmd2ds CLEAR;
%mend cmd2ds;
