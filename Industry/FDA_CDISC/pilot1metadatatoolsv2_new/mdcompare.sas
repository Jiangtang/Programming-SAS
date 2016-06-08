%macro mdcompare(baselib=_default_,complib=_default_,checkcat=_default_,
 select=_default_,exclude=_default_,mdprefixb=_default_,mdprefixc=_default_,
 printdif=_default_,compare=_default_,base=_default_,compall=_default_,
 mode=_default_,outlib=_default_,xxdata=_default_,xxvars=_default_,
 observat=_default_,project=_default_,outprefix=_default_,print=_default_,
 complengths=_default_,verbose=_default_,debug=_default_);
  /*soh************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdcompare
TYPE                     : utility
DESCRIPTION              : Compares metadata sets and catalog entries and
                           reports differences.  Useful to compare
                           specification information when you have two
                           versions of a specification or to compare a study
                           requirement to standards.  Optionally creates
                           output data sets containing the results of the
                           comparison.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\mdcompare\mdcompare DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS
BROAD-USE MODULES        : ut_logical mdmake ut_titlstrt ut_entrycomp
                           ut_errmsg mdadstandard ut_parmdef
INPUT                    : Metadata residing in libraries specified by the 
                            BASELIB and COMPLIB parameters
OUTPUT                   : A report sent to the current ODS destination
                           Optional output data sets written to a library
                            specified by the OUTLIB parameter.
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _ir
--------------------------------------------------------------------------------
Parameters:
Name      Type     Default  Description and Valid Values
--------- -------- -------- -------------------------------------------------
BASELIB   required          Libref of baseline meta information to compare to
COMPLIB   required          Libref of comparison meta information to compare
MDPREFIXB optional          Prefix of metadata names in BASELIB
MDPREFIXC optional          Prefix of metadata names in COMPLIB
CHECKCAT  required 1        %ut_logical value specifying whether to compare
                             content of catalog entries.  Comparing catalog
                             entries can cause longer execution time, so if
                             catalog entries are not of interest set CHECKCAT
                             to a false value.
SELECT    optional          List of data sets defined in the meta data to 
                             include in the comparison.
EXCLUDE   optional          List of data sets defined in the meta data to 
                             exclude from the comparison
PRINTDIF  required 1000     Maximum number of lines to print of the
                             differences between catalog entries describing
                             derivations (passed to ut_entrycomp macro)
PRINT     required 1        ut_logical value specifying whether to generate
                             printed output reporting the differences between
                             baselib and complib.  It may be helpful to set
                             this to a false value when OUTLIB is not null.
BASE      required base     Word to use in output listing to identify 
                             information from BASELIB
COMPARE   required compare  Word to use in output listing to identify 
                             information from COMPLIB
COMPALL   required 1        %ut_logical value specifying whether to compare
                             all meta variables in BASELIB to COMPLIB.
                             When COMPALL is false, the following are not
                             compared or compared differently:
                             tables: torder tdescription location
                             columns: cpkey cshort corder corder clabellong 
                              cformatflag cimportance cderivetype cdomain
                              cheader cdescription
                             columns_param is not compared when COMPALL is 
                              false
MODE      required listall  Defines mode of comparison - listall, listbase 
                             or listcomp.  This works like the PROC COMPARE
                             statement options of the same name.
OUTLIB    optional          Libref where output data sets are written.
OUTPREFIX optional          Prefix applied to the data set names written to
                             OUTLIB
XXDATA     required _none_  Parameter value passed to mdadstandard macro.
                              Defines whether and how to create copies of 
                              data sets whose names end with "XX" that are
                              defined in the INLIB metadata.  The data
                              set whose names end in "XX" are template
                              data set definitions that should be copied
                              for each study phase.
                             _none_ : do not create copies of data set
                              definitions whose names end in "XX"
                             _any_ : create copies of data set definitions
                              and replace the "XX" with a suffix defined in
                              the XXDATAVALS parameter
                             otherwise : other values of XXDATA are assumed
                              to be a blank delimited list of suffixes 
                              Each copy of an XX data set will be renamed 
                              using these suffixes.  The "XX" will be
                              replaced by a suffix in the XXDATA parameter.
                              A copy of the XX data set definition is made
                              for each XXDATA suffix defined.  The suffix
                              of _null_ will make a copy and replace "XX"
                              with the null character (i.e. no suffix).
XXVARS    required _none_   Parameter value passed to mdadstandard macro.
                             Defines special processing for BASE COLUMN names
                             in the COLUMNS metadata set and PARAMRELCOL in
                             the COLUMNS_PARAM metadata set.  Variables
                             whose names end in XX are templates for names
                             and the XX can be substituted with suffixes 
                             that indicated study phase.
                            _none_ This value will specify not to process
                             variables ending in XX differently than other
                             variables.
                            _any_ This value will allow any suffix to be
                             substituted that replaces XX in the variable
                             names defined in the BASE metadata. This also
                             allows a null suffix (suffixless) to be defined.
                            list of suffixes This value is a blank 
                             delimited list of suffixes that will be allowed
                             to replace XX in variables whose names end in
                             XX.
OBSERVAT  optional null     Parameter passed to mdadstandard macro.
                             Lists data sets defined in COMPLIB that should
                             conform to the OBSERVAT data set in BASELIB.
                             The value is a list of data set names followed
                             by the prefix associated with that data set name.
                             e.g. data1 prefix1 data2 prefix2 vit vs.  The
                             prefix will be added to the variable names in 
                             the BASELIB observat data set definition - 
                             variables whose names begin with "OBS" will 
                             be changed to a name where the prefix replaces
                             "OBS".  The observat data set definition will
                             be replicated for each data set listed in 
                             the OBSERVAT parameter and the variable names
                             beginning with "OBS" will be change to the 
                             new prefix that follows the data set name.
                             If OBSERVAT is null no comparison to the 
                              observat data set will be done.
PROJECT    optional         Value of PROJECT variable in OUTLIB parameters
                             data set.  This is used solely to populate the
                             PROJECT variable in the output data sets.
COMPLENGTHS required 1      %ut_logical value specifying whether to compare
                             the CLENGTH variable in the COLUMNS metadata set
                             and the PLENGTH variable in the COLUMNS_PARAM
                             data set.
VERBOSE   required 1        %ut_logical value specifying whether verbose mode
                             is on or off
DEBUG     required 0        %ut_logical value specifying whether debug mode
                             is on or off
--------------------------------------------------------------------------------
Usage Notes:

  The call this macro makes to ut_entrycomp will create an OUTLIB data set named
  descriptions_list

--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

  %mdcompare(baselib=metagen,complib=m)
  
    Compares the study ADS requirements that reside in metadata in the m libref
    to the ADS standard that resides in metadata in the metagen libref.

  %mdcompare(baselib=metagen,complib=m,outlib=<libref>,print=no)
  
    Compares the study ADS requirements that reside in metadata in the m libref
    to the ADS standard that resides in metadata in the metagen libref and 
    reports the results in output data sets instead of a printed listing.
  -----------------------------------------------------------------------------
      Author &
Ver#  Peer Reviewer    Request #        Broad-Use MODULE History Description
----  ---------------- ---------------  -------------------------------------
1.0   Gregory Steffens BMRGCS27JUN2005A Original version of the broad-use
        Sheetal Lal                      module 27Jun05
2.0   Gregory Steffens BMRKW14FEB2006A  January 2006
        Vijay Sharma                    When COMPALL is false, compares
                                         format names only when formatflag
                                         = 1 in base or compare.
                                        Suppress two notes about tables
                                         with no columns_param
                                        Suppress note 0 matching
                                         observations found in &mdsn to be
                                         generated only when the &mdsn
                                         data set has at least one
                                         observation.
                                        Suppress when COMPALL is false
                                         proc report with title of
                                         Formats in &base but not in
                                         &compare and clarified title to 
                                         Formats defined in VALUES in
                                          &base but not in &compare
                                        proc report with title of
                                         Formats in &compare but not in
                                         &base
                                         clarified title to 
                                         Formats defined in VALUES in
                                          &compare but not in &base
                                        Clarified title of proc print of
                                         _itformatmap
                                        Clarified message from
                                         &base values data set has no
                                         referenced formats
                                         to
                                         VALUES data set has no referenced
                                         formats in &base
                                         the above message is sent to the
                                         log only and not to print
                                        Clarified message from
                                         &compare values data set has no
                                         referenced formats
                                         to
                                         VALUES data set has no referenced
                                         formats in &compare
                                         the above message is sent to the
                                         log only and not to print
                                        Added FREQ tables of attribute
                                         differences
                                        Modified second and third titles
                                        Made conditional on debug true of
                                         list of Formats with different
                                         names but associated with same
                                         column name
                                        Made proc freq of column by
                                         attribute conditional on at least
                                         one attribute being different
                                        Added BASE and COMPARE parameters
                                         to first title
                                        Supress physical path in title 
                                         when BASELIB or COMPLIB are work
                                        Enhanced comparison of CFORMAT
                                         when COMPALL is false
                                        Added the new TSHORT variable of
                                         the TABLES metadata set to the
                                         list of variables being compared.
                                         TSHORT is compared only when
                                         COMPALL is true.
                                        Added COMPLENGTHS parameter
                                        Supressed comparison of table type
                                         when COMPALL is false and either
                                         type value is missing
2.1   Gregory Steffens BMRKW21FEB2007A SAS version 9 migration
       Michael Fredericksen
3.0   Gregory Steffens BMR             Compare variable types only when 
                                        COMPALL is true
                                       Changed array index maximum format from
                                        7.0 to 32.0 in call symputs
  **eoh************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(baselib,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(complib,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(mdprefixb,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(mdprefixc,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(checkcat,1,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(printdif,1000,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(print,1,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(base,%str(base   ),_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(compare,compare,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(compall,1,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(mode,listall,listall listbase listcomp,_pdmacroname=mdcompare,
 _pdrequired=1)
%ut_parmdef(select,_default_,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(exclude,_default_,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(outlib,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(outprefix,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(xxdata,_default_,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(xxvars,_default_,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(observat,_default_,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(project,_pdmacroname=mdcompare,_pdrequired=0)
%ut_parmdef(complengths,1,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=mdcompare,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=mdcompare,_pdrequired=1)
%ut_logical(checkcat)
%ut_logical(compall)
%ut_logical(complengths)
%ut_logical(print)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt i mdsn param paramrel pc parcol nobsnb nobsnc nobsb nobsc ls
 libexists i done next run_time access_macro all_tables_same all_cp_same dsid
 source_varnum;
%let mode = %upcase(&mode);
%ut_titlstrt
title&titlstrt "(mdcompare) Comparison of meta data sets in "
 "&baselib &base and &complib &compare"
 %if %bquote(&mdprefixb) ^= %then %do;
   " mdprefixb=&mdprefixb"
 %end;
 %if %bquote(&mdprefixc) ^= %then %do;
   " mdprefixc=&mdprefixc"
 %end;
;
%let libexists = 0;
title%eval(&titlstrt + 1) "(mdcompare) Base:&baselib"
 %if %bquote(&baselib) ^= %then %do;
   %if %sysfunc(libref(&baselib)) = 0 & %bquote(%upcase(&baselib)) ^= WORK %then
    %do;
     ": %sysfunc(pathname(&baselib))"
     %let libexists = 1;
   %end;
 %end;
 %if ^ &libexists & %bquote(&base) ^= %then %do;
   ": &base"
 %end;
;
%let libexists = 0;
title%eval(&titlstrt + 2) "(mdcompare) Compare:&complib"
 %if %bquote(&complib) ^= %then %do;
   %if %sysfunc(libref(&complib)) = 0 & %bquote(%upcase(&complib)) ^= WORK %then
    %do;
     ": %sysfunc(pathname(&complib))"
     %let libexists = 1;
   %end;
 %end;
 %if ^ &libexists & %bquote(&compare) ^= %then %do;
   ": &compare"
 %end;
;
%let ls = %sysfunc(getoption(linesize));
%if %bquote(&outlib) ^= %then %do;
  %if %sysfunc(libref(&outlib)) ^= 0 %then %do;
    %let outlib =;
    %ut_errmsg(msg="Outlib libref does not exist (&outlib) - "
     "reassigning to null",macroname=mdcompare,print=0)
  %end;
%end;
%if %bquote(&outlib) ^= %then %do;
  *============================================================================;
  * Create output data set containing macro parameter values;
  *============================================================================;
  data _irparameters_list;
    length project $ 20  run_time 8  module_name $ 32 parameter $ 32  seqid 8
     value $ 65;
    format run_time datetime15.;
    project = "&project";
    run_time = input("&sysdate9:&systime",datetime15.);
    call symput('run_time',trim(left(put(run_time,12.0))));
    module_name = 'mdcompare';
    parameter = 'baselib';    seqid = 1;    value = "&baselib";    output;
    parameter = 'complib';    seqid = 1;    value = "&complib";    output;
    parameter = 'checkcat';   seqid = 1;    value = "&checkcat";   output;
    %let i = 0;    %let done = 0;
    %if %bquote(&select) ^= %then %do %until (&done);
      parameter = 'select';     
      %let i = %eval(&i + 1);
      %let next = %scan(&select,&i,%str( ));
      %if %bquote(&next) ^= %then %do;
        seqid = &i;    value = "&next";     output;
      %end;
      %else %let done = 1;
    %end;
    %let i = 0;    %let done = 0;
    %if %bquote(&exclude) ^= %then %do %until (&done);
      parameter = 'exclude';
      %let i = %eval(&i + 1);
      %let next = %scan(&exclude,&i,%str( ));
      %if %bquote(&next) ^= %then %do;
        seqid = &i;    value = "&next";     output;
      %end;
      %else %let done = 1;
    %end;
    parameter = 'mdprefixb';  seqid = 1;    value = "&mdprefixb";  output;
    parameter = 'mdprefixc';  seqid = 1;    value = "&mdprefixc";  output;
    parameter = 'printdif';   seqid = 1;    value = "&printdif";   output;
    parameter = 'print';      seqid = 1;    value = "&print";      output;
    parameter = 'compare';    seqid = 1;    value = "&compare";    output;
    parameter = 'base';       seqid = 1;    value = "&base";       output;
    parameter = 'compall';    seqid = 1;    value = "&compall";    output;
    parameter = 'mode';       seqid = 1;    value = "&mode";       output;
    parameter = 'outlib';     seqid = 1;    value = "&outlib";     output;
    parameter = 'outprefix';  seqid = 1;    value = "&outprefix";  output;
    parameter = 'xxvars';     seqid = 1;    value = "&xxvars";     output;
    parameter = 'xxdata';     seqid = 1;    value = "&xxdata";     output;
    %let i = 0;    %let done = 0;
    %if %bquote(&observat) ^= %then %do %until (&done);
      parameter = 'observat';
      %let i = %eval(&i + 1);
      %let next = %scan(&observat,%eval(&i + (&i - 1)),%str( ));
      %let next = &next %scan(&observat,%eval(&i + &i),%str( ));
      %if %bquote(&next) ^= %then %do;
        seqid = &i;    value = "&next";     output;
      %end;
      %else %let done = 1;
    %end;
    parameter = 'project';    seqid = 1;    value = "&project";    output;
    parameter = 'verbose';    seqid = 1;    value = "&verbose";    output;
    parameter = 'debug';      seqid = 1;    value = "&debug";      output;
    stop;
  run;
  proc sort data=_irparameters_list
   out=&outlib..&outprefix.macro_parameters_list;
    by project run_time parameter seqid;
  run;
  *============================================================================;
  * Create OUTLIB SUMMARY_LIST data set;
  *============================================================================;
  data &outlib..&outprefix.summary_list;
    length project $ 20  run_time 8 user_id_submitter $ 10
     base_path comp_path $ 200;
    user_id_submitter = "&sysuserid";
    format run_time datetime15.;
    project = "&project";
    run_time = &run_time;
    base_path = pathname("&baselib");
    comp_path = pathname("&complib");
    output;
    stop;
  run;
%end;
%else %do;
  data _null_;
    run_time = input("&sysdate9:&systime",datetime15.);
    call symput('run_time',trim(left(put(run_time,12.0))));
    stop;
  run;
%end;
*==============================================================================;
* Call the mdmake macro to copy the comp metadatabase into work with the;
*  prefix _irc for comparison to the base metadata in work with the prefix _irb;
*==============================================================================;
%mdmake(inlib=&complib,outlib=work,inprefix=&mdprefixc,outprefix=_irc,
 inselect=&select,inexclude=&exclude,contents=0,mode=replace,verbose=&verbose)
*==============================================================================;
* Copy the base metadata to work with the prefix _irb;
*==============================================================================;
%if (%bquote(&observat) ^= & %bquote(%upcase(&observat)) ^= _DEFAULT_) |
 (%bquote(&xxdata) ^= & %bquote(%upcase(&xxdata)) ^= _NONE_ &
 %bquote(%upcase(&xxdata)) ^= _DEFAULT_) |
 (%bquote(&xxvars) ^= & %bquote(%upcase(&xxvars)) ^= _NONE_ &
 %bquote(%upcase(&xxvars)) ^= _DEFAULT_) %then %do;
  %mdadstandard(inlib=&baselib,outlib=work,inprefix=&mdprefixb,outprefix=_irb,
   select=&select,exclude=&exclude,contents=0,observat=&observat,
   xxdata=&xxdata,xxdatavals=_irctables,xxvars=&xxvars,xxvarsvals=_irccolumns,
   verbose=&verbose,debug=&debug)
  %let access_macro = mdadstandard;
%end;
%else %do;
  %mdmake(inlib=&baselib,outlib=work,inprefix=&mdprefixb,outprefix=_irb,
   inselect=&select,inexclude=&exclude,contents=0,mode=replace,
   verbose=&verbose,debug=&debug)
  %let access_macro = mdmake;
%end;
*==============================================================================;
* Sort and compare tables meta data sets;
*==============================================================================;
proc sort data = _irbtables
 out = _irdsnsb (label="&baselib..&mdprefixb.tables");
  by table;
run;
data _null_;
  if eof & _n_ = 1 then %ut_errmsg(msg="No observations found in &base tables",
   type=note,macroname=mdcompare,print=0);
  stop;
  set _irbtables end=eof;
run;
proc sort data = _irctables
 out = _irdsnsc (label="&complib..&mdprefixc.tables");
  by table;
run;
data _null_;
  if eof & _n_ = 1 then
   %ut_errmsg(msg="No observations found in &compare tables",type=note,
   macroname=mdcompare,print=0);
  stop;
  set _irctables end=eof;
run;
title%eval(&titlstrt + 3) "(mdcompare) Comparison of "
 "&baselib..&mdprefixb.tables and &complib..&mdprefixc.tables";
data _irtboth
     _irtnotbase (keep=table _tlabel)
     _irtnotcomp (keep=table tlabel);
  merge _irdsnsb (in=frombase)
        _irdsnsc (in=fromcomp rename=(tlabel=_tlabel type=_type torder=_torder
                  tdescription=_tdescription location=_location tshort=_tshort))
  ;
  by table;
  if first.table + last.table ^= 2 then
   %ut_errmsg(msg="Table defined more than once " table frombase= fromcomp=,
    macroname=mdcompare,type=note);
  if first.table;
  if frombase & fromcomp then output _irtboth;
  else if ^ frombase then output _irtnotbase;
  else if ^ fromcomp then output _irtnotcomp;
run;
%if &print %then %do;
  %if &mode = LISTALL | &mode = LISTCOMP %then %do;
    proc print data = _irtnotbase  width=minimum;
     title%eval(&titlstrt + 3)
      "(mdcompare) Data Sets found in &compare but not &base";
    run;
    title%eval(&titlstrt + 3);
  %end;
  %if &mode = LISTALL | &mode = LISTBASE %then %do;
    proc print data = _irtnotcomp  width=minimum;
     title%eval(&titlstrt + 3)
      "(mdcompare) Data Sets found in &base but not &compare";
    run;
    title%eval(&titlstrt + 3);
  %end;
%end;

%let dsid = %sysfunc(open(_irtboth,i));
%if &dsid > 0 %then %do;
  %let source_varnum=%sysfunc(varnum(&dsid,source));
  %let dsid = %sysfunc(close(&dsid));
%end;
%else %let source_varnum = 0;

%let all_tables_same = 0;
data _irtables_list_parent (keep=table attribute base comp source);
  file print;
  if eof then do;
    _irnumber_tables = _n_ - 1;
    if err_flag_all ^= 1 & _n_ > 1 then do;
      %ut_errmsg(msg=//// @10
       "All " _irnumber_tables "compared data sets have the same data set "
       "attributes" ////,type=note,macroname=mdcompare,fileback=print)
      call symput('all_tables_same','1');
    end;
    if _n_ = 1 then do;
      %ut_errmsg(msg="0 matching observations found in tables - "
       "comparison details not printed" /,macroname=mdcompare,type=warning,
       fileback=print)
    end;
  end;
  set _irtboth  end=eof;
  length attribute $ 32 base comp $ 400;

  %if &source_varnum <= 0 %then %do;
    length source $ 15;
    source = ' ';
  %end;

  errflag = 0;
  if _n_ = 1 then err_flag_all = 0;
  if tlabel ^= _tlabel & upcase(source) ^ in ('OBSERVAT' 'XXDATA') then do;
    attribute = 'tlabel';
    base = tlabel;
    comp = _tlabel;
    link headerline;
  end;
  if type ^= _type
   %if ^ &compall %then %do;
     & type ^= ' ' & _type ^= ' '
   %end;
   then do;
    attribute = 'type';
    base = type;
    comp = _type;
    link headerline;
  end;
  %if &compall %then %do;
    if torder ^= _torder then do;
      attribute = 'torder';
      base = left(put(torder,best.));
      comp = left(put(_torder,best.));
      link headerline;
    end;
    if tdescription ^= _tdescription then do;
      attribute = 'tdescription';
      base = tdescription;
      comp = _tdescription;
      link headerline;
    end;
    if location ^= _location then do;
      attribute = 'location';
      base = location;
      comp = _location;
      link headerline;
    end;
    if tshort ^= _tshort then do;
      attribute = 'tshort';
      base = tshort;
      comp = _tshort;
      link headerline;
    end;
  %end;
  if errflag = 1 then err_flag_all = 1;
  else do;
    attribute = 'same';
    base = ' ';
    comp = ' ';
    output;
  end;
  return;
    headerline:
    if ^ errflag then do;
      %if &print %then %do;
        put &ls*"=" / 'Data Set: ' table /;
      %end;
      errflag = 1;
    end;
    %if &print %then %do;
      %ut_errmsg(msg='Data Set ' attribute +(-1) 's do not match ' /
       @4 "&base: " base / @4 "&compare: " comp /,
       type=note,macroname=mdcompare,max=,log=0);
    %end;
    output;
  return;
  retain err_flag_all;
  drop _ir:;
run;
data _irtables_list;
  length project $ 20  run_time 8;
  format run_time datetime15.;
  project = "&project";
  run_time = &run_time;
  set _irtables_list_parent (in=inboth)
   %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTCOMP %then %do;
     _irtnotbase (in=notinbase keep=table)
   %end;
   %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTBASE %then %do;
     _irtnotcomp (in=notincomp keep=table)
   %end;
  ;
  if inboth & source = ' ' then source = 'both';
  %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTCOMP %then %do;
    if notinbase then do;
      attribute = 'non-corresponding';
      if source = ' ' then source = 'comp           ';
    end;
  %end;
  %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTBASE %then %do;
    if notincomp then do;
       attribute = 'non-corresponding';
       if source = ' ' then source = 'base           ';
    end;
  %end;
run;
%if ^ &all_tables_same %then %do;
  proc freq data = _irtables_list;
    table table * attribute / missing norow nocol nopercent;
  run;
%end;
%if %bquote(&outlib) ^= %then %do;
  proc sort data = _irtables_list    out = &outlib..&outprefix.tables_list
   (label="Compare &baselib..&mdprefixb.tables to &complib..&mdprefixc.tables");
    by table attribute;
  run;
%end;
title%eval(&titlstrt + 3);
%*=============================================================================;
%* Process columns and columns_param metadata sets;
%*=============================================================================;
%do i = 1 %to 2;
  %if &i = 1 %then %do;
    %let mdsn = columns;
    %let param =;
    %let paramrel =;
    %let pc = c;
    %let parcol = Variable;
  %end;
  %else %do;
    %let mdsn = columns_param;
    %let param = param;
    %let paramrel = paramrel;
    %let pc = p;
    %let parcol = Parameter;
  %end;
  *============================================================================;
  %bquote(* Keep obs in &mdsn only if the table that the column is in exists;)
  *  in both base and compare - dont compare columns when the tables are not in;
  *  both base and compare;
  *============================================================================;
  proc sort data = _irb&mdsn  out = _irvarsb;
    by table column &param &paramrel;
  run;
  %let nobsnb = 0;
  %let nobsb = 0;
  data _irvarsb (label="&baselib..&mdprefixb.columns")
       _irvarsbtnotboth (keep = table column &param &paramrel &pc.label
        %if &access_macro = mdadstandard %then %do;
          source
        %end;
        );
    if eof then do;
      if _irnumobs > . then
       call symput('nobsnb',trim(left(put(_irnumobs,32.0))));
      if _irnobsb > . then
       call symput('nobsb',trim(left(put(_irnobsb,32.0))));
    end;
    merge _irvarsb (in=invarsb)  _irtboth (in=inboth keep=table) end=eof;
    by table;
    if invarsb then _irnobsb + 1;
    if inboth & invarsb then do;
      _irnumobs + 1;
      output _irvarsb;
    end;
    else if ^ inboth then output _irvarsbtnotboth;
    %if &mdsn ^= columns_param %then %do;
      else if ^ invarsb then %ut_errmsg(msg="Table has no &mdsn in &base "
       table=,type=note,macroname=mdcompare);
    %end;
    drop _irnumobs _irnobsb;
  run;
  proc sort data = _irc&mdsn  out = _irvarsc;
    by table column &param &paramrel;
  run;
  %let nobsnc = 0;
  %let nobsc = 0;
  data _irvarsc (label="&complib..&mdprefixc.columns")
       _irvarsctnotboth (keep = table column &param &paramrel &pc.label);
    if eof then do;
      if _irnumobs > . then
       call symput('nobsnc',trim(left(put(_irnumobs,32.0))));
      if _irnobsc > . then
       call symput('nobsc',trim(left(put(_irnobsc,32.0))));
    end;
    merge _irvarsc (in=invarsc)  _irtboth (in=inboth keep=table) end=eof;
    by table;
    if invarsc then _irnobsc + 1;
    if inboth & invarsc then do;
      _irnumobs + 1;
      output _irvarsc;
    end;
    else if ^ inboth then output _irvarsctnotboth;
    %if &mdsn ^= columns_param %then %do;
      else if ^ invarsc then %ut_errmsg(msg="Table has no &mdsn in &compare "
       table=,type=note,macroname=mdcompare);
    %end;
    drop _irnumobs _irnobsc;
  run;
  *============================================================================;
  %bquote(* Compare &mdsn meta data set;)
  *============================================================================;
  title%eval(&titlstrt + 3) "(mdcompare) Comparison of "
   "&baselib..&mdprefixb.&mdsn and &complib..&mdprefixc.&mdsn";

  %if (&nobsnb = 0 & &nobsb > 0) & (&nobsnc = 0 & &nobsc > 0) %then %do;
    %ut_errmsg(msg="0 matching observations found in &mdsn - "
     "comparison details not printed" /
     "&nobsnb matching obs found in &base out of &nobsb obs" /
     "&nobsnc matching obs found in &compare out of &nobsc obs",
     macroname=mdcompare,type=warning)
  %end;

  %ut_errmsg(msg=nobsnb=&nobsnb nobsb=&nobsb nobsnc=&nobsnc nobsc=&nobsc
   compall=&compall mode=&mode mdsn=&mdsn outlib=&outlib,macroname=mdcompare,
   print=0)
  %if (&compall | &mdsn = columns) &
   (
   (&nobsnb > 0 & &nobsnc > 0) | 
   ((&mode = LISTALL | &mode = LISTBASE) & &nobsnb > 0) |
   ((&mode = LISTALL | &mode = LISTCOMP) & &nobsnc > 0)
   )
   %then %do;
    data _ircboth
         _ircnotbase (keep=table column &param &paramrel &pc.format)
         _ircnotcomp (keep=table column &param &paramrel &pc.format);
      merge _irvarsb (in=frombase)
            _irvarsc (in=fromcomp rename=(&pc.short=_&pc.short
                     &pc.order=_&pc.order &pc.label=_&pc.label 
                     &pc.labellong=_&pc.labellong &pc.type=_&pc.type
                     &pc.length=_&pc.length &pc.format=_&pc.format
                     &pc.formatflag=_&pc.formatflag 
                     &pc.importance=_&pc.importance
                     &pc.derivetype=_&pc.derivetype
                     &pc.domain=_&pc.domain &pc.header=_&pc.header
                     &pc.description=_&pc.description
                     %if %bquote(&mdsn) = columns %then %do;
                       &pc.pkey=_&pc.pkey
                     %end;
                     %else %do;
                       paramrelcol=_paramrelcol
                     %end;
       ));
      by table column &param &paramrel;
      if
       %if %bquote(&paramrel) ^= %then %do; 
         first.&paramrel + last.&paramrel ^= 2
       %end;
       %else %do;
         first.column + last.column ^= 2
       %end;
       then %ut_errmsg(msg="&parcol defined more than once in &mdsn "
       table= column= &param &paramrel frombase= fromcomp= _n_=,
       macroname=mdcompare,type=note);
      if
       %if %bquote(&paramrel) ^= %then %do; 
         first.&paramrel
       %end;
       %else %do;
         first.column
       %end;
      ;
      if frombase & fromcomp then output _ircboth;
      else if ^ frombase then output _ircnotbase;
      else if ^ fromcomp then output _ircnotcomp;
    run;
    %*-------------------------------------------------------------------------;
    %* Print non-matching observations;
    %*-------------------------------------------------------------------------;
    %if &print %then %do;
      %if &mode = LISTALL | &mode = LISTCOMP %then %do;
        proc print data = _ircnotbase  width=minimum;
         title%eval(&titlstrt + 3)
          "(mdcompare) &parcol.s found in &compare but not &base";
        run;
        proc print data = _irvarsctnotboth  width=minimum;
          by table;
          title%eval(&titlstrt + 3) "(mdcompare) &compare &parcol.s found in "
           "tables that do not exist in &base and &compare";
        run;
        title%eval(&titlstrt + 3);
      %end;
      %if &mode = LISTALL | &mode = LISTBASE %then %do;
        proc print data = _ircnotcomp  width=minimum;
          title%eval(&titlstrt + 3)
           "(mdcompare) &parcol.s found in &base but not &compare";
        run;
        proc print data = _irvarsbtnotboth  width=minimum;
          by table;
          title%eval(&titlstrt + 3) "(mdcompare) &base &parcol.s found in "
           "tables that do not exist in &base and &compare";
        run;
        title%eval(&titlstrt + 3);
      %end;
    %end;
    data _ir&mdsn._list_parent (keep=table column &param &paramrel &pc.format
     attribute base comp source);
      file print;
      if eof & err_flag_all ^= 1 & _n_ > 1 then do;
        _irnumber = _n_ - 1;
        %ut_errmsg(msg=//// @10 
         "All " _irnumber " compared &parcol.s attributes compared equal" ////,
          type=note,macroname=mdcompare,fileback=print)
      end;
      set _ircboth end=eof;
      errflag = 0;
      length attribute $ 32 base comp $ 400;
      %if &access_macro = mdmake %then %do;
        length source $ 15;
        source = ' ';
      %end;
      if _n_ = 1 then err_flag_all = 0;
      %if %bquote(&param) = %then %do;
        %if &compall %then %do;
          if &pc.pkey ^= _&pc.pkey then do;
            attribute = "&pc.pkey";
            base = left(put(&pc.pkey,best.));
            comp = left(put(_&pc.pkey,best.));
            link headerline;
          end;
        %end;
      %end;
      %else %do;
        if paramrelcol ^= _paramrelcol then do;
          attribute = "&pc.paramrelcol";
          base = paramrelcol;
          comp = _paramrelcol;
          link headerline;
        end;
      %end;
      %if &compall %then %do;
        if &pc.short ^= _&pc.short
         %if &pc = c %then %do;
           & upcase(source) ^ in ('OBSERVATOBS' 'XXVARS')
         %end;
         then do;
          attribute = "&pc.short";
          base = &pc.short;
          comp = _&pc.short;
          link headerline;
        end;
        %if &pc = c %then %do;
          if upcase(source) ^ in ('OBSERVATOBS' 'XXVARS') &
           length(left(column)) > 8 then do;
            if cshort = ' ' then do;
              attribute = 'cshort';
              base = 'CSHORT must be populated';
              comp = '';
              link headerline;
            end;
            if _cshort = ' ' then do;
              attribute = 'cshort';
              base = ' ';
              comp = 'CSHORT must be populated';
              link headerline;
            end;
          end;
        %end;
      %end;
      if &pc.order ^= _&pc.order
       %if ^ &compall %then %do;
         & &pc.order ^= . & ^ _&pc.order ^= .
       %end;
       then do;
        attribute = "&pc.order";
        base = left(put(&pc.order,best.));
        comp = left(put(_&pc.order,best.));
        link headerline;
      end;
      if &pc.label ^= _&pc.label & upcase(source) ^ in ('OBSERVATOBS' 'XXVARS')
       then do;
        attribute = "&pc.label";
        base = &pc.label;
        comp = _&pc.label;
        link headerline;
      end;
      %if &compall %then %do;
        if &pc.labellong ^= _&pc.labellong then do;
          attribute = "&pc.labellong";
          base = &pc.labellong;
          comp = _&pc.labellong;
          link headerline;
        end;
      %end;
      if &pc.type ^= _&pc.type then do;
        attribute = "&pc.type";
        base = &pc.type;
        comp = _&pc.type;
        link headerline;
      end;
      %if &complengths %then %do;
        if &pc.length ^= _&pc.length then do;
          attribute = "&pc.length";
          base = left(put(&pc.length,best.));
          comp = left(put(_&pc.length,best.));
          link headerline;
        end;
      %end;
      if &pc.format ^= _&pc.format
       %if ^ &compall %then %do;
         & (&pc.formatflag = 1 | _&pc.formatflag = 1)
       %end;
       then do;
        attribute = "&pc.format";
        base = &pc.format;
        comp = _&pc.format;
        link headerline;
      end;
      %if &compall %then %do;
        if &pc.formatflag ^= _&pc.formatflag then do;
          attribute = "&pc.formatflag";
          base = left(put(&pc.formatflag,best.));
          comp = left(put(_&pc.formatflag,best.));
          link headerline;
        end;
        if &pc.importance ^= _&pc.importance then do;
          attribute = "&pc.importance";
          base = &pc.importance;
          comp = _&pc.importance;
          link headerline;
        end;
        if &pc.derivetype ^= _&pc.derivetype then do;
          attribute = "&pc.derivetype";
          base = &pc.derivetype;
          comp = _&pc.derivetype;
          link headerline;
        end;
        if &pc.domain ^= _&pc.domain then do;
          attribute = "&pc.domain";
          base = &pc.domain;
          comp = _&pc.domain;
          link headerline;
        end;
        if &pc.header ^= _&pc.header then do;
          attribute = "&pc.header";
          base = left(put(&pc.header,best.));
          comp = left(put(_&pc.header,best.));
          link headerline;
        end;
        if &pc.description ^= _&pc.description then do;
          attribute = "&pc.description";
          base = &pc.description;
          comp = _&pc.description;
          link headerline;
        end;
      %end;
      if errflag = 1 then err_flag_all = 1;
      else do;
        attribute = 'same';
        base = ' ';
        comp = ' ';
        output;
      end;
      return;
        headerline:
        if ^ errflag then do;
          %if &print %then %do;
            put &ls*'-' / 'Data Set: ' table 'Variable: ' column 
             %if %bquote(&param) ^= %then %do;
               &param paramrel
             %end;
            /;
          %end;
          errflag = 1;
        end;
        %if &print %then %do;
          %ut_errmsg(msg=attribute +(-1) 's do not match ' / @19 "&base: " base
           / @19 "&compare: " comp /,type=note,macroname=mdcompare,max=,log=0)
        %end;
        output;
      return;
      retain err_flag_all;
      drop _ir:;
    run;
    title%eval(&titlstrt + 3);
    data _irvarstnotboth;
      merge _irvarsbtnotboth (in=frombase)
            _irvarsctnotboth (in=fromcomp);
      by table column &param &paramrel;
      length source $ 15;
      if frombase & fromcomp & source = ' ' then source = 'both';
      else if frombase & ^ fromcomp then source = 'base';
      else if fromcomp & ^ frombase then source = 'comp';
      %if %bquote(&mode) = LISTALL %then %do;
        output;
      %end;
      %else %if %bquote(&mode) = LISTCOMP %then %do;
        if fromcomp then output;
      %end;
      %else %if %bquote(&mode) = LISTBASE %then %do;
         if frombase then output;
      %end;
      drop &pc.label;
    run;
    data _ir&mdsn._list;
      length project $ 20  run_time 8;
      format run_time datetime15.;
      project = "&project";
      run_time = &run_time;
      set _ir&mdsn._list_parent (in=inboth)
       %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTCOMP %then %do;
         _ircnotbase (in=notinbase)
       %end;
       %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTBASE %then %do;
         _ircnotcomp (in=notincomp)
       %end;
        _irvarstnotboth (in=varstnotboth)
      ;
      if inboth & source = ' ' then source = 'both';
      %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTCOMP %then %do;
        if notinbase then do;
          attribute = 'non-corresponding';
          if source = ' ' then source = 'comp';
        end;
      %end;
      %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTBASE %then %do;
        if notincomp then do;
          attribute = 'non-corresponding';
          if source = ' ' then source = 'base';
        end;
      %end;
      if varstnotboth then attribute = 'nocompare';
    run;
    %let all_cp_same = 0;
    data _null_;
      if eof then do;
        if _n_ = 1 then call symput('all_cp_same','1');
        else call symput('all_cp_same','0');
      end;
      stop;
      set _ir&mdsn._list (where = (upcase(attribute) ^= 'SAME')) end=eof;
    run;
    %if ^ &all_cp_same %then %do;
      proc freq data = _ir&mdsn._list;
        table table * attribute / missing norow nocol nopercent;
      run;
    %end;
  %end;    /* obs exist in base and compare */
