/*<pre><b>
/ Program      : xlsheets.sas
/ Version      : 2.2
/ Author       : Roland Rashleigh-Berry
/ Date         : 14-Sep-2014
/ Purpose      : Get a list of sheet names (topics) from an Excel spreadsheet
/                using DDE and write them to a global macro variable.
/ SubMacros    : none
/ Notes        : Sheet names containing spaces will be enclosed in double quotes
/                in the global macro variable. You must remove these double
/                quotes when using the %xl2sas macro as sheet names in quotes
/                are not accepted. Use the %dequote macro to do this. You can
/                extract each name in turn, whether quoted or not, using:
/                     %dequote(%scanq(&_xlsheets_,&i,%str( )))
/                and to count the number of sheet names to loop through use
/                %wordsq. Sheet names are returned in alphabetical order, rather
/                than sheet position order, due to the way "topics" are handled
/                by Excel.
/ Usage        : %xlsheets(C:\Mydata\Spread Sheet Name.xls);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ xlfile            (pos) (no quotes) Full path name of spreadsheet file (allows
/                   spaces in the file name).
/ secswait=2        Number of seconds to wait for the spreadsheet to open
/ mvar=_xlsheets_   Name of global macro variable to receive sheet names
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  16Dec10         Use %sysexec instead of X command to open file to allow
/                      for spaces in the file name (v1.1)
/ rrb  20Dec10         Write sheet names to a global macro variable instead of
/                      to a dataset (v2.0)
/ rrb  08May11         Code tidy
/ rrb  26Jun11         Remove xlfile quotes if supplied (v2.1)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v2.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: xlsheets v2.2;

%macro xlsheets(xlfile,
              secswait=2,
                  mvar=_xlsheets_
                );

  %local errflag err savopts;
  %let err=ERR%str(OR);
  %let errflag=0;
  %if %length(&xlfile) %then %let xlfile=%sysfunc(dequote(&xlfile));

  %if not %length(&mvar) %then %let mvar=_xlsheets_;

  %global &mvar;
  %let &mvar=;


      /*----------------------------------*
              Check input parameters
       *----------------------------------*/


  %if not %length(&xlfile) %then %do;
    %let errflag=1;
    %put &err: (xlsheets) No Excel spreadsheet file name supplied to xlfile=;
  %end;
  %else %do;
    %if not %sysfunc(fileexist(&xlfile)) %then %do;
      %let errflag=1;
      %put &err: (xlsheets) xlfile=&xlfile can not be found;
    %end;
  %end;



  %if not %length(&secswait) %then %let secswait=2;
  %else %do;
    %if %length(%sysfunc(compress(&secswait,1234567890))) %then %do;
      %let errflag=1;
      %put &err: (xlsheets) An integer number of seconds is required. You specified secswait=&secswait;
    %end;
  %end;

  %if &errflag %then %goto exit;



      /*---------------------------------*
              Store current options
       *---------------------------------*/

  %*- store current xwait and xsync settings -;
  %let savopts=%sysfunc(getoption(xwait)) %sysfunc(getoption(xsync)); 



      /*---------------------------------*
              Read the spreadsheet
       *---------------------------------*/


  *- set required options for dde to work correctly -;
  options noxwait noxsync;


  *- start up Excel by opening the spreadsheet -;
  %sysexec "&xlfile";


  *- wait for Excel to finish starting up -;
  data _null_;
    x=sleep(&secswait);
  run;


  *- assign filerefs -;
  filename _xlcmd dde 'Excel|system' lrecl=3000;
  filename _xltop dde 'Excel|system!topics' lrecl=3000;


  *- Excel command to remove new-line characters -;
  data _null_;
    file _xlcmd;
    put "[error(FALSE)]";
    put "[FORMULA.REPLACE(""%sysfunc(byte(10))"","""",2,1,FALSE,FALSE)]" ;
  run;


  *- read in the topics -;
  data _null_;
    length topic scan2 $ 1000 storetop $ 30000;
    retain storetop " ";
    infile _xltop dlm='09'x dsd pad notab;
    input topic $ @@;
    if _n_>1 then do;
      if index(topic,'[')=1 then do;
        scan2=scan(topic,2,']');
        if length(scan2) > length(compress(scan2,' '))
          then storetop=trim(storetop)||' "'||trim(scan2)||'"';
        else storetop=trim(storetop)||' '||scan2;
        call symput("&mvar",trim(left(storetop)));
      end;
    end;
  run;


  *- close the spreadsheet and quit -;
  data _null_;
    file _xlcmd;
    put "[File.Close()]";
    put '[QUIT]';
  run;


  *- deassign filerefs -;
  filename _xltop clear;
  filename _xlcmd clear;


      /*---------------------------------*
                 Restore options
       *---------------------------------*/

  *- restore previous xwait and xsync settings -;
  options &savopts;




      /*---------------------------------*
                       Exit
       *---------------------------------*/

  %goto skip;
  %exit: %put &err: (xlsheets) Leaving macro due to problem(s) listed;
  %skip:

%mend xlsheets;
