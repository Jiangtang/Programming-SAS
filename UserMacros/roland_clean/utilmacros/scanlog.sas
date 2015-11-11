/*<pre><b>
/ Program   : scanlog.sas
/ Version   : 3.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 31-Oct-2013
/ Purpose   : To scan sas log file(s) or the log window for important messages
/             optionally using a "rules" file.
/ SubMacros : none
/ Notes     : For the log file you can either supply a full file name in quotes
/             or an unquoted fileref. This can be a mixed list separated by
/             spaces. If not set then the interactive log window is assumed.
/
/             To automatically supply a directory list of full-path quoted file
/             names then use %lsfpq (Unix) or %dirfpq (Windows) in the supplied
/             parameter value (see examples in the usage notes below).
/
/             Because mixed types (filerefs and filenames) are allowed then no
/             checking will be done for the existence of these files so you
/             should ensure that they really exist.
/
/             If you are running interactively and have not set any parameters
/             then the contents of your log window will be copied to a temporary
/             file with libref _savelog where it will be scanned and diagnostics
/             will be written to print output and the _savelog libref will be
/             cleared at the end of the macro call.
/
/             To use this macro efficiently in interactive sas sessions you can
/             assign a call to this macro to a function key by pressing the F9
/             function key and assigning the exact text of the gsubmit statement
/             in the usage notes below to your chosen function key and saving it
/             using the disk icon. Once done then if you press that function key
/             in the future it will scan what is in the log window for important
/             messages and report diagnostics to print output. This print output
/             can be deleted using the results window on the left when no longer
/             required so as not to clutter the output.
/
/             If you are running an interactive session and this macro is not on
/             your autocall path you can activate it by copying and pasting into
/             a pgm window, make any desired edits to the searches if required,
/             and then compile it by running it. There is no need to save it and
/             used this way you can change the search code as needed without
/             affecting other users.
/
/             You can specify a "rules" text file with this macro and you can
/             optionally specify that the contents of this "rules" file be
/             treated as Perl Regular Expressions. Used in this way you can scan
/             any type of text file (not just sas logs). See the description of
/             the rulesfile parameter below for further details.
/
/             FEEL FREE TO HARDCODE CHANGES TO THE SEARCH in the code below.
/             Your site standards to highlight errors, warnings and notes will
/             be different from mine so feel free to change the code to match
/             your site standards. Changing the code is more efficient than
/             using a rules file.
/
/ Usage     : %scanlog("full-file-path-name")
/             %scanlog("full-file-path-name-1" "full-path-name-2")
/             %scanlog(fileref)
/             %scanlog(fileref(a.log) fileref(b.log))
/             %scanlog(fileref "full-path-name")
/             %scanlog(%lsfpq(/usr/mypath/*.log))
/             %scanlog(%dirfpq(C:\temp\*.log))
/             %scanlog(fileref(a.log) "full-path-name" %dirfpq(C:\temp\*.log))
/             %scanlog;         *- this is for interactive sas sessions -;
/             %scanlog(,log);   *- this is for interactive sas sessions -;
/             %scanlog(fileref,"output-file")
/             %scanlog(rulesfile=C:\temp\myrules.txt)
/             %scanlog(rulesfile="C:\temp\myrules.txt")
/             %scanlog(rulesfile="C:\temp\myrules.txt",prx=yes)
/               or in command line box for interactive sessions (note syntax):
/             gsubmit '%scanlog;'
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ logfile           (pos) Log file(s) to scan (separated by spaces). You must
/                   quote file names but must not quote fileref members.
/ dest              (pos) Destination for diagnostics. Normally it is the log
/                   but for interactive sessions where this macro is called
/                   with no parameters set then the destination will be print
/                   output so that it does not mess up the log. But you can set
/                   this to log, print or a file in quotes to override this
/                   behaviour.
/ has0obs=no        By default do not scan for " has 0 observations ". This has
/                   no effect if the rules file is used. It allows you to switch
/                   on or off this search since in some cases it is useful and
/                   for other cases not.
/ rulesfile         Rules file (quoted or unquoted). This overrides the hard-
/                   coded searches if set and is a plain text file of what lines
/                   to accept, followed by a single blank line, followed by
/                   which lines to reject. No other lines such as comment lines
/                   are allowed. Leading and trailing spaces are significant so
/                   take care that there are the right number of spaces at the                
/                   end of each line even though not visible.
/
/                   Note that these lines will be treated as plain text but if
/                   there is a ^ at the beginning of the line then it will be
/                   assumed that you want the following string to be found at
/                   the start of the line only. If you want the lines to be 
/                   treated as Perl Regular Expressions then set prx=yes in
/                   which case the "^" at the beginning of a line also signifies
/                   the following string must be found at the start of a line.
/
/ prx=no            By default, do not treat the contents of the "rules" file as
/                   Perl Regular Expressions.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jul11         More checks added and added automatic handling and easy
/                      calling for interactive sas sessions (v2.0)
/ rrb  27Jul11         Improve display message for interactive sessions (v2.1)
/ rrb  28Jul11         Minor tidy up in header and searches
/ rrb  31Jul11         Rules file, Perl Regular Expression, has0obs= and
/                      multiple log files processing added (v3.0)
/ rrb  19Aug11         header update
/ rrb  31Oct13         "options notes" and "options nonotes" placed before and
/                      after the scanning data step and FATAL search added for
/                      position 1 in the log (v3.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk. 
/=============================================================================*/

