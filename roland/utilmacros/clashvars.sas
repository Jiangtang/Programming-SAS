/*<pre><b>
/ Program   : clashvars.sas
/ Version   : 2.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Nov-2011
/ Purpose   : To identify where there is a clash of variable characteristics for
/             datasets in a library and to output diagnostics.
/ SubMacros : none
/ Notes     : Output goes to the log by default but can also be sent to print
/             output and a file. 
/ Usage     : %clashvars(mylib)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libname           (pos) Libref.
/ file              (pos) Output destination (default "log")
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  31Jul07         Header tidy
/ rrb  04May11         Code tidy
/ rrb  30Jun11         Route output to the log by default but allow to route to
/                      print output as well as a flat file (v2.0)
/ rrb  02Nov11         Suppress NOTEs in the log (v2.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: clashvars v2.1;

%macro clashvars(libname,file);

  %local savopts;

  %let savopts=%sysfunc(getoption(notes));
  options nonotes;

  %if not %length(&libname) %then %let libname=%sysfunc(getoption(user));
  %if not %length(&libname) %then %let libname=work;

  proc sql noprint;
    create table _clash as 
    select * from dictionary.columns
    where libname="%upcase(&libname)" and memtype='DATA'
    order by name, memname, type, length, format, label;
  quit;

  proc sort nodupkey data=_clash(keep=name type length format label)
                      out=_clashbad;
    by name type length format label;
  run;

  data _clashbad;
    set _clashbad;
    by name;
    if last.name and not first.name then output;
    keep name;
  run;

  data _clash;
    merge _clashbad(in=_bad) _clash;
    by name;
   if _bad;
  run;

  %put;
  data _null_;
    %if not %length(&file) %then %do;
    %end;
    %else %if "%upcase(%sysfunc(dequote(&file)))" EQ "LOG" %then %do;
    %end;
    %else %if "%upcase(%sysfunc(dequote(&file)))" EQ "PRINT" %then %do;
      file print notitles noprint;
    %end;
    %else %do;
      file "%sysfunc(dequote(&file))" notitles noprint;
    %end;
    set _clash;
    put @1 name @20 memname @35 type @40 length @45 format @60 label;
  run;
  %put;

  proc datasets nolist;
    delete _clash _clashbad;
  run;
  quit;

  options &savopts;

%mend clashvars;
