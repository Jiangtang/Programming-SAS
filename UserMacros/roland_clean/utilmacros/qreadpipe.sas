/*<pre><b>
/ Program   : qreadpipe.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 23-Sep-2011
/ Purpose   : Function-style macro to read the output of a system command and
/             return the result trimmed and MACRO QUOTED.
/ SubMacros : %qtrim
/ Notes     : Result will be MACRO QUOTED. Use %unquote to make the string 
/             output usable in ordinary sas code.
/ Usage     : %let mvar=%qreadpipe(echo $USER);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ command           (pos) System command. This should not be enclosed in quotes
/                   but may be enclosed in %str(), %quote() etc..
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  22Jul07         Header tidy
/ rrb  30Jul07         Header tidy
/ rrb  31Oct08         Major redesign for v2.0
/ rrb  12Oct09         Macro renamed from readpipe to qreadpipe (v2.1)
/ rrb  04May11         Code tidy
/ rrb  23Sep11         Header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: qreadpipe v2.1;

%macro qreadpipe(command);
  %local fname fid str rc res err;
  %let err=ERR%str(OR);
  %let rc=%sysfunc(filename(fname,&command,pipe));
  %if &rc NE 0 %then %do;
    %put &err: (qreadpipe) Pipe file could not be assigned due to the following:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let fid=%sysfunc(fopen(&fname,s,80,b));
    %if &fid EQ 0 %then %do;
  %put &err: (qreadpipe) Pipe file could not be opened due to the following:;
  %put %sysfunc(sysmsg());
    %end;
    %else %do;
      %do %while(%sysfunc(fread(&fid)) EQ 0);
        %let rc=%sysfunc(fget(&fid,str,80));
        %let res=&res%superq(str);
      %end;
%qtrim(&res)
      %let rc=%sysfunc(fclose(&fid));
      %if &rc NE 0 %then %do;
  %put &err: (qreadpipe) Pipe file could not be closed due to the following:;
  %put %sysfunc(sysmsg());
      %end;
      %let rc=%sysfunc(filename(fname));
      %if &rc NE 0 %then %do;
  %put &err: (qreadpipe) Pipe file could not be deassigned due to the following:;
  %put %sysfunc(sysmsg());
      %end;
    %end;
  %end;
%mend qreadpipe;