%put MACRO CALLED: scanlog v3.1;

%macro scanlog(logfile,
                  dest,
             rulesfile=,
               has0obs=no,
                   prx=no
              );

  %local savopts err errflag logid i fl;

  %let savopts=%sysfunc(getoption(NOTES)) %sysfunc(getoption(MPRINT));
  options NONOTES NOMPRINT;

  %let err=ERR%str(OR);
  %let errflag=0;


        /****************************************
                Set up parameter defaults
         ****************************************/

  %if not %length(&prx) %then %let prx=no;
  %let prx=%upcase(%substr(&prx,1,1));

  %if not %length(&has0obs) %then %let has0obs=no;
  %let has0obs=%upcase(%substr(&has0obs,1,1));

  %if %length(&rulesfile) %then %do;
    %let rulesfile=%sysfunc(dequote(&rulesfile));
    %if not %sysfunc(fileexist(&rulesfile)) %then %do;
      %put &err: (scanlog) Rules file "&rulesfile" can not be found;
      %let errflag=1;
    %end;
  %end;

  %*- Interactive sessions where the macro is called without parameters and   -;
  %*- so we assume the log window needs scanning and we want the diagnostics  -;
  %*- put some place other than the log so best place is print output instead.-;
  %*- So we set the destination to print output and copy the log window       -;
  %*- contents to a temporary file where we can scan it and discard it later. -;
  %if (&sysenv EQ FORE) and (not %length(&logfile)) %then %do;
    %if not %length(&dest) %then %let dest=print;
    filename _savelog temp;
    dm "log; file _savelog;";
    %let logfile=_savelog;
  %end;

  %if not %length(&logfile) %then %do;
    %put &err: (scanlog) No log file specified as first positional parameter;
    %let errflag=1;
  %end;

  %if &errflag %then %goto exit;

  %*- set up the destination if not set -;
  %if not %length(&dest) %then %let dest=log;
  %else %do;
    %if "%upcase(%sysfunc(dequote(&dest)))" EQ "LOG" %then %let dest=log;
    %else %if "%upcase(%sysfunc(dequote(&dest)))" EQ "PRINT" 
      %then %let dest=print notitles;
  %end;


        /****************************************
                 Generate the rules code
         ****************************************/

  %if %length(&rulesfile) %then %do;
    filename _rulcode temp;

    *-- Generate the rules code and write it to a temporary file --;

    %if &prx EQ Y %then %do;
      data _null_;
        retain switch 0;
        file _rulcode;
        infile "&rulesfile" eof=eof;
        input;
        if _n_=1 then do;
          put 'if (';
          put '   prxmatch("/' _infile_ '/",_infile_)';
        end;
        else if _infile_ = " " then do;
          put ' ) and not (';
          switch=1;
        end;
        else do;
          if switch=1 then do;
            switch=0;
            put '   prxmatch("/' _infile_ '/",_infile_)';
          end;
          else put 'or prxmatch("/' _infile_ '/",_infile_)';
        end;
      return;
      eof:
        put ') then put _infile_;';
      return;
      run;
    %end;

    %else %do;
      data _null_;
        length tempstr $ 200;
        retain switch 0;
        file _rulcode;
        infile "&rulesfile" eof=eof;
        input;
        if _n_=1 then do;
          put 'if (';
          if substr(_infile_,1,1)='^' then do;
            tempstr='   index(_infile_,"'||substr(_infile_,2)||'")=1';
            put tempstr;
          end;
          else put '   index(_infile_,"' _infile_ '")';
        end;
        else if _infile_ = " " then do;
          put ' ) and not (';
          switch=1;
        end;
        else do;
          if switch=1 then do;
            switch=0;
            if substr(_infile_,1,1)='^' then do;
              tempstr='   index(_infile_,"'||substr(_infile_,2)||'")=1';
              put tempstr;
            end;
            else put '   index(_infile_,"' _infile_ '")';
          end;
          else do;
            if substr(_infile_,1,1)='^' then do;
              tempstr='or index(_infile_,"'||substr(_infile_,2)||'")=1';
              put tempstr;
            end;
            else put 'or index(_infile_,"' _infile_ '")';
          end;
        end;
      return;
      eof:
        put ') then put _infile_;';
      return;
      run;
    %end;
  %end;


        /****************************************
            Define the macro to scan each file
         ****************************************/

  %macro _scanlog(file);

    %*- set up a suitable message to say what log is being worked on --;
    %let logid=file %sysfunc(dequote(&file));
    %if (&sysenv EQ FORE) and (&file EQ _savelog) %then
      %let logid=Interactive SAS session log;


    *-- search on the terms either using "rule file" generated code or default --;

    *- NOTES has to be forced into effect for the scanning -;
    *- data step otherwise the important messages searched -;
    *- for in the NOTE: lines will not be written.         -;
    OPTIONS NOTES;
    data _null_;
      infile &file eof=eof;
      file &dest ;
      input;
      if _n_=1 then
  put / / "============== Scanning &logid for important messages ==============";
      %if %length(&rulesfile) %then %do;
        %include _rulcode;
      %end;
      %else %do;
        if (
           index(_infile_,"ERROR")=1
        or index(_infile_,"WARNING")=1
        or index(_infile_,"FATAL")=1
        or index(_infile_,"MERGE statement has more ")
        or index(_infile_,"W.D format")
        or index(_infile_," truncated ")
        or index(_infile_," outside the axis range ")
        or index(_infile_,"NOTE: Invalid")=1
        or index(_infile_," uninitialized")
        or index(_infile_,"was not found or could not be loaded")
        or index(_infile_,"Duplicate BY variable(s)")
        or index(_infile_,"Mathematical operations could not")
        or index(_infile_,"Division by zero")
        %if "&has0obs" EQ "Y" %then %do;
          or index(_infile_," has 0 observations ")
        %end;  
           )
        and not (
           index(_infile_,"BY-line has been truncated")
        or index(_infile_,"The length of data column ")
        or index(_infile_,"Errors printed on")
        or index(_infile_,"scheduled to expire on")
        or index(_infile_,"product with which")
        or index(_infile_,"representative to have")
        or index(_infile_,"The Remote engine is active. The updated SHARESESSIONCNTL")
        or index(_infile_,"Computing exact confidence limits for")
        )
        then put _infile_;
      %end;
    return;
    eof:
    put "=================== Finished scanning &logid =======================";
    return;
    run;
    OPTIONS NONOTES;
  %mend _scanlog;


        /****************************************
            Call the scan macro for each file
         ****************************************/

  %let fl=%sysfunc(scanq(&logfile,1,%str( )));
  %_scanlog(&fl);
  %let i=2;
  %let fl=%sysfunc(scanq(&logfile,&i,%str( )));
  %do %while(%length(&fl));
    %_scanlog(&fl);
    %let i=%eval(&i+1);
    %let fl=%sysfunc(scanq(&logfile,&i,%str( )));
  %end;


        /****************************************
                    Tidy up and exit
         ****************************************/

  %*- Free the temporary fileref if we set it above -;
  %if (&sysenv EQ FORE) and (&logfile EQ _savelog) %then %do;
    filename _savelog clear;
  %end;

  *- Free the temporary file containing rules code -;
  %if %length(&rulesfile) %then %do;
    filename _rulcode clear;
  %end;

  *- delete the internally defined macro -;
  proc catalog catalog=work.sasmacr entrytype=macro;
    delete _scanlog;
  quit;


  %goto skip;
  %exit: %put &err: (scanlog) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend scanlog;