%end;    /* i  1 to 2 columns and columns_param */
*==============================================================================;
* Compare values meta data sets;
*==============================================================================;
*------------------------------------------------------------------------------;
* Map format names between base name and compare name to support comparing;
*  a values list for a column or parameter even when the name of the list;
*  associated with that column or parameter is different in base vs compare;
*------------------------------------------------------------------------------;
proc sort data = _irbcolumns;
  by table column;
run;
proc sort data = _irccolumns;
  by table column;
run;
data _ircformatmap;
  merge 
   _irbcolumns (in=base keep=table column cformat rename=(cformat=cformat_base)
                where=(cformat_base ^= ' '))
   _irccolumns (in=comp keep=table column cformat rename=(cformat=cformat_comp)
                where=(cformat_comp ^= ' '));
  by table column;
  keep cformat_base cformat_comp;
run;
proc sort data = _ircformatmap  nodupkey;
  by cformat_base cformat_comp;
run;
proc sort data = _irbcolumns_param;
  by table column param paramrel;
run;
proc sort data = _irccolumns_param;
  by table column param paramrel;
run;
data _irpformatmap;
  merge 
   _irbcolumns_param (in=base keep=table column param paramrel pformat
                     rename=(pformat=pformat_base) where=(pformat_base ^= ' '))
   _irccolumns_param (in=comp keep=table column param paramrel pformat
                     rename=(pformat=pformat_comp) where=(pformat_comp ^= ' '));
  by table column param paramrel;
  keep pformat_base pformat_comp;
