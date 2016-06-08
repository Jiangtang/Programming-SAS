%macro mdatribs(inlib=_default_,mdlib=_default_,outlib=_default_,
 force=_default_,mdprefix=_default_,allatribs=_default_,softfmts=_default_,
 select=_default_,exclude=_default_,verbose=_default_,newvarvaln=_default_,
 newvarvalc=_default_,contents=_default_,debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : mdatribs.sas
   VERSION NUMBER           : 1
   TYPE                     : metadata
   AUTHOR                   : Gregory Steffens
   DESCRIPTION              : Adds attributes to existing data sets as defined
                              in meta data sets.  Attributes include data set
                              labels, variable labels and formats.
   SOFTWARE/VERSION#        : SAS/Version 8
   INFRASTRUCTURE           : Windows, MVS
   PEER REVIEWER            : <Enter broad-use module Peer Reviewer's name(s)>
   VALIDATION LEVEL         : 6
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
                               Document List>
   REGULATORY STATUS        : GCP
   CREATION DATE            : 01/Feb/2004
   TEMPORARY OBJECT PREFIX  : _ma
   BROAD-USE MODULES        : %ut_logical %ut_parmdef %ut_titlstrt
                              %mdmake %ut_quote_token
   INPUT                    : as defined by inlib and mdlib parameters
   OUTPUT                   : as defined by outlib parameter
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
   -------- -------- -------- --------------------------------------------------
   INLIB    required          Libref of library containing study data
   MDLIB    required &inlib   Libref of library containing spec meta data sets
                               TABLES COLUMNS VALUES
   OUTLIB   required &inlib   Libref of library to copy data sets to
   FORCE    required 1        %ut_logical value specifying whether to force 
                               assignment of member labels, variable labels and 
                               variable formats when the member or variable 
                               already has one.
   ALLATRIBS required 0       %ut_logical value specifying whether the following
                               functions will be done: 1.) drop variables from
                               INLIB that are not defined in MDLIB, 2.) add
                               variables to INLIB that are defined in SPECLIB 
                               but do not exist in INLIB, 3.) reassign the 
                               length of variables in INLIB that are defined
                               in SPECLIB.
   NEWVARVALN required .       Value to assign variables that are added to the
                               data set when ALLATRIBS is true.  This value is
                               assigned to numeric variables.
   NEWVARVALC required blank  Value to assign variables that are added to the
                               data set when ALLATRIBS is true.  This value is
                               assigned to character variables.
   SOFTFMTS required 0        %ut_logical value specifying whether to assign 
                               formats to variables when the FMTFLAG is false
                               or missing
   MDPREFIX optional          Prefix to apply to meta data set names in INLIB
   SELECT   optional          List of data set names to process.  By default all
                               data sets are processed.
   EXCLUDE  optional          List of data set names not to process.  By default
                               no data sets are excluded.
   CONTENTS required 1        %ut_logical value specifying whether to generate
                               a PROC CONTENTS report of each data set
   VERBOSE  required 1        %ut_logical value specifying whether verbose mode
                               is on or off
   DEBUG    required 0        %ut_logical value specifying whether debug mode
                               is on or off.

--------------------------------------------------------------------------------
  Usage Notes:  <Parameter dependencies and additional information for the user>
  The data sets are updated with PROC DATASETS so the data is not read by
  the macro so execution is faster.  But if ALLATRS is true then a data step
  may be necessary.  If OUTLIB is not the same as INLIB then
  the INLIB data are copied to OUTLIB prior to the modifications.

--------------------------------------------------------------------------------
  Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

  The simplest call is:

     %mdatribs(inlib=r,outlib=a)

   This will read the data sets in the r library and assign labels
   and formats in all the data sets in the a library.

--------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
  Ver#  Author           Description
  ----  ---------------  -------------------------------------------------------
  001   Gregory Steffens Original version of the broad-use module

 **eoh*************************************************************************/
