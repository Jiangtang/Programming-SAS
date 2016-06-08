%macro ut_logical (varname,vartype=_default_,max=25,counter=_logn_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_logical
   TYPE                     : utility
   DESCRIPTION              : Translates various logical values to the two
                               Boolean logical values 0 and 1.  This is useful
                               to call for macro parameters so that users can
                               have a consistent choice of values for truth and
                               falsity.  GUI and BUMs can benefit from this to
                               support foreign languages.
   DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\Clinical\General\
                               Broad-use modules\SAS\ut_logical\
                               Validation deliverables\ut_logical DL.doc
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : MS Windows, MVS, SDD
   BROAD-USE MODULES        : ut_parmdef
   INPUT                    : none
   OUTPUT                   : none
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : GCP
   TEMPORARY OBJECT PREFIX  : _lo
  ------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- --------------------------------------------------
   VARNAME  required          Name of the variable containing the text to 
                               translate to a boolean value of 0 or 1.  This is
                               a positional parameter.
   VARTYPE  required macro    The type of VARNAME - i.e. 
                               MACRO for macro variable 
                               DATAC for data set character variable
                               DATAN for data set numeric variable
   MAX      see note 25       The number of times to display error messages when
                               VARTYPE is not macro.  This required when VARTYPE
                               is not MACRO and is ignored otherwise.
   COUNTER  see note _logn_   The name of the variable to use to count the
                               number of time an error message is displayed
                               when VARTYPE is not macro.  This variable name
                               is created in the data step but dropped from the
                               data set.  This required when VARTYPE is not
                               MACRO and is ignored otherwise.
  ------------------------------------------------------------------------------
  Usage Notes:

   recognized TRUTH values: Y T YES TRUE  ON  JA   OUI
   recognized FALSE values: N F NO  FALSE OFF NEIN NON

   Takes logical values of SAS variables and translates to a consistent Boolean
   value, so that callers do not all have to check for Y T TRUE etc.

   Specify a different COUNTER value with each call to LOGICAL from within a
    single data step.
  ------------------------------------------------------------------------------
  Assumptions:

   Can be called in a macro when VARNAME is a macro variable name
   or can be called in a data step when VARNAME is a data set variable.
   Use the VARTYPE parameter to specify the type of VARNAME 

  ------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %ut_logical(verbose)   : translates macro parameter "verbose" to 1 or 0

    data a.habits;
      set r.hb;
      %ut_logical(smoke)   : translates the value of SMOKE from Y to 1 and 
      .                    from N to 0, assuming SMOKE has the values Y and N
      .                    indicating whether the patient smokes or not.
      .
    run;

  ------------------------------------------------------------------------------
		 Author	&							  Broad-Use MODULE History 
  Ver#   Peer Reviewer   Request # 		      Description
  ----  ---------------- ---------------      ----------------------------------
  001   Greg Steffens    BMRGCS21JUN2004A     Original version of the broad-use
          Guangbin Peng                        module 21Jun2004
  002   Greg Steffens    BMRMI07FEB2006A      Changed ut_parmdef call to specify
           Vijay Sharma                        _pdverbose false so the user does
                                               not see needless lines in the log
                                               file
                                              Changed header comment: references
                                               from logical to ut_logical
                                              Infrastructure includes MVS and
                                               MS Windows rather than only 
                                               windows
                                              Improved description of the
                                               COUNTER parameter
                                              Made MAX and COUNTER parameters
                                               required only when VARTYPE is not
                                               MACRO.
                                              Changed message text to be
                                               consistent with ut_errmsg format.
  2.1   Gregory Steffens BMRMI29JAN2007A      SAS version 9 migration
         Michael Fredericksen
  2.2   Gregory Steffens BMRMSR24May2007     SDD validation
         
  **eoh************************************************************************/
%* ============================================================================;
%* Declare local macro variables;
%* ============================================================================;
%local truth false req;
%* ============================================================================;
%* Process parameters;
%* ============================================================================;
%ut_parmdef(varname,,,_pdmacroname=ut_logical,_pdverbose=0,_pdrequired=1)
%ut_parmdef(vartype,macro,macro datac datan,_pdmacroname=ut_logical,
 _pdverbose=0,_pdrequired=1)
%if %bquote(%upcase(&vartype)) ^= MACRO %then %let req = 1;
%else %let req = 0;
%ut_parmdef(max,25,_pdmacroname=ut_logical,_pdverbose=0,_pdrequired=&req)
%ut_parmdef(counter,_logn_,_pdmacroname=ut_logical,_pdverbose=0,
 _pdrequired=&req)
%let vartype = %upcase(&vartype);
%if %bquote(&vartype) = | %bquote(&vartype) = DATA %then %let vartype = DATAC;
%* ============================================================================;
%* Define true and false values;
%* (the 0 1 values are not included since no translation is required);
%* ============================================================================;
%let truth = Y T YES TRUE  ON  OUI JA;
%let false = N F NO  FALSE OFF NON NEIN;
%if &vartype = MACRO %then %do;
  %* ==========================================================================;
  %* Translate macro variable truth values to Boolean 1 or 0 truth value;
  %* ==========================================================================;
  %if &&&varname ^= 0 & &&&varname ^= 1 %then %do;
    %if %sysfunc(indexw(&truth,%upcase(&&&varname))) %then %let &varname = 1;
    %else %if %sysfunc(indexw(&false,%upcase(&&&varname))) %then
     %let &varname = 0;
    %else %if &&&varname ^= 1 & &&&varname ^= 0 %then %put UWARNING(ut_logical):
     INVALID LOGICAL VALUE OF &varname = %nrbquote(&&&VARNAME)
      truth:&truth    false:&false;
  %end;
%end;
%else %if %bquote(&vartype) = DATAC %then %do;
  %* ==========================================================================;
  %* Translate data step character variable truth values to Boolean 1 or 0;
  %* ==========================================================================;
  if &varname ^ in ('1','0') then do;
    if indexw("&truth",upcase(&varname)) then &varname = '1';
    else if indexw("&false",upcase(&varname)) then &varname = '0';
    else do;
      &counter + 1;
      if &counter <= &max then
       put / "UWAR" "NING(ut_logical): INVALID LOGICAL VALUE OF " &varname=  / 
       " truth:&truth    false:&false";
      if &counter = &max then
       put 'UNOTE(ut_logical_): Additional war'
        'ning messages will not be printed';
      drop &counter;
    end;
  end;
%end;
%else %if %bquote(&vartype) = DATAN %then %do;
  %* ==========================================================================;
  %* Translate data step numeric variable truth values to Boolean 1 or 0;
  %* ==========================================================================;
  if &varname then &varname = 1;
  else &varname = 0;
%end;
%mend;
