%macro mdfreqvals(inlib=_default_,out=_default_,mdlib=_default_,
 mdprefix=_default_,maxlevels=_default_,ldecodesuffix=_default_,
 sdecodesuffix=_default_,fmtcat=_default_,select=_default_,verbose=1,debug=0);
  /*soh************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : mdfreqvals
   TYPE                     : metadata
   DESCRIPTION              : Creates a VALUES metadata from the values found
                               in the data sets in a specified SAS library.
                               Optionally updates the COLUMNS metadata set 
                               variables CFORMAT and CFORMATFLAG.
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
							      Document List>
   SOFTWARE/VERSION#        : <Enter software name and version(s)used 
							      for code development and testing 
                               [e.g., SAS/Version 8]>
   INFRASTRUCTURE           : Windows, MVS
   BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt ut_quote_token
                              ut_find_decodes ut_find_decodes
   INPUT                    : <List all files and their production locations 
                               including AUTOEXEC files, if applicable>
   OUTPUT                   : <List all files [e.g. data sets] and 
                               file types [e.g. macro variable]>
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : <Enter applicable regulatory status [e.g. GCP,
                               GLP, GMP, GPP, NDR (non drug related) 
                               regulations, non-regulated, or N/A]. Refer to 
                               Statistics Glossary for the definition of each 
                               of the terms.>
   TEMPORARY OBJECT PREFIX  : <Enter unique ID for each broad-use module.
                               See Broad-Use Module Request.>
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
  INLIB     required         Libref of input data sets
  OUT       required         Name of output data set
  MDLIB     optional         Libref of metadata sets
  MAXLEVELS required 100     
  LDECODESUFFIX optional     
  SDECODESUFFIX optional     
  FMTCAT    optional          
  SELECT    optional          
  VERBOSE   required 1        %ut_logical value specifying whether verbose mode
                               is on or off
  DEBUG     required 0        %ut_logical value specifying whether debug mode
                               is on or off

  -----------------------------------------------------------------------------
  Usage Notes: <Parameter dependencies and additional information for the user>

  -----------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

  -----------------------------------------------------------------------------
		 Author	&							  Broad-Use MODULE History 
  Ver#   Peer Reviewer   Request # 		      Description
  ----  ---------------- ---------------      --------------------------------
  1.0   Gregory Steffens <Enter BUM Request#> Original version of the broad-use 
        <Peer Reviewer name>                  module
                  
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization - define parameters, declare local variables etc.;
%*=============================================================================;
%ut_parmdef(inlib,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(out,values,_pdmacroname=mdfreqvals,_pdrequired=1)
%ut_parmdef(mdlib,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(mdprefix,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(maxlevels,100,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(ldecodesuffix,lnm,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(sdecodesuffix,snm,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(fmtcat,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(select,_pdmacroname=mdfreqvals,_pdrequired=0)
%ut_parmdef(verbose,1,_pdmacroname=mdfreqvals,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=mdfreqvals,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%local selectq numdsns dsnnum num_type_stmt_parts type_stmt_parts_num titlstrt;
%ut_quote_token(inmvar=select,outmvar=selectq)
%let selectq = %upcase(&selectq);
%ut_titlstrt
title&titlstrt "(mdfreqvals) Creating &out from &inlib";
*==============================================================================;
* Create a proc contents data set and subset if SELECT parameter specified;
*==============================================================================;
proc contents data = &inlib.._all_  out = _mfcont  noprint;
run;
data _mfcont;
  set _mfcont;
  memname = upcase(memname);
  name = upcase(name);
  %if %bquote(&select) ^= %then %do;
    if memname in ( &selectq );
  %end;
run;
proc sort data = _mfcont;
  by memname name;
run;
*==============================================================================;
* Determine what the code/decode variable names are and merge these with the;
*  proc contents data set adding the following variables;
*  root_name code_name sdecode_name ldecode_name valvar cformatflag;
*==============================================================================;
%ut_find_decodes(contentsdsn=_mfcont,out=_mfdecodes,verbose=&verbose,
 ldecodesuffix=&ldecodesuffix,sdecodesuffix=&sdecodesuffix,debug=&debug)
proc sql;
  create table _mfcont_codes as
  select c.*, d.root_name, d.code_name, d.sdecode_name, d.ldecode_name
   from _mfcont c left join _mfdecodes d
   on c.memname = d.memname & (name = code_name | name = sdecode_name |
   name = ldecode_name);
quit;
data _mfcont_codes;
  set _mfcont_codes;
  if root_name = ' ' then root_name = name;
  length valvar $ 32  cformatflag 8;
  if code_name = ' ' & sdecode_name = ' ' & ldecode_name = ' ' then do;
    valvar = 'start';
    cformatflag = 2;
  end;
  else do;
    if name = code_name then do;
      valvar = 'start';
      cformatflag = 2;
    end;
    else if name = sdecode_name then do;
      valvar = 'flabel';
      cformatflag = 3;
    end;
    else if name = ldecode_name then do;
      valvar = 'flabellong';
      cformatflag = 4;
    end;
  end;
run;
proc sort data = _mfcont_codes;
  by memname root_name name;
run;
*==============================================================================;
* Add order number of variable in proc summary var statement and;
*  the value list name that will be created by proc summary;
*  adding variables: var_stmt_order and val_list_name;
*==============================================================================;
data _mfcontcodes;
  set _mfcont_codes;
  by memname root_name;
  if first.memname then var_stmt_order = 1;
  else var_stmt_order + 1;
  if first.root_name then do;
    val_list_number + 1;
    val_list_name = 'VAL' || trim(left(put(val_list_number,32.0)));
  end;
  retain val_list_name;
  drop val_list_number;
run;
%if &debug %then %do;
  proc print data = _mfcontcodes width=minimum;
    by memname;
    var name root_name code_name sdecode_name ldecode_name var_stmt_order
     val_list_name valvar cformatflag;
    title%eval(&titlstrt + 1) '(mdfreqvals debug) _mfcontcodes';
  run;
  title%eval(&titlstrt + 1);
%end;
*==============================================================================;
* Create a format to return the variable order number from the variable name;
*  for use later when creating the _type_ variable value from proc summary;
*==============================================================================;
data _mfname_order_fmt;
  set _mfcontcodes (keep=memname name var_stmt_order);
  length fmtname $ 8  type $ 1  start $ 65  label $ 32;
  fmtname = 'vo';
  type = 'C';
  start = trim(left(memname)) || ' ' || trim(left(name));
  label = trim(left(put(var_stmt_order,32.0)));
  keep fmtname type start label;
run;
%if &debug %then %do;
  proc print data = _mfname_order_fmt width=minimum;
    title%eval(&titlstrt + 1) '(mdfreqvals debug) _mfname_order_fmt';
  run;
  title%eval(&titlstrt + 1);
%end;
proc format cntlin=_mfname_order_fmt;
run;
*==============================================================================;
* Process each data set in the proc contents output data set;
*==============================================================================;
%let numdsns = 0;
data _null_;
  if eof & numdsns > 0 then
   call symput('numdsns',trim(left(put(numdsns,32.0))));
  set _mfcontcodes (keep=memname) end=eof;
  by memname;
  if first.memname;
  numdsns + 1;
  call symput('dsn' || trim(left(put(numdsns,32.0))),trim(left(memname)));
run;
%if &numdsns > 0 %then %do;
  %do dsnnum = 1 %to &numdsns;
    *--------------------------------------------------------------------------;
    %bquote(* Processing data set &&dsn&dsnnum;)
    *--------------------------------------------------------------------------;
    %let numvars = 0;
    data _mfcont_currentdsn;
      set _mfcontcodes (keep=memname name type var_stmt_order val_list_name
       root_name code_name sdecode_name ldecode_name valvar cformatflag
       where = (memname = "&&dsn&dsnnum"))  end=eof;
      if eof then call symput('_type_length',trim(left(put(_n_,32.0))));
    run;
    *--------------------------------------------------------------------------;
    * Create parallel macro arrays with one element per variable;
    * ;
    * VAR       Variable name array;
    * VARTYPE   Variable type array (numeric or character);
    * VAR_TYPE_ Character value of _TYPE_ variable created by PROC SUMMARY;
    * VALVAR    Variable in VALUES metadata - START FLABEL or FLABELLONG;
    * VARFMT    Value of columns.cformat and values.format;
    *--------------------------------------------------------------------------;
    data _mftype_stmt_parts;
      set _mfcont_currentdsn  end=eof  nobs=nobs;
      _type_num = 2**(nobs - _n_);
      length _type_char $ &_type_length  type_stmt_part $ 98;
      _type_char = repeat('0',&_type_length);
      if code_name = ' ' & sdecode_name = ' ' & ldecode_name = ' ' then do;
        substr(_type_char,input(put(trim(left(memname)) || ' ' ||
         trim(left(name)),$vo.),32.0),1) = '1';
        type_stmt_part = trim(left(name));
      end;
      else do;
        if code_name ^= ' ' then do;
          substr(_type_char,input(put(trim(left(memname)) || ' ' ||
           trim(left(code_name)),$vo.),32.0),1) = '1';
          type_stmt_part = code_name;
          needast = '*';
        end;
        else needast = ' ';
        if sdecode_name ^= ' ' then do;
          substr(_type_char,input(put(trim(left(memname)) || ' ' ||
           trim(left(sdecode_name)),$vo.),32.0),1) = '1';
          type_stmt_part = trim(left(type_stmt_part)) || needast ||
           sdecode_name;
          needast = '*';
        end;
        if ldecode_name ^= ' ' then do;
          substr(_type_char,input(put(trim(left(memname)) || ' ' ||
           trim(left(ldecode_name)),$vo.),32.0),1) = '1';
          type_stmt_part = trim(left(type_stmt_part)) || needast ||
           ldecode_name;
          needast = ' ';
        end;
        type_stmt_part = left(type_stmt_part);
      end;
      call symput('var' || trim(left(put(_n_,32.0))),trim(left(name)));
      call symput('vartype' || trim(left(put(_n_,32.0))),trim(left(put(type,2.0))));
      call symput('var_type_' || trim(left(put(_n_,32.0))),_type_char);
      call symput('valvar' || trim(left(put(_n_,32.0))),trim(left(valvar)));
      call symput('varfmt' || trim(left(put(_n_,32.0))),trim(left(val_list_name)));
      if eof then call symput('numvars',trim(left(put(_n_,32.0))));
      keep type_stmt_part code_name sdecode_name ldecode_name root_name
       memname name valvar val_list_name _type_num _type_char;
    run;
    %if &debug %then %do;
      proc print data = _mftype_stmt_parts  width=minimum;
        by memname;
        title%eval(&titlstrt + 1)
         "(ut_find_decodes debug) _mftype_stmt_parts before sort nodupkey";
      run;
      title%eval(&titlstrt + 1);
      %do varnum = 1 %to &numvars;
        %put var&varnum=&&var&varnum;
        %put vartype&varnum=&&vartype&varnum;
        %put var_type_&varnum=&&var_type_&varnum;
        %put valvar&varnum=&&valvar&varnum;
        %put varfmt&varnum=&&varfmt&varnum;
        %put;
      %end;
    %end;
    *--------------------------------------------------------------------------;
    * Create macro array with one element per code, short and long decode;
    * ;
    * TYPE_STMT_PART Component of PROC SUMMARY TYPE statement;
    *--------------------------------------------------------------------------;
    proc sort data = _mftype_stmt_parts (keep=type_stmt_part code_name
     sdecode_name ldecode_name root_name) nodupkey;
      by type_stmt_part;
    run;
    %let num_type_stmt_parts = 0;
    data _null_;
      set _mftype_stmt_parts end=eof;
      call symput('type_stmt_part' || trim(left(put(_n_,32.0))),
       trim(left(type_stmt_part)));
      if eof then call symput('num_type_stmt_parts',trim(left(put(_n_,32.0))));
    run;
    %if &debug %then %do;
      proc print data = _mfcont_currentdsn  width=minimum;
        by memname;
        title%eval(&titlstrt + 1) "(ut_find_decodes debug) _mfcont_currentdsn";
      run;
      proc print data = _mftype_stmt_parts  width=minimum;
        title%eval(&titlstrt + 1)
         "(ut_find_decodes debug) _mftype_stmt_parts after sort nodupkey";
      run;
      title%eval(&titlstrt + 1);
      %do type_stmt_parts_num = 1 %to &num_type_stmt_parts;
        %put type_stmt_part&type_stmt_parts_num=&&type_stmt_part&type_stmt_parts_num;
      %end;
    %end;
    *--------------------------------------------------------------------------;
    * Run PROC SUMMARY to create list of unique values and freqency of these;
    *--------------------------------------------------------------------------;
    proc summary data = &inlib..&&dsn&dsnnum missing noprint chartype;
      class 
       %do varnum = 1 %to &numvars;
         &&var&varnum
       %end;
      / groupinternal;
      types 
       %do type_stmt_parts_num = 1 %to &num_type_stmt_parts;
         &&type_stmt_part&type_stmt_parts_num
       %end;
      ;
      output out=_mfsmry;
    run;
    %if &maxlevels > 0 %then %do;
    *--------------------------------------------------------------------------;
    * Determine what _TYPE_ s have too many values;
    *--------------------------------------------------------------------------;
      data _mftoo_many_levels;
        set _mfsmry;
        by _type_;
        if first._type_ then do;
          number_levels = 0;
          too_many_levels = 0;
        end;
        number_levels + 1;
        if last._type_ & number_levels > &maxlevels then output;
        keep _type_ number_levels;
      run;
    %end;
    *==========================================================================;
    * Process PROC SUMMARY output data set to create variable for VALUES;
    *  metadata set;
    *==========================================================================;
    data _mfvarstarts_new (keep=format start flabel flabellong)
     _mf_type_eror
      %if &maxlevels > 0 %then %do;
        _mfvarsdropped (keep=format number_levels);
        merge _mfsmry (in=fromsmry)  _mftoo_many_levels (in=fromtoomany);
        by _type_;
      %end;
      %else %do;
        ;
        set _mfsmry;
      %end;
      length format $ 32 start $ 300 flabel $ 100 flabellong $ 400;
      flabel = ' ';
      flabellong = ' ';

%* add: if numeric and more than maxlevels then define range with start/end;

      %do varnum = 1 %to &numvars;
        if _type_ = "&&var_type_&varnum" then do;
          format = "&&varfmt&varnum";
          %if &&vartype&varnum = 1 %then %do;
            &&valvar&varnum = left(put(&&var&varnum,best.));
          %end;
          %else %if &&vartype&varnum = 2 %then %do;
            &&valvar&varnum = &&var&varnum;
          %end;
          %else %do;
            &&valvar&varnum = ' ';
            %put unrecognized type vartype&varnum=&&vartype&varnum;
          %end;
        end;
      %end;
      if format = ' ' then output _mf_type_eror;
      %if &maxlevels > 0 %then %do;
        if ^ fromtoomany then output _mfvarstarts_new;
        else if last._type_ then output _mfvarsdropped;
      %end;
    run;
    proc print data = _mf_type_eror width=minimum;
      title%eval(&titlstrt + 1) '(mdfreqvals) _type_ er'
       'rors - format name not assigned';
    run;
    title%eval(&titlstrt + 1);
    %if &maxlevels > 0 %then %do;
      proc print data = _mfvarsdropped;
        var format number_levels;
        title%eval(&titlstrt + 1) '(mdfreqvals) Variable values not used because more values than '
          "&maxlevels";
      run;
      title%eval(&titlstrt + 1);
    %end;
    %if &dsnnum = 1 %then %do;
      data _mfvarstarts;
        set _mfvarstarts_new;
      run;
    %end;
    %else %do;
      proc append base=_mfvarstarts data=_mfvarstarts_new;
      run;
    %end;
  %end;  /* end iteration of each data set */
  proc sort data = _mfvarstarts;
    by format start;
  run;

  *============================================================================;
  * ;
  *============================================================================;

