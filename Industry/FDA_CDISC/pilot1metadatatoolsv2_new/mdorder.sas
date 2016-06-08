%macro mdorder(inlib=_default_,outlib=_default_,select=_default_,
 exclude=_default_,varorder=_default_,compare=_default_,mdlib=_default_,
 mdprefix=_default_,sort=_default_,verbose=_default_,debug=_default_);
  /*soh************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdorder
TYPE                     : metadata, data transformation
DESCRIPTION              : Recreates a library of all or selected data sets
                            and reorders the variables' position in the data
                            sets PDV by the order defined in metadata,
                            alphabetic order of the variable name or label.
                            Optionally places key variables first in order.
                            Also sorts the data set(s) by the primary keys
                            defined in the metadata.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\mdorder\mdorderDL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MSWindows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt
INPUT                    : As defined by the parameters INLIB, MDLIB, SELECT
                            and EXCLUDE
OUTPUT                   : As defined by the parameters OUTLIB, SELECT and
                            EXCLUDE
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _mo
--------------------------------------------------------------------------------
Parameters:
Name      Type     Default  Description and Valid Values
--------- -------- -------- -------------------------------------------------
INLIB    required          Libref of input library
OUTLIB   required work     Libref of output library
SELECT   optional          List of data sets to process - all data sets are
                            processed if select is null
EXCLUDE  optional          List of data sets in INLIB to exclude from
                            processing - no datasets are excluded if null
VARORDER  required see note Sort by variable name, by variable label or by
                            order defined in MDLIB.COLUMNS CORDER variable
                            valid values: CORDER, NAME or LABEL
                            Default: when MDLIB specified - CORDER
                            otherwise NAME.
MDLIB    optional          Libref of library containing metadata sets.
                            This is required if SORT is true of if VARORDER
                            is CORDER.
MDPREFIX optional          Prefix added to metadata set names in MDLIB
SORT     required 1        %ut_logical value specifying whether to sort by
                            the primary keys defined in MDLIB.COLUMNS.
                            Default: if MDLIB not null then = 1
                            otherwise = 0
COMPARE  required 1        %ut_logical value specifying whether to do a PROC
                            COMPARE of the data sets in INLIB to the data 
                            sets in OUTLIB
VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                            is on or off
DEBUG    required 0        %ut_logical value specifying whether debug mode
                            is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

  %mdorder(inlib=preads,outlib=a,mdlib=m)

  This reads the data library referenced by the libref preads, orders the
  variables as defined by the metadata residing in the library referenced by
  the libref m, sorts the data sets as by the primary keys defined in the 
  metadata and writes the resultant data sets to the library a.

--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

--------------------------------------------------------------------------------
     Author &
Ver#  Peer Reviewer   Request #        Broad-Use MODULE History Description
---- ---------------- --------------- ------------------------------------------
1.0   Gregory Steffens BMRMI30JAN2006B Original version of the broad-use
       Vijay Sharma                         module January 2006
1.1   Gregory Steffens BMRMI20FEB2007B SAS version 9 migration
       Michael Fredericksen
  **eoh************************************************************************/
%ut_parmdef(verbose,1,_pdrequired=1,_pdverbose=1,_pdmacroname=mdorder)
%ut_logical(verbose)
%ut_parmdef(inlib,_pdrequired=1,_pdverbose=&verbose,_pdmacroname=mdorder)
%ut_parmdef(outlib,work,_pdverbose=&verbose,_pdmacroname=mdorder,_pdrequired=1)
%ut_parmdef(select,_pdverbose=&verbose,_pdmacroname=mdorder)
%ut_parmdef(exclude,_pdverbose=&verbose,_pdmacroname=mdorder)
%ut_parmdef(mdlib,_pdverbose=&verbose,_pdmacroname=mdorder)
%ut_parmdef(mdprefix,_pdverbose=&verbose,_pdmacroname=mdorder)
%ut_parmdef(compare,1,_pdrequired=1,_pdverbose=&verbose,_pdmacroname=mdorder)
%ut_parmdef(debug,0,_pdrequired=1,_pdverbose=&verbose,_pdmacroname=mdorder)
%if &verbose %then %put (mdorder) macro starting;
%ut_logical(compare)
%ut_logical(debug)
%if %bquote(%upcase(&varorder)) = %upcase(_default_) %then %do;
  %if %bquote(&mdlib) ^= %then %let varorder = corder;
  %else %let varorder = name;
