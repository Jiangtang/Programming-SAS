/*<pre><b>
/ Program      : closerep.sas
/ Version      : 4.4
/ Author       : Roland Rashleigh-Berry
/ Date         : 12-Oct-2009
/ Purpose      : Spectre (Clinical) macro to close the temporary file created
/                by the %openrep macro for redirected sas output and copy to a
/                final output file with page number labels added.
/ SubMacros    : %endwith %qreadpipe %qdequote %pagexofy (or another macro
/                defined to _pagemac_). Relies on your having already called
/                the %titles macro so that global macro variables are set.
/ Notes        : If this  macro is called in an interactive session then the
/                final output file will be displayed in the Notepad window.
/
/ Usage        : Should be used with the %titles and %openrep macros as below.
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
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  22jun05         Add system command to delete output .lis file before
/                      overwriting it.
/ rrb  19mar06         Code added for handling figures
/ rrb  13Feb07         "macro called" message added
/ rrb  15Feb07         Macro made Windows compliant for version 2.0
/ rrb  16Feb07         Macro now writes to donelist.tmp rather than .txt file
/ rrb  22Feb07         Display outdir macro value and use a data step to mod to
/                      donelist.tmp instead of using a system command.
/ rrb  23Feb07         Use "systask command" instead of "x"
/ rrb  07Mar07         Use %pagexofy instead of "&_pagescript_" as this global
/                      macro variable is no longer used. Change call to
/                      %pagexofy macro to define the style. Drop use of the
/                      "pagexofy" script for Unix platforms.
/ rrb  25Jun07         Call to %pagexofy macro is now replaced by whatever macro
/                      is defined to the global macro variable _pagemac_ . Note
/                      that whatever macro it is must have exactly the same
/                      style of call with the same parameters.
/ rrb  19Jul07         Uses _lisfile_ for the final output file
/ rrb  19Jul07         Use "donelist" temporary file as defined to donelist
/                      environment variable named "DONELIST"
/ rrb  30Jul07         Header tidy
/ rrb  12Oct09         Calls to %readpipe and %dequote changed to calls to
/                      %qreadpipe and %qdequote due to macro renaming (v4.4)
/===============================================================================
/ No guarantee as to the suitability or accuracy of this code is given or
/ implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: closerep v4.4;

%macro closerep;

  %local i donelist outdir outfile outlis outps err;
  %let err=ERR%str(OR);

  %*- abort check -;
  %global _abort_;
  %if %length(&_abort_) %then %do;
    %put &err: (closerep) There has been a problem in a previous macro so this macro will now exit;
    %goto exit;
  %end;


  %*- Get contents of OUTDIR environment variable if set -;
  %if "&sysscp" EQ "WIN" %then %do;
    %let outdir=%qdequote(%qreadpipe(echo '%OUTDIRWIN%'));
    %*- if it did not resolve then set to null -;
    %if "%qsubstr(&outdir,1,1)" EQ "%" %then %let outdir=;
    %*- make sure it ends with a directory slash -;
    %let outdir=%endwith(&outdir,\);
  %end;
  %else %let outdir=%endwith(%qreadpipe(echo $OUTDIR),/);


  %*- Get contents of DONELIST environment variable if set -;
  %if "&sysscp" EQ "WIN" %then %do;
    %let donelist=%qdequote(%qreadpipe(echo '%DONELIST%'));
    %*- if it did not resolve then set to the "donelist.tmp" default -;
    %if "%qsubstr(&donelist,1,1)" EQ "%" %then %let donelist=donelist.tmp;
  %end;
  %else %do;
    %let donelist=%qreadpipe(echo $DONELIST);
    %*- if it did not resolve then set to the "donelist.tmp" default -;
    %if not %length(&donelist) %then %let donelist=donelist.tmp;
  %end;

  %put NOTE: (closerep) outdir=&outdir donelist=&donelist;



                  /*=================================*
                           TABLES AND LISINGS
                   *=================================*/


  %if "&_reptype_" NE "FIGURE" %then %do;

    %*- set up names of temporary file and final .lis file -;
    %let outfile=&outdir&_prog_..tmp;
    %let outlis=&outdir&_lisfile_;


    *- Reset print output back to standard location. This will also free -;
    *- the lock held on the temporary file so that it can be deleted.  -;
    run;
    proc printto print=print;
    run;


    *- delete output .lis file -;
    %if "&sysscp" EQ "WIN" %then %do;
      systask command "erase &outlis" taskname=del;
    %end;
    %else %do;
      systask command "rm -f &outlis" taskname=del;
   %end;
    waitfor del;


    *- Add page labels and output to new .lis file -;
    %&_pagemac_(&outfile,&outlis,style="&_pagexofy_");


    %*- if OUTDIR is set then write an entry to the "donelist" temporary file -;
    %if %length(&outdir) %then %do;
      data _null_;
        file "&outdir.&donelist" mod;
        put "&_repsort_ &_lisfile_";
      run;
    %end;


    *- Delete temporary output file -;
    %if "&sysscp" EQ "WIN" %then %do;
      systask command "erase &outfile";
    %end;
    %else %do;
      systask command "rm -f &outfile";
    %end;


    %*- If running interactively then display the -;
    %*- output .lis file in the notepad window -;
    %if not %length(&_sysin_) %then %do;
      dm "notepad;inc &outlis";
    %end;

  %end;


                  /*=================================*
                                 FIGURES
                   *=================================*/


  %else %do;
 
    %*- set up name of final ps file -;
    %let outps=&outdir&_prog_..ps&_replabel_;


    data _null_;
      infile psfile;
      file "&outps" new;
      input;
      %if %length(&_figbkmark_) %then %do;
        if _n_=1 then do;
          put _infile_;
          put "/pdfmark where";
          put "{pop} {userdict /pdfmark /cleartomark load put} ifelse";
          put "[ /Title (&_figbkmark_)";
          put "  /OUT pdfmark";
        end;
        else put _infile_;
      %end;
      %else %do;
        put _infile_;
      %end;
    run;


    *- clear the psfile libref -;
    filename psfile clear;


    %*- if OUTDIR is set then write an entry to the "done list" file -;
    %if %length(&outdir) %then %do;
      data _null_;
        file "&outdir.&donelist" mod;
        put "&_repsort_ &_prog_..ps&_replabel_";
      run;
    %end;
  
  %end;



  run;


  %goto skip;
  %exit: %put &err: (closerep) Leaving macro due to problem(s) listed;
  %skip:

%mend closerep;
