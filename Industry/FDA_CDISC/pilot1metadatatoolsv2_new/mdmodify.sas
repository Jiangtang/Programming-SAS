%macro mdmodify(mdlib1=,mdlib2=,mode=,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : mdmodify
   VERSION NUMBER           : 1
   TYPE                     : utility
   AUTHOR                   : Greg Steffens
   DESCRIPTION              : Delete a data set definition, rename a data set, 
                               delete a variable definition or rename a variable
   SOFTWARE/VERSION#        : SAS/Version 8
   INFRUSTRUCTURE           : Windows
   PEER REVIEWER            : <Enter broad-use module Peer Reviewer's name(s)>
   VALIDATION LEVEL         : 6
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                               Document List>
   REGULATORY STATUS        : GCP
   CREATION DATE            : 14Jul2004
   TEMPORARY OBJECT PREFIX  : _mm
   BROAD-USE MODULES        : <List other modules called by this module>
   INPUT                    : <List all files and their locations>
   OUTPUT                   : <List all files and their locations and 
                               file types>
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
   -------- -------- -------- --------------------------------------------------
   MDLIB1   required          Libref of metadata to modify
   MDLIB2   optional MDLIB1   Libref of metadata to copy from when MODE is
                               COPYDSN or COPYVAR
   MDPREFIX1 optional         
   MDPREFIX2 optional         
   MODE     required          DELETEDSN 
                              RENAMEDSN 
                              COPYDSN   
                              DELETEVAR 
                              RENAMEVAR 
                              COPYVAR   
   NAME     required          Name of data set to delete when MODE=DELETEDSN
                              Name of variable to delete when MODE=DELETEVAR
                              Name of data set to rename when MODE=RENAMEDSN 
                               first is old name second is new name
                              Name of variable to rename when MODE=RENAMEVAR
                               first is old name second is new name
                              Name of data set to copy when MODE=COPYDSN 
                               first is data set in MDLIB2 to copy, optional
                               second is data set name in MDLIB1 (if second is
                               missing it defaults to MDLIB2 data set name
                              Name of variable to copy when MODE=COPYDSN 
                               first is variable in MDLIB2 to copy, optional
                               second is variable name in MDLIB1 (if second is
                               missing it defaults to MDLIB2 data set name
   VERBOSE  required 1        
   DEBUG    required 0        
--------------------------------------------------------------------------------
  Usage Notes:  <Parameter dependencies and additional information for the user>

--------------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:


--------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
  Ver#  Author           Description
  ----  ---------------  -------------------------------------------------------
  001   <Author's name>  Original version of the broad-use module

 **eoh*************************************************************************/
%ut_parmdef(mdlib,_pdrequired=1)
%ut_parmdef(verbose,1)
%ut_parmdef(debug,0)
%local titlstrt;
%ut_logical(verbose) 
%ut_logical(debug)
%ut_titlstrt
title&titlstrt "(_mdmodify) ";


%*=============================================================================;
%* Macro section comment - will not appear in the log file;
%*=============================================================================;

%*-----------------------------------------------------------------------------;
%* Macro subsection comment - will not appear in the log file;
%*-----------------------------------------------------------------------------;

*==============================================================================;
* Section comment - will appear in the log file;
*==============================================================================;

*------------------------------------------------------------------------------;
* Subsection comment - will appear in the log file;
*------------------------------------------------------------------------------;

%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _<prefix>:;
  run; quit;
%end;

title&titlstrt;
%mend;
