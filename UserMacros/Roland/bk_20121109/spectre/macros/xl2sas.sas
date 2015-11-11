/*<pre><b>
/ Program      : xl2sas.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 03-Feb-2008
/ Purpose      : Read an html Excel spreadsheet into a sas dataset using DDE
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
/                Note that because of rules for rendering html, double spaces in
/                cell values in the html spreadsheet file will normally be
/                converted to single spaces unless the value is protected by
/                tags or the spaces are non-breaking spaces ("A0"x).
/
/ Usage        : %xl2sas(xlfile=C:\myfiles\myspred.xls,sheetname=Results,
/                        dsout=sasuser.myspred,compress=no,vpref=_col,vlen=50,
/                        startrow=5,startcol=1,endrow=95,endcol=10)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ xlfile            (no quotes) Full path name of spreadsheet file (not quoted
/                   unless there are spaces in the file name in which case
/                   enclose those parts or the whole name in double quotes).
/ sheetname         (no quotes) Name of spreadsheet sheet you want to read in.
/                   This will be visible as the bottom tag name when you open
/                   the spreadsheet in Excel.
/ secswait=2        Number of seconds to wait for Excel to come up
/ dsout             Output dataset name
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
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: xl2sas v1.0;

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
              endcol=
              );

%local error opts maxvarnum;
%let error=0;



      /*----------------------------------*
              Check input parameters
       *----------------------------------*/

%if not %length(&xlfile) %then %do;
  %let error=1;
  %put ERROR: (xl2sas) No Excel spreadsheet file name supplied to xlfile=;
%end;
%else %do;
  %if not %sysfunc(fileexist(&xlfile)) %then %do;
    %let error=1;
    %put ERROR: (xl2sas) xlfile=&xlfile can not be found;
  %end;
%end;


%if not %length(&sheetname) %then %do;
  %let error=1;
  %put ERROR: (xl2sas) No Excel spreadsheet sheet name supplied to sheetname=;
%end;


%if not %length(&secswait) %then %let secswait=2;
%else %do;
  %if %length(%sysfunc(compress(&secswait,1234567890))) %then %do;
    %let error=1;
    %put ERROR: (xl2sas) An integer number of seconds is required. You specified secswait=&secswait;
  %end;
%end;


%if not %length(&dsout) %then %do;
  %let error=1;
  %put ERROR: (xl2sas) No output dataset name supplied to dsout=;
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
    %let error=1;
    %put ERROR: (xl2sas) An integer is required. You specified startrow=&startrow;
  %end;
%end;


%if not %length(&startcol) %then %let startcol=1;
%else %do;
  %if %length(%sysfunc(compress(&startcol,1234567890))) %then %do;
    %let error=1;
    %put ERROR: (xl2sas) An integer is required. You specified startcol=&startcol;
  %end;
%end;


%if not %length(&endrow) %then %do;
  %let error=1;
  %put ERROR: (xl2sas) No integer specified for endrow=;
%end;
%else %do;
  %if %length(%sysfunc(compress(&endrow,1234567890))) %then %do;
    %let error=1;
    %put ERROR: (xl2sas) An integer is required. You specified endrow=&endrow;
  %end;
%end;


%if not %length(&endcol) %then %do;
  %let error=1;
  %put ERROR: (xl2sas) No integer specified for endcol=;
%end;
%else %do;
  %if %length(%sysfunc(compress(&endcol,1234567890))) %then %do;
    %let error=1;
    %put ERROR: (xl2sas) An integer is required. You specified endcol=&endcol;
  %end;
%end;


%if &error %then %goto error;



      /*---------------------------------*
              Store current options
       *---------------------------------*/

%*- store current xwait and xsync settings -;
%let opts=%sysfunc(getoption(xwait,keyword)) %sysfunc(getoption(xsync,keyword)); 



      /*---------------------------------*
              Read the spreadsheet
       *---------------------------------*/

%*- calculate highest numbered sas variable -;
%let maxvarnum=%eval(&endcol-&startcol+1);


*- set required options for dde to work correctly -;
options noxwait noxsync;


*- start up Excel by opening the spreadsheet -;
X &xlfile;


*- wait for Excel to finish starting up -;
data _null_;
  x=sleep(&secswait);
run;


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
data &dsout;
  length &vpref.1-&vpref.&maxvarnum $ &vlen;
  infile _xlin dlm='09'x notab dsd pad missover;
  input &vpref.1-&vpref.&maxvarnum;
run;


*- deassign filerefs -;
filename _xlin clear;
filename _xlcmd clear;



      /*---------------------------------*
                 Restore options
       *---------------------------------*/

*- restore previous xwait and xsync settings -;
options &opts;



      /*---------------------------------*
                Edit the dataset
       *---------------------------------*/

*- edit the fields and drop rows depending on options set -;
%if "&compress" EQ "Y" or "&compbl" EQ "Y" or "&left" EQ "Y"
 or "&dropblanklines" EQ "Y" %then %do;
  data &dsout;
    retain accum "  ";
    set &dsout;
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
          *- compress for multiple blanks spaces -;
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
                       Exit
       *---------------------------------*/

%goto skip;
%error: %put ERROR: (xl2sas) Leaving macro due to error(s) listed;
%skip:

%mend;
