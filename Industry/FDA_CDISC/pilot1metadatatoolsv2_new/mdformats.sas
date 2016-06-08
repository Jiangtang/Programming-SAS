%macro mdformats(mdlib=_default_,outlib=_default_,outdata=_default_,
 outcat=_default_,inprefix=_default_,select=_default_,exclude=_default_,
 verbose=_default_,alterpswd=_default_,fmtlib=_default_,catkill=_default_,
 flabeltype=_default_,debug=_default_);
/*soh===========================================================================
  Eli Lilly
   PROGRAM NAME    : mdformats.sas            Temporary Object Prefix: _mf
   TYPE            : user utility
   PROGRAMMER      : Greg Steffens
   DESCRIPTION     : Create a format catalog from metadata
   LANGUAGE/VERSION: SAS/Version 8
   VALIDATOR       : 
   INITIATION DATE : 16Apr2004
   INPUT FILE(S)   : none
   OUTPUT FILE(S)  : none
   XTRNL PROG CALLS: ut_parmdef ut_logical mdmake
--------------------------------------------------------------------------------
  Parameters:
   Name      Type     Default  Description
   --------  -------- -------- -------------------------------------------------
   MDLIB     required          Libref of library containing metadata
   OUTLIB    required work     Libref of output library where the output format
                                catalog and data set will be created by this
                                macro.
   OUTDATA   optional formats  Name of data set containing format information to
                               output.  If null then no output data set will be
                               be created.
   OUTCAT    required formats  Name of output format catalog.  Formats will be
                                added to or replaced in this catalog if it 
                                already exists.  If it does not exist then it
                                will be created with the formats derived from 
                                MDLIB.values.  c.f. CATKILL.
   CATKILL   required 0        %ut_logical values specifying whether to delete
                                all catalog entries in OUTCAT prior to creating
                                the new formats in OUTCAT.  
   FLABELTYPE required flabel  Name of the variable in MDLIB values data set 
                                that contains the format label.  This parameter
                                must equal flabel or flabellong.
   FMTLIB    required 1        %ut_logical value specifying whether or not to
                                print the formats in the OUTCAT format catalog
                                after adding the new formats.
   INPREFIX  optional          Prefix to apply to metadata set names in MDLIB
   SELECT    optional          Blank delimited list of data sets defined by
                                metadata for which to create formats.  If this
                                parameter is not specified then all data set
                                formats will be processed - c.f. EXCLUDE.
   EXCLUDE   optional          Blank delimited list of data sets defined by
                                metadata to exclude from processing.  If this
                                parameter is not specified then no data set
                                formats will be excluded - c.f. SELECT.
   VERBOSE   required 1        %ut_logical value specifying whether verbose mode
                                is on or off
   ALTERPSWD optional          Alter password - specify if an alter password is
                                defined for the metadata in MDLIB
   DEBUG     required 0        %ut_logical value specifying whether debug mode
                                is on or off

  Usage Notes:

  Typical Macro Calls:

    %studyrefs(project=aaaa);
    %mdformats(mdlib=m,outlib=a)


--------------------------------------------------------------------------------
                         REVISION HISTORY
================================================================================
  REV#  Date       User ID   Description
  ----  ---------  --------  ---------------------------------------------------
  001   ddmmmyyyy
eoh===========================================================================*/
%put (mdformats) starting macro;
%ut_parmdef(mdlib,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(outlib,work,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(fmtlib,1,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(outdata,formats,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(outcat,formats,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(catkill,0,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(flabeltype,flabel,flabel flabellong FLABEL FLABELLONG,
 _pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(inprefix,_pdmacroname=mdformats,_pdrequired=0,_pdverbose=1)
%ut_parmdef(select,_pdmacroname=mdformats,_pdrequired=0,_pdverbose=1)
%ut_parmdef(exclude,_pdmacroname=mdformats,_pdrequired=0,_pdverbose=1)
%ut_parmdef(verbose,1,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_parmdef(alterpswd,_pdmacroname=mdformats,_pdrequired=0,_pdverbose=1)
%ut_parmdef(debug,0,_pdmacroname=mdformats,_pdrequired=1,_pdverbose=1)
%ut_logical(fmtlib)
%ut_logical(catkill)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt;
%ut_titlstrt
*==============================================================================;
* Read metadata;
*==============================================================================;
%mdmake(inlib=&mdlib,outlib=work,mode=replace,inprefix=&inprefix,outprefix=_mf,
 alterpswd=&alterpswd,contents=0,debug=&debug)
*==============================================================================;
* Determine which objects in values are formats rather than valid values;
*==============================================================================;
proc sort data = _mfvalues (keep=format flabel where = (flabel ^= ' ')) 
 out = _mfvalfmts (keep=format)  nodupkey;
  by format;
run;
data _mfvalues;
  merge _mfvalues (in=fromvals)  _mfvalfmts (in=fromfmts);
  by format;
  if fromvals & fromfmts;
run;
*==============================================================================;
* Determine type of format from columns metadata;
*==============================================================================;
data _mfcolfmts;
  set _mfcolumns (keep = cformat ctype clength cformatflag
       rename=(cformat=format ctype=type cformatflag=formatflag))
      _mfcolumns_param (keep = pformat ptype plength pformatflag
       rename=(pformat=format ptype=type pformatflag=formatflag))
  ;
  if format ^= ' ';
  keep format type;
run;
proc sort data = _mfcolfmts  nodupkey;
  by format type;
run;
*==============================================================================;
* Merge with values metadata to create a cntlin data set for proc format;
*==============================================================================;
proc sql;
  create table _mfcntlin as
   select _mfvalues.*, _mfcolfmts.type from _mfvalues, _mfcolfmts
   where _mfvalues.format = _mfcolfmts.format & _mfvalues.format ^= ' ';
run; quit;
proc sort data = _mfcntlin;
  by format type start end;
run;

%* add length to cntlin data set based on length of label values and clength?;
%* default length is automatically longest label value;
%* min is 1 and max is 40 until label is > 40 then it is same as default length;

data _mfdups  _mfbadend  _mfcntlin;
  set _mfcntlin;
  by format type start;
  if first.start + last.start ^= 2 then output _mfdups;
  if start ^= ' ' & end = ' ' then end = start;
  if end < start then do;
    output _mfbadend;
  end;
  if first.start then output _mfcntlin;
run;
proc print data = _mfdups width=minimum;
  title&titlstrt "(mdformats) Duplicate value ranges in &mdlib..values";
run;
proc print data = _mfbadend width=minimum;
  title&titlstrt "(mdformats) End less than Start in &mdlib..values";
run;
%if &debug %then %do;
  proc print data = _mfcntlin width=minimum;
    by format type;
    title&titlstrt "(mdformats) _mfcntlin data set for proc format cntlin";
  run;
%end;
title&titlstrt;
*==============================================================================;
* Create the format catalog and the output data set;
*==============================================================================;
%if &catkill & %sysfunc(cexist(&outlib..&outcat)) %then %do;
  proc catalog catalog=&outlib..&outcat kill;
  run;
%end;
proc format cntlin = _mfcntlin (rename=(format=fmtname
 %if %upcase(&flabeltype) = FLABEL %then %do;
   flabel=label
 %end;
 %else %do;
   flabellong=label
 %end;
 ))
 lib = &outlib..&outcat
 %if &fmtlib %then %do;
   fmtlib
 %end;
;
run;
%if %bquote(&outdata) ^= %then %do;
  data &outlib..&outdata;
    set _mfcntlin;
  run;
%end;
*==============================================================================;
* Cleanup at end of the macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib = work nolist;
    delete _mf:;
  run; quit;
%end;
title&titlstrt;
%put (mdformats) ending macro;
%mend mdformats;
