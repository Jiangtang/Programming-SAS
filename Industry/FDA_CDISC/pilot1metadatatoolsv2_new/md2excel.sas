%macro md2excel(mdlib=_default_,select=_default_,exclude=_default_,
 excel_file=_default_,keepall=_default_,verbose=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME               : md2excel
CODE TYPE               : Broad-use Module
DESCRIPTION            	: <Provide brief description of the code purpose>
SOFTWARE/VERSION#      	: SAS/Version 9
INFRASTRUCTURE         	: MS Windows, MVS, SDD
BROAD-USE MODULES      	: ut_parmdef ut_logical mdmake
INPUT                  	: metadatabase as defined by the MDLIB parameter
OUTPUT                 	: excel file as defined by the EXCEL_FILE parameter
VALIDATION LEVEL       	: 6
REQUIREMENTS            : <reference the location of the requirements document (e.g. SAP, protocol, TFL requirements)
                          or type in the full detailed requirements>
ASSUMPTIONS            	: <Scope and preconditions that requirements are based on, if applicable: optional>
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _me

PARAMETERS:
Name       Type     Default Description and Valid Values
---------- -------- ------- ----------------------------------------------------
MDLIB      required         Libref of metadata library
EXCEL_FILE required         Full path name of excel file to create, including
                             the .xls file extension.  This file should not 
                             exist prior to calling md2excel.
SELECT     optional         
EXCLUDE    optional         
KEEPALL    required 0       
VERBOSE    required 1       %ut_logical specifying whether verbose mode is on
                             or off
DEBUG      required 0       %ut_logical specifying whether debug mode is on
                             or off

USAGE NOTES:

 This macro issues a SAS/Access libname, so SAS/Access to excel must be
 installed.

TYPICAL WAYS TO EXECUTE THIS CODE:

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver#  Peer Reviewer   Code History Description
---- ---------------- ----------------------------------------------------------
1.0  Gregory Steffens Original version of the code

**eoh**************************************************************************/
%ut_parmdef(mdlib,_pdmacroname=md2excel,_pdrequired=1)
%ut_parmdef(select,_pdmacroname=md2excel,_pdrequired=0)
%ut_parmdef(exclude,_pdmacroname=md2excel,_pdrequired=0)
%ut_parmdef(excel_file,_pdmacroname=md2excel,_pdrequired=1)
%ut_parmdef(keepall,0,_pdmacroname=md2excel,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=md2excel,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=md2excel,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)

%local os in_sdd;
%ut_os

%mdmake(inlib=&mdlib,outlib=work,outprefix=_me,inselect=&select,
 inexclude=&exclude,keepall=&keepall,verbose=&verbose,debug=&debug)

%if ^ &in_sdd %then %do;
  libname _mexcel excel "&excel_file";
  data _mexcel.tables;
    set _metables;
  run;
  data _mexcel.columns;
    set _mecolumns;
  run;
  data _mexcel.columns_param;
    set _mecolumns_param;
  run;
  data _mexcel.values;
    set _mevalues;
  run;
%end;
%else %do;
  %local now;
  data _null_;
    call symput('now',compress(put(datetime(),datetime18.0),': '));
    stop;
  run;
  signon;
  %syslput excel_file_sddxpath = %sysfunc(pathname(&excel_file));
  %syslput excel_file_pc = md&_sddusr_.&now..xls;
  rsubmit;
    options noxwait xsync;
    %nrstr(
     %put UNOTE: excel_file_sddxpath=&excel_file_sddxpath;
     %put excel_file_pc=&excel_file_pc;
     %put sysscp=&sysscp;
     %put _user_;
    )
    proc upload inlib=work outlib=work;
      select _metables _mecolumns _mecolumns_param _mevalues;
    run;
    %nrstr(    
     libname _mexcel excel "&excel_file_pc"; 
    )
    data _mexcel.tables;
      set _metables;
    run;
    data _mexcel.columns;
      set _mecolumns;
    run;
    data _mexcel.columns_param;
      set _mecolumns_param;
    run;
    data _mexcel.values;
      set _mevalues;
    run;
    libname _mexcel clear;
    %nrstr(
     proc download infile="&excel_file_pc" outfile="&excel_file_sddxpath"
      binary;
     run;
     data _null_;
       rc = system("del &excel_file_pc");
       put rc=;
       if rc ^= 0 then put 'UWARNING: temporary excel file not deleted';
       stop;
     run;
     %put _user_;
    )
    proc datasets lib=work nolist;
      delete _me:;
    run; quit;
  endrsubmit;
  signoff;
%end;

%if ^ &debug %then %do;
  %if ^ &in_sdd %then %do;
    libname _mexcel clear;
  %end;
  proc datasets lib=work nolist;
    delete _me: _medescriptions(memtype=catalog);
  run; quit;
%end;
%mend;
