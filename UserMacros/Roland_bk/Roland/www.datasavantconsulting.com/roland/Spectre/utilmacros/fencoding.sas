/*<pre><b>
/ Program   : fencoding.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Jun-2014
/ Purpose   : To determine the encoding of a text file from the byte order mark
/ SubMacros : none
/ Notes     : This macro checks the first few bytes of a text file and best
/             guesses the file encoding from this and displays it in the log
/             along with the start of the file as text. These first few bytes
/             will contain a "byte order mark" unless the text file is plain
/             ASCII (ANSI). These byte order marks can confuse some software
/             such as html browsers and can make them interpret text files as
/             Windows Media files.
/ Usage     : %fencoding(full-file-path);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ filepath          (pos) File path (quoted or unquoted)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  17Jun14         New (v1.0)
/ rrb  20Jun14         Header update (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: fencoding v1.0;


%macro fencoding(filepath);

  %local savopts;
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %let filepath=%sysfunc(dequote(&filepath));

  data _null_;
    length filestart $ 16;
    rc=filename('fref1',"&filepath");
    fid1=fopen('fref1','I',32767,'B');
    if fid1<=0 then put "ERR" "OR: (fencoding) File &filepath could not be opened";
    else do;
      put;
      eof1=fread(fid1);
      get1=fget(fid1,filestart,16);
      if 31<rank(subpad(filestart,1,1))<127
       and 31<rank(subpad(filestart,2,1))<127
       then put "Plain ascii (ANSI)";
      else if subpad(filestart,1,3)='EFBBBF'X then put "UTF-8";
      else if subpad(filestart,1,2)='FEFF'X then put "UTF-16 (BE)";
      else if subpad(filestart,1,2)='FFFE'X then put "UTF-16 (LE)";
      else if subpad(filestart,1,4)='0000FEFF'X then put "UTF-32 (BE)";
      else if subpad(filestart,1,4)='0000FFFE'X then put "UTF-32 (LE)";
      else if subpad(filestart,1,3)='2B2F76'X then put "UTF-7";
      else if subpad(filestart,1,3)='F7644C'X then put "UTF-1";
      else if subpad(filestart,1,4)='DD736673'X then put "UTF-EBCDIC";
      else if subpad(filestart,1,3)='0EFEFF'X then put "SCSU";
      else if subpad(filestart,1,3)='FBEE28'X then put "BOCU-1";
      else if subpad(filestart,1,4)='84319533'X then put "GB-18030";
      else put "Binary (maybe)";
      put filestart=;
      put;
      rc=fclose(fid1);
    end;
    rc=filename('fref1',' ');
  run;

  options &savopts;

%mend fencoding;
