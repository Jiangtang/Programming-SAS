/*<pre><b>
/ Program      : openrep.sas
/ Version      : 2.1
/ Author       : Roland Rashleigh-Berry
/ Date         : 12-Oct-2009
/ Purpose      : Spectre (Clinical) macro to redirect print output to a
/                temporary file.
/ SubMacros    : %endwith %qreadpipe %qdequote. Relies on your having already
/                called the %titles macro so that global variables are set. At
/                the very least, %jobinfo must have been run.
/ Notes        : none
/ Usage        : Should be used with the %titles and %closerep macros as below.
/ 
/ %allocr
/ %titles
/ %openrep
/ <reporting code>
/ %closerep
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ missing=' '       By default, set missing option to a space. If you set this
/                   to null then no action will be taken.
/ formchar='|_---|+|---+=|-/\<>*'  By default, set formchar option so that
/                   across spanning characters are underscores. If you set this
/                   to null then no action will be taken.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19mar06         Handling for figures added
/ rrb  13Feb07         "macro called" message added
/ rrb  22Feb07         Made Windows compliant for version 2.0
/ rrb  23Feb07         Use "systask command" instead of "x"
/ rrb  30Jul07         Header tidy
/ rrb  12Oct09         Calls to %readpipe and %dequote changed to calls to
/                      %qreadpipe and %qdequote due to macro renaming (v2.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: openrep v2.1;

%macro openrep(missing=' ',formchar='|_---|+|---+=|-/\<>*');

  %local outdir outfile err;
  %let err=ERR%str(OR);

  %*- abort check -;
  %global _abort_;
  %if %length(&_abort_) %then %do;
    %put &err: (openrep) There has been a problem in a previous macro so this macro will now exit;
    %goto exit;
  %end;


  %*- make sure titles macro has run -;
  %global _repid_;
  %if not %length(&_repid_) %then %do;
    %put &err: (openrep) You need to run the "titles" macro before calling this macro;
    %let _abort_=1;
    %goto exit;
  %end;


  %*- Get contents of OUTDIR environment variable if set. -;
  %*- Note that for Cygwin users doing a full run of Spectre then -;
  %*- you have to set up the OUTDIR environment variable manually -;
  %*- as a user environment variable within the Windows environment. -;
  %if "&sysscp" EQ "WIN" %then %do;
    %let outdir=%qdequote(%qreadpipe(echo '%OUTDIRWIN%'));
    %*- if it did not resolve then set to null -;
    %if "%qsubstr(&outdir,1,1)" EQ "%" %then %let outdir=;
    %*- make sure it ends with a directory slash -;
    %let outdir=%endwith(&outdir,\);
  %end;
  %else %let outdir=%endwith(%qreadpipe(echo $OUTDIR),/);


  %put NOTE: (openrep) outdir=&outdir;


  *- set options -;
  %if %length(&missing) %then %do;
    options missing=&missing;
    %put NOTE: (openrep) "missing" option changed to missing=&missing;
  %end;

  %if %length(&formchar) %then %do;
    options formchar=&formchar;
    %put NOTE: (openrep) "formchar" option changed to formchar=&formchar;
  %end;


                  /*=================================*
                           TABLES AND LISINGS
                   *=================================*/


  %if "&_reptype_" NE "FIGURE" %then %do;

    %*- set up name of temporary file -;
    %let outfile=&outdir&_prog_..tmp;

    *- delete temporary file if it already exists -;
    %if "&sysscp" EQ "WIN" %then %do;
      systask command "erase &outfile" taskname=del;
    %end;
    %else %do;
      systask command "rm -f &outfile" taskname=del;
    %end;
    waitfor del;

    *- direct standard print output to the temporary file -;
    run;
    proc printto print="&outfile";
    run;

  %end;


                  /*=================================*
                                 FIGURES
                   *=================================*/

  %else %do;

    %*- set up name of temporary postscript file -;
    %let outfile=&outdir&_prog_..pzz&_replabel_;

    *- set up psfile fileref -;
    filename psfile "&outfile" new;  

    *- set goptions -;
    goptions device=&_device_ targetdevice=&_device_ rotate=&_rotate_
             colors=(black) cback=white
             ftext=swiss ftitle=swiss htext=0.4cm
             gsfname=psfile gunit=cm gsfmode=replace 
             vsize=&_vsize_ hsize=&_hsize_
             vorigin=&_vorigin_ horigin=&_horigin_
             ;
    run;

  %end;

  %goto skip;
  %exit: %put &err: (openrep) Leaving macro due to problem(s) listed;
  %skip:

%mend openrep;
