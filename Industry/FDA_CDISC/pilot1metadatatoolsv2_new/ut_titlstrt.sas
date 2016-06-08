%macro ut_titlstrt(tstartvar=_default_,debug=_default_);
  /*soh************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_titlstrt
   TYPE                     : utility
   DESCRIPTION              : Determines what the first unused title line number
                              is and returns the value in a macro variable
                              specified by the  tstartvar parameter
   DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\Clinical\General\
                               Broad-use Modules\SAS\ut_titlstrt\
                               Validation Deliverables\ut_titlstrt DL.doc
                               Validation Deliverables
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : MS Windows, MVS
   BROAD-USE MODULES        : ut_parmdef ut_logical
   INPUT                    : none
   OUTPUT                   : none
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : GCP
   TEMPORARY OBJECT PREFIX  : none
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
  TSTARTVAR required titlstrt Name of macro variable that is assigned the 
                                first available title line number
  DEBUG     required 0        %ut_logical value specifying whether to turn
                                debug mode on or not
  -----------------------------------------------------------------------------
  Usage Notes: <Parameter dependencies and additional information for the user>

  If all 10 title lines are used then TSTARTVAR will contain the number 10
  rather then the number 11, since SAS allows only 10 title lines.  A UWARNING
  is generated to inform you when this happens.

  This BUM macro is one way to meet the BUM design requirement to ensure that
  the titles that existed prior to the macro call still exist after the macro
  completes.  This BUM macro also allows titles to be retained when BUMs call
  other BUMs or any calling code defines titles that should be kept 
  during execution of a BUM or LUM.
  -----------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %local titlstrt;
    %ut_titlstrt;
    title&titlstrt "this is the first unused title line";
    title%eval(&titlstrt + 1) "the next unused title line";
    .
    .
    .
    title&titlstrt;  to be put at end of macro to clear titles it used

  -----------------------------------------------------------------------------
		 Author	&							  Broad-Use MODULE History
  Ver#   Peer Reviewer   Request # 		      Description
  ----  ---------------- ---------------- -------------------------------------
  1.0   Gregory Steffens BMRGCS23Jun2004A Original version of the broad-use
         John Reese                        module 23Jun2004
  1.1   Gregory Steffens BMRMSR05JAN2007A SAS Version 9 migration
         Michael Fredericksen
  2.0   Gregory Steffens BMRMSR24JuL2007  SDD migration validation
                                          Added _pdrequired to the two calls
                                           to ut_parmdef
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(tstartvar,titlstrt,_pdmacroname=ut_titlstrt,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_titlstrt,_pdrequired=1)
%ut_logical(debug)
%local maxtitle dsid rc;
%let &tstartvar = 1;
%*=============================================================================;
%* Find highest title line number used and add 1 to it;
%*=============================================================================;
%let dsid = %sysfunc(open(sashelp.vtitle (where = (type = 'T')),i));
%if &dsid > 0 %then %do;
  %if &debug %then %put (titlstrt) dsid=&dsid;
  %let &tstartvar = %eval(%sysfunc(attrn(&dsid,nlobsf)) + 1);
  %let rc = %sysfunc(close(&dsid));
  %if &debug %then %do;
    %put (titlstrt) dsid=&dsid close of vtitle view rc=&rc
     &tstartvar=&&&tstartvar;
    proc print data = sashelp.vtitle;
    run;
  %end;
%end;
%else %put UWARNING (titlestart) Unable to open sashelp.vtitle dsid=&dsid;
%*=============================================================================;
%* If the title line number is invalid then set it to 10;
%*=============================================================================;
%if &&&tstartvar < 1 | &&&tstartvar > 10 %then %do;
  %put UWARNING (titlestrt) maximum number of title lines is invalid -
   resetting to 10;
  %let &tstartvar = 10;
%end;
%if &debug %then %put titlstrt macro ending;
%mend ut_titlstrt;
