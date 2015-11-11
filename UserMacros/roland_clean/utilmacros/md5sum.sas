/*<pre><b>
/ Program   : md5sum.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Aug-2011
/ Purpose   : To write the md5 checksum to the log for a two-level dataset
/             stored on Unix or Linux.
/ SubMacros : %rcmd2log
/ Notes     : This macro is only for use in sas sessions where you can "rsubmit"
/             code to a remote server.
/
/             This is only intended for two-level dataset names stored on
/             Unix/Linux and uses the "md5sum" command run on the remote host.
/             Do not use it on WORK datasets.
/
/             It is a good idea to run this macro directly after creating a
/             dataset to write the checksum to the log so that you can check at
/             a later date that the dataset has not become corrupted (corruption
/             is more likely in proportion to the size of the dataset). 
/
/ Usage     : %md5sum(outads.basco)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Two level dataset name. Do not use on work datasets.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Aug11         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: md5sum v1.0;

%macro md5sum(ds);
  %local hilvl lowlvl path filename str err;
  %let err=ERR%str(OR);
  %if "%scan(&ds,2,.)" EQ " " %then %do;
    %put &err: (md5sum) You must supply a two level dataset name ds=&ds;
    %goto exit;
  %end;
  %else %do;
    %if not %sysfunc(exist(&ds)) %then %do;
      %put &err: (md5sum) Dataset %upcase(&ds) does not exist;
      %goto exit;
    %end;
    %let hilvl=%scan(&ds,1,.);
    %let lolvl=%scan(&ds,2,.);
    %if %upcase(&hilvl) EQ WORK %then %do;
      %put &err: (md5sum) You must not use this on WORK datasets ds=&ds;
      %put &err: (md5sum) Use only on stored datasets on Unix/Linux;
      %goto exit;
    %end;
    %let path=%sysfunc(pathname(&hilvl));
    %let filename=%lowcase(&lolvl).sas7bdat;
    %let str=rcmd2log(md5sum &path/&filename);
    %put NOTE: (md5sum) %upcase(&ds) is stored as &path/&filename;
    %*- call the rcmd2log macro to display the md5sum in the log -;
    %&str;
  %end;
  %goto skip;
  %exit: %put &err: (md5sum) Leaving macro due to problem(s) listed;
  %skip:
%mend md5sum;
