/*<pre><b>
/ Program   : scanfile.sas
/ Version   : 3.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 19-Sep-2011
/ Purpose   : Counts the number of lines of text in a file that contain the
/             string or the regular expression you specify within the line limit
/             you choose and optionally writes the line or blocks of lines to
/             the log.
/ SubMacros : none
/ Notes     : This macro is useful for scanning LST files to ensure they contain
/             strings such as population set identifiers and subgroup
/             identifiers. The search can be case sensitive or not as you wish.
/             If you set a low line limit then you could aim to just search the
/             titles on the first page of .LST output.
/
/             Setting prx=yes allows you to use the more powerful Perl Regular
/             Expressions to search on in which case you can use the "or" (¦)
/             symbol to search on multiple terms.
/
/             The result of the number of lines matching the pattern you specify
/             will be written to the global macro variable _lines_ .
/
/             If you specify a file that does not exist then no error message
/             will be put out by this macro. Instead, _lines_ will be set to
/             DNE and it is up to the user to take action based on that.
/
/             If an error message is issued then _lines_ will be  null (i.e. it
/             will be blank).
/
/             If the file exists but is empty then _lines_ will be set to
/             EMPTY .
/
/             You can write blocks of lines to the log using the printmore=
/             parameter to state a specific number of lines to print after the
/             matching line or using the untilstr= parameter to signal a line
/             match to stop writing more lines.
/
/ Usage     : %scanfile(C:\temp\myfile.lst,Treated,3,casesens=no)
/
/             *-- Complex example of scanning all the sas programs   --;
/             *-- in a library and printing the "proc format" steps. --;
/             %doallitem(%qreadpipe(dir /B C:\Mylib\*.sas),
/             '%scanfile(C:\Mylib\&item,proc format,
/             untilstr=run,notstr=cntlin,casesens=no)');
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/      (note that enclosing quotes will be ignored for "file" and "str")
/ file              (pos) Full file path of file you wish to search
/ str               (pos) String or regular expression you wish to search on
/ limit             (pos) Number of lines limit to search
/ casesens=yes      By default, search is case sensitive
/ prx=no            By default, the string is not a perl regular expression
/ print=no          By default, do not print the matching lines
/ printmore=0       By default, do not print this extra number of lines after
/                   finding a match.
/ untilstr          String or regular expression to signal the last of the extra
/                   lines to print.
/ notstr            String or regular expression to exclude a match on str
/ _n_=no            By default, do not display the line numbers
/ silent=no         By default, put out a message to the log for all the files
/                   being scanned whether the string was found or not.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  08Sep11         new (v1.0)
/ rrb  12Sep11         existerr= parameter added (v1.1)
/ rrb  13Sep11         print=, printmore=, notstr= and untilstr= parameters
/                      added (v2.0)
/ rrb  15Sep11         _n_= and silent= parameters added (v2.1)
/ rrb  17Sep11         existerr= processing removed so that this macro will not
/                      issue an error message if a file does not exist but will
/                      instead set _lines_ to DNE (v3.0)
/ rrb  19Sep11         _lines_ now set to EMPTY for an empty file so that it
/                      works the same way as the %gettitles macro (v3.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: scanfile v3.1;

%macro scanfile(file,str,limit,
               untilstr=,
                 notstr=,
                  print=no,
              printmore=0,
                    prx=no,
               casesens=yes,
                    _n_=no,
                 silent=no);

  %local err errflag savopts;
  %let savopts=%sysfunc(getoption(notes));

  options nonotes;

  %let err=ERR%str(OR);
  %let errflag=0;

  %global _lines_;
  %let _lines_=;


  %if not %length(&silent) %then %let silent=no;
  %let silent=%upcase(%substr(&silent,1,1));

  %if not %length(&printmore) %then %let printmore=0;

  %if %length(&untilstr) %then %let printmore=99;

  %if &printmore GT 0 %then %let print=yes;

  %if not %length(&_n_) %then %let _n_=no;
  %let _n_=%upcase(%substr(&_n_,1,1));
  %if &_n_ EQ Y %then %let _n_=_n_=;
  %else %let _n_=;

  %if not %length(&print) %then %let print=no;
  %let print=%upcase(%substr(&print,1,1));


  %if not %length(&file) %then %do;
    %let errflag=1;
    %put &err: (scanfile) No file specified to the first positional parameter;
  %end;
  %else %do;
    %let file=%sysfunc(dequote(&file));
    %if not %sysfunc(fileexist(&file)) %then %do;
      %let _lines_=DNE;
      %goto skip;
    %end;
  %end;

  %if not %length(&str) %then %do;
    %let errflag=1;
    %put &err: (scanfile) No search string specified to the second positional parameter;
  %end;

  %if %length(&limit) %then %do;
    %if %length(%sysfunc(compress(&limit,0123456789))) %then %do;
      %let errflag=1;
      %put &err: (scanfile) Third positional parameter must be a positive integer limit=&limit;
    %end;
  %end;

  %if &errflag %then %goto exit;


  %if not %length(&casesens) %then %let casesens=yes;
  %let casesens=%upcase(%substr(&casesens,1,1));

  %if not %length(&prx) %then %let prx=no;
  %let prx=%upcase(%substr(&prx,1,1));

  %if &prx EQ Y %then %do;
    %if &casesens EQ Y %then %let casesens=;
    %else %let casesens=i;
  %end;

  %let _lines_=0;

  data _null_;
    retain printmore . gotit 0;
    infile "&file" eof=eof;
    input;
    %if &print EQ Y and &silent NE Y %then %do;
      if _n_=1 then put / ">>>>>>>>>>>>>>>>>>> scanning file &file";
    %end;
    %if %length(&limit) %then %do;
      if _n_>&limit then goto eof;
    %end;
    %if &prx EQ Y %then %do;
      if prxmatch("/%sysfunc(dequote(&str))/&casesens",_infile_) 
      %if %length(&notstr) %then %do;
        and not prxmatch("/%sysfunc(dequote(&notstr))/&casesens",_infile_) 
      %end;
      then do;
        numlines+1;
        printmore=&printmore;
        %if &print EQ Y %then %do;
          %if &silent EQ Y %then %do;
            if gotit eq 0 then put / ">>>>>>>>>>>>>>>>>>> scanning file &file";
          %end;
          put &_n_ _infile_;
        %end;
        gotit=1;
      end;
      %if %length(&untilstr) %then %do;
        else if printmore>0 and
        prxmatch("/%sysfunc(dequote(&untilstr))/&casesens",_infile_) then do;
          printmore=0;
          put &_n_ _infile_;
        end;
      %end;
      else do;
        if printmore>0 then do;
          put &_n_ _infile_;
          printmore=printmore-1;
        end;
      end;
    %end;
    %else %do;
      %if &casesens EQ N %then %do;
        if index(upcase(_infile_),%upcase("%sysfunc(dequote(&str))"))
        %if %length(&notstr) %then %do;
          and not index(upcase(_infile_),%upcase("%sysfunc(dequote(&notstr))"))
        %end;
        then do;
          numlines+1;
          printmore=&printmore;
          %if &print EQ Y %then %do;
            %if &silent EQ Y %then %do;
              if gotit eq 0 then put / ">>>>>>>>>>>>>>>>>>> scanning file &file";
            %end;
            put &_n_ _infile_;
          %end;
          gotit=1;
        end;
        %if %length(&untilstr) %then %do;
          else if printmore>0 and 
          index(upcase(_infile_),%upcase("%sysfunc(dequote(&untilstr))")) then do;
            printmore=0;
            put &_n_ _infile_;
          end;
        %end;
        else do;
          if printmore>0 then do;
            put &_n_ _infile_;
            printmore=printmore-1;
          end;
        end;
      %end;
      %else %do;
        if index(_infile_,"%sysfunc(dequote(&str))")
        %if %length(&notstr) %then %do;
          and not index(_infile_,"%sysfunc(dequote(&notstr))")
        %end;
        then do;
          numlines+1;
          printmore=&printmore;
          %if &print EQ Y %then %do;
            %if &silent EQ Y %then %do;
              if gotit eq 0 then put / ">>>>>>>>>>>>>>>>>>> scanning file &file";
            %end;
            put &_n_ _infile_;
          %end;
          gotit=1;
        end;
        %if %length(&untilstr) %then %do;
          else if printmore>0 and
          index(_infile_,"%sysfunc(dequote(&untilstr))") then do;
            printmore=0;
            put &_n_ _infile_;
          end;
        %end;
        else do;
          if printmore>0 then do;
            put &_n_ _infile_;
            printmore=printmore-1;
          end;
        end;
      %end;
    %end;
  return;
  eof:
    if _n_=1 and _infile_=" " then call symput('_lines_',"EMPTY");
    else call symput('_lines_',compress(put(numlines,13.)));
    stop;
  return;
  run;

  %goto skip;
  %exit: %put &err: (scanfile) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend scanfile;
