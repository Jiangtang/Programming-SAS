%macro mdcpput(table=_default_,paramvar=_default_,lmargin=_default_,
 html=_default_,htmlfile=_default_,htmlfileref=_default_,
 descriptions=_default_,values=_default_,labellong=_default_,
 userformats=_default_,maxvaluesobs=_default_,debug=_default_);
  /*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
BROAD-USE MODULE NAME    : mdcpput
TYPE                     : metadata
DESCRIPTION              : Print macro called from mdprint macro - do not use
                            mdcpput - it is only to support mdprint.
DOCUMENT LIST            : \\spreeprd\genesis\SPREE\QA\General\
                            Broad_use_modules\SAS\mdprint\mdprint-mdcpput DL.doc
SOFTWARE/VERSION#        : SAS/Version 8 and 9
INFRASTRUCTURE           : MS Windows, MVS, SDD
BROAD-USE MODULES        : ut_logical ut_parmdef ut_marray ut_errmsg
INPUT                    : As defined by the MDLIB parameter
OUTPUT                   : As defined by the optional HTMLFILE parameter
                            Otherwise the SAS listing file
VALIDATION LEVEL         : 6
REGULATORY STATUS        : GCP
TEMPORARY OBJECT PREFIX  : _mc
--------------------------------------------------------------------------------
Parameters:
 Name     Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
TABLE    required          Name of table to print metadata information about
PARAMVAR optional          Name of parameter variable to print metadata 
                            information about  - the value of the PARAM
                            variable in the columns_param metadata set
LMARGIN  required 0        Number of columns to allocate to the left margin
                            The printed report will be indented by this 
                            amount.
HTML     required 0        %ut_logical value specifying whether or not to
                            create an html file
HTMLFILE optional          Name of the html file to create when HTML is true
HTMLFILEREF optional       Fileref of the html file to create when HTML is
                            true
DESCRIPTIONS req  1        %ut_logical value specifying whether or not to 
                            print variable descriptions
VALUES   required 1        %ut_logical value specifying whether or not to
                            print variables valid values and code/decode
                            mappings
LABELLONG required 1       %ut_logical value specifying whether or not to
                            print the variable long label
USERFORMATS required 1     %ut_logical values specifing whether format names
                            where formatflag is 2, 3 or 4 will be printed
                            from the COLUMNS and COLUMNS_PARAM metadata.
MAXVALUESOBS optional max  Maximum number of observations in the VALUES to
                            print for each variable.  MAX means to print
                            all observations.  Otherwise specify an integer.
DEBUG    required 0        %ut_logical value specifying whether debug mode
                            is on or off
--------------------------------------------------------------------------------
Usage Notes: <Parameter dependencies and additional information for the user>

   This macro is called from the mdprint macro and is not meant to be used
   other than in that context.

--------------------------------------------------------------------------------
Assumptions: <Scope and preconditions>

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:

--------------------------------------------------------------------------------
     Author &
Ver#  Peer Reviewer   Request #        Broad-Use MODULE History Description
---- ---------------- ---------------- -----------------------------------------
1.0  Gregory Steffens BMRGCS23Apr2005A Original version of the broad-use module
1.1  Gregory Steffens BMRMSR20Feb2007C SAS version 9 migration
      Michael Fredericksen
2.0  Gregory Steffens BMR14Jan2008      Changed message from
      Russ Newhouse                      valid values for variable
                                         to
                                         valid values for parameter
                                         Changed USERFORMATS to recognize new
                                          values of c/pformatflag and suppresses
                                          the format names when these are 2, 3
                                          or 4 instead of just 2 or 3.
                                        Added HTMLFILEREF parameter (SDD needs
                                         this)
                                        Deleted blank lines when HTML is false
                                        Fixed issue where _NOMISS_ valid value
                                         printed both _NOMISS_ and Missing 
                                         value not allowed.  Now prints only
                                         Missing value not allowed.
  **eoh************************************************************************/
