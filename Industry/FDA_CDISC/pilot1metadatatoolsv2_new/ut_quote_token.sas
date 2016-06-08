%macro ut_quote_token(inmvar=_default_,outmvar=_default_,dlm=_default_,
 debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : ut_quote_token
TYPE                     : utility
DESCRIPTION              : This module inserts double quotation marks around
                            each delimited token in the user-specified macro
                            variable.  Its input is a macro variable whose
                            value is a list of tokens.  Its output is a macro
                            variable whose value is these tokens with quotes
                            added around each token.  If a token already has
                            double quotes around it, no additional quotes are
                            added.  Single quotes surrounding a token are
                            replaced with double quotes.
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS, SDD
BROAD-USE MODULES        : ut_parmdef ut_logical
INPUT                    : Macro variable whose value is a list of tokens
OUTPUT                   : Macro variable whose value is these tokens with
                            quotes added around each token
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : none needed
--------------------------------------------------------------------------------
Parameters:
 Name     Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
INMVAR   required             Name of macro variable containing text to quote.
OUTMVAR  required &INMVAR     Name of macro variable containing text in VAR
                               with quotes added.
DLM      required blank       A list of delimiter characters to split text in
                  comma        VAR into tokens.
DEBUG    required 0           %ut_logical value specifying whether debug mode
                               is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

  If a token already has double quotes around it none are added

  If INMVAR contains unbalanced quote signs this is a SAS syntax error and this
  macro cannot handle this situation.
--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

   When a macro variable has a list which you want to use with the IN operator.
 
   if datavar in (&quoted); can be inserted in a data step if you call 
   %ut_quote_token(inmvar=nodquotes,outmvar=quoted) prior to the data step.

   When a macro variable contains a list of data sets you want to use in a 
   SELECT statement

   %local selectq;  (assumes SELECT macro variable is a parameter of the macro)
   %ut_quote_token(inmvar=select,outmvar=selectq)
   proc copy in=in out=out;
     select &selectq;
   run;
   when SELECT is SUBJINFO VITALS HABITS then 
   SELECTQ is "SUBJINFO" "VITALS" "HABITS"
--------------------------------------------------------------------------------
     Author &
Ver# Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMRGCS11Mar2005A Original version of the broad-use module
                                         11Mar2005
1.1  Gregory Steffens BMRMSR21FEB2007E Migration to SAS version 9
      Michael Fredericksen
1.2  Gregory Steffens BMRMSR29OCT2007A Migration to SDD
      Shong DeMattos
  **eoh************************************************************************/
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=ut_quote_token,
 _pdverbose=1)
%ut_logical(debug)
%ut_parmdef(inmvar,_pdrequired=1,_pdmacroname=ut_quote_token,
 _pdverbose=&debug)
%ut_parmdef(outmvar,&inmvar,_pdrequired=1,_pdmacroname=ut_quote_token,
 _pdverbose=&debug)
%ut_parmdef(dlm,%str( ,),_pdrequired=1,_pdmacroname=ut_quote_token,
 _pdverbose=&debug)
%if &debug %then %put (ut_quote_token) macro starting;
%local i nextoken tempvar frstchar lastchar substrlen;
%if %bquote(&outmvar) = %then %let outmvar = &inmvar;
%if %bquote(%upcase(&outmvar)) ^= %bquote(%upcase(&inmvar)) %then
 %let &outmvar =;
%if &debug %then %put (ut_quote_token) inmvar=&inmvar outmvar=&outmvar
 &inmvar=&&&inmvar &outmvar=&&&outmvar dlm=&dlm;
%*=============================================================================;
%* SCAN each token, strip existing single or double quotes around each ;
%* add double quotes;
%*=============================================================================;
%let i = 0;
%do %while (%bquote(&nextoken) ^= | &i = 0);
  %let i = %eval(&i + 1);

  %let nextoken = %qscan(%bquote(&&&inmvar),&i,&dlm);

  %if &debug %then %put (ut_quote_token) i=&i nextoken=&nextoken;
  %if %bquote(&nextoken) ^= %then %do;
    %let frstchar = %bquote(%substr(%bquote(&nextoken),1,1));
    %let lastchar = %bquote(%substr(%bquote(&nextoken),%length(&nextoken),1));
    %if %bquote(&frstchar) = %str(%") | %bquote(&frstchar) = %str(%') %then
     %let nextoken = %bquote(%substr(%bquote(&nextoken),2));
    %if %bquote(&lastchar) = %str(%") | %bquote(&lastchar) = %str(%')
     %then %do;
      %let substrlen = %eval(%length(&nextoken) - 1);
      %if &debug %then %put (ut_quote_token) i=&i substrlen=&substrlen
       nexttoken=&nextoken;
      %let nextoken = %substr(%bquote(&nextoken),1,&substrlen);
    %end;
    %let tempvar = &tempvar %bquote(%sysfunc(quote(%quote(&nextoken))));
  %end;
  %if &debug %then %put (ut_quote_token) i=&i nextoken=&nextoken
   tempvar=&tempvar frstchar=&frstchar lastchar=&lastchar;
%end;
%if %bquote(&outmvar) ^= %then %let &outmvar = &tempvar;
%if &debug %then %do;
  %put (ut_quote_token) &outmvar=&&&outmvar;
  %put (ut_quote_token) ut_quote_token macro ending;
%end;
%mend;
