/*<pre><b>
/ Program   : rcmd2ds.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Aug-2011
/ Purpose   : To run a system command on the remote host and write the output to
/             the dataset RWORK._rcmd.
/ SubMacros : none
/ Notes     : This macro is only for use in sas sessions where you can "rsubmit"
/             code to a remote server.
/
/             It works by using a pipe filename statement in an rsumbit block
/             where the output is read in and written to a dataset _rcmd in the
/             RWORK library with the single variable STR.
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
/ cmd               (pos) command you want to run in the remote session
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Aug11         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: rcmd2ds v1.0;

%macro rcmd2ds(cmd);
  %syslput _rcmd=&cmd;
  RSUBMIT;
    filename _rcmd pipe "&_rcmd";
    data _rcmd;
      length str $ 200;
      infile _rcmd;
      input;
      str=_infile_;
    run;
    filename _rcmd clear;
  ENDRSUBMIT;
%mend rcmd2ds;