%ut_parmdef(table,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(paramvar,_pdmacroname=mdcpput)
%ut_parmdef(lmargin,0,_pdmacroname=mdcpput)
%ut_parmdef(html,0,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(htmlfile,_pdmacroname=mdcpput)
%ut_parmdef(htmlfileref,_pdmacroname=mdcpput)
%ut_parmdef(descriptions,1,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(values,1,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(labellong,1,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(userformats,1,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(maxvaluesobs,max,_pdrequired=1,_pdmacroname=mdcpput)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=mdcpput)
%ut_logical(html)
%ut_logical(descriptions)
%ut_logical(values)
%ut_logical(labellong)
%ut_logical(userformats)
%ut_logical(debug)
%local pc ls needls c1 c2 c3 c4 c5 c6 c7 c8 c9 c10 c11 c12 c13 c14  
 cvars cvarsl pkeylen nvars nvarsl varnum numcolumns columnnum
 numcvars cvararay numcvarsl numnvars nvararay numnvarsl cn
 numparamrel paramrelnum curparamrel
 hasstart hasend hasflabel hasflabellong colspan
 paramrel1 paramfmt1 curdesc curfmt outfile
;
%if %bquote(&htmlfileref) ^= %then %do;
  %let outfile = &htmlfileref;
  %if %bquote(&htmlfile) ^= %then
   %ut_errmsg(msg=Do not specify both HTMLFILE and HTMLFILEREF parameters -
   using htmlfileref = &htmlfileref,print=0,macroname=mdcpput);
%end;
%else %if %bquote(&htmlfile) ^= %then %do;
  %if %qsubstr(&htmlfile,1,1) ^= %str(%") & %qsubstr(&htmlfile,1,1) ^= %str(%')
   %then %let outfile = "&htmlfile";
  %else %let outfile = &htmlfile;
%end;
%if %bquote(&outfile) = & &html %then %do;
  %ut_errmsg(msg=HTMLFILE or HTMLFILEREF must be specified - ending macro 
   htmlfileref=&htmlfileref htmlfile=&htmlfile outfile=&outfile,print=0,
   macroname=mdcpput);
  %goto endmac;
%end;
*==============================================================================;
* Subset input data set (columns or columns_param);
*  based on whether PARAMVAR was specified. Set metavariable name prefix c/p;
* Create macro arrays col cparamfl fmt desc;
*==============================================================================;
%let numcolumns = 0;
%if %bquote(&paramvar) = %then %do;
  %let pc = c;
  data _mcindsn;
    set _mpcolumns   (where = (upcase(table) = "%upcase(&&table&tablenum)"));
    if cexist('work._mpdescriptions.' || trim(left(cdescription)) || '.source')
     then cdescription = cdescription;
    else if cexist('work._mpdescriptions.' || trim(left(column)) || '.source')
     then cdescription = column;
    else cdescription = ' ';
  run;
  proc sort data = _mcindsn out = _mcindsnsort;
    by table column;
  run;
  data _null_;
    if eof then do;
      if numcolumns > 0 then
       call symput('numcolumns',trim(left(put(numcolumns,8.0))));
    end;
    set _mcindsnsort  end=eof;
    by table column;
    if column = ' ' & hascolumns then
     put '(mdcpput) column name is mis' 'sing ' table= column= &pc.short=;
    if (column ^= ' ' | ^ hascolumns) & first.column;
    if column ^= ' ' then do;
      numcolumns + 1;
      call symput('col' || trim(left(put(numcolumns,8.0))),trim(column));
      call symput('cparamfl' || trim(left(put(numcolumns,8.0))),
       trim(left(put(cparamfl,2.0))));
      call symput('fmt' || trim(left(put(numcolumns,8.0))),trim(&pc.format));
      call symput('fmtfl' || trim(left(put(numcolumns,8.0))),
       trim(left(put(&pc.formatflag,32.0))));
      %if &descriptions %then %do;
        call symput('desc' || trim(left(put(numcolumns,8.0))),
         trim(&pc.description));
      %end;
      %else %do;
        call symput('desc' || trim(left(put(numcolumns,8.0))),'');
      %end;
    end;
  run;
%end;
%else %do;
  %let pc = p;
  data _mcindsn;
    set _mpcolumns_param (where = (upcase(table) = "%upcase(&&table&tablenum)" &
     upcase(column) = "%upcase(&paramvar)"));
    if cexist('work._mpdescriptions.' || trim(left(pdescription)) || '.source')
     then pdescription = pdescription;
    else if cexist('work._mpdescriptions.' || trim(left(paramrelcol)) ||
     '.source') then pdescription = paramrelcol;
    else pdescription = ' ';
  run;
  proc sort data = _mcindsn out = _mcindsnsort;
    by table column param paramrel;
  run;
  data _null_;
    if eof then do;
      if numcolumns > 0 then
       call symput('numcolumns',trim(left(put(numcolumns,8.0))));
    end;
    set _mcindsnsort  end=eof;
    by table column param;
    if column = ' ' then
     put '(mdcpput) column name is mis' 'sing ' table= column= &pc.short=;
    if column ^= ' ' & first.param;
    numcolumns + 1;
    call symput('col' || trim(left(put(numcolumns,8.0))),trim(param));
    call symput('cparamfl' || trim(left(put(numcolumns,8.0))),'0');
    call symput('fmt' || trim(left(put(numcolumns,8.0))),trim(&pc.format));
    call symput('fmtfl' || trim(left(put(numcolumns,8.0))),
     trim(left(put(&pc.formatflag,32.0))));
    %if &descriptions %then %do;
      call symput('desc' || trim(left(put(numcolumns,8.0))),
       trim(&pc.description));
    %end;
    %else %do;
      call symput('desc' || trim(left(put(numcolumns,8.0))),'');
    %end;
  run;
%end;
%if &debug %then %do columnnum = 1 %to &numcolumns;
  %ut_errmsg(msg=col&columnnum=&&col&columnnum
   cparamfl&columnnum=&&cparamfl&columnnum fmt&columnnum=&&fmt&columnnum
   fmtfl&columnnum=&&fmtfl&columnnum desc&columnnum=&&desc&columnnum,
   macroname=mdcpput,print=0)
%end;
*==============================================================================;
* Determine maximum print column lengths;
*==============================================================================;
%*=============================================================================;
%*   Create macro array of metadata set character variable names;
%*   and a parallel array of variable names holding max lengths of each;
%*=============================================================================;
%let cvars = table column &pc.short &pc.label &pc.labellong
 &pc.type &pc.format &pc.importance &pc.derivetype &pc.domain;
%let cvarsl = tablelen columnlen shortlen labellen labellonglen
 typelen formatlen importancelen derivetypelen domainlen;
%local &cvarsl column &pc.short &pc.label &pc.labellong
 &pc.type &pc.format &pc.importance &pc.derivetype &pc.domain;
%if %bquote(&paramvar) ^= %then %do;
  %let cvars = &cvars param paramrel paramrelcol;
  %let cvarsl = &cvarsl paramlen paramrellen paramrelcollen;
  %let pkeylen = 0;
%end;
%else %do;
  %local paramrel paramrelcol paramrellen paramrelcollen;
%end;
%ut_marray(invar=cvars,outvar=cvar,outnum=numcvars,varlist=cvararay)
%local &cvararay;
%ut_marray(invar=cvars,outvar=cvar,outnum=numcvars)
%ut_marray(invar=cvarsl,outvar=cvarl,outnum=numcvarsl,varlist=cvararay)
%local &cvararay;
%ut_marray(invar=cvarsl,outvar=cvarl,outnum=numcvarsl)
%*=============================================================================;
%*   Create macro array of metadata set numeric variable names;
%*   and a parallel array of variable names holding max lengths of each;
%*=============================================================================;
%let nvars = &pc.order &pc.length &pc.formatflag &pc.header;
%let nvarsl = orderlen lengthlen formatflaglen headerlen;
%if %bquote(&paramvar) = %then %do;
  %let nvars = &nvars cpkey;
  %let nvarsl = &nvarsl pkeylen;
%end;
%local &nvars &nvarsl;
%ut_marray(invar=nvars,outvar=nvar,outnum=numnvars,varlist=nvararay)
%local &nvararay;
%ut_marray(invar=nvars,outvar=nvar,outnum=numnvars)
%ut_marray(invar=nvarsl,outvar=nvarl,outnum=numnvarsl,varlist=nvararay)
%local &nvararay;
%ut_marray(invar=nvarsl,outvar=nvarl,outnum=numnvarsl)
*==============================================================================;
* Determine lengths of variable values;
*==============================================================================;
data _null_;
  if eof then do;
    %do varnum = 1 %to &numcvars;
      call symput("&&cvarl&varnum",trim(left(put(max(&&cvarl&varnum,0),3.0))));
      %if &debug %then %do;
        put "(mdcpput) cvar&varnum: &&cvar&varnum    cvarl&varnum: "
         &&cvarl&varnum=;
      %end;
    %end;
    %do varnum = 1 %to &numnvars;
      call symput("&&nvarl&varnum",trim(left(put(max(&&nvarl&varnum,0),3.0))));
      %if &debug %then %do;
        put "(mdcpput) nvar&varnum: &&nvar&varnum    nvarl&varnum: "
         &&nvarl&varnum=;
      %end;
    %end;
  end;
  set _mcindsn  end=eof;
  %if ^ &userformats %then %do;
    if &pc.format ^= ' ' & &pc.formatflag in (2 3 4) then do;
      &pc.format = ' ';
      &pc.formatflag = .;
    end;
  %end;
  if &pc.format =: '_PF' then do;
    &pc.format = ' ';
    &pc.formatflag = .;
  end;
  %do varnum = 1 %to &numcvars;
    if &&cvar&varnum ^= ' ' & length(&&cvar&varnum) > &&cvarl&varnum then
     &&cvarl&varnum = length(&&cvar&varnum);
  %end;
  %do varnum = 1 %to &numnvars;
    if &&nvar&varnum ^= . &
     length(trim(left(put(&&nvar&varnum,10.)))) > &&nvarl&varnum then
     &&nvarl&varnum = length(trim(left(put(&&nvar&varnum,10.))));
  %end;
  retain
   %do varnum = 1 %to &numcvars;
     &&cvarl&varnum
   %end;
   %do varnum = 1 %to &numnvars;
     &&nvarl&varnum
   %end;
  ;
run;
%if ^ &labellong %then %let labellonglen = 0;
%*                          COLUMNS to print:
   1 column/param    min=9
   2 paramrel        min=26
   3 short           min=9
   4 paramrelcol     min=28
   5 label           min=5
   6 pkey            min=3
   7 type            min=4
   8 length          min=6
   9 format          min=6
  10 formatflag      min=6
  11 importance      min=5
  12 domain          min=6
  13 header          min=6
  14 derivetype      min=9
 / 1 labellong       
;
%if ^ &html %then %do;
  %*---------------------------------------------------------------------------;
  %* Compute column pointer values;
  %*---------------------------------------------------------------------------;
  %let c1 = %eval(&lmargin + 1);
  %if %bquote(&paramvar) = %then %do;
    %let c2 = &c1;
    %if &columnlen > 0 %then
     %let c3  = %eval(&c2  + %sysfunc(max(&columnlen,8)) + 1);
    %else %let c3 = &c2;
    %let c4 = &c3;
    %if &shortlen > 0 %then
     %let c5  = %eval(&c4  + %sysfunc(max(&shortlen,9)) + 1);
    %else %let c5 = &c4;
  %end;
  %else %do;
    %if &paramlen > 0 %then
     %let c2  = %eval(&c1  + %sysfunc(max(&paramlen,9)) + 1);
    %else %let c2 = &c1;
    %if &paramrellen > 0 %then 
     %let c3 = %eval(&c2 + %sysfunc(max(&paramrellen,26)) + 1;
    %else %let c3 = &c2;
    %if &shortlen > 0 %then 
     %let c4 = %eval(&c3 + %sysfunc(max(&shortlen,9)) + 1;
    %else %let c4 = &c3;
   %if &paramrelcollen > 0 %then 
    %let c5 = %eval(&c4 + %sysfunc(max(&paramrelcollen,28)) + 1;
   %else %let c5 = &c4;
  %end;
  %if &labellen > 0 %then 
   %let c6 = %eval(&c5 + %sysfunc(max(&labellen,5)) + 1;
  %else %let c6 = &c5;
  %if &pkeylen > 0 %then
   %let c7  = %eval(&c6  + %sysfunc(max(&pkeylen,3)) + 1);
  %else %let c7 = &c6;
  %if &typelen > 0 %then 
   %let c8  = %eval(&c7  + %sysfunc(max(&typelen,4)) + 1);
  %else %let c8 = &c7;
  %if &lengthlen > 0 %then
   %let c9  = %eval(&c8  + %sysfunc(max(&lengthlen,6)) + 1);
  %else %let c9 = &c8;
  %if &formatlen > 0 %then
   %let c10  = %eval(&c9  + %sysfunc(max(&formatlen,6)) + 1);
  %else %let c10 = &c9;
  %if &formatflaglen > 0 %then 
   %let c11  = %eval(&c10  + %sysfunc(max(&formatflaglen,5)) + 1);
  %else %let c11 = &c10;
  %if &importancelen > 0 %then
   %let c12 = %eval(&c11 + %sysfunc(max(&importancelen,6)) + 1);
  %else %let c12 = &c11;
  %if &domainlen > 0 %then
   %let c13 = %eval(&c12 + %sysfunc(max(&domainlen,6)) + 1);
  %else %let c13 = &c12;
  %if &headerlen > 0 %then 
   %let c14 = %eval(&c13 + %sysfunc(max(&headerlen,6)) + 1);
  %else %let c14 = &c13;
  %if &debug %then %do cn = 1 %to 14;
    %ut_errmsg(msg=c&cn=&&c&cn,macroname=mdcpput,print=0)
  %end;
  %*---------------------------------------------------------------------------;
  %* compute minimum linesize and reset if necessary;
  %*---------------------------------------------------------------------------;
  %let ls = %sysfunc(getoption(linesize));
  %let needls = %eval(&c14 + %sysfunc(max(&derivetypelen,9)));
  %if &ls < &needls %then %do;
    %bquote(* increasing linesize from &ls to &needls because it cannot
     contain all columns;)
    options linesize = &needls;
  %end;
  %else %do;
    %ut_errmsg(
     msg=Current linesize of &ls not changed since &needls is required,
     type=note,macroname=mdcpput,print=0)
    %let ls =;
  %end;
%end;
%else %let c1 = 1;
*==============================================================================;
%if %bquote(&paramvar) = %then %do;
 %bquote(* Print list of columns in the current table &table;)
%end;
%else %do;
  %bquote(* Print list of parameter values for the current PARAM: &paramvar;)
%end;
*==============================================================================;
data _null_;
  set _mcindsn  end=eof;
  %if ^ &userformats %then %do;
    if &pc.format ^= ' ' & &pc.formatflag in (2 3 4) then do;
      &pc.format = ' ';
      &pc.formatflag = .;
    end;
  %end;
  if &pc.format =: '_PF' then do;
    &pc.format = ' ';
    &pc.formatflag = .;
  end;
  %if &html %then %do;
    file &outfile mod;
    if _n_ = 1 then put 
     '<p><br style="clear:left">'
     %if %bquote(&paramvar) = %then %do;
       '<a name="' table +(-1) '"> </a> '
       %if ^ &mult_html %then %do;
         "<a href=""#dsnlist""> back to list of data sets</a> "
       %end;
       %else %do;
         "<a href=""./&mult_file_prefix..html"">"
         "back to list of data sets</a>"
       %end;
     %end;
     %else %do;
       '<a name="' table +(-1) "&paramvar.param""> </a>"
       "<a href=""#&&table&tablenum""> back to data set &&table&tablenum</a> "
     %end;
     "</p>"
     "<table style=""float:left"" border "
     %if %bquote(&paramvar) = %then %do;
       "title=""&&table&tablenum Variables"">"
     %end;
     %else %do;
       "title=""&&table&tablenum Values of Parameter &paramvar"">"
     %end;
     '<tr>  <th colspan=14 align=center> '
     table ':' tlabel 
     %if %bquote(&paramvar) ^= %then %do;
       "  Parameter variable: &paramvar "
     %end;
     '</th> </tr>' /
     '<tr> ' 
     %if %bquote(&paramvar) = %then %do;
       '<th> Variable </th> '
     %end;
     %else %do;
       '<th> Parameter Value </th> '
       %if &paramrellen > 0 %then %do;
         '<th> Parameter Related Variable </th>'
       %end;
     %end;
     %if &shortlen > 0 %then %do;
       '<th> Short Name </th>'
     %end;
     %if %bquote(&paramvar) ^= & &paramrelcollen > 0 %then %do;
       '<th> Parameter Variable Wide Name </th>'
     %end;
     %if &labellen > 0 %then %do;
       '<th> Label </th> '
     %end;
     %if &pkeylen > 0 %then %do;
       '<th> Key </th> '
     %end;
     %if &typelen > 0 %then %do;
       '<th> Type </th> '
     %end;
     %if &lengthlen > 0 %then %do;
       '<th> Length </th> '
     %end;
     %if &formatlen > 0 %then %do;
       '<th> Format </th> '
     %end;
     %if &formatflaglen > 0 %then %do;
       '<th> Format Type </th> '
     %end;
     %if &importancelen > 0 %then %do;
       '<th> Importance </th> '
     %end;
     %if &domainlen > 0 %then %do;
       '<th> SubDomain </th> '
     %end;
     %if &headerlen > 0 %then %do;
       '<th> Header Flag </th> '
     %end;
     %if &derivetypelen > 0 %then %do;
       '<th> DeriveType </th> '
     %end;
     %if &labellonglen > 0 %then %do;
       '<th> Long Label </th> '
     %end;
     '</tr> '
    ;
    if (hasvalues & &values) | (&descriptions & &pc.description ^= ' ') then
     %if %bquote(&paramvar) = %then %do;
       do;
         if ^ cparamfl & ^ cparamrelfl then put
          '<tr><td><a href="#' table +(-1) column +(-1) '">' column $ '</a>';
         else if cparamfl then
          put '<tr title="' table 'Parameter Variable" bgcolor="silver"><td>'
           '<a href="#' table +(-1) column +(-1) '"><b>' column $ '</b></a>'
         ;
         else if cparamrelfl then 
          put '<tr title="' table 'Parameter-Related Variable"><td>'
           '<a href="#' table +(-1) column +(-1) '"><b>' column $ '</b></a>'
         ;
       end;
       else do;
         if ^ cparamfl & ^ cparamrelfl then put '<tr><td>' column $;
         else if cparamfl then
          put '<tr title="' table 'Parameter Variable" bgcolor="silver"><td>'
           '<a href="#' table +(-1) column +(-1) "param" '"><b>' column $
           '</b></a>'
         ;
         else if cparamrelfl then 
          put '<tr title="' table 'Parameter-Related Variable"><td>'
           '<a href="#' table +(-1) column +(-1) '"><b>' column $ '</b></a>'
         ;
       end;
     %end;
     %else %do;
       put '<tr><td><a href="#' table +(-1) param +(-1) paramrel +(-1)
        '">' param $ '</a> ';
       else put "<tr><td>" param $;
     %end;
    put '</td>' /
     %if %bquote(&paramvar) ^= & &paramrellen > 0 %then %do;
       '<td>' paramrel '</td>'
     %end;
     %if &shortlen > 0 %then %do;
       '<td>' &pc.short '</td>'
     %end;
     %if %bquote(&paramvar) ^= & &paramrelcollen > 0 %then %do;
       '<td>' paramrelcol '</td>'
     %end;
     %if &labellen > 0 %then %do;
       '<td>' &pc.label '</td>'
     %end;
     %if &pkeylen > 0  %then %do;
       '<td>' &pc.pkey 2.0 '</td> '
     %end;
     %if &typelen > 0 %then %do;
       '<td>' &pc.type '</td>'
     %end;
     %if &lengthlen > 0 %then %do;
       '<td>' &pc.length 4.0 '</td>'
     %end;
     %if &formatlen > 0 %then %do;
       '<td>' &pc.format '</td>'
     %end;
     %if &formatflaglen > 0 %then %do;
       '<td>' &pc.formatflag '</td>'
     %end;
     %if &importancelen > 0 %then %do;
       '<td>' &pc.importance '</td>'
     %end;
     %if &domainlen > 0 %then %do;
       '<td>' &pc.domain $ '</td> '
     %end;
     %if &headerlen > 0 %then %do;
       '<td>' &pc.header '</td> '
     %end;
     %if &derivetypelen > 0 %then %do;
       '<td>' &pc.derivetype '</td> '
     %end;
     %if &labellonglen > 0 %then %do;
       '<td>' &pc.labellong $ '</td> '
     %end;
     / '</tr>'
    ;
    if eof then put '</table><p><br style="clear:left"> '
     %if ^ &mult_html %then %do;
       "<a href=""#dsnlist""> back to list of data sets</a> "
     %end;
     %else %do;
       "<a href=""./&mult_file_prefix..html"">"
       "back to list of data sets</a>"
     %end;
     "<br><br></p>";
  %end;
  %else %do;
    file print header=hdr;
    if _n_ = 1 then put _page_;
    put 
     %if %bquote(&paramvar) = %then %do;
       @&c1 column
       %if &shortlen > 0 %then %do;
         @&c3 &pc.short
       %end;
     %end;
     %else %do;
       @&c1 param
       %if &paramrellen > 0 %then %do;
         @&c2 paramrel 
       %end;
       %if &shortlen > 0 %then %do;
         @&c3 &pc.short
       %end;
       %if &paramrelcollen > 0 %then %do;
         @&c4 paramrelcol 
       %end;
     %end;
     %if &labellen > 0 %then %do;
       @&c5 &pc.label
     %end;
     %if &pkeylen > 0 %then %do;
       @&c6 &pc.pkey : 2.0
     %end;
     %if &typelen  > 0 %then %do;
       @&c7 &pc.type
     %end;
     %if &lengthlen  > 0 %then %do;
       @&c8 &pc.length : 4.0
     %end;
     %if &formatlen  > 0 %then %do;
       @&c9 &pc.format
     %end;
     %if &formatflaglen  > 0 %then %do;
       @&c10 &pc.formatflag : 1.0
     %end;
     %if &importancelen  > 0 %then %do;
       @&c11 &pc.importance
     %end;
     %if &domainlen > 0 %then %do;
       @&c12 &pc.domain
     %end;
     %if &headerlen  > 0 %then %do;
       @&c13 &pc.header : 2.0
     %end;
     %if &derivetypelen > 0 %then %do;
       @&c14 &pc.derivetype
     %end;
    ;
    if &pc.labellong ^= ' ' & &pc.labellong ^= &pc.label then
     put @&c1 +10 &pc.labellong;
    return;
    hdr:
     put 
      %if %bquote(&paramvar) ^= %then %do;
        @&c1 "Values of Parameter Variable: &paramvar  in table &table"
        // @&c1 'Parameter'
        %if &paramrellen > 0 %then %do;
          @&c2 'Parameter Related Variable'
        %end;
        %if &shortlen > 0 %then %do;
          @&c3 'ShortName'
        %end;
        %if &paramrelcollen > 0 %then %do;
          @&c4 'Parameter Variable Wide Name'
        %end;
      %end;
      %else %do;
        @&c1 "Variables specified in : " table  // @&c1 'Variable'
        %if &shortlen > 0 %then %do;
          @&c3 'ShortName'
        %end;
      %end;
      %if &labellen > 0 %then %do;
        @&c5 'Label'
      %end;
      %if &pkeylen > 0 %then %do;
        @&c6 'Key'
      %end;
      %if &typelen > 0 %then %do;
        @&c7 'Type'
      %end;
      %if &lengthlen > 0 %then %do;
        @&c8 'Length'
      %end;
      %if &formatlen > 0 %then %do;
        @&c9 'Format'
      %end;
      %if &formatflaglen > 0 %then %do;
        @&c10 'FmtTp'
      %end;
      %if &importancelen > 0 %then %do;
        @&c11 'Import'
      %end;
      %if &domainlen > 0 %then %do;
        @&c12 'Domain'
      %end;
      %if &headerlen > 0 %then %do;
        @&c13 'Header'
      %end;
      %if &derivetypelen > 0 %then %do;
        @&c14 'Derived'
      %end;
      /
      %if %bquote(&paramvar) = %then %do;
        @&c1  %sysfunc(max(&columnlen,8))*'-'
        %if &shortlen > 0 %then %do;
          @&c3  %sysfunc(max(&shortlen,9))*'-'
        %end;
      %end;
      %else %do;
        @&c1  %sysfunc(max(&paramlen,9))*'-'
        %if &paramrellen > 0 %then %do;
          @&c2  %sysfunc(max(&paramrellen,26))*'-'
        %end;
        %if &shortlen > 0 %then %do;
          @&c3  %sysfunc(max(&shortlen,9))*'-'
        %end;
        %if &paramrelcollen > 0 %then %do;
          @&c4  %sysfunc(max(&paramrelcollen,28))*'-'
        %end;
      %end;
      %if &labellen > 0 %then %do;
        @&c5  %sysfunc(max(&labellen,5))*'-'
      %end;
      %if &pkeylen > 0 %then %do;
        @&c6  3*'-'
      %end;
      %if &typelen > 0 %then %do;
        @&c7  4*'-'
      %end;
      %if &lengthlen > 0 %then %do;
        @&c8  6*'-'
      %end;
      %if &formatlen > 0 %then %do;
        @&c9  %sysfunc(max(&formatlen,6))*'-'
      %end;
      %if &formatflaglen > 0 %then %do;
        @&c10  5*'-'
      %end;
      %if &importancelen > 0 %then %do;
        @&c11 6*'-'
      %end;
      %if &domainlen > 0 %then %do;
        @&c12 %sysfunc(max(&domainlen,6))*'-'
      %end;
      %if &headerlen > 0 %then %do;
        @&c13 6*'-'
      %end;
      %if &derivetypelen > 0 %then %do;
        @&c14 9*'-'
      %end;
     ;
    return;
  %end;
run;
%if %bquote(&&tdesc&tablenum) ^= & %bquote(&paramvar) = %then %do;
  *----------------------------------------------------------------------------;
  %bquote(* Print general data set information about &&table&tablenum;)
  *----------------------------------------------------------------------------;
  data _null_;
    infile _mpdesc(&&tdesc&tablenum...source) end=enddesc length=entrylen;
    input @1 line $varying200. entrylen;
    %if &html %then %do;
      line = htmlencode(line);
      line = tranwrd(line,'"','&quot;');
      file &outfile mod;
      if _n_ = 1 then 
       put "<pre title = ""General Information about &&table&tablenum"">";
    %end;
    %else %do;
      file print;
      if _n_ = 1 then
       put @&c1 "General Information about &&table&tablenum";
    %end;
    curlinelen = length(line);
    put @&c1 line $varying200. curlinelen;
    %if &html %then %do;
      if enddesc then put '</pre>';
    %end;
  run;
%end;
%if &debug %then %ut_errmsg(msg=table=&&table&tablenum numcolumns=&numcolumns,
 print=0,macroname=mdcpput);
%if &numcolumns > 0 & (&descriptions | &values) %then %do;
  *============================================================================;
  * Print derivation logic and valid values of each column;
  *============================================================================;
  %do columnnum = 1 %to &numcolumns;
    %if %bquote(&paramvar) ^= %then %do;
      %let numparamrel = 0;
      data _null_;
        if eof then call symput('numparamrel',trim(left(put(paramrelnum,5.0))));
        set _mcindsn (where = (param = "&&col&columnnum")) end=eof;
        paramrelnum + 1;
        call symput('paramrel' || trim(left(put(paramrelnum,5.0))),
         trim(left(upcase(paramrel))));
        call symput('paramdesc' || trim(left(put(paramrelnum,5.0))),
         trim(left(upcase(pdescription))));
        call symput('paramfmt' || trim(left(put(paramrelnum,5.0))),
         trim(left(upcase(pformat))));
        call symput('paramfmtfl' || trim(left(put(paramrelnum,5.0))),
         trim(left(put(pformatflag,32.0))));
      run;
    %end;
    %else %do;
      %let numparamrel = 1;
      %let paramrel1 =;
      %let paramdesc1 =;
      %let paramfmt1 =;
      %let paramfmtfl1 =;
    %end;
    %if &numparamrel > 0 %then %do paramrelnum = 1 %to &numparamrel;
      %ut_errmsg(msg=paramrel&paramrelnum=&&paramrel&paramrelnum 
       paramdesc&paramrelnum=&&paramdesc&paramrelnum
       paramfmt&paramrelnum=&&paramfmt&paramrelnum
       paramfmtfl&paramrelnum=&&paramfmtfl&paramrelnum,
       macroname=mdcpput,print=0)
    %end;
    %if &numparamrel > 0 %then %do paramrelnum = 1 %to &numparamrel;
      %if %bquote(&paramvar) ^= %then %do;
        %let curparamrel = &&paramrel&paramrelnum;
        %let curdesc = &&paramdesc&paramrelnum;
        %let curfmt = &&paramfmt&paramrelnum;
        %let curfmtfl = &&paramfmtfl&paramrelnum;
      %end;
      %else %do;
        %let curparamrel =;
        %let curdesc = &&desc&columnnum;
        %let curfmt = &&fmt&columnnum;
        %let curfmtfl = &&fmtfl&columnnum;
      %end;
      %if &debug %then
       %ut_errmsg(msg=curparamrel=&curparamrel curdesc=&curdesc curfmt=&curfmt
        curfmtfl=&curfmtfl columnnum=&columnnum paramrelnum=&paramrelnum,
       print=0,macroname=mdcpput);
      data _null_;
        if _n_ = 1 then do;
          hasstart = 0;
          hasend = 0;
          hasflabel = 0;
          hasflabellong = 0;
        end;
        if eof then do;
          call symput('hasstart',trim(left(put(hasstart,1.0))));
          call symput('hasend',trim(left(put(hasend,1.0))));
          call symput('hasflabel',trim(left(put(hasflabel,1.0))));
          call symput('hasflabellong',trim(left(put(hasflabellong,1.0))));
          colspan = hasstart + hasend + hasflabel + hasflabellong;
          call symput('colspan',trim(left(put(colspan,4.0))));
        end;
        set _mpvalues (where=(upcase(format) = "%upcase(&curfmt)" &
         format ^= ' ')) end=eof;
        hasstart = 1;
        if end        ^= ' ' then hasend        = 1;
        if flabel     ^= ' ' then hasflabel     = 1;
        if flabellong ^= ' ' then hasflabellong = 1;
        retain hasstart hasend hasflabel hasflabellong;
      run;
      data _null_;
        %if &html %then %do;
          file &outfile mod;
        %end;
        %else %do;
          file print linesleft=ll notitles nofootnotes noprint;
        %end;
        %if &descriptions %then %do;
          _mchasdesc = 0;
          %if %bquote(&curdesc) ^= %then %do;
            %if &columnnum = 1 %then %do;
              length line $ 200;
            %end;
            *------------------------------------------------------------------;
            %bquote(* Derivation logic description for Col: &&col&columnnum 
             in entry &curdesc;)
            %if %bquote(&curparamrel) ^= %then %do;
              %bquote(*Paramrel: &curparamrel;)
            %end;
            *------------------------------------------------------------------;
            %if &html %then %do;
              put "<hr> <p>"
               "<a name=""&&table&tablenum..&&col&columnnum..&curparamrel""> "
               "</a>Data Set: &&table&tablenum  "

               %if &&cparamfl&columnnum %then %do;
                 '<a href="#' "&table.&&col&columnnum..param"">"
               %end;
               %if %bquote(&paramvar) = %then %do;
                 "Column: &&col&columnnum" 
               %end;
               %else %do;
                 "when &paramvar = &&col&columnnum then &curparamrel:"
               %end;
               %if &&cparamfl&columnnum %then %do;
                 '</a>'
               %end;
               '</p><pre title = "'
               %if %bquote(&paramvar) = %then %do;
                 "Information about &&table&tablenum &&col&columnnum"">"
               %end;
               %else %do;
                 "Information about &&table&tablenum &curparamrel when &paramvar=&&col&columnnum"">"
               %end;
              ;
            %end;
            %else %do;
              put
               @&c1 +1 &needls*"-" /
               @&c1 +1 "Data Set:  &&table&tablenum  " 
               %if %bquote(&paramvar) = %then %do;
                 "Column: &&col&columnnum" 
               %end;
               %else %do;
                 "when &paramvar = &&col&columnnum then &curparamrel:"
               %end;
              ;
            %end;
            if ^ eofile&columnnum then do;
              _mcfirst = 1;
              do until (eofile&columnnum);
                infile _mpdesc(&curdesc..source) end=eofile&columnnum
                 length=entrylen;

                if _mcfirst then input @1 line $varying200. entrylen;
                else do;
                  input @1 line $varying200. entrylen;
                  _mcfirst = 0;
                end;
                %if &html %then %do;
                  line = htmlencode(line);
                  line = tranwrd(line,'"','&quot;');
                %end;
                curlinelen = length(line);
                put @&c1
                 %if ^ &html %then %do;
                   +1
                 %end;
                 line $varying200. curlinelen;
                if eofile&columnnum then do;
                  %if &html %then %do;
                    put '<br>';
                  %end;
                  %else %do;
                    put //;
                  %end;
                end;
              end;
            end;
            %if &html %then %do;
              put '</pre>';
            %end;
            _mchasdesc = 1;
          %end;
        %end;
        %else %do;
          _mchasdesc = 0;
        %end;
        %if &values %then %do;
          *--------------------------------------------------------------------;
          %bquote(* Valid Values for column &&col&columnnum;)
          %if %bquote(&curparamrel) ^= %then %do;
            %bquote(*Paramrel: &curparamrel;)
          %end;
          *--------------------------------------------------------------------;
          _mchasvals = 0;    _mcallowmiss = 0;
          %if %bquote(&&curfmt) ^= %then %do;
            if ^ eodsn&columnnum then do until (eodsn&columnnum);
              if ^ _mchasvals then do;
                %if %bquote(&curdesc) = | ^ &descriptions %then %do;
                  %if &html %then %do;
                    put "<hr><p><a "
                     "name=""&&table&tablenum..&&col&columnnum..&curparamrel"">"
                     " </a>" / "Data Set:  &&table&tablenum  "
                     %if &&cparamfl&columnnum %then %do;
                       '<a href="#' "&table.&&col&columnnum..param"">"
                     %end;
                     %if %bquote(&paramvar) = %then %do;
                       "Column: &&col&columnnum" 
                     %end;
                     %else %do;
                       "when &paramvar = &&col&columnnum then &curparamrel:"
                     %end;
                     %if &&cparamfl&columnnum %then %do;
                       '</a>'
                     %end;
                     '</p>';
                  %end;
                  %else %do;
                    put @&c1 +1 &needls*"-" / @&c1 +1 "Data Set:  &&table&tablenum  "
                    %if %bquote(&paramvar) = %then %do;
                      "Column: &&col&columnnum" 
                    %end;
                    %else %do;
                      "when &paramvar = &&col&columnnum then &curparamrel:"
                    %end;
                    / ;
                  %end;
                %end;
                %if &html %then %do;
                  %if %bquote(&paramvar) = %then %do;
                    put "<p>Valid value(s) for variable &&col&columnnum ";
                     %if &&fmtfl&columnnum = 2 %then %do;
                       %if ^ &hasend %then %do;
                         put 'in Start column.';
                       %end;
                       %else %do;
                         put 'between start and end (inclusive).';
                       %end;
                     %end;
                     %else %if &&fmtfl&columnnum = 3 %then %do;
                       put 'in Label column.';
                     %end;
                     %else %if &&fmtfl&columnnum = 4 %then %do;
                       put 'in Long Label column.';
                     %end;
                     put '</p>';
                  %end;
                  %else %do;
                    put "<p>Valid value(s) found ";
                     %if &curfmtfl = 2 %then %do;
                       %if ^ &hasend %then %do;
                         put 'in Start column.';
                       %end;
                       %else %do;
                         put 'between start and end (inclusive).';
                       %end;
                     %end;
                     %else %if &curfmtfl = 3 %then %do;
                       put 'in Label column.';
                     %end;
                     %else %if &curfmtfl = 4 %then %do;
                       put 'in Long Label column.';
                     %end;
                     put '</p>';
                  %end;
                %end;
                %else %do;
                  %if %bquote(&paramvar) = %then %do;
                    put @&c1 +1 "Valid value(s) for variable &&col&columnnum "
                     %if &&fmtfl&columnnum = 2 %then %do;
                       %if ^ &hasend %then %do;
                         'in Start column.'
                       %end;
                       %else %do;
                         'between start and end (inclusive).'
                       %end;
                     %end;
                     %else %if &&fmtfl&columnnum = 3 %then %do;
                       'in Label column.'
                     %end;
                     %else %if &&fmtfl&columnnum = 4 %then %do;
                       'in Long Label column.'
                     %end;
                    ;
                    put;
                  %end;
                  %else %do;
                    put @&c1 +1 "Valid value(s) "
                     %if &curfmtfl = 2 %then %do;
                       %if ^ &hasend %then %do;
                         'in Start column.'
                       %end;
                       %else %do;
                         'between start and end (inclusive).'
                       %end;
                     %end;
                     %else %if &curfmtfl = 3 %then %do;
                       'in Label column.'
                     %end;
                     %else %if &curfmtfl = 4 %then %do;
                       'in Long Label column.'
                     %end;
                    ;
                    put;
                  %end;
                %end;
              end;
              set _mpvalues (where=(upcase(format) = "%upcase(&curfmt)"
               & format ^= ' '))    end=eodsn&columnnum;
              %if %bquote(maxvaluesobs) ^= &
               %bquote(%upcase(&maxvaluesobs)) ^= MAX %then %do;
                _number_of_values + 1;
                if _number_of_values <= &maxvaluesobs then do;
              %end;
              %if &html %then %do;
                if ^ _mchasvals then put
                 '<p></p> <table style="float:left" border title="'
                 %if %bquote(&paramvar) = %then %do;
                   "Format &curfmt of &&table&tablenum &&col&columnnum"">"
                 %end;
                 %else %do;
                   "Format &curfmt of &&table&tablenum &curparamrel when "
                   "&paramvar=&&col&columnnum"">"
                 %end;
                 / "<tr><th colspan=&colspan align=center> "
                 "Format &curfmt values list </th></tr><tr>"
                 %if &hasstart %then %do;
                   '<th>Start</th>'
                 %end;
                 %if &hasend %then %do;
                   '<th>End</th> '
                 %end;
                 %if &hasflabel %then %do;
                   '<th>Label</th>'
                 %end;
                 %if &hasflabellong %then %do;
                   '<th>Long Label</th>'
                 %end;
                 '</tr>'
                ;
                if start ^= ' ' then do;
                  start = htmlencode(start);
                  start = tranwrd(start,'"','&quot;');
                end;
                if end ^= ' ' then do;
                  end = htmlencode(end);
                  end = tranwrd(end,'"','&quot;');
                end;
                if flabel ^= ' ' then do;
                  flabel = htmlencode(flabel);
                  flabel = tranwrd(flabel,'"','&quot;');
                end;
                if flabellong ^= ' ' then do;
                  flabellong = htmlencode(flabellong);
                  flabellong = tranwrd(flabellong,'"','&quot;');
                end;
                if start ^= ' ' | end ^= ' ' then do;
                  if upcase(start) ^= '_NOMISS_' then put '<tr>'
                   %if &hasstart %then %do;
                     '<td>' start '</td>'
                   %end;
                   %if &hasend %then %do;
                     '<td>' end '</td>'
                   %end;
                   %if &hasflabel %then %do;
                     '<td>' flabel '</td>'
                   %end;
                   %if &hasflabellong %then %do;
                     '<td>' flabellong '</td>'
                   %end;
                  '</tr>';
                end;
                else do;
                  put "<tr><td colspan=&colspan>Mis"
                   'sing Value Allowed</td></tr>'
                  ;
                  _mcallowmiss = 1;
                end;
              %end;
              %else %do;
                _mcstartlen = length(start);
                _mcendlen = length(end);
                _mclabellen = length(flabel);
                _mcllabellen = length(flabellong);
                if flabel ^= ' ' | flabellong ^= ' ' then do;
                  if end ^= ' ' then
                   put @&c1 +2 'Min:' Start $varying. _mcstartlen
                   '  Max:' end $varying. _mcendlen ' translates to "'
                   flabel $varying. _mclabellen '"' /
                   @&c1 +19 '"' flabellong $varying. _mcllabellen '"';
                  else if start ^= ' ' then
                   put @&c1 +2 Start $varying. _mcstartlen ' translates to "'
                    flabel $varying. _mclabellen '"'
                   / @&c1 +19 '"' flabellong $varying. _mcllabellen '"';
                  if start = ' ' & end = ' ' then do;
                    put @&c1 +2 'Mis' 'sing value is allowed';
                    _mcallowmiss = 1;
                  end;
                end;
                else do;
                  if end ^= ' ' then put @&c1 +2
                   'Min:' Start $varying. _mcstartlen
                   '  Max:' end $varying. _mcendlen;
                  else if start ^= ' ' & upcase(start) ^= '_NOMISS_' then
                   put @&c1 +2 Start $varying. _mcstartlen;
                  if start = ' ' & end = ' ' then do;
                    put @&c1 +2 'Mis' 'sing value allowed';
                    _mcallowmiss = 1;
                  end;
                end;
              %end;
              %if %bquote(maxvaluesobs) ^= &
               %bquote(%upcase(&maxvaluesobs)) ^= MAX %then %do;
                end;
                else if _number_of_values = (&maxvaluesobs + 1) then do;
                  %if &html %then %do;
                    put "<tr><td>Maximum values (&maxvaluesobs) "
                     "reached<br>no more printed</td></tr>";
                  %end;
                  %else %do;
                    put @&c1 +2 "Maximum values (&maxvaluesobs) "
                     "reached no more printed";
                  %end;
                end;
              %end;
              _mchasvals = 1;
            end;
            if _mchasvals then do;
              %if &html %then %do;
                if ^ _mcallowmiss then put 
                 "<tr><td colspan=&colspan>Mis"
                 'sing value is not allowed</td></tr>';
                %if %bquote(maxvaluesobs) ^= &
                 %bquote(%upcase(&maxvaluesobs)) ^= MAX %then %do;
                  if _number_of_values > &maxvaluesobs then 
                   put '<tr><td>Total number of values = '
                    _number_of_values : 5.0 '</td></tr>';
                %end;
                put '</table><p><br style="clear:left"></p>';
              %end;
              %else %do;
                if ^ _mcallowmiss then put @&c1 +2 'Mis'
                 'sing value is not allowed' /;
                %if %bquote(maxvaluesobs) ^= &
                 %bquote(%upcase(&maxvaluesobs)) ^= MAX %then %do;
                  if _number_of_values > &maxvaluesobs then 
                   put @&c1 +2 'Total number of values = '
                    _number_of_values : 5.0;
                %end;
              %end;
            end;
          %end;
        %end;
        %else %do;
          _mchasvals = 0;
        %end;
        %if &html & (&descriptions | &values) %then %do;
          if _mchasdesc | _mchasvals then do;
            *------------------------------------------------------------------;
            %bquote(* Return to data set from &&col&columnnum;)
            %if %bquote(&curparamrel) ^= %then %do;
              %bquote(*Paramrel: &curparamrel;)
            %end;
            *------------------------------------------------------------------;
            put '<p>' 
             %if %bquote(&paramvar) = %then %do;
               "<a href=""#&&table&tablenum"">"
               "back to data set &&table&tablenum</a>"
             %end;
             %else %do;
               "<a href=""#&&table&tablenum..&paramvar.param" 
               '"> back to parameter list</a> '
             %end;
             '</p>'
            ;
          end;
        %end;
        stop;
      run;
      %if &debug %then %ut_errmsg(msg=columnnum=&columnnum
       col&columnnum=&&col&columnnum,print=0,macroname=mdcpput);
    %end;
  %end;
%end;
%else %ut_errmsg(msg=no columns found numcolumns=&numcolumns,print=0,
 macroname=mdcpput);
%if &ls ^= %then %do;
  options linesize=&ls;
%end;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _mc:;
  run; quit;
%end;
%endmac:
%mend;
