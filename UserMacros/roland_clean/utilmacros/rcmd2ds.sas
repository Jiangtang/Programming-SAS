/*<pre><b>
/ Program   : rcmd2ds.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To run a system command on the remote host and write the output to
/             a dataset.
/ SubMacros : none
/ Notes     : This macro is only for use in sas sessions where you can "rsubmit"
/             code to a remote server.
/
/             It works by using a pipe filename statement in an rsumbit block
/             where the output is read in and written to a dataset in the RWORK
/             library with the single variable STR.
/
/             This is suitable where multiple lines of output are returned. For
/             single line output you can use %rcmd2mvar to write the output to a
/             macro variable stored locally.
/
/ Usage     : %rcmd2ds(ls /root/usr/mylib)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ cmd               (pos) Command you want to run in the remote session
/ dsout             (pos) Output dataset name to go in RWORK (defaults to
/                   _rcmd2ds).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Aug11         new (v1.0)
/ rrb  20Mar14         Allow output dataset name to be changed. STR length
/                      increased to 256  (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: rcmd2ds v2.0;

%macro rcmd2ds(cmd,dsout);
  %if not %length(&dsout) %then %let dsout=_rcmd2ds;
  %syslput _rcmd=&cmd;
  %syslput _dsout=&dsout;
  RSUBMIT;
  filename _rcmd2ds pipe "&_rcmd";
  data &_dsout;
    length str $ 256;
    infile _rcmd2ds;
    input;
    str=_infile_;
  run;
  filename _rcmd2ds CLEAR;
  ENDRSUBMIT;
%mend rcmd2ds;
