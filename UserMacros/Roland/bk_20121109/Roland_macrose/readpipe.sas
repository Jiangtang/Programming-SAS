/*<pre><b>
/ Program   : readpipe.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 30-Jul-2007
/ Purpose   : Function-style macro to read the output of a system command and
/             assign it to a macro variable.
/ SubMacros : none
/ Notes     : none
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
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: readpipe v1.0;

%macro readpipe(command); 
%local fname fid str rc; 
%let rc=%sysfunc(filename(fname,&command,pipe));   
%if &rc NE 0 %then %do; 
  %put ERROR: (readpipe) Pipe file could not be assigned due to the following:; 
  %put %sysfunc(sysmsg()); 
%end; 
%else %do; 
  %let fid=%sysfunc(fopen(&fname,s)); 
  %if &fid EQ 0 %then %do; 
%put ERROR: (readpipe) Pipe file could not be opened due to the following:; 
%put %sysfunc(sysmsg()); 
  %end; 
  %else %do; 
    %do %while(%sysfunc(fread(&fid)) EQ 0); 
      %let rc=%sysfunc(fget(&fid,str,200)); 
&str 
    %end; 
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
