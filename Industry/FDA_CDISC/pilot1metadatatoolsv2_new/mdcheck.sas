%macro mdcheck(inlib=_default_,mdlib=_default_,fmtcats=_default_,
 mdprefix=_default_,select=_default_,exclude=_default_,flabeltype=_default_,
 fmtcntlout=_default_,maxobs=_default_,outlib=_default_,outprefix=_default_,
 project=_default_,print=_default_,complengths=_default_,verbose=_default_,
 debug=_default_);
  /*soh************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdcheck
TYPE                     : metadata
DESCRIPTION              : Compares a data base to its specification
                            contained in meta data sets and reports
                            inconsistencies in structure and content.
DOCUMENT LIST            : \\spreeprd\genesis\SPRE\\QA\General\
                            Broad_use_modules\SAS\mdcheck\mdcheck DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MSWindows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt ut_errmsg
                           mdbuild mdcompare mdmake
INPUT                    : specification meta data sets in mdlib library and
                            SAS data sets in inlib library
OUTPUT                   : Output data sets are optionally created when the
                            OUTLIB parameter is specifed in the macro call
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _mc
--------------------------------------------------------------------------------
Parameters:
Name      Type     Default  Description and Valid Values
--------- -------- -------- ----------------------------------------------------
 INLIB    required          Libref of library containing database
 MDLIB    required          Libref of library containing specification
                             meta data sets.
 MDPREFIX optional          Passed to macro MDCOMPARE MDPREFIXB parameter
                             This is used to build metadata from INLIB to
                             compare to MDLIB.
 FMTCATS  optional null     See mdbuild macro for description of FMTCATS.
                             This is used to build metadata from INLIB to
                             compare to MDLIB.  The default value mdcheck 
                             assigns is the null value, overriding the default
                             of mdbuild.
 FMTCNTLOUT optional        See mdbuild macro for description of FMTCNTLOUT
 SELECT   optional          A list of data set names in INLIB and MDLIB
                             that you want
                             the macro to limit itself to.  A null value 
                             results in all data sets being processed
 EXCLUDE  optional          A list of data set names in INLIB and MDLIB
                             that you want
                             the macro to exclude from processing.  A null 
                             values results in excluding no data sets.
 FLABELTYPE required flabel flabel or flabellong.  See mdbuild for details.
 MAXOBS   required 0        The maximum number of bad observations to print.
                             This limits the number of observations printed
                             that have at least one variable with an invalid
                             value.  It also limits the number of observations
                             printed that are duplicates, as defined by the
                             primary keys of the data set.  The value of 
                             MAXOBS must be a positive integer.
 OUTLIB   optional          Libref of where optional output data sets are 
                             written.  This is passed to the mdcompare macro.
                             In addition a data set named values_freq is
                             created by the mdcheck macro and written to
                             OUTLIB.
 OUTPREFIX optional         Prefix to apply to all output data set names.
 PROJECT  optional          Value of the PROJECT variable in the output data
                             sets.
 PRINT    required 1        %ut_logical value specifying whether the summaries
                             and listings are written to the SAS listing file
                             (or ODS destination).  It may be desireable to
                             set PRINT to a false value when OUTLIB is 
                             specified.
 COMPLENGTHS required 0      %ut_logical value specifying whether to compare
                              the CLENGTH variable in the COLUMNS metadata set
                              This is passed to the mdcompare macro.
 VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                             is on or off
 DEBUG    required 0        %ut_logical value specifying whether debug mode
                             is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

   The MDCHECK macro calls MDBUILD to create metadata describing the data in
   the INLIB library.  It then calls MDCOMPARE to compare this metadata to the
   metadata residing in the MDLIB library.
--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

  %mdcheck(inlib=a,mdlib=m,fmtcats=a.formats,maxobs=100)

  Compare the data in the a library to the requirements in the m library.  The
  a.formats format catalog defines the valid values allowed for formatted
  variables.  Change the maximum number of observations with disallowed
  values to be printed to 100.


  %mdcheck(inlib=a,mdlib=m,fmtcntlout=e.formats,fmtcats=)

  Compare the data in the a library to the requirements in the m library.  The
  valid values allowed for formatted variables are defined the e.formats data
  set that is structured like a cntlout data set of proc format.


  libname metrics "<physical path>';
  %mdcheck(inlib=a,mdlib=m,fmtcats=a.formats,outlib=metrics,print=no)

  Compare the data in the a library to the requirements in the m library.
  Output data sets are written to the metrics library and the summary and
  listings of the discrepancies are not created.
--------------------------------------------------------------------------------
      Author &
Ver#   Peer Reviewer   Request #        Broad-Use MODULE History Description
----  ---------------- ---------------- ----------------------------------------
1.0   Gregory Steffens BMRGCS25JUL2005A Original version of the broad-use
       Sheetal Lal                       module 25Jul05
2.0   Gregory Steffens BMRMI30JAN2006A  January 2006
       Vijay Sharma
                         Added support of the convention followed in the ADS
                          standard where decode values are stored in variables.
                          When c/pformatflag = 3 then INLIB values are checked
                          against the FLABEL values in the VALUES data set
                          instead of START.
                          When c/pformatflag = 4 then INLIB values are checked
                          against the FLABELLONG values in the VALUES data set
                          instead of START.
                          When c/pformatflag = 2 then INLIB values are checked
                          against the START values in the VALUES data set.
                          When c/pformatflag = 1 then a SAS system format is 
                          defined if c/pformat and the values data set is not
                          used to check values in INLIB.
                         Added parameters OUTLIB OUTPREFIX PROJECT and PRINT
                          passed to the mdcompare macro and used to create
                          an additional output data set with the number of
                          observations that include variable(s) with values
                          not allowed by the metadata (named values_freq).
                         Added a count by variable of the number of observations
                          with disallowed values printed before each listing
                          of observations with disallowed values.
                         Added a count of each variable's disallowed values.
                         Added a count by parameter of the number of
                          observations with disallowed values printed before
                          each listing of observations with disallowed values.
                         Added a count of each parameter's disallowed values.
                         Added total observation count in the title of the
                          listing of observations with disallowed values.
                         Reassigned CORDER in the COLUMNS metadata set so that
                          it takes primary keys and header variables into 
                          account and will match the VARNUM assignment to CORDER
                          created by mdbuild from the INLIB data.
                         Changed default value of MAXOBS to 0.
                         Added support for values metadata set start = _nomiss_
                          to require no missing values allowed but no other
                          valid values defined.
                         Added two title lines describing inlib and mdlib
                         Changed default value of FMTCATS to null
                         Added check for duplicates in the values metadata set
                          duplicates of fmtname type start hlo.  Duplicates are
                          reported and the duplicates are deleted.
                         Added COMPLENGTHS parameter.
2.1  Gregory Steffens BMRMI20FEB2007A SAS version 9 migration
      Michael Fredericksen

3.0   Gregory Steffens                         
                         Changed where clause in PROC FREQ of invalid values
                          by variable from contains operator to indexw function.
                          This fixes a bug where a code variable values were 
                          reported as invalid when they were valid - when 
                          the code variable and one of its decode variables
                          both had invalid values then the code variable values
                          that were valid were reported as invalid from
                          observations where the decode value was invalid.  That
                          is,
                  WHERE UPCASE(BAD_COLUMNS) ? "%upcase(&&bad_var&bad_var_number)"
                          selected observations where bad_columns contained
                          "abcsnm" or "abclnm" but not "abc" when reporting
                          invalid values of "abc".  The indexw function fixes
                          this by selecting blank-delimited words rather than 
                          undelimited text strings
                  indexw(upcase(bad_columns),"%upcase(&&bad_var&bad_var_number)"
                         Did similar change for the reporting of invalid 
                          parameter values.
                         Fixed unreported bug with xxvars=_any_ and observat
                          =null.  The SOURCE variable is not created by 
                          mdadstandard in this case and mdcheck generated 
                          warnings about uninitialized and type conversion.
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(inlib,_pdrequired=1,_pdmacroname=mdcheck)
%ut_parmdef(mdlib,_pdrequired=1,_pdmacroname=mdcheck)
%ut_parmdef(fmtcats,,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(fmtcntlout,_default_,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(mdprefix,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(select,_default_,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(exclude,_default_,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(flabeltype,_default_,_pdrequired=1,_pdmacroname=mdcheck)
%ut_parmdef(maxobs,0,_pdrequired=1,_pdmacroname=mdcheck)
%ut_parmdef(outlib,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(outprefix,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(project,_pdrequired=0,_pdmacroname=mdcheck)
%ut_parmdef(print,1,_pdrequired=1,_pdmacroname=mdcheck)
%ut_parmdef(complengths,0,_pdmacroname=mdcheck,_pdrequired=1)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=mdcheck,_pdverbose=1)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdcheck,_pdverbose=1)
%ut_logical(print)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt numtables tablenum fmtsearch numcolumns columnnum numkeys
 keynum numdups collen numparamrels paramrellen badobs hasvalues paramrelnum
 total_obs first_table number_bad_vars bad_var_number number_bad_params
 bad_param_number;
%ut_titlstrt
title&titlstrt "(mdcheck) Checking data in &inlib to requirements in &mdlib";
title%eval(&titlstrt + 1) "(mdcheck) Inlib:&inlib"
 %if %bquote(&inlib) ^= %then %do;
   %if %sysfunc(libref(&inlib)) = 0 & %bquote(%upcase(&inlib)) ^= WORK %then
    %do;
     ": %sysfunc(pathname(&inlib))"
   %end;
 %end;
;
title%eval(&titlstrt + 2) "(mdcheck) Mdlib:&mdlib"
 %if %bquote(&inlib) ^= %then %do;
   %if %sysfunc(libref(&mdlib)) = 0 & %bquote(%upcase(&mdlib)) ^= WORK %then
    %do;
     ": %sysfunc(pathname(&mdlib))"
   %end;
 %end;
;
*==============================================================================;
* Call mdbuild to create metadata describing INLIB and call mdcompare to;
*  compare that metadata to the specified metadata that INLIB is supposed to;
*  conform to (mdmake is called to add header variables to metadata);
*==============================================================================;
%mdbuild(inlib=&inlib,mdlib=work,outprefix=_mcd,fmtcats=&fmtcats,
 fmtcntlout=&fmtcntlout,flabeltype=&flabeltype,verbose=&verbose,debug=&debug)
%mdmake(inlib=&mdlib,outlib=work,inprefix=&mdprefix,outprefix=_mcm,
 mode=replace,addparam=0,addheader=1,inselect=&select,inexclude=&exclude,
 contents=0,mkcat=0,verbose=1,debug=&debug)
*------------------------------------------------------------------------------;
* Redefine corder to match corder as populated with varnum by mdbuild;
%* This should be the same order in mdprint and mdorder and mdmkdsn;
*------------------------------------------------------------------------------;
data _mcmcolumns;
  set _mcmcolumns;
  if cpkey > 0 then cpkeyyn = 1;
  else cpkeyyn = 0;
run;
proc sort data = _mcmcolumns;
  by table descending cpkeyyn cpkey cheader corder column;
run;
data _mcmcolumns;
  set _mcmcolumns (rename = (corder = corder_original));
  by table;
  if first.table then corder = 1;
  else corder + 1;
run;
%mdcompare(baselib=work,complib=work,mdprefixb=_mcm,mdprefixc=_mcd,
 base=Spec,compare=Data,compall=0,select=&select,exclude=&exclude,
 checkcat=0,outlib=&outlib,outprefix=&outprefix,project=&project,print=&print,
 complengths=&complengths,verbose=&verbose,debug=&debug)
*==============================================================================;
* Check values in INLIB to values allowed in MDLIB;
*==============================================================================;
%mdmake(inlib=&mdlib,outlib=work,inprefix=&mdprefix,outprefix=_mcm,
 mode=replace,addparam=1,addheader=0,inselect=&select,inexclude=&exclude,
 contents=0,mkcat=0,verbose=&debug,debug=&debug)
%let numtables = 0;
data _null_;
  if eof & tablenum > 0 then
   call symput('numtables',trim(left(put(tablenum,6.0))));
  set _mcmtables (keep=table) end=eof;
  if exist("&inlib.." || trim(left(table))) then do;
    tablenum + 1;
    call symput('tab' || trim(left(put(tablenum,6.0))),trim(left(table)));
  end;
  else %ut_errmsg(msg="Table defined in metadata does not" " exist in &inlib "
   table=,macroname=mdcheck,type=note);
run;
%if &debug %then %do;
  %put (mdcheck) numtables=&numtables;
  %if &numtables > 0 %then %do tablenum = 1 %to &numtables;
    %put tab&tablenum=&&tab&tablenum;
  %end;
%end;
%if &numtables > 0 %then %do;
  %let first_table = 1;
  *----------------------------------------------------------------------------;
  * Create a list of formats and format types that are referenced in metadata;
  *  sets COLUMNS and COLUMNS_PARAM;
  *----------------------------------------------------------------------------;
  proc sort data = _mcmcolumns (keep = cformat ctype column cformatflag
   where = (cformat ^= ' '))  out = _mcmcolfmts  nodupkey;
    by cformat ctype column;
  run;
  data _mcmcolfmts;
    set _mcmcolfmts;
    by cformat;
    if first.cformat then do;
      ctypen = 0;
      ctypec = 0;
      csnm = 0;
      clnm = 0;
    end;
    if upcase(ctype) = 'N' then ctypen = 1;
    if upcase(ctype) = 'C' then ctypec = 1;
    if cformatflag = 3 then csnm = 1;
    else if cformatflag = 4 then clnm = 1;
    if last.cformat then output;
    retain ctypen ctypec csnm clnm;
    keep cformat ctypen ctypec csnm clnm;
  run;
  proc sort data = _mcmcolumns_param (keep = pformat ptype paramrel pformatflag
   where=(pformat^=' '))  out = _mcmparmfmts  nodupkey;
    by pformat ptype paramrel;
  run;
  data _mcmparmfmts;
    set _mcmparmfmts;
    by pformat;
    if first.pformat then do;
      ptypen = 0;
      ptypec = 0;
      psnm = 0;
      plnm = 0;
    end;
    if upcase(ptype) = 'N' then ptypen = 1;
    if upcase(ptype) = 'C' then ptypec = 1;
    if pformatflag = 3 then psnm = 1;
    else if pformatflag = 4 then plnm = 1;
    if last.pformat then output;
    retain ptypen ptypec psnm plnm;
    keep pformat ptypen ptypec psnm plnm;
  run;
  data _mcmcpfmts;
    merge _mcmcolfmts (rename=(cformat=format))
          _mcmparmfmts (rename=(pformat=format));
    by format;
    if ctypen | ptypen then ftypen = 1;
    else ftypen = 0;
    if ctypec | ptypec then ftypec = 1;
    else ftypec = 0;
    if csnm | psnm then do;
      snm_number + 1;
      formatsnm = 'snm' || trim(left(put(snm_number,6.0))) || '_';
    end;
    else formatsnm = '';
    if clnm | plnm then do;
      lnm_number + 1;
      formatlnm = 'lnm' || trim(left(put(lnm_number,6.0))) || '_';
    end;
    else formatlnm = '';
    keep format ftypen ftypec formatsnm formatlnm;
  run;
  *----------------------------------------------------------------------------;
  * Merge these referenced formats with the VALUES metadata set to create a;
  *  cntlin data set for PROC FORMAT;
  * These formats translate allowed values to 1 and all other values to 0;
  *----------------------------------------------------------------------------;
  %let hasvalues = 0;
  data _mccntlin;
    merge _mcmvalues (in=fromvals rename=(start=start_value end=end_value))
          _mcmcpfmts (in=fromfmts);
    by format;
    if fromvals & fromfmts;
    call symput('hasvalues','1');
    if upcase(left(start_value)) = '_NOMISS_' & first.format + last.format ^= 2
     then %ut_errmsg(msg="Formats with VALUES.START = _NOMISS_ must have only "
     "one observation in VALUES " format=,macroname=mdcheck,type=warning);
    if end_value = ' ' & start_value ^= ' ' then end_value = start_value;
    length source_variable $ 10  source_format $ 32;
    hlo = ' ';
    fmtname = format;
    source_format = format;
    source_variable = 'start';
    if upcase(left(start_value)) ^= '_NOMISS_' then do;
      start = start_value;
      end = end_value;
      label = '1';
    end;
    else do;
      start = ' ';
      end = ' ';
      label = '0';
    end;
    type = ' ';
    if ftypen | (ftypen ^= 1 & ftypec ^= 1) then do;
      type = 'N';
      output;
    end;
    if ftypec then do;
      type = 'C';
      output;
    end;

%* if formatflag is 3 or 4 then it is assumed the variable type is C
to fix this create formatsnmn formatsnmc formatlnmn formatlnmc;

    if formatsnm ^= ' ' then do;
      fmtname = formatsnm;
      type = 'C';
      if upcase(left(start_value)) ^= '_NOMISS_' then start = flabel;
      else start = ' ';
      end = start;
      source_variable = 'flabel';
      output;
    end;
    if formatlnm ^= ' ' then do;
      fmtname = formatlnm;
      type = 'C';
      if upcase(left(start_value)) ^= '_NOMISS_' then start = flabellong;
      else start = ' ';
      end = start;
      source_variable = 'flabellong';
      output;
    end;
    if last.format then do;
      fmtname = format;
      hlo = 'O';
      start = ' ';
      end = ' ';
      if upcase(left(start_value)) ^= '_NOMISS_' then label = '0';
      else label = '1';
      type = ' ';
      source_variable = 'hlo';
      if ftypen | (ftypen ^= 1 & ftypec ^= 1) then do;
        type = 'N';
        output;
      end;
      if ftypec then do;
        type = 'C';
        output;
      end;
      if formatsnm ^= ' ' then do;
        fmtname = formatsnm;
        type = 'C';
        output;
      end;
      if formatlnm ^= ' ' then do;
        fmtname = formatlnm;
        type = 'C';
        output;
      end;
    end;
    keep fmtname type start end label hlo source_variable source_format;
  run;
  %if &hasvalues %then %do;
    proc sort data = _mccntlin;
      by fmtname type start hlo;
    run;
    data _mccntlin  _mccntlindups;
      set _mccntlin;
      by fmtname type start hlo;
      if first.hlo + last.hlo = 2 then output _mccntlin;
      else do;
        if first.hlo then output _mccntlin;
        output _mccntlindups;
      end;
    run;
    %if &verbose %then %do;
      proc print data = _mccntlindups  width=minimum;
        var fmtname source_format type start end hlo source_variable;
        title%eval(&titlstrt + 3) "(mdcheck) Values metadata set duplicates";
      run;
      title%eval(&titlstrt + 3);
    %end;
    %if &debug %then %do;
      proc print data = _mccntlin  width=minimum;
        title%eval(&titlstrt + 3) "(mdcheck) _mccntlin data set";
      run;
      title%eval(&titlstrt + 3);
    %end;
    proc format cntlin=_mccntlin (drop=source_variable source_format)
     lib=work._mcformats
     %if &debug %then %do;
       fmtlib
     %end;
    ;
    run;
    %let fmtsearch = %sysfunc(getoption(fmtsearch));
    options fmtsearch = (work._mcformats work library);
    *--------------------------------------------------------------------------;
    * Create data set of columns that have formats and that exist;
    *--------------------------------------------------------------------------;
    proc sort data = _mccntlin (keep=fmtname)  out = _mcvalfmts  nodupkey;
      by fmtname;
    run;
    proc sort data = _mcmcolumns (keep=table column ctype cformat cformatflag
     where=(cformat ^= ' '))  out = _mccolfmts;
      by cformat;
    run;
    data _mccolumns_with_values;
      merge _mcvalfmts (in=fromval rename=(fmtname=cformat))
            _mccolfmts (in=fromcol)
            _mcmcpfmts (in=fromcpfmts keep=format formatsnm formatlnm
                        rename=(format=cformat))
       end=eof;
      by cformat;
      if fromval & fromcol;
      if fromcpfmts then do;
        if cformatflag = 3 then cformat = formatsnm;
        else if cformatflag = 4 then cformat = formatlnm;
      end;
    run;
    proc sort data = _mccolumns_with_values;
      by table column;
    run;
    data _mccolumns_with_values;
      set _mccolumns_with_values;
      by table;
      if first.table then _mcdsid = open("&inlib.." || trim(left(table)));
      if _mcdsid > 0 then do;
        _mcvarnum = varnum(_mcdsid,column);
        if _mcvarnum <= 0 then do;
          %ut_errmsg(msg="Variable defined in COLUMNS with valid values does "
           "not exist in &inlib.. " table= column=,type=note,macroname=mdcheck,
           log=0)
          column_exists = 0;
        end;
        else column_exists = 1;
      end;
      else do;
        if first.table then %ut_errmsg(msg="Cannot open &inlib.." table,
         type=note,macroname=mdcheck);
        column_exists = 0;
      end;
      if last.table & _mcdsid > 0 then _mcdsid = close(_mcdsid);
      if column_exists then output;
      retain _mcdsid;
    run;
    *--------------------------------------------------------------------------;
    * Create data set of paramrel columns that have formats and that exist;
    *--------------------------------------------------------------------------;
    proc sort data = _mcmcolumns_param (keep=table column param paramrel ptype
     pformat pformatflag where=(pformat ^= ' ' & paramrel ^= ' '))
     out = _mcparamfmts;
      by pformat;
    run;
    data _mcparams_with_values;
      merge _mcvalfmts   (in=fromval rename=(fmtname=pformat))
            _mcparamfmts (in=fromparam)
            _mcmcpfmts   (in=fromcpfmts keep=format formatsnm formatlnm
                          rename=(format=pformat))
       end=eof;
      by pformat;
      if fromval & fromparam;
      if fromcpfmts then do;
        if pformatflag = 3 then pformat = formatsnm;
        else if pformatflag = 4 then pformat = formatlnm;
      end;
    run;
    proc sort data = _mcparams_with_values;
      by table column paramrel;
    run;
    data _mcparams_with_values;
      set _mcparams_with_values;
      by table;
      if first.table then _mcdsid = open("&inlib.." || trim(left(table)));
      if _mcdsid > 0 then do;
        _mcvarnum = varnum(_mcdsid,column);
        if _mcvarnum <= 0 then do;
          %ut_errmsg(
           msg="Variable defined in columns_param with valid values does not"
           " exist in &inlib.. " table= column=,type=note,
           macroname=mdcheck,log=0)
          column_exists = 0;
        end;
        else column_exists = 1;
        _mcvarnum = varnum(_mcdsid,paramrel);
        if _mcvarnum <= 0 then do;
          %ut_errmsg(msg="PARAMREL Variable does not" " exist in &inlib.."
           table column= paramrel=,type=note,macroname=mdcheck,log=0)
          paramrel_exists = 0;
        end;
        else paramrel_exists = 1;
      end;
      else do;
        if first.table then
         %ut_errmsg(msg="Cannot open &inlib.." table,type=note,
         macroname=mdcheck);
        column_exists = 0;
        paramrel_exists = 0;
      end;
      if last.table & _mcdsid > 0 then _mcdsid = close(_mcdsid);
      if column_exists & paramrel_exists then output;
      retain _mcdsid;
    run;
    %do tablenum = 1 %to &numtables;
      *========================================================================;
      %bquote(*Checking data set variables for invalid values &&tab&tablenum;)
      *========================================================================;
      *------------------------------------------------------------------------;
      * Build array of columns with CFORMAT and VALUES entries;
      *  parallel arrays from COLUMNS:  COLUMN CFORMAT;
      *------------------------------------------------------------------------;
      %let numcolumns = 0;
      %let collen = 1;
      data _null_;
        if eof then do;
          if numcolumns > 0 then
           call symput('numcolumns',trim(left(put(numcolumns,7.0))));
          call symput('collen',trim(left(put(max(collen,1),5.0))));
        end;
        set _mccolumns_with_values (where = (table="&&tab&tablenum"))  end=eof;
        numcolumns + 1;

%* if type of variable is different that type in data then the put function
   will fail later with an error that type has already been set.  So, if ctype
   is not actual type then fix the put function and format name;

        call symput('col' || trim(left(put(numcolumns,7.0))),
         trim(left(column)));
        if ctype ^= 'C' then
         call symput('fmt' || trim(left(put(numcolumns,7.0))),
         trim(left(cformat)));
        else do;
          if cformat ^=: '$' then
           call symput('fmt' || trim(left(put(numcolumns,7.0))),
           '$' || trim(left(cformat)));
          else call symput('fmt' || trim(left(put(numcolumns,7.0))),
           trim(left(cformat)));
        end;
        collen + length(column) + 1;
      run;
      *------------------------------------------------------------------------;
      * Build array of parameter variables with PFORMAT and VALUES entries;
      *  parallel arrays from COLUMNS_PARAM:  COLUMN PARAM PARAMREL PFORMAT;
      *------------------------------------------------------------------------;
      %let numparamrels = 0;
      %let paramrellen = 1;
      data _null_;
        if eof then do;
          if numparamrels > 0 then
           call symput('numparamrels',trim(left(put(numparamrels,7.0))));
          call symput('paramrellen',trim(left(put(max(paramrellen,1),5.0))));
        end;
        set _mcparams_with_values (where = (table = "&&tab&tablenum"))  end=eof;
        numparamrels + 1;
        call symput('pcol' || trim(left(put(numparamrels,7.0))),
         trim(left(column)));
        call symput('param' || trim(left(put(numparamrels,7.0))),
         trim(left(param)));
        call symput('paramrel' || trim(left(put(numparamrels,7.0))),
         trim(left(paramrel)));
        if ptype ^= 'C' then call symput('pfmt' ||
         trim(left(put(numparamrels,7.0))),trim(left(pformat)));
        else do;
          if pformat ^=: '$' then
           call symput('pfmt' || trim(left(put(numparamrels,7.0))),
           '$' || trim(left(pformat)));
          else call symput('pfmt' || trim(left(put(numparamrels,7.0))),
           trim(left(pformat)));
        end;
        paramrellen + length(paramrel) + 1;
      run;
      %if &numcolumns > 0 | &numparamrels > 0 %then %do;
        *----------------------------------------------------------------------;
        * Read data set and use format lookup to determine if invalid values;
        *  exist - when formatted value of a variable = 0;
        *----------------------------------------------------------------------;
        %put UNOTE(mdcheck): numcolumns=&numcolumns numparamrels=&numparamrels;
        %let badobs = 0;
        %let total_obs = 0;
        data _mcbad_values (drop=_mcdata_set _mcvariable _mcparam _mcparam_rel)
             _mcbad_variables (keep=_mcdata_set _mcvariable)
             _mcbad_params (keep=_mcdata_set _mcvariable _mcparam _mcparam_rel)
          ;
          if eof then do;
            if _mcbad_obs > 0 then
             call symput('badobs',trim(left(put(_mcbad_obs,9.0))));
            if _mctotal_obs > 0 then
             call symput('total_obs',trim(left(put(_mctotal_obs,9.0))));
          end;
          set &inlib..&&tab&tablenum  end=eof;
          _mctotal_obs + 1;
          length bad_columns $ %eval(&collen + &paramrellen + 1)
           _mcdata_set _mcvariable _mcparam_rel _mcparam $ 32;
          _mcdata_set = "&&tab&tablenum";
          _mcerr_flag = 0;
          %do columnnum = 1 %to &numcolumns;
            if left(put(&&col&columnnum,&&fmt&columnnum...)) = '0' then do;
              _mcerr_flag = 1;
              bad_columns = trim(bad_columns) || " &&col&columnnum";
              _mcvariable = "&&col&columnnum";
              output _mcbad_variables;
            end;
            format &&col&columnnum;
          %end;
          _mcvariable = " ";
          _mcparam = " ";
          _mcparam_rel = " ";
          %do paramrelnum = 1 %to &numparamrels;
            if &&pcol&paramrelnum = "&&param&paramrelnum" & 
             left(put(&&paramrel&paramrelnum,&&pfmt&paramrelnum...)) = '0' then
             do;
              _mcerr_flag = 1;
              bad_columns = trim(bad_columns) || " &&paramrel&paramrelnum";
              _mcvariable = "&&pcol&paramrelnum";
              _mcparam = "&&param&paramrelnum";
              _mcparam_rel = "&&paramrel&paramrelnum";
              output _mcbad_params;
            end;
            format &&paramrel&paramrelnum;
          %end;
          if _mcerr_flag then do;
            _mcbad_obs + 1;
            output _mcbad_values;
          end;
          drop _mcerr_flag _mcbad_obs _mctotal_obs;
        run;
        title%eval(&titlstrt + 3)
         "(mdcheck) Observations with bad values found in &&tab&tablenum";
        %if &badobs > 0 %then %do;
          %if &print %then %do;
            %if &numcolumns > 0 %then %do;
              proc freq data = _mcbad_variables (where = (_mcvariable ^= ' '));
                table _mcvariable * _mcdata_set / norow nocol nopercent missing
                 out = _mcvar_freq
                 %if ^ &print %then %do;
                   noprint
                 %end;
                ;
                label _mcdata_set = 'Table'  _mcvariable = 'Column';
                title%eval(&titlstrt + 4) "(mdcheck) Number of observations"
                 " with values not in requirement - by variable";
              run;
              title%eval(&titlstrt + 4);
            %end;
            %if &numparamrels > 0 %then %do;
              proc freq data = _mcbad_params (where = (_mcparam_rel ^= ' '));
                table _mcdata_set * _mcvariable * _mcparam * _mcparam_rel /
                 norow nocol nopercent missing  out = _mcparam_freq
                 %if ^ &print %then %do;
                   noprint
                 %end;
                ;
                label _mcdata_set = 'Table'  _mcparam_rel = 'Parameter Column';
                title%eval(&titlstrt + 4) "(mdcheck) Number of observations"
                 " with values not in requirement - by parameter";
              run;
              title%eval(&titlstrt + 4);
            %end;
            %if &numcolumns > 0 %then %do;
              proc sort data = _mcbad_variables  out = _mcbadvars  nodupkey;
                by _mcvariable;
              run;
              %let number_bad_vars = 0;
              data _null_;
                if eof & number_bad_vars > 0 then call symput('number_bad_vars',
                 trim(left(put(number_bad_vars,6.0))));
                set _mcbadvars end=eof;
                number_bad_vars + 1;
                call symput('bad_var' || trim(left(put(number_bad_vars,6.0))),
                 trim(left(_mcvariable)));
              run;
              %if &number_bad_vars > 0 %then %do;
                %do bad_var_number = 1 %to &number_bad_vars;
                  proc freq data = _mcbad_values (where=(
                   indexw(upcase(bad_columns),"%upcase(&&bad_var&bad_var_number)"
                   ) > 0))
                  ;
                    table &&bad_var&bad_var_number /
                     norow nocol nopercent missing;
                    title%eval(&titlstrt + 4) "(mdcheck) Frequency of"
                     " disallowed variable values in &&tab&tablenum";
                   run;
                 %end;
                title%eval(&titlstrt + 4);
              %end;
            %end;
            %if &numparamrels > 0 %then %do;
              proc sort data = _mcbad_params  out = _mcbadparams  nodupkey;
                by _mcvariable _mcparam _mcparam_rel;
              run;
              %let number_bad_params = 0;
              data _null_;
                if eof & number_bad_params > 0 then
                 call symput('number_bad_params',
                 trim(left(put(number_bad_params,6.0))));
                set _mcbadparams end=eof;
                number_bad_params + 1;
                call symput('bad_variable' ||
                 trim(left(put(number_bad_params,6.0))),
                 trim(left(_mcvariable)));
                call symput('bad_param' ||
                 trim(left(put(number_bad_params,6.0))),trim(left(_mcparam)));
                call symput('bad_param_rel' ||
                 trim(left(put(number_bad_params,6.0))),
                 trim(left(_mcparam_rel)));
              run;
              %if &number_bad_params > 0 %then %do;
                %do bad_param_number = 1 %to &number_bad_params;

%* What if a parameter value is the same as a column name?
  Would overreport invalid values then in the following proc freq if that
  variable had an invalid value in an observation but the parameter did not;

                  proc freq data = _mcbad_values (where=(

                   indexw(upcase(bad_columns),
                   "%upcase(&&bad_param_rel&bad_param_number)") > 0

                    & upcase(&&bad_variable&bad_param_number) =
                    "%upcase(&&bad_param&bad_param_number)"));
                    table &&bad_variable&bad_param_number *
                     &&bad_param_rel&bad_param_number /
                     norow nocol nopercent missing;
                    title%eval(&titlstrt + 4) "(mdcheck) Frequency of"
                     " disallowed parameter values in &&tab&tablenum";
                   run;
                %end;
                title%eval(&titlstrt + 4);
              %end;
            %end;
            %if &maxobs > 0 %then %do;
              proc print data = _mcbad_values (obs=&maxobs)  width=minimum;
                title%eval(&titlstrt + 4) "(mdcheck) "
                 %if &badobs > &maxobs %then %do;
                   "First &maxobs observations out of &badobs"
                 %end;
                 %else %do;
                   "Observations with values not in requirement = &badobs"
                 %end;
                 " (total=&total_obs)";
              run;
              title%eval(&titlstrt + 4);
            %end;
          %end;    /* print is true */
          %if %bquote(&outlib) ^= %then %do;
            data _mcvalues_freq;
              length project $ 20  run_time 8 table column $ 32 count 8;
              format run_time datetime15.;
              project = "&project";
              run_time = input("&sysdate9:&systime",datetime15.);
              set 
              %if ^ &first_table %then %do;
                _mcvalues_freq
              %end;
               %if &numcolumns > 0 %then %do;
                 _mcvar_freq (rename = (_mcdata_set=table _mcvariable=column))
               %end;
               %if &numparamrels > 0 %then %do;
                 _mcparam_freq (rename=(_mcdata_set=table _mcparam_rel=column))
               %end;
              ;
              keep project run_time table column count;
            run;
            %let first_table = 0;
          %end;    /* outlib is not null */
        %end;      /* badobs > 0 */
        %else %ut_errmsg(msg="(mdcheck) No bad values found in
         &inlib..&&tab&tablenum",macroname=mdcheck,type=note);
        title%eval(&titlstrt + 3);
      %end;    /* numcolumns or numparamrels > 0 */
      %else %ut_errmsg(msg=Valid Values not defined for &&tab&tablenum,
       type=note,macroname=mdcheck);
    %end;    /* numtables iterative loop checking values */
    %if %bquote(&outlib) ^= & %sysfunc(exist(_mcvalues_freq)) %then %do;
      data &outlib..&outprefix.values_freq
       (label='Number of observations that contain disallowed values');
        set _mcvalues_freq;
      run;
    %end;
    %if %bquote(&fmtsearch) ^= %then %do;
      options fmtsearch=&fmtsearch;
    %end;
    %else %do;
      options fmtsearch=(work library);
    %end;
  %end;  /* hasvalues loop */
  %else %put UWARNING:(mdcheck) No values defined in &mdlib..&mdprefix.values;
  %do tablenum = 1 %to &numtables;
    *==========================================================================;
    %bquote(*Checking data set primary keys for uniqueness &&tab&tablenum;)
    *==========================================================================;
    %let numdups = 0;
    %let numkeys = 0;
    data _null_;
      set _mcmcolumns (where = (upcase(table) = "%upcase(&&tab&tablenum)"
       & cpkey > 0)) end=eof;
      by table;
      if _n_ = 1 then _mcdsid = open("&inlib.." || trim(left(table)));
      if _mcdsid > 0 then do;
        _mcvarnum = varnum(_mcdsid,column);
        if _mcvarnum <= 0 then do;
          %ut_errmsg(msg="Primary key variable does "
           "not exist in &inlib..&&tab&tablenum " column= cpkey=,type=note,
           macroname=mdcheck)
          return;
        end;
      end;
      else do;
        if _n_ = 1 then
         %ut_errmsg(msg="Cannot open &inlib..&&tab&tablenum",type=note,
         macroname=mdcheck);
        return;
      end;
      if eof & _mcdsid > 0 then _mcdsid = close(_mcdsid);
      _mccpkey + 1;
      call symput('cpkey' || trim(left(put(_mccpkey,6.0))),left(column));
      call symput('numkeys',trim(left(put(_mccpkey,6.0))));
      retain _mcdsid;
    run;
    %if &numkeys > 0 %then %do;
      proc sort data = &inlib..&&tab&tablenum  out = _mcurtable;
        by
         %do keynum = 1 %to &numkeys;
           &&cpkey&keynum
         %end;
        ;
      run;
      data _mcduplicates;
        if eof & _mcnumdups > 0 then
         call symput('numdups',trim(left(put(_mcnumdups,6.0))));
        set _mcurtable end=eof;
        by
         %do keynum = 1 %to &numkeys;
           &&cpkey&keynum
         %end;
        ;
        if first.&&cpkey&numkeys + last.&&cpkey&numkeys ^= 2;
        keep
         %do keynum = 1 %to &numkeys;
           &&cpkey&keynum
         %end;
        ;
        _mcnumdups + 1;
      run;
      proc datasets lib=work nolist;
        delete _mcurtable;
      run; quit;
      proc print data = _mcduplicates (obs=&maxobs)  width=minimum;
        title%eval(&titlstrt + 3)
         "(mdcheck) Duplicate Observations found in &&tab&tablenum";
        %if &numdups > &maxobs %then %do;
          title%eval(&titlstrt + 4)
           "(mdcheck) First &maxobs observations out of &numdups";
        %end;
      run;
      title%eval(&titlstrt + 3);
      %do keynum = 1 %to &numkeys;
        %let &&cpkey&keynum =;
      %end;
    %end;
    %else %ut_errmsg(msg="No primary keys defined in metadata for "
     "&&tab&tablenum",macroname=mdcheck,type=note);
  %end;    /* numtables iterative loop checking primary key uniqueness */
%end;      /* numtables > 0 loop */
%else %put UWARNING:(mdcheck) No data sets defined in &mdlib..&mdprefix.tables;
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of mdcheck macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _mc:;
    %if %sysfunc(cexist(work._mcformats)) %then %do;
      delete _mc: / memtype=catalog;
    %end;
  run; quit;
%end;
title&titlstrt;
%mend;
