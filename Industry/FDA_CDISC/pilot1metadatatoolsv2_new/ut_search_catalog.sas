%macro ut_search_catalog(cat=_default_,search=_default_,out=_default_,
 verbose=_default_,debug=_default_);
  /*soh************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : ut_search_catalog
   TYPE                     : utility
   DESCRIPTION              : Searches all source entries in a catalog and
                               lists the names of the entries that contain a
                               specified text string.
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                              Document List>
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : Windows, MVS, Unix
   BROAD-USE MODULES        : <List all the broad-use modules called
                              by this module>
   INPUT                    : <List all files and their production locations
                               including AUTOEXEC files, if applicable>
   OUTPUT                   : SAS listing file and an optional data set
   VALIDATION LEVEL         : N/A - used as a LUM for now or the use falls
                               outside the scope of the code validation SOP
   REGULATORY STATUS        : NDR (non drug related) non-regulated
   TEMPORARY OBJECT PREFIX  : _se
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
   CAT      required          One or two level name of a SAS catalog that
                               contains source entries whose contents will be
                               searched for a text string
   SEARCH   required          The text string that will be searched for in the
                               catalog specified by the CAT parameter
   OUT      optional          The name of an output data set containing the
                               names and type of catalog entries in CAT that
                               contain the string specfied by SEARCH.
   VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                               is on or off.  If verbose is on then a listing
                               will be generated of the names of the entries
                               in CAT that contain the string specified by 
                               SEARCH.  If VERBOSE is on or if OUT is null then
                               this listing is generated.  If VERBOSE is off 
                               then the data steps that search the entry 
                               contents are suppressed from the log file. 
   DEBUG    required 0        %ut_logical value specifying whether debug mode
                               is on or off
  -----------------------------------------------------------------------------
  Usage Notes:

  The optional output data set will containg the variables ENTRY and TYPE.

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
%ut_parmdef(cat,_pdrequired=1,_pdmacroname=ut_search_catalog)
%ut_parmdef(search,_pdrequired=1,_pdmacroname=ut_search_catalog)
%ut_parmdef(out,_pdrequired=0,_pdmacroname=ut_search_catalog)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=ut_search_catalog)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=ut_search_catalog)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt numentries entrynum libref catalog notes mprint has_string
 entries_with_string;
%ut_titlstrt
%if %bquote(%scan(&cat,2,%str(.))) ^= %then %do;
  %let libref = %scan(&cat,1,%str(.));
  %let catalog = %scan(&cat,2,%str(.));
%end;
%else %do;
  %let libref=work;
  %let catalog = &cat;
%end;
*==============================================================================;
* Process catalog entries;
*==============================================================================;
proc catalog catalog = &cat;
  contents out=_seentries;
run;
%let numentries = 0;
data _null_;
  if eof & entry_num > 0 then
   call symput('numentries',trim(left(put(entry_num,32.0))));
  set _seentries (where = (upcase(type) = 'SOURCE')) end=eof;
  entry_num + 1;
  call symput('entry' || trim(left(put(entry_num,32.0))),trim(left(name)));
run;
%let entries_with_string = 0;
%if &numentries > 0 %then %do;
  filename _secat catalog "&libref..&catalog";
  filename _secat list;
  %if ^ &debug %then %do;
    %let notes = %sysfunc(getoption(notes));
    %let mprint = %sysfunc(getoption(mprint));
    options nonotes nomprint;
  %end;
  %do entrynum = 1 %to &numentries;
    *--------------------------------------------------------------------------;
    %bquote(* &entrynum Searching entry &&entry&entrynum...source;)
    *--------------------------------------------------------------------------;
    %if ^ &debug %then %put UNOTE:
     &entrynum Processing &&entry&entrynum...source out of &numentries;
    %let has_string = 0;
    data _seentry_with_string;
      infile _secat(&&entry&entrynum...source) length=len;
      input record $varying200. len;
      if index(upcase(record),upcase("&search")) > 0;
      length entry $ 32 type $ 8;
      entry = "&&entry&entrynum";
      type = "SOURCE";
      output;
      call symput('has_string','1');

%* Add logic to list lines in catalog that contain string
   Should table/column be included in the list of entries where text was found?
;

      stop;
      keep entry type;
    run;
    %if &has_string %then %do;
      proc append base=_seentries_with_string  data=_seentry_with_string;
      run;
      %let entries_with_string = %eval(&entries_with_string + 1);
    %end;
  %end;
  %if ^ &debug %then %do;
    options &notes &mprint;
  %end;
  %if &verbose | %bquote(&out) = %then %do;
    proc print data = _seentries_with_string width=minimum;
      title&titlstrt "(ut_search_catalog) Entries containing the string ""&search"" ";
    run;
    title&titlstrt;
  %end;
  %if %bquote(&out) ^= %then %do;
    data &out (label="Entries in &cat containing &search");
      set _seentries_with_string;
    run;
  %end;
%end;
%else %ut_errmsg(msg="no entries found in &cat",macroname=ut_search_catalog,
 type=note);
%ut_errmsg(msg="&numentries found in &cat - "
 "&entries_with_string contain the string &search",type=note,
 macroname=ut_search_catalog)
%if ^ &debug %then %do;
*==============================================================================;
* Cleanup at end of ut_search_catalog macro;
*==============================================================================;
  proc datasets lib=work nolist;
    delete _se:;
  run; quit;
%end;
title&titlstrt;
%mend;
