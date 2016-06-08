%macro utcomplibs(lib1=_default_,lib2=_default_,nobs=_default_,
 formats=_default_,procompare=_default_,printequal=_default_,
 verbose=_default_,debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : utcomplibs
   VERSION NUMBER           : 1
   TYPE                     : utility
   AUTHOR                   : Greg Steffens
   DESCRIPTION              : Compares one SAS library of data sets to another
   SOFTWARE/VERSION#        : SAS/Version 8
   INFRASTRUCTURE           : Windows, Unix
   PEER REVIEWER            : <Enter broad-use module Peer Reviewer's name(s)>
   VALIDATION LEVEL         : 6
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                               Document List>
   REGULATORY STATUS        : <Enter status [GCP, GLP, GMP, GPP, NDR (nondrug
                               related) regulations, non-regulated, or N/A.]>
   CREATION DATE            : 4AUG2004
   TEMPORARY OBJECT PREFIX  : <Enter unique ID for each broad-use module.
                               See Broad-Use Module Request.>
   BROAD-USE MODULES        : ut_parmdef ut_logical ut_titlstrt
   INPUT                    : ut_parmdef ut_logical
   OUTPUT                   : <List all files and their locations and 
                               file types>
--------------------------------------------------------------------------------
  Parameters:
   Name       Type     Default  Description and Valid Values
   ---------- -------- -------- ------------------------------------------------
   LIB1       required          Libref of first library of data sets to compare
   LIB2       required          Libref of second library of data sets to compare
   NOBS       required 1        ut_logical value specifying whether to compare
                                 the number of observations of each of the 
                                 data sets
   FORMATS    required 1        ut_logical value specifying whether to compare
                                 the format assignments to variables
   PROCOMPARE required 0        ut_logical value specifying whether to execute
                                 a PROC COMPARE of each of the data sets 
                                 in LIB1 and LIB2.  A comparison of the 
                                 structure of same-name data sets in LIB1 and 
                                 LIB2 is always done.  The PROCOMPARE parameter
                                 specifies whether or not to also compare the
                                 content of same named data sets.
   PRINTEQUAL required 1        ut_logical value specifying whether to print
                                 the names of variables whose attributes
                                 compare equal
   VERBOSE    required 1        ut_logical value specifying whether verbose
                                 mode is on or off
   DEBUG      required 0        ut_logical value specifying whether debug 
                                 mode is on or off

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
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(verbose,1,_pdrequired=0,_pdmacroname=utcomplibs,_pdverbose=0)
%ut_logical(verbose)
%ut_parmdef(lib1,_pdrequired=0,_pdmacroname=utcomplibs,_pdverbose=&verbose)
%ut_parmdef(lib2,_pdrequired=0,_pdmacroname=utcomplibs,_pdverbose=&verbose)
%ut_parmdef(nobs,1,_pdrequired=1,_pdmacroname=utcomplibs,_pdverbose=&verbose)
%ut_parmdef(printequal,1,_pdrequired=1,_pdmacroname=utcomplibs,_pdverbose=&verbose)
%ut_parmdef(formats,1,_pdrequired=1,_pdmacroname=utcomplibs,_pdverbose=&verbose)
%ut_parmdef(procompare,0,_pdrequired=0,_pdmacroname=utcomplibs,
 _pdverbose=&verbose)
%ut_parmdef(debug,0,_pdrequired=0,_pdmacroname=utcomplibs,_pdverbose=&verbose)
%ut_logical(nobs)
%ut_logical(formats)
%ut_logical(procompare)
%ut_logical(printequal)
%ut_logical(debug)
%local titlstrt clnot1_obs clnot2_obs;
%ut_titlstrt
title&titlstrt "Comparing lib1: &lib1: %sysfunc(pathname(&lib1))";
title%eval(&titlstrt + 1) "With lib2: &lib2: %sysfunc(pathname(&lib2))";
*==============================================================================;
* Create PROC CONTENTS output data set for each library;
%*        PROC CONTENTS does not report data sets with 0 variables;
%*         use dictionary view to get list of data sets and compare to contents;
*==============================================================================;
proc contents data = &lib1.._all_  out = _clcont1  noprint;
run;
data _clcont1;
  set _clcont1;
  memname = upcase(memname);
  name = upcase(name);
run;
proc sort data = _clcont1;
  by memname name;
run;
proc contents data = &lib2.._all_  out = _clcont2  noprint;
run;
data _clcont2;
  set _clcont2;
  memname = upcase(memname);
  name = upcase(name);
run;
proc sort data = _clcont2;
  by memname name;
run;
%if &debug %then %do;
  proc print data = _clcont1 width=minimum;
    title%eval(&titlstrt + 2) '(utcomplibs) Debug: Contents of lib1';
  run;
  proc print data = _clcont2 width=minimum;
    title%eval(&titlstrt + 2) '(utcomplibs) Debug: Contents of lib2';
  run;
  proc contents data = _clcont1;
    title%eval(&titlstrt + 2)
     '(utcomplibs) Debug: Contents of contents data set';
  run;
  title%eval(&titlstrt + 2);
%end;
*==============================================================================;
* Create data set of members that exist in both libraries;
*==============================================================================;
data _clmem1;
  set _clcont1 (keep=memname memlabel);
  by memname;
  if first.memname;
run;
data _clmem2;
  set _clcont2 (keep=memname memlabel);
  by memname;
  if first.memname;
run;
data _clmatch (keep=memname)
     _clmemnot1 (keep=memname memlabel)
     _clmemnot2 (keep=memname memlabel2 rename=(memlabel2=memlabel));
  merge _clmem1 (in=from1)
        _clmem2 (in=from2 rename=(memlabel=memlabel2));
  by memname;
  if from1 & from2 then output _clmatch;
  else if from1 then output _clmemnot2;
  else if from2 then output _clmemnot1;
run;
*==============================================================================;
* Print members that exist in one library but not both libraries;
*==============================================================================;
proc print data = _clmemnot1;
  title%eval(&titlstrt + 3) "(utcomplibs) Members in &lib2 but not &lib1";
run;
proc print data = _clmemnot2;
  title%eval(&titlstrt + 3) "(utcomplibs) Members in &lib1 but not &lib2";
run;
title%eval(&titlstrt + 3);
%if ^ &procompare %then %do;
  *============================================================================;
  * If PROC COMPARE is not requested then do a comparison of structure only;
  * Subset PROC CONTENTS output data sets to include only members that exist;
  * in both libraries;
  *============================================================================;
  data _clcont1_common_mems
       _clcontm1_common_mems(keep=memname memlabel memtype typemem nobs delobs);
    merge _clcont1 (in=from1)  _clmatch (in=fromboth);
    by memname;
    if from1 & fromboth;
    output _clcont1_common_mems;
    if first.memname then output _clcontm1_common_mems;
  run;
  data _clcont2_common_mems
       _clcontm2_common_mems(keep=memname memlabel memtype typemem nobs delobs);
    merge _clcont2 (in=from2)  _clmatch (in=fromboth);
    by memname;
    if from2 & fromboth;
    output _clcont2_common_mems;
    if first.memname then output _clcontm2_common_mems;
  run;
  *============================================================================;
  * Compare the member attributes of each data set by comparing attributes;
  *  contained in the PROC CONTENTS output data sets;
  *============================================================================;
  data _clmemdiffs (keep=member attribute lib1_value lib2_value);
    merge _clcontm1_common_mems 
          _clcontm2_common_mems (rename=(memlabel=memlabel2 memtype=memtype2
                                  typemem=typemem2 nobs=nobs2 delobs=delobs2));
          /*
           engine crdate nobs modate delobs idxcount protect
           flags compress reuse sorted charset collate nodupkey noduprec
           encrypt pointobs genmax gennum gennext
          */
    by memname;
    length member $ 32 attribute $ 25 lib1_value lib2_value $ 200;
    if first.memname then do;
      * flag if any member attribute differs for the current member;
      _clerrmematr = 0;
      if memlabel ^= memlabel2 & first.memname then do;
        member = memname;
        attribute = 'Member Label';
        lib1_value = memlabel;
        lib2_value = memlabel2;
        output _clmemdiffs;
        _clerrmematr = 1;
      end;
      if memtype  ^= memtype2 & first.memname  then do;
        member = memname;
        attribute = 'Member Type';
        lib1_value = memtype;
        lib2_value = memtype2;
        output _clmemdiffs;
        _clerrmematr = 1;
      end;
      if typemem  ^= typemem2 & first.memname  then do;
        member = memname;
        attribute = 'Type of Member';
        lib1_value = typemem;
        lib2_value = typemem2;
        output _clmemdiffs;
        _clerrmematr = 1;
      end;
      %if &nobs %then %do;
        if nobs     ^= nobs2 & first.memname then do;
          member = memname;
          attribute = 'Number of Obs';
          lib1_value = left(put(nobs,32.0));
          lib2_value = left(put(nobs2,32.0));
          output _clmemdiffs;
          _clerrmematr = 1;
        end;
        if delobs   ^= delobs2   then do;
          member = memname;
          attribute = 'Number of deleted obs';
          lib1_value = left(put(delobs,32.0));
          lib2_value = left(put(delobs2,32.0));
          output _clmemdiffs;
          _clerrmematr = 1;
        end;
      %end;
      %if &printequal %then %do;
        if ^ _clerrmematr then do;
          member = memname;
          attribute = '-All-';
          lib1_value = 'All member attributes are the same';
          lib2_value = ' ';
          output _clmemdiffs;
        end;
      %end;
    end;
    label lib1_value = "lib1=&lib1 Value"
     lib2_value = "lib2=&lib2 Value";
  run;
  *============================================================================;
  * Compare the variable attributes of each data set by comparing attributes;
  *  contained in the PROC CONTENTS output data sets;
  *============================================================================;
  %let clnot1_obs = 0;
  %let clnot2_obs = 0;
  data _clnot1 (keep=memname name label2 rename=(label2=label))
   _clnot2 (keep=memname name label)
   _clvardiffs (keep=member variable attribute lib1_value lib2_value);
    if eof then do;
      if clnot1_obs > 0 then
       call symput('clnot1_obs',trim(left(put(clnot1_obs,8.0))));
      if clnot2_obs > 0 then
       call symput('clnot2_obs',trim(left(put(clnot2_obs,8.0))));
    end;
    merge _clcont1_common_mems (in=lib1)
          _clcont2_common_mems
          (in=lib2 rename=(delobs=delobs2 format=format2 formatd=formatd2
          formatl=formatl2 informat=informat2 informd=informd2
          informl=informl2 just=just2 label=label2 length=length2
          memlabel=memlabel2 memtype=memtype2 nobs=nobs2 type=type2
          typemem=typemem2))    end = eof;
          /*
           varnum npos idxusage sortedby
          */
    by memname name;
    if ^lib1 then do;
      clnot1_obs + 1;
      output _clnot1;
    end;
    else if ^lib2 then do;
      clnot2_obs + 1;
      output _clnot2;
    end;
    length member variable $ 32 attribute $ 25 lib1_value lib2_value $ 200;
    if lib1 & lib2;
    if first.memname then do;
      * flag if any variable attribute differs for any variable in the;
      *  current member;
      _clerrmemvaratr = 0;
    end;
    * flag if any attribute of current variable differs;
    if first.name then _clerrvaratr = 0;
    %if &formats %then %do;
      if format  ^= format2  then do;
        member = memname;
        variable = name;
        attribute = 'Format';
        lib1_value = format;
        lib2_value = format2;
        output _clvardiffs;
        _clerrmemvaratr = 1;
        _clerrvaratr = 1;
      end;
      if formatd  ^= formatd2  then do;
        member = memname;
        variable = name;
        attribute = 'Format Decimal Places';
        lib1_value = left(put(formatd,32.0));
        lib2_value = left(put(formatd2,32.0));
        output _clvardiffs;
        _clerrmemvaratr = 1;
       _clerrvaratr = 1;
      end;
      if formatl  ^= formatl2  then do;
        member = memname;
        variable = name;
        attribute = 'Format Length';
        lib1_value = left(put(formatl,32.0));
        lib2_value = left(put(formatl2,32.0));
        output _clvardiffs;
        _clerrmemvaratr = 1;
        _clerrvaratr = 1;
      end;
      if informat ^= informat2 then do;
        member = memname;
        variable = name;
        attribute = 'Informat';
        lib1_value = informat;
        lib2_value = informat2;
        output _clvardiffs;
        _clerrmemvaratr = 1;
        _clerrvaratr = 1;
      end;
      if informd  ^= informd2  then do;
        member = memname;
        variable = name;
        attribute = 'Informat decimal Places';
        lib1_value = left(put(informd,32.0));
        lib2_value = left(put(informd2,32.0));
        output _clvardiffs;
        _clerrmemvaratr = 1;
        _clerrvaratr = 1;
      end;
      if informl  ^= informl2  then do;
        member = memname;
        variable = name;
        attribute = 'Informat Length';
        lib1_value = left(put(informl,32.0));
        lib2_value = left(put(informl2,32.0));
        output _clvardiffs;
        _clerrmemvaratr = 1;
        _clerrvaratr = 1;
      end;
    %end;
    if just     ^= just2     then do;
      member = memname;
      variable = name;
      attribute = 'Format Justification';
      lib1_value = left(put(just,32.0));
      lib2_value = left(put(just2,32.0));
      output _clvardiffs;
      _clerrmemvaratr = 1;
      _clerrvaratr = 1;
    end;
    if label    ^= label2    then do;
      member = memname;
      variable = name;
      attribute = 'Variable Label';
      lib1_value = label;
      lib2_value = label2;
      output _clvardiffs;
      _clerrmemvaratr = 1;
      _clerrvaratr = 1;
    end;
    if length   ^= length2   then do;
      member = memname;
      variable = name;
      attribute = 'Variable Length';
      lib1_value = left(put(length,32.0));
      lib2_value = left(put(length2,32.0));
      output _clvardiffs;
      _clerrmemvaratr = 1;
      _clerrvaratr = 1;
    end;
    if type     ^= type2     then do;
      member = memname;
      variable = name;
      attribute = 'Variable Type';
      lib1_value = left(put(type,32.0));
      lib2_value = left(put(type2,32.0));
      output _clvardiffs;
      _clerrmemvaratr = 1;
      _clerrvaratr = 1;
    end;
    %if &verbose %then %do;
      if last.name & ^ _clerrvaratr then do;
        member = memname;
        variable = name;
        attribute = '-All-';
        lib1_value = 'All variable attributes for this variable are the same';
        lib2_value = ' ';
        output _clvardiffs;
      end;
    %end;
    if last.memname & ^ _clerrmemvaratr then do;
      member = memname;
      variable = '-All-';
      attribute = '-All-';
      lib1_value = 'All variable attributes for all variables are the same';
      lib2_value = ' ';
      output _clvardiffs;
    end;
    label lib1_value = "lib1=&lib1 Value"
     lib2_value = "lib2=&lib2 Value";
    retain _clerrmemvaratr;
  run;
  proc sort data = _clmemdiffs;
    by member;
  run;
  proc sort data = _clvardiffs;
    by member variable;
  run;
  %if &clnot1_obs > 0 %then %do;
    proc print data = _clnot1 width=minimum;
      title%eval(&titlstrt + 3) "(utcomplibs) Variables Not found in &lib1";
    run;
  %end;
  %if &clnot2_obs > 0 %then %do;
    proc print data = _clnot2 width=minimum;
      title%eval(&titlstrt + 3) "(utcomplibs) Variables Not found in &lib2";
    run;
  %end;
  proc print data = _clmemdiffs width=minimum  label;
    by member;
    title%eval(&titlstrt + 3) "(utcomplibs) Member Attribute Differences";
  run;
  proc print data = _clvardiffs
   %if ^ &printequal %then %do;
     (where = (
     lib1_value ^= 'All variable attributes for this variable are the same' &
     lib1_value ^= 'All variable attributes for all variables are the same'
     ))
   %end;
   width=minimum  label
  ;
    by member variable;
    title%eval(&titlstrt + 3) "(utcomplibs) Variable Attribute Differences";
  run;
  title%eval(&titlstrt + 3);
%end;
%if &procompare %then %do;
  *============================================================================;
  * If the PROCOMPARE parameter is true then do a PROC COMPARE of each data set;
  *  that exists in both libraries.  This assumes the sort order is the same ;
  *  so no ID statement is used;
  *============================================================================;
  %local nummems;
  %let nummems = 0;
  data _null_;
    if eof & nummems > 0 then
     call symput('nummems',trim(left(put(nummems,5.0))));
    set _clmatch (keep=memname) end=eof;
    by memname;
    if first.memname;
    nummems + 1;
    call symput('mem' || trim(left(put(nummems,5.0))),trim(left(memname)));
  run;
  %if &nummems > 0 %then %do i = 1 %to &nummems;
    proc compare base=&lib1..&&mem&i  compare=&lib2..&&mem&i listall;
    run;
  %end;
  %else %put (utcomplibs) No member names are in common so no proc compare done;
%end;
%if ^ &debug %then %do;
  *============================================================================;
  * Cleanup at end of utcomplibs macro;
  *============================================================================;
  proc datasets lib=work nolist;
    delete _cl:;
  run; quit;
%end;
title&titlstrt;
%mend;