%end;
%ut_parmdef(varorder,,corder name label,_pdrequired=1,_pdverbose=&verbose,
 _pdmacroname=mdorder)
%if %bquote(%upcase(&sort)) = %upcase(_default_) %then %do;
  %if %bquote(&mdlib) ^= %then %let sort = 1;
  %else %let sort = 0;
%end;
%else %do;
  %ut_logical(sort)
%end;
%ut_parmdef(sort,,,_pdrequired=1,_pdverbose=&verbose,_pdmacroname=mdorder)
%local titlstrt numvars nummems memnum varnum selectq excludeq numkeys keynum;
%ut_titlstrt
%ut_quote_token(inmvar=select,outmvar=selectq)
%let selectq = %upcase(&selectq);
%ut_quote_token(inmvar=exclude,outmvar=excludeq)
%let excludeq = %upcase(&excludeq);
title&titlstrt
 "(mdorder) Reordering Variables From &inlib to &outlib Selecting &select";
%if %bquote(&mdlib) = %then %do;
  %let invars =;
  %let mdsnprfx =;
%end;
*=============================================================================;
* Sort contents data set by member and variable name;
*=============================================================================;
proc contents data = &inlib.._all_    out = _mocont    noprint;
run;
data _mocont;
  set _mocont;
  memname = upcase(memname);
  name = upcase(name);
  %if %bquote(&selectq) ^= %then %do;
    if memname in (&selectq);
  %end;
  %if %bquote(&excludeq) ^= %then %do;
    if memname ^ in (&excludeq);
  %end;
run;
proc sort data = _mocont;
  by memname name;
run;
%if %bquote(&mdlib) ^= %then %do;
  *============================================================================;
  * Lookup variables in the COLUMNS data set to get key vars and order of vars;
  *============================================================================;
  %mdmake(inlib=&mdlib,outlib=work,mode=replace,inprefix=&mdprefix,
   outprefix=_mo,inselect=&select,inexclude=&exclude,addheader=1,
   contents=0,verbose=&verbose,debug=&debug)
  data _mocols;
    set _mocolumns (keep=table column cpkey corder cheader);
    table = upcase(table);
    column = upcase(column);
    if cpkey > 0 then _moiskey = 1;
    else _moiskey = 0;
  run;
  proc sort data = _mocols;
    by table column;
  run;
  data _mocont _monocols _monocont;
    merge _mocont (in=a keep = memname name memlabel label)
          _mocols (in=b rename=(table=memname column=name));
    by memname name;
    if ^ a then output _monocont;
    else if ^ b then output _monocols;
    if a then output _mocont;
  run;
  %if &verbose %then %do;
    proc print data = _monocont;
      title%eval(&titlstrt + 1)
       "(mdorder) Variables in &mdlib..columns not in &inlib";
    run;
    proc print data = _monocols;
      title%eval(&titlstrt + 1)
       "(mdorder) Variables in &inlib not in &mdlib..columns";
    run;
    title%eval(&titlstrt + 1);
  %end;
%end;
proc sort data = _mocont  equals;
  by memname 
   %if %bquote(&mdlib) ^= %then %do;
     %* This should be the same order as mdprint;
     descending _moiskey cpkey cheader
   %end;
   %if %bquote(%upcase(&varorder)) = %upcase(name) %then %do;
     name
   %end;
   %else %if %bquote(%upcase(&varorder)) = %upcase(label) %then %do;
     label name
   %end;
   %else %if %bquote(%upcase(&varorder)) = %upcase(corder) %then %do;
     corder name
   %end;
  ;
