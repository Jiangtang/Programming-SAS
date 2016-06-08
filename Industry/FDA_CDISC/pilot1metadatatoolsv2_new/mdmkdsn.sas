%macro mdmkdsn(mdlib=_default_,outlib=_default_,mdprefix=_default_,
 verbose=_default_,select=_default_,exclude=_default_,replace=_default_,
 debug=_default_);
/*soh===========================================================================
  Eli Lilly
   PROGRAM NAME    : mdmkdsn.sas            Temporary Object Prefix: _ik
   PROGRAMMER      : Gregory Steffens
   DESCRIPTION     : Creates all the data sets defined by the meta data sets 
                      with all variables and attributes but with zero obs.
   LANGUAGE/VERSION: SAS/Version 8
   INITIATION DATE : 20Jan2004
   VALIDATOR       : 
   INPUT FILE(S)   : meta data indicated by LIBREF parameter
   OUTPUT FILE(S)  : data sets defined by meta data written to OUTLIB
   XTRNL PROG CALLS: %ut_logical %ut_titlstrt %mdmake %mdatribs %ut_parmdef
   PROGRAM PATH    : /SPREE/RMP/Clinical//Neuroscience/Symbiax/Bioplar I 
                     Depression/H6P-US-HDAQ Acute/general/code_lib/sasmacro/
   REQUIREMENTS    : /SPREE/RMP/Clinical/Neuroscience/Symbiax/Bioplar I
                      Depression/H6P-US-HDAQ Acute/general/HDAQ Detailed
                      Dataset Requirements.doc
   VALIDATION LEVEL: as defined by a calling program
   REGULATORY STATUS: GCP 
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description
   -------- -------- -------- --------------------------------------------------
   MDLIB    required          Libref of meta data set library
   OUTLIB   required work     Libref of output data set library
   SELECT   optional          A blank delimited list of data sets defined in 
                               MDLIB that you want to create.  A null value
                               indicates all data sets are to be created.
   EXCLUDE  optional          
   MDPREFIX optional          
   REPLACE  required 0        %ut_logical value specifying whether existing data
                               sets in OUTLIB will be replaced by this macro.
                               If REPLACE is false the data sets in OUTLIB that
                               already exist there will not be created by this
                               macro.  If REPLACE is TRUE then data sets in
                               OUTLIB can be replaced by this macro.  If the 
                               data set defined in MDLIB does not exist in
                               OUTLIB then the data set will be created 
                               regardless of the value of REPLACE.
   VERBOSE  required 1        %ut_logical value turning verbose mode on and off
   DEBUG    required 1        %ut_logical value turning debug mode on and off

  Usage Notes:

  This macro translates double quotes to single quotes in data set and 
  variable labels.

--------------------------------------------------------------------------------
                         REVISION HISTORY
================================================================================
  REV#  Date       User ID   Description
  ----  ---------  --------  ---------------------------------------------------
  001   
eoh===========================================================================*/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%put (mdmkdsn) macro starting;
%ut_parmdef(mdlib,_pdmacroname=mdmkdsn)
%ut_parmdef(outlib,work,_pdmacroname=mdmkdsn)
%ut_parmdef(select,_pdmacroname=mdmkdsn)
%ut_parmdef(exclude,_pdmacroname=mdmkdsn)
%ut_parmdef(mdprefix,_pdmacroname=mdmkdsn)
%ut_parmdef(verbose,1,_pdmacroname=mdmkdsn)
%ut_parmdef(replace,0,_pdmacroname=mdmkdsn)
%ut_parmdef(debug,0,_pdmacroname=mdmkdsn)
%local titlstrt numdsns dsnnum dsns subsetdsns;
%ut_logical(verbose)
%ut_logical(replace)
%ut_logical(debug)
%ut_titlstrt
title&titlstrt "(mdmkdsn) Creating data in &outlib from meta data in &mdlib";
*==============================================================================;
* Get meta data descriptions of the required data;
*==============================================================================;
%mdmake(inlib=&mdlib,outlib=work,inselect=&select,inprefix=&mdprefix,
 outprefix=_mk,contents=0,debug=&debug)
*==============================================================================;
* Create a macro array of the data sets that need to be created;
*==============================================================================;
%let subsetdsns = 0;
%let numdsns = 0;
data _null_;
  if eof & numdsns > 0 then call symput('numdsns',compress(put(numdsns,5.0)));
  set _mktables end=eof;
  if upcase(type) ^= 'VIEW';
  %if ^ &replace %then %do;
    if exist("&outlib.." || trim(left(table))) then do;
      call symput('subsetdsns','1');
      return;
    end;
  %end;
  numdsns + 1;
  call symput('dsn' || compress(put(numdsns,5.0)),trim(left(table)));
  call symput('dsl' || compress(put(numdsns,5.0)),
   trim(left(translate(tlabel,"'",'"'))));
run;
%if &subsetdsns %then %do dsnnum = 1 %to &&numdsns;
  %let dsns = &dsns &&dsn&dsnnum;
%end;
%else %let dsns =;
%if &debug %then %do;
  %put (mdmkdsn) numdsns=&numdsns dsns=&dsns;
  %do dsnnum = 1 %to &numdsns;
    %put (mdmkdsn) &dsnnum dsn&dsnnum=&&dsn&dsnnum;
  %end;
%end;
*==============================================================================;
* Create data sets with 0 obs and 0 vars for mdattribs to start with;
*==============================================================================;
%if &numdsns > 0 %then %do dsnnum = 1 %to &numdsns;
  data &outlib..&&dsn&dsnnum (label="&&dsl&dsnnum");
    _mkvar = .;
    stop;
    drop _mkvar;
  run;
%end;
*==============================================================================;
* Call mdatribs to add the variables and their attributes;
*==============================================================================;
%mdatribs(mdlib=&mdlib,inlib=&outlib,outlib=&outlib,allatribs=1,
 select=&dsns,verbose=0,debug=&debug)
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of mdmkdsn macro;
  *============================================================================;
  proc datasets lib = work nolist;
    delete _mk:;
  run; quit;
%end;
title&titlstrt;
%put (mdmkdsn) macro ending;
%mend;
