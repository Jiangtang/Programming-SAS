/*<pre><b>
/ Program   : rcmd2sas.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To run a system command on the remote host and write the output to
/             a dataset.
/ SubMacros : %rcmd2ds
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
/ Usage     : %rcmd2sas(ls /root/usr/mylib)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ cmd               (pos) Command you want to run in the remote session
/ dsout             (pos) Output dataset name to go in RWORK (defaults to
/                   _rcmd2sas).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  20Mar14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: rcmd2sas v1.0;

%macro rcmd2sas(cmd,dsout);
  %if not %length(&dsout) %then %let dsout=_rcmd2sas;
  %rcmd2ds(&cmd,&dsout)
%mend rcmd2sas;