run;
proc sort data = _irpformatmap  nodupkey;
  by pformat_base pformat_comp;
run;
data _irformatmap (keep = format_base format_comp)  _irformatmap_all;
  merge 
   _ircformatmap (rename=(cformat_base=format_base cformat_comp=format_comp))
   _irpformatmap (rename=(pformat_base=format_base pformat_comp=format_comp));
  by format_base format_comp;
  if format_base ^= ' ' & format_comp ^= ' ' & format_base ^= format_comp then
   output _irformatmap;
  if format_comp ^= ' ' then format = format_comp;
  else if format_base ^= ' ' then format = format_base;
  output _irformatmap_all;
run;
%if &debug %then %do;
  proc print data = _ircformatmap width=minimum;
    title%eval(&titlstrt + 3) "(mdcompare) debug: _ircformatmap";
  run;
  proc print data = _irpformatmap width=minimum;
    title%eval(&titlstrt + 3) "(mdcompare) debug: _irpformatmap";
  run;
  title%eval(&titlstrt + 3);
%end;
%if &debug %then %do;
  proc print data = _irformatmap width=minimum;
    title%eval(&titlstrt + 3) "(mdcompare) Formats with different names but "
     "associated with same column name in &base and &compare";
  run;
  title%eval(&titlstrt + 3);
