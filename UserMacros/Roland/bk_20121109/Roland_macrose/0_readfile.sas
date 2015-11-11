/*<pre><b>
/ Program   : readfile.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to read in a flat file and assign the
/             contents to a macro variable.
/ SubMacros : none
/ Notes     : You could use this to generate information and write it to a file
/             and then read it in to a macro variable for further processing.
/             Lines in the file must not be longer than 200 characters. Line
/             breaks will be lost when the data is read in.
/ Usage     : %let mvar=%readfile(filename);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ file              (pos) Path name of flat file
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: readfile v1.0;

%macro readfile(file);
  %local fname fid str rc err;
  %let err=ERR%str(OR);
  %let file="%sysfunc(compress(&file,%str(%'%")))";
  %if not %sysfunc(fileexist(&file)) %then 
  %put &err: (readfile) File &file does not exist;
  %else %do;
    %let rc=%sysfunc(filename(fname,&file));  
    %if &rc NE 0 %then %do;
  %put &err: (readfile) File &file could not be assigned due to the following:;
  %put %sysfunc(sysmsg());
    %end;
    %else %do;
      %let fid=%sysfunc(fopen(&fname));
      %if &fid EQ 0 %then %do;
  %put &err: (readfile) File &file could not be opened due to the following:;
  %put %sysfunc(sysmsg());
      %end;
      %else %do;
        %do %while(%sysfunc(fread(&fid)) EQ 0);
          %let rc=%sysfunc(fget(&fid,str,200));
&str
        %end;
        %let rc=%sysfunc(fclose(&fid));
        %if &rc NE 0 %then %do;
  %put &err: (readfile) File &file could not be closed due to the following:;
  %put %sysfunc(sysmsg());
        %end;
        %let rc=%sysfunc(filename(fname));
        %if &rc NE 0 %then %do;
  %put &err: (readfile) File &file could not be deassigned due to the following:;
  %put %sysfunc(sysmsg());
        %end;
      %end;
    %end;
  %end;
%mend readfile;
