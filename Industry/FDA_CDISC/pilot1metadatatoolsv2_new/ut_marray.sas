%macro ut_marray(invar=_default_,outvar=_default_,outnum=_default_,
 dlm=_default_,varlist=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME   : ut_marray
TYPE                    : utility
DESCRIPTION             : Creates an array of macro variables containing
                           delimited values from an input variable.
                          Creates an array of variables from one variable
                           which has a list of values.
REQUIREMENTS            : https://sddchippewa.sas.com/webdav/lillyce/qa/general/
                           bums/mdmoddt/documentation/ut_marray_rd.doc
SOFTWARE/VERSION#       : SAS/Version 8 and 9
INFRASTRUCTURE          : MS Windows, MVS, SDD
BROAD-USE MODULES       : ut_parmdef ut_logical
INPUT                   : one macro variable as defined by INVAR parameter
OUTPUT                  : macro variables as defined by the OUTVAR parameter
VALIDATION LEVEL        : 6
REGULATORY STATUS       : GCP
TEMPORARY OBJECT PREFIX : none required
--------------------------------------------------------------------------------
Parameters:
 Name     Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
INVAR     required            Name of variable containing list of tokens to 
                               put into array elements
OUTVAR    required            Stem of the name of the array variables (i.e. 
                               the name without the numbers)
OUTNUM    required see note   Name of the variable returning the number of 
                               array elements created to the caller. The default
                               value is "num" followed by the value of
                               the OUTVAR parameter.
DLM       required blank ,    Delimeters between tokens in INVAR parameter
VARLIST   optional            Name of variable that returns the list of array
                               element names to the caller
VERBOSE   required 0          ut_logical value specifying whether verbose mode
                               is on or off
DEBUG     required 0          ut_logical value to turn debug mode on or off
--------------------------------------------------------------------------------
Usage Notes:

     The intended use of ut_marray is to be called by another macro to create
     an array of macro variables each element of which has as a value an item
     in a list of items passed into the macro via INVAR.

     %local dsnelems numdsns;
     %ut_marray(invar=dsnlist,outvar=dsn,outnum=numdsns,varlist=dsnelems);
     %local &dsnelems;
     %ut_marray(invar=dsnlist,outvar=dsn,outnum=numdsns)

  when %ut_marray is called with varlist it creates a list of macro array
  variable element names in the varlist variable.  This allows the caller to
  declare the array variables as local to the calling macro.  The second call
  without varlist creates the macro array but the variables are now local to
  the caller rather than local to ut_marray.  The array elements are named
  dsn1 dsn2 etc. and can be referenced by the calling macro as &&dsn&i where
  i is the index to the array.
--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

--------------------------------------------------------------------------------
     Author &
Ver# Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMRGCS01Apr2005A Original version of the broad-use module
                                        01Apr2005
1.1  Gregory Steffens BMRMSR21FEB2007C Migration to SAS version 9
       Michael Fredericksen
2.0  Gregory Steffens BMRGCS12Dec2007  Migration to SDD
      Russ Newhouse
  **eoh************************************************************************/
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=ut_marray,_pdverbose=0)
%ut_logical(debug)
%ut_parmdef(invar,_pdrequired=1,_pdmacroname=ut_marray,_pdverbose=&debug)
%ut_parmdef(outvar,_pdrequired=1,_pdmacroname=ut_marray,_pdverbose=&debug)
%ut_parmdef(outnum,num&outvar,_pdrequired=1,_pdmacroname=ut_marray,
 _pdverbose=&debug)
%ut_parmdef(dlm,%str( %,),_pdrequired=1,_pdmacroname=ut_marray,
 _pdverbose=&debug)
%ut_parmdef(varlist,_pdrequired=0,_pdmacroname=ut_marray,_pdverbose=&debug)
%ut_parmdef(verbose,0,_pdrequired=1,_pdmacroname=ut_marray,_pdverbose=&debug)
%ut_logical(verbose)
%local _amincpy _manextv _mai;
%if &debug %then %put ut_marray macro starting;
%if %bquote(&&&invar) ^= %then %do;
  %*===========================================================================;
  %* SCAN the list of tokens in INVAR and create an array of macro variables;
  %*  whose values are the tokens;
  %*===========================================================================;
  %if %bquote(&invar) ^= %then
   %let _amincpy = %sysfunc(compbl(%bquote(&&&invar)));
  %if &debug %then %put (ut_marray) &invar=&&&invar _amincpy=&_amincpy;
  %if %bquote(&varlist) ^= %then %let &varlist =;
  %let _manextv = %scan(%bquote(&_amincpy),1,&dlm);
  %let _mai = 1;
  %do %while (%bquote(&_manextv) ^=);
    %if %bquote(&outvar) ^= %then %do;
      %let &outvar&_mai = &_manextv;
      %if %bquote(&varlist) ^= %then %let &varlist = &&&varlist &outvar&_mai;
    %end;
    %let _mai = %eval(&_mai + 1);
    %let _manextv = %scan(%bquote(&_amincpy),&_mai,&dlm);
  %end;
  %if %bquote(&outnum) ^= %then %let &outnum = %eval(&_mai - 1);
%end;
%else %do;
  %if %bquote(&outnum) ^= %then %let &outnum = 0;
  %if %bquote(&varlist) ^= %then %let &varlist =;
%end;
%if &debug %then %do;
  %*===========================================================================;
  %* Print the macro array when debug mode is on;
  %*===========================================================================;
  %put (ut_marray) &outnum=&&&outnum;
  %if %bquote(&varlist) ^= %then %put (ut_marray) &varlist=&&&varlist;
  %do _mai = 1 %to &&&outnum;
    %put (ut_marray) &outvar&_mai=&&&outvar&_mai;
  %end;
  %put ut_marray macro ending;
%end;
%mend;
