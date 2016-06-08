%macro ut_find_long_chars(lib=_default_,out=_default_,select=_default_,
 exclude=_default_,maxlength=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : ut_find_long_chars
TYPE                     : utility
DESCRIPTION              : Lists character variables whose allocated length
                            is greater than MAXLENGTH and reports the actual
                            maximum used length.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\ut_find_long_chars\
                            ut_find_long_chars DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : Windows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical ut_quote_token ut_errmsg
                            ut_titlstrt
INPUT                    : data sets in library specified by the LIB
                            parameter
OUTPUT                   : Optional output data set as specified by the 
                            OUT parameter
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _fl
--------------------------------------------------------------------------------
Parameters:
Name      Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
LIB       required            Libref of input data library
OUT       required _fllengths Output data set name
SELECT    optional            Blank delimited List of data sets in LIB to
                               limit processing to
EXCLUDE   optional            Blank delimited List of data sets in LIB to
                               exclude from processing
MAXLENGTH required 200        The maximum length of a variable that will not
                               be reported as a long variable.  Variables
                               with a length greater than this value will be
                               reported.
VERBOSE   required 1          %ut_logical value specifying whether verbose
                               mode is on or off
DEBUG     required 0          %ut_logical value specifying whether debug
                               mode is on or off
--------------------------------------------------------------------------------
Usage Notes:

--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

  %ut_find_longchars(lib=a)

  This macro call find character variables with an allocated length greater
  than 200 and lists these along with their maximum actual length.


  %ut_find_longchars(lib=a,maxlength=1)

  This macro call find character variables with an allocated length greater
  than 1 and list these along with their maximum actual length.  This will 
  help find character variables whose allocated length is longer than required
  to hold the actual values.
  
--------------------------------------------------------------------------------
        Author &
Ver#   Peer Reviewer   Request #       Broad-Use MODULE History Description
----  ---------------- --------------- -----------------------------------------
1.0   Gregory Steffens BMRMRM16DEC2005A     Original version of the broad-use 
       Vijay Sharma                           module  December 2005
1.1   Gregory Steffens BMRMRM21Feb2007D Migration to SAS version 9
       Michael Fredericksen
2.0   Gregory Steffens                      Added sorts of _fllongchars and
                                             _flmaxlen - this was required
                                             in SDD/unix.
                                            Added labels to output data set
                                             variables and proc print.
 **eoh*************************************************************************/
*==============================================================================;
* Initialization;
*==============================================================================;
%ut_parmdef(lib,_pdmacroname=ut_find_long_chars,_pdrequired=1)
%ut_parmdef(out,_fllengths,_pdmacroname=ut_find_long_chars,_pdrequired=1)
%ut_parmdef(select,_pdmacroname=ut_find_long_chars)
%ut_parmdef(exclude,_pdmacroname=ut_find_long_chars)
%ut_parmdef(maxlength,200,_pdmacroname=ut_find_long_chars,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=ut_find_long_chars,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_find_long_chars,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%if &debug %then %let verbose = 1;
%local selectq excludeq titlstrt numdsns dsn_num var_num;
%ut_quote_token(inmvar=select,outmvar=selectq,debug=&debug)
%let selectq = %upcase(&selectq);
%ut_quote_token(inmvar=exclude,outmvar=excludeq,debug=&debug)
%let excludeq = %upcase(&excludeq);
%ut_titlstrt
title&titlstrt "(ut_find_long_chars) Searching &lib for character variables"
 " with allocated lengths longer than &maxlength";
%if %bquote(%upcase(&lib)) ^= WORK %then %do;
  title%eval(&titlstrt + 1) "(ut_find_long_chars) %sysfunc(pathname(&lib))";
%end;
*==============================================================================;
* Create a contents output data set of input library;
*  subset if specified by the SELECT parameter;
*==============================================================================;
proc contents data = &lib.._all_  out=_flcontents  noprint;
run;
data _flcontents;
  set _flcontents (where = (type = 2
   %if %bquote(&select) ^= %then %do;
     & upcase(memname) in (&selectq)
   %end;
   %if %bquote(&exclude) ^= %then %do;
     & upcase(memname) ^ in (&excludeq)
   %end;
  ));
run;
*==============================================================================;
* Read contents data set and create a macro variable array of each data set;
*  that contains a long character variable and a 2-dimensional array of each;
*  long variable name;
*==============================================================================;
%let numdsns = 0;
data _fllongchars;
  if eof then do;
    if memname_num > 0 then
     call symput('numdsns',trim(left(put(memname_num,6.0))));
  end;
  set _flcontents (where = (length > &maxlength)) end = eof;
  by memname;
  if first.memname then do;
    memname_num + 1;
    call symput('dsn' || trim(left(put(memname_num,6.0))),left(memname));
    var_num = 0;
  end;
  var_num + 1;
  call symput('var' || trim(left(put(memname_num,6.0))) || '_' ||
   trim(left(put(var_num,6.0))),trim(left(name)));
  if last.memname then call symput('numvars' ||
   trim(left(put(memname_num,6.0))),trim(left(put(var_num,6.0))));
run;
proc sort data = _fllongchars;  /* this was required in SDD */
  by memname name;
run;
%if &debug %then %do;
  *============================================================================;
  * Print a list of the variables with long allocated lengths;
  *============================================================================;
  proc print data = _fllongchars  width=minimum;
    var memname name length;
  run;
%end;
*------------------------------------------------------------------------------;
* Create data set from dictionary table to get data sets with no variables;
*------------------------------------------------------------------------------;
proc sql;
  create table _flmems as select memname from dictionary.tables
   where upcase(libname) = "%upcase(&lib)"
   %if %bquote(&selectq) ^= %then %do;
     & upcase(memname) in (&selectq)
   %end;
   %if %bquote(&excludeq) ^= %then %do;
     & upcase(memname) ^ in (&excludeq)
   %end;
   ;
quit;
*==============================================================================;
* Read each data set that contains a long variable allocation to determine;
*  the actual lengths of each long character variable;
*==============================================================================;
%if &numdsns > 0 %then %do;
  %do dsn_num = 1 %to &numdsns;
    *--------------------------------------------------------------------------;
    %bquote(* &dsn_num of &numdsns Processing data set &&dsn&dsn_num;)
    *--------------------------------------------------------------------------;
    data _flmaxlen_dsn (rename = (_flmemname=memname _flname=name
                        _flmaxlen_actual=maxlen_actual));
      set &lib..&&dsn&dsn_num end=eof;
      length _flmemname _flname $ 32;
      _flmemname = "&&dsn&dsn_num";
      %do var_num = 1 %to &&numvars&dsn_num;
        if length(&&var&dsn_num._&var_num) > _flmaxlen&var_num then
         _flmaxlen&var_num = length(&&var&dsn_num._&var_num);
      %end;
      if eof then do;
        %do var_num = 1 %to &&numvars&dsn_num;
          _flname = "&&var&dsn_num._&var_num";
          _flmaxlen_actual = _flmaxlen&var_num;
          output;
        %end;
      end;
      keep _flmemname _flname _flmaxlen_actual;
      retain
       %do var_num = 1 %to &&numvars&dsn_num;
         _flmaxlen&var_num
       %end;
      ;
    run;
    proc append base=_flmaxlen  data=_flmaxlen_dsn  force;
    run;
  %end;
  data _fllongchars;
    merge _fllongchars (in=fromlong)  _flmems;
    by memname;
    if ^ fromlong & name = ' ' then name = 'no long chars found';
  run;
  proc sort data = _flmaxlen;  /* this was required in SDD */
    by memname name;
  run;
  data &out (label="Character variables in &lib longer than &maxlength");
    merge _fllongchars (keep=memname name length)
          _flmaxlen (keep=memname name maxlen_actual);
    by memname name;
    label length='Allocated Length' maxlen_actual='Maximum Length of Values';
  run;
  %if &verbose %then %do;
    proc print  data = &out (where=(name ^=: 'no long chars')) width=minimum
     n noobs label;
    run;
  %end;
%end;
%else %do;
  data &out (label="Character variables in &lib longer than &maxlength");
    set _flmems;
    name = 'no long chars found';
    length = .;
    maxlen_actual = .;
  run;
  %ut_errmsg(msg="No data has an allocated length greater than &maxlength",
   macroname=ut_find_long_chars)
%end;
*==============================================================================;
* Clean-up at end of ut_find_long_chars macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _fl:;
  run; quit;
%end;
title&titlstrt;
%mend;
