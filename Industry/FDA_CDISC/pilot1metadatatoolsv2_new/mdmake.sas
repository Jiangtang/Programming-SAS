%macro mdmake(outlib=_default_,ic=_default_,audit=_default_,contents=_default_,
 mode=_default_,inlib=_default_,inprefix=_default_,outprefix=_default_,
 inselect=_default_,inexclude=_default_,outselect=_default_,
 outexclude=_default_,verbose=_default_,addparam=_default_,
 alterpswd=_default_,mkcat=_default_,addheader=_default_,
 keepall=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdmake
TYPE                     : metadata
DESCRIPTION              : Create standard meta data sets, optionally
                            reading existing metadata from an input and/or
                            output library.  Mdmake can copy all or part of a
                            metadatabase from one location to another and it
                            can combine all or part of two metadatabases.
REQUIREMENTS             : https://sddchippewa.sas.com/webdav/lillyce/qa/general/
                            bums/mdmoddt/documentation/mdmake_rd.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS, SDD
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt ut_quote_token
                           ut_errmsg
INPUT                    : As defined by parameters INLIB
OUTPUT                   : As defined by parameters OUTLIB
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _mm
--------------------------------------------------------------------------------
Parameters:
Name     Type     Default  Description and Valid Values
--------- -------- -------- --------------------------------------------------
OUTLIB    required work     Libref of output library to write new meta data
                             sets to.  If OUTLIB already contains meta data
                             sets then that meta data can be included and the
                             meta data sets made standard - see MODE
                             parameter.
INLIB     optional          Libref of input library that contains meta data
                             sets.  These can be combined with data sets
                             that exist in OUTLIB.  If no OUTLIB meta data
                             sets exist then INLIB is copied to OUTLIB.  In
                             either case the meta data sets are standardized
                             - standard names, labels, types, lengths, etc.
                             If INLIB does not exist then 0-observations
                             metadata sets are created in OUTLIB.
MODE       required merge   Mode of meta data set processing - replace,
                             append or merge (must be low case).
                             If the metadata set exists in OUTLIB and
                              metadata exists in INLIB then:
                              If mode is "append" the metadata in INLIB is
                               appended to metadata in OUTLIB.
                              If mode is "replace" the meta data sets in
                               OUTLIB are replaced with the metadata in INLIB
                              If mode is "merge" the meta data sets in
                               OUTLIB are updated by metadata in INLIB.
                             If the metadata set exists in OUTLIB but not in
                              INLIB then:
                              If mode is "append" the metadata in OUTLIB is
                               standardized and the content of the metadata
                               is kept.
                              If mode is "replace" the meta data sets in
                               OUTLIB are standardized and emptied of all 
                               observations.
                              If mode is "merge" the meta data sets in
                               OUTLIB are standardized and the content of
                               the metadata is kept.
                             If the metadata set exists in INLIB but not in
                              OUTLIB then:
                              If mode is "append" the metadata in INLIB is
                               standardized and the content of the metadata
                               is kept.
                              If mode is "replace" the meta data sets in
                               INLIB are standardized and copied to OUTLIB.
                              If mode is "merge" the meta data sets in
                               INLIB are standardized and the content of
                               the metadata is kept.
INPREFIX  optional          A prefix to the names of the data sets and
                             catalog that are read from INLIB
OUTPREFIX optional          A prefix to the names of the data sets and
                             catalog that are created in OUTLIB
MKCAT     required 0        Logical value specifying whether to create
                             a catalog entry in DESCRIPTIONS for each column
                             and each param in COLUMNS_PARAM
                             If MODE is not REPLACE and INLIB or OUTLIB is
                             specified then the INLIB and/or OUTLIB entries
                             will be used.  Otherwise the catalog entries
                             will contain only the template information.
IC        required 0        Logical value specifying whether to define
                             integrity constraints
AUDIT     required 0        Logical value specifying whether to initialize
                             an audit trail
ALTERPSWD optional          The SAS data set option ALTERPSWD - this is
                             recommended when AUDIT is true
CONTENTS  required 1        Logical value specifying whether to run PROC
                             CONTENTS on the meta data sets
INSELECT  optional          Blank delimited list of table names defined in
                             the metadata that you want to limit processing
                             to.  The INLIB metadata will be subsetted
                             by these table names.  A null value specifies
                             to select all tables (c.f. INEXCLUDE)
INEXCLUDE optional          Blank delimited list of table names defined in
                             the metadata that you want to exclude from
                             processing.  The INLIB metadata will be
                             subsetted by these table names.  A null value
                             specifies to exclude no tables (c.f. INSELECT)
OUTSELECT optional          Blank delimited list of table names defined in
                             the metadata that you want to limit processing
                             to.  The OUTLIB metadata will be subsetted
                             by these table names.  A null value specifies
                             to select all tables (c.f. INEXCLUDE)
OUTEXCLUDE optional         Blank delimited list of table names defined in
                             the metadata that you want to exclude from
                             processing.  The OUTLIB metadata will be
                             subsetted by these table names.  A null value
                             specifies to exclude no tables (c.f. INSELECT)
VERBOSE   required 1        %ut_logical value specifying whether verbose
                             mode is on or off.
ADDPARAM  required 0        %ut_logical value specifying whether to add meta
                             data information for parmameter information
                             A flag is added to COLUMNS if the column is
                             a parameter defined in COLUMNS_PARAM.  Flag
                             variables added are: CPARAMFL CPARAMREL_MISS and
                             CPARAMRELFL.
                             The values defined in COLUMNS_PARAM are added to
                             VALUES for the corresponding column.  Typically
                             ADDPARAM should be false when calling mdmake to
                             store permanent metadata and should be true
                             when calling mdmake to access metadata for
                             use in the work library to use the metadata
                             for printing, checking, etc.
ADDHEADER required 0        ut_logical value specifying whether to add header
                             variables to data sets defined in COLUMNS. 
                             ADDHEADER should be false when calling mdmake to
                             store permanent metadata and should be true
                             when calling mdmake to access metadata for
                             use in the work library to use the metadata
                             for printing, checking, etc.
KEEPALL   required 0        %ut_logical value specifying whether to keep all the
                             metavariables in the metadata sets or to keep only
                             the standard metavariables.
DEBUG     required 0        %ut_logical value specifying whether debug mode
                              is on or off
--------------------------------------------------------------------------------
Usage Notes:

--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

--------------------------------------------------------------------------------
      Author &
Ver#  Peer Reviewer    Request #         Broad-Use MODULE History Description
----  ---------------- ---------------   ---------------------------------------
1.0   Greg Steffens    BMRGCS02APR2005A  Original version of the broad-use
       Srinivase Gudapati                 module
2.0   Greg Steffens    BMRKW27FEB2006A   Added TSHORT variable to the TABLES
       Vijay Sharma                       metadata set
                                         Clarified header comment about mode
                                          replace
                                         Initialize HEADERFLAG macro variable
                                          to 0 prior to the data step that
                                          assigns it a value.
                                         Changed p/c formatflag to allow
                                          . 1 2 3 4 in the integrity checks
                                          and redefined the variable label
                                          for p/c formatflag to list the new
                                          meanings of p/cformatflag.
                                         When ADDPARAM is true the formatflag
                                          variable is set to 2 instead of 3
                                          to conform to the new meanings of
                                          formatflag.
2.1   Gregory Steffens BMRKW21FEB2007B SAS version 9 migration
       Michael Fredericksen
3.0   Gregory Steffens BMRGCS30OCT2007   Added checks for duplicates
       Russ Newhouse                     Added report of overlays when MODE
                                          is MERGE - matching observations
                                         Added KEEPALL parameter
                                         Added referential integrity checks
                                          of INLIB and OUTLIB metadata when
                                          VERBOSE is true
                                         Strip format and informat from 
                                          character variables in the output
                                          metadata sets.  This fixes problems
                                          with the input data sets that have
                                          a format that is shorter than the
                                          metavariable length and truncation
                                          of start when mdprint uses the
                                          addparams parameter.
                                         Resolved version 8 SAS bug where
                                          there is a limit of the length of
                                          the select statement in PROC 
                                          CATALOG of about 32k.  The macro
                                          now decides if a select exclude or
                                          no subsetting statement is required,
                                          and selects the shortest one.
                                         Do not use param name as a default
                                          catalog entry name since param is
                                          not required to be a valid SAS name.
                                         Added check that INLIB and OUTLIB exist
                                         Deleted UWARNING that PARAM must be a 
                                          valid SAS name when PARAM contains an
                                          embedded blank.
                                         Fixed bug when mode is merge so that
                                          inlib descriptions overwrite outlib
                                          descriptions instead of outlib
                                          overwriting inlib.
                                         Changed %put statement that catalogs
                                          do not exist to a call to ut_errmsg
                                         Changed symput function calls to use 
                                          format of 32.0 instead of 4.0 or 6.0
                                          to increase the maximum number of
                                          catalog entries, formats, length, etc.
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization - process parameters, call ut_logical, declare local
%*  variables get starting title line;
%*=============================================================================;
%ut_parmdef(verbose,1,_pdmacroname=mdmake,_pdrequired=1)
%ut_logical(verbose)
%ut_parmdef(outlib,work,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(ic,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(audit,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(contents,1,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(mode,merge,replace append merge,_pdmacroname=mdmake,_pdrequired=1,
 _pdverbose=&verbose)
%ut_parmdef(inlib,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(inprefix,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(outprefix,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(inselect,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(inexclude,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(outselect,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(outexclude,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(addparam,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(addheader,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(alterpswd,_pdmacroname=mdmake,_pdverbose=&verbose)
%ut_parmdef(mkcat,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(keepall,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_parmdef(debug,0,_pdmacroname=mdmake,_pdrequired=1,_pdverbose=&verbose)
%ut_logical(ic)
%ut_logical(audit)
%ut_logical(contents)
%ut_logical(addparam)
%ut_logical(addheader)
%ut_logical(mkcat)
%ut_logical(keepall)
%ut_logical(debug)
%if &debug %then %ut_errmsg(msg=macro starting,macroname=mdmake,print=0,
 debug=&debug);
%local inselectq inexcludeq outselectq outexcludeq exist i mdsn param pc parcol
 alterpswdp numcols mprint notes maxlen headerflag titlstrt headersource
 headersourcet incondition outcondition numents entnum checklib checkprefix
 tables_exist columns_exist columns_param_exist values_exist subset_type;
%if %bquote(&alterpswd) ^= %then %do;
  %let alterpswd  = alter = &alterpswd;
  %let alterpswdp = (&alterpswd);
%end;
%ut_quote_token(inmvar=inselect,outmvar=inselectq)
%let inselectq = %upcase(&inselectq);
%ut_quote_token(inmvar=inexclude,outmvar=inexcludeq)
%let inexcludeq = %upcase(&inexcludeq);
%ut_quote_token(inmvar=outselect,outmvar=outselectq)
%let outselectq = %upcase(&outselectq);
%ut_quote_token(inmvar=outexclude,outmvar=outexcludeq)
%let outexcludeq = %upcase(&outexcludeq);
%ut_titlstrt
%if %bquote(%upcase(&inlib)) = %bquote(%upcase(&outlib)) &
 %bquote(%upcase(&inprefix)) = %bquote(%upcase(&outprefix)) %then %do;
  %ut_errmsg(msg=inlib and outlib are the same - resetting inlib to null,
   macroname=mdmake,print=0,debug=&debug)
  %let inlib =;
%end;
%if %bquote(&inlib) ^= %then %do;
  %if %sysfunc(libref(&inlib)) ^= 0 %then %do;
    %ut_errmsg(msg="libref &inlib does not " "exist",type=error,
     macroname=mdmake,debug=&debug);
    %let inlib =;
  %end;
%end;
%if %bquote(&outlib) ^= %then %do;
  %if %sysfunc(libref(&outlib)) ^= 0 %then %do;
    %ut_errmsg(msg="libref &outlib does not " "exist",type=error,
     macroname=mdmake,debug=&debug);
    %let inlib =;
  %end;
%end;
%if %bquote(&inlib) ^= %then %do;
  title&titlstrt "(mdmake) Creating metadata from &inlib to &outlib mode=&mode";
%end;
%else %do;
  title&titlstrt "(mdmake) Creating metadata in &outlib mode=&mode";
%end;
%*=============================================================================;
%* Assign INLIB table subset condition clause into macro variable INCONDITION;
%*=============================================================================;
%if %bquote(&inselectq) ^= %then %do;
  %let incondition = upcase(table) in (&inselectq);
%end;
%if %bquote(&inexcludeq) ^= %then %do;
  %if %bquote(&inselectq) ^= %then %do;
    %let incondition = &incondition &;
  %end;
  %let incondition = &incondition upcase(table) ^ in (&inexcludeq);
%end;
%*=============================================================================;
%* Assign OUTLIB table subset condition clause into macro variable OUTCONDITION;
%*=============================================================================;
%if %bquote(&outselectq) ^= %then %do;
  %let outcondition = upcase(table) in (&outselectq);
%end;
%if %bquote(&outexcludeq) ^= %then %do;
  %if %bquote(&outselectq) ^= %then %do;
    %let outcondition = &outcondition &;
  %end;
  %let outcondition = &outcondition upcase(table) ^ in (&outexcludeq);
%end;
%if &debug %then 
 %ut_errmsg(msg=debug: incondition=&incondition outcondition=&outcondition,
  macroname=mdmake,print=0,debug=&debug);
*==============================================================================;
* Create tables meta data set;
*==============================================================================;
%let exist = 0;
%if %sysfunc(exist(&inlib..&inprefix.tables)) %then %do;
  data _mmtablesadd;
    set &inlib..&inprefix.tables
     %if %bquote(&inselectq) ^= | %bquote(&inexcludeq) ^= %then %do;
       %str( (where = ( &incondition )) )
     %end;
    ;
    table = upcase(table);
  run;
  proc sort data = _mmtablesadd;
    by table;
  run;
  %if &verbose %then %do;
    data _mmtablesduplicates;
      set _mmtablesadd (keep=table tlabel);
      by table;
      if first.table + last.table ^= 2;
    run;
    proc print data = _mmtablesduplicates width=minimum;
      title%eval(&titlstrt + 1)
       "(mdmake) Duplicate Definitions in &inlib..&inprefix.tables";
    run;
    title%eval(&titlstrt + 1);
  %end;
  %let exist = 1;
%end;
%if %bquote(%upcase(&mode)) ^= REPLACE &
 %sysfunc(exist(&outlib..&outprefix.tables)) %then %do;
  data _mmtablesold;
    set &outlib..&outprefix.tables
     %if %bquote(&outselectq) ^= | %bquote(&outexcludeq) ^= %then %do;
       (where = ( &outcondition ))
     %end;
    ;
    table = upcase(table);
  run;
  proc sort data = _mmtablesold    out = 
   %if &exist %then %do;
     _mmtablesold
   %end;
   %else %do;
     _mmtablesadd
   %end;
  ;
    by table;
  run;
  %if &exist %then %do;
    %if &verbose %then %do;
      data _mmtablesduplicates;
        set _mmtablesold (keep=table tlabel);
        by table;
        if first.table + last.table ^= 2;
      run;
      proc print data = _mmtablesduplicates width=minimum;
        title%eval(&titlstrt + 1)
         "(mdmake) Duplicate Definitions in &outlib..&outprefix.tables";
      run;
      title%eval(&titlstrt + 1);
    %end;
    data _mmtablesadd  _mmtables_overlay (keep=table);
      %if %bquote(%upcase(&mode)) = APPEND %then %do;
        set _mmtablesold  _mmtablesadd;
        by table;
      %end;
      %else %if %bquote(%upcase(&mode)) = MERGE %then %do;
        merge _mmtablesold (in=fromold)  _mmtablesadd (in=fromadd);
        by table;
        if fromold & fromadd then output _mmtables_overlay;
      %end;
      output _mmtablesadd;
    run;
    %if &verbose %then %do;
      proc print data = _mmtables_overlay width=minimum;
        title%eval(&titlstrt + 1) "(mdmake) Definitions in "
         "&outlib..&outprefix.tables overlaid by &inlib..&inprefix.tables";
      run;
      title%eval(&titlstrt + 1);
    %end;
  %end;
  %let exist = 1;
%end;
data &outlib..&outprefix.tables (label='Metadata Describing Table Attributes'
 &alterpswd);
  attrib table        length=$32 label='Table Name';
  attrib tshort       length=$8  label='Table Short Name';
  attrib tlabel       length=$40 label='Table Label';
  attrib torder       length=8   label='Table Order in mdprint Output';
  attrib type         length=$5  label='Table Type - view/table';
  attrib tdescription length=$32 
   label='Catalog Entry Containing Description of Table';
  attrib location     length=$50 label='Table Location';
  if 0 then do;
    array cvars _character_;
    do i = 1 to dim(cvars);
      cvars{i} = ' ';
    end;
    array nvars _numeric_;
    do i = 1 to dim(nvars);
      nvars{i} = .;
    end;
    drop i;
  end;
  %if &exist %then %do;
    set _mmtablesadd;
    type = upcase(type);
    tdescription = upcase(tdescription);
   %if ^ &keepall %then %do;
      keep table tshort tlabel torder type location tdescription;
    %end;
  %end;
  %else %do;
    stop;
  %end;
  format _character_;
  informat _character_;
run;
%*=============================================================================;
%* Create columns and columns_param meta data sets;
%*=============================================================================;
%do i = 1 %to 2;
  %if &i = 1 %then %do;
    %let mdsn = columns;
    %let param =;
    %let pc = c;
    %let parcol = Column;
  %end;
  %else %do;
    %let mdsn = columns_param;
    %let param = param;
    %let pc = p;
    %let parcol = Parameter;
  %end;
  *============================================================================;
  %bquote(* Create &mdsn meta data set;)
  *============================================================================;
  %let headersource =;
  %let headersourcet =;
  %let exist = 0;
  %if %sysfunc(exist(&inlib..&inprefix.&mdsn)) %then %do;
    data _mmcolumnsadd;
      %if %bquote(&param) ^= %then %do;
        length paramrel $ 32;
      %end;
      set &inlib..&inprefix.&mdsn
       %if (%bquote(&inselectq) ^= | %bquote(&inexcludeq) ^=) %then %do;
         (where = ( &incondition ))
       %end;
      ;
      table = upcase(left(table));
      column = upcase(left(column));
      %if %bquote(&param) ^= %then %do;
        &param = upcase(left(&param));
        paramrel = upcase(left(paramrel));
      %end;
      &pc.format = upcase(left(&pc.format));
    run;
    proc sort data = _mmcolumnsadd;
      by table column
       %if %bquote(&param) ^= %then %do;
         &param paramrel
       %end;
      ;
    run;
    %if &verbose %then %do;
      data _mmcolumnsduplicates;
        set _mmcolumnsadd (keep=table column
         %if %bquote(&param) ^= %then %do;
           param paramrel /* plabel */
         %end;
        );
        by table column
        %if %bquote(&param) = %then %do;
          ;
          if first.column + last.column ^= 2;
        %end;
        %else %do;
          param paramrel;
          if first.paramrel + last.paramrel ^= 2;
        %end;
      run;
      proc print data = _mmcolumnsduplicates width=minimum;
        title%eval(&titlstrt + 1)
         "(mdmake) Duplicate Definitions in &inlib..&inprefix.&mdsn";
      run;
      title%eval(&titlstrt + 1);
    %end;
    %let exist = 1;
  %end;
  %if %bquote(%upcase(&mode)) ^= REPLACE &
   %sysfunc(exist(&outlib..&outprefix.&mdsn)) %then %do;
    data _mmcolumnsold;
      %if %bquote(&param) ^= %then %do;
        length paramrel $ 32;
      %end;
      set &outlib..&outprefix.&mdsn
       %if (%bquote(&outselectq) ^= | %bquote(&outexcludeq) ^=) %then %do;
         (where = ( &outcondition ))
       %end;
      ;
      table = upcase(left(table));
      column = upcase(left(column));
      %if %bquote(&param) ^= %then %do;
        &param = upcase(left(&param));
        paramrel = upcase(left(paramrel));
      %end;
      &pc.format = upcase(left(&pc.format));
    run;
    proc sort data = _mmcolumnsold    out =
     %if &exist %then %do;
       _mmcolumnsold
     %end;
     %else %do;
       _mmcolumnsadd
     %end;
    ;
      by table column
       %if %bquote(&param) ^= %then %do;
         &param paramrel
       %end;
      ;
    run;
    %if &exist %then %do;
      %if &verbose %then %do;
        data _mmcolumnsduplicates;
          set _mmcolumnsold (keep=table column
           %if %bquote(&param) ^= %then %do;
             param paramrel    /* plabel */
           %end;
          );
          by table column
          %if %bquote(&param) = %then %do;
            ;
            if first.column + last.column ^= 2;
          %end;
          %else %do;
            param paramrel;
            if first.paramrel + last.paramrel ^= 2;
          %end;
        run;
        proc print data = _mmcolumnsduplicates width=minimum;
          title%eval(&titlstrt + 1)
           "(mdmake) Duplicate Definitions in &outlib..&outprefix.&mdsn";
        run;
        title%eval(&titlstrt + 1);
      %end;
      data _mmcolumnsadd  _mmcolumns_overlay (keep=table column &param);
        %if %bquote(%upcase(&mode)) = APPEND %then %do;
          set _mmcolumnsold  _mmcolumnsadd;
          by table column
           %if %bquote(&param) ^= %then %do;
             &param paramrel
           %end;
          ;
        %end;
        %else %if %bquote(%upcase(&mode)) = MERGE %then %do;
          merge _mmcolumnsold (in=fromold)  _mmcolumnsadd (in=fromadd);
          by table column
           %if %bquote(&param) ^= %then %do;
             &param paramrel
           %end;
          ;
          if fromold & fromadd then output _mmcolumns_overlay;
        %end;
        output _mmcolumnsadd;
      run;
      %if &verbose %then %do;
        proc print data = _mmcolumns_overlay width=minimum;
          title%eval(&titlstrt + 1) "(mdmake) &outlib..&outprefix.&mdsn overlaid "
           "by &inlib..&inprefix.&mdsn";
        run;
        title%eval(&titlstrt + 1);
      %end;
    %end;
    %else %do;
      %let headersource = &outlib..&outprefix.columns;
      %let headersourcet = outlib;
    %end;
    %let exist = 1;
  %end;
  %else %if &exist %then %do;
    %let headersource = &inlib..&inprefix.columns;
    %let headersourcet = inlib;
  %end;
  data &outlib..&outprefix.&mdsn (&alterpswd 
   label="Metadata Describing Column &param Attributes")
   _mmcolumnsalltabs;
    attrib table        length=$32 label='Table Name';
    attrib column       length=$32 label='Column Name';
    %if %bquote(&param) ^= %then %do;
      attrib param        length=$32 label='Parameter Value';
      attrib paramrel     length=$32 label='Name of PARAM related COLUMN';
      attrib paramrelcol  length=$32 label='Name of PARAMREL ';
    %end;
    attrib &pc.short       length=$8  label="&parcol Short Name";
    %if %bquote(&param) = %then %do;
      attrib &pc.pkey        length=8   label="Primary Key Number";
    %end;
    attrib &pc.order       length=8   label="&parcol Order";
    attrib &pc.label       length=$40 label="&parcol Label";
    attrib &pc.labellong   length=$100 label="&parcol Long label";
    attrib &pc.type        length=$1  label="&parcol Type";
    attrib &pc.length      length=8   label="&parcol Length";
    attrib &pc.format      length=$13
     label="&parcol Name of SAS system format, User format or Values list";
    attrib &pc.formatflag  length=8
     label="&parcol Format Type 1=SAS system 2=values in start 3=values in flabel 4=values in flabellong";
    attrib &pc.importance  length=$2  label="&parcol Importance";
    attrib &pc.derivetype  length=$9  label="Type of derivation";
    attrib &pc.domain      length=$8  label="&parcol data domain";
    attrib &pc.header      length=8   label="&parcol header number";
    attrib &pc.description length=$32
     label="Catalog Entry Containing Description of &parcol";
    if 0 then do;
      array cvars _character_;
      do i = 1 to dim(cvars);
        cvars{i} = ' ';
      end;
      array nvars _numeric_;
      do i = 1 to dim(nvars);
        nvars{i} = .;
      end;
      drop i;
    end;
    %if &exist %then %do;
      set _mmcolumnsadd;
      &pc.short       = upcase(&pc.short);
      &pc.type        = upcase(&pc.type);
      &pc.format      = upcase(&pc.format);
      &pc.importance  = upcase(&pc.importance);
      &pc.derivetype  = upcase(&pc.derivetype);
      &pc.domain      = upcase(&pc.domain);
      &pc.description = upcase(&pc.description);
      output &outlib..&outprefix.&mdsn;
      %if ^ &keepall %then %do;
        keep table column &param &pc.short 
         %if %bquote(&param) = %then %do;
           &pc.pkey
         %end;
         %else %do;
           paramrel paramrelcol
         %end;
         &pc.label &pc.labellong
         &pc.type &pc.length &pc.format &pc.formatflag 
         &pc.importance &pc.derivetype &pc.domain &pc.order
         &pc.header &pc.description
        ;
      %end;
    %end;
    %else %do;
      stop;
    %end;
    format _character_;
    informat _character_;
  run;
  %if &addparam & &i = 2 & &exist %then %do;
    * -------------------------------------------------------------------------;
    * Add flags to columns data set to flag if it is a parameter or paramrel;
    * CPARAMFL       Column is a parameter column;
    * CPARAMREL_MISS columns_param has at least one paramrel with missing value;
    * CPARAMRELFL    Column is a paramrel column;
    * -------------------------------------------------------------------------;
    proc sort data = &outlib..&outprefix.columns_param (keep = table column
     paramrel  where = (table ^= ' ' & (column ^= ' ' | paramrel ^= ' ')))
     out = _mmcolparm  nodupkey;
      by table column paramrel;
    run;
    data _mmcolparmfl (keep = table column cparamfl cparamrel_miss)
         _mmcolparmrelfl (keep = table paramrel cparamrelfl);
      set _mmcolparm;
      by table column;
      if first.column then cparamrel_miss = 0;
      if column ^= ' ' then cparamfl = 1;
      if paramrel = ' ' then cparamrel_miss = 1;
      if paramrel ^= ' ' then cparamrelfl = 1;
      else cparamrelfl = 0;
      if last.column & column ^= ' ' then output _mmcolparmfl;
      if paramrel ^= ' ' then output _mmcolparmrelfl;
      retain cparamrel_miss;
    run;
    proc sort data = _mmcolparmrelfl nodupkey;
      by table paramrel;
    run;
    data _mmcolumns (label="Metadata Describing Column &param Attributes");
      merge &outlib..&outprefix.columns (in=fromcol)
       _mmcolparmfl (in=fromparm);
      by table column;
      if fromparm & ^ fromcol then %ut_errmsg(
       msg='column found in columns_param data set but not in columns '
       table= column=,macroname=mdmake,type=warning,max=,debug=&debug);
      if ^ fromparm then do;
        if cparamfl = . then cparamfl = 0;
        if cparamrel_miss = . then cparamrel_miss = 0;
      end;
      if cparamfl then %ut_errmsg(msg='Column is a parameter ' table= column=
       cparamfl= fromparm=,macroname=mdmake,print=0,max=,debug=&debug);
    run;
    * -------------------------------------------------------------------------;
    * Add variable to columns data set to flag if it is a paramrel column;
    * -------------------------------------------------------------------------;
    data &outlib..&outprefix.columns(&alterpswd 
     label="Metadata Describing Column Attributes");
      merge _mmcolumns (in=fromcol)
       _mmcolparmrelfl (in=fromparm  rename=(paramrel=column));
      by table column;
      if fromparm & ^ fromcol then %ut_errmsg(
         msg='paramrel found in columns_param data set but not in columns '
         table= column=,macroname=mdmake,type=warning,max=,debug=&debug);
      if ^ fromparm then cparamrelfl = 0;
      if cparamrelfl then %ut_errmsg(msg='Column is related to a parameter '
       table= column= cparamfl= cparamrelfl= fromparm=,macroname=mdmake,
       print=0,max=,debug=&debug);
    run;
  %end;
  %if &addheader & %bquote(&headersource) = %then %do;
    %ut_errmsg(msg=ADDHEADER parameter reset to false because of ambiguous
     header table source library,macroname=mdmake,type=warning,debug=&debug)
    %let addheader = 0;
  %end;
  %if &addheader & &i = 1 & &exist & %bquote(&headersource) ^= %then %do;
    * -------------------------------------------------------------------------;
    * ADDHEADER true: Copy obs in columns data set that define header variables;
    * -------------------------------------------------------------------------;
    data _mmcolheader;
      set &headersource (keep = table column cheader cpkey
       where = (table ^= ' ' & column ^= ' '));
      table = left(upcase(table));
      column = left(upcase(column));
    run;
    proc sort data = _mmcolheader;
      by table column;
    run;
    %let maxlen = 0;
    *--------------------------------------------------------------------------;
    * Determine length of list of primary keys for next data step LENGTH;
    *  statement.  Set flag whether there are any header variables or not;
    *--------------------------------------------------------------------------;
    %let headerflag = 0;
    data _null_;
      if _n_ = 1 then headerflag = '0';
      if eof then do;
        if maxlen > 0 then
         call symput('maxlen',trim(left(put(maxlen,32.0))));
        call symput('headerflag',headerflag);
      end;
      set _mmcolheader (keep = table column cpkey cheader) end=eof;
      by table;
      curlen = length(column);
      if first.table then tablelen = 0;
      tablelen = tablelen + curlen + 1;
      if last.table & tablelen > maxlen then maxlen = tablelen;
      if cheader > 0 & cpkey <= 0 then headerflag = '1';
      retain tablelen maxlen headerflag;
    run;
    %if &maxlen > 0 & &headerflag %then %do;
      *------------------------------------------------------------------------;
      * If there are header variables then continue;
      * Create data sets of table names with a list of their primary keys;
      * _mmcolheader contains only tables contributing header variables;
      * _mmtablekeys contains all tables (that are SELECTed or not EXCLUDEd);
      *------------------------------------------------------------------------;
      data _mmcolheader (rename=(table=tableh pkeys=pkeysh))
           _mmtablekeys (rename=(table=tablek pkeys=pkeysk));
        set _mmcolheader (keep=table column cpkey cheader);
        by table;
        length pkeys $ &maxlen;
        if first.table then do;
          pkeys = ' ';
          headerflag = 0;
        end;
        if cpkey > 0 then
         pkeys = left(trim(left(pkeys)) || ' ' || trim(left(column)));
        if cheader > 0 then headerflag = 1;
        if last.table & pkeys ^= ' ' then do;
          %if ((%bquote(&headersourcet) = inlib & %bquote(&incondition) ^=) |
           (%bquote(&headersourcet) = outlib & %bquote(&outcondition) ^=))
           %then %do;
            if 
             %if %bquote(&headersourcet) = inlib & %bquote(&incondition) ^=
              %then %do;
               &incondition
             %end;
             %else %if %bquote(&headersourcet) = outlib &
              %bquote(&outcondition) ^= %then %do;
               %outcondition
             %end;
            then
          %end;
          output _mmtablekeys;
          if headerflag then output _mmcolheader;
        end;
        retain pkeys headerflag;
        keep table pkeys;
      run;
      *------------------------------------------------------------------------;
      * For each table that contributes header variables (source);
      *  compare its primary keys to each of the other tables (targets);
      *  create the data set _mmtjoins that lists all target tables that;
      *  contain all the primary keys of source data sets;
      *------------------------------------------------------------------------;
      data _mmtjoins;
        set _mmcolheader;
        length nextkey $ 32;
        do i = 1 to nobs;
          set _mmtablekeys nobs=nobs point=i;
          nomatchkey = 0;
          if tableh ^= tablek then do until (nomatchkey = 1 | nextkey = ' ');
            nextkey = '';
            k = 1;
            do until (nextkey = ' ');
              nextkey = scan(pkeysh,k,' ');
              if nextkey ^= ' ' & ^ indexw(pkeysk,nextkey) then nomatchkey = 1;
              %if &debug %then %do;
                put _all_ /;
              %end;
              k = k + 1;
            end;
            %if &debug %then %do;
              put _n_= tableh= tablek= nomatchkey= //;
            %end;
            if ^ nomatchkey then output;
          end;
        end;
        keep tableh tablek;
        label tableh = 'Table contributing header variable'
         tablek = 'Table receiving header variable';
      run;
      proc sort data = _mmtjoins nodupkey;
        by tableh tablek;
      run;
      *------------------------------------------------------------------------;
      * Add header variables from source tables to target tables;
      *------------------------------------------------------------------------;
      proc append base = _mmcolumnsalltabs  data = &headersource  force;
      run;
      data _mmcolumnsalltabs;
        set _mmcolumnsalltabs;
        table = upcase(table);
        column = upcase(column);
        cformat = upcase(cformat);
      run;
      data _mmcolumns (rename=(table_new=table));
        length table_new table_source $ 32;
        set _mmcolumnsalltabs;
        table_new = table;
        table_source = ' _self_';
        output;
        do i = 1 to nobs;
          set _mmtjoins nobs=nobs point=i;
          %if &debug %then %do;
            put _n_= table= column= cheader= cpkey= tableh= tablek= table_new=;
          %end;
          if table = tableh & cheader > 0 & cpkey <= 0 then do;
            table_new = tablek;
            table_source = tableh;
            output;
            %ut_errmsg(msg="header variable " column "being added to table "
             tablek "from table " tableh,macroname=mdmake,print=0,max=,
             debug=&debug)
            %if &debug %then %do;
              put _all_ /;
            %end;
          end;
        end;
        label table_new = "Table Name";
        drop table tablek tableh;
      run;
      *------------------------------------------------------------------------;
      * Sort augmented columns data set and subset according to SELECT and;
      *  EXCLUDE parameters;
      *------------------------------------------------------------------------;
      proc sort data = _mmcolumns
       %if ((%bquote(&headersourcet) = inlib & %bquote(&incondition) ^=) |
        (%bquote(&headersourcet) = outlib & %bquote(&outcondition) ^=))
        %then %do;
         (where = ( 
          %if %bquote(&headersourcet) = inlib & %bquote(&incondition) ^=
           %then %do;
            &incondition
          %end;
          %else %if %bquote(&headersourcet) = outlib &
           %bquote(&outcondition) ^= %then %do;
            %outcondition
          %end;
         ))
       %end;
      ;
        by table column table_source;
      run;
      %if &debug %then %do;
        proc print data = _mmcolheader;
          title%eval(&titlstrt + 1) '(mdmake) debug print: _mmcolheader data set';
        run;
        proc print data = _mmtablekeys;
          title%eval(&titlstrt + 1) '(mdmake) debug print: _mmtablekeys data set';
        run;
        proc print data = _mmtjoins label;
          title%eval(&titlstrt + 1) '(mdmake) debug print: _mmtjoins data set';
          label tablek = "table receiving header variables (tablek)"
           tableh = 'table supplying header variables (tableh)';
        run;
        title%eval(&titlstrt + 1);
      %end;
      *------------------------------------------------------------------------;
      * Delete duplicate definitions on COLUMNS;
      *  the user may have entered a COLUMN in a target TABLE and also;
      *  flagged a header to be added from a source TABLE;
      *------------------------------------------------------------------------;
      data _mmcolumns;
        set _mmcolumns;
        by table column;
        if first.column then dupsel = .;
        if table_source = ' _self_' then output;
        if first.column + last.column ^= 2 then do;
          if first.column then dupsel = 0;
          %ut_errmsg(msg='Duplicate column found as a result of adding '
           'headers - deleting duplicates ' / _n_= table= column= table_source=
           cheader= cpkey= /,macroname=mdmake,print=0,max=,debug=&debug)
          if table_source = ' _self_' then do;
            dupsel = 1;
            put 'UNOTE(mdmake): selected in loop 1 ' _n_= /;
          end;
          if dupsel = 0 then do;
            if ctype ^= ' ' & clabel ^= ' ' then do;
              dupsel = 1;
              output;
              put 'UNOTE(mdmake): selected in loop 2 ' _n_= /;
            end;
            if last.column & dupsel = 0 then do;
              dupsel = 1;
              output;
              put 'UNOTE(mdmake): selected in loop 3 ' _n_= /;
            end;
          end;
        end;
        else if table_source ^= ' _self_' then output;
        drop table_source dupsel;
      run;
      %if &debug %then %do;
        proc compare data=&outlib..&outprefix.columns compare=_mmcolumns
         listall;
          id table column;
         title%eval(&titlstrt + 1)
          "(mdmake) Debug: comparison of COLUMNS with headers "
          "added to COLUMNS without headers";
        run;
        title%eval(&titlstrt + 1);
      %end;
      *------------------------------------------------------------------------;
      * Sort and create the OUTLIB COLUMNS data set;
      *------------------------------------------------------------------------;
      proc sort data = _mmcolumns out = &outlib..&outprefix.columns
       (label = "Metadata Describing Column Attributes");
        by table column;
      run;
    %end;
    %else %do;
      %ut_errmsg(msg=header variables not added,macroname=mdmake,print=0,
       debug=&debug)
      %if ^ &headerflag %then %ut_errmsg(msg=No header variables found,
       macroname=mdmake,print=0,debug=&debug);
      %if &maxlen <= 0 %then %ut_errmsg(msg=No primary Keys found,
       macroname=mdmake,print=0,debug=&debug);
    %end;
  %end;
%end;
*==============================================================================;
* Create values meta data set;
*==============================================================================;
%let exist = 0;
%if %sysfunc(exist(&inlib..&inprefix.values)) %then %do;
  data _mmvaluesadd;
    length format $ 13;
    set &inlib..&inprefix.values (where = (format ^= ' '));
    format = upcase(left(format));
  run;
  proc sort data = _mmvaluesadd;
    by format start;
  run;
  %let exist = 1;
  %if &verbose %then %do;
    data _mmvaluesduplicates;
      set _mmvaluesadd (keep=format start end flabel);
      by format start;
      if first.start + last.start ^= 2;
    run;
    proc print data = _mmvaluesduplicates width=minimum;
      title%eval(&titlstrt + 1)
       "(mdmake) Duplicate Definitions in &inlib..&inprefix.values";
    run;
    title%eval(&titlstrt + 1);
  %end;
%end;
%if %bquote(%upcase(&mode)) ^= REPLACE &
 %sysfunc(exist(&outlib..&outprefix.values)) %then %do;
  data 
   %if &exist %then %do;
     _mmvaluesold
   %end;
   %else %do;
     _mmvaluesadd;
   %end;
  ;
    set &outlib..&outprefix.values (where = (format ^= ' '));
    format = upcase(left(format));
  run;
  proc sort  data = 
   %if &exist %then %do;
     _mmvaluesold
   %end;
   %else %do;
     _mmvaluesadd;
   %end;
  ;
    by format start;
  run;
  %if &exist %then %do;
    %if &verbose %then %do;
      data _mmvaluesduplicates;
        set _mmvaluesold (keep=format start end flabel);
        by format start;
        if first.start + last.start ^= 2;
      run;
      proc print data = _mmvaluesduplicates width=minimum;
        title%eval(&titlstrt + 1)
         "(mdmake) Duplicate Definitions in &outlib..&outprefix.values";
      run;
      title%eval(&titlstrt + 1);
    %end;
    data _mmvaluesadd  _mmvalues_overlay (keep=format start end);
      %if %bquote(%upcase(&mode)) = APPEND %then %do;
        set _mmvaluesold  _mmvaluesadd;
        by format start;
      %end;
      %if %bquote(%upcase(&mode)) = MERGE %then %do;
        merge _mmvaluesold (in=fromold)  _mmvaluesadd (in=fromadd);
        by format start;
        if fromold & fromadd then output _mmvalues_overlay;
      %end;
      output _mmvaluesadd;
    run;
    %if &verbose %then %do;
      proc print data = _mmvalues_overlay  width=minimum;
        title%eval(&titlstrt + 1) "(mdmake) &outlib..&outprefix.values overlaid"
         " by &inlib..&inprefix.values";
      run;
      title%eval(&titlstrt + 1);
    %end;
  %end;
  %let exist = 1;
%end;
data
 %if %bquote(&inselect) ^= | %bquote(&inexclude) ^= | %bquote(&outselect) ^= |
  %bquote(&outexclude) ^= %then %do;
   _mmvalues
 %end;
 %else %do;
   &outlib..&outprefix.values (&alterpswd 
    label="Metadata Describing Valid Values of Column")
 %end;
;
  attrib format     length=$13  label="Format Name";
  attrib start      length=$300 label='Start Value';
  attrib end        length=$300 label='End Value';
  attrib flabel     length=$100 label='Format Label';
  attrib flabellong length=$400 label='Long Format Label';
  if 0 then do;
    array cvars _character_;
    do i = 1 to dim(cvars);
      cvars{i} = ' ';
    end;
    array nvars _numeric_;
    do i = 1 to dim(nvars);
      nvars{i} = .;
    end;
    drop i;
  end;
  %if &exist %then %do;
    set _mmvaluesadd;
    %if ^ &keepall %then %do;
      keep format start end flabel flabellong;
    %end;
  %end;
  %else %do;
    stop;
  %end;
  format _character_;
  informat _character_;
run;
%if %bquote(&inselect) ^= | %bquote(&inexclude) ^= | %bquote(&outselect) ^= |
  %bquote(&outexclude) ^= %then %do;
  * ---------------------------------------------------------------------------;
  * If SELECT or EXCLUDE parameters are specified then subset the formats in;
  *  VALUES to those used by the selected tables;
  * ---------------------------------------------------------------------------;
  proc sort data = &outlib..&outprefix.columns_param (keep = pformat)
   out = _mmcolpfmt  nodupkey;
    by pformat;
  run;
  proc sort data = &outlib..&outprefix.columns (keep = cformat) out = _mmcolfmt
   nodupkey;
    by cformat;
  run;
  data _mmgetfmts;
    merge _mmcolfmt  (rename=(cformat=format))
          _mmcolpfmt (rename=(pformat=format));
    by format;
    if format ^= ' ';
  run;
  data &outlib..&outprefix.values (&alterpswd 
   label="Metadata Describing Valid Values of Column");
    merge _mmvalues (in=fromvals)  _mmgetfmts (in=fromfmts);
    by format;
    if fromvals & fromfmts;
  run;
%end;
%if &addparam %then %do;
  * ---------------------------------------------------------------------------;
  * Add param values from columns_param to values data set for param variable;
  * assign CFORMAT in COLUMNS data set to match the format in VALUES;
  * ---------------------------------------------------------------------------;
  proc sort data = &outlib..&outprefix.columns_param (keep = table column
   param where = (table ^= ' ' & column ^= ' ' & param ^= ' '))
   out = _mmcolparmvals  nodupkey;
    by table column param;
  run;
  data _mmcolpfmts (keep=table column cformat cformatflag_param)
       _mmvalpfmts (keep=cformat param rename=(cformat=format param=start));
    set _mmcolparmvals;
    by table column param;
    length cformat $ 13;
    if first.column then do;
      fmtnum + 1;
      cformat = '_PF' || trim(left(put(fmtnum,32.0))) || '_';
      cformatflag_param = 2;
      output _mmcolpfmts;
    end;
    if first.param then output _mmvalpfmts;
    retain cformat;
  run;
  proc sort data = _mmvalpfmts;
    by format start;
  run;
  data &outlib..&outprefix.columns (drop=cformatparam cformatflag_param
   label="Metadata Describing Column Attributes")
   _mmdelvals (keep=cformatparam);
    merge &outlib..&outprefix.columns (in=fromcols)
     _mmcolpfmts (in=frompfmts rename=(cformat=cformatparam));
    by table column;
    if fromcols & frompfmts & cformat = ' ' then do;
      cformat = cformatparam;
      cformatflag = cformatflag_param;
    end;
    if fromcols & frompfmts & cformat ^= ' ' & cformat ^= cformatparam then do;
      %ut_errmsg(msg='column is a param and has a CFORMAT of ' cformat
       table= column= ' values coming from VALUES instead of COLUMNS_PARAM',
       macroname=mdmake,max=,print=0,debug=&debug)
      output _mmdelvals;
    end;
    if fromcols then output &outlib..&outprefix.columns;
    if ^ fromcols then %ut_errmsg(msg='column is in columns_param but not in '
     'columns' table= column=,macroname=mdmake,max=,debug=&debug);
  run;
  proc sort data = _mmdelvals nodupkey;
    by cformatparam;
  run;
  data _mmvalpfmts;
    merge _mmvalpfmts  _mmdelvals (in=fromdel rename=(cformatparam=format));
    by format;
    if fromdel then delete;
  run;
  data &outlib..&outprefix.values (&alterpswd 
   label="Metadata Describing Valid Values of Column");
    merge &outlib..&outprefix.values  (in=fromvals)
     _mmvalpfmts (in=fromcols);
    by format start;
  run;
%end;
*==============================================================================;
* Create descriptions catalog;
*==============================================================================;
data _mmcolsent;
  set &outlib..&outprefix.columns (keep = column cdescription);
  if column ^= ' ';
  if cdescription ^= ' ' then do;
    description = upcase(cdescription);
    refbycname = 0;
  end;
  else do;
    description = upcase(column);
    refbycname = 1;
  end;
  if description ^= ' ' then output;
  keep description refbycname;
run;
proc sort data = _mmcolsent  nodupkey;
  by description;
run;
data _mmcolparament;
  set &outlib..&outprefix.columns_param (keep = column param paramrelcol
   pdescription);
  if column ^= ' ' & param ^= ' ';
  if pdescription ^= ' ' then do;
    description = upcase(pdescription);
    refbypname = 0;
  end;
  else if paramrelcol ^= ' ' then do;
    description = upcase(paramrelcol);
    refbypname = 1;
  end;
  if description ^= ' ' then output;
  keep description refbypname;
run;
proc sort data = _mmcolparament  nodupkey;
  by description;
run;
data _mmtabsent;
  set &outlib..&outprefix.tables (keep=table tdescription);
  if table ^= ' ';
  if tdescription ^= ' ' then do;
    description = upcase(tdescription);
    refbytname = 0;
  end;
  else do;
    description = upcase(tdescription);
    refbytname = 1;
  end;
  if description ^= ' ' then output;
  keep description refbytname;
run;
proc sort data = _mmtabsent  nodupkey;
  by description;
run;
data _mmentries;
  merge _mmcolsent  _mmcolparament  _mmtabsent  end=eof;
  by description;
  if first.description;
  keep description refbytname refbycname refbypname;
run;
%if &mkcat %then %do;
  *----------------------------------------------------------------------------;
  * MKCAT parameter is true so create a template catalog entry for every column;
  *----------------------------------------------------------------------------;
  %let numcols = 0;
  data _null_;
    if eof & colnum > 0 then
     call symput('numcols',trim(left(put(colnum,32.0))));
    set _mmentries  end=eof;
    colnum + 1;
    call symput('col' || trim(left(put(colnum,32.0))),trim(left(description)));
  run;
  %if &numcols > 0 %then %do;
    %if ^ &debug %then %do;
      %let mprint = %sysfunc(getoption(mprint));
      %let notes = %sysfunc(getoption(notes));
      options nomprint nonotes;
    %end;
    filename _mmdesc catalog "work._mmdescriptions";
    %do colnum = 1 %to &numcols;
      data _null_;
        file _mmdesc(&&col&colnum...source);
        put 'General Description' // @4 'put description here' @90 '.' ////
         'Detailed Description' // @4 '[data set] variables' // @4 'formula';
        stop;
      run;
    %end;
    filename _mmdesc clear;
    %if ^ &debug %then %do;
      options &mprint &notes;
    %end;
  %end;
%end;
*------------------------------------------------------------------------------;
* Create _mmdescriptions catalog containing all entries in INLIB and OUTLIB;
*------------------------------------------------------------------------------;
%if %sysfunc(cexist(&outlib..&outprefix.descriptions)) %then %do;
  %if %upcase(&mode) ^= REPLACE %then %do;
    proc catalog catalog = &outlib..&outprefix.descriptions;
      copy out = work._mmdescriptions
       %if ^ &mkcat %then %do;
         new
       %end;
      ;
    run; quit;
  %end;
  %if %sysfunc(cexist(&inlib..&inprefix.descriptions)) %then %do;
    proc catalog catalog = &inlib..&inprefix.descriptions;
      copy out = work._mmdescriptions;
    run; quit;
  %end;
  %else %if ^ &mkcat %then
   %ut_errmsg(msg=OUTLIB catalog left as is &outlib..&&outprefix.descriptions,
   macroname=mdmake,print=0,debug=&debug);
%end;
%else %do;
  %if %sysfunc(cexist(&inlib..&inprefix.descriptions)) %then %do;
    proc catalog catalog = &inlib..&inprefix.descriptions;
      copy out = work._mmdescriptions
       %if ^ &mkcat %then %do;
         new
       %end;
      ;
    run; quit;
  %end;
  %else %do;
    %ut_errmsg(msg=Catalogs do not exist &inlib..&inprefix.descriptions
     &outlib..&outprefix.descriptions,macroname=mdmake,print=0)
  %end;
%end;
%let subset_type=;
%if %sysfunc(cexist(work._mmdescriptions)) %then %do;
  *----------------------------------------------------------------------------;
  * Copy _mmdescriptions catalog to OUTLIB keeping only required entries;
  *----------------------------------------------------------------------------;
  *----------------------------------------------------------------------------;
  * Compare actual entry names to _mmentries to see if catalog has entries;
  *  that are not used or if metadata points to non-existent catalog entry;
  *----------------------------------------------------------------------------;
  proc catalog cat = _mmdescriptions;
    contents out=_mmcatents_actual;
  run; quit;
  data _mmcatents_actual;
    set _mmcatents_actual;
    name = upcase(name);
    type = upcase(type);
    if type = 'SOURCE';
  run;
  proc sort data = _mmcatents_actual;
    by name;
  run;
  data _mmcatent_notused (keep=name type desc crdate moddate)
       _mmcatent_notfound (keep=name)
       _mmcatent_found_used (keep=name type desc crdate moddate)
       _mmmult_refbyname (keep=name refbytname refbycname refbypname)
  ;
    if eof then do;
      if exclude_length <= 0 then call symput('subset_type','copyall');
      else if select_length <= 0 then call symput('subset_type','excludeall');
      else if exclude_length < select_length then
       call symput('subset_type','exclude');
      else call symput('subset_type','select');
      %ut_errmsg(msg=select_length= exclude_length=,macroname=mdmake,print=0)
      %if &sysver = 8.2 %then %do;
        if select_length > 32000 & exclude_length > 32000 then do;
          %ut_errmsg(msg='Length of select/exclude statement is longer than SAS'
           ' version 8 allows so all entries will be copied' select_length=
           exclude_length=,macroname=mdmake,type=warning)
          call symput('subset_type','copyall');
        end;
      %end;
    end;
    merge _mmentries (in=metadata rename=(description=name))
          _mmcatents_actual (in=catalog) end=eof;
    by name;
    if ^ metadata & upcase(name) ^ in ('_SPEC_' '_TEMPLATE_') then do;
      exclude_length = max(exclude_length,0) + length(name) + 1;
      output _mmcatent_notused;
    end;
    if ^ catalog & ^ refbytname & ^ refbycname & ^ refbypname then do;
      output _mmcatent_notfound;
    end;
    if catalog & metadata then do;
      if (sum(refbytname,refbycname,refbypname) > 1) then 
       output _mmmult_refbyname;
    end;
    if (catalog & metadata) | upcase(name) = '_SPEC_' then do;
      select_length = max(select_length,0) + length(name) + 1;
      output _mmcatent_found_used;
    end;
    retain select_length exclude_length;
  run;
  %put UNOTE(mdmake): subset_type=&subset_type;
  %let numents = 0;
  %if &subset_type = exclude | &subset_type = select %then %do;
    data _null_;
      if eof then do;
        if numents > 0 then
         call symput('numents',trim(left(put(numents,32.0))));
      end;
      set
       %if &subset_type = select %then %do;
         _mmcatent_found_used
       %end;
       %else %if &subset_type = exclude %then %do;
         _mmcatent_notused
       %end;
       end=eof;
      numents + 1;
      call symput('ent' || trim(left(put(numents,32.0))),trim(left(name)));
    run;
    %ut_errmsg(msg=Number of entries to &subset_type = &numents,
     macroname=mdmake,print=0,debug=&debug)
    %if &debug %then %do entnum = 1 %to &numents;
      %ut_errmsg(msg=ent&entnum = &&ent&entnum,macroname=mdmake,print=0,
       debug=&debug)
    %end;
  %end;    %* subset_type is exclude or select;
  %if &subset_type ^= excludeall %then %do;
    proc catalog catalog = _mmdescriptions;
      copy out = &outlib..&outprefix.descriptions  new;
      %if (&subset_type = select | &subset_type = exclude) & &numents > 0 %then
       %do;
        &subset_type
         %do entnum = 1 %to &numents;
           &&ent&entnum
         %end;
         / entrytype = source
        ;
      %end;
    run; quit;
  %end;    %* subset_type not excludeall;
%end;      %* _mmdescriptions exists;
%else %if (&subset_type = excludeall | ^ %sysfunc(cexist(work._mmdescriptions)))
 & %sysfunc(cexist(&outlib..&outprefix.descriptions)) %then %do;
  proc catalog catalog = &outlib..&outprefix.descriptions kill;
  run; quit;
%end;
filename _mmct catalog "&outlib..&outprefix.descriptions";
data _null_;
  file _mmct(_TEMPLATE_.source);
  put 'General Description' // @4 'put description here' @90 '.' ////
   'Detailed Description' // @4 '[data set] variables' // @4 'formula';
  stop;
run;
filename _mmct clear;
%if &verbose & %sysfunc(cexist(work._mmdescriptions)) %then %do;
  %if %bquote(&inselect) = & %bquote(&inexclude) = & 
   %bquote(&outselect) = & %bquote(&outexclude) = %then %do;
    proc print data = _mmcatent_notused width=minimum;
      title%eval(&titlstrt + 1)
       "(mdmake) Catalog Entries not Referenced by Metadata";
    run;
  %end;
  proc print data = _mmcatent_notfound width=minimum;
    title%eval(&titlstrt + 1)
     "(mdmake) Catalog Entries Referenced by Metadata but not "
     "Found in Catalog";
  run;
  proc print data = _mmmult_refbyname width=minimum;
    title%eval(&titlstrt + 1) "(mdmake) Catalog entries associated with "
     "multiple objects by default names";
  run;
  title%eval(&titlstrt + 1);
%end;
%if &debug %then %ut_errmsg(msg=ic=&ic audit=&audit,macroname=mdmake,print=0,
 debug=&debug);
%if &verbose %then %do;
  *============================================================================;
  * Check referential integrity;
  *============================================================================;
  %do i = 1 %to 2;
    %let checklib =;
    %let checkprefix =;
    %let tables_exist = 0;
    %let columns_exist = 0;
    %let columns_param_exist = 0;
    %let values_exist = 0;
    %if &i = 1 %then %do;
      %let checklib = &inlib;
      %let checkprefix = &inprefix;
    %end;
    %else %do;
      %if %bquote(%upcase(&mode)) ^= REPLACE %then %let checklib = &outlib;
      %let checkprefix = &outprefix;
    %end;
    %if %bquote(&checklib) ^= %then %do;
      %if %sysfunc(exist(&checklib..&checkprefix.tables)) %then
       %let tables_exist = 1;
      %if %sysfunc(exist(&checklib..&checkprefix.columns)) %then
       %let columns_exist = 1;
      %if %sysfunc(exist(&checklib..&checkprefix.columns_param)) %then
       %let columns_param_exist = 1;
      %if %sysfunc(exist(&checklib..&checkprefix.values)) %then
       %let values_exist = 1;
    %end;
    %put i=&i checklib=&checklib;
    %if &tables_exist & (&columns_exist | &columns_param_exist) %then %do;
      data _mmtablescheck;
        length table $ 32;
        set &checklib..&checkprefix.tables (keep=table);
        table = upcase(table);
      run;
      proc sort data = _mmtablescheck;
        by table;
      run;
    %end;
    %if &columns_exist  & (&tables_exist | &columns_param_exist) %then %do;
      data _mmcolumnscheck;
        length table column $ 32;
        set &checklib..&checkprefix.columns (keep=table column);
        table = upcase(table);
        column = upcase(column);
      run;
      proc sort data = _mmcolumnscheck;
        by table column;
      run;
    %end;
    %if &tables_exist & &columns_exist %then %do;
      data _mmtabnotcol  _mmcolnottab;
        merge _mmtablescheck (in=fromtables)  _mmcolumnscheck (in=fromcolumns);
        by table;
        if ^ fromtables then output _mmcolnottab;
        else if ^ fromcolumns then output _mmtabnotcol;
      run;
      proc print data = _mmtabnotcol width=minimum;
        title%eval(&titlstrt + 1) "(mdmake) Data sets defined in TABLES that "
         "have no variables defined in COLUMNS";
      run;
      proc print data = _mmcolnottab width=minimum;
        title%eval(&titlstrt + 1) "(mdmake) Variables defined in COLUMNS "
         "in data sets not defined in TABLES";
      run;
      title%eval(&titlstrt + 1);
    %end;
    %if &columns_param_exist & (&columns_exist | &tables_exist) %then %do;
      data _mmcolumns_paramcheck;
        length table column $ 32;
        set &checklib..&checkprefix.columns_param
         (keep = table column param paramrel);
        table = upcase(table);
        column = upcase(column);
        param = upcase(param);
        paramrel = upcase(paramrel);
      run;
      proc sort data = _mmcolumns_paramcheck;
        by table column;
      run;
    %end;
    %if &tables_exist & &columns_param_exist %then %do;
      data _mmcolpnottab;
        merge _mmtablescheck (in=fromtables)
              _mmcolumns_paramcheck (in=fromcolumns_param);
        by table;
        if ^ fromtables then output _mmcolpnottab;
      run;
      proc print data = _mmcolpnottab width=minimum;
        title%eval(&titlstrt + 1) "(mdmake) Variables defined in COLUMNS_PARAM "
         "in data sets not defined in TABLES";
      run;
      title%eval(&titlstrt + 1);
    %end;
    %if &columns_exist & &columns_param_exist %then %do;
      data _mmcolpnotcol;
        merge _mmcolumnscheck (in=fromcolumns)
              _mmcolumns_paramcheck (in=fromcolumns_param);
        by table column;
        if ^ fromcolumns then output _mmcolpnotcol;
      run;
      proc print data = _mmcolpnotcol width=minimum;
        title%eval(&titlstrt + 1) "(mdmake) Variables defined in COLUMNS_PARAM "
         "not defined in COLUMNS";
      run;
      title%eval(&titlstrt + 1);
    %end;
    %if &values_exist %then %do;
      %if &columns_exist | &columns_param_exist %then %do;
        data _mmformatcheck;
          length format $ 8;
          set &checklib..&checkprefix.values (keep = format);
          format = upcase(format);
        run;
        proc sort data = _mmformatcheck  nodupkey;
          by format;
        run;
      %end;
      %if &columns_exist %then %do;
        data _mmcformatcheck  _mmbadcformatflag;
          length cformat $ 8  cformatflag 8;
          set &checklib..&checkprefix.columns;
          if cformat ^= ' ' & cformatflag ^= 1;
          cformat = upcase(cformat);
          output _mmcformatcheck;
          if cformatflag ^ in (2 3 4) then output _mmbadcformatflag;
        run;
        proc sort data = _mmcformatcheck
         nodupkey;
          by cformat;
        run;
        data _mmcformatnotformat _mmformatnotcformat (keep=cformat);
          merge _mmcformatcheck (in=fromcformat)
                _mmformatcheck (in=fromformat rename=(format=cformat));
          by cformat;
          if ^ fromcformat then output _mmformatnotcformat;
          else if ^ fromformat then output _mmcformatnotformat;
        run;
        proc print data = _mmbadcformatflag width=minimum;
          title%eval(&titlstrt + 1)
           "(mdmake) Invalid CFORMATFLAGs defined in COLUMNS";
        run;
        proc print data = _mmcformatnotformat width=minimum;
          title%eval(&titlstrt + 1) "(mdmake) CFORMATs defined in COLUMNS "
           "not defined in VALUES";
        run;
        title%eval(&titlstrt + 1);
      %end;
      %if &columns_param_exist %then %do;
        data _mmpformatcheck  _mmbadpformatflag;
          length pformat $ 8;
          set &checklib..&checkprefix.columns_param (keep=pformat pformatflag
           where = (pformat ^= ' ' & pformatflag ^= 1));
          pformat = upcase(pformat);
          output _mmpformatcheck;
          if pformatflag ^ in (2 3 4) then output _mmbadpformatflag;
        run;
        proc sort data = _mmpformatcheck  nodupkey;
          by pformat;
        run;
        data _mmpformatnotformat _mmformatnotpformat (keep=pformat);
          merge _mmpformatcheck (in=frompformat)
                _mmformatcheck (in=fromformat rename=(format=pformat));
          by pformat;
          if ^ frompformat then output _mmformatnotpformat;
          else if ^ fromformat then output _mmpformatnotformat;
        run;
        proc print data = _mmbadpformatflag width=minimum;
          title%eval(&titlstrt + 1)
           "(mdmake) Invalid PFORMATFLAGs defined in COLUMNS_PARAM";
        run;
        proc print data = _mmpformatnotformat width=minimum;
          title%eval(&titlstrt + 1) "(mdmake) PFORMATs defined in COLUMNS_PARAM"
           " not defined in VALUES";
        run;
        %if %sysfunc(exist(work._mmformatnotcformat)) %then %do;
          data _mmformatnotcpformat;
            merge _mmformatnotcformat (in=fromc rename=(cformat=format))
                  _mmformatnotpformat (in=fromp rename=(pformat=format));
            by format;
            if fromc & fromp;
          run;
          proc print data = _mmformatnotcpformat width=minimum;
            title%eval(&titlstrt + 1) "(mdmake) FORMATS defined in VALUES "
             "not defined in COLUMNS CFORMAT or COLUMNS_PARAM PFORMAT";
          run;
          title%eval(&titlstrt + 1);
        %end;
        %else %do;
          proc print data = _mmformatnotpformat width=minimum;
            title%eval(&titlstrt + 1) "(mdmake) FORMATS defined in VALUES "
             "not defined in COLUMNS_PARAM PFORMAT";
          run;
          title%eval(&titlstrt + 1);
        %end;
      %end;
      %else %do;
        proc print data = _mmformatnotcformat width=minimum;
          title%eval(&titlstrt + 1) "(mdmake) FORMATS defined in VALUES "
           "not defined in COLUMNS CFORMAT";
        run;
      %end;
    %end;
  %end;
%end;
%if &ic | &audit %then %do;
  *============================================================================;
  * Define integrity contraints and audit trails;
  *============================================================================;
  proc datasets lib=&outlib nolist;
    %* ;
    modify &outprefix.tables &alterpswdp;
    %if &ic %then %do;
      ic create primary key(table)
       message='Primary keys must be unique and nonmissing';
      ic create val_type = check(where = (type in ('TABLE' 'VIEW' ' ')));
      run;
    %end;
    %if &audit %then %do;
      audit &outprefix.tables &alterpswdp;  initiate;
      run;
    %end;
    %* ;
    modify &outprefix.columns &alterpswdp;
    %if &ic %then %do;
      ic create primary key(table column)
       message='Primary keys must be unique and nonmissing'
      ;
      ic create val_cpkey  = check(where = (cpkey >= 0 | cpkey = .))
       message = "CPKEY must be a positive integer 0 or greater"
      ;
      ic create val_ctype  = check(where = (ctype in ('C' 'N')))
       message = "CTYPE must be C or N"
      ;
      ic create val_clen = check(where = (ctype = 'C' & 1<=clength<=1000
       | ctype = 'N' & 2<=clength<=8))
       message = "CLENGTH is invalid"
      ;
      ic create val_fmtf   = check(where = (cformatflag in (. 1 2 3 4)))message =
       "CFORMATFLAG must be 1, 2, 3, 4 or missing (values user system no not-applicable)"
      ;
     /* primary endpoint (pe), secondary endpoint (se), safety1 (s1),
        safety2 (s2) */
      ic create val_import = check(where = 
       (cimportance in ('PE' 'SE' 'S1' 'S2' ' '))) message = 
       "CIMPORTANCE must be PE SE S1 S2 or missing
       (PrimaryEfficacy SecondaryEfficacy PrimarySafety SecondarySafety)"
      ;
      ic create val_derive =
       check(where = (cderivetype in ('COPY' 'TRANSFORM' 'DERIVED' ' ')))
       message = "CDERIVETYPE must be COPY TRANSFORM or DERIVE"
      ;
      ic create val_header = check(where = (cheader >= 0 | cheader = .))
       message = "CHEADER must be greater than or equal to 0"
      ;
    %end;
    run;
    %if &audit %then %do;
      audit &outprefix.columns &alterpswdp;  initiate;
      run;
    %end;
    %* ;
    modify &outprefix.columns_param &alterpswdp;
    %if &ic %then %do;
      ic create primary key(table column param paramrel)
       message='Primary keys must be unique and nonmissing';
      ic create val_ptype  = check(where = (ptype in ('C' 'N')))
       message = 'PTYPE must be C or N'
      ;
      ic create val_plen   = check(where = (ptype = 'C' & 1<=plength<=200
       | ptype = 'N' & 2<=plength<=8))
       message = 'PLENGTH is invalid'
      ;
      ic create val_fmtf   = check(where = (pformatflag in (. 1 2 3 4)))message =
       "PFORMATFLAG must be 1, 2, 3, 4 or missing (values user system no not-applicable)"
      ;
      ic create val_import = check(where = 
       (pimportance in ('PE' 'SE' 'S1' 'S2' ' '))) message = 
       'PIMPORTANCE must be PE SE S1 S2 or missing
       (PrimaryEfficacy SecondarEfficacy PrimarySafety SecondarySafety)'
      ;
      ic create val_derive =
       check(where = (pderivetype in ('COPY' 'TRANSFORM' 'DERIVED' ' ')))
       message = "PDERIVETYPE must be COPY TRANSFORM or DERIVE"
      ;
      ic create val_header = check(where = (pheader >= 0 | pheader = .))
       message = 'PHEADER must be greater than or equal to 0'
      ;
      run;
    %end;
    %if &audit %then %do;
      audit &outprefix.columns_param &alterpswdp;  initiate;
      run;
    %end;
    %* ;
    modify &outprefix.values &alterpswdp;
    %if &ic %then %do;
      ic create val_unique = unique(format start)
       message='Format / Start must be unique';
      run;
    %end;
    %if &audit %then %do;
      audit &outprefix.values &alterpswdp;  initiate;
      run;
    %end;
  quit;
%end;
%if &contents %then %do;
  title%eval(&titlstrt + 1) "(mdmake) Description of Meta Data Sets in &outlib";
  proc contents data = &outlib..&outprefix.tables position;
  run;
  proc contents data = &outlib..&outprefix.columns position;
  run;
  proc contents data = &outlib..&outprefix.columns_param position;
  run;
  proc contents data = &outlib..&outprefix.values position;
  run;
  proc catalog catalog = &outlib..&outprefix.descriptions;
    contents;
  run; quit;
  title%eval(&titlstrt + 1);
%end;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _mm: / memtype=data;
    %if %sysfunc(cexist(work._mmdescriptions)) %then %do;
      delete _mm: / memtype=catalog;
    %end;
  run; quit;
%end;
title&titlstrt;
%if &debug %then %ut_errmsg(msg=macro ending,macroname=mdmake,print=0,
 debug=&debug);
%mend;
