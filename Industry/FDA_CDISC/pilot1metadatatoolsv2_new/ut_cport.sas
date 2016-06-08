%macro ut_cport(lib=_default_,select=_default_,exclude=_default_,
 file=_default_,host=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : ut_cport
TYPE                     : utility
DESCRIPTION              : Creates a SAS transport file from a SAS library.
                            The transport file can be written to a local or
                            remote host.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\Clinical\
                            Broad-Use Modules\SAS\UT_CPORT\
                            Validation Deliverables\UT_CPORT DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical
INPUT                    : SAS library as defined by LIB parameter
OUTPUT                   : transport file as defined by FILE parameter
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _cp
--------------------------------------------------------------------------------
Parameters:
 Name     Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
LIB       required            Libref of SAS library that includes the data
                               library to be put in the transport file
SELECT    optional            Blank delimited list of data set names defined
                               by the metadata to include in the transport file.
                               All data sets are included by default.
EXCLUDE   optional            Blank delimited list of data set names defined
                               by the metadata to exclude from the transport
                               file.  No data sets are excluded by default. 
FILE      required             physical path of tranport file to create
HOST      optional            Name of the foreign host to create OUTFILE on. 
                               When HOST is specified, ftp will be used to copy
                               FILE to the foreign host.  When HOST is not
                               specified, FILE will be created on a local file
                               system.
VERBOSE   required 1          %ut_logical value specifying whether verbose mode
                               is on or off
DEBUG     required 0          %ut_logical value specfifying whether debug mode
                               is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

    I. To create a transport file on MVS from a PC library
        libname in 'd:\mactest\ut_cport\testdata\' access=readonly;
        %ut_cport(lib=in,file=C037083.TEST.CPORT,host=mvs)

    II. To create a transport file on the PC from a PC library
        libname in 'd:\mactest\ut_cport\testdata\' access=readonly;
        %ut_cport(lib=in,file=d:\mactest\ut_cport\testdata\cport.xpt)

    III. To create a transport file on MVS from an MVS library
        libname in 'rmp.some.study.library' access=readonly;
        %ut_cport(lib=in,file=.cport.xpt)
--------------------------------------------------------------------------------
     Author &
Ver# Peer Reviewer     Request #        Broad-Use MODULE History Description
---- ----------------- --------------- -----------------------------------------
1.0   Gregory Steffens BMRGCS09Feb2005A Original version of the broad-use module
       Nihar Ranjan
1.1   Gregory Steffens BMRMRM21FEB2007C SAS version 9 migration
       Michael Fredericksen
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(lib,_pdrequired=1,_pdmacroname=ut_cport)
%ut_parmdef(select,_pdmacroname=ut_cport)
%ut_parmdef(exclude,_pdmacroname=ut_cport)
%ut_parmdef(file,_pdrequired=1,_pdmacroname=ut_cport)
%ut_parmdef(host,_pdrequired=0,_pdmacroname=ut_cport)
%ut_parmdef(verbose,0,_pdrequired=1,_pdmacroname=ut_cport)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=ut_cport)
%ut_logical(verbose)
%ut_logical(debug)
*==============================================================================;
* Issue FILENAME statement pointing to output transport file;
*==============================================================================;

%* FILE must not contain the directory when ftping to unix so parse the
   directory from FILE and specify in CD parameter of FILENAME;

%if %bquote(&host) ^= %then %do;
  filename _cpport ftp "&file" lrecl=80 blocksize=8000 recfm=f
   host="&host" prompt
   %if %bquote(%upcase(&host)) = MVS %then %do;
     rcmd='site blocksize=8000 recfm=fb lrecl=80'
   %end;
   %if &debug %then %do;
     debug
   %end;
  ;
%end;
%else %do;
  filename _cpport "&file";
%end;
filename _cpport list;
*==============================================================================;
* Call CPORT to create transport file;
*==============================================================================;
proc cport lib = &lib    file = _cpport;
  %if %bquote(&select) ^= %then %do;
    select &select;
  %end;
  %if %bquote(&exclude) ^= %then %do;
    exclude &exclude;
  %end;
run;
%*=============================================================================;
%* Cleanup at end of macro;
%*=============================================================================;
%if ^ &debug %then %do;
  filename _cpport clear;
%end;
%mend;
