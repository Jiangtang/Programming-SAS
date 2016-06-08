%macro ut_os(osvar=_default_,sddvar=_default_,verbose=_default_,
 debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_os
   VERSION NUMBER           : 1
   TYPE                     : utility
   AUTHOR                   : Gregory Steffens
   DESCRIPTION              : Determines the operating system name and assigns
                               to a macro variable.
   SOFTWARE/VERSION#        : SAS/Version 8
   INFRASTRUCTURE           : Windows, MVS, Unix
   PEER REVIEWER            : <Enter broad-use module Peer Reviewer's name(s)>
   VALIDATION LEVEL         : 6
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                               Document List>
   REGULATORY STATUS        : GCP
   CREATION DATE            : <Enter date file was opened and coding began -
                               DD/MMM/YYYY> 
   TEMPORARY OBJECT PREFIX  : <Enter unique ID for each broad-use module.
                               See Broad-Use Module Request.>
   BROAD-USE MODULES        : ut_parmdef ut_logical
   INPUT                    : <List all files and their locations>
   OUTPUT                   : <List all files and their locations and 
                               file types>
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
   -------- -------- -------- --------------------------------------------------
   OSVAR    required os       The name of a macro variable to hold
                               the name of the operating system this macro is 
                               running in.
   SDDVAR   optional in_sdd   The name of a macro variable to hold SDD return -
                              Returns a value of 1 if running in SDD and a value
                               of 0 otherwise.
   VERBOSE  required 1         
   DEBUG    required 0        

--------------------------------------------------------------------------------
  Usage Notes:  <Parameter dependencies and additional information for the user>

    The value of osvar is usually the value of &sysscp, but it assigns a value
     of "unix" for any of the unix operating systems.  The case of the value
     of osvar is lower case.

--------------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %local os;
    %ut_os

--------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
  Ver#  Author           Description
  ----  ---------------  -------------------------------------------------------
  001   Gregory Steffens  Original version of the broad-use module

 **eoh*************************************************************************/
%ut_parmdef(debug,0,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_logical(debug)
%ut_parmdef(verbose,1,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_parmdef(osvar,os,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_parmdef(sddvar,in_sdd,_pdmacroname=ut_os,_pdrequired=1,_pdverbose=0)
%ut_logical(verbose)
%if &debug %then %put (ut_os) macro starting;
%*=============================================================================;
%* Assign value to sddvar variable   1 if running in SDD  0 otherwise;
%*=============================================================================;
%let &sddvar = 0;
%if &sysver ^= 8.2 %then %do;
  %if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms)
   %then %let &sddvar = 1;
%end;
%if &debug %then %put (ut_os) sddvar = &sddvar = &&&sddvar;
%*=============================================================================;
%* When &SYSSCP is one of the types of unix assign osvar a value of unix;
%*  otherwise assign osvar a value of &SYSSCP;
%*=============================================================================;
%if &sysscp = SUN 4 | &sysscp = SUN 64 | &sysscp = RS6000 | &sysscp = ALXOSF |
 &sysscp = HP 300 | &sysscp = HP 800 | &sysscp = LINUX | &sysscp = RS6000 | 
 &sysscp = SUN 3 | &sysscp = ALXOSF %then %let &osvar = unix;
%else %let &osvar = %sysfunc(lowcase(&sysscp));
%if &debug %then %put (ut_os) osvar = &osvar = &&&osvar  sysscp=&sysscp;
%if &debug %then %put (ut_os) macro ending;
%mend;
