/*<pre><b>
/ Program   : clashlibs.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 02-Nov-2011
/ Purpose   : To identify where there is a clash of variable characteristics for
/             the specified dataset(s) in the multiple assigned libraries and to
/             output diagnostics. Case is important for variable names. To make
/             sure all variable names are created in upper case then use the 
/             system option VALIDVARNAME=UPCASE before you create the datasets.
/ SubMacros : none
/ Notes     : Output goes to the log by default but can also be sent to print
/             output or a file. All the librefs assigned in the current session
/             are searched.
/
/             If you are checking datasets across libraries for consistency then
/             it might be a good idea to create a correct version of the dataset
/             in the WORK library to use as a reference for when differences are
/             reported.
/
/ Usage     : %clashlibs(myds)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsets             (pos) (not quoted) Single level space-separated dataset
/                   name(s) for comparison of variable characteristics of
/                   identically named datasets in the assigned multiple
/                   libraries.
/ file              (pos) Output destination (default "log")
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  02Nov11         Suppress NOTEs in the log (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: clashlibs v1.1;

%macro clashlibs(dsets,file);

  %local err i dset dsetlist savopts;

  %let savopts=%sysfunc(getoption(notes));
  options nonotes;

  %let err=ERR%str(OR);

  %if not %length(&dsets) %then %do;
    %put &err: (clashlibs) No dataset list specified;
    %goto exit;
  %end;

  %let dslist=;
  %let i=1;
  %let dset=%scan(&dsets,&i,%str( ));
  %do %while(%length(&dset));
    %let dset="%upcase(%scan(&dset,-1,.))";
    %let dsetlist=&dsetlist &dset;
    %let i=%eval(&i+1);
    %let dset=%scan(&dsets,&i,%str( ));
  %end;

  proc sql noprint;
    create table _clash as 
    select * from dictionary.columns
    where memname IN (&dsetlist) and memtype='DATA'
    order by memname, name, libname, type, length, format, label;
  quit;

  proc sort nodupkey data=_clash(keep=memname name type length format label)
                      out=_clashbad;
    by memname name type length format label;
  run;

  data _clashbad;
    set _clashbad;
    by memname name;
    if last.name and not first.name then output;
    keep memname name;
  run;

  data _clash;
    merge _clashbad(in=_bad) _clash;
    by memname name;
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
    put @1 memname @16 name @35 libname @44 type @49 length @54 format @69 label;
  run;
  %put;

  proc datasets nolist;
    delete _clash _clashbad;
  run;
  quit;

  %goto skip;
  %exit: %put &err: (clashlibs) Leaving macro due to problem(s) listed;
  %skip:

  options &savopts;

%mend clashlibs;
