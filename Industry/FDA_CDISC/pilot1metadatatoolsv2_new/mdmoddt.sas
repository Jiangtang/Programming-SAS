%macro mdmoddt(mdlib=_default_,mdprefix=_default_,outmvar=_default_,
 outfmt=_default_,verbose=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : mdmoddt
CODE TYPE           : Broad-use Module
DESCRIPTION         : Determines the most recent modification datetime of a
                       metadatabase.
SOFTWARE/VERSION#   : SAS/Version 9
INFRASTRUCTURE      : MS Windows, MVS, SDD
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : ut_parmdef ut_logical ut_errmsg
INPUT               : Metadata library designated by MDLIB and MDPREFIX
                       parameters
OUTPUT              : Macro variable as designated by the OUTMVAR parameter
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/
                       bums/mdmoddt/documentation/mdmoddt_rd.doc
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _mt

PARAMETERS: <enter N/A if no parameters>
Name      Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
MDLIB     required            Libref of input metadata members
MDPREFIX  optional            Prefix of metadata member names
OUTMVAR   required moddt      Name of macro variable that will be assiged the
                               formatted datetime of the most recently modified
                               metadata member.  This name cannot be any of
                               _mtdsid, _mtmod_most_recent or _mtmod_current.
OUTFMT    optional datetime19 Format to apply to the datetime value that 
                               populates OUTMVAR. (include the dot)
VERBOSE   required 1          %ut_logical value specifying whether verbose mode
                               is on or off
DEBUG     required 0          %ut_logical value specifying whether debug mode
                               is on or off

USAGE NOTES:

TYPICAL WAYS TO EXECUTE THIS CODE:

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver#  Peer Reviewer   Code History Description
---- ---------------- ----------------------------------------------------------
1.0  Gregory Steffens Original version of the code BMRGCS09Jan2008
      Russ Newhouse
  **eoh************************************************************************/
%ut_parmdef(mdlib,_pdrequired=1,_pdmacroname=mdmoddt,_pdverbose=1)
%ut_parmdef(mdprefix,_pdrequired=0,_pdmacroname=mdmoddt,_pdverbose=1)
%ut_parmdef(outmvar,moddt,_pdrequired=1,_pdmacroname=mdmoddt,_pdverbose=1)
%ut_parmdef(outfmt,datetime19.,_pdrequired=0,_pdmacroname=mdmoddt,_pdverbose=1)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=mdmoddt,_pdverbose=1)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdmoddt,_pdverbose=1)
%ut_logical(verbose)
%ut_logical(debug)
%local _mtdsid _mtmod_most_recent _mtmod_current;
%*=============================================================================;
%* Find the latest modification date of any meta data set and catalog entry;
%*  and issue title with this date appended;
%* _mtmod_current  : Modification datetime of current member;
%* _mtmod_most_recent : Modification datetime of most recently modified member so far;
%*=============================================================================;
%*=============================================================================;
%* TABLES;
%*=============================================================================;
%let _mtdsid = %sysfunc(open(&mdlib..&mdprefix.tables,i));
%if &_mtdsid > 0 %then %do;
  %let _mtmod_current = %sysfunc(attrn(&_mtdsid,modte));
  %let _mtdsid = %sysfunc(close(&_mtdsid));
  %let _mtmod_most_recent = &_mtmod_current;
  %ut_errmsg(msg=&mdlib..&mdprefix.tables 
   _mtmod_current=%sysfunc(compress(%sysfunc(putn(&_mtmod_current,datetime19.))))
   most recent=%sysfunc(compress(%sysfunc(putn(&_mtmod_most_recent,datetime19.)))),
   macroname=mdmoddt,print=0,debug=&debug)
%end;
%else %if &verbose %then
 %ut_errmsg(msg="cannot open &mdlib..&mdprefix.tables to determine "
 "modification date",macroname=mdmoddt,type=warning,debug=&debug);
%*=============================================================================;
%* COLUMNS;
%*=============================================================================;
%let _mtdsid = %sysfunc(open(&mdlib..&mdprefix.columns,i));
%if &_mtdsid > 0 %then %do;
  %let _mtmod_current = %sysfunc(compress(%sysfunc(attrn(&_mtdsid,modte))));
  %let _mtdsid = %sysfunc(close(&_mtdsid));
  %if &_mtmod_current > &_mtmod_most_recent %then
   %let _mtmod_most_recent = &_mtmod_current;
  %ut_errmsg(msg=&mdlib..&mdprefix.columns
   _mtmod_current=%sysfunc(compress(%sysfunc(putn(&_mtmod_current,datetime19.))))
   most recent=%sysfunc(compress(%sysfunc(putn(&_mtmod_most_recent,datetime19.)))),
   macroname=mdmoddt,print=0,debug=&debug)
