%macro mdport(mdlib=_default_,mdprefix=_default_,select=_default_,
 exclude=_default_,mdmake=_default_,outfile=_default_,ftp=_default_,
 host=_default_,verbose=_default_,debug=_default_);
/*soh===========================================================================
  Eli Lilly
   PROGRAM NAME    : mdport.sas            Temporary Object Prefix: _mdport
   TYPE            : user utility
   PROGRAMMER      : Greg Steffens
   DESCRIPTION     : Creates a SAS transport file containing all metadata sets
                      and the descriptions catalog. This can be used to backup
                      a metadatabase or to send metadata somewhere as one 
                      transport file that can be imported on any platform.
   LANGUAGE/VERSION: SAS/Version 8
   VALIDATOR       :
   INITIATION DATE : 18Jun2004
   INPUT FILE(S)   : none
   OUTPUT FILE(S)  : none
   XTRNL PROG CALLS: ut_parmdef ut_logical ut_mdmake
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description
   -------- -------- -------- --------------------------------------------------
   MDLIB    required          Libref of SAS library that includes the metadata
   MDPREFIX optional          Prefix to apply to the metadata set names
   SELECT   optional          Blank delimited list of data set names defined
                               by the metadata to include in the transport file.
                               All data sets are included by default.  The
                               MDMAKE parameter must have a true value for
                               the SELECT parameter to be activated.
   EXCLUDE  optional          Blank delimited list of data set names defined
                               by the metadata to exclude from the transport
                               file.  No data sets are excluded by default.  The
                               MDMAKE parameter must have a true value for
                               the EXCLUDE parameter to be activated.
   OUTFILE  required          physical path of tranport file to create
   FTP      required 0        %ut_logical value specifying whether or not to 
                               ftp the transport file to OUTFILE.  When the 
                               transport file is to be created on a different
                               operating system than the one where the SAS 
                               session is executing then ftp should usually be 
                               true.  For example, when running a PC SAS session
                               to create a transport file on MVS you should
                               set the FTP parameter to a true value.
   HOST     optional MVS      Name of the host to create OUTFILE on when FTP
                               has a true value.
   MDMAKE   required 1        %ut_logical value specifying whether to call 
                               the mdmake macro to process the metadata 
                               before creating the transport file.  If MDMAKE
                               is false then SELECT and EXCLUDE are not 
                               processed.  MDMAKE will add or drop variables to
                               the metadata to make it strictly in conformance
                               with the standard metadata structure.
   VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                               is on or off
   DEBUG    required 0        %ut_logical value specifying whether debug mode is
                               on or off

  Usage Notes:

  Typical Macro Calls:


--------------------------------------------------------------------------------
                         REVISION HISTORY
================================================================================
  REV#  Date       User ID   Description
  ----  ---------  --------  ---------------------------------------------------
  001   ddmmmyyyy
eoh===========================================================================*/

%ut_parmdef(mdlib,_default_,_pdrequired=1,_pdmacroname=mdport)
%ut_parmdef(mdprefix,_pdmacroname=mdport)
%ut_parmdef(select,_default_,_pdmacroname=mdport)
%ut_parmdef(exclude,_default_,_pdmacroname=mdport)
%ut_parmdef(verbose,_default_,_pdrequired=1,_pdmacroname=mdport)
%ut_parmdef(outfile,_pdrequired=1,_pdmacroname=mdport)
%ut_parmdef(mdmake,1,_pdrequired=1,_pdmacroname=mdport)
%ut_parmdef(ftp,0,_pdrequired=1,_pdmacroname=mdport)
%ut_parmdef(host,MVS,_pdrequired=0,_pdmacroname=mdport)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdport)
%ut_logical(debug)
%ut_logical(mdmake)
%ut_logical(ftp)
%local inlib;

%if &mdmake %then %do;
  %mdmake(inlib=&mdlib,select=&select,exclude=&exclude,outlib=work,mode=replace,
   verbose=&verbose,inprefix=&mdprefix,outprefix=&mdprefix,debug=&debug)
  %let inlib = work;
%end;
%else %do;
  %let inlib = &mdlib;
%end;

%if &ftp %then %do;
  filename _mdport ftp "&outfile" lrecl=80 blocksize=8000 recfm=f
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
  filename _mdport "&outfile";
%end;

proc cport lib = &inlib    file = _mdport;
 select &mdprefix.tables (memtype=data) &mdprefix.columns (memtype=data) 
  &mdprefix.columns_param (memtype=data) &mdprefix.values (memtype=data) 
  &mdprefix.descriptions (memtype=catalog);
run;

filename _mdport clear;

%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete &mdprefix.tables (memtype=data) &mdprefix.columns (memtype=data) 
     &mdprefix.columns_param (memtype=data) &mdprefix.values (memtype=data) 
     &mdprefix.descriptions (memtype=catalog);
  run; quit;
%end;

%mend mdport;