%*=============================================================================;
%* Initialization;
%*=============================================================================;
%ut_parmdef(inlib,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(mdlib,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(outlib,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(force,1,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(mdprefix,_pdmacroname=mdatribs,_pdrequired=0,_pdverbose=1)
%ut_parmdef(newvarvaln,.,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1);
    %*   newvarvalc is required but parmdef reports blank as not specified;
%ut_parmdef(newvarvalc,%str( ),_pdmacroname=mdatribs,_pdrequired=0,_pdverbose=1);
%ut_parmdef(allatribs,0,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(verbose,1,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(softfmts,0,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(select,_pdmacroname=mdatribs,_pdrequired=0,_pdverbose=1)
%ut_parmdef(exclude,_pdmacroname=mdatribs,_pdrequired=0,_pdverbose=1)
%ut_parmdef(contents,1,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_parmdef(debug,0,_pdmacroname=mdatribs,_pdrequired=1,_pdverbose=1)
%ut_logical(force)
%ut_logical(softfmts)
%ut_logical(contents)
%ut_logical(debug)
%ut_logical(allatribs)
%ut_logical(verbose)
%local titlstrt nummems numvars i j datastep selectq excludeq;
%ut_titlstrt
%if %bquote(&mdlib) = %then %do;
  %put (mdatribs) MDLIB is a required parameter of the mdatribs macro;
  %put (mdatribs) terminating mdatribs;
  %goto endmac;
%end;
%if %bquote(&inlib) = %then %do;
  %put (mdatribs) INLIB is a required parameter of the mdatribs macro;
  %put (mdatribs) terminating mdatribs macro;
  %goto endmac;
%end;
%if %bquote(&mdlib) = %then %let mdlib = &inlib;
%if %bquote(&outlib)  = %then %let outlib = &inlib;
%ut_quote_token(inmvar=select,outmvar=selectq)
%let selectq = %upcase(&selectq);
%ut_quote_token(inmvar=exclude,outmvar=excludeq)
%let excludeq = %upcase(&excludeq);
%if %bquote(%upcase(&outlib)) ^= %bquote(%upcase(&inlib)) %then %do;
  *============================================================================;
  * If outlib is different from inlib copy the data from inlib to outlib;
  *============================================================================;
  proc copy in=&inlib out=&outlib;
    %if %bquote(&select) ^= %then %do;
      select &select;
    %end;
    %else %if %bquote(&exclude) ^= %then %do;
      exclude &exclude;
    %end;
  run;
%end;
*==============================================================================;
* Get meta data descriptions of member and variable attributes;
*==============================================================================;
%mdmake(outlib=work,inlib=&mdlib,inprefix=&mdprefix,outprefix=_ma,
 mode=replace,contents=0,inselect=&select,inexclude=&exclude,
 addheader=1,debug=&debug)
data _madsns;
  length table $ 32;
  set _matables;
  table = upcase(table);
run;
proc sort data = _madsns;
  by table;
run;
data _mavars;
  length table column $ 32;
  set _macolumns;
  table = upcase(table);
  column = upcase(column);
  cformat = upcase(cformat);
run;
proc sort data = _mavars;
  by table column;
run;
data _mameta _manotabl _manovars;
  merge _madsns (in=fromdsns keep=table tlabel)
        _mavars (in=fromvars keep=table column ctype clabel cformat cformatflag
                 clength cpkey corder clabellong cheader);
  by table;
  if ^ fromdsns then output _manotabl;
  if ^ fromvars then output _manovars;
  if fromdsns & fromvars;
  output _mameta;
run;
proc sort data = _mameta;
  by table column;
run;
%if &verbose %then %do;
  proc print data = _manotabl width=minimum;
    title%eval(&titlstrt + 0)
     "(mdatribs) Variables defined in metadata that have no table definition";
  run;
  proc print data = _manovars width=minimum;
    title%eval(&titlstrt + 0)
     "(mdatribs) Tables defined in metadata that have no variables defined";
  run;
  title%eval(&titlstrt + 0);
%end;
*==============================================================================;
* Merge meta data with actual data attributes;
*==============================================================================;
proc contents data = &inlib.._all_    out = _macont  noprint;
run;
*------------------------------------------------------------------------------;
* This dictionary step and merge is necessary when an &inlib data set has 0 var;
*  in this case proc contents does not create an obs in _macont (eg mdmkdsn);
*------------------------------------------------------------------------------;
%* not doing upcase on libname cuts processing time in half
 see SI note SN-009581;
proc sql;
  create table _matablesdict as select memname, memlabel from dictionary.tables
   where libname = "%upcase(&inlib)";
quit;
data _macont;
  merge _macont _matablesdict;
  by memname;
run;
data _macont;
  length memname name $ 32;
  set _macont
   %if %bquote(&selectq) ^= | %bquote(&excludeq) ^= %then %do;
     (where = (
     %if %bquote(&selectq) ^= %then %do;
       upcase(memname) in (&selectq)
     %end;
     %if %bquote(&excludeq) ^= %then %do;
       %if %bquote(&selectq) ^= %then %do;
         &
       %end;
       upcase(memname) ^ in (&excludeq)
     %end;
     ))
   %end;
  ;
  memname = upcase(memname);
  name = upcase(name);
run;
proc sort data = _macont;
  by memname name;
run;
%let nummems = 0;
data _madsns;
  if eof then do;
    if nummem > 0 then call symput('nummems',compress(put(nummem,5.0)));
  end;
  merge _madsns (in=frommeta keep=table tlabel)
        _macont (in=fromcont keep=memname memlabel rename=(memname=table))
        end=eof;
  by table;
  if frommeta & fromcont;
  if first.table then do;
    nummem + 1;
    call symput('mem' || compress(put(nummem,5.0)),trim(left(table)));
    call symput('mlb' || compress(put(nummem,5.0)),trim(left(tlabel)));
    output;
  end;
run;
data _mameta  _manomet _manocnt;
  merge _mameta (in=frommeta)
        _macont (in=fromcont keep=memname memlabel name label format length type
         rename=(memname=table name=column))    end=eof;
  by table column;
  if cpkey > 0 then cpkeyyn = 1;
  else cpkeyyn = 0;
  if frommeta & ^ fromcont then do;
    _mavarfl = 'M';
    output _manocnt _mameta;
  end;
  else if ^ frommeta & fromcont then do;
    _mavarfl = 'C';
    output _manomet _mameta;
  end;
  else if frommeta & fromcont then do;
    _mavarfl = 'B';
    output _mameta;
  end;
  label _mavarfl = 'Variable flag C=in study contents M=in metadata B=both';
run;
%if &verbose %then %do;
  proc print data = _manomet width=minimum;
    var table column;
    title%eval(&titlstrt + 0) "(mdatribs) Data Sets and Variables in library "
     "(&inlib) but not defined in metadata (&mdlib)";
    title%eval(&titlstrt + 1) "(mdatribs) === THESE VARIABLES WILL BE DROPPED ==="
     %if ^ &allatribs %then %do;
       "if you specify the ALLATRIBS parameter to true"
     %end;
    ;
  run;
  proc print data = _manocnt width=minimum;
    var table column;
    title%eval(&titlstrt + 0) "(mdatribs) Data Sets and Variables defined in "
     "metadata (&mdlib) but do not exist in library (&inlib)";
    title%eval(&titlstrt + 1) "(mdatribs) You should add these variables to &inlib"
     " or delete them from metadata (&mdlib)";
    title%eval(&titlstrt + 2) "(mdatribs) === THESE VARIABLES WILL BE ADDED "
     "WITH A VALUE OF num:&newvarvaln or char:"&newvarvalc" ==="
     %if ^ &allatribs %then %do;
       "if you specify the ALLATRIBS parameter to true"
     %end;
    ;
  run;
  title%eval(&titlstrt + 0);
%end;
%if &debug %then %do;
  proc print data = _mameta width=minimum;
    title%eval(&titlstrt + 0) "(mdatribs) _mameta data set variable attributes";
  run;
  proc print data = _macont width=minimum;
    title%eval(&titlstrt + 0) "(mdatribs) _macont data set variable attributes";
  run;
  title%eval(&titlstrt + 0);
  %put (mdatribs) nummems=&nummems;
  %do i = 1 %to &nummems;
    %put (mdatribs) mem&i=&&mem&i mlb&i=&&mlb&i;
  %end;
%end;
proc sort data = _mameta;

  by table descending cpkeyyn cpkey cheader corder column;
  %* this does not match mdcheck so need to fix this BY or call mdorder;

run;
%if &nummems > 0 %then %do i = 1 %to &nummems;
  *============================================================================;
  %bquote(* &i Process data set &&mem&i);
  * to add data set label, variable label, format and length;
  *============================================================================;
  %let datastep = 0;
  %let numvars = 0;
  data _null_;
    if eof then do;
      if numvar > 0 then call symput('numvars',compress(put(numvar,5.0)));
    end;
    length cformat $ 15;  %* length to allow addition of . and $ and datetime21.3;
    set _mameta (where = (upcase(table) = "%upcase(&&mem&i)")) end = eof;

/*
    %ut_logical(cfofmtaflag,vartype=datan)
*/

    if column ^= ' ' | clabel ^= ' ' | (cformat ^= ' '
/*
     %if ^ &softfmts %then %do;
       & cformatflag ^ in (2 3 4)
     %end;
*/
     )
    ;
    numvar + 1;
    call symput('var' || compress(put(numvar,5.0)),trim(left(column)));
    call symput('vtp' || compress(put(numvar,5.0)),'n');
    if ctype ^= ' ' then do;
      if upcase(ctype) =: 'C' then 
       call symput('vtp' || compress(put(numvar,5.0)),'c');
      else if upcase(ctype) =: 'N' then 
       call symput('vtp' || compress(put(numvar,5.0)),'n');
    end;
    %if &debug %then %do;
      put _n_= table= column= _mavarfl=;
    %end;
    call symput('vln' || compress(put(numvar,5.0)),'');
    if ctype =: 'N' then _maminlen = 3;
    else _maminlen = 1;
    if _mavarfl = 'B' then do;
      call symput('vac' || compress(put(numvar,5.0)),'modify');
    end;
    else if _mavarfl = 'C'  then do;
      call symput('vac' || compress(put(numvar,5.0)),'drop');
      call symput('datastep','1');
      %if &debug %then %do;
        put _n_= 'c ' _mavarfl= table= column=;
      %end;
    end;
    else if _mavarfl = 'M' then do;
      call symput('vac' || compress(put(numvar,5.0)),'add');

      if clength ^= . then call symput('vln' || compress(put(numvar,5.0)),
       compress(put(max(clength,_maminlen),5.0)));

      call symput('datastep','1');
      %if &debug %then %do;
        put _n_= 'm ' _mavarfl= table= column=;
      %end;
    end;
    if clabel ^= label
     %if ^ &force %then %do;
       & label = ' '
     %end;
     then do;
      if clabel ^= clabellong & clabel =: clabellong then 
       call symput('vlb' || compress(put(numvar,5.0)),trim(left(clabellong)));
      else call symput('vlb' || compress(put(numvar,5.0)),trim(left(clabel)));
    end;
    else call symput('vlb' || compress(put(numvar,5.0)),' ');
    if clength ^= length & clength > 0 & _mavarfl = 'B' then do;

      call symput('vln' || compress(put(numvar,5.0)),
       compress(put(max(clength,_maminlen),5.0)));

      call symput('datastep','1');
      %if &allatribs %then 
       %ut_errmsg(msg='Changing length of ' table= column= 'from ' length 'to '
        clength,macroname=mdatribs,type=note);
      %if &debug %then %do;
        put _n_= 'vln ' table= column= clength= length=;
      %end;
    end;
    if

     %if ^ &softfmts %then %do;
       cformatflag ^ in (2 3 4) &
     %end;

     cformat ^= ' ' then do;

      if upcase(ctype) =: 'C' & cformat ^=: '$' then
       cformat = '$' || substr(cformat,1,7);
      if index(cformat,'.') = 0 then cformat = trim(left(cformat)) || '.';

      %if ^ &force %then %do;
        if format = ' ' then
         call symput('vfm' || compress(put(numvar,5.0)),trim(left(cformat)));
        else call symput('vfm' || compress(put(numvar,5.0)),'_nochange_');
      %end;
      %else %do;
        if cformat ^= format then 
         call symput('vfm' || compress(put(numvar,5.0)),trim(left(cformat)));
        else call symput('vfm' || compress(put(numvar,5.0)),'_nochange_');
      %end;

    end;
    else do;
      %if ^ &force %then %do;
        if format ^= ' ' then
         call symput('vfm' || compress(put(numvar,5.0)),'_nochange_');
        else do;
          if cformat = ' ' then
           call symput('vfm' || compress(put(numvar,5.0)),'_nochange_');
          else call symput('vfm' || compress(put(numvar,5.0)),' ');
        end;
      %end;
      %else %do;
        if cformat ^= format then
         call symput('vfm' || compress(put(numvar,5.0)),' ');
        else call symput('vfm' || compress(put(numvar,5.0)),'_nochange_');
      %end;
    end;

  run;
  %if &debug %then %do;
    %put numvars=&numvars datastep=&datastep allatribs=&allatribs;
    %do j = 1 %to &numvars;
      %put var&j=&&var&j vtp&j=&&vtp&j vac&j=&&vac&j vlb&j=&&vlb&j
       vln&j=&&vln&j vfm&j=&&vfm&j;
    %end;
  %end;

  %if &numvars > 0 | %nrbquote(&&mlb&i) ^= %then %do;

    %if &numvars > 0 & &datastep & &allatribs %then %do;
      data &outlib..&&mem&i;
        %if &numvars > 0 %then %do j = 1 %to &numvars;
          %if &&vac&j = drop %then %do;
            drop &&var&j;
          %end;
          %else %if &&vac&j = add %then %do;

%* call ut_find_long_chars with output data set to be sure truncation of text
   does not occur with the length statement or maybe ut_truncate_long_chars;

             %if &&vtp&j = c %then %do;
               %if &&vln&j ^= %then %do;
                 length &&var&j $ &&vln&j;
               %end;
               &&var&j = "&newvarvalc";
             %end;
             %else %if &&vtp&j = n %then %do;
               %if &&vln&j ^= & &&vln&j <= 8 & &&vln&j >= 3 %then %do;
                 length &&var&j &&vln&j;
               %end;
               %else %do;
                 length &&var&j 8;
               %end;
               &&var&j = &newvarvaln;
             %end;
          %end;
          %else %if &&vac&j = modify & &&vln&j ^= %then %do;
             %if &&vtp&j = c %then %do;
               length &&var&j $ &&vln&j;
             %end;
             %else %if &&vtp&j = n %then %do;
               %if &&vln&j ^= & &&vln&j <= 8 & &&vln&j >= 3 %then %do;
                 length &&var&j &&vln&j;
               %end;
               %else %do;
                 length &&var&j 8;
               %end;
             %end;
          %end;
        %end;
        set &outlib..&&mem&i;
      run;
    %end;
    %if &numvars > 0 %then %do;
      proc datasets lib=&outlib nolist;
        modify &&mem&i
         %if %superq(mlb&i) ^= %then %do;
           (label = "%superq(mlb&i)")
         %end;
        ;
        %if &numvars > 0 %then %do j = 1 %to &numvars;
          %if &&vac&j = modify | (&&vac&j = add & &allatribs) |
           (&&vac&j = drop & ^ &allatribs) %then %do;
            %if %superq(vlb&j) ^= %then %do;
              label &&var&j = "%superq(vlb&j)";
            %end;

            %if %bquote(&&vfm&j) ^= _nochange_ %then %do;
              format &&var&j &&vfm&j..;
            %end;
  
          %end;
        %end;
      run; quit;
    %end;
    %else %put (mdatribs) no variables to modify;
    %if &contents %then %do;
      proc contents data = &outlib..&&mem&i;
        title&titlstrt "(mdatribs) Contents of output library &outlib";
      run;
    %end;
  %end;
  %else %put (mdatribs) No variables in &&mem&i need modification;
%end;
%else %put (mdatribs) No members found;
%endmac:
*==============================================================================;
* Cleanup at end of mdatribs macro;
*==============================================================================;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _ma:;
  run; quit;
%end;
title&titlstrt;
%mend;
