%macro thin2wide(data=_default_,out=_default_,mdlib=_default_,
 mdprefix=_default_,mdselect=_default_,mdexclude=_default_,pkeys=_default_,
 param_var=_default_,paramrel_vars=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : thin2wide
   TYPE                     : data transformation
   DESCRIPTION              : Transforms a tall-thin data set into a short-wide
                               data set, e.g. the observat tall-thin structure
                               can be transformed to a short-wide data 
                               structure with this macro.
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
							      Document List>
   SOFTWARE/VERSION#        : SAS/Version 8 and 9
   INFRASTRUCTURE           : Windows, MVS, Unix
   BROAD-USE MODULES        : ut_parmdef mdmake ut_marray
   INPUT                    : as defined by the DATA and MDLIB parameters
   OUTPUT                   : as defined by the OUT parameter
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : GCP
   TEMPORARY OBJECT PREFIX  : _tw
  -----------------------------------------------------------------------------
  Parameters:
   Name         Type     Default  Description and Valid Values
  ------------- -------- -------- -------------------------------------------------
  DATA          required          Name of the input data set that is in a
                                   tall-thin structure containing the parameter
                                   variable PARAM_VAR and one or more parameter
                                   related variables PARAMREL_VARS.
  OUT           required          Name of output data set that is to be created
                                   in a short-wide structure.  Observations in
                                   DATA are collapsed, PARAM_VAR is dropped and
                                   each PARAMREL_VARS results in an array of
                                   new variables where the number of elements
                                   in the array is the number of unique values
                                   of PARAM_VAR.
  MDLIB         optional          Libref of metadata that includes a
                                   specification of DATA.  see usage note.
  MDPREFIX      optional          Prefix of the metadata set names
  MDSELECT      optional DATA     

  MDEXCLUDE     optional          
drop mdexclude?

  PKEYS         optional          List of primary key variables of DATA when
                                   MDLIB is not specified
  PARAM_VAR     optional          Name of the parameter variable in DATA when
                                   MDLIB is not specified

support more than one param var ?


  PARAMREL_VARS optional          List of variable names that are parameter
                                   related variables when MDLIB is not specified
  VERBOSE       required 1        %ut_logical value specifying whether verbose
                                   mode is on or off
  DEBUG         required 0        %ut_logical value specifying whether debug mode
                                   is on or off
  -----------------------------------------------------------------------------
  Usage Notes:

  This macro will replace the variables PARAM_VAR and PARAMREL_VARS with an
  array of variables whose names are specified in the metadata set
  columns_param paramrelcol.  If the metadata does not specify this name then
  a name will be created by this macro.  When the variables are dropped the 
  output data set is rekeyed and observations are collapsed to create a more
  short-wide data set structure.  PARAM_VAR is a primary key and the number
  of its values determines the number of new variables created for each
  paramrel_vars variable.

  Either MDLIB or all of PKEYS PARAM_VAR and PARAMREL_VARS must be specified.
  If MDLIB and the other parameters are specified then MDLIB takes precedence.
  If MDLIB and the parameter is specified and MDLIB does not contain the 
  information then the parameter value is used.

  The metadata in MDLIB must contain at least:
  COLUMNS      : table column cpkey 
  COLUMNS_PARAM: table column param paramrel paramrelcol ptype plength plabel
                 pformat pformatflag

  Double quotes will be compressed out of PLABEL values in the COLUMNS_PARAM
  metadata set.

  -----------------------------------------------------------------------------
  Assumptions:

  The metadata in MDLIB must correctly describe the data set named by the DATA
  parameter.  This can be verified by running the mdcheck macro to compare 
  the metadata to the data set.  If COLUMNS_PARAM does not contain all the
  values of the PARAM_VAR variable or if not all the parameter related 
  variables are defined then the macro will not transform DATA correctly.  If
  MDLIB is not specified and the parameters are instead then the parameter
  values must be correct to get the expected transformation of DATA.

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

  -----------------------------------------------------------------------------
      Author	&
Ver#   Peer Reviewer   Request #        Broad-Use MODULE History Description
----  ---------------- ---------------- ----------------------------------------
1.0   Gregory Steffens <BUM Request#>   Original version of the broad-use module
       <Peer Reviewer name>
  **eoh************************************************************************/
%ut_parmdef(data,_pdmacroname=thin2wide,_pdrequired=1)
%ut_parmdef(out,_pdmacroname=thin2wide,_pdrequired=1)
%ut_parmdef(mdlib,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(mdselect,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(mdexclude,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(mdprefix,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(pkeys,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(param_var,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(paramrel_vars,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(verbose,1,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(debug,0,_pdmacroname=thin2wide,_pdrequired=0)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt numkeys keys keynum numparams paramnum numprels prels else;
%ut_titlstrt
title&titlstrt "(thin2wide) Transforming tall-thin &data to short-wide &out";

%if %bquote(&mdselect) = %then %let mdselect = %upcase(&data);
%if %index(&mdselect,%str(.)) > 0 %then
 %let mdselect = %scan(&mdselect,2,%str(.));

%if %sysfunc(exist(&data)) %then %do;
  data _twdata;
    set &data;
  run;
%end;
%else %do;
  %ut_errmsg(msg="Input data set does not exist &data - "
   "terminating",macroname=thin2wide,type=warning)

  %if ^ &debug %then %goto endmac;
  data _twdata;
    stop;
  run;

%end;
%if %bquote(&mdlib) ^= %then %do;
  *============================================================================;
  * Metadata, so read columns and columns_param to get values of parameters;
  *  PKEYS PARAM_VAR and PARAMREL_VARS;
  *============================================================================;
  %mdmake(inlib=&mdlib,outlib=work,outprefix=_tw,contents=0,mode=replace,
   inprefix=&mdprefix,inselect=&mdselect,inexclude=&mdexclude,
   verbose=&verbose,debug=&debug)
  *----------------------------------------------------------------------------;
  * Determine list of primary key variables - metadata or PKEYS parameter;
  *----------------------------------------------------------------------------;
  %if %bquote(&pkeys) ^= %then
   %ut_errmsg(msg="MDLIB and PKEYS parameters were both specified - "
   "using metadata to define primary keys",macroname=thin2wide);
  proc sort data = _twcolumns (keep=table cpkey column where=(cpkey ^= .))
   out = _twpkeys;
    by table cpkey column;
  run;
  %let numkeys = 0;
  data _null_;
    if eof & cpkey_num > 0 then
     call symput('numkeys',trim(left(put(cpkey_num,32.0))));
    set _twpkeys end=eof;
    cpkey_num + 1;
    call symput('cpkey' || trim(left(put(cpkey_num,32.0))),trim(left(column)));
  run;
  %if &numkeys >= 1 %then %do;
    %let pkeys =;
    %do keynum = 1 %to &numkeys;
      %let pkeys = &pkeys &&cpkey&keynum;
    %end;
  %end;
  %else %do;
    %ut_errmsg(msg="no primary key variables specified in metadata",
     macroname=thin2wide)
    %if %bquote(&pkeys) ^= %then %ut_errmsg(
     msg="Using primary keys specified by PKEYS parameter",
     macroname=thin2wide);
    %else %do;
      %ut_errmsg(msg="Primary keys not defined in metadata or parameter - "
       "terminating",macroname=thin2wide)
      %goto endmac;
    %end;
  %end;
  *----------------------------------------------------------------------------;
  * Determine name of parameter variable - metadata or PARAM_VAR parameter;
  *----------------------------------------------------------------------------;
  %if %bquote(&param_var) ^= %then
   %ut_errmsg(msg="MDLIB and PARAM_VAR parameters were both specified - "
   "using metadata to define parameter variable",macroname=thin2wide);
  %let numparams = 0;
  data _null_;
    if eof & param_num > 0 then
     call symput('numparams',trim(left(put(param_num,32.0))));
    set _twcolumns_param (keep=table column) end=eof;
    by table column;
    if first.column & column ^= ' ';
    param_num + 1;
    call symput('param' || trim(left(put(param_num,32.0))),trim(left(column)));
  run;
  %if &numparams = 1 %then %let param_var = &param1;
  %else %do;
    %if &numparams < 1 %then %do;
      %ut_errmsg(msg="no parameter variable found in metadata",
       macroname=thin2wide)
    %end;
    %else %if &numparams > 1 %then %do;
      %ut_errmsg(msg="Multiple parameter variables found in metadata - "
       "(&numparams found)",macroname=thin2wide,type=warning)
      %do paramnum = 1 %to &numparams;
        %put param&paramnum &&param&paramnum;
      %end;
    %end;
    %if %bquote(&param_var) ^= %then
     %ut_errmsg(msg="Using parameter variable specified by PARAM_VAR parameter",
      macroname=thin2wide);
    %else %do;
      %ut_errmsg(msg="PARAM_VAR not able to be determined by metadata or "
       "parameter - terminating",macroname=thin2wide)
      %goto endmac;
    %end;
  %end;
  *----------------------------------------------------------------------------;
  * Determine list of parameter related variables - PARAMREL_VARS parameter;
  *----------------------------------------------------------------------------;
  %if %bquote(&paramrel_vars) ^= %then
   %ut_errmsg(msg="MDLIB and PARAMREL_VARS parameters were both specified - "
   "using metadata to define parameter related variables, PARAMREL_VARS",
   macroname=thin2wide);

  proc sort data = _twcolumns_param;
    by table column paramrel;
  run;
  %let numparamrels = 0;
  data _null_;
    if eof then do;
      if paramrel_num > 0 then
       call symput('numparamrels',trim(left(put(paramrel_num,32.0))));
    end;
    set _twcolumns_param (keep=table column paramrel) end=eof;
    by table column paramrel;
    if paramrel ^= ' ';
    if first.paramrel then do;
      paramrel_num + 1;
      call symput('paramrel' || trim(left(put(paramrel_num,32.0))),
       trim(left(paramrel)));
    end;
  run;
  %if &numparamrels >= 1 %then %do;
    %let paramrel_vars =;
    %do paramrelnum = 1 %to &numparamrels;
      %let paramrel_vars = &paramrel_vars &&paramrel&paramrelnum;
    %end;
  %end;
  %else %do;
    %ut_errmsg(msg="no paramrel variables found in metadata",
     macroname=thin2wide)
    %if %bquote(&paramrel_vars) ^= %then %ut_errmsg(
     msg="Using parameter related variables specified by PARAMREL_VARS "
     "parameter",macroname=thin2wide);
    %else %do;
      %ut_errmsg(msg="Parameter related variables  not defined in metadata or "
       "parameter - terminating",macroname=thin2wide)
      %goto endmac;
    %end;
  %end;

  *----------------------------------------------------------------------------;
  * Flag paramrelcols that should not be created - they have a values list;
  *  that contains only the missing value;
  *----------------------------------------------------------------------------;
  proc sort data = _twvalues;
    by format start;
  run;
  data _twmissformats;
    set _twvalues;
    by format start;
    if first.format + last.format = 2 & start = ' ' & flabel = ' ' &
     flabellong = ' ';
    keep format;
  run;
  proc sort data = _twcolumns_param;
    by pformat;
  run;
  data _twcolumns_param;
    merge _twcolumns_param (in=fromcp)
          _twmissformats (in=frommiss rename=(format=pformat));
    by pformat;
    if fromcp;
    if frommiss then paramrelcol_create = 0;
    else paramrelcol_create = 1;
  run;
  %if &debug %then %do;
    proc print data = _twmissformats width=minimum;
      title%eval(&titlstrt + 1)
       "(thin2wide debug) Formats that include only the missing value";
    run;
  %end;
  proc print data = _twcolumns_param (where = (paramrelcol_create = 0)) noobs
   width=minimum;
    id table column;
    title%eval(&titlstrt + 1) "(thin2wide) Variables not created in &out";
    title%eval(&titlstrt + 2) "(thin2wide) because they are associated with "
     "values that have only missing as a valid value";
    var param paramrel paramrelcol pformat;
  run;
  title%eval(&titlstrt + 1);

%end;    /* MDLIB not null */
%else %if %bquote(&param_var) ^= & %bquote(&paramrel_vars) ^= %then %do;
  *============================================================================;
  * No metadata, so build columns_param from param_var and paramrel_vars;
  *  parameters;
  *============================================================================;

%* 
  maybe add this do loop section to mdbuild macro instead to build columns_param

  also support user defining columns_param table column paramrel paramrelcol
   but no param values and then get param values from DATA
;

  %ut_marray(invar=paramrel_vars,outvar=prel,outnum=numprels,varlist=prels)
  %local &prels;
  %ut_marray(invar=paramrel_vars,outvar=prel,outnum=numprels)
  *----------------------------------------------------------------------------;
  * Find type and length of params for each param_var and paramrel_vars value;
  *----------------------------------------------------------------------------;
  proc sort data = _twdata (keep=&param_var
   %do prelnum = 1 %to &numprels;
     &&prel&prelnum
   %end;
   ) out = _twparamvallist  nodupkey;

    by &param_var
     %do prelnum = 1 %to &numprels;
       &&prel&prelnum
     %end;
    ;

  run;
  data _twtype_length;
    length table column param paramrel $ 32  ptype $ 1  plength 8;
    set _twparamvallist end=eof;

    by &param_var
     %do prelnum = 1 %to &numprels;
       &&prel&prelnum
     %end;
    ;

    if first.&param_var then do;
      %do prelnum = 1 %to &numprels;
        _twt&prelnum = ' ';
        _twl&prelnum = .;
      %end;
    end;
    %do prelnum = 1 %to &numprels;    
      if verify(&&prel&prelnum,'0123456789.') then _twt&prelnum = 'C';
      if length(&&prel&prelnum) > _twl&prelnum then
       _twl&prelnum = length(&&prel&prelnum);
    %end;
    if last.&param_var then do;
      table = "&mdselect";
      column = upcase("&param_var");
      param = &param_var;
      %do prelnum = 1 %to &numprels;    
        paramrel = upcase("&&prel&prelnum");
        if _twt&prelnum = 'C' then do;
          ptype = 'C';
          plength = _twl&prelnum;
        end;
        else do;
          ptype = 'N';
          plength = 8;
        end;
        output;
      %end;
    end;
    retain
     %do prelnum = 1 %to &numprels;
       _twt&prelnum _twl&prelnum
     %end;
    ;
    keep table column param paramrel ptype plength;
  run;
  proc sort data = _twtype_length;
    by table column param paramrel;
  run;
  *----------------------------------------------------------------------------;
  * Create a list of unique values in the parameter variable in DATA;
  *----------------------------------------------------------------------------;
  proc freq data = _twdata noprint;
    table &param_var / missing norow nocol nopercent out = _twparam_vals;
  run;
  *----------------------------------------------------------------------------;
  * Create columns_param metadata set except for PTYPE and PLENGTH from the;
  *  unique values in DATA;
  *----------------------------------------------------------------------------;
  data _twcp;
    length table column param paramrel paramrelcol $ 32 plabel $ 40
     pformat $ 13 pformatflag 8;
    set _twparam_vals;
    table = upcase("&mdselect");
    column = upcase("&param_var");
    param = &param_var;
    paramrelcol = ' ';
    plabel = ' ';
    pformat = ' ';
    pformatflag = .;
    %do prelnum = 1 %to &numprels;    
      paramrel = upcase("&&prel&prelnum");
      output;
    %end;
    keep table column param paramrel paramrelcol plabel pformat pformatflag;
  run;
  proc sort data = _twcp;
    by table column param paramrel;
  run;
  *----------------------------------------------------------------------------;
  * Merge the PTYPE and PLENGTH variables to the columns_param metadata set;
  *  and add a flag to create paramrelcol always;
  *----------------------------------------------------------------------------;
  data _twcolumns_param;
    merge _twcp (in=fromcp)  _twtype_length (in=fromtl);
    by table column param paramrel;
    if ^ (fromcp & fromtl) then put 'Merge mismatch' / _all_ //;
    paramrelcol_create = 1;
  run;
  %if &debug %then %do;
    proc print data = _twcolumns_param width=minimum;
      title%eval(&titlstrt + 1) "(thin2wide) columns_param build from &data";
    run;
    title%eval(&titlstrt + 1);
  %end;

%end;

*==============================================================================;
* Create parallel arrays of:;
*     param        : Each parameter value - unique values of the PARAM_VAR;
*                     variable in DATA;
*     paramrel_n   : The number of paramrel variables associated with the;
*                     current param value and the number of associated arrays;
*                     describing each paramrelcol variable for each param;
* Create the associated arrays for each element in param array of:;
*     paramrel     : Name of parameter related variable
*     paramrelcol  : Name of variable in the output short-wide data set
*     ptype        : Type (numeric|character) of the output data set variable
*                     named by paramrelcol;
*     plength      : Length of output data set variable named by paramrelcol;
*     plabel       : Label of output data set variable named by paramrelcol;
*     pformat      : format associated with output data set variable named;
*                     by paramrelcol;
*==============================================================================;
proc sort data = _twcolumns_param;
  by table column param paramrel;
run;
%let numparamvals = 0;
data _null_;
  if eof then do;
    if paramval_num > 0 then
     call symput('numparamvals',trim(left(put(paramval_num,32.0))));
  end;
  set _twcolumns_param (keep=table column paramrel param paramrelcol ptype
   plength plabel pformat pformatflag paramrelcol_create
   where = (paramrelcol_create ^= 0)) end=eof;
  by table column param paramrel;
  if paramrel ^= ' ' & paramrelcol_create ^= 0;
  if first.param then do;
    paramval_num + 1;
    call symput('paramval' || trim(left(put(paramval_num,32.0))),
     trim(left(param)));
    paramrel_num = 0;
  end;
  if first.paramrel then do;
    paramrel_num + 1;
    call symput('paramrel' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),
     trim(left(paramrel)));
    if paramrelcol = ' ' then do;
      if (length(trim(left(paramrel))) + 1 + length(compress(param)) <= 32) &
       param ^= ' ' then
       paramrelcol = trim(left(paramrel)) || '_' || compress(param);
      else if length(trim(left(paramrel))) +
       length(trim(left(put(paramval_num,32.0)))) <= 32 then
       paramrelcol = trim(left(paramrel)) || trim(left(put(paramval_num,32.0)));
      else do;
        paramrelcol_id + 1;
        paramrelcol = 'PARAMRELCOL' || trim(left(put(paramrelcol_id,32.0)));
      end;
    end;
    call symput('paramrelcol' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),
     trim(left(paramrelcol)));
    if upcase(ptype) = 'N' then
     call symput('ptype' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),
     trim(left(' ')));
    else call symput('ptype' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),
     trim(left('$')));

    if plength <= 0 & ptype = 'N' then plength = 8;
%* or plength > 8;

    call symput('plength' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),
     trim(left(put(plength,32.0))));
    if plabel = ' ' then 
     plabel = "&param_var" || ' ' || param;
    call symput('plabel' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),
     trim(left(compress(plabel,'"'))));
    if pformatflag = 1 then do;
      if index(pformat,'.') > 0 then
       call symput('pformat' || trim(left(put(paramval_num,32.0))) || '_' ||
       trim(left(put(paramrel_num,32.0))),
       trim(left(pformat)));
      else
       call symput('pformat' || trim(left(put(paramval_num,32.0))) || '_' ||
       trim(left(put(paramrel_num,32.0))),
       trim(left(pformat)) || '.');
    end;
    else call symput('pformat' || trim(left(put(paramval_num,32.0))) || '_' ||
     trim(left(put(paramrel_num,32.0))),' ');
  end;
  if last.param then 
   call symput('paramrel_n' || trim(left(put(paramval_num,32.0))),
   trim(left(put(paramrel_num,32.0))));
run;

%* add checks of parameter vars - 
     param_var has only one variable
     pkeys not null
     paramrel_vars not null
     mvar array elements not null (except pformat)
     etc.
;

%*---------------------------------------------------------------------------;
%* If PARAM_VAR was also specified as a PKEYS then take it out of the;
%*  PKEYS primary key list;
%*---------------------------------------------------------------------------;
%if %bquote(&pkeys) ^= %then %do;
  %ut_marray(invar=pkeys,outvar=cpkey,outnum=numkeys,varlist=keys)
  %local &keys;
  %ut_marray(invar=pkeys,outvar=cpkey,outnum=numkeys)
  %do keynum = 1 %to &numkeys;
    %if &&cpkey&keynum = &param_var %then %do;
      %do newkeynum = &keynum %to &numkeys;
        %if &newkeynum ^= &numkeys %then %do;
          %let newnextkeynum = %eval(&newkeynum + 1);
          %let cpkey&newkeynum = &&cpkey&newnextkeynum;
        %end;
        %else %do;
          %let cpkey&newkeynum =;
          %let newnumkeys = %eval(&numkeys - 1);
        %end;
      %end;
      %let numkeys = &newnumkeys;
    %end;
  %end;
%end;
%else %let numkeys = 0;
*----------------------------------------------------------------------------;
* Get type of the param_var variable;
*----------------------------------------------------------------------------;
%if %bquote(&mdlib) ^= %then %do;
  data _null_;
    set _twcolumns (where = (table = "%upcase(&mdselect)" &
     column = "%upcase(&param_var)"));
    call symput('param_var_type',trim(left(ctype)));
  run;
%end;
%else %do;
  proc contents data = _twdata  out=_twcontents  noprint;
  run;
  data _null_;
    set _twcontents (where = (upcase(name) = upcase("&param_var")));
    if type = 1 then call symput('param_var_type','N');
    else call symput('param_var_type','C');
  run;
%end;
%if &debug %then %do;
  %*---------------------------------------------------------------------------;
  %* Print the parameters and arrays to the log file when debug mode is on;
  %*---------------------------------------------------------------------------;
  %ut_errmsg(msg=pkeys=&pkeys,macroname=thin2wide,print=0)
  %ut_errmsg(msg=param_var=&param_var,macroname=thin2wide,print=0)
  %ut_errmsg(msg=paramrel_vars=&paramrel_vars,macroname=thin2wide,print=0)
  %ut_errmsg(msg=numparamvals=&numparamvals,macroname=thin2wide,print=0)
  %do paramvalnum = 1 %to &numparamvals;
    %put paramval&paramvalnum=&&paramval&paramvalnum;
    %put paramrel_n&paramvalnum=&&paramrel_n&paramvalnum;
    %put;
    %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
      %put paramrel&paramvalnum._&paramrelnum=&&paramrel&paramvalnum._&paramrelnum;
      %put paramrelcol&paramvalnum._&paramrelnum=&&paramrelcol&paramvalnum._&paramrelnum;
      %put ptype&paramvalnum._&paramrelnum=&&ptype&paramvalnum._&paramrelnum;
      %put plength&paramvalnum._&paramrelnum=&&plength&paramvalnum._&paramrelnum;
      %put plabel&paramvalnum._&paramrelnum=&&plabel&paramvalnum._&paramrelnum;
      %put pformat&paramvalnum._&paramrelnum=&&pformat&paramvalnum._&paramrelnum;
      %put;
    %end;
    %put ======================================================================;
  %end; 
%end;
*==============================================================================;
* Sort the input data set;
*==============================================================================;
proc sort data = _twdata;
  by
   %do keynum = 1 %to &numkeys;
     &&cpkey&keynum
   %end;
   &param_var
  ;
run;
*==============================================================================;
* Create the output data set;
*==============================================================================;
data &out (label="Short-wide transformation of &data"
           drop= &param_var
           %do paramrelnum = 1 %to &numparamrels;
             &&paramrel&paramrelnum
           %end; )
     _twduplicates (keep = 
           %do keynum = 1 %to &numkeys;
             &&cpkey&keynum
           %end;
           &param_var)
     _twvalues_not_in_md (keep = 
           %do keynum = 1 %to &numkeys;
             &&cpkey&keynum
           %end;
           &param_var
           %do paramrelnum = 1 %to &numparamrels;
             &&paramrel&paramrelnum
           %end;
           )
;
  set _twdata;
  by
   %do keynum = 1 %to &numkeys;
     &&cpkey&keynum
   %end;
   &param_var
  ;
  if first.&param_var + last.&param_var ^= 2 then output _twduplicates;
  *----------------------------------------------------------------------------;
  * Declare length and type of paramrelcol variables;
  *----------------------------------------------------------------------------;
  length
   %do paramvalnum = 1 %to &numparamvals;
     %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
       %if %bquote(&&plength&paramvalnum._&paramrelnum) ^= %then %do;
         &&paramrelcol&paramvalnum._&paramrelnum &&ptype&paramvalnum._&paramrelnum
         &&plength&paramvalnum._&paramrelnum
       %end;
     %end;
   %end;
  ;
  *----------------------------------------------------------------------------;
  * Initialize paramrelcol variables to missing;
  *----------------------------------------------------------------------------;
  if first.&&cpkey&numkeys then do;
    %do paramvalnum = 1 %to &numparamvals;
      %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
        %if %bquote(&&paramrelcol&paramvalnum._&paramrelnum) ^= %then %do;
          %if &&ptype&paramvalnum._&paramrelnum = $ %then %do;
            &&paramrelcol&paramvalnum._&paramrelnum = ' ';
          %end;
          %else %do;
            &&paramrelcol&paramvalnum._&paramrelnum = .;
          %end;
        %end;
      %end;
    %end;
  end;
  *----------------------------------------------------------------------------;
  *Assign paramrelcol variable a value from the corresponding paramrel variable;
  *----------------------------------------------------------------------------;
  %let else =;
  %do paramvalnum = 1 %to &numparamvals;
    %if %bquote(&param_var) ^= %then %do;
      *........................................................................;
      %bquote(* &paramvalnum Processing parameter variable value &&paramval&paramvalnum;)
      *........................................................................;
      &else if &param_var =
       %if &param_var_type = C %then %do;
         "&&paramval&paramvalnum"
       %end;
       %else %do;
         &&paramval&paramvalnum
       %end;
       then do;
         %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
           %if %bquote(&&paramrelcol&paramvalnum._&paramrelnum) ^= &
            %bquote(&&paramrel&paramvalnum._&paramrelnum) ^=
            %then %do;
              &&paramrelcol&paramvalnum._&paramrelnum =
               &&paramrel&paramvalnum._&paramrelnum;
           %end;
         %end;
       end;
       %let else = else;
    %end;
  %end;
  *........................................................................;
  * Unexpected parameter variable values;
  *........................................................................;
  &else output _twvalues_not_in_md;
  *----------------------------------------------------------------------------;
  * Output an observation when all paramrelcol variable have been assigned a;
  *  value within the PARAMREL by group;
  *----------------------------------------------------------------------------;
  if last.&&cpkey&numkeys then output &out;
  *----------------------------------------------------------------------------;
  * Retain paramrelcol variable values;
  *----------------------------------------------------------------------------;
  retain
   %do paramvalnum = 1 %to &numparamvals;
     %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
       &&paramrelcol&paramvalnum._&paramrelnum
     %end;
   %end;
  ;
  *----------------------------------------------------------------------------;
  * Assign labels to paramrelcol variables;
  *----------------------------------------------------------------------------;
  label
   %do paramvalnum = 1 %to &numparamvals;
     %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
       %if %bquote(&&paramrelcol&paramvalnum._&paramrelnum) ^= &
        %bquote(&&plabel&paramvalnum._&paramrelnum) ^= 
        %then %do;
        &&paramrelcol&paramvalnum._&paramrelnum =
        "&&plabel&paramvalnum._&paramrelnum"
       %end;
     %end;
   %end;
  ;
  *----------------------------------------------------------------------------;
  * Assign formats to paramrelcol variables;
  *----------------------------------------------------------------------------;
  format
   %do paramvalnum = 1 %to &numparamvals;
     %do paramrelnum = 1 %to &&paramrel_n&paramvalnum;
       %if %bquote(&&pformat&paramvalnum._&paramrelnum) ^= %then %do;
        &&paramrelcol&paramvalnum._&paramrelnum &&pformat&paramvalnum._&paramrelnum
       %end;
     %end;
   %end;
  ;
run;
proc print data = _twduplicates width=minimum;
  title%eval(&titlstrt + 1) "(thin2wide) Duplicate observations found - "
   "this causes problems with the transpose";
run;
proc print data = _twvalues_not_in_md width=minimum;
  title%eval(&titlstrt + 1)
   "(thin2wide) Paramrel variable values not" " found in the metadata - "
   "this causes problems with the transpose";
run;
title%eval(&titlstrt + 1);
*==============================================================================;
* Cleanup at end of thin2wide macro;
*==============================================================================;
%endmac:
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _tw: / memtype=data;
    %if %bquote(&mdlib) ^= %then %do;
      delete _tw: / memtype=catalog;
    %end;
  run; quit;
%end;
title&titlstrt;
%mend;