%end;
proc sql;
  create table _irbvalues_mapped as
  select * from _irbvalues b left join _irformatmap m
  on b.format = m.format_base;
quit;
data _irbvalues_mapped;
  set _irbvalues_mapped;

  if format_comp ^= ' ' then format = format_comp;
  else if format_base ^= ' ' then format = format_base;

  if format_base = ' ' & format_comp = ' ' & format ^= ' ' then do;
    format_base = format;
    format_comp = format;
  end;
run;
proc sort data = _irbvalues_mapped;
  by format start end;
run;
%if &debug %then %do;
  proc print data = _irbvalues_mapped (obs=3000)  width=minimum;
    by format;
    title%eval(&titlstrt + 3) "(mdcompare) _irbvalues_mapped (first 3000 obs)";
  run;
  title%eval(&titlstrt + 3);
%end;
proc sort data = _irbvalues_mapped
 out = _irvalsb (label="&baselib..&mdprefixb.values");
  by format start end;
run;
proc sort data = _ircvalues 
 out = _irvalsc (label="&complib..&mdprefixc.values");
  by format start end;
run;
title%eval(&titlstrt + 3) "(mdcompare) Comparison of "
 "&baselib..&mdprefixb.values and &complib..&mdprefixc.values";
*------------------------------------------------------------------------------;
* List formats in both base and compare;
*------------------------------------------------------------------------------;
data _irbformats;
  set _irvalsb (keep = format);
  by format;
  if first.format;
