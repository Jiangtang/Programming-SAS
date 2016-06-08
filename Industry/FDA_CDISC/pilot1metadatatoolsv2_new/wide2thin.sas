%macro wide2thin(data=_default_,out=_default_,
 mdlib=_default_,mdprefix=_default_,mdselect=_default_,
 param_var=_default_,paramrelmap=_default_,verbose=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME   : wide2thin
TYPE                    : data transformation
DESCRIPTION             : Transforms a short-wide (horizontal) data set into a
                           tall-thin (vertical) data set.  For example vitals
                           into an observat data set.  It can be driven by
                           metadata (preferred) or by a set of macro parameters.
DOCUMENT LIST           : \\spreeprd\genesis\SPREE\QA\
SOFTWARE/VERSION#       : SAS/Version 8 and 9
INFRASTRUCTURE          : MS Windows, MVS, Unix, SDD
BROAD-USE MODULES       : ut_parmdef ut_logical ut_marray
INPUT                   : As defined by the DATA MDLIB and MDPREFIX parameters
OUTPUT                  : As defined by the OUT parameter
VALIDATION LEVEL        : 6
REGULATORY STATUS       : GCP
TEMPORARY OBJECT PREFIX : _wt
--------------------------------------------------------------------------------
Parameters:
Name        Type     Default    Description and Valid Values
----------- -------- ---------- ------------------------------------------------
DATA        required            The name of the input data set that is in a
                                 short-wide (horizontal) structure
OUT         required            The name of the output data set that will be
                                 created in a tall-thin (vertical) structure
MDLIB       optional            The libref where metadata resides
MDPREFIX    optional            The prefix of the metadata members in MDLIB
MDSELECT    optional DATA       
PARAM_VAR   optional            The name of the output parameter variable
PARAMRELMAP optional            A map of paramrelcol to its paramrelvars
          inparamvar1: outparamrel1 inparamrelcol1 outparamrel2 inparamrelcol2 |
          inparamvar2: outparamrel1 inparamrelcol3 outparamrel2 inparamrelcol4 |
                                 where 
                                 INPARAMVARn    name of variable in input data
                                                set whose name becomes a value
                                                of PARAM_VAR in the output data
                                                set.  This variable is dropped
                                                when creating OUT.  Its value
                                                is assigned to the variable
                                                specified by one of the
                                                following variable pairs.
                                 OUTPARAMRELn   Name of output data set paramrel
                                                variable for the current value
                                                of INPARAMVARn. This variable is
                                                added when creating OUT and gets
                                                it value from INPARAMRECOLn.
                                 INPARAMRELCOLn Name of the input data set
                                                paramrelcol variable whose
                                                value is mapped to the 
                                                corresponding OUTPARAMRELn.
                                                This variable is dropped when
                                                creating OUT.
VERBOSE     required 1          %ut_logical value specifying whether verbose
                                 mode is on or off
DEBUG       required 0          %ut_logical value specfifying whether debug
                                 mode is on or off
--------------------------------------------------------------------------------
Usage Notes:

--------------------------------------------------------------------------------
Assumptions:

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

--------------------------------------------------------------------------------
     Author &
Ver#  Peer Reviewer   Request #        Broad-Use Module History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMR              Original version of the broad-use module
  **eoh************************************************************************/
%ut_parmdef(data,_pdmacroname=thin2wide,_pdrequired=1)
%ut_parmdef(out,_pdmacroname=thin2wide,_pdrequired=1)
%ut_parmdef(mdlib,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(mdprefix,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(mdselect,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(param_var,parameter,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(paramrelmap,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(verbose,1,_pdmacroname=thin2wide,_pdrequired=0)
%ut_parmdef(debug,0,_pdmacroname=thin2wide,_pdrequired=0)
%ut_logical(verbose)
%ut_logical(debug)
%local titlstrt paramnum numparams params resultc_length numparamrelcol
 paramrelcol_num;
%ut_titlstrt
title&titlstrt "(thin2wide) Transforming short-wide &data to tall-thin &out";

%if %bquote(&mdselect) = %then %let mdselect = %upcase(&data);
%if %index(&mdselect,%str(.)) > 0 %then
 %let mdselect = %scan(&mdselect,2,%str(.));

%if %sysfunc(exist(&data)) %then %do;
  data _wtdata;
    set &data;
  run;
%end;
%else %do;
  %ut_errmsg(msg="Input data set does not exist &data - "
   "terminating",macroname=thin2wide,type=warning)
  %if    ^    &debug %then %goto endmac;
  data _wtdata;
    stop;
  run;
%end;
*==============================================================================;
* Create parallel arrays of macro variables;
* ;
* PARAM       : names of the input parameter variables PARAM_VARS that become;
*               values of the output PARAM_VAR variable;
* PRELCOLS_N  : number of elements in the PARAMREL and PARAMRELCOL arrays for
*               the current element in the PARAM array;
* ;
* For each element in the PARAM array create two 2-dimensional arrays of:;
* PARAMREL    : name of the parameter related variable;
* PARAMRELCOL : name of the paramrelcol variable corresponding to paramrel;
* ;
* Create separate parallel arrays of PARAMREL variable attributes;
* PREL       - Name   of PARAMREL variable in output data set;
* PREL_LABEL - Label  of PARAMREL variable in output data set;
* PREL_TYPE  - Type   of PARAMREL variable in output data set;
* PREL_LEN   - Length of PARAMREL variable in output data set;
* PREL_FMT   - Format of PARAMREL variable in output data set;
*==============================================================================;
%if %bquote(&mdlib) ^= %then %do;
  *============================================================================;
  * Read metadata by calling the mdmake macro;
  *============================================================================;
  %mdmake(inlib=&mdlib,inprefix=&mdprefix,outlib=work,outprefix=_wt,
   mode=replace,inselect=&mdselect,contents=0,verbose=&verbose,debug=&debug)
  *============================================================================;
  * Put parameter variable name in macro variable PARAM_VAR;
  *============================================================================;
  %let numparams = 0;
  data _null_;
    if eof then do;
      if param_num > 0 then
       call symput('numparams',trim(left(put(param_num,32.0))));
    end;
    set _wtcolumns_param end=eof;
    by table column param paramrel;
    if first.column then do;
      if _n_ ^= 1 then do;
        %ut_errmsg(msg="wide2thin supports only one parameter variable but "
         "&mdselect defines more than one " column=,type=warning,
         macroname=wide2thin)
        stop;
      end;
      call symput('param_var',trim(left(upcase(column))));
    end;
    if first.param then do;
      param_num + 1;
      call symput('param' || trim(left(put(param_num,32.0))),trim(left(param)));
      paramrelcol_num = 0;
    end;
    paramrelcol_num + 1;
    call symput('paramrel' || trim(left(put(param_num,32.0))) || '_' ||
     trim(left(put(paramrelcol_num,32.0))),trim(left(paramrel)));
    call symput('paramrelcol' || trim(left(put(param_num,32.0))) || '_' ||
     trim(left(put(paramrelcol_num,32.0))),trim(left(paramrelcol)));
    if last.param then
     call symput('prelcols_n' || trim(left(put(param_num,32.0))),
     trim(left(put(paramrelcol_num,32.0))));
  run;
  proc sort data = _wtcolumns_param (keep=table paramrel)
            out = _wtprels (rename=(paramrel=column)) nodupkey;
    by paramrel;
  run;
  %let numparamrels = 0;
  data _null_;
    if eof & paramrel_num > 0 then
     call symput('numparamrels',trim(left(put(paramrel_num,32.0))));
    merge _wtcolumns (in=fromcol)  _wtprels (in=fromprel)  end=eof;
    by table column;
    if fromprel;
    if ^ fromcol then put 'Variable defined as PARAM_REL not"
     " found in COLUMNS ' / _all_ //;
    if fromcol;
    paramrel_num + 1;
    call symput('prel' || trim(left(put(paramrel_num,32.0))),
     trim(left(column)));
    call symput('prel_label' || trim(left(put(paramrel_num,32.0))),
     trim(left(compress(clabel,'"'))));
    if upcase(ctype) = 'N' then
     call symput('prel_type' || trim(left(put(paramrel_num,32.0))),'');
    else call symput('prel_type' || trim(left(put(paramrel_num,32.0))),'$');
    if clength > 0 then
     call symput('prel_len' || trim(left(put(paramrel_num,32.0))),
     trim(left(put(clength,32.0))));
    else call symput('prel_len' || trim(left(put(paramrel_num,32.0))),'');
    if cformatflag = 1 then do;
      if index(cformat,'.') > 0 then
       call symput('prel_fmt' || trim(left(put(paramrel_num,32.0))),
       trim(left(cformat)));
      else
       call symput('prel_fmt' || trim(left(put(paramrel_num,32.0))),
       trim(left(cformat)) || '.');
    end;
    else do;
      call symput('prel_fmt' || trim(left(put(paramrel_num,32.0))),'');
    end;
  run;
%end;
%else %do;

  %* 
  Parse list of parameter variables in DATA followed by a colon and then by
  a list of couples of parameter-related variable in OUT and paramrelcol in DATA
  followed by a verticl bar  there can be any number of bar-delimted strings
        inparamvar1: paramrel1 paramrelcol1 paramrel2 paramrelcol2 |
  After parsing, create the macro variable arrays as described above - the rest
  of the macro is not different for metadata as compared to paramters
  ;

  %local done_with_vertbar vertbar_token param_maps colon_n done_with_colon;
  %if %bquote(&paramrelmap) ^= %then %do;
    %let numparams = 1;
    %let done_with_vertbar = 0;
    %do %until (&done_with_vertbar);
      %let vertbar_token = %scan(&paramrelmap,&numparams,%str(|));
      %if %bquote(&vertbar_token) ^= %then %do;
        %local param&numparams prelcols_n&numparams;
        %let param&numparams = %scan(&vertbar_token,1,%str(:));
        %if &debug %then %put (wide2thin) param&numparams=&&param&numparams;
        %let param_maps = %scan(&vertbar_token,2,%str(:));
        %let prelcols_n&numparams = 1;
        %let colon_n = 1;
        %let done_with_colon = 0;
        %do %until (&done_with_colon);
          %if %bquote(%scan(&param_maps,&colon_n,%str( ))) ^= %then %do;
            %local paramrel&numparams._&&prelcols_n&numparams 
             paramrelcol&numparams._&&prelcols_n&numparams;
            %let paramrel&numparams._&&prelcols_n&numparams =
             %scan(&param_maps,&colon_n,%str( ));
            %let paramrelcol&numparams._&&prelcols_n&numparams =
             %scan(&param_maps,%eval(&colon_n + 1),%str( ));
            %if &debug %then %do;
              %put (wide2thin) paramrel&numparams._&&prelcols_n&numparams=&&&&paramrel&numparams._&&prelcols_n&numparams;
              %put (wide2thin) paramrelcol&numparams._&&prelcols_n&numparams=&&&&paramrelcol&numparams._&&prelcols_n&numparams;
            %end;
            %let prelcols_n&numparams = %eval(&&prelcols_n&numparams + 1);
            %let colon_n = %eval(&colon_n + 2);
          %end;  %* there is a paramrel paramrelcol pair;
          %else %do;
            %let done_with_colon = 1;
            %let prelcols_n&numparams = %eval(&&prelcols_n&numparams - 1);
          %end;
        %end;    %* do until done_with_colon;
        %if &debug %then %put (wide2thin) prelcols_n&numparams=&&prelcols_n&numparams  colon_n=&colon_n;
        %let numparams = %eval(&numparams + 1);
      %end;      %* vertbar_token not null;
      %else %do;
        %let done_with_vertbar = 1;
        %let numparams = %eval(&numparams - 1);
      %end;
     %end;       %* do until done_with_vertbar;
  %end;          %* paramrelmap not null;
  %if &debug %then %put (wide2thin) numparams=&numparams;

%* Now get the name label type length format of the paramrel variables from the
   attributes of the paramrelcol variables and put in the prel arrays
   proc contents DATA
   keep obs for paramrelcol variables
   map to paramrel variables
   evaluate paramrelcol attributes within each paramrel group of variables
;
%let numparamrels = 0;

%end;

%if &debug    | ^ &debug    %then %do;

  %put (wide2thin) numparams=&numparams;
  %put;
  %do paramnum = 1 %to &numparams;
    %put (wide2thin) param&paramnum=&&param&paramnum prelcols_n&paramnum=&&prelcols_n&paramnum;
    %put;
    %do paramrelcol_num = 1 %to &&prelcols_n&paramnum;
      %put (wide2thin) paramrel&paramnum._&paramrelcol_num=&&paramrel&paramnum._&paramrelcol_num;
      %put (wide2thin) paramrelcol&paramnum._&paramrelcol_num=&&paramrelcol&paramnum._&paramrelcol_num;
      %put;
    %end;
    %put ......................................................................;
  %end;
  %put ========================================================================;
  %do paramrel_num = 1 %to &numparamrels;
    %put ......................................................................;
    %put (wide2thin) prel&paramrel_num=&&prel&paramrel_num;
    %put (wide2thin) prel_label&paramrel_num=&&prel_label&paramrel_num;
    %put (wide2thin) prel_type&paramrel_num=&&prel_type&paramrel_num;
    %put (wide2thin) prel_len&paramrel_num=&&prel_len&paramrel_num;
    %put (wide2thin) prel_fmt&paramrel_num=&&prel_fmt&paramrel_num;
    %put;
  %end;
%end;
*==============================================================================;
* Determine attributes of param_vars variables in input DATA;
*==============================================================================;
%do paramnum = 1 %to &numparams;
  %let param_type&paramnum =;
%end;
proc contents data = _wtdata  out=_wtcontents  noprint;
run;
%let resultc_length = 0;
data _null_;
  if eof & resultc_length > 0 then
   call symput('resultc_length',trim(left(put(resultc_length,32.0))));
  set _wtcontents end=eof;
  %do paramnum = 1 %to &numparams;
    if upcase(name) = "%upcase(&&param&paramnum)" then do;
      if type = 1 then call symput("param_type&paramnum",'N');
      else call symput("param_type&paramnum",'C');
      if type = 2 & length > resultc_length then resultc_length = length;
    end;
  %end;
  retain resultc_length;
run;
%*=============================================================================;
%* Determine maximum length of param_vars variable names;
%*=============================================================================;
%let param_length = 0;
%do paramnum = 1 %to &numparams;
  %if %length(&&param&paramnum) > &param_length %then
   %let param_length = %length(&&param&paramnum);
  %if &debug %then
   %put (wide2thin) &&param&paramnum %length(&&param&paramnum) param_length=&param_length;
%end;
*==============================================================================;
* Create the output data set;
*==============================================================================;
data &out (label="tall-thin transformation of &data");
  set _wtdata;

%* add length of paramrel vars;

  length 
   %if %bquote(&param_var) ^= & %bquote(&param_length) ^= %then %do;
     &param_var $ &param_length
   %end;
   %do paramrel_num = 1 %to &numparamrels;
     %if %bquote(&&prel&paramrel_num) ^= & &&prel_len&paramrel_num ^= %then %do;
       &&prel&paramrel_num &&prel_type&paramrel_num &&prel_len&paramrel_num
     %end;
   %end;
  ;
  %do paramnum = 1 %to &numparams;
    *..........................................................................;
    %bquote(* &paramnum Processing paramrel variable &&param&paramnum;)
    *..........................................................................;
    %if %bquote(&&param_type&paramnum) ^= %then %do;
      &param_var = "&&param&paramnum";
      %do paramrelcol_num = 1 %to &&prelcols_n&paramnum;
         &&paramrel&paramnum._&paramrelcol_num =
         &&paramrelcol&paramnum._&paramrelcol_num;
        drop &&paramrelcol&paramnum._&paramrelcol_num;
      %end;
    %end;
    %else %ut_errmsg(msg="parameter not" "  found &&param&paramnum",
     type=warning,macroname=wide2thin);
    output;
    *..........................................................................;
    * Initialize paramrel variables between parm values in case they dont all;
    *  exist for every param otherwise previouse paramrel values would be;
    *  retained to the next parm value;
    *..........................................................................;
    %do paramrel_num = 1 %to &numparamrels;
      call missing(&&prel&paramrel_num);
    %end;
  %end;
  *............................................................................;
  * Assign labels and formats to new paramrel output variables;
  *............................................................................;
  %do paramrel_num = 1 %to &numparamrels;
    %if %bquote(&&prel_label&paramrel_num) ^= %then %do;
      label &&prel&paramrel_num = "&&prel_label&paramrel_num";
    %end;
    %if %bquote(&&prel_fmt&paramrel_num) ^= %then %do;
      format &&prel&paramrel_num &&prel_fmt&paramrel_num;
    %end;
  %end;

run;
*==============================================================================;
* Cleanup at end of wide2thin macro;
*==============================================================================;
%endmac:
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _wt: / memtype=data;
    %if %bquote(&mdlib) ^= %then %do;
      delete _wt: / memtype=catalog;
    %end;
  run; quit;
%end;
title&titlstrt;
%mend;
