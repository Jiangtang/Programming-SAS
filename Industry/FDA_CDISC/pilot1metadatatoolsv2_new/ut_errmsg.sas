%macro ut_errmsg(msg=_default_,fileback=_default_,macroname=_default_,
 type=_default_,log=_default_,print=_default_,max=_default_,
 counter=_default_,verbose=_default_,debug=_default_);
  /*soh************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_errmsg
   TYPE                     : utility
   DESCRIPTION              : This macro writes informational and
                               error messages to BOTH the SAS log and print
                               files.  Ut_errmsg also can abort SAS when the
                               messge type is worse than a pre-defined level.
   DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                               Broad_use_modules\SAS\ut_errmsg\ut_errmsg DL.doc
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : MS Windows, MVS
   BROAD-USE MODULES        : ut_parmdef ut_logical
   INPUT                    : none
   OUTPUT                   : log and/or listing lines as defined by the MSG
                               LOG and PRINT parameters
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : GCP
   TEMPORARY OBJECT PREFIX  : _er
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
   MSG      required          The text of the error message to display.  Use PUT
                               syntax when in data step.  Use %PUT syntax when 
                               not in a data step and PRINT is false.
   MACRONAME required         The name of the macro calling ut_errmsg.  This 
                               macroname will be included when printing MSG so 
                               the user is informed what macro generated the 
                               message.
   TYPE     required NOTE     The type of error message - NOTE, WARNING or ERROR
                               if this TYPE exceeds the max_error_type global
                               macro variable value that can be set in the 
                               autoexec then ut_errmsg will abort the SAS
                               program.
   LOG      required 1        %ut_logical value specifying whether to write the
                               error message to the SAS log file.
   PRINT    required 1        %ut_logical value specifying whether to write the 
                               error message to the SAS print file.
   MAX      optional 25       The maximum number of times to write the error 
                               message when called from a data step.  The error
                               message is written for each bad observation until
                               this limit is reached.  If MAX is null then no
                               limit is put on the number of times the error
                               message is written.
   COUNTER  required _errmsg  The name of the variable used to count up to MAX.
                               If your data set already has a variable of this
                               default name then override the name with this
                               parameter.
   FILEBACK optional LOG      The fileref to return to when ut_errmsg completes.
                               This applies only when ut_errmsg is called inside
                               a data step.  Ut_errmsg issues a FILE statment 
                               so if the calling macro requires a fileref to be
                               active then ut_errmsg has to be told what this
                               fileref is.
   VERBOSE  required see note %ut_logical value specifying whether verbose mode
                               is on or off.  Default is the value of the 
                               DEBUG parameter
   DEBUG    required 0        %ut_logical value specifying whether debug mode
                               is on or off
  -----------------------------------------------------------------------------
  Usage Notes: <Parameter dependencies and additional information for the user>

The TYPE must be NOTE, WARNING, or ERROR.  The TYPE will be prefixed 
to the text specified in MSG and the type will have the letter U prefixed to 
it.  So, 
  %ut_errmsg(msg='invalid value for variable SYMTYP: ' SYMTYP,type=warning,
   macroname=callingmacro)
will print
  UWARNING(callingmacro): invalid value for variable SYMTYP: badvalue of symtyp
in the log and print files.

FILEBACK is advised when a PUT statement follows a call to UT_ERRMSG in a data
step.

The global macro variable MAX_ERROR_TYPE can be assigned one of three values
prior to calling the ut_errmsg macro in order to specify when the ut_errmsg
macro may abort-abend the SAS program when the condition exists.  The 
MAX_ERROR_TYPE global macro variable may be set in the autoexec or anywhere
else prior to the call to ut_errmsg.
If MAX_ERROR_TYPE is NOTE then if TYPE is WARNING or ERROR then ut_errmsg will
 abort the program.
If MAX_ERROR_TYPE is WARNING then if TYPE is ERROR then ut_errmsg will
 abort the program.
If MAX_ERROR_TYPE is ERROR then ut_errmsg will never abort the program.

Use a different COUNTER value in each call to UT_ERRMSG within the same data
step.

Although most calls to UT_ERRMSG can be followed safely with a semicolon, there  
are circumstances (in IF/THEN/ELSE blocks) where a semicolon can cause a SAS  
error when following a call to UT_ERRMSG.

When PRINT is true, use PUT syntax as a value of MSG.  
When PRINT is false and not in a data step use %PUT syntax as a value of MSG.
When PRINT is false and in a data step use PUT syntax as a value of MSG.

PRINT and LOG should not both be false. otherwise no message will be generated.
  -----------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

  -----------------------------------------------------------------------------
        Author &                          Broad-Use MODULE History
  Ver#   Peer Reviewer   Request #        Description
  ----  ---------------- ---------------- --------------------------------------
  1.0   Gregory Steffens BMRGCS15Mar2005A Original version of the
         Srinivasa Gudipati                    broad-use module 29Mar2005
  1.1   Gregory Steffens BMRMSR29JAN2007A SAS version 9 migration
         Michael Fredericksen
  2.0   Gregory Steffens                  Do not abort when executing in SDD
         
  3.0   Gregory Steffens BMRMSR23JUL2007  
         
  **eoh************************************************************************/
