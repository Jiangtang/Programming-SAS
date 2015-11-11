/*<pre><b>
/ Program   : termstr.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-May-2013
/ Purpose   : To guess the line termination character(s) (CRLF or LF) of a text
/             input file and write it to the global macro variable _termstr_ .
/ SubMacros : none
/ Notes     : This macro is not foolproof. It reads in the first 32767 bytes of
/             the file declaring it to be a fixed record format file and
/             searches for the CRLF characters in that first 32767 bytes only.
/             If found it writes the string CRLF to the global macro variable
/             _termstr_ otherwise it has the default value of LF.
/
/             In SAS data steps, the infile statement allow you to specify the
/             termstr= value as LF or CRLF and this macro guesses the value for
/             you so that you can use "termstr=&_termstr_" in your infile
/             statement after testing a file with this macro.
/
/ Usage     : %termstr(myfile);
/             %put _termstr_ = &_termstr_;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ file              (pos) Full file path name (no quotes). If the file name
/                   contains special characters then enclose it in %nrstr( ) .
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02May13         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: termstr v1.0;

%macro termstr(file);

  %local savopts;
  %global _termstr_;
  %let _termstr_=LF;
  %let savopts=%sysfunc(getoption(NOTES));

  options nonotes;

  data _null_;
    infile "&file" pad lrecl=32767 recfm=F;
    input;
    *- Look for the carriage-return line-feed double character and if   -;
    *- we find it then assume that CRLF is the line termination string. -;
    if index(_infile_,"0D0A"X) then call symput('_termstr_','CRLF');
    stop;
  run;

  options &savopts;

%mend termstr;
