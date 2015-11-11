/*<pre><b>
/ Program   : readpipe.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Oct-2008
/ Purpose   : Function-style macro to read the output of a system command and
/             return the result MACRO QUOTED and trimmed.
/ SubMacros : %qtrim %verifyb
/ Notes     : Result will be MACRO QUOTED. Use %unquote to make the string 
/             output usable in ordinary sas code.
/ Usage     : %let mvar=%readpipe(echo $USER);
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
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: readpipe v2.0;

%macro readpipe(command);
%local fname fid str rc res;
%let rc=%sysfunc(filename(fname,&command,pipe));
%if &rc NE 0 %then %do;
  %put ERROR: (readpipe) Pipe file could not be assigned due to the following:;
  %put %sysfunc(sysmsg());
%end;
%else %do;
  %let fid=%sysfunc(fopen(&fname,s,80,b));
  %if &fid EQ 0 %then %do;
%put ERROR: (readpipe) Pipe file could not be opened due to the following:;
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
%put ERROR: (readpipe) Pipe file could not be closed due to the following:;
%put %sysfunc(sysmsg());
    %end;
    %let rc=%sysfunc(filename(fname));
    %if &rc NE 0 %then %do;
%put ERROR: (readpipe) Pipe file could not be deassigned due to the following:;
%put %sysfunc(sysmsg());
    %end;
  %end;
%end;
%mend;
