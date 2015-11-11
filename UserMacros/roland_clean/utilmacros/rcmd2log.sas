/*<pre><b>
/ Program   : rcmd2log.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Aug-2011
/ Purpose   : To run a system command on the remote host and write the output to
/             the log.
/ SubMacros : none
/ Notes     : This macro is only for use in sas sessions where you can "rsubmit"
/             code to a remote server.
/
/             It works by using a pipe filename statement in an rsumbit
/             block where the output is read in and written to the log.
/
/ Usage     : %rcmd2log(ps -fu userid); *- see details of a user-id -;
/             %rcmd2log(ps -fp 12345);  *- see details of a process-id -;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ cmd               (pos) command you want to run in the remote session
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Aug11         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: rcmd2log v1.0;

%macro rcmd2log(cmd);
  %syslput _rcmd=&cmd;
  rsubmit;
  filename _rcmd pipe "&_rcmd";
  data _null_;
    infile _rcmd;
    input;
    put _infile_;
  run;
  filename _rcmd clear;
  endrsubmit;
%mend rcmd2log;
