/*<pre><b>
/ Program      : xl2sas.sas
/ Version      : 2.3
/ Author       : Roland Rashleigh-Berry
/ Date         : 14-Sep-2014
/ Purpose      : Read an Excel spreadsheet into a sas dataset using DDE
/ SubMacros    : none
/ Notes        : This is meant to be run interactively. The start and end rows
/                and columns you specify are those required to read the grid of
/                spreadsheet cells you are interested in. For columns, A=1, B=2,
/                etc.. Numeric integer values must be given for these. You must
/                have Excel for this to work. This was especially written for
/                Excel spreadsheets that are really html files such as those
/                written using "ods html file=xxx.xls;" as Excel can correctly
/                open these html files and treat them as normal spreadsheets and 
/                communicate the cell values through DDE.
/
/                This macro is also useful for XML imported into Excel and
/                difficult spreadsheet page contents where you have blocks of
/                information separated by space lines that SAS/Connect is
/                unable to interpret. If the start row and row length of these
/                blocks is variable then you can use this macro to read only
/                column 1 using dropblanklines=no and then the resulting dataset
/                will reveal the start and end rows of the blocks by the
/                observation number and then subsequent calls of this macro can
/                be used to read the blocks at the correct start and end rows.               
/
/                Note that because of rules for rendering html, double spaces in
/                cell values in the html spreadsheet file will, by default, be
/                compressed to single spaces unless the value is protected by
/                tags or the spaces are non-breaking spaces ("A0"x) or
/                compression disabled using compbl=no.
/
/ Usage        : %xl2sas(xlfile=C:\myfiles\My Spread Sheet.xls,sheetname=Sheet1,
/                        dsout=sasuser.myspread,compress=no,vpref=_col,vlen=50,
/                        startrow=5,startcol=1,endrow=95,endcol=10)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ xlfile            (no quotes) Full path name of spreadsheet file (will accept
/                   file name with spaces).
/ sheetname         (no quotes) Name of spreadsheet sheet you want to read in.
/                   This will be visible as the bottom tag name when you open
/                   the spreadsheet in Excel (or you can use %xlsheets to write
/                   this list of sheet names to a global macro variable but
/                   you must remove the quotes added by the %xlsheets macro for
/                   sheet names containing spaces (use %dequote)).
/ secswait=2        Number of seconds to wait for the spreadsheet to open
/ dsout             Output dataset name (will default to the internal work
/                   dataset _xl2sas if you do not specify a value but you must
/                   not specify _xl2sas to this parameter as a dataset name)
/ compress=no       (no quotes) Set to "yes" to compress for all spaces. This
/                   will include the non-breaking space character "A0"x .
/                   Note this this action, if set to "yes", will effectively
/                   override the actions of compbl= and left= .
/ compbl=yes        (no quotes) By default, compress multiple spaces into single
/                   spaces. This will include the non-breaking space character
/                   "A0"x . Even if you set this to "no" then Excel itself will
/                   compress multiple spaces into single spaces unless the tags
/                   in the html file protect the values or the spaces are non-
/                   breaking spaces ("A0"x).
/ left=yes          (no quotes) By default, left-align fields by removing
/                   leading spaces. Leading spaces include the non-breaking
/                   space character "A0"x . Even if you set this to "no" then
/                   Excel itself will left-align text by dropping leading
/                   spaces unless the tags in the html file protect the values
/                   or the spaces are non-breaking spaces ("A0"x).
/ dropblanklines=yes (no quotes) By default, drop lines where all the values in
/                   the column range you specify are blank.
/ vpref=C           Prefix for the numbered variables created in the sas dataset
/ vlen=80           Length of the sas dataset variables (they are all character)
/ startrow=1        Start row to read cells from
/ startcol=1        Start column to read cells from
/ endrow            End row to read cells from
/ endcol            End column to read cells from
/ quit=yes          By default, close the spreadsheet file after reading the
/                   spreadsheet sheet.
/ closesheet=yes    By default, close the sheet after reading it
/ getnames=yes      By default, use what is in the first row read in for the
/                   variable names and their labels.
/ xlisopen=no       Set to yes if the Excel file is already open in Excel
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  31Aug10         Add quit= parameter and File.Close() and QUIT (v1.1)
/ rrb  16Dec10         %sysexec used in place of X command so you can use file
/                      names with spaces in them without any problem (v1.2)
/ rrb  21Dec10         Added getnames=yes so the variable names and their labels
/                      will be taken from the first row read and added
/                      closesheet=yes so the converse will allow leaving the
/                      sheet open after reading it (v2.0)
/ rrb  01Jan11         xlisopen= parameter added (v2.1)
/ rrb  04May11         Code tidy
/ rrb  26Jun11         Remove xlfile quotes if supplied (v2.2)
/ rrb  14Sep14         Use of "keyword" dropped for boolean options (v2.3)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: xl2sas v2.3;

%macro xl2sas(xlfile=,
           sheetname=,
            secswait=2,
               dsout=,
            compress=no,
              compbl=yes,
                left=yes,
      dropblanklines=yes,
               vpref=C,
                vlen=80,
            startrow=1,
            startcol=1,
              endrow=,
              endcol=,
            getnames=yes,
                quit=yes,
          closesheet=yes,
            xlisopen=no
              );

  %local errflag err savopts maxvarnum;
  %let err=ERR%str(OR);
  %let errflag=0;
  %if %length(&xlfile) %then %let xlfile=%sysfunc(dequote(&xlfile));



      /*----------------------------------*
              Check input parameters
       *----------------------------------*/

  %if not %length(&xlisopen) %then %let xlisopen=no;
  %let xlisopen=%upcase(%substr(&xlisopen,1,1));

  %if not %length(&getnames) %then %let getnames=yes;
  %let getnames=%upcase(%substr(&getnames,1,1));

  %if not %length(&quit) %then %let quit=yes;
  %let quit=%upcase(%substr(&quit,1,1));

  %if not %length(&closesheet) %then %let closesheet=yes;
  %let closesheet=%upcase(%substr(&closesheet,1,1));

  %if &xlisopen NE Y %then %do;
    %if not %length(&xlfile) %then %do;
      %let errflag=1;
      %put &err: (xl2sas) No Excel spreadsheet file name supplied to xlfile=;
    %end;
    %else %do;
      %if not %sysfunc(fileexist(&xlfile)) %then %do;
        %let errflag=1;
        %put &err: (xl2sas) xlfile=&xlfile can not be found;
      %end;
    %end;
  %end;


  %if not %length(&sheetname) %then %do;
    %let errflag=1;
    %put &err: (xl2sas) No Excel spreadsheet sheet name supplied to sheetname=;
  %end;


  %if not %length(&secswait) %then %let secswait=2;
  %else %do;
    %if %length(%sysfunc(compress(&secswait,1234567890))) %then %do;
      %let errflag=1;
      %put &err: (xl2sas) An integer number of seconds is required. You specified secswait=&secswait;
    %end;
  %end;



  %if not %length(&compress) %then %let compress=no;
  %let compress=%upcase(%substr(&compress,1,1));


  %if not %length(&compbl) %then %let compbl=yes;
  %let compbl=%upcase(%substr(&compbl,1,1));


  %if not %length(&left) %then %let left=yes;
  %let left=%upcase(%substr(&left,1,1));


  %if not %length(&dropblanklines) %then %let dropblanklines=yes;
  %let dropblanklines=%upcase(%substr(&dropblanklines,1,1));


  %if not %length(&vpref) %then %let vpref=C;


  %if not %length(&vlen) %then %let vlen=80;


  %if not %length(&startrow) %then %let startrow=1;
  %else %do;
    %if %length(%sysfunc(compress(&startrow,1234567890))) %then %do;
      %let errflag=1;
      %put &err: (xl2sas) An integer is required. You specified startrow=&startrow;
    %end;
  %end;


  %if not %length(&startcol) %then %let startcol=1;
  %else %do;
    %if %length(%sysfunc(compress(&startcol,1234567890))) %then %do;
      %let errflag=1;
      %put &err: (xl2sas) An integer is required. You specified startcol=&startcol;
    %end;
  %end;


  %if not %length(&endrow) %then %do;
    %let errflag=1;
    %put &err: (xl2sas) No integer specified for endrow=;
  %end;
  %else %do;
    %if %length(%sysfunc(compress(&endrow,1234567890))) %then %do;
      %let errflag=1;
      %put &err: (xl2sas) An integer is required. You specified endrow=&endrow;
    %end;
  %end;


  %if not %length(&endcol) %then %do;
    %let errflag=1;
    %put &err: (xl2sas) No integer specified for endcol=;
  %end;
  %else %do;
    %if %length(%sysfunc(compress(&endcol,1234567890))) %then %do;
      %let errflag=1;
      %put &err: (xl2sas) An integer is required. You specified endcol=&endcol;
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

  %*- calculate highest numbered sas variable -;
  %let maxvarnum=%eval(&endcol-&startcol+1);


  *- set required options for dde to work correctly -;
  options noxwait noxsync;


  %if &xlisopen NE Y %then %do;

    *- start up Excel by opening the spreadsheet -;
    %sysexec "&xlfile";

    %if &secswait GT 0 %then %do;
      *- wait for Excel to finish starting up -;
      data _null_;
        x=sleep(&secswait);
      run;
    %end;

  %end;


  *- assign filerefs -;
  filename _xlin dde "Excel|&sheetname!R&startrow.C&startcol:R&endrow.C&endcol" lrecl=3000;
  filename _xlcmd dde 'Excel|system' lrecl=3000;


  *- Excel command to remove new-line characters -;
  data _null_;
    file _xlcmd;
    put "[error(FALSE)]";
    put "[FORMULA.REPLACE(""%sysfunc(byte(10))"","""",2,1,FALSE,FALSE)]" ;
  run;


  *- read in the spreadsheet page -;
  data _xl2sas;
    length &vpref.1-&vpref.&maxvarnum $ &vlen;
    infile _xlin dlm='09'x notab dsd pad missover;
    input &vpref.1-&vpref.&maxvarnum;
  run;


  *- close the spreadsheet sheet and optionally quit -;
  data _null_;
    file _xlcmd;
    %if &closesheet NE N %then %do;
      put "[File.Close()]";
    %end;
    %if &quit NE N %then %do;
      put '[QUIT]';
    %end;
  run;


  *- deassign filerefs -;
  filename _xlin clear;
  filename _xlcmd clear;



      /*---------------------------------*
                 Restore options
       *---------------------------------*/

  *- restore previous xwait and xsync settings -;
  options &savopts;



      /*---------------------------------*
                Edit the dataset
       *---------------------------------*/

  *- edit the fields and drop rows depending on options set -;
  %if "&compress" EQ "Y" or "&compbl" EQ "Y" or "&left" EQ "Y"
   or "&dropblanklines" EQ "Y" %then %do;
    data _xl2sas;
      retain accum "  ";
      set _xl2sas;
      array &vpref.ra {*} &vpref.1-&vpref.&maxvarnum;
      accum=" ";
      do i=1 to dim(&vpref.ra);
        %if "&compress" EQ "Y" or "&compbl" EQ "Y" or "&left" EQ "Y" %then %do;
          *- translate the non-breaking space into an ordinary space -;
          &vpref.ra(i)=translate(&vpref.ra(i)," ","A0"x);
        %end;
        %if "&compress" EQ "Y" %then %do;
          *- compress for all spaces -;
          &vpref.ra(i)=compress(&vpref.ra(i));
        %end;
        %else %do;
          %if "&compbl" EQ "Y" %then %do;
            *- compress for multiple blank spaces -;
            &vpref.ra(i)=compbl(&vpref.ra(i));
          %end;
          %if "&left" EQ "Y" %then %do;
            *- left-align field -;
            &vpref.ra(i)=left(&vpref.ra(i));
          %end;
        %end;
        accum=trim(left(accum))||trim(left(&vpref.ra(i)));
      end;
      %if "&dropblanklines" EQ "Y" %then %do;
        if accum ne " " then output;
      %end;
      drop i accum;
    run;
  %end;

      /*---------------------------------*
                Getnames processing
       *---------------------------------*/

  %if "&getnames" EQ "Y" %then %do;

    data _null_;
      length oddchars oldvar newvar tochars value $ 32 label $ 200;
      set _xl2sas(obs=1);
      array &vpref.ra {*} &vpref.1-&vpref.&maxvarnum;
      if _n_=1 then call execute('data _xl2sas;set _xl2sas(firstobs=2);rename');
      do i=1 to dim(&vpref.ra);
        oldvar=vname(&vpref.ra(i));
        value=vvalue(&vpref.ra(i));
        if missing(value) then value=oldvar;
        else do;
          link ren;
          call execute(' '||trim(oldvar)||"="||trim(newvar));
        end;
      end;
      call execute(";label");
      do i=1 to dim(&vpref.ra);
        oldvar=vname(&vpref.ra(i));
        label=vvalue(&vpref.ra(i));
        if not missing(label) then
          call execute(' '||trim(oldvar)||'="'||trim(left(label))||'"');
      end;
      call execute(";run;");
    return;
    ren:
      tochars=repeat("_",31);
      oddchars=compress(trim(value),
        "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ");
      newvar=left(translate(trim(value),tochars,oddchars));
    return;
    run;

  %end;



      /*---------------------------------*
                Tidy up and Exit
       *---------------------------------*/

  %if %length(&dsout) %then %do;

    data &dsout;
      set _xl2sas;
    run;

    proc datasets nolist memtype=data;
      delete _xl2sas;
      run;
    quit;

  %end;


  %goto skip;
  %exit: %put &err: (xl2sas) Leaving macro due to problem(s) listed;
  %skip:

%mend xl2sas;
