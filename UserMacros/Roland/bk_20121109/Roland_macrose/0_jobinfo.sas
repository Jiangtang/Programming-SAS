/*<pre><b>
/ Program   : jobinfo.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 12-Oct-2009
/ Purpose   : Spectre (Clinical) macro to store important job information in
/             global macro variables.
/ SubMacros : %qreadpipe
/ Notes     : If this macro can not determine the calling program then it will
/             assume you are running interactively and prompt for the program
/             name.
/ Usage     : %jobinfo
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ N/A
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         Made Windows compliant and "macro called" msg added
/ rrb  30Jul07         Header tidy
/ rrb  28Sep08         Header changed to classify this macro as belonging to
/                      Spectre (Clinical).
/ rrb  12Oct09         Call to %readpipe changed to call to %qreadpipe due to
/                      macro renaming (v2.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: jobinfo v2.1;

%macro jobinfo;

  %*- set up global macro variables -;
  %global _sysin_ _prog_ _user_ _path_;


  %*- assign values -;
  %let _sysin_=%sysfunc(getoption(sysin));
  %if "&sysscp" EQ "WIN" %then %let _user_=&sysuserid;
  %else %let _user_=%sysget(USER);
  %if "&sysscp" EQ "WIN" %then %let _path_=%qreadpipe(cd);
  %else %let _path_=%sysget(PWD);
  %if %length(&_sysin_) %then %let _prog_=%scan(&_sysin_,-2,.\/);
  %else %do;
    %*- Interactive SAS so prompt for the program name -;
    %window progname color=green columns=56 rows=12
      #2 @2 'Enter the name of your sas program below'
      #3 @2 '(no extension -- case is important)'
      #4 @2 'Program:' @11 _prog_ 32 attr=rev_video 
            display=yes required=yes color=white
      #6 @15 'Press ENTER to continue.';
    %display progname;
    %*- left-align -;
    %let _prog_=%scan(&_prog_,1,.);
  %end;


  %put;
  %put MSG: (jobinfo) The following global macro variables have been set up;
  %put MSG: (jobinfo) and can be used in your code. ;
  %put _sysin_=&_sysin_;
  %put _prog_=&_prog_;
  %put _user_=&_user_;
  %put _path_=&_path_;
  %put;

%mend jobinfo;
