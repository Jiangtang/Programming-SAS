/*<pre><b>
/ Program   : rcmd2mvar.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Aug-2011
/ Purpose   : To run a system command on the remote host and write the output to
/             a macro variable on the local host.
/ SubMacros : %getvalue
/ Notes     : This macro is only for use in sas sessions where you can "rsubmit"
/             code to a remote server.
/
/             It works by using a pipe filename statement in an rsumbit block
/             where the output is read in and written to a dataset that is read
/             into a macro variable back on the local host.
/
/             Only use this for commands returning one line output. For multiple
/             line output then use %rcmd2ds to write to a dataset or %rcmd2log
/             to write to the log.
/
/             The macro variable to receive the output must have been declared
/             in a local session before this macro is called. Note that this is
/             not a "function-style macro". It must be used in the way shown in
/             the usage notes.
/
/ Usage     : %rcmd2mvar(ps -fu userid,mymvar); *- see details of a user-id -;
/             %rcmd2mvar(ps -fp 12345,mymvar); *- see details of a process-id -;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ cmd               (pos) command you want to run in the remote session
/ mvar              (pos) Name of macro variable to write output to
/ usequotes=no      By default, do not quote the returned string
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Aug11         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: rcmd2mvar v1.0;

%macro rcmd2mvar(cmd,mvar,usequotes=no);
  %syslput _rcmd=&cmd;
  RSUBMIT;
    filename _rcmd pipe "&_rcmd";
    data _rcmd;
      infile _rcmd;
      input;
      str=trim(_infile_);
    run;
    filename _rcmd clear;
  ENDRSUBMIT;
  %let &mvar=%getvalue(rwork._rcmd,str,1,usequotes=&usequotes);
  proc datasets nolist lib=rwork;
    delete _rcmd;
  run;
  quit;
%mend rcmd2mvar;