run;
data _ircformats;
  set _irvalsc (keep = format);
  by format;
  if first.format;
run;
data _irfnotinb _irfnotinc _irfinboth;
  merge _irbformats (in=frombase)
        _ircformats (in=fromcompare);
  by format;
  if first.format;
  if ^ frombase then output _irfnotinb;
  else if ^ fromcompare then output _irfnotinc;
  else output _irfinboth;
run;
%if &print %then %do;
  %if &mode = LISTALL | &mode = LISTCOMP %then %do;
    proc report data = _irfnotinb  panels=20  nowindows headline;
      columns format;
      define format / display width=8;
      title%eval(&titlstrt + 4)
       "(mdcompare) Formats defined in VALUES in &compare but not in &base";
    run;
  %end;
  %if (&mode = LISTALL | &mode = LISTBASE) & &compall %then %do;
    proc report data = _irfnotinc  panels=20  nowindows headline;
      columns format;
      define format / display width=8;
      title%eval(&titlstrt + 4)
       "(mdcompare) Formats defined in VALUES in &base but not in &compare";
    run;
  %end;
  title%eval(&titlstrt + 4);
%end;
*------------------------------------------------------------------------------;
* List differences in values for the formats that are in both base and compare;
*------------------------------------------------------------------------------;
data _irvalsb;
  if eof & _n_ = 1 then %ut_errmsg(msg="VALUES data set has no referenced"
   " formats in &base",macroname=mdcompare,type=note,print=0);
  merge _irvalsb (in=frombase)  _irfinboth (in=fromboth)  end=eof;
  by format;
  if fromboth & frombase;
  _irnumobs + 1;
  drop _ir:;
