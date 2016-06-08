%macro mdshortlong(mdlib=_default_,lib=_default_,mode=_default_,
 outprog=_default_,outprogl=_default_,mdprefix=_default_,select=_default_,
 exclude=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdshortlong
TYPE                     : metadata and data transform
DESCRIPTION              : Renames data sets and variables between long and
                            short names defined in metadata.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\mdshortlong\mdshortlong DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : Windows, MVS, SDD
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt mdmake ut_errmsg
INPUT                    : data sets modified in library specified by the LIB
                            parameter
                           metadata as specified by the MDLIB parameter
OUTPUT                   : data sets modified in library specified by the LIB
                            parameter
                           SAS program as specified by the OUTPROG parameter
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _sl
--------------------------------------------------------------------------------
Parameters:
Name     Type     Default  Description and Valid Values
-------- -------- -------- --------------------------------------------------
MDLIB    required          Libref where metadata resides
LIB      optional          Libref of input library.  If specified then the
                            variables in this library will be renamed using
                            PROC DATASETS.  If not specified then SAS code
                            can be written to OUTPROG based solely on 
                            metadata in MDLIB.  If OUTPROG is specified then
                            these PROC DATASETS are not executed - instead
                            a program is written to a file that does the 
                            renames when you run that program.  It is still
                            usefull to specify LIB even when you specify
                            OUTPROG because the macro can verify the
                            existence of variables.
MODE     required l2s      Mode of rename - long name to short name (l2s) or
                            short name to long name (s2l)
OUTPROG  optional          Name of file to write a SAS program to that 
                            does the renaming.  This program can be
                            sent with the data library so that the 
                            receiver of the data can run the program to 
                            rename variables.  This is usefull when 
                            it is required to use a V5 transport file 
                            of data that contains long names.  When OUTPROG
                            is specified then a program is written to that
                            file and the proc datasets are not executed to
                            execute any renames.
OUTPROGL optional data     Libref to define in the OUTPROG program file.
                            If LIB is specified then OUTPROGL is assigned
                            the same value as LIB, even if OUTPROGL was
                            specified differently in the call to mdshortlong.
MDPREFIX optional          Prefix to apply to metadata set names in MDLIB
SELECT   optional          Blank delimited list of data set names defined
                            in the metadata to limit processing to.
EXCLUDE  optional          Blank delimited list of data set names defined
                            in the metadata to exclude from processing
VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                            is on or off
DEBUG    required 0        %ut_logical value specifying whether debug mode
                            is on or off

--------------------------------------------------------------------------------
Usage Notes:

  A version 5 transport file is required for FDA data submissions.  V5
  transport files do not support long names.  The mdshortlong macro can
  rename the variables in LIB to the short names defined in metadata residing
  in MDLIB.  A transport file can then be created containing this data.  The
  mdshortlong macro can then be executed again to create SAS code in OUTPROG
  that renames variables from their short names to their long names.  This 
  program can be sent with the transport file so the FDA can easily rename
  variables from short names to long names so they exactly match the source
  database in LIB.

  Either LIB or OUTPROG or both must be specified when calling mdshortlong.

--------------------------------------------------------------------------------
Assumptions:

  Metadata resides in MDLIB and includes the map between long names and short
  names defined in the COLUMNS data set.  The long variable name is in 
  COLUMN and the corresponding short name is in CSHORT.  The mdshortlong macro
  will rename variables when the COLUMNS metadata set contains a value in 
  CSHORT that is different from the value in COLUMN.  This rename is most often
  done for values of COLUMN that with a length greater than 8, but the rename 
  is done even for values of COLUMN that are less than 8.

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:


  Example I:

  libname ads 'path where data resides';
  libname md  'path where metadata resides' access=readonly;
  %mdshortlong(lib=ads,mdlib=md)

  This will rename long variable names to short variable names of data sets
  that reside in the library ADS according to the mapping of names in metadata
  that reside in the library MD.
  A version 5 SAS transport file can be created from this modified library.
  Do a PROC COPY before calling mdshortlong if you want to keep both the
  long and short named database.

  Example II:

  libname md  'path where metadata resides' access=readonly;
  %mdshortlong(lib=ads,mdlib=md,mode=l2s,outprog=\path\sasprog.sas)

  This will write a SAS program to \path\sasprog.sas that renames variables
  from their short names to their long names.
  This program can be run on the data that is extracted from the transport file
  to convert the short names back to the long names. 

--------------------------------------------------------------------------------
     Author &
Ver#   Peer Reviewer   Request #        Broad-Use MODULE History Description
----  ---------------- ---------------- ----------------------------------------
1.0   Gregory Steffens BMRMRM16DEC2005B Original version of the broad-use 
       Vijay Sharma                      module  December 2005
1.1   Gregory Steffens BMRMRM21FEB2007A SAS version 9 migration
       Michael Fredericksen
2.0   Gregory Steffens                  Support table renames using tshort
 **eoh*************************************************************************/
%*=============================================================================;
%* Process parameters;
%*=============================================================================;
%ut_parmdef(mdlib,_pdmacroname=mdshortlong,_pdrequired=1)
%ut_parmdef(lib,_pdmacroname=mdshortlong,_pdrequired=0)
%ut_parmdef(mode,l2s,l2s s2l L2S S2L,_pdmacroname=mdshortlong,_pdrequired=1)
%ut_parmdef(outprog,_pdmacroname=mdshortlong,_pdrequired=0)
%ut_parmdef(outprogl,data,_pdmacroname=mdshortlong,_pdrequired=0)
%ut_parmdef(mdprefix,_default_,_pdmacroname=mdshortlong,_pdrequired=0)
%ut_parmdef(select,_default_,_pdmacroname=mdshortlong,_pdrequired=0)
%ut_parmdef(exclude,_default_,_pdmacroname=mdshortlong,_pdrequired=0)
%ut_parmdef(verbose,1,_pdmacroname=mdshortlong,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=mdshortlong,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%let mode = %upcase(&mode);
%if %bquote(&lib) = & %bquote(&outprog) = %then %do;
  %ut_errmsg(msg=Either LIB or OUTPROG or both must be specified,
   macroname=mdshortlong,type=note)
  %goto endmac;
%end;
%*=============================================================================;
%* Declare local macro variables and initialize some macro variables;
%*=============================================================================;
%local titlstrt lib_path num_columns num_tables q s p;
%ut_titlstrt
%if %bquote(&lib) ^= %then %do;
  %let lib_path = %sysfunc(pathname(&lib));
  %ut_errmsg(msg=lib_path=&lib_path,macroname=mdshortlong,print=0)
%end;
%if %bquote(&lib) ^= %then %let outprogl = &lib;
%else %if %bquote(&outprogl) = & %bquote(&outprog) ^= %then
 %let outprogl = data;
%*-----------------------------------------------------------------------------;
%* Define macro variables to use in the PUT statement when OUTPROG is specified;
%*-----------------------------------------------------------------------------;
%if %bquote(&outprog) ^= %then %do;
  %let q = %str(%");
  %let s = %str(/);
  %let p = %str(+2);
%end;
*==============================================================================;
* Call MDMAKE to copy the metadata in MD to the work library;
*==============================================================================;
%mdmake(inlib=&mdlib,outlib=work,inprefix=&mdprefix,outprefix=_sl,
 inselect=&select,inexclude=&exclude,mode=replace,contents=0,
 verbose=&verbose,debug=&debug)
proc sort data = _sltables (keep = table tshort tlabel  where = (table ^= ' ' &
 (length(table) > 8 | (tshort ^= ' ' & upcase(tshort) ^= upcase(table)))))
 out = _sltabtrans;
  by table;
run;
proc sort data = _slcolumns (keep = table column cshort clabel
 where = (table ^= ' ' & column ^= ' ' &
 (length(column) > 8 | (cshort ^= ' ' & upcase(cshort) ^= upcase(column)))))
 out = _slcoltrans;
  by table column;
run;
data _sltrans;
  merge _slcoltrans (in=fromcols)  _sltabtrans (in=fromtables);
  by table;
  if fromtables & ^ fromcols then table_only = 1;
  else table_only = 0;
run;
*==============================================================================;
* Create macro variable arrays to map between long and short variable names;
*==============================================================================;
%let num_columns = 0;
data
 _slcoltrans_exist (keep=table column cshort clabel)
 _slneedcshort     (keep=table column cshort clabel)
 _sltabtrans_exist (keep=table tshort tlabel table_only);
  if eof then do;
    if column_num > 0 then
     call symput('num_columns',trim(left(put(column_num,8.0))));
    %if %bquote(&lib) ^= %then %do;
      if _sldsid > 0 then _slcloserc = close(_sldsid);
    %end;
  end;
  set _sltrans end=eof;
  by table column;
  if cshort = ' ' & length(column) > 8 then output _slneedcshort;
  if cshort ^= ' ' | tshort ^= ' ';
  %if %bquote(&lib) ^= %then %do;
    if first.table then do;
      if _sldsid > 0 then _slcloserc = close(_sldsid);
      _sldsid = open("&lib.." || trim(left(table)));
      if _sldsid <= 0 then %ut_errmsg(msg="Table defined in metadata does not "
       "exist in &lib " table=,macroname=mdshortlong,type=warning);
    end;
    if _sldsid > 0;
    if first.table then output _sltabtrans_exist;
    %if &mode = L2S %then %do;
      if column ^= ' ' then do;
        _slvarnum = varnum(_sldsid,column);
    %end;
    %else %if &mode = S2L %then %do;
      if cshort ^= ' ' then do;
        _slvarnum = varnum(_sldsid,cshort);
    %end;
        if _slvarnum <= 0 then %ut_errmsg(msg="Column defined in metadata "
         "does not " "exist in &lib mode=&mode " table= column= cshort=,
         macroname=mdshortlong,type=warning,counter=_sleror_message_counter);
        if _slvarnum > 0;
        output _slcoltrans_exist;
      end;
    retain _sldsid;
    drop _sleror_message_counter _slvarnum _sldsid;
  %end;
  %else %do;
    if cshort ^= ' ' then output _slcoltrans_exist;
    if tshort ^= ' ' & first.table then output _sltabtrans_exist;
  %end;
  if cshort ^= ' ';
  column_num + 1;
  call symput('table'  || trim(left(put(column_num,32.0))),trim(left(table)));
  call symput('column' || trim(left(put(column_num,32.0))),trim(left(column)));
  call symput('cshort' || trim(left(put(column_num,32.0))),trim(left(cshort)));
run;
proc print data = _slneedcshort  width=minimum;
  title&titlstrt
   "(mdshortlong) Long Column Names with no Short Name Defined in Metadata";
run;
title&titlstrt;
*==============================================================================;
* Create macro variable array of each table that contains a long variable name;
*==============================================================================;
%let num_tables = 0;
data _null_;
  if eof & table_num > 0 then
   call symput('num_tables',trim(left(put(table_num,8.0))));
  set _sltabtrans_exist  end = eof;
  by table;
  if first.table;
  table_num + 1;
  call symput('tab'    || trim(left(put(table_num,32.0))),trim(left(table)));
  call symput('tshort' || trim(left(put(table_num,32.0))),trim(left(tshort)));
  call symput('tonly'  || trim(left(put(table_num,32.0))),put(table_only,1.0));
  if length(table) > 8 & tshort = ' ' then
   %ut_errmsg(msg="TABLE name length is greater than 8" table= " but no TSHORT",
   macroname=mdshortlong,type=warning);
run;
%ut_errmsg(msg=num_tables=&num_tables num_columns=&num_columns,
 macroname=mdshortlong,print=0)
*==============================================================================;
* If long variable names exist then rename them to the short names defined in;
*  metadata;
*==============================================================================;
%if &num_tables > 0 %then %do;
  %if %bquote(&outprog) ^= %then %do;
    data _null_;
      file "&outprog";
      put
       "libname &outprogl '<insert physical path of data library here>';" /
  %end;
  %unquote(&q)proc datasets  lib=&outprogl  nolist;%unquote(&q) &s
  %do table_num = 1 %to &num_tables;
    %unquote(&q)*-----------------------------------------------;%unquote(&q) &s
    %unquote(&q)%bquote(* Processing data set &outprogl..&&tab&table_num;)%unquote(&q) &s
    %unquote(&q)*-----------------------------------------------;%unquote(&q) &s

    %if ^ &&tonly&table_num %then %do;
      &p %unquote(&q)modify &&tab&table_num ; %unquote(&q) &s
      &p &p %unquote(&q)rename %unquote(&q) &s
      %do column_num = 1 %to &num_columns;
        %if &&table&column_num = &&tab&table_num %then %do;
          &p &p 
          %if &mode = S2L %then %do;
            %unquote(&q)&&cshort&column_num = &&column&column_num%unquote(&q)
          %end;
          %else %do;
            %unquote(&q)&&column&column_num = &&cshort&column_num%unquote(&q)
          %end;
          &s
        %end;
      %end;
      &p &p %unquote(&q);%unquote(&q) &s
    %end;

    %if %bquote(&&tshort&table_num) ^= %then %do;
      &p &p
      %if &mode = S2L %then %do;
        %unquote(&q)change &&tshort&table_num = &&table&table_num;%unquote(&q)
      %end;
      %else %do;
        %unquote(&q)change &&table&table_num = &&tshort&tabl_num;%unquote(&q)
      %end;
      &s
    %end;

  %end;
  %unquote(&q)quit;%unquote(&q) &s
  %if %bquote(&outprog) ^= %then %do;
    ;
    stop;
    run;
  %end;
%end;
%else %ut_errmsg(msg="No long column names found with short names mapped",
 macroname=mdshortlong);
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of mdshortlong macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _sl:;
  run; quit;
%end;
%endmac:
%mend;
