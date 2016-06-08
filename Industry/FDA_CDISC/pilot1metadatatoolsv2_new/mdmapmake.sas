%macro mdmapmake(outlib=_default_,outprefix=_default_,sourcemd=_default_,
 sourceprefix=_default_,targetmd=_default_,targetprefix=_default_,
 sselect=_default_,sexclude=_default_,tselect=_default_,texclude=_default_,
 verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME   : mdmapmake
TYPE                    : metadata
DESCRIPTION             : Creates map metadata sets.  Optionally includes
                           information from existing metadata for source
                           or target of map.
DOCUMENT LIST           : \\spreeprd\genesis\SPREE\QA\General\Broad_use_modules\
                           SAS\mdmapmake\mdmapmake DL.doc
SOFTWARE/VERSION#       : SAS/Version 8 and 9
INFRASTRUCTURE          : MS Windows, MVS, Unix, SDD
BROAD-USE MODULES       : ut_parmdef ut_logical mdmake
INPUT                   : As defined by the SOURCEMD and TARGETMD parameters
OUTPUT                  : As define by the OUTLIB parameter
VALIDATION LEVEL        : 6
REGULATORY STATUS       : GCP
TEMPORARY OBJECT PREFIX : _mb
--------------------------------------------------------------------------------
Parameters:
Name         Type     Default    Description and Valid Values
------------ -------- ---------- --------------------------------------------------
OUTLIB       required work       Libref of output library where map metadata
                                  will be written
OUTPREFIX    optional            Prefix of output metadata set names
SOURCEMD     optional            Libref of existing metadata that will be used
                                  to populate source information in the map
                                  metadata
SOURCEPREFIX optional            Prefix of SOURCEMD metadata set names
TARGETMD     optional            Libref of existing metadata that will be used
                                  to populate target information in the map
                                  metadata
SSELECT      optional            
SEXCLUDE     optional            
TSELECT      optional            
TEXCLUDE     optional            
TARGETPREFIX optional            Prefix of TARGETMD metadata set names
VERBOSE      required 1          %ut_logical value specifying whether verbose mode
                                  is on or off
DEBUG        required 0          %ut_logical value specifying whether debug mode
                                  is on or off

--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

--------------------------------------------------------------------------------
     Author &
Ver#  Peer Reviewer   Request #        Broad-Use Module History Description
---- ---------------- ---------------- -----------------------------------------
1.0   <Author name>    <BUM Request#>  Original version of the broad-use module
       <Peer Reviewer name>

  **eoh************************************************************************/
*==============================================================================;
* Initialization;
*==============================================================================;
%ut_parmdef(outlib,_pdrequired=1,_pdmacroname=mdmapmake)
%ut_parmdef(outprefix,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(sourcemd,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(sourceprefix,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(sselect,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(sexclude,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(tselect,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(texclude,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(targetmd,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(targetprefix,_pdrequired=0,_pdmacroname=mdmapmake)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=mdmapmake)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdmapmake)
%ut_logical(verbose)
%ut_logical(debug)
%local i mdsn param paramrel;
%if %bquote(&sourcemd) ^= %then %do;
  *============================================================================;
  * Call mdmake to get metadata for source information;
  *============================================================================;
  %mdmake(inlib=&sourcemd,outlib=work,mode=replace,inprefix=&sourceprefix,
   outprefix=_mbsource,inselect=&sselect,inexclude=&sexclude,
   contents=0,verbose=&verbose,debug=&debug)
%end;
%if %bquote(&targetmd) ^= %then %do;
  *============================================================================;
  * Call mdmake to get metadata for target information;
  *============================================================================;
  %mdmake(inlib=&targetmd,outlib=work,mode=replace,inprefix=&targetprefix,
   outprefix=_mbtarget,,inselect=&tselect,inexclude=&texclude,
   contents=0,verbose=&verbose,debug=&debug)
%end;
*==============================================================================;
* Create tables meta data set;
*==============================================================================;
data &outlib..&outprefix.tables_map
 (label='Metadata Describing Table map');
  attrib source_table      length=$32 label='Table Name Source Metadata';
  attrib target_table      length=$32 label='Table Name Target Metadata';
  %if %bquote(&sourcemd) ^= & %bquote(&targetmd) = %then %do;
    set _mbsourcetables (keep=table rename=(table=source_table));
  %end;
  %else %if %bquote(&sourcemd) = & %bquote(&targetmd) ^= %then %do;
    set _mbtargettables (keep=table rename=(table=target_table));
  %end;
  %else %if %bquote(&sourcemd) ^= & %bquote(&targetmd) ^= %then %do;
    merge _mbsourcetables (in=fromsource keep=table)
          _mbtargettables (in=fromtarget keep=table);
    by table;
    if fromsource & fromtarget then do;
      source_table = table;
      target_table = table;
    end;
    else if fromsource & ^ fromtarget then do;
      source_table = table;
      target_table = ' ';
    end;
    else if ^ fromsource & fromtarget then do;
      source_table = ' ';
      target_table = table;
    end;
  %end;
  %if %bquote(&sourcemd) = | %bquote(&targetmd) = %then %do;
    if 0 then do;
      array cvars _character_;
      do i = 1 to dim(cvars);
        cvars{i} = ' ';
      end;
      drop i;
    end;
    %if %bquote(&sourcemd) = & %bquote(&targetmd) = %then %do;
      stop;
    %end;
  %end;
  keep source_table target_table;
run;
%*=============================================================================;
%* Create columns and columns_param meta data sets;
%*=============================================================================;
%do i = 1 %to 2;
  %if &i = 1 %then %do;
    %let mdsn = columns;
    %let param =;
    %let paramrel =;
  %end;
  %else %do;
    %let mdsn = columns_param;
    %let param = param;
    %let paramrel = paramrel;
  %end;
  *============================================================================;
  %bquote(* Create &mdsn meta data set;)
  *============================================================================;
  data &outlib..&outprefix.&mdsn._map (
   label="Metadata Describing Column &param map");
    attrib source_table        length=$32 label='Table Name Source Metadata';
    attrib source_column       length=$32 label='Column Name Source Metadata';
    %if %bquote(&param) ^= %then %do;
      attrib source_param    length=$32 label='Parameter Value Source Metadata';
      attrib source_paramrel length=$32 label='Name of PARAM related COLUMN Source Metadata';
    %end;
    attrib target_table        length=$32 label='Table Name Target Metadata';
    attrib target_column       length=$32 label='Column Name Target Metadata';
    %if %bquote(&param) ^= %then %do;
      attrib target_param    length=$32 label='Parameter Value Target Metadata';
      attrib target_paramrel length=$32 label='Name of PARAM related COLUMN Target Metadata';
    %end;
    %if %bquote(&sourcemd) ^= & %bquote(&targetmd) = %then %do;
      set _mbsource&mdsn (keep=table column &param &paramrel
       rename=(table=source_table column=source_column
       %if %bquote(&mdsn) = columns_param %then %do;
         param=source_param paramrel=source_paramrel
       %end;
       ));
    %end;
    %if %bquote(&sourcemd) = & %bquote(&targetmd) ^= %then %do;
      set _mbtarget&mdsn (keep=table column &param &paramrel
       rename=(table=target_table column=target_column
       %if %bquote(&mdsn) = columns_param %then %do;
         param=target_param paramrel=target_paramrel
       %end;
       ));
    %end;
    %if %bquote(&sourcemd) ^= & %bquote(&targetmd) ^= %then %do;
      merge _mbsource&mdsn (in=fromsource keep=table column &param &paramrel)
            _mbtarget&mdsn (in=fromtarget keep=table column &param &paramrel);
      by table column &param &paramrel;
      if fromsource & fromtarget then do;
        source_table = table;
        target_table = table;
        source_column = column;
        target_column = column;
        %if &mdsn = columns_param %then %do;
          source_param = param;
          source_paramrel = paramrel;
          target_param = param;
          target_paramrel = paramrel;
        %end;
      end;
      else if fromsource & ^ fromtarget then do;
        source_table = table;
        target_table = ' ';
        source_column = column;
        target_column = ' ';
        %if &mdsn = columns_param %then %do;
          source_param = param;
          source_paramrel = paramrel;
          target_param = ' ';
          target_parmrel = ' ';
        %end;
      end;
      else if ^ fromsource & fromtarget then do;
        source_table = ' ';
        target_table = table;
        source_column = ' ';
        target_column = column;
        %if &mdsn = columns_param %then %do;
          source_param = ' ';
          source_paramrel = ' ';
          target_param = param;
          target_parmrel = paramrel;
        %end;
      end;
    %end;
    %if %bquote(&sourcemd) = | %bquote(&targetmd) = %then %do;
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
      %if %bquote(&sourcemd) = & %bquote(&targetmd) = %then %do;
        stop;
      %end;
    %end;
    keep source_table source_column target_table target_column
     %if &mdsn = columns_param %then %do;
       source_param target_param source_paramrel target_paramrel
     %end;
    ;
  run;
%end;
*==============================================================================;
* Create values meta data set;
*==============================================================================;
data &outlib..&outprefix.values_map
 (label="Metadata Describing Valid Values of Column");
  attrib source_format     length=$13  label="Format Name Source Metadata";
  attrib source_start      length=$300 label='Start Value Source Metadata';
  attrib source_end        length=$300 label='End Value Source Metadata';
  attrib target_format     length=$13  label="Format Name Target Metadata";
  attrib target_start      length=$300 label='Start Value Target Metadata';
  attrib target_end        length=$300 label='End Value Target Metadata';
  %if %bquote(&sourcemd) ^= & %bquote(&targetmd) = %then %do;
    set _mbsourcevalues (keep=format start end
     rename=(format=source_format start=source_start end=source_end));
  %end;
  %if %bquote(&sourcemd) = & %bquote(&targetmd) ^= %then %do;
    set _mbtargetvalues (keep=format start end
     rename=(format=source_format start=source_start end=source_end));
  %end;
  %else %if %bquote(&sourcemd) ^= & %bquote(&targetmd) ^= %then %do;
    merge _mbsourcevalues (in=fromsource keep=format start end)
          _mbtargetvalues (in=fromtarget keep=format start end);
    by format start end;
    if fromsource & fromtarget then do;
      source_format = format;
      target_format = format;
      source_start = start;
      target_start = start;
      source_end = end;
      target_end = end;
    end;
    else if fromsource & ^ fromtarget then do;
      source_format = format;
      target_format = ' ';
      source_start = start;
      target_start = ' ';
      source_end = end;
      target_end = ' ';
    end;
    else if ^ fromsource & fromtarget then do;
      source_format = ' ';
      target_format = format;
      source_start = ' ';
      target_start = start;
      source_end = ' ';
      target_end = end;
    end;
  %end;
  %if %bquote(&sourcemd) = | %bquote(&targetmd) = %then %do;
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
    %if %bquote(&sourcemd) = & %bquote(&targetmd) = %then %do;
      stop;
    %end;
  %end;
  keep source_format source_start source_end target_format target_start
   target_end;
run;
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of mdmapmake macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _mb:;
  run; quit;
%end;
%mend;
