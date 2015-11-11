/*<pre><b>
/ Program   : hexchars.sas
/ Version   : 2.2
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-May-2013
/ Purpose   : To show up ascii non-printables characters in a flat file by
/             displaying their ascii codes as hexadecimal numbers in "< >"
/             symbols.
/ SubMacros : none
/ Notes     : Files path can be quoted or unquoted. If you are using this to
/             look for invisible delimiters in a ".csv" file then these
/             invisible delimiters are almost certainly the horizontal tab
/             character "09"x. To find out then use this macro as in the first
/             example usage notes and you will see "<09>" (or a different value)
/             in the log and once you know you can use "proc import" to read in
/             the file using this syntax:
/                PROC IMPORT DATAFILE="myfile.ext" OUT=mydset DBMS=DLM REPLACE;
/                  DELIMITER="09"x;
/                  GETNAMES=YES;
/                RUN;
/             Alternately, you can use the %dlm2sas macro to read in a file and
/             create a dataset but that macro can only read simple files and
/             will create only character fields of a uniform length.
/ Usage     : %hexchars(infile.ext)
/             %hexchars(infile.ext,"outfile.ext")
/             %hexchars(infile.ext,outfile.ext)
/             %hexchars("infile.ext")
/             %hexchars("infile.ext",print)
/             %hexchars("infile.ext","log")
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ infile            (pos) Input file (quoted or unquoted)
/ file              (pos) Output file (quoted or unquoted) (can be "print" or
/                   "log"). Written to the log by default.
/ termstr=CRLF      Terminating characters for each line. CRLF is for Windows
/                   platforms where the file is a pure ascii file. LF is for
/                   Unix platforms or utf-8 encoded files. You can use the
/                   %termstr macro to help you decide this value.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/ rrb  25Jun11         Renamed from %asciinonp and changed to enable output to
/                      be written to print output or the log and made more
/                      friendly for file quoting  (v2.0)
/ rrb  02Jul11         Added check on input file existence (v2.1)
/ rrb  02May13         termstr=CRLF parameter added (v2.2)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: hexchars v2.2;

%macro hexchars(infile,file,termstr=CRLF);

  %local err;
  %let err=ERR%str(OR);

  %if not %length(&infile) %then %do;
    %put &err: (hexchars) No file path specified;
    %goto exit;
  %end;
  %else %do;
    %let infile=%sysfunc(dequote(&infile));
    %if not %sysfunc(fileexist(&infile)) %then %do;
      %put &err: (hexchars) File "&infile" can not be found;
      %goto exit;
    %end;
  %end;

  %if %length(&file) %then %let file=%sysfunc(dequote(&file));

  data _null_;
    length linein $ 256 newline $ 400 char $ 1;
    retain outpos 0 ;
    infile "&infile" pad termstr=&termstr;
    %if not %length(&file) %then %do;
    %end;
    %else %if "%upcase(&file)" EQ "LOG" %then %do;
    %end;
    %else %if "%upcase(&file)" EQ "PRINT" %then %do;
      file print notitles noprint;
    %end;
    %else %do;
      file "&file" notitles noprint;
    %end;
    input linein $char256.;
    outpos=1;
    if linein ne ' ' then do;
      do i=1 to length(linein);
        char=substr(linein,i,1);
        rank=rank(char);
        if 32 <= rank <= 126 then do;
          substr(newline,outpos,1)=char;
          outpos=outpos+1;
        end;
        else do;
          substr(newline,outpos,4)='<'||put(rank,hex2.)||'>';
          outpos=outpos+4;
        end;
      end;
      put @(length(newline)-length(left(newline))+1) newline;
    end;
    else put;
  run;

  %goto skip;
  %exit: %put &err: (hexchars) Leaving macro due to problem(s) listed;
  %skip:

%mend hexchars;