%end;
%else %if &verbose %then
 %ut_errmsg(msg="cannot open &mdlib..&mdprefix.columns to determine "
 "modification date",macroname=mdmoddt,type=warning,debug=&debug);
%*=============================================================================;
%* COLUMNS_PARAM;
%*=============================================================================;
%let _mtdsid = %sysfunc(open(&mdlib..&mdprefix.columns_param,i));
%if &_mtdsid > 0 %then %do;
  %let _mtmod_current = %sysfunc(compress(%sysfunc(attrn(&_mtdsid,modte))));
  %let _mtdsid = %sysfunc(close(&_mtdsid));
  %if &_mtmod_current > &_mtmod_most_recent %then %let _mtmod_most_recent = &_mtmod_current;
  %ut_errmsg(msg=&mdlib..&mdprefix.columns_param
   _mtmod_current=%sysfunc(compress(%sysfunc(putn(&_mtmod_current,datetime19.))))
   most recent=%sysfunc(compress(%sysfunc(putn(&_mtmod_most_recent,datetime19.)))),
   macroname=mdmoddt,print=0,debug=&debug)
%end;
%else %if &verbose %then 
%ut_errmsg(msg="cannot open &mdlib..&mdprefix.columns_param to "
 "determine modification date",macroname=mdmoddt,type=warning,debug=&debug);
%*=============================================================================;
%* VALUES;
%*=============================================================================;
%let _mtdsid = %sysfunc(open(&mdlib..&mdprefix.values,i));
%if &_mtdsid > 0 %then %do;
  %let _mtmod_current = %sysfunc(compress(%sysfunc(attrn(&_mtdsid,modte))));
  %let _mtdsid = %sysfunc(close(&_mtdsid));
  %if &_mtmod_current > &_mtmod_most_recent %then
   %let _mtmod_most_recent = &_mtmod_current;
  %ut_errmsg(msg=&mdlib..&mdprefix.values
   _mtmod_current=%sysfunc(compress(%sysfunc(putn(&_mtmod_current,datetime19.))))
   most recent=%sysfunc(compress(%sysfunc(putn(&_mtmod_most_recent,datetime19.)))),
   macroname=mdmoddt,print=0,debug=&debug)
%end;
%else %if &verbose %then
 %ut_errmsg(msg="cannot open &mdlib..&mdprefix.values to determine "
 "modification date",macroname=mdmoddt,type=warning,debug=&debug);
%*=============================================================================;
%* DESCRIPTIONS;
%*=============================================================================;
%if %sysfunc(cexist(&mdlib..&mdprefix.descriptions)) %then %do;
  proc catalog catalog = &mdlib..&mdprefix.descriptions;
    contents out = _mtcontdesc;
  run; quit;
  %let _mtmod_current =;
  data _null_;
    length date $ 8 moddate 8;
    if eof then do;
      call symput('_mtmod_current',trim(left(put(_mtmod_current,32.2))));
      %ut_errmsg(msg='catalog ' _mtmod_current= _mtmod_current : datetime19.,
       macroname=mdmoddt,print=0,debug=&debug)
    end;
    set _mtcontdesc (keep=date moddate) end=eof;
    if _n_ = 1 then _mtmod_current = moddate;
    else if moddate > _mtmod_current then _mtmod_current = moddate;
    retain _mtmod_current;
  run;
  %if &_mtmod_current > &_mtmod_most_recent %then
   %let _mtmod_most_recent = &_mtmod_current;
  %ut_errmsg(msg=&mdlib..&mdprefix.descriptions catalog
   _mtmod_current=%sysfunc(compress(%sysfunc(putn(&_mtmod_current,datetime19.))))
   most recent=%sysfunc(compress(%sysfunc(putn(&_mtmod_most_recent,datetime19.)))),
   macroname=mdmoddt,print=0,debug=&debug)
%end;
%else %if &verbose %then
 %ut_errmsg(msg="cannot open &mdlib..&mdprefix.descriptions to determine "
 "modification date",macroname=mdmoddt,type=warning,debug=&debug);
%*=============================================================================;
%* Populate output macro variable with formatted datetime of most recent;
%*  metadata modification;
%*=============================================================================;
%if %bquote(&outfmt) ^= %then %do;
  %let _mtmod_most_recent = %sysfunc(putn(&_mtmod_most_recent,&outfmt));
%end;
%ut_errmsg(msg=_mtmod_most_recent=&_mtmod_most_recent,macroname=mdmoddt,print=0,
 debug=&debug)
%if %bquote(&outmvar) ^= %then %let &outmvar = &_mtmod_most_recent;
*==============================================================================;
* Cleanup at end of mdmoddt macro;
*==============================================================================;
%if ^ &debug & %sysfunc(cexist(&mdlib..&mdprefix.descriptions)) %then %do;
  proc datasets lib=work nolist;
    delete _mt:;
  run; quit;
%end;
%mend;
