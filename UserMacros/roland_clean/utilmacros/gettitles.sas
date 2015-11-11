/*<pre><b>
/ Program   : gettitles.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Sep-2011
/ Purpose   : To read the title lines of an LST file and write them to a global
/             macro variable _titles_ .
/ SubMacros : none
/ Notes     : This macro reads up to ten lines of an LST file or up to a blank
/             line and writes the result to the global macro variable _titles_ .
/             Multiple title lines will be joined into a single line.
/
/             The purpose of this macro is to allow you to check the titles
/             against those defined in another source to ensure no changes have
/             been made or that any differences are acceptable.
/
/             If the file does not exist then _titles_ will be given the value
/             DNE. If the file is empty then _titles_ will be set to EMPTY. If
/             an error message is issued then _titles_ will be null (i.e. blank)
/             (the %scanfile macro works the same way).
/
/             Since the text written to _titles_ might exceed 262 characters
/             then if you wish to retrieve its contents in a later data step you
/             should use symget("_titles_") rather than resolve "&_titles_" to
/             avoid a syntax error.
/
/             The logic that determines when the titles have stopped will vary
/             with your site standards. The coded solution below is only a
/             suggested solution. You are free to change the code to suit your
/             site standards.
/
/ Usage     : %gettitles(C:\temp\myfile.lst)
/
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ file              (pos) Full file path of file you wish to search (quoted or
/                   unquoted).
/ compbl=yes        By default, compress the titles for multiple blanks
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  19Sep11         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: gettitles v1.0;

%macro gettitles(file,compbl=yes);

  %local err errflag savopts;
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %let err=ERR%str(OR);
  %let errflag=0;

  %global _titles_;
  %let _titles_=;


  %if not %length(&file) %then %do;
    %let errflag=1;
    %put &err: (gettitles) No file specified;
  %end;
  %else %do;
    %let file=%sysfunc(dequote(&file));
    %if not %sysfunc(fileexist(&file)) %then %do;
      %let _titles_=DNE;
      %goto skip;
    %end;
  %end;


  %if &errflag %then %goto exit;


  %if not %length(&compbl) %then %let compbl=yes;
  %let compbl=%upcase(%substr(&compbl,1,1));


  data _null_;
    length keeptitles $ 2000;
    retain keeptitles " " i 0;
    infile "&file" eof=eof;
    input;
    i=i+1;
    *- what logic you put here will depend on your site standards -;
    if i>10 then goto eof;
    else if _infile_ EQ " " then goto eof;
    else if _n_>1 and substr(_infile_,1,1) NE " " then goto eof;
    else do;
      %if &compbl EQ N %then %do;
        if keeptitles EQ " " then keeptitles=trim(left(_infile_));
        else keeptitles = trim(keeptitles)||" "||trim(left(_infile_));
      %end;
      %else %do;
        if keeptitles EQ " " then keeptitles=compbl(trim(left(_infile_)));
        else keeptitles = trim(keeptitles)||" "||compbl(trim(left(_infile_)));
      %end;
    end;
  return;
  eof:
    if _n_=1 and _infile_=" " then call symput('_titles_',"EMPTY");
    else call symput('_titles_',trim(keeptitles));
    stop;
  return;
  run;

  %goto skip;
  %exit: %put &err: (gettitles) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend gettitles;
