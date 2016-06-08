/*<pre><b>
/ Program   : fmts2fda.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To create sas code to generate formats as found in your data
/ SubMacros : %quotelst
/ Notes     : The FDA sometimes requests the user-defined formats you are using
/             in your datasets. You can either send them the full format catalog
/             members or use this utility so that the formats can be generated.
/             This will only give you the codes and their formatted values as it
/             occurs in your data. It will NOT give all codes defined to the
/             formats. If you want all possible codes mapped then send them the
/             format catalogs and do not use this utility.
/
/             Note that this utility is weak on numeric formats. These can be
/             very long lists of values. You should just use this to identify
/             what numeric formats are being used and replace the generated code
/             with the original code for the numeric format.
/
/ Usage     : %fmts2fda(mylib1 mylib2)
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libname           (pos) Libref of the library where your datasets are stored.
/                   More than one can be specified (separated by spaces).
/ file=fdaformats.sas    Name of the flat file that will hold the formats code
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

%put MACRO CALLED: fmts2fda v1.0;

%macro fmts2fda(libname,file=fdaformats.sas);

  %local wrn;
  %let wrn=WAR%str(NING);

  %if NOT %length(&libname) %then %let libname=%sysfunc(getoption(user));
  %if NOT %length(&libname) %then %let libname=work;


  *- find all datasets and variables in the library that have -;
  *- user-defined formats and output to a dataset -;
  proc sql noprint;
    create table _fmts as
    select libname, memname, name, type, format
    from dictionary.columns
    where libname in (%quotelst(%upcase(&libname)))
    and memtype='DATA'
    and compress(format,'F$0123456789.') 
      not in (' ' 'DATE' 'TIME' 'DATETIME' 'CHAR' 'BEST' 'Z');
  quit;


  %*- warn if no user formats and exit -;
  %if NOT %nobs(_fmts) %then %do;
    %put &wrn: (fmts2fda) No user-defined formats are used in library=&libname;
    data _null_;
      file "&file";
      put "No user-defined formats are used in library=&libname";
    run;
    %goto skip;
  %end;


  *- delete base dataset if it already exists -;
  %if %sysfunc(exist(_fmtbase)) %then %do;
    proc datasets nolist;
      delete _fmtbase;
    run;
    quit;
  %end;


  *- for each dataset, sort nodupkey, add the format name and type, -;
  *- assign the variable contents to variable "start" and append on -;
  *- to the base dataset. -;
  data _null_;
    set _fmts;
    call execute('proc sort nodupkey data='||trim(libname)||'.'||trim(memname)||'(keep='||
      trim(name)||') out=_fmtbit;by '||trim(name)||';run;');
    call execute('data _fmtbit;length type $ 4 format start $ 20;retain format "'||
      trim(format)||'" type "'||type||'";set _fmtbit;');
    if type='char' then call execute('start='||trim(name)||';drop '||trim(name)||';run;');
    else call execute('start=trim(left(put('||trim(name)||',best16.)));drop '||trim(name)||';run;');
    call execute('proc append base=_fmtbase data=_fmtbit;run;');
  run;


  *- get rid of duplicates from the base dataset -;
  proc sort nodupkey data=_fmtbase;
    by format type start;
  run;


  *- write the "proc format" code out to the flat file -;
  data _null_;
    length fmt $ 20 label $ 40;
    file "&file" noprint notitles;
    set _fmtbase end=last;
    by format;
    if _n_=1 then put 'proc format;';
    fmt=compress(format,'.');
    if first.format then put @3 'value ' fmt;
    if type='char' then do;
      label=putc(start,format);
      put @5 '"' start +(-1) '"="' label +(-1) '"';
    end;
    else do;
      label=putn(input(start,best16.),format);
      put @5 start +(-1) '="' label +(-1) '"';
    end;
    if last.format then put @3 ';';
    if last then put 'run;';
  run;


  *- tidy up -;
  proc datasets nolist;
    delete _fmts _fmtbase _fmtbit;
  run;
  quit;

  %skip:

%mend fmts2fda;