run;
*=============================================================================;
* Create macro array of data sets and variables in required order;
*=============================================================================;
%let nummems = 0;
data _null_;
  if eof & nummems > 0 then call symput('nummems',compress(put(nummems,6.0)));
  set _mocont end=eof;
  by memname;
  if first.memname;
  nummems + 1;
  call symput('m' || compress(put(nummems,6.0)),trim(left(memname)));
  call symput('ml' || compress(put(nummems,6.0)),
   trim(left(translate(memlabel,"'",'"'))));
run;
%if &debug %then %put nummems=&nummems;
*=============================================================================;
* Set each data set in and redefine variable order by specifying a LABEL;
* statement prior to the SET statement - this does not redefine label;
* or other variable attributes but does define variable order in data set;
*=============================================================================;
%if &nummems > 0 %then %do memnum = 1 %to &nummems;
  *--------------------------------------------------------------------------;
  %bquote(* &memnum of &nummems Processing data set &&m&memnum;)
  *--------------------------------------------------------------------------;
  %let numvars = 0;
  %let numkeys = 0;
  %if %bquote(%upcase(&varorder)) ^= %then %do;
    data _null_;
      if eof then do;
        if numvars > 0 then call symput('numvars',compress(put(numvars,6.0)));
        %if %bquote(&mdlib) ^= %then %do;
          if numkeys > 0 then call symput('numkeys',compress(put(numkeys,6.0)));
        %end;
      end;
      set _mocont
       (where = (upcase(memname) = "%upcase(&&m&memnum)"))
       end=eof;
      numvars + 1;
      call symput('v' || compress(put(numvars,6.0)),trim(left(name)));
      call symput('l' || compress(put(numvars,6.0)),
       trim(left(translate(label,"'",'"'))));
      %if %bquote(&mdlib) ^= %then %do;
        if cpkey > 0;
        numkeys + 1;
        call symput('key' || compress(put(numkeys,6.0)),trim(left(name)));
      %end;
    run;
  %end;
  %if &debug %then
   %put (mdorder) memnum=&memnum m&memnum=&&m&memnum numvars=&numvars;
  %if &sort & &numkeys > 0 %then %do;
    proc sort data = &inlib..&&m&memnum    out = _mo&&m&memnum;
      by 
       %do keynum = 1 %to &numkeys;
         &&key&keynum
       %end;
      ;
    run;
  %end;
  %if (&sort & &numkeys > 0) |
   (%bquote(%upcase(&outlib)) ^= %bquote(%upcase(&inlib))) |
   (%bquote(&varorder) ^= & &numvars > 0)
   %then %do;
    proc sql;
      create table &outlib..&&m&memnum
       %if %bquote(&&ml&memnum) ^= %then %do;
         (label = "&&ml&memnum")
       %end;
       as select
       %if %bquote(&varorder) ^= & &numvars > 0 %then %do;
         %do i = 1 %to &numvars;
           &&v&i
           %if &i ^= &numvars %then %do;
             ,
           %end;
         %end;
       %end;
       from 
       %if &sort & &numkeys > 0 %then %do;
         _mo&&m&memnum
       %end;
       %else %do;
         &inlib..&&m&memnum
       %end;
      ;
    quit;
    %if &compare & %bquote(%upcase(&inlib)) ^= %bquote(%upcase(&outlib)) %then 
     %do;
      proc compare compare=&outlib..&&m&memnum  listall  maxprint=(1000,500)
        %if &sort & &numkeys > 0 %then %do;
          base = _mo&&m&memnum;
          id
           %do keynum = 1 %to &numkeys;
             &&key&keynum
           %end;
          ;
        %end;
        %else %do;
          base = &inlib..&&m&memnum;
        %end;
      run;
    %end;    /* proc compare */
  %end;      /* create output data set to OUTLIB */
%end;        /* memnum = 1 to nummems */
*=============================================================================;
* End mdorder macro;
*=============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _mo:;
  run; quit;
%end;
title&titlstrt;
%if &verbose %then %put (mdorder) macro ending;
%mend;