run;
data _irvalsc;
  if eof & _n_ = 1 then
   %ut_errmsg(msg="VALUES data set has no referenced formats in &compare",
   macroname=mdcompare,type=note,print=0);
  merge _irvalsc (in=frombase)  _irfinboth (in=fromboth)  end=eof;
  by format;
  if fromboth & frombase;
  _irnumobs + 1;
  drop _ir:;
run;
data 
 _irfsnotinb    (keep = format start end _flabel _flabellong)
 _irfsnotinc    (keep = format format_comp format_base start end flabel
                 flabellong)
 _irvalues_list_parent
                (keep = format_base format_comp start end attribute base comp
                 source)
 _irfdiff       (keep = format format_base format_comp)
;
  file print;
  if eof & err_flag_all = 0 & _n_ > 1 then do;
    _irnumber = _n_ - 1;
    %ut_errmsg(msg=//// @10 "All " _irnumber 
     " compared values compared equal" ////,type=note,macroname=mdcompare,
     fileback=print)
  end;
  merge _irvalsb (in=frombase)
        _irvalsc (in=fromcomp rename = (flabel=_flabel flabellong=_flabellong))
  end=eof;
  by format start end;
  length attribute $ 32 base comp $ 400;
  length source $ 15;
  source = ' ';
  errflag = 0;
  if _n_ = 1 then err_flag_all = 0;
  if first.format then _ir_err_flag_f = 0;
  if  ^ frombase then output _irfsnotinb;
  else if  ^ fromcomp then output _irfsnotinc;
  if frombase & fromcomp;
  if flabel ^= _flabel then do;
    attribute = "flabel";
    base = flabel;
    comp = _flabel;
    link headerline;
  end;
  if flabellong ^= _flabellong then do;
    attribute = "flabellong";
    base = flabellong;
    comp = _flabellong;
    link headerline;
  end;
  if errflag = 1 then do;
    err_flag_all = 1;
    _ir_err_flag_f = 1;
  end;
  else do;
    attribute = 'same';
    base = ' ';
    comp = ' ';
    output _irvalues_list_parent;
  end;
  if last.format & _ir_err_flag_f = 1 then output _irfdiff;
  return;
    headerline:
    if ^ errflag then do;
      %if &print %then %do;
        put &ls*'-' / 'Format: ' format  'Start: ' start;
      %end;
      errflag = 1;
    end;
    if format ^= format_base & format_base ^= ' ' then
     put 'Base format name:' format_base;
    put;
    %if &print %then %do;
      %ut_errmsg(msg='Value ' attribute +(-1) 's do not match ' /
       @4 "&base: " base / @4 "&compare: " comp /,type=note,macroname=mdcompare,
       max=,log=0)
    %end;
    output _irvalues_list_parent;
  return;
  retain err_flag_all;
  drop _ir:;
