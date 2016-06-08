%macro mdadstandard(inlib=_default_,outlib=_default_,inprefix=_default_,
 outprefix=_default_,select=_default_,exclude=_default_,observat=_default_,
 xxdata=_default_,xxdatavals=_default_,xxvars=_default_,xxvarsvals=_default_,
 template=_default_,tprefix=_default_,contents=_default_,
 verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdadstandard
TYPE                     : metadata
DESCRIPTION              : Processes metadata content for the special case of
                            metadata that contains the ADS standard.
                            Makes copies of templates defined in the ADS
                            standard - OBSERVAT data set, XX data sets and 
                            XX variables.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                           Broad_use_modules\SAS\mdadstandard\
                           mdadstandard DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS
BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt ut_errmsg ut_marray
                            mdmake
INPUT                    : metadata residing in a library specified by the INLIB
                            parameter
OUTPUT                   : metadata written to the library specified by the
                            OUTLIB parameter
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _as
--------------------------------------------------------------------------------
Parameters:
 Name     Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
INLIB      required          The input libref where the metadata sets reside
OUTLIB     required work     The output libref where the metadata is written
                              by this macro after revisions are made
INPREFIX   optional          A prefix of the metadata set names in INLIB
OUTPREFIX  optional          A prefix to be added to the metadata set names
                              in OUTLIB
SELECT     optional          A blank delimited list of data set names define
                              in the INLIB metadata to limit processing to
EXCLUDE    optional          A blank delimited list of data set names defined
                              in the INLIB metadata to exclude from
                              processing
TEMPLATE   optional observat The name of the template data set that will be
                              processed according to the OBSERVAT parameter.
                              Only one template can be specified for each
                              call to the mdadstandard macro.
TPREFIX    optional obs      Template prefix - the prefix used for variable
                              names in the TEMPLATE data set that will be 
                              changed to the new prefix defined in the 
                              OBSERVAT parameter.
OBSERVAT   optional          A blank delimited list of pairs of data set 
                              name and variable prefix.  A copy of the 
                              definition of the OBSERVAT data set residing
                              in the INLIB metadata will be made.  The copy
                              will have the TABLE variable in the metadata
                              reassigned to the value of the data set name
                              in the OBSERVAT parameter.  Any COLUMN values
                              in the copy that begin with "OBS" will have
                              the "OBS" replaced with the prefix defined
                              in the OBSERVAT parameter.  Specify a prefix
                              of _null_ in the observat parameter to indicate
                              that "OBS" should be replaced with the null
                              character - i.e. "OBS" will be trimmed off.
XXDATA     required _none_   Defines whether and how to create copies of 
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
XXDATAVALS optional          This parameter is used only when XXDATA is 
                              _any_.  
XXVARS     required _none_   Works like XXDATA parameter but for variable
                              names instead of data set names.
                             Defines whether and how to create copies of 
                              variables whose names end with "XX" that are
                              defined in the INLIB metadata.  The variables
                              whose names end in "XX" are template
                              variable definitions that should be copied
                              for each study phase.
                             _none_ : do not create copies of variable
                              definitions whose names end in "XX"
                             _any_ : create copies of variable definitions
                              and replace the "XX" with a suffix defined in
                              the XXVARSVALS parameter
                             otherwise : other values of XXVARS are assumed
                              to be a blank delimited list of suffixes 
                              Each copy of an XX variable will be renamed 
                              using these suffixes.  The "XX" will be
                              replaced by a suffix in the XXVARS parameter.
                              A copy of the XX variable definition is made
                              for each XXVARS suffix defined.  The suffix
                              of _null_ will make a copy and replace "XX"
                              with the null character (i.e. no suffix).
XXVARSVALS optional          This parameter is used only when XXVARS is _any_.
                              This defines the name of a data set that includes
                              the variables TABLE and COLUMN.  The COLUMN
                              values define the actually used suffixes of the
                              XX variables in INLIB metadata.  This data set
                              is typically the COLUMNS metadata set.
CONTENTS   required 0        %ut_logical value specifying whether a PROC 
                              CONTENTS shall be run on the output metadata
                              sets.
VERBOSE    required 1        %ut_logical value specifying whether verbose
                              mode is on or off
DEBUG      required 0        %ut_logical value specfifying whether debug
                              mode is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

  The mdadstandard macro does special processing of metadata that hold the 
  Lilly ADS standard.  This standard includes a template data set named
  "observat", template data set names whose names end in XX and template
  variables whose names end in XX.  The mdadstandard macro creates copies of
  these templates and names these copies as specified with the parameters of
  the macro.  The OBSERVAT data set template was created to hold efficacy
  data and contains variables whose names begin with "obs".  Parameters of 
  this macro allow specification of the prefix(es) that replace "obs" and the
  name of the data set copy of observat.  The XX data sets and variables are
  meant to hold information for treatment phases of a study.  There are as 
  many of these variables as you need for your study.  Parameters allow
  specification of the substitute suffixes of these data set and variable
  names.

  mdadstandard is optionally called by mdcompare, when comparing a study 
  ADS requirement to the ADS standard.  Another use of mdadstandard is 
  to make a copy of the observat template definition in metadata so a 
  new efficacy ADS standard can be created.  A user can call mdadstandard
  to SELECT the observat data set and use the OBSERVAT parameter to rename
  the data set and OBS variables.  This is a good starting point for defining
  a new ADS standard.
--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

  INLIB contains metadata holding standards or requirements that conform
  to the ADS standard template naming conventions.

  Supplied prefixes and suffixes will not cause the names to exceed their
  maximum length.
--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

  libname md  '<location of the library that contains the input metadata>';
  libname out '<location of the library that contains the output metadata>';

  %mdadstandard(inlib=md,outlib=out,observat=efficacy eff,select=observat)

    Makes a copy of the observat template named "efficacy" and renames
    all variables whose name begin with "obs" to start with "eff" instead.
    This is the most common way mdadstandard is called by users.  The other
    parameters are typically used by other macros that call mdadstandard, 
    such as the mdcheck macro.


  %mdadstandard(inlib=md,outlib=work,
   observat=obsrepli parm,
   xxvars=vp1 vp2 vp3,
   xxdata=dp1 dp2 dp3)

    This call makes a copy of the observat template named obsrepli, replacing
    "obs" at the start of variable names with "parm".
    Three copies of each variable name whose name ends in "XX" are created,
    replacing "XX" with "VP1" in the first variable copy, "VP2" in the
    second variable copy and "VP3" in the third varaible copy.
    Three copies of each data set whose name ends in "XX" are created,
    replacing "XX" with "DP1" in the first data set copy, with "DP2" in the
    second data set copy and "DP3" in the third data set copy.
   

  %mdadstandard(inlib=md,outlib=out,
   observat=obsrepli1 parm obsrepli2 _null_,
   xxvars=_any_,xxvarsvals=md.cvals,
   xxdata=_any_,xxdatavals=md.tvals)

    This call creates two observat copies.
    Copies of each variable whose name ends in "XX" are made.  The number of
    copies depends on the number of suffixes found in the md.cvals data set.
    Copies of each data set whose name ends in "XX" are made.  The number of
    copies depends on the number of suffixes found in the md.tvals data set.
--------------------------------------------------------------------------------
      Author &
Ver#  Peer Reviewer    Request #        Broad-Use MODULE History Description
----  ---------------- ---------------- ----------------------------------------
1.0   Gregory Steffens BMRGCS11Jul2005A Original version of the broad-use module
       Sheetal Lal                       11/Jul/2005
1.1   Gregory Steffens BMRMSR19FEB2007A SAS version 9 migration 06Mar2007
       Michael Fredericksen
2.0   Gregory Steffens                  Added TEMPLATE and TPREFIX parameters
  **eoh************************************************************************/
%ut_parmdef(inlib,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_parmdef(outlib,work,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_parmdef(inprefix,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(outprefix,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(select,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(exclude,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(template,observat,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(tprefix,obs,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(observat,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(xxdata,_none_,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_parmdef(xxdatavals,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(xxvars,_none_,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_parmdef(xxvarsvals,_pdmacroname=mdadstandard,_pdrequired=0)
%ut_parmdef(contents,0,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=mdadstandard,_pdrequired=1)
%ut_logical(contents)
%ut_logical(verbose)
%ut_logical(debug)
%if %bquote(&&xxdata) = %then %do;
  %ut_errmsg(msg="xxdata parameter invalid - setting xxdata to _none_ " 
   "Specify _null_ if no suffix is requested",
   macroname=mdadstandard,print=0,type=note)
  %let xxdata = _none_;
%end;
%if %bquote(&&xxvars) = %then %do;
  %ut_errmsg(msg="xxvars parameter invalid - setting xxvars to _none_ "
   "Specify _null_ if no suffix is requested",
   macroname=mdadstandard,print=0,type=note)
  %let xxvars = _none_;
%end;
%local titlstrt mksource mksource_table mksource_column;
%ut_titlstrt
title&titlstrt "(mdadstandard) Processing metadata from &inlib";
%let mksource = 0;
%let mksource_table = 0;
%let mksource_column = 0;
%if &debug %then %do;
  proc print data = &inlib..&inprefix.tables  width=minimum n;
    title%eval(&titlstrt + 1)
     "(mdadstandard debug) INLIB: &inlib..&inprefix.tables";
  run;
  proc print data = &inlib..&inprefix.columns  width=minimum n;
    title%eval(&titlstrt + 1)
     "(mdadstandard debug) INLIB: &inlib..&inprefix.columns";
  run;
  proc print data = &inlib..&inprefix.columns_param  width=minimum n;
    title%eval(&titlstrt + 1)
     "(mdadstandard debug) INLIB: &inlib..&inprefix.columns_param";
  run;
  title%eval(&titlstrt + 1);
%end;
%if %bquote(&observat) ^= %then %do;
  %local numovtabs ovtabnum numovpairs observat_list numovtabs_revised
   ovtabnum_revised;
  *============================================================================;
  * Process the OBSERVAT parameter to generate data set definitions from;
  *  the INLIB metadata definition of the OBSERVAT data set;
  *============================================================================;
  %*---------------------------------------------------------------------------;
  %* Create an array of OBSERVAT table names (ovt) and a parallel array of;
  %*  prefixes (ovp) as defined by the OBSERVAT macro parameter;
  %*---------------------------------------------------------------------------;
  %ut_marray(invar=observat,outvar=ov,outnum=numovpairs,varlist=observat_list)
  %local &observat_list;
  %ut_marray(invar=observat,outvar=ov,outnum=numovpairs)
  %let numovtabs = 0;
  %do ovtabnum = 1 %to &numovpairs;
    %let numovtabs = %eval(&numovtabs + 1);
    %local ovt&numovtabs ovp&numovtabs;
    %let ovt&numovtabs = &&ov&ovtabnum;
    %* was an ovt requested twice by mistake? - if so set to null;
    %if &numovtabs > 1 %then %do i = %eval(&numovtabs - 1) %to 1 %by -1;
      %if &&ovt&numovtabs = &&ovt&i %then %do;
        %ut_errmsg(msg=Replica data set specified twice (&&ovt&numovtabs),
         type=note,macroname=mdadstandard,print=0)
        %let ovt&numovtabs =;
      %end;
    %end;
    %let ovtabnum = %eval(&ovtabnum + 1);
    %if &ovtabnum <= &numovpairs %then %do;
      %if %bquote(%upcase(&&ov&ovtabnum)) ^= _NULL_ %then
       %let ovp&numovtabs = &&ov&ovtabnum;
      %else %let ovp&numovtabs =;
    %end;
    %else %do;
      %let ovp&numovtabs =;
      %ut_errmsg(msg="OBSERVAT parameter has an odd number of values - it "
       "must have pairs of values: table name followed by prefix "
       "numovpairs=&numovpairs observat=&observat",
       macroname=mdadstandard,type=error)
    %end;
  %end;
  %if &verbose %then %do ovtabnum = 1 %to &numovtabs;
    %put ovt&ovtabnum=&&ovt&ovtabnum    ovp&ovtabnum=&&ovp&ovtabnum;
  %end;
  *----------------------------------------------------------------------------;
  * Read the non-observat data set definitions from the INLIB metadata;
  *  using the _asout prefix;
  *----------------------------------------------------------------------------;
  %mdmake(inlib=&inlib,outlib=work,inprefix=&inprefix,outprefix=_asout,
   inselect=&select,inexclude=&exclude &template,mode=replace,contents=0,
   verbose=&verbose,debug=&debug)
  *----------------------------------------------------------------------------;
  * See if observat replicate data set definition exists in INLIB metadata;
  * already and if so delete it from the observat parameter and call ut_errmsg;
  *----------------------------------------------------------------------------;
  %if &numovtabs > 0 %then %do;
    data _null_;
      set _asouttables
       (keep=table  where = (upcase(table) in (
       %do ovtabnum = 1 %to &numovtabs;
         %if %bquote(&&ovt&ovtabnum) ^= %then %do;
           "%upcase(&&ovt&ovtabnum)"
         %end;
       %end;
       )))
      ;
      %do ovtabnum = 1 %to &numovtabs;
        %if %bquote(&&ovt&ovtabnum) ^= %then %do;
          if upcase(table) = "%upcase(&&ovt&ovtabnum)" then do;
            %ut_errmsg(msg="OBSERVAT parameter specified a data set name that "
             "already exists in your metadata - deleting &&ovt&ovtabnum from "
             "parameter",macroname=mdadstandard,type=warning)
            call symput("ovt&ovtabnum",'');
            call symput("ovp&ovtabnum",'');
          end;
        %end;
      %end;
    run;
  %end;
  %*---------------------------------------------------------------------------;
  %* Redefine ovt (tables) and ovp (prefixes) macro arrays;
  %*  shift non-null array elements to the left;
  %*  and reassign numovtabs to the number of non-null ovt table elements;
  %*---------------------------------------------------------------------------;
  %let numovtabs_revised = 0;
  %do ovtabnum = 1 %to &numovtabs;
    %if %bquote(&&ovt&ovtabnum) ^= %then
     %let numovtabs_revised = %eval(&numovtabs_revised + 1);
    %else %do ovtabnum_revised = %eval(&ovtabnum + 1) %to &numovtabs;
      %if %bquote(&&ovt&ovtabnum_revised) ^= %then %do;
        %local ovt&ovtabnum;
        %let ovt&ovtabnum = &&ovt&ovtabnum_revised;
        %let ovp&ovtabnum = &&ovp&ovtabnum_revised;
        %let ovt&ovtabnum_revised =;
        %let ovp&ovtabnum_revised =;
        %let ovtabnum_revised = &ovtabnum;
        %let numovtabs_revised = %eval(&numovtabs_revised + 1);
      %end;
    %end;
  %end;
  %if &numovtabs ^= &numovtabs_revised %then %do;
    %put numovtabs=&numovtabs    numovtabs_revised=&numovtabs_revised;
    %do ovtabnum = 1 %to &numovtabs;
      %put ovt&ovtabnum=&&ovt&ovtabnum    ovp&ovtabnum=&&ovp&ovtabnum;
    %end;
    %let numovtabs = &numovtabs_revised;
  %end;
  %if &numovtabs_revised > 0 %then %do;
    *--------------------------------------------------------------------------;
    * Select the observat definition from the metadata;
    *  and create the table definitions specified in the OBSERVAT parameter;
    *  using the _aso prefix for the observat-only copy of the metadata;
    *--------------------------------------------------------------------------;
    %mdmake(inlib=&inlib,outlib=work,inprefix=&inprefix,outprefix=_aso,
     inselect=&template,mode=replace,contents=0,verbose=&verbose,debug=&debug)
    *--------------------------------------------------------------------------;
    * Create the _asov prefix from _aso to contain the observat replicates and;
    *  the SOURCE variable;
    *--------------------------------------------------------------------------;
    data _asovtables;
      length source $ 15;
      source = "OBSERVAT";
      if eof & _n_ = 1 then do;
        %ut_errmsg(msg="&template template definition was not found in &INLIB",
         type=warning,macroname=mdadstandard)
        link make_observat;
      end;
      set _asotables end=eof;
      link make_observat;
      return;
      make_observat:
      %if &numovtabs > 0 %then %do ovtabnum = 1 %to &numovtabs;
        %if %bquote(&&ovt&ovtabnum) ^= %then %do;
          table = "%upcase(&&ovt&ovtabnum)";
          output;
        %end;
      %end;
      return;
    run;
    proc sort data = _asovtables;
      by table;
    run;

    data _asovcolumns (drop=column  rename=(newcolumn=column));
      set _asocolumns;
      length newcolumn $ 32  source $ 15;
      source = ' ';
      %if &numovtabs > 0 %then %do ovtabnum = 1 %to &numovtabs;
        %if %bquote(&&ovt&ovtabnum) ^= %then %do;
          table = "%upcase(&&ovt&ovtabnum)";
          if upcase(column) =: "%upcase(&tprefix)" then do;
            if cdescription = ' ' & cexist('work._asodescriptions.' ||
             trim(left(column)) || '.source') then cdescription = column;
            newcolumn = left("%upcase(&&ovp&ovtabnum)" ||
             trim(left(substr(upcase(column),length("&tprefix") + 1))));
            source = 'OBSERVATOBS';
          end;
          else do;
            newcolumn = column;
            source = 'OBSERVATNOOBS';
          end;
          output;
        %end;
      %end;
    run;
    proc sort data = _asovcolumns;
      by table column;
    run;
    data _asovcolumns_param (drop=column  rename=(newcolumn=column));
      set _asocolumns_param;
      length newcolumn $ 32  source $ 15;
      source = ' ';
      %if &numovtabs > 0 %then %do ovtabnum = 1 %to &numovtabs;
        %if %bquote(&&ovt&ovtabnum) ^= %then %do;
          table = "%upcase(&&ovt&ovtabnum)";
          if upcase(column) =: "%upcase(&tprefix)" then do;
            newcolumn = left("%upcase(&&ovp&ovtabnum)" ||
             trim(left(substr(upcase(column),length("&tprefix") + 1)));
            source = 'OBSERVATOBS  ';
          end;
          else do;
            newcolumn = column;
            source = 'OBSERVATNOOBS';
          end;
          output;
        %end;
      %end;
    run;

    proc sort data = _asovcolumns_param;
      by table column param paramrel;
    run;
    proc datasets lib=work nolist;
      change _asovalues = _asovvalues;
      change _asodescriptions = _asovdescriptions;
    run; quit;
    *--------------------------------------------------------------------------;
    * Call mdmake to merge the _asov and _asout metadata to re-create the;
    *  _asout metadata;
    *--------------------------------------------------------------------------;
    %mdmake(inlib=work,outlib=work,inprefix=_asov,outprefix=_asout,
     contents=0,mode=merge,verbose=&verbose,debug=&debug)
    *--------------------------------------------------------------------------;
    * Merge _asout with _asov to add the SOURCE variable to _asout metadata;
    * sets since mdmake drops non-standard metavariables;
    *--------------------------------------------------------------------------;
    data _asouttables;
      merge _asouttables (in=fromout)
            _asovtables (in=fromov keep=table source);
      by table;
      if fromout;
    run;
    data _asoutcolumns;
      merge _asoutcolumns (in=fromout)
            _asovcolumns (in=fromov keep=table column source);
      by table column;
      if fromout;
    run;
    data _asoutcolumns_param;
      merge
       _asoutcolumns_param (in=fromout)
       _asovcolumns_param (in=fromov keep=table column param paramrel source);
      by table column param paramrel;
      if fromout;
    run;
    %let mksource = 1;
  %end;    /* numovtabs_revised > 0 */
  %else %do;
    %ut_errmsg(msg="No &template replicates will be created since they all "
     "already exist in &inlib",type=warning,macroname=mdadstandard)
  %end;
%end;
%else %do;
  *============================================================================;
  * Call mdmake to copy metadata from INLIB to WORK with _asout prefix;
  *  since the OBSERVAT parameter was not specified;
  *============================================================================;
  %mdmake(inlib=&inlib,outlib=work,inprefix=&inprefix,outprefix=_asout,
   inselect=&select,inexclude=&exclude,contents=0,mode=replace,
   verbose=&verbose,debug=&debug)
%end;
%if &debug %then %do;
  proc print data = _asouttables  width=minimum;
    title%eval(&titlstrt + 1)
     '(mdadstandard debug) _asouttables after observat loop';
  run;
  proc print data = _asoutcolumns  width=minimum;
    title%eval(&titlstrt + 1)
     '(mdadstandard debug) _asoutcolumns after observat loop';
  run;
  proc print data = _asoutcolumns_param  width=minimum;
    title%eval(&titlstrt + 1)
     '(mdadstandard debug) _asoutcolumns_param after observat loop';
  run;
  title%eval(&titlstrt + 1);
%end;
%if %bquote(&xxdata) ^= & %bquote(%upcase(&xxdata)) ^= _NONE_ %then %do;
  *============================================================================;
  * Process the XXDATA parameter to create copies of data set names that end;
  *  with XX.  These data sets should be replicated for each study phase;
  *============================================================================;
  %let mksource = 1;
  %let mksource_table = 1;
  %if %bquote(%upcase(&xxdata)) = _ANY_ %then %do;
    %if %bquote(&xxdatavals) ^= & %sysfunc(exist(&xxdatavals)) %then %do;
      *------------------------------------------------------------------------;
      * Process XX data set names to allow any suffix in reference metadata set;
      *------------------------------------------------------------------------;
      data _asdatavals;
        set &&xxdatavals (keep = table  where = (table ^= ' '));
        table = upcase(left(table));
      run;
      proc sort data = _asdatavals  nodupkey;
        by table;
      run;
      data _asdataxx;
        set _asouttables
         (where = (substr(table,max(length(table)-1,1)) = 'XX'));
      run;
      proc sql;
        create table _asdataxx
         as select x.* , v.table as table_compare
         from _asdataxx as x left join _asdatavals as v
         on upcase(v.table) like
          (trim(substr(upcase(x.table),1,max(length(x.table)-2,1))) || '%')
        ;
      quit;
      %if &debug %then %do;
        proc print data = _asdatavals width=minimum;
          var table;
          title%eval(&titlstrt + 1)
           "(mdadstandard) xxdatavals data set (&xxdatavals)";
        run;
        proc print data = _asdataxx width=minimum;
          title%eval(&titlstrt + 1) "(mdadstandard) _asdataxx data set I";
        run;
        title%eval(&titlstrt + 1);
      %end;
      data _asdataxx (drop=stem suffix)
           _asxxdatamap (keep=source table stem suffix source_table
                        rename=(table=target));
        set _asdataxx;
        length stem suffix source_table $ 32  source $ 15;
        source = 'XXDATA';
        source_table = table;
        if upcase(table) ^= 'XX' then do;
          stem = substr(table,1,length(table)-2);
          if length(table_compare) > length(stem) & table_compare ^= ' ' then
           suffix = substr(table_compare,length(stem)+1);
          else suffix = ' ';
        end;
        else do;
          stem = ' ';
          suffix = ' ';
        end;
        if table ^= 'XX' & table_compare ^= ' ' &
         length(stem) + length(suffix) <= vlength(table) then
         table = upcase(trim(left(stem)) || trim(left(suffix)));
        if suffix ^= ' ' then do;
          if tlabel ^= ' ' & index(upcase(tlabel),'XX') > 0 &
           0 < ((length(tlabel) - 2) + length(suffix)) <= vlength(tlabel) then
           do;
            tlabel = tranwrd(tlabel,'XX',trim(suffix));
            tlabel = tranwrd(tlabel,'xx',trim(suffix));
          end;
        end;
        drop table_compare;
      run;
    %end;    /* xxdatavals loop */
    %else %do;
      %ut_errmsg(msg="The XXDATA parameter = &xxdata but the XXDATAVALS "
       "parameter is not specified or specified data set does not exist "
       "xxdatavals=&xxdatavals",macroname=mdadstandard,type=error)
      data _asdataxx;
        stop;
        set _asouttables;
      run;
      data _asxxdatamap;
        length source_table target stem suffix $ 32  source $ 15;
        source_table = ' ';
        target = ' ';
        stem = ' ';
        suffix = ' ';
        source = ' ';
        stop;
      run;
    %end;
  %end;    /* _any_ loop */
  %else %if %bquote(&xxdata) ^= %then %do;
    *--------------------------------------------------------------------------;
    * Process XX tables to allow suffixes specified in XXDATA parameter;
    *--------------------------------------------------------------------------;
    data _asdataxx (drop=table tlabel rename=(newtable=table newtlabel=tlabel))
         _asxxdatamap (keep=source_table newtable source
                      rename=(newtable=target));
      set _asouttables
       (where = (substr(upcase(table),max(length(table)-1,1)) = 'XX'));
      length source_table newtable _asnext $ 32  source $ 15;
      _assuffixes = "&xxdata";
      source = 'XXDATA';
      source_table = table;
      _asi = 1;
      do until (_asnext = ' ');
        _asnext = scan(_assuffixes,_asi,' ');
        newtable = ' ';
        if _asnext ^= ' ' then do;
          if upcase(_asnext) = '_NULL_' then do;
            if upcase(table) = 'XX' then newtable = 'XX';
            else newtable = substr(table,1,length(table)-2);
          end;
          else if 0 <= ((length(table) - 2) + length(_asnext)) <= vlength(table)
           then do;
            if upcase(table) = 'XX' then newtable = trim(left(upcase(_asnext)));
            else newtable = trim(substr(table,1,length(table)-2)) ||
             trim(left(upcase(_asnext)));
          end;
          else newtable = table;
          if tlabel ^= ' ' & index(upcase(tlabel),'XX') > 0 &
           0 < ((length(tlabel) - 2) + length(_asnext)) <= vlength(tlabel) &
           upcase(_asnext) ^= '_NULL_' then do;
            newtlabel = tranwrd(tlabel,'XX',trim(_asnext));
            newtlabel = tranwrd(newtlabel,'xx',trim(_asnext));
          end;
          else newtlabel = tlabel;
          output;
        end;
        _asi + 1;
      end;
      drop _as:;
    run;
  %end;    /* xxdata suffixes loop */
  proc sort data = _asdataxx;
    by table;
  run;
  data _asouttables;
    set _asouttables
        (where = (substr(upcase(table),max(length(table)-1,1)) ^= 'XX'))
        _asdataxx;
  run;
  proc sort data = _asouttables;
    by table;
  run;
  data _asoutcolumns (drop=table rename=(table_new=table));
    set _asoutcolumns;
    if substr(upcase(table),length(table)-1) = 'XX' & nobs > 0 then
     do mapobs = 1 to nobs;
      set _asxxdatamap (keep=source_table target) point=mapobs  nobs=nobs;
      if table = source_table then do;
        table_new = target;
        output;
      end;
      else table_new = table;
    end;
    else do;
      table_new = table;
      output;
    end;
    drop target;
  run;
  proc sort data = _asoutcolumns;
    by table column;
  run;
  data _asoutcolumns_param (drop=table rename=(table_new=table));
    set _asoutcolumns_param;
    if substr(upcase(table),max(length(table)-1,1)) = 'XX' & nobs > 0 then
     do mapobs = 1 to nobs;
      set _asxxdatamap (keep=source_table target)  point=mapobs  nobs=nobs;
      if upcase(table) = upcase(source_table) then do;
        table_new = target;
        output;
      end;
      else table_new = table;
    end;
    else do;
      table_new = table;
      output;
    end;
    drop target;
  run;
  proc sort data = _asoutcolumns_param;
    by table column param paramrel;
  run;
  %if &debug %then %do;
    proc print data = _asdataxx width=minimum;
      title%eval(&titlstrt + 1)
       "(mdadstandard debug) _asdataxx data set II in xxdata loop";
    run;
    proc print data = _asxxdatamap width=minimum;
      title%eval(&titlstrt + 1)
       "(mdadstandard debug) _asxxdatamap data set in xxdata loop";
    run;
    proc print data = _asouttables  width=minimum;
      title%eval(&titlstrt + 1)
       '(mdadstandard debug) _asouttables in xxdata loop';
    run;
    proc print data = _asoutcolumns  width=minimum;
      by table;
      title%eval(&titlstrt + 1)
       '(mdadstandard debug) _asoutcolumns in xxdata loop';
    run;
    proc print data = _asoutcolumns_param  width=minimum;
      by table column;
      title%eval(&titlstrt + 1)
       '(mdadstandard) _asoutcolumns_param in xxdata loop';
    run;
    title%eval(&titlstrt + 1);
  %end;
%end;    /* xxdata not _none_ or is null loop */
%if %bquote(&xxvars) ^= & %bquote(%upcase(&xxvars)) ^= _NONE_ %then %do;
  *============================================================================;
  * Process the XXVARS parameter to create copies of variable names that end;
  *  with XX.  These variables should be replicated for each study phase;
  *============================================================================;
  %let mksource = 1;
  %let mksource_table = 1;
  %let mksource_column = 1;
  %if %bquote(%upcase(&xxvars)) = _ANY_ %then %do;
    %if %bquote(&xxvarsvals) ^= & %sysfunc(exist(&xxvarsvals)) %then %do;
      *------------------------------------------------------------------------;
      * Process XX variables to allow any suffix in reference metadata set;
      *------------------------------------------------------------------------;
      data _asvarsvals;
        set &&xxvarsvals (keep = table column
         where = (table ^= ' ' & column ^= ' '));
        table = upcase(table);
        column = upcase(column);
      run;
      proc sort data = _asvarsvals  nodupkey;
        by table column;
      run;
      data _asvarsxx;
        set _asoutcolumns
         (where = (substr(column,max(length(column)-1,1)) = 'XX'));
      run;
      proc sql;
        create table _asvarsxx
         as select b.* , c.column as column_compare
         from _asvarsxx as b left join _asvarsvals as c
         on upcase(b.table) = upcase(c.table) &
          upcase(c.column) like
          (trim(substr(upcase(b.column),1,max(length(b.column)-2,1))) || '%')
        ;
      quit;
      %if &debug %then %do;
        proc print data = _asvarsvals width=minimum;
          var table column;
          title%eval(&titlstrt + 1)
           "(mdadstandard) xxvarsvals data set (&xxvarsvals)";
        run;
        proc print data = _asvarsxx width=minimum;
          title%eval(&titlstrt + 1) "(mdadstandard) _asvarsxx data set I";
        run;
        title%eval(&titlstrt + 1);
      %end;
      data _asvarsxx (drop=stem suffix)
           _asxxvarsmap (keep=table column stem suffix source_table
                         source_column source);
        set _asvarsxx;
        length stem suffix source_table source_column $ 32  source $ 15;
        source = 'XXVARS';
        source_table = table;
        source_column = column;
        if upcase(column) ^= 'XX' then do;
          stem = substr(column,1,length(column)-2);
          if length(column_compare) > length(stem) & column_compare ^= ' ' then
           suffix = substr(column_compare,length(stem)+1);
          else suffix = ' ';
        end;
        else do;
          stem = ' ';
          suffix = ' ';
        end;
        if column ^= 'XX' & length(stem) + length(suffix) <= vlength(column) &
         column_compare ^= ' ' then do;
          if cdescription = ' ' & cexist('work._asoutdescriptions.' ||
           trim(left(column)) || '.source') then cdescription = column;
          column = trim(left(stem)) || trim(left(suffix));
        end;
        if suffix ^= ' ' then do;
          if cshort ^= ' ' & substr(upcase(cshort),max(length(cshort)-1,1)) =
           'XX' &
           0 <= ((length(cshort) - 2) + length(suffix)) <= vlength(cshort)
           then cshort = trim(substr(cshort,1,max(length(cshort)-2,1))) ||
           trim(left(upcase(suffix)));
          if clabel ^= ' ' & index(upcase(clabel),'XX') > 0 &
           0 <= ((length(clabel) - 2) + length(suffix)) <= vlength(clabel) &
           upcase(suffix) ^= '_NULL_' then
           do;
            clabel = tranwrd(clabel,'XX',trim(suffix));
            clabel = tranwrd(clabel,'xx',trim(suffix));
          end;
          if clabellong ^= ' ' &  index(upcase(clabellong),'XX') > 0 &
           0 <= ((length(clabellong) - 2) + length(suffix)) <= vlength(clabellong)
           & upcase(suffix) ^= '_NULL_' then do;
            clabellong = tranwrd(clabellong,'XX',trim(suffix));
            clabellong = tranwrd(clabellong,'xx',trim(suffix));
          end;
        end;
        drop column_compare;
      run;
    %end;    /* xxvarsvals exists */
    %else %do;
      %ut_errmsg(msg="The XXVARS parameter = &xxvars but the XXVARSVALS "
       "parameter is not specified or specified data set does not exist",
       macroname=mdadstandard,type=error)
      data _asvarsxx;
        stop;
        set _asoutcolumns;
      run;
      data _asxxvarsmap;
        stop;
        length table column source_table source_column stem suffix $ 32
         source $ 15;
        table =  ' ';
        column = ' ';
        source_table = ' ';
        source_column = ' ';
        stem = ' ';
        suffix = ' ';
        source = ' ';
      run;
    %end;
  %end;    /* xxvars _any_ loop */
  %else %if %bquote(&xxvars) ^= %then %do;
    *--------------------------------------------------------------------------;
    * Process XX variables to allow suffixes specified in XXVARS parameter;
    *--------------------------------------------------------------------------;
    data _asvarsxx (drop=column clabel clabellong cshort
                   rename=(newcolumn=column newcshort=cshort newclabel=clabel
                   newclabellong=clabellong))
         _asxxvarsmap (keep=table newcolumn source_table source_column source
                       rename=(newcolumn=column));
      set _asoutcolumns
       (where = (substr(column,length(column)-1) = 'XX'));
      length source_column newcolumn _asnext $ 32  newcshort $8  source $ 15;
      _assuffixes = "&xxvars";
      source = 'XXVARS';
      source_table = table;
      source_column = column;
      _asi = 1;
      do until (_asnext = ' ');
        _asnext = scan(_assuffixes,_asi,' ');
        newcolumn = ' ';
        if _asnext ^= ' ' then do;
          if upcase(_asnext) = '_NULL_' then do;
            if upcase(column) = 'XX' then newcolumn = 'XX';
            else newcolumn = substr(column,1,length(column)-2);
            if cdescription = ' ' & cexist('work._asoutdescriptions.' ||
             trim(left(column)) || '.source') then cdescription = column;
          end;
          else if 0 <=((length(column) - 2) + length(_asnext))<= vlength(column)
           then do;
            if upcase(column) = 'XX' then
             newcolumn = trim(left(upcase(_asnext)));
            else newcolumn = trim(substr(column,1,length(column)-2)) ||
             trim(left(upcase(_asnext)));
            if cdescription = ' ' & cexist('work._asoutdescriptions.' ||
             trim(left(column)) || '.source') then cdescription = column;
          end;
          else newcolumn = column;
          if substr(upcase(cshort),max(length(cshort)-1,1)) = 'XX' then
           do;
            if upcase(_asnext) = '_NULL_' then do;
              if upcase(cshort) = 'XX' then newcshort = 'XX';
              else newcshort = substr(cshort,1,max(length(cshort)-2,1));
            end;
            else if
             0 <= ((length(cshort) - 2) + length(_asnext)) <= vlength(cshort)
             then do;
              if upcase(cshort) = 'XX' then
               newcshort = trim(left(upcase(_asnext)));
              else newcshort = trim(substr(cshort,1,length(cshort)-2)) ||
               trim(left(upcase(_asnext)));
            end;
            else newcshort = cshort;
          end;
          else newcshort = cshort;
          if clabel ^= ' ' & index(upcase(clabel),'XX') > 0 &
           ((length(clabel) - 2) + length(_asnext)) <= vlength(clabel) &
           upcase(_asnext) ^= '_NULL_' then do;
            newclabel = tranwrd(clabel,'XX',trim(_asnext));
            newclabel = tranwrd(newclabel,'xx',trim(_asnext));
          end;
          else newclabel = clabel;
          if clabellong ^= ' ' &  index(upcase(clabellong),'XX') > 0 &
           ((length(clabellong) - 2) + length(_asnext)) <= vlength(clabellong)
           & upcase(_asnext) ^= '_NULL_' then do;
            newclabellong = tranwrd(clabellong,'XX',trim(_asnext));
            newclabellong = tranwrd(newclabellong,'xx',trim(_asnext));
          end;
          else newclabellong = clabellong;
          output;
        end;
        _asi + 1;
      end;
      drop _as:;
    run;
  %end;    /* xxvars suffixes loop */
  proc sort data = _asvarsxx;
    by table column;
  run;
  data _asoutcolumns;
    set _asoutcolumns (where =
     (substr(column,length(column)-1) ^= 'XX'))
     _asvarsxx;
  run;
  proc sort data = _asoutcolumns;
    by table column;
  run;
  data _asoutcolumns_param (drop=column rename=(column_new=column));
    set _asoutcolumns_param;
    if substr(column,length(column)-1) = 'XX' & nobs > 0 then
     do mapobs = 1 to nobs;
      set _asxxvarsmap (keep=source source_table source_column column
                       rename=(column=target))
       point=mapobs  nobs=nobs;
      if table = source_table and column = source_column then do;
        column_new = target;
        output;
      end;
      else column_new = column;
    end;
    else do;
      column_new = column;
      output;
    end;
    drop target;
  run;
  %if &debug %then %do;
    proc print data = _asvarsxx width=minimum;
      title%eval(&titlstrt + 1) "(mdadstandard) _asvarsxx data set";
    run;
    proc print data = _asxxvarsmap width=minimum;
      title%eval(&titlstrt + 1) "(mdadstandard) _asxxvarsmap data set";
    run;
    proc print data = _asouttables  width=minimum;
      title%eval(&titlstrt + 1) '(mdadstandard) _asouttables in xxvars loop';
    run;
    proc print data = _asoutcolumns  width=minimum;
      by table;
      title%eval(&titlstrt + 1) '(mdadstandard) _asoutcolumns in xxvars loop';
    run;
    proc print data = _asoutcolumns_param  width=minimum;
      by table column;
      title%eval(&titlstrt + 1)
       '(mdadstandard) _asoutcolumns_param in xxvars loop';
    run;
    title%eval(&titlstrt + 1);
  %end;
%end;    /* xxvars not _none_ or null loop */
%if %bquote(&outlib) ^= %then %do;
  *============================================================================;
  * Copy metadata to output location;
  *============================================================================;
  *----------------------------------------------------------------------------;
  * Call mdmake to create 0-obs data set to define standard meta attributes;
  *----------------------------------------------------------------------------;
  %mdmake(outlib=work,mode=replace,outprefix=_ast,contents=0)
  *----------------------------------------------------------------------------;
  * Set mdmake 0-obs standard metadata sets from mdmake with output metadata;
  *----------------------------------------------------------------------------;
  data &outlib..&outprefix.tables;
    set _asttables _asouttables;
    %if ^ &mksource %then %do;
      length source $ 15;
      source = source;
    %end;
    %if &mksource_table & %bquote(%upcase(&xxdata)) ^= _NONE_ %then %do;
      drop source_table;
    %end;
  run;
  data &outlib..&outprefix.columns;
    set _astcolumns _asoutcolumns;
    %if ^ &mksource %then %do;
      length source $ 15;
      source = source;
    %end;
    %if &mksource_table %then %do;
      drop source_table;
    %end;
    %if &mksource_column %then %do;
      drop source_column;
    %end;
  run;
  data &outlib..&outprefix.columns_param;
    set _astcolumns_param _asoutcolumns_param;
    %if ^ &mksource %then %do;
      length source $ 15;
      source = source;
    %end;
    %if &mksource_table %then %do;
      drop source_table;
    %end;
    %if &mksource_column %then %do;
      drop source_column;
    %end;
  run;
  data &outlib..&outprefix.values;
    set _astvalues _asoutvalues;
  run;
  proc catalog;
    copy in=work._asoutdescriptions  out=&outlib..&outprefix.descriptions;
  run; quit;
  %if &contents %then %do;
    proc contents data = &outlib..&outprefix.tables;
    run;
    proc contents data = &outlib..&outprefix.columns;
    run;
    proc contents data = &outlib..&outprefix.columns_param;
    run;
    proc contents data = &outlib..&outprefix.values;
    run;
    proc catalog catalog = &outlib..&outprefix.descriptions;
      contents;
    run;  quit;
 %end;
%end;
*==============================================================================;
* Clean up at end of mdadstandard macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _as:;
    delete _as: / memtype=catalog;
  run; quit;
%end;
title&titlstrt;
%mend;