%* Add:  if md.values already exists then compare to _mfout;

  data _mfout;
    attrib format     length=$13  label="Format Name";
    attrib start      length=$300 label='Start Value';
    attrib end        length=$300 label='End Value';
    attrib flabel     length=$100 label='Format Label';
    attrib flabellong length=$400 label='Long Format Label';
    set _mfvarstarts;

    if 0 then do;
      end = ' ';
    end;

    keep format start end flabel flabellong;
  run;
  proc sort data = _mfout;
    by format start end;
  run;

  %if %bquote(&mdlib) ^= %then %do;
    *==========================================================================;
    * update cformat in columns metadata set;
    *==========================================================================;
    data _mfcolumns;
      set &mdlib..&mdprefix.columns;
      table = upcase(table);
      column = upcase(column);
    run;
    proc sort data = _mfcolumns;
      by table column;
    run;
    proc sort data = _mfcontcodes (keep=memname name val_list_name cformatflag)
     out = _mformatnames  nodupkey;
      by memname name;
    run;
    data &mdlib..&mdprefix.columns (drop=val_list_name cfflag)
     _mfexistingcformats (keep=table column cformat cformatflag val_list_name
                          cfflag)
     _mfnotincolumns (keep=table column)
     _mfcformatnamemap (keep=table column cformat cformatflag val_list_name
                        cfflag)
    ;
      merge _mfcolumns (in=fromcols)
            _mformatnames (in=fromfnames rename=(memname=table name=column
                           cformatflag=cfflag));
      by table column;
      if (val_list_name ^= ' ' & cfflag ^= 1) |
       (cformat ^= ' ' & cformatflag ^= 1) then output _mfcformatnamemap;
      if ^ fromcols then do;
        output _mfnotincolumns;
      end;
      if fromcols;
      if cformat = ' ' then do;
        cformat = val_list_name;
        cformatflag = cfflag;
      end;
      else do;

        %if %bquote(&selectq) ^= %then %do;
          if upcase(table) in ( &selectq ) then
        %end;

        output _mfexistingcformats;
      end;
      output &mdlib..&mdprefix.columns;
    run;
    proc print data = _mfexistingcformats width=minimum;
      title%eval(&titlstrt + 1)
       '(mdfreqvals) CFORMAT values already in &mdlib..&mdprefix.columns';
    run;
    proc print data = _mfnotincolumns width=minimum;
      title%eval(&titlstrt + 1)
       '(mdfreqvals) variables not defined in &mdlib..&mdprefix.columns';
    run;
    title%eval(&titlstrt + 1);

    %if %sysfunc(exist(&mdlib..&mdprefix.values)) %then %do;
      %let dsid = %sysfunc(open(&mdlib..&mdprefix.values));
      %if &dsid > 0 %then %do;
        *======================================================================;
        * Combine and compare existing values and new values metadata sets;
        *======================================================================;
        %if %sysfunc(attrn(&dsid,nobs)) > 0 %then %do;
          proc sort data = &mdlib..&mdprefix.values  out = _mfvalues;
            by format start end;
          run;

%* match formats if associated with same column even if format name is different
   first merge by format and then by format start end;

          data _mfdifflabels _mfnotindata _mfnotinvalues;
            merge _mfvalues (in=fromvalues)
                  _mfout (in=fromout
                          rename=(flabel=flabelout flabellong=flabellongout));
            by format start end;
          
        %end;
      %end;
    %end;

  %end;
%end;
%else %do;
  %ut_errmsg(msg="no data sets found in &inlib",macroname=mdfreqvars,type=warning)
%end;
*==============================================================================;
* Create output data set;
*==============================================================================;
data &out;
  set _mfout;
run;
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of mdfreqvals macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _mf:;
  run; quit;
%end;
%mend;
