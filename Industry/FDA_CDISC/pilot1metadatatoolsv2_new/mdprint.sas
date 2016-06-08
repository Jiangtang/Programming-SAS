%macro mdprint(mdlib=_default_,html=_default_,htmlfile=_default_,
 htmlfileref=_default_,lmargin=_default_,select=_default_,exclude=_default_,
 inprefix=_default_,title=_default_,descriptions=_default_,values=_default_,
 labellong=_default_,userformats=_default_,maxvaluesobs=_default_,
 addheader=_default_,mult_html=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdprint
TYPE                     : metadata
DESCRIPTION              : Prints meta data sets as a data specification.
                            Creates an HTML file with hperlinks, a SAS listing
                            or any other SAS ODS output destination.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\mdprint\mdprint-mdcpput DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS, SDD
BROAD-USE MODULES        : ut_logical ut_titlstrt ut_errmsg mdmake mdcpput 
                           ut_htmlhead ut_parmdef mdmoddt
INPUT                    : As defined by the MDLIB parameter
OUTPUT                   : As defined by the optional HTMLFILE parameter
                            Otherwise the SAS listing file or other ODS
                            destination
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _mp
--------------------------------------------------------------------------------
Parameters:
 Name        Type     Default    Description and Valid Values
------------ -------- ---------- -----------------------------------------------
MDLIB        required            Libref of library containing meta data sets 
HTML         required 0          %ut_logical value specifying whether to create
                                 an html document instead of a SAS listing file
HTMLFILE     optional            Name of file to contain the html document when
                                  HTML is true
HTMLFILEREF  optional            Fileref of file to contain the html document
                                  when HTML is true

MULT_HTML    optional 0          %ut_logical value specifying whether or not to
                                  create separate html files for each data set.

LMARGIN      required 0          Number of columns to reserve for the left margin
                                  - applies only when HTML is false
INPREFIX     optional            Prefix of meta data set names residing in MDLIB
                                  This is passed to INPREFIX parameter of the 
                                  mdmake macro
SELECT       optional            A blank delimited list of data set names defined
                                  in the MDLIB metadata to limit processing to.
EXCLUDE      optional            A blank delimited list of data set names defined
                                  in the MDLIB metadata to exclude from
                                  processing
DESCRIPTIONS required 1          %ut_logical value specifying whether or not to
                                  print variable descriptions
VALUES       required 1          %ut_logical value specifying whether or not to
                                  print variables valid values and code/decode
                                  mappings
TITLE        optional            Title to add to existing titles.  The datetime of
                                  last modification made to the metadata is
                                  added to the title text specified with the
                                  TITLE parameter, unless the SELECT or EXCLUDE
                                  parameters are specified.  The default title
                                  is Database Specification followed by the date
                                  and time the metadata in MDLIB was last
                                  modified.
LABELLONG    required 1          %ut_logical value specifying whether to print
                                  the variable long label.
USERFORMATS  required 1          %ut_logical values specifying whether format
                                  names where formatflag is 2, 3 or 4 will be
                                  printed from the COLUMNS and COLUMNS_PARAM
                                  metadata.
MAXVALUESOBS  optional max       Maximum number of observations in the VALUES to
                                  print for each variable.  MAX means to print
                                  all observations.  Otherwise specify an
                                  integer.
ADDHEADER    required 1          %ut_logical passed to mdmake. Specifies whether
                                  to print header variables in each data set
                                  they are copied into.  If false the header
                                  variables are printed only in the source data
                                  set it is originally created in.  If true the
                                  header variables are printed in every data set
                                  they can exist in.
VERBOSE      required 1          %ut_logical value specifying whether verbose
                                  mode is on or off
DEBUG        required 0          %ut_logical value specifying whether debug mode
                                  is on or off
--------------------------------------------------------------------------------
Usage Notes:

If mdprint is called in the SDD environment and the MULT_HTML parameter is
true, the the user is required by SDD to declare each output html file to SDD 
as an output html file.
--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

    libname m '<directory where metadata resides>' access=readonly;

    %mdprint(mdlib=m,html=1,htmlfile=h:\myreqs.html,title=My Data Requirements)
    will generate a single html file

    %mdprint(mdlib=m,html=1,htmlfile=h:\myreqs.html,title=My Data Requirements,
     mult_html=yes)
    Will generate one html file per data set defined in the metadata plus
    one top level html file that links these all together.  This speeds the 
    time to open the html file and also fixes a problem with a browser limit of
    the number of links in a single html can contain.

    %mdprint(mdlib=m)
    will generate a SAS listing
--------------------------------------------------------------------------------
     Author &
Ver#  Peer Reviewer    Request #        Broad-Use MODULE History Description
---- ----------------- ---------------- ----------------------------------------
1.0   Gregory Steffens BMRGCS23Apr2005A Original version of the broad-use module
       Sheetal Lal
1.1   Gregory Steffens BMRMSR20FEB2007C SAS version 9 migration
       Michael Fredericksen
2.0   Gregory Steffens BMRGCS14Jan2008  Added TSHORT variable from the TABLES
       Russ Newhouse                     metadata set
                                        Added HTMLFILEREF parameter (SDD needs
                                         this)
                                        Do not append modification date to title
                                         if title is null
                                        Reduced whitespace at various places
                                        Added MULT_HTML parameter
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=1)
%ut_logical(verbose)
%ut_parmdef(mdlib,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(html,0,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(htmlfile,_pdrequired=0,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(htmlfileref,_pdrequired=0,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(mult_html,0,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(lmargin,0,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(inprefix,_pdrequired=0,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(select,_pdrequired=0,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(exclude,_pdrequired=0,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(title,Database Specification,_pdrequired=0,_pdmacroname=mdprint,
 _pdverbose=&verbose)
%ut_parmdef(maxvaluesobs,_default_,_pdrequired=1,_pdmacroname=mdprint,
 _pdverbose=&verbose)
%ut_parmdef(addheader,1,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdprint,_pdverbose=&verbose)
%ut_logical(debug)
%ut_logical(html)
%ut_logical(mult_html)
%local titlstrt numtables c1 c2 c3 c4 dsid moddt modte numparamcols paramcolnum
 cparamfl typelen tablelen tlablelen typelen loclen tshortlen outfile
 outfile_current mult_file_dir mult_file_dir_col mult_file_prefix
;
%if %bquote(&htmlfileref) ^= %then %do;
  %let outfile = &htmlfileref;
  %if %bquote(&htmlfile) ^= %then %do;
    %ut_errmsg(msg=Do not specify both HTMLFILE and HTMLFILEREF parameters -
     using htmlfileref=&htmlfileref (htmlfile=&htmlfile),type=warning,print=0,
     macroname=mdprint);
    %let htmlfile =;
  %end;
%end;
%else %if %bquote(&htmlfile) ^= %then %do;
  %if %qsubstr(&htmlfile,1,1) ^= %str(%") & %qsubstr(&htmlfile,1,1) ^= %str(%')
   %then %let outfile = "&htmlfile";
  %else %let outfile = &htmlfile;
%end;
%if %bquote(&outfile) = & &html %then %do;
  %ut_errmsg(msg=HTMLFILE or HTMLFILEREF must be specified - ending macro 
   htmlfileref=&htmlfileref htmlfile=&htmlfile outfile=&outfile,type=warning,
   print=0,macroname=mdprint);
  %goto endmac;
%end;
%if &mult_html & ^ &html %then %let mult_html = 0;
%if &mult_html %then %do;
  %* --------------------------------------------------------------------------;
  %* Determine mult_file_dir - html directory from htmlfile or htmlfileref;
  %* --------------------------------------------------------------------------;
  %if %bquote(&htmlfile) ^= %then %let mult_file_prefix = &htmlfile;
  %else %if %bquote(&htmlfileref) ^= %then
   %let mult_file_prefix = %sysfunc(pathname(&htmlfileref));
  %let htmlfileref =;
  %let mult_file_dir = %sysfunc(reverse(&mult_file_prefix));
  %if &debug %then %ut_errmsg(msg=dir=&mult_file_dir,macroname=mdprint,print=0);
  %let mult_file_dir_col = %index(&mult_file_dir,%str(/));
  %if &mult_file_dir_col = 0 %then
   %let mult_file_dir_col = %index(&mult_file_dir,%str(\));
  %if &mult_file_dir_col > 0 %then
   %let mult_file_dir = %sysfunc(reverse(%substr(&mult_file_dir,&mult_file_dir_col)));
  %else %let mult_file_dir =;
  %if &debug %then %ut_errmsg(msg=mult_file_dir=&mult_file_dir 
   mult_file_col=&mult_file_dir_col,macroname=mdprint,print=0);
  %* --------------------------------------------------------------------------;
  %* Determine mult_file_prefix- html filename from htmlfile or htmlfileref;
  %* --------------------------------------------------------------------------;
  %if &debug %then
   %ut_errmsg(mult_file_prefix=&mult_file_prefix,macroname=mdprint,print=0);
  %let mult_file_prefix= %scan(%sysfunc(reverse(&mult_file_prefix)),1,%str(/\));
  %if &debug %then
   %ut_errmsg(msg=mult_file_prefix=&mult_file_prefix,macroname=mdprint,print=0);
  %if %index(&mult_file_prefix,%str(.)) > 0 %then
   %let mult_file_prefix = %scan(&mult_file_prefix,2,%str(.));
  %let mult_file_prefix = %sysfunc(reverse(&mult_file_prefix));
  %if &debug %then
   %ut_errmsg(msg=mult_file_prefix=&mult_file_prefix,macroname=mdprint,print=0);
%end;
%ut_titlstrt;
%if %bquote(&select) = & %bquote(&exclude) = & %bquote(&title) ^= %then %do;
  %*===========================================================================;
  %* Find latest modification date of any meta data set and catalog entry;
  %*  and issue title with this date appended;
  %* If SELECT or EXCLUDE is specified this moddt may not apply to the metadata;
  %*  that was selected, so no date is added to the title;
  %*===========================================================================;
  %mdmoddt(mdlib=&mdlib,mdprefix=&inprefix,outfmt=datetime13.,verbose=&verbose,
   debug=&debug)
  %let title = &title (&moddt);
%end;
title&titlstrt "&title";
*==============================================================================;
* Copy metadata from MDLIB to work library;
*==============================================================================;
%mdmake(inlib=&mdlib,outprefix=_mp,contents=0,inselect=&select,
 inexclude=&exclude,inprefix=&inprefix,addparam=1,mode=replace,
 addheader=&addheader,verbose=&verbose,debug=&debug)
*==============================================================================;
* Issue filename to catalog for subsequent printing;
*==============================================================================;
filename _mpdesc catalog 'work._mpdescriptions';
*==============================================================================;
* Read table metadata set to determine column lengths for subsequent printing;
*==============================================================================;
data _null_;
  if eof then do;
    %if ^ &html %then %do;
      call symput('tablelen',trim(left(put(max(tablelen,0),3.0))));
      call symput('tlabellen',trim(left(put(max(tlabellen,0),3.0))));
    %end;
    call symput('typelen',trim(left(put(max(typelen,0),3.0))));
    call symput('loclen',trim(left(put(max(loclen,0),3.0))));
    call symput('tshortlen',trim(left(put(max(tshortlen,0),3.0))));
  end;
  set _mptables end=eof;
  by table;
  if first.table + last.table ^= 2 then %ut_errmsg(msg='Duplicate table name '
   'in tables data set ' table,macroname=mdprint,print=0,debug=&debug);
  if last.table;
  %if ^ &html %then %do;
    if table ^= ' ' & length(table) > tablelen then tablelen = length(table);
    if tlabel ^= ' ' & length(tlabel) > tlabellen then
     tlabellen = length(tlabel);
  %end;
  if type ^= ' ' & length(trim(type)) > typelen then
   typelen = length(trim(type));
  if location ^= ' ' & length(location) > loclen then
   loclen = length(location);
  if tshort ^= ' ' & length(tshort) > tshortlen then
   tshortlen = length(tshort);
  retain
   %if ^ &html %then %do;
     tablelen tlabellen
   %end;
   typelen loclen tshortlen;
  drop
   %if ^ &html %then %do;
     tablelen tlabellen
   %end;
   typelen loclen tshortlen;
run;
%*=============================================================================;
%* Compute print column numbers for data set information;
%* C1 table          tablelen      col header=13;
%* C2 tshort         tshortlen     col header= 9;
%* C3 tlabel         tlabellen     col header=14;
%* C4 type           typelen       col header= 4;
%* C5 location       loclen        col header= 8;
%*=============================================================================;
%if ^ &html %then %do;
  %let c1 = %eval(&lmargin + 1);
  %let c2 = %eval(&c1 + %sysfunc(max(&tablelen,13)) + 1);
  %if &tshortlen > 0 %then
   %let c3 = %eval(&c2 + %sysfunc(max(&tshortlen,9)) + 1);
  %else %let c3 = &c2;
  %let c4 = %eval(&c3 + %sysfunc(max(&tlabellen,14)) + 1);
  %if &typelen > 0 %then
   %let c5 = %eval(&c4 + %sysfunc(max(&typelen,4)) + 1);
  %else %let c5 = &c4;
  %if &debug %then %ut_errmsg(msg=tablelen=&tablelen tlabellen=&tlabellen 
   typelen=&typelen loclen=&loclen c1=&c1 c2=&c2 c3=&c3 c4=&c4,
   macroname=mdprint,print=0,debug=&debug);
%end;
%else %do;
  %if &debug %then %ut_errmsg(msg=typelen=&typelen loclen=&loclen,
   macroname=mdprint,print=0,debug=&debug);
%end;
*==============================================================================;
* Print the list of data sets and their attributes;
%* Create TABLE and TDESC macro variable arrays;
*==============================================================================;
proc sort data = _mptables  out = _mptablesnodup;
  by table torder;
run;
data _mptablesnodup;
  set _mptablesnodup;
  by table;
  if last.table;
run;
proc sort data = _mptablesnodup;
  by torder table;
run;
data _null_;
  if eof then
   call symput('numtables',trim(left(put(max(numtables,0),8.0))));
  set _mptablesnodup end=eof;
  numtables + 1;
  call symput('table' || trim(left(put(numtables,8.0))),trim(left(table)));
  if tdescription ^= ' ' &
   cexist('work._mpdescriptions.' || trim(left(tdescription)) || '.source')
   then do;
    call symput('tdesc' || trim(left(put(numtables,8.0))),
     trim(left(tdescription)));
    %if &debug %then %do;
      %ut_errmsg(msg='tdescription exists ' _n_= tdescription= table=
       numtables=,macroname=mdprint,print=0,debug=&debug)
    %end;
  end;
  else do;
    call symput('tdesc' || trim(left(put(numtables,8.0))),' ');
    %if &debug %then %do;
      %ut_errmsg(msg='tdescription does ' 'not exist ' _n_= tdescription= table=
       numtables=,macroname=mdprint,type=warning,debug=&debug)
    %end;
  end;
run;
proc sort data = _mptables  out = _mptablesorder;
  by torder table;
run;
data _null_;
  length tlabel location $ 100;
  set _mptablesorder end=eof;
  %if &html %then %do;
    file &outfile;
    if _n_ = 1 then do;
      %ut_htmlhead(title=&title)
      put '<h1 style="text-align:center">'
       "<a name=""dsnlist"">&title</a><br></h1>" /
       '<table style="float:left" border title="List of Data Sets"> <tr> ';
      m1 = -1;  retain m1;
      put
       '<th> Data Set Name </th>'
       %if &tshortlen > 0 %then %do;
         '<th> ShortName </th>'
       %end;
       '<th> Data Set Label </th>'
       %if &typelen > 0 %then %do;
         '<th> Type </th>'
       %end;
       %if &loclen %then %do;
         '<th> Location </th>'
       %end;
       '</tr>'
      ;
    end;
    tlabel = htmlencode(tlabel);
    tlabel = tranwrd(tlabel,'"','&quot;');
    location = htmlencode(location);
    location = tranwrd(location,'"','&quot;');
    put 
     %if ^ &mult_html %then %do;
       "<tr> <td> <a href=""#" table $ +m1 '">' table $ '</a> </td>'
     %end;
     %else %do;
       "<tr> <td> <a href=""./&mult_file_prefix._" table $ +m1 '.html">'
       table $ '</a> </td>'
     %end;
     %if &tshortlen > 0 %then %do;
       '<td>' tshort $ '</td>'
     %end;
     '<td>' tlabel $ '</td>'
     %if &typelen > 0 %then %do;
       '<td>' type $ '</td>'
     %end;
     %if &loclen > 0 %then %do;
       '<td>' location $ '</td>'
     %end;
     '</tr>'
    ;
    if eof then do;
      put '</table>';
      %if %sysfunc(cexist(work._mpdescriptions._spec_.source)) %then %do;
        put '<p><br style="clear:left"></p>'
         '<pre title = "Information about Specification">';
        do until (enddesc);
          infile _mpdesc(_spec_.source) end=enddesc  length=entrylen;
          input @1 line $varying200. entrylen;
          line = htmlencode(line);
          line = tranwrd(line,'"','&quot;');
          curlinelen = length(line);
          put line $varying200. curlinelen;
        end;
        put '</pre>';
      %end;
    end;
  %end;
  %else %do;
    file print header=hdr;
    put 
     @&c1 table
     %if &tshortlen > 0 %then %do;
       @&c2 tshort
     %end;
     @&c3 tlabel
     %if &typelen > 0 %then %do;
       @&c4 type
     %end;
     %if &loclen > 0 %then %do;
       @&c5 location
     %end;
    ;
    %if %sysfunc(cexist(work._mpdescriptions._spec_.source)) %then %do;
      if eof then do;
        put //;
        do until (enddesc);
          infile _mpdesc(_spec_.source) end=enddesc length=entrylen;
          input @1 line $varying200. entrylen;
          curlinelen = length(line);
          put @&c1 line $varying200. curlinelen;
        end;
      end;
    %end;
    return;
    hdr:
     if ^ eof | _n_ = 1 then put
      @&c1 'Data Set Name'
      %if &tshortlen > 0 %then %do;
        @&c2 'ShortName'
      %end;
      @&c3 'Data Set Label'
      %if &typelen > 0 %then %do;
        @&c4 'Type'
      %end;
      %if &loclen > 0 %then %do;
        @&c5 'Location'
      %end;
      /
      @&c1 %sysfunc(max(&tablelen,13))*'-'
      %if &tshortlen > 0 %then %do;
        @&c2 9*'-'
      %end;
      @&c3 %sysfunc(max(&tlabellen,14))*'-'
      %if &typelen > 0 %then %do;
        @&c4 5*'-'
      %end;
      %if &loclen > 0 %then %do;
        @&c5 %sysfunc(max(&loclen,8))*'-'
      %end;
    ;
    return;
  %end;
run;
*==============================================================================;
* Print column information for each data set;
*==============================================================================;
*==============================================================================;
* Add CPKEYYN, HASCOLUMNS and TLABEL variables to _mpcolumns metadata set;
*  and check for tables that have no columns defined;
* Add observation to COLUMNS if a table defined in TABLES has no COLUMNS obs;
*==============================================================================;
data _mpcolumns;
  set _mpcolumns;
  if cpkey > 0 then cpkeyyn = 1;
  else cpkeyyn = 0;
run;
proc sort data = _mpcolumns;
  by table column;
run;
data _mphascolumns;
  merge _mpcolumns (in=fromcol keep=table column)
        _mptables (in=fromtab keep=table tlabel);
  by table;
  if first.table then hascolumns = 0;
  if fromcol & column ^= ' ' then hascolumns = 1;
  if last.table;
  if ^ hascolumns then %ut_errmsg(msg='no columns found for table '
   table,macroname=mdprint,type=warning,debug=&debug);
  retain hascolumns;
  keep table tlabel hascolumns;
run;
%if &debug %then %do;
  proc print data = _mphascolumns;
    title%eval(&titlstrt +1) "(mdprint debug) _mphascolumns";
  run;
  title%eval(&titlstrt + 1);
%end;
data _mpcolumns;
  merge _mpcolumns   _mphascolumns;
  by table;
run;
*==============================================================================;
* Add TLABEL variable to _mpcolumns_param metadata set;
*  and check for tables that have no column parameters defined;
*==============================================================================;
data _mpcolumns_param;
  merge _mpcolumns_param (in=fromcolp)
        _mptables (in=fromtab keep=table tlabel);
  by table;
  if ^ fromcolp then %ut_errmsg(msg='no parameters found for table '
   table $32.,macroname=mdprint,print=0,debug=&debug);
  if fromcolp;
run;
*==============================================================================;
* Add HASVALUES flag variable to _mpcolumns and _mpcolumns_param;
*==============================================================================;
proc sort data = _mpvalues (keep = format  where = (format ^= ' '))
 out = _mpvalfl  nodupkey;
  by format;
run;
proc sort data = _mpcolumns;
  by cformat;
run;
data _mpcolumns;
  merge _mpcolumns (in=fromcol)  _mpvalfl (in=fromval rename=(format=cformat));
  by cformat;
  if fromcol;
  if fromval then hasvalues = 1;
  else hasvalues = 0;
run;
proc sort data = _mpcolumns_param;
  by pformat;
run;
data _mpcolumns_param;
  merge _mpcolumns_param (in=fromcolp)
        _mpvalfl (in=fromval rename=(format=pformat));
  by pformat;
  if fromcolp;
  if fromval then hasvalues = 1;
  else hasvalues = 0;
run;
*==============================================================================;
* Sort data sets in the order their contents will be listed;
*==============================================================================;
%* This should be the same order in mdcheck and mdorder;
proc sort data = _mpcolumns;
  by table descending cpkeyyn cpkey cheader corder column;
run;
proc sort data = _mpvalues;
  by format start;
run;
proc sort data = _mpcolumns_param;
  by table column param pheader porder paramrel;
run;
%if &numtables > 0 %then %do tablenum = 1 %to &numtables;
  *============================================================================;
  %bquote(* &tablenum Processing table &&table&tablenum;)
  *============================================================================;
  %if &html & &mult_html %then %let outfile_current 
   = &mult_file_dir.&mult_file_prefix._&&table&tablenum...html;
  %else %let outfile_current = &outfile;
  %if &mult_html %then %do;
    data _null_;
      file "&outfile_current";
      %ut_htmlhead
      stop;
    run;
  %end;
  *----------------------------------------------------------------------------;
  * Call mdcpput macro to print list of columns in current table;
  *----------------------------------------------------------------------------;
  %mdcpput(table=&&table&tablenum,lmargin=&lmargin,html=&html,
   htmlfile=&outfile_current,htmlfileref=&htmlfileref,
   descriptions=&descriptions,values=&values,labellong=&labellong,
   userformats=&userformats,maxvaluesobs=&maxvaluesobs,debug=&debug)
  *----------------------------------------------------------------------------;
  * Call mdcpput macro to print list of column parameters in current table;
  %* Print _param data set information from columns_param;
  %* same print logic as above where current table and each column/param;
  %* print param values for each table / column-with-params instead of each
   table;
  %* marray of cols with params in current table and do loop each of these;
  *----------------------------------------------------------------------------;
  %let cparamfl = 0;
  data _null_;
    set _mpcolumns (where = (upcase(table) = "%upcase(&&table&tablenum)")
     keep=table cparamfl cparamrelfl cparamrel_miss);
    if cparamfl | cparamrelfl then do;
      call symput('cparamfl','1');
      stop;
    end;
  run;
  %if &cparamfl %then %do;
    %let numparamcols = 0;
    data _null_;
      if eof & numparamcols > 0 then
       call symput('numparamcols',compress(put(numparamcols,7.0)));
      set _mpcolumns_param
       (where = (upcase(table) = "%upcase(&&table&tablenum)")) end=eof;
      by table column;
      if first.column;
      numparamcols + 1;
      call symput('paramcol' || compress(put(numparamcols,7.0)),
       trim(left(column)));
    run;
    %do paramcolnum = 1 %to &numparamcols;
      *======================================================================;
      %bquote(* Parameter Variables in table &&table&tablenum
       Column &paramcolnum &&paramcol&paramcolnum;)
      *======================================================================;
      %mdcpput(table=&&table&tablenum,paramvar=&&paramcol&paramcolnum,
       lmargin=&lmargin,html=&html,
       htmlfile=&outfile_current,htmlfileref=&htmlfileref,
       descriptions=&descriptions,values=&values,labellong=&labellong,
       userformats=&userformats,maxvaluesobs=&maxvaluesobs,debug=&debug)
    %end; /* paramcolnum loop */
  %end;   /* cparamfl loop */
  %if &mult_html %then %do;
    data _null_;
      file "&outfile_current" mod;
      %ut_htmlhead(end=1)
      stop;
    run;
  %end;
%end;     /* numtables loop */

%if &html %then %do;

  data _null_;
    file &outfile mod;
    %ut_htmlhead(end=1)
  run;
%end;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _mp: / memtype=all;
  run; quit;
%end;
title&titlstrt;
filename _mpdesc clear;
%endmac:
%mend;
