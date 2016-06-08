%macro ut_progname(outvar=_default_,outvnum=_default_,verbose=_default_,
 debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_progname
   VERSION NUMBER           : 1
   TYPE                     : utility
   AUTHOR                   : Gregory Steffens
   DESCRIPTION              : <Provide brief description of requirements>
   SOFTWARE/VERSION#        : SAS/Version 8
   INFRASTRUCTURE           : Windows, MVS
   PEER REVIEWER            : <Enter broad-use module Peer Reviewer's name(s)>
   VALIDATION LEVEL         : 6
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                               Document List>
   REGULATORY STATUS        : <Enter status [GCP, GLP, GMP, GPP, NDR (nondrug
                               related) regulations, non-regulated, or N/A.]>
   CREATION DATE            : <Enter date file was opened and coding began -
                               DD/MMM/YYYY> 
   TEMPORARY OBJECT PREFIX  : _pn
   BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt
   INPUT                    : <List all files and their locations>
   OUTPUT                   : <List all files and their locations and 
                               file types>
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
   -------- -------- -------- --------------------------------------------------
   OUTVAR   required sasprog  Root name of macro array created by this macro.
                               The numbers "1", "2" etc will be added to the 
                               end of this root name when creating the macro
                               variables that are the array elements.
   OUTVNUM  required numprogs Name of macro variable created that contains the
                               number of elements in the macro variable array
                               OUTVAR
   VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                               is on or off
   DEBUG    required 0        %ut_logical value specfifying whether debug mode
                               is on or off

--------------------------------------------------------------------------------
  Usage Notes:  <Parameter dependencies and additional information for the user>

--------------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:


--------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
  Ver#  Author           Description
  ----  ---------------- -------------------------------------------------------
  001   Gregory Steffens Original version of the broad-use module
 **eoh*************************************************************************/
%ut_parmdef(outvar,sasprog,_pdmacroname=ut_progname,_pdrequired=1)
%ut_parmdef(outvnum,numprogs,_pdmacroname=ut_progname,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=ut_progname,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_progname,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt prognum sysin os in_sdd;
%ut_titlstrt
%ut_os;

%if &os = win %then %do;
  %let sysin = %sysfunc(getoption(sysin));
  %if &debug %then %do;
    %put (ut_progname) Submitted file path is in env var SAS_EXECFILEPATH=%sysget(SAS_EXECFILEPATH).;
    %put (ut_progname) Submitted file name is in env var SAS_EXECFILENAME=%sysget(SAS_EXECFILENAME).;
    %put (ut_progname) sysin=&sysin;
    %put (ut_progname) sysprocessname=&sysprocessname;
  %end;
%end;

%if &debug %then %put (ut_progname) in_sdd=&in_sdd;
%if &in_sdd %then %do;
  data _null_;
    length path filename $ 500;
    if eof then do;
      call symput("&outvar.1",trim(left(path)) || '/' || trim(left(filename)));
      %if &debug %then %do;
        put path= filename=;
      %end;
    end;
    set &sddparms (keep=id valtype value  where = (id = '<process>')) end=eof;
    if valtype = 'path' then path = value;
    else if valtype = 'filename' then filename = value;
    retain path filename;
  run;
  %if %bquote(&&&outvar.1) = %then %let &outvar.1 = &_sddprc_;
  %let &outvnum = 1;
  %if &debug %then %put (ut_progname) outvar = &outvar.1 = &&&outvar.1;
  %if &debug %then %put (ut_progname) outvnum = &outvnum = &&&outvnum;
%end;
%else %do;
  proc sql noprint;
    create table _pnextfiles as select * from dictionary.extfiles;
  quit;
  %if &debug %then %do;
    proc print;
      title&titlstrt '(ut_progname) dictionary.extfiles';
    run;
    title&titlstrt;
  %end;
  data sas_progs_ln;
    if eof then call symput("&outvnum",trim(left(put(max(prognum,0),4.0))));
    set _pnextfiles
     %if &sysscp = WIN %then %do;
       (where = (left(reverse(upcase(xpath))) =: 'SAS.' & upcase(fileref) =: '#LN'))
     %end;
     %else %if &sysscp = OS %then %do;
       (where = (upcase(fileref) =: 'SYSIN'))
     %end;
     end=eof;
    prognum + 1;
    call symput("&outvar" || trim(left(put(prognum,4.0))),trim(left(xpath)));
  run;
  %if &debug %then %do;
    %put (ut_progname) &outvnum=&&&outvnum;
    %do prognum = 1 %to &&&outvnum;
      %put (ut_progname) &outvar&prognum=&&&outvar&prognum;
    %end;
    proc print data = sas_progs_ln  width=minimum;
      title&titlstrt
       '(ut_progname) dictionary.extfiles with xpath ending with .sas';
    run;
    title&titlstrt;
  %end;
%end;
%mend;
