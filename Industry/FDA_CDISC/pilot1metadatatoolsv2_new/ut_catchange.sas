%macro ut_catchange(incat=_default_,outcat=_default_,select=_default_,
 exclude=_default_,types=_default_,from=_default_,to=_default_,
 delimit=_default_,verbose=_default_,debug=_default_);
  /*soh************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_catchange
   TYPE                     : utility
   DESCRIPTION              : Changes all occurrences of one or more text
                               strings in all entries in INCAT and writes the
                               result to OUTCAT.
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                              Document List>
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : Windows, MVS, Unix
   BROAD-USE MODULES        : ut_parmdef ut_quote_token ut_marray
   INPUT                    : <List all files and their production locations
                               including AUTOEXEC files, if applicable>
   OUTPUT                   : <List all files [e.g. data sets] and
                               file types [e.g. macro variable]>
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : <Enter applicable regulatory status [e.g. GCP,
                               GLP, GMP, GPP, NDR (non drug related)
                               regulations, non-regulated, or N/A]. Refer to
                               Statistics Glossary for the definition of each
                               of the terms.>
   TEMPORARY OBJECT PREFIX  : <Enter unique ID for each broad-use module.
                               See Broad-Use Module Request.>
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
  INCAT     required          one or two level name of input catalog that will
                               be read by this macro
  OUTCAT    required INCAT    one or two level name of the output catalog that
                               will be written by this macro.
  SELECT    optional          list of entry names whose contents will be
                               evaluated and changed.  If unspecified all 
                               entries are selected.
  EXCLUDE   optional          list of entry names whose contents will not be
                               evaluated and changed.  If unspecified no entry
                               is excluded.
  TYPES     required source   list of entry types that are processed by this 
                               macro
  FROM      required          the text string to search for to change
  TO        required          the text string th change to
  DELIMIT   required space    the delimiter that separates multiple FROM and TO
                               value pairs.
  VERBOSE   required 1        %ut_logical value specifying whether verbose mode
                               is on or off
  DEBUG     required 0        %ut_logical value specifying whether debug mode
                               is on or off

  -----------------------------------------------------------------------------
  Usage Notes: <Parameter dependencies and additional information for the user>

  -----------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

  -----------------------------------------------------------------------------
		 Author	&							  Broad-Use MODULE History
  Ver#   Peer Reviewer   Request # 		      Description
  ----  ---------------- ---------------      --------------------------------
  1.0   Gregory Steffens <Enter BUM Request#> Original version of the broad-use
        <Peer Reviewer name>                  module

  **eoh************************************************************************/
%*=============================================================================;
%* Process parameters;
%*=============================================================================;
%ut_parmdef(incat,_pdrequired=1,_pdmacroname=ut_catchange)
%ut_parmdef(outcat,_pdmacroname=ut_catchange)
%ut_parmdef(select,_pdmacroname=ut_catchange)
%ut_parmdef(exclude,_pdmacroname=ut_catchange)
%ut_parmdef(types,source,source program scl,_pdrequired=1,
 _pdmacroname=ut_catchange)
%ut_parmdef(from,_pdrequired=1,_pdmacroname=ut_catchange)
%ut_parmdef(to,_pdmacroname=ut_catchange)
%ut_parmdef(delimit,%str( ),_pdrequired=1,_pdmacroname=ut_catchange)
%ut_parmdef(verbose,1,_pdmacroname=ut_catchange)
%ut_parmdef(debug,0,_pdmacroname=ut_catchange)
%if %bquote(&outcat) = %then %let outcat = &incat;
%*=============================================================================;
%* Declare local macro variables and determine title line;
%*=============================================================================;
%local typesq selectq excludeq numfroms fromnum numtos numtos froms tos
 titlstrt options;
%ut_titlstrt
%*=============================================================================;
%* Parse FROM and TO into two parallel macro variable arrays;
%*=============================================================================;
%ut_marray(invar=from,outvar=f,outnum=numfroms,varlist=froms,dlm=&delimit)
%local &froms;
%ut_marray(invar=from,outvar=f,outnum=numfroms,dlm=&delimit)
%ut_marray(invar=to,outvar=t,outnum=numtos,varlist=tos,dlm=&delimit)
%local &tos;
%ut_marray(invar=to,outvar=t,outnum=numtos,dlm=&delimit)
%if &numfroms > 0 %then %do fromnum = 1 %to &numfroms;
  %put (ut_catchange) &fromnum from=&&f&fromnum to=&&t&fromnum;
%end;
%if &numfroms ^= &numtos %then %do;
  %ut_errmsg(msg="Number of from strings is different than the number of to "
   "strings numfroms=&numfroms numtos=&numtos",macroname=ut_catchange)
  %goto endmac;