%* ============================================================================;
%* Initialization - ut_parmdef ut_logical upcase and declare local variables;
%* ============================================================================;
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=0)
%ut_logical(debug)
%ut_parmdef(verbose,&debug,_pdrequired=1,_pdmacroname=ut_errmsg,
 _pdverbose=&debug)
%ut_logical(verbose)
%ut_parmdef(msg,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(fileback,log,_pdrequired=0,_pdmacroname=ut_errmsg,
 _pdverbose=&verbose)
%ut_parmdef(macroname,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
 /* type parameter not printed so that ut_sas8lchk will not find the string */
%ut_parmdef(type,note,note warning error,_pdrequired=1,_pdmacroname=ut_errmsg,
 _pdverbose=0)
%ut_parmdef(log,1,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(print,1,_pdrequired=1,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(max,25,_pdrequired=0,_pdmacroname=ut_errmsg,_pdverbose=&verbose)
%ut_parmdef(counter,_errmsg,_pdrequired=1,_pdmacroname=ut_errmsg,
 _pdverbose=&verbose)
%ut_logical(log)
%ut_logical(print)
%if &debug %then %put UNOTE(ut_errmsg): macro starting;
%local error maxerror datastep firstchar lastchar msgq max_error_type_original;
%global max_error_type;
%let type = %upcase(&type);
%let macroname = %upcase(&macroname);
%* ============================================================================;
%* If executing in SDD then do not allow abort - SDD does not support abort;
%* ============================================================================;
%if &sysver ^= 8.2 %then %do;
  %if %symglobl(_sddusr_) | %symglobl(_sddprc_) |  %symglobl(sddparms)
   %then %do;
    %if %bquote(%upcase(&max_error_type)) ^= ERROR %then %do;
      %let max_error_type_original = &max_error_type;
      %let max_error_type = ERROR;
    %end;
  %end;
%end;
%* ============================================================================;
%* Determine if called in a data step or not;
%* ============================================================================;
%if %bquote(&sysprocname) = %upcase(DATASTEP) %then %let datastep = 1;
%else %let datastep = 0;
%* ============================================================================;
%* Set default value to global macro variable to define worse tolerated;
%*  TYPE of message without aborting program;
%* ============================================================================;
%if %bquote(&max_error_type) = %then %let max_error_type = ERROR;
%else %let max_error_type = %upcase(&max_error_type);
%* ============================================================================;
%* Evaluate the TYPE and max_error_type values -- convert them to numerics;
%*  for ease of comparison.;
%* ============================================================================;
%if &type = NOTE %then %let error = 0;
%else %if &type = WARNING %then %let error = 4;
%else %if &type = ERROR %then %let error = 12;
%else %do;
  %put UERROR(UT_ERRMSG): type:&type NOT RECOGNIZED BY UT_ERRMSG MACRO;
  %put UERROR(UT_ERRMSG): types allowed are: note warning error;
  %let error = 12;
%end;
%if &max_error_type = NOTE %then %let maxerror = 0;
%else %if &max_error_type = WARNING %then %let maxerror = 4;
%else %if &max_error_type = ERROR %then %let maxerror = 12;
%else %do;
  %put UERROR(UT_ERRMSG): type: &max_error_type NOT RECOGNIZED BY UT_ERRMSG
   MACRO setting to ERROR;
  %let maxerror = 12;
%end;
%* ----------------------------------------------------------------------------;
%* If LOG and PRINT are false then message to log and set LOG to 1;
%* ----------------------------------------------------------------------------;
%if ^ %bquote(&log) & ^ %bquote(&print) %then %do;
  %put UWARNING(UT_ERRMSG): Both LOG and PRINT parameters are false -;
  %put  resetting LOG to true;
  %let log = 1;
%end;
%* ----------------------------------------------------------------------------;
%* Cite an error in the usage of UT_ERRMSG if no message is given.;
%* ----------------------------------------------------------------------------;
%if %bquote(&msg) = %then
  %put UERROR(UT_ERRMSG): The UT_ERRMSG macro requires the MSG parameter
   with the message text;
%else %do;
  %* ==========================================================================;
  %* Process UT_ERRMSG from within a data step.;
  %* ==========================================================================;
  %if &datastep = 1 %then %do;
    /* Do statement so ut_errmsg can be called from within an
     if ... then ... ut_errmsg format */
    do;
      %if %bquote(&counter) ^= & &max > 0 %then %do;
        &counter + 1;
        if &counter <= &max then do;
      %end;
        %if &print %then %do;
          file print;
          put "U%substr(&TYPE,1,2)" "%substr(&type,3)(&macroname): " &msg;
          %if &error > &maxerror %then %do;
            put "U%substr(&TYPE,1,2)" 
             "%substr(&type,3)(&macroname): -- Aborting Program" %str(;);
          %end;
          %if &max > 1 %then %do;
           if &counter = &max then put 'UN' 'OTE(ut_errmsg): '
            'Further messages of this type will not be printed';
          %end;
        %end;
        %if &log %then %do;
          file log;
          put "U%substr(&TYPE,1,2)" "%substr(&type,3)(&macroname): " &msg;
          %if &error > &maxerror %then %do;
            put "U%substr(&TYPE,1,2)"
             "%substr(&type,3)(&macroname): -- Aborting Program" %str(;);
          %end;
          %if &max > 1 %then %do;
           if &counter = &max then put 'UN' 'OTE(ut_errmsg): '
            'Further messages of this type will not be printed';
          %end;
        %end;
      %if %bquote(&counter) ^= & &max > 0 %then %do;
        end;
        drop &counter;
      %end;
      %* ----------------------------------------------------------------------;
      %* When FILEBACK is specified, reset the FILE from PRINT to FILEBACK.;
      %* ----------------------------------------------------------------------;
      %if %bquote(&fileback) ^= & (%upcase(&fileback) ^= LOG | ^ &log) %then
       %str(file &fileback;);
      %* ----------------------------------------------------------------------;
      %* If ERROR level is greater than MAXimum allowed, ABORT the program.;
      %* ----------------------------------------------------------------------;
      %if &error > &maxerror %then %str(abort abend;);
    end;
  %end;
  %else %do;
    %* ========================================================================;
    %* Process UT_ERRMSG from outside datastep.;
    %* ========================================================================;
    %if &print %then %do;
      %let firstchar = %qsubstr(&msg,1,1);
      %let lastchar = %qsubstr(&msg,%length(&msg),1);
      %if &firstchar = %str(%") & &lastchar = %str(%") | 
       &firstchar = %str(%') & &lastchar = %str(%') %then %let msgq = &msg;
	  %else %let msgq = "&msg";
      data _null_; 
        file print;
        put "U%substr(&TYPE,1,2)" "%substr(&type,3)(&macroname): " &msgq;
        stop;
      run;
    %end;
    %if &log %then %put U&type(&macroname): &msg;
    %if &error > &maxerror %then %do;
      ; /* to terminate a statement if ut_errmsg is called inside a statement */
      %put U&type(&macroname): -- Aborting Program;
      data _null_;
        abort abend;
      run;
    %end;
  %end;
%end;
%if &debug %then %put UNOTE(ut_errmsg): macro ending;
%if &max_error_type_original ^= %then
 %let max_error_type = &max_error_type_original;
%mend;