run;
title%eval(&titlstrt + 3);
%if %bquote(&outlib) ^= %then %do;
  data _irvalues_list  _irvalues_different (keep=format_base format_comp);
    length project $ 20  run_time 8;
    format run_time datetime15.;
    project = "&project";
    run_time = &run_time;
    set _irvalues_list_parent (in=inboth)
     %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTCOMP %then %do;
       _irfsnotinb (in=fsnotinb keep=format start end)
       _irfnotinb (in=fnotinb  keep=format)
     %end;
     %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTBASE %then %do;
       _irfsnotinc (in=fsnotinc keep=format format_base format_comp start end)
       _irfnotinc (in=fnotinc  keep=format)
     %end;
    ;
    if inboth & source = ' ' then source = 'both';
    %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTCOMP %then %do;
      if fsnotinb then do;
        attribute = 'non-corresponding';
        if source = ' ' then source = 'comp           ';

        if format_comp = ' ' then format_comp = format;

      end;
      if fnotinb then do;
        attribute = 'nocompare';
        if source = ' ' then source = 'comp           ';
        format_comp = format;
      end;
    %end;
    %if %bquote(&mode) = LISTALL | %bquote(&mode) = LISTBASE %then %do;
      if fsnotinc then do;
        attribute = 'non-corresponding';
        if source = ' ' then source = 'base           ';
      end;
      if fnotinc then do;
        attribute = 'nocompare';
        if source = ' ' then source = 'base           ';
        format_base = format;
        format_comp = ' ';
      end;
    %end;
    output _irvalues_list;
    if attribute in ('nocompare' 'non-correspoding') then
     output _irvalues_different;
    %if ^ &debug %then %do;
      drop format;
    %end;
    drop format;
  run;
  proc sort data = _irvalues_list    out = &outlib..&outprefix.values_list
   (label="Compare &baselib..&mdprefixb.values to &complib..&mdprefixc.values")
  ;
    by format_comp format_base start attribute;
  run;
  data _irvalues_different;
    set _irvalues_different;
    if format_base ^= ' ' then do;
      format = format_base;
      output;
    end;
    if format_comp ^= format_base & format_comp ^= ' ' then do;
      format = format_comp;
      output;
    end;
    keep format;
  run;
  proc sort data = _irvalues_different  nodupkey;
    by format;
  run;
  proc sort data = _ircolumns_list;
    by cformat;
  run;
  data _ircolumns_list;
    merge _ircolumns_list (in=list)
          _irvalues_different (in=diff rename=(format=cformat));
    by cformat;
    if list;
    if diff then values_different = 'y';
    else if cformat ^= ' ' then values_different = 'n';
  run;
  proc sort data = _ircolumns_list  out = &outlib..&outprefix.columns_list (
   label="Compare &baselib..&mdprefixb.columns to &complib..&mdprefixc.columns")
  ;
    by table column attribute;
  run;
  %if &compall %then %do;
    proc sort data = _ircolumns_param_list;
      by pformat;
    run;
    data _ircolumns_param_list;
      merge _ircolumns_param_list (in=list)
            _irvalues_different (in=diff rename=(format=pformat));
      by pformat;
      if list;
      if diff then values_different = 'y';
      else if pformat ^= ' ' then values_different = 'n';
    run;
    proc sort data = _ircolumns_param_list
     out = &outlib..&outprefix.columns_param_list (label="Compare "
      "&baselib..&mdprefixb.columns_param to &complib..&mdprefixc.columns_param")
    ;
      by table column param paramrel attribute;
    run;
  %end;