%end;
%*=============================================================================;
%* Tokenize and quote TYPES SELECT and EXCLUDE;
%*=============================================================================;
%ut_quote_token(inmvar=types,outmvar=typesq)
%let typesq = %upcase(&typesq);
%ut_quote_token(inmvar=select,outmvar=selectq)
%let selectq = %upcase(&selectq);
%ut_quote_token(inmvar=exclude,outmvar=excludeq)
%let excludeq = %upcase(&excludeq);
*==============================================================================;
* Process selected catalog entries;
*==============================================================================;
proc catalog cat = &incat;
  contents out=_cccatcont;
run;
%let numents = 0;
data _null_;
  if eof then call symput('numents',trim(left(put(ent_num,32.0))));
  set _cccatcont (where = (upcase(type) in (&typesq)
   %if %bquote(&selectq) ^= %then %do;
     & upcase(name) in (&selectq)
   %end;
   %if %bquote(&excludeq) ^= %then %do;
     & upcase(name) ^ in (&excludeq)
   %end;
   )) end=eof;
  ent_num + 1;
  call symput('ent' || trim(left(put(ent_num,32.0))),trim(left(name)));
  call symput('typ' || trim(left(put(ent_num,32.0))),trim(left(type)));
run;
%if &numents > 0 & &numfroms > 0 %then %do;
  %if %bquote(%upcase(&incat)) ^= %bquote(%upcase(&outcat)) %then %do;
    proc catalog cat = &incat;
      copy out = &outcat;
    run;
  %end;
  filename _cccati catalog "&incat";
  filename _cccato catalog "&outcat";
  %do entnum = 1 %to &numents;
    %put UNOTE: &entnum Processing &&ent&entnum...&&typ&entnum of &numents;
    data _ccentry_changed  _ccentry_case_found;
      length entry $ 65 from to $ 256;
      infile _cccati(&&ent&entnum...&&typ&entnum) length=len;
      input record $varying256. len;
      if len > 256 then
       %ut_errmsg(msg="Record length exceedes maximum supported length of 256 "
       len=,macroname=ut_catchange,type=warning);
      %do fromnum = 1 %to &numfroms;
        from = "&&f&fromnum";
        to = "&&t&fromnum";
        entry = "&&ent&entnum...&&typ&entnum";

        if index(record,"&&f&fromnum") > 0 then do;

          record = tranwrd(record,"&&f&fromnum","&&t&fromnum");
          output _ccentry_changed;
        end;

        else if index(upcase(record),upcase("&&f&fromnum")) > 0 then do;

          output _ccentry_case_found;
        end;
      %end;
      new_length = length(record);
      file _cccato(&&ent&entnum...&&typ&entnum);
      put record $varying256. new_length;
      keep entry from to record;
    run;
    %if &entnum = 1 %then %do;
      data _ccentries_changed;
        set _ccentry_changed;
      run;
      data _ccentries_case_found;
        set _ccentry_case_found;
      run;
    %end;
    %else %do;
      proc append base=_ccentries_changed  data = _ccentry_changed;
      run;
      proc append base=_ccentries_case_found  data = _ccentry_case_found;
      run;
      %if ^ &debug %then %do;
        %if &numents > 2 %then %do;
          %if &entnum = 2 %then %do;
            %let options = options;
            %if %upcase(%sysfunc(getoption(mprint))) ^= NOMPRINT %then %do;
              %let options = &options mprint;
              options nomprint;
            %end;
            %if %upcase(%sysfunc(getoption(notes))) ^= NONOTES %then %do;
              %let options = &options notes;
              options nonotes;
            %end;
            %let options = &options%str(;);
          %end;
          %else %if &entnum = &numents & %bquote(&options) ^= options%str(;)
           %then %do;
            &options
          %end;
        %end;
      %end;
    %end;
  %end;
  %if &verbose %then %do;
    *==========================================================================;
    * Print reports;
    *==========================================================================;
    proc sort data = _ccentries_changed;
      by entry from;
    run;
    proc print data = _ccentries_changed width=minimum;
      by entry;
      title&titlstrt "(ut_catchange) Entries changed from &incat to &outcat";
    run;
    proc sort data = _ccentries_case_found;
      by entry from;
    run;
    proc print data = _ccentries_case_found width=minimum;
      by entry;
      title&titlstrt
       "(ut_catchange) Entries with from string in different case";
    run;
    title&titlstrt;
  %end;
%end;
%endmac:
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of ut_catchange macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _cc:;
  run; quit;
%end;
title&titlstrt;
%mend;
