%macro mdbuild(inlib=_default_,mdlib=_default_,contents=_default_,
 outprefix=_default_,where=_default_,fmtcats=_default_,flabeltype=_default_,
 mkcat=_default_,fmtcntlout=_default_,verbose=_default_,debug=_default_);
  /*soh************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdbuild
TYPE                     : metadata
DESCRIPTION              : Builds metadata sets from an existing library of
                            SAS members (data sets,views and format catalogs)
                            or from a proc contents data set.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\mdbuild\mdbuild DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt ut_marray mdmake
                           ut_errmsg
INPUT                    : as defined by the parameters INLIB and MDLIB
OUTPUT                   : as defined by the parameter OUTLIB
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _mb
--------------------------------------------------------------------------------
Parameters:
Name      Type     Default  Description and Valid Values
--------- -------- -------- -------------------------------------------------
INLIB      optional          Libref of input library that you want to 
                              describe in metadata.  INLIB or CONTENTS must
                              be specified in the call to this macro.
MDLIB      required work     Libref of output library the metadata is to be
                              written to
FMTCATS    optional fmtsearch Blank delimited list of 2-level format catalog
                              names to derive valid values from.  Librefs
                              can also be included in the list, in which case
                              a catalog name of FORMATS is assumed.  Default 
                              is FMTSEARCH indicating that the current
                              definition of catalogs in the FMTSEARCH option 
                              is to be used.  FMTCATS or FMTCNTLOUT must be
                              specified in the call to this macro.
FLABELTYPE required flabel   The type of the label recorded in the format
                              catalog or FMTCNTLOUT data set.  This
                              determines whether the VALUES data set 
                              FLABEL or FLABELLONG will be populated.  Valid
                              values of FLABELTYPE are FLABEL and FLABELLONG.
                              If FLABELTYPE = FLABEL but the actual format
                              label length is greater than 100 then the 
                              FLABELLONG variable will be populated instead
                              of FLABEL.
FMTCNTLOUT optional          Name of a proc format cntlout data set 
                              describing formats.  This is used instead of
                              FMTCATS if you have the cntlout data set but do
                              not have access to the actual format catalogs.
                              The FMTCNTLOUT data set is assumed to include
                              the variables fmtname, type, start, end and
                              label,as defined by the PROC FORMAT cntlout
                              data set.
CONTENTS  optional           Name of a proc contents output data set 
                              describing a library.  This is used instead of
                              INLIB if you have the contents data set but do
                              not have access to the actual library INLIB. 
                              The CONTENTS data set is assumed to include
                              the variables memname memlabel memtype name
                              label type length format varnum, as defined
                              by the PROC CONTENTS output data set.
OUTPREFIX optional           Prefix to add to the metadata set names created
                              in the MDLIB library
WHERE     optional           A where clause to be applied to the contents
                              data set (created from INLIB or passed with
                              the parameter CONTENTS).  This allows you to 
                              select certain data sets or variables in INLIB 
                              to describe in MDLIB.  e.g. 
                              memname in ('CC603' 'DM502')
MKCAT    required 0          %ut_logical value specifying whether catalog 
                              entries should be created for each variable
VERBOSE  required 1          %ut_logical value specifying whether verbose
                              mode is on or off
DEBUG    required 0          %ut_logical value specifying whether debug mode
                              is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

  MDBUILD can be used when you need to create requirements for a database you
  need to build and there is another database similar to it.  MDBUILD can do
  much of the work for you by creating a metadatabase of the old database that 
  can be modified to describe the new data requirements.

  MDBUILD can also be used to document a database.  Run MDBUILD on the database
  and then run MDPRINT on that metadatabase.  This generates a very useful 
  description of the database that is superior to PROC CONTENTS in many ways, 
  including a list of valid values (derived from the format catalog) for 
  variables that have user-defined formats associated with them.

  MDBUILD can create metadata on any database you can do a LIBNAME too,
  including oracle tables.

  If you do not have access to the database, use a CONTENTS and FMTCNTLOUT
  parameters instead of INLIB and FMTCATS.  For example, if you need metadata
  of a study you do not have access to because of data privacy issues, request
  someone who does have read access to run PROC CONTENTS and PROC FORMAT on
  the study and give you the output data sets from those procs.  These can be
  used as input to MDBUILD and does not violate and data privacy rules because
  you do not need access to any clinical data content.

  MDBUILD cannot populate all metadata content, but it can do alot of them and
  save a great deal of time to create a metadata description of a SAS library.
  TABLES : table tlabel type
  COLUMNS: table column ctype clength cformat clabel corder clabellong 
           cpkey (partial)
  COLUMNS_PARAM: none
  VALUES : format start end flabel flabellong (when format catalog is supplied)
--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

    %mdbuild(inlib=r,mdlib=work);

--------------------------------------------------------------------------------
      Author &
Ver#   Peer Reviewer   Request #        Broad-Use MODULE History Description
----  ---------------- ---------------- ------------------------------------
1.0   Gregory Steffens BMRGCS18MAY2005A Original version of the broad-use
        Srinivasa Gudipati               module 18 May 2005
2.0   Gregory Steffens BMRKW26JAN2006B  January 2006
        Vijay Sharma                    Added format width and decimal
                                         from contents data set into
                                         CFORMAT.  One result of this is
                                         that DATE is not assumed to be
                                         DATE9.
                                        Made deletion of catalog at end of
                                         macro conditional on _mbfmtcats
                                         catalog actually existing.
2.1   Gregory Steffens BMR21Feb2007C    SAS version 9 migration
       Michael Fredericksen
3.0   Gregory Steffens                  If FORMAT of proc contents output data
                                         set is F then set to missing.  This 
                                         is to address problem where w.d formats
                                         are reported as Fw.d.
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(inlib,_pdrequired=0,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(mdlib,work,_pdrequired=1,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(fmtcats,fmtsearch,_pdrequired=0,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(flabeltype,flabel,flabel FLABEL flabellong FLABELLONG,_pdrequired=0,
 _pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(contents,_pdrequired=0,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(fmtcntlout,_pdrequired=0,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(outprefix,_pdrequired=0,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(where,_pdrequired=0,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(mkcat,0,_pdrequired=1,_pdmacroname=mdbuild,_pdverbose=1)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdbuild,_pdverbose=1)
%ut_logical(verbose)
%ut_logical(mkcat)
%ut_logical(debug)
%if &debug %then %let verbose = 1;
%local titlstrt fcataray numcats numcatalogs catnum new;
%ut_titlstrt
title&titlstrt "(mdbuild) Creating metadata in &mdlib from &inlib.&contents "
 "and &fmtcats.&fmtcntlout";
%if %bquote(&inlib) ^= & %bquote(&contents) ^= %then
 %ut_errmsg(msg="INLIB and CONTENTS parameters were specified - "
 "using CONTENTS and ignoring INLIB",macroname=mdbuild,type=note);
%if %bquote(&contents) = %then %do;
  %if %bquote(&inlib) ^= %then %do;
    *--------------------------------------------------------------------------;
    * Execute PROC CONTENTS on INLIB when a contents data set is not passed in;
    *--------------------------------------------------------------------------;
    proc contents data = &inlib.._all_ out = _mbcontents  noprint;
    run;
    * sql is required in case there are data sets with 0 variables;
    proc sql;
      create table _mbtablesdict as select memname, memlabel, memtype
       from dictionary.tables 
       where libname = "%upcase(&inlib)";
    quit;
    data _mbcontents;
      merge _mbcontents _mbtablesdict;
      by memname;
    run;
    %let contents = _mbcontents;
  %end;
  %else %ut_errmsg(msg="INLIB and CONTENTS are both missing "
   "TABLE and COLUMNS will not be populated",macroname=mdbuild,type=note);
%end;
%if %bquote(&contents) ^= & %sysfunc(exist(&contents)) %then %do;
  *============================================================================;
  * Create TABLES and COLUMNS metadata sets from PROC CONTENTS data set;
  *============================================================================;
  data _mbcontents;
    set &contents;
    memname = upcase(memname);
    name = upcase(name);
    format = upcase(format);
  run;
  proc sort data = _mbcontents
   %if %bquote(&where) ^= %then %do;
     (where = (&where))
   %end;
   out = _mbcontents;
    by memname name;
  run;
  data _mbtables (keep=table tlabel ttype rename=(ttype=type))
       _mbcolumns (keep = table column ctype clength cformat clabel corder 
                   cpkey clabellong);
    set _mbcontents (keep = memname memlabel memtype name label type length
                     format formatl formatd varnum);
    by memname;
    length ctype $ 1 cpkey 8 clabel $ 40 clabellong $ 100 ttype $ 5 cformat $ 13;
    clabel = label;
    if length(label) > 40 then clabellong = label;
    if type = 1 then ctype = 'N';
    else if type = 2 then ctype = 'C';
    cformat = format;
    if cformat ^= '$' then do;
      if upcase(cformat) = 'F' then cformat = ' ';
      if formatl > 0 then
       cformat = trim(left(cformat)) || trim(left(put(formatl,6.0)));
      if formatd > 0 then cformat = trim(left(cformat)) || '.' ||
       trim(left(put(formatd,6.0)));
    end;
    else cformat = ' ';
    if cformat =: '$' then do;
      if type ^= 2 then %ut_errmsg(msg='type and format name inconsistent ' 
       memname= name= type= cformat= format=,type=warning,macroname=mdbuild);
      if cformat ^= '$' then cformat = substr(cformat,2);
    end;
    if name = 'RESPROJ' then cpkey = 1;
    else if name = 'FACILITY' then cpkey = 2;
    else if name = 'SDYID' then cpkey = 3;
    else if name = 'INVID' then cpkey = 4;
    else if name = 'SUBJID' then cpkey = 5;
    else if name = 'VISID' then cpkey = 6;
    if memtype = 'DATA' then ttype = 'TABLE';
    else if memtype = 'VIEW' then ttype = 'VIEW';
    if first.memname then output _mbtables;
    output _mbcolumns;
    rename memname = table  memlabel = tlabel  name = column  length = clength
     varnum = corder;
  run;
%end;
*==============================================================================;
* Read format catalog(s) to create VALUES metadata set;
*==============================================================================;
%if %bquote(&fmtcntlout) = & %bquote(&fmtcats) ^= %then %do;
  %if %bquote(%upcase(&fmtcats)) = FMTSEARCH %then %do;
    %let fmtcats = %sysfunc(compress(%sysfunc(getoption(fmtsearch)),%str(())));
    %if &debug %then %ut_errmsg(msg=fmtcats=&fmtcats,macroname=mdbuild,
     type=note,print=0);
  %end;
  %ut_marray(invar=fmtcats,outvar=fmt,outnum=numcats,varlist=fcataray);
  %local &fcataray;
  %ut_marray(invar=fmtcats,outvar=fmt,outnum=numcats)
  %ut_errmsg(msg=numcats=&numcats fmtcats=&fmtcats,type=note,print=0,
   macroname=mdbuild)
  %let numcatalogs = &numcats;
  %if &numcats > 0 %then %do catnum = 1 %to &numcats;
    %ut_errmsg(msg=&catnum fmt&catnum=&&fmt&catnum,macroname=mdbuild,type=note,
     print=0)
    %if %bquote(%scan(&&fmt&catnum,2,%str(.))) = %then
     %let fmt&catnum = &&fmt&catnum...formats;
    %if ^ %sysfunc(cexist(&&fmt&catnum)) %then %do;
      %if %bquote(&fmtcntlout) = &
       %bquote(%upcase(&&fmt&catnum)) ^= WORK.FORMATS &
       %bquote(%upcase(&&fmt&catnum)) ^= LIBRARY.FORMATS %then %do;
        %ut_errmsg(msg=numcatalogs=&numcatalogs,type=note,macroname=mdbuild,
         print=0)
        %ut_errmsg(msg="Format catalog does not exist &&fmt&catnum",
         type=warning,macroname=mdbuild)
      %end;
      %let numcatalogs = %eval(&numcatalogs - 1);
      %if %bquote(&fmtcntlout) = &
       %bquote(%upcase(&&fmt&catnum)) ^= WORK.FORMATS &
       %bquote(%upcase(&&fmt&catnum)) ^= LIBRARY.FORMATS %then %do;
        %ut_errmsg(msg=numcatalogs=&numcatalogs,type=note,macroname=mdbuild,
         print=0)
      %end;
    %end;
  %end;
  %if &numcatalogs > 0 %then %do;
    %let new = new;
    proc catalog;
      %do catnum = &numcats %to 1 %by -1;
        %if %sysfunc(cexist(&&fmt&catnum)) %then %do;
          copy in = &&fmt&catnum  out = _mbfmtcats  &new;
          run;
          %let new =;
        %end;
        %else %ut_errmsg(msg=format catalog does not exist - &&fmt&catnum,
         type=note,macroname=mdbuild,print=0);
      %end;
    quit;
    proc format lib = work._mbfmtcats  cntlout = _mbfmtcats;
    run;
    data _mbfmtcats;
      set _mbfmtcats;
      fmtname = upcase(fmtname);
      start = left(start);
      end = left(end);
    run;
    proc sort data = _mbfmtcats;
      by fmtname type;
    run;
  %end;
  %else %ut_errmsg(msg='No format catalogs exist',type=note,
   macroname=mdbuild);
%end;
%else %if %bquote(&fmtcntlout) ^= %then %do;
  %if %bquote(&fmtcats) ^= %then
   %ut_errmsg(msg=FMTCNTLOUT and FMTCATS have been specified - using FMTCNTLOUT
   &fmtcntlout,macroname=mdbuild,type=note,print=0);
  data _mbfmtcats;
    set &fmtcntlout;
    fmtname = upcase(fmtname);
  run;
  proc sort data = _mbfmtcats;
    by fmtname type;
  run;
%end;
%else %ut_errmsg(msg='No format catalogs specified so no valid values defined',
 macroname=mdbuild,type=note,print=0);
%if %sysfunc(exist(work._mbfmtcats)) %then %do;
  %if %sysfunc(exist(work._mbcolumns)) %then %do;
    data _mbfmtsindata;
      set _mbcolumns (keep = cformat ctype where = (cformat ^= ' '));
      length fmtname $ 13 type $ 1;
      fmtname = upcase(cformat);
      type = upcase(ctype);
      keep fmtname type;
    run;
    proc sort data = _mbfmtsindata nodupkey;
      by fmtname type;
    run;
    data _mbvalues
         _mbnofmt  (keep = format type)
         _mbnodata (keep = format type);
      merge _mbfmtsindata (in=fromdata)
            _mbfmtcats (in=fromfmtcats  keep = fmtname type start end label);
      by fmtname type;
      if first.type then do;
        if ^ fromfmtcats & fmtname ^ in ('DATE' 'DATETIME' 'DATE9') then
         output _mbnofmt;
        else if ^ fromdata then output _mbnodata;
      end;
      if fromdata & fromfmtcats;
      length flabel $ 100 flabellong $ 400;
      %if %bquote(%upcase(&flabeltype)) = FLABELLONG %then %do;
        flabel = ' ';
        flabellong = label;
      %end;
      %else %do;
        if length(label) <= 100 then flabel = label;
        else flabellong = label;
      %end;
      output _mbvalues;
      rename fmtname = format;
    run;
    %if &verbose %then %do;
      proc print data = _mbnofmt;
        title%eval(&titlstrt + 1) "(mdbuild): Formats defined in data not"
         " found in format catalogs";
      run;
      proc print data = _mbnodata;
        title%eval(&titlstrt + 1)
         "(mdbuild) Formats defined in format catalogs not used in data";
      run;
      title%eval(&titlstrt + 1);
    %end;
  %end;
  %else %do;
    data _mbvalues;
      set _mbfmtcats (in=fromfmtcats  keep = fmtname type start end label);
      length flabel $ 100 flabellong $ 400;
      %if %bquote(%upcase(&flabeltype)) = FLABELLONG %then %do;
        flabel = ' ';
        flabellong = label;
      %end;
      %else %do;
        if length(label) <= 100 then flabel = label;
        else flabellong = label;
      %end;
      rename fmtname=format;
    run;
  %end;
%end;

%* add code to update cformatflag in columns;

*==============================================================================;
* Call the mdmake macro to standardize the metadata sets and write to MDLIB;
*==============================================================================;
%mdmake(inlib=work,inprefix=_mb,outlib=&mdlib,outprefix=&outprefix,contents=0,
 mode=replace,mkcat=&mkcat,verbose=&verbose,debug=&debug)
*==============================================================================;
* Cleanup at end of mdbuild macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _mb:;
    %if %sysfunc(cexist(_mbfmtcats)) %then %do;
      delete _mb: / mt=catalog;
    %end;
  run; quit;
%end;
title&titlstrt;
%mend;