%end;
%if &print & (&mode = LISTALL | &mode = LISTCOMP) %then %do;
  *----------------------------------------------------------------------------;
  * List start values not in base;
  *----------------------------------------------------------------------------;
  proc sort data = _irfsnotinb;
    by format start;
  run;
  proc print data = _irfsnotinb  width=minimum;
    by format;
    title%eval(&titlstrt + 3)
     "(mdcompare) Format Start Values found in &compare but not &base";
    label format=' ';
  run;
  title%eval(&titlstrt + 3);
%end;
%if &print & (&mode = LISTALL | &mode = LISTBASE) %then %do;
  *----------------------------------------------------------------------------;
  * List start values not in compare;
  *----------------------------------------------------------------------------;
  proc sort data = _irfsnotinc;
    by format format_base start;
  run;
  proc print data = _irfsnotinc  width=minimum;
    by format format_base;
    title%eval(&titlstrt + 3)
     "(mdcompare) Format Start Values found in &base but not &compare";
    label format=' ' format_base=' ';
  run;
  title%eval(&titlstrt + 3);
%end;
%if &checkcat %then %do;
  *============================================================================;
  * Compare catalog entries containing derivation logic;
  *============================================================================;
  %if ^ &print %then %let printdif = 0;
  %ut_entrycomp(cat1=work._irbdescriptions,cat2=work._ircdescriptions,
   printdif=&printdif,cat1label=&baselib..&mdprefixb.descriptions,
   cat2label=&complib..&mdprefixc.descriptions,mode=&mode,out=_irentrycomp,
   verbose=&verbose,debug=&debug);
  %if %bquote(&outlib) ^= %then %do;
    data &outlib..&outprefix.descriptions_list;
      length project $ 20  run_time 8;
      format run_time datetime15.;
      project = "&project";
      run_time = &run_time;
      set _irentrycomp;
    run;
  %end;
%end;
*==============================================================================;
* Clean up at end of mdcompare macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _ir:;
    delete _ir: / memtype=catalog;
  run; quit;
%end;
%else %put (mdcompare) macro ending;
title&titlstrt;
%mend;
