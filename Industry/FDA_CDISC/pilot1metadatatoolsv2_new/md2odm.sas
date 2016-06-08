%macro md2odm(mdlib=_default_,select=_default_,exclude=_default_,
 mdprefix=_default_,outxml=_default_,outxmlref=_default_,colsame=_default_,

 author=_default_,stylesheet=_default_,
 ODMVersion=_default_,StudyName=_default_,ProtocolName=_default_,
 AnnotatedCRF_location=_default_,SupplementalDoc=_default_,
 StudyDescription=_default_,Originator=_default_,SourceSystem=_default_,
 SourceSystemVersion=_default_,priorFileOID=_default_,FileType=_default_,
 FileOID=_default_,schemaLocation=_default_,
 crt_prefix=_default_,

 verbose=_default_,debug=_default_);
  /*soh************************************************************************
   Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME    : md2odm
   TYPE                     : metadata
   DESCRIPTION              : Creates the define.xml file from metadata
   DOCUMENT LIST            : <Enter name and location of the Broad-Use Module
							      Document List>
   SOFTWARE/VERSION#        : SAS/Version 8
   INFRASTRUCTURE           : Windows, MVS, Unix
   BROAD-USE MODULES        : <List all the broad-use modules called 
							      by this module>
   INPUT                    : <List all files and their production locations 
                               including AUTOEXEC files, if applicable>
   OUTPUT                   : an xml file as defined by the OUTXML or OUTXMLREF
                               parameters
   VALIDATION LEVEL         : 6
   REGULATORY STATUS        : GCP
   TEMPORARY OBJECT PREFIX  : _od
  -----------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
  MDLIB     required          
  MDPREFIX  optional          
  SELECT    optional          
  EXCLUDE   optional          
  OUTXML    optional          
  OUTXMLREF optional          
  COLSAME   required 0        
  VERBOSE   required 1        %ut_logical value specifying whether verbose mode
                               is on or off
  DEBUG     required 0        %ut_logical value specifying whether debug mode
                               is on or off
  ODM elements and attributes as described in the ODM and define schemas:
  AUTHOR
  STYLESHEET
  ODMVersion
  StudyName
  ProtocolName
  AnnotatedCRF_location
  SupplementalDoc
  StudyDescription
  Originator
  SourceSystem
  SourceSystemVersion
  priorFileOID
  FileType
  FileOID
  crt_prefix    
  schemaLocation
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
%* Initialization;
%*=============================================================================;
%ut_parmdef(mdlib,_pdmacroname=md2odm,_pdrequired=1)
%ut_parmdef(mdprefix,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(select,_default_,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(exclude,_default_,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(outxml,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(outxmlref,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(StudyName,_pdmacroname=md2odm,_pdrequired=1)
%ut_parmdef(ProtocolName,_pdmacroname=md2odm,_pdrequired=1)
%ut_parmdef(author,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(stylesheet,crtdds3-1-1.xsl,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(colsame,0,_pdmacroname=md2odm,_pdrequired=1)
%ut_parmdef(odmversion,1.3,1.2 1.3,_pdmacroname=md2odm,_pdrequired=1)
%ut_parmdef(StudyDescription,_pdmacroname=md2odm,_pdrequired=1)
%ut_parmdef(Originator,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(SourceSystem,ClinTrial,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(SourceSystemVersion,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(priorFileOID,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(FileType,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(FileOID,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(AnnotatedCRF_location,blankcrf.pdf,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(SupplementalDoc,_pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(crt_prefix,crt,_pdrequired=1,_pdmacroname=md2odm,_pdverbose=1)
%ut_parmdef(schemaLocation,http://www.cdisc.org/ns/odm/v1.3 UTIL/cp01.xsd,
 _pdmacroname=md2odm,_pdrequired=0)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=md2odm,_pdverbose=1)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=md2odm,_pdverbose=1)
%ut_logical(colsame)
%ut_logical(verbose)
%ut_logical(debug)
%if %bquote(&author) = %then %let author = &sysuserid;
%local outfile moddt;
%if %bquote(&outxmlref) ^= %then %do;
  %let outfile = &outxmlref;
  %if %bquote(&outxml) ^= %then %put UWARNING: Do not specify both outxml and
   outxmlref parameters - using outxmlref = &outxmlref;
%end;
%else %do;
  %if %bquote(&outxml) ^= %then %let outfile = "&outxml";
  %else %do;
    %put UWARNING The OUTXML or OUTXMLREF parameter must be specified;
    %goto endmac;
  %end;
%end;
%if %bquote(&outfile) = %then %do;
  %put UNOTE: OUTXML or OUTXMLREF must be specified - ending macro 
   outxmlref=&outxmlref outxml=&outxml outfile=&outfile;
  %goto endmac;
%end;
*==============================================================================;
* Call the MDMAKE macro to copy metadata to the work library;
*==============================================================================;

%* call mdadstandard instead for xx vars to au and xt ?  exclude observat;

%mdmake(inlib=&mdlib,outlib=work,inprefix=&mdprefix,outprefix=_odm,
 mode=replace,addparam=0,addheader=1,inselect=&select,inexclude=&exclude,
 contents=1,mkcat=0,keepall=1,verbose=1,debug=&debug)
data _odmtables;

  length Repeating IsReferenceData $ 3 Domain Origin $ 200 Purpose $ 10
   Comment $ 200 Class $ 15 Structure $ 400;

  set _odmtables;

  if Repeating       = ' ' then Repeating       = 'Yes';
  if IsReferenceData = ' ' then IsReferenceData = 'No';
  if Domain          = ' ' then Domain          = ' ';

  if Origin          = ' ' then Origin          = ' ';

  if Purpose         = ' ' then Purpose         = ' ';
  if Comment         = ' ' then Comment         = ' ';
  if Class           = ' ' then Class           = ' ';
  if Structure       = ' ' then Structure       = ' ';

run;
data _odmcolumns;
  length Mandatory $ 3 Origin Source $ 200 DataType $ 8 DisplayFormat $ 15
   Comment Role $ 200 MethodDefType $ 11 SignificantDigits 8 SDSVarName $ 32;
  set _odmcolumns;

%* Role element of ItemDef is deprecated and replaced with Role attribute of ItemRef;

  if Role = ' ' then do;
    Role = ' ';
    RolecodelistOID = ' ';
  end;
  if cOrigin ^= ' ' then Origin = cOrigin;
  if Source = ' ' then Source = ' ';
  if upcase(ctype) = 'C' then datatype = 'text';
  else if upcase(ctype) = 'N' then do;
    if upcase(cformat) =: 'DATETIME' then datatype = 'datetime';
    else if upcase(cformat) =: 'DATE' then datatype = 'date';
    else if upcase(cformat) =: 'TIME' then datatype = 'time';
    else if clength < 8 then datatype = 'integer';
    else do;
      datatype = 'float';
      SignificantDigits = input(scan(cformat,2,'.'),5.0);
    end;
  end;
  if comment = ' ' then comment = clabellong;
  if DisplayFormat = ' ' & cformatflag = 1 then DisplayFormat = cformat;
  if upcase(cderivetype) = 'DERIVED' then MethodDefType = 'Computation';
  else if upcase(cderivetype) = 'IMPUTED' then MethodDefType = 'Imputation';
  else if upcase(cderivetype) = 'TRANSFORM' then MethodDefType = 'Transpose';
  else if upcase(cderivetype) = 'COPY' then MethodDefType = 'Other';
  else if upcase(cderivetype) ^= ' ' then MethodDefType = 'Other';
  else MethodDefType = 'Computation';
  if Mandatory = ' ' then Mandatory = 'Yes';
  if SDSVarName      = ' ' then SDSVarName      = ' ';
  else cpflag = 0;
run;
*==============================================================================;
* Determine the most recent modification datetime of the metadata;
*==============================================================================;
%mdmoddt(mdlib=&mdlib,mdprefix=&mdprefix,verbose=&verbose,debug=&debug)
*==============================================================================;
* Open the ODM tag and start the subelements;
*==============================================================================;
data _null_;
  moddt = input("&moddt",datetime13.);
  nowdt = datetime();
  file &outfile;
  put 
   '<?xml version="1.0" encoding="ISO-8859-1" ?>' /
   %if %bquote(&stylesheet) ^= %then %do;
     "<?xml-stylesheet type=""text/xsl"" href=""&stylesheet""?>" /
   %end;
   "<!-- **************************************************************** -->" /
   "<!-- File: define.xml                                                 -->" /
   "<!-- Date: &sysdate    &systime                                       -->" /
   "<!-- Author: &author                                                  -->" /
   "<!-- Description: This the define.xml which implements the Case       -->" /
   "<!--  Report Tabulation Data Definition Specification Version 1.0.0   -->" /
   "<!-- **************************************************************** -->"
  ;


* put "<ODM xmlns=""http://www.cdisc.org/ns/odm/v&odmversion"" " /
   ' xmlns:ds="http://www.w3.org/2000/09/xmldsig#"' /
   ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' /
   ' xmlns:xlink="http://www.w3.org/1999/xlink"' /
   ' xmlns:def="http://www.cdisc.org/ns/def/v1.0"' /

   ' xsi:schemaLocation="http://www.cdisc.org/models/def/v1.0/ define1-0-0.xsd"'
   /

%*   ' xsi:schemaLocation="http://www.cdisc.org/ns/odm/v1.3 define1-0-0.xsd"' /;

   ' FileType="Snapshot"' /
   " FileOID=""&FileOID"" " /
   ' CreationDateTime="' nowdt : IS8601DT. +(-1) '"' /
   %if %bquote(&moddt) ^= %then %do;
     ' AsOfDateTime="' moddt : IS8601DT. +(-1) '"' /
   %end;
   ' Granularity="Metadata"' /
   " ODMVersion=""&odmversion"" " /
   '>'
  ;

%* ODM tag from cp01 example for pilot project;
put 
 '<ODM   xmlns="http://www.cdisc.org/ns/odm/v1.3"' /
 ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' /
 ' xmlns:xlink="http://www.w3.org/1999/xlink"' /
 ' xmlns:crt="http://www.cdisc.org/ns/crt/v3.1.1"' /
 ' xmlns:sdtm="http://www.cdisc.org/ns/sdtm/v3.1.1"' /
 ' xmlns:cp01="http://www.cdisc.org/ns/pilot/1.0"' /
 " xsi:schemaLocation=""&schemaLocation""" /
  	
 ' ODMVersion="1.3"' /
 %if %bquote(&FileOID) ^= %then %do;
   " FileOID=""&FileOID""" /
 %end;
 ' FileType="Snapshot"' /
 ' CreationDateTime="' nowdt : IS8601DT. +(-1) '"' /
 %if %bquote(&moddt) ^= %then %do;
   ' AsOfDateTime="' moddt : IS8601DT. +(-1) '"' /
 %end;
 '>'
;

  put "<Study OID=""&studyname"">";
  put "<GlobalVariables>" /
   " <StudyName>&studyname</StudyName>" /
   " <StudyDescription>&StudyDescription</StudyDescription>" /
   %if %bquote(&ProtocolName) ^= %then %do;
     " <ProtocolName>&ProtocolName</ProtocolName>" /
   %end;
   %else %do;
     " <ProtocolName>Protocol Name not defined</ProtocolName>" /
   %end;
   "</GlobalVariables>"
  ;
  put "<MetaDataVersion OID=""CDISC.SDTM.3.1.0"" " /
   "Name=""&studyname, Data Definitions"" " /
   "Description=""Study &studyname, Data Definitions"" " /
   "&crt_prefix:DefineVersion=""1.0.0"" " /
   "&crt_prefix:StandardName=""CDISC SDTM"" " /
   "&crt_prefix:StandardVersion=""3.1.1"" >"
  ;

  %if %bquote(&AnnotatedCRF_location) ^= %then %do;
    put "<&crt_prefix:AnnotatedCRF>" /
     " <&crt_prefix:DocumentRef leafID=""blankcrf"" />" /
     "</&crt_prefix:AnnotatedCRF>"
    ;
    put
     "<&crt_prefix:leaf ID=""blankcrf"" xlink:href=""&AnnotatedCRF_location"">"
     / " <&crt_prefix:title>Annotated Case Report Form</&crt_prefix:title>" /
     "</&crt_prefix:leaf>"
    ;
  %end;

  %if %bquote(&SupplementalDoc) ^= %then %do;
    put "<&crt_prefix:SupplementalDoc>" /
     " <&crt_prefix:DocumentRef leafID=""SupplementalDataDefinitions"" /> " /
     "</&crt_prefix:SupplementalDoc>"
    ;
    put "<&crt_prefix:leaf ID=""SupplementalDataDefinitions"" " /
     " xlink:href=""supplementaldatadefinitions.pdf"" >" /
     " <&crt_prefix:title>Supplemental Data Definitions Document</&crt_prefix:title>" /
     "</&crt_prefix:leaf>"
    ;
  %end;
run;
*==============================================================================;
* Create table OIDs;
*==============================================================================;
data _odmtables_oid;
  set _odmtables;
  table_oid = 'TABLE' || trim(left(put(_n_,8.0)));
run;
*==============================================================================;
* Merge table information with column information and create column OIDs;
*==============================================================================;
%if &colsame %then %do;
  *----------------------------------------------------------------------------;
  * Column characteristics are the same in all data sets they exist in;
  * so a column gets one OID regardless of the number of domains it exists in;
  *----------------------------------------------------------------------------;
  proc sort data = _odmcolumns (keep=column)  out = _odmcolids  nodupkey;
    by column;
  run;
  data _odmcolids;
    set _odmcolids;
    column_oid = 'COL' || trim(left(put(_n_,8.0)));
    column_oid_sort = _n_;
  run;
  proc sort data = _odmcolumns  out = _odmcolumns_bycol;
    by column;
  run;
  data _odmcolumns_oid;
    merge _odmcolumns_bycol  _odmcolids;
    by column;
  run;
  proc sort data = _odmcolumns_oid;
    by table corder column;
  run;
%end;
%else %do;
  *----------------------------------------------------------------------------;
  * Column characteristics are not the same in all data sets they exist in;
  * so a column gets a different OID for each of the domains it exists in;
  *----------------------------------------------------------------------------;
  proc sort data = _odmcolumns  out = _odmcolids;
    by table corder column;
  run;
  data _odmcolumns_oid;
    set _odmcolumns;
    column_oid = 'COL' || trim(left(put(_n_,8.0)));
    column_oid_sort = _n_;
  run;
%end;

data _odmcolumns_oids;
  merge _odmtables_oid (in=fromtables keep=table table_oid tlabel location
                       torder tshort domain repeating isreferencedata purpose
                       class structure)
        _odmcolumns_oid (in=fromcols);
  by table;
  if ^ fromcols & first.table then
   %ut_errmsg(msg="Table not defined in COLUMNS "
   "metadata but defined in TABLES metadata " table= /,
   macroname=md2odm,type=warning,max=100);
  if fromcols;
  if cpkey > 0 then cpkeyflag = 1;
  if ^ fromtables & first.table then
   %ut_errmsg(msg="Table not defined in TABLES metadata but defined in COLUMNS "
   "metadata - no table OID is assigned " table= /,
   macroname=md2odm,type=warning,max=100);
run;

*==============================================================================;
* Add a variable containing a comma delimited list of primary key variables;
*==============================================================================;
proc sort data = _odmcolumns_oids;
  by table descending cpkeyflag cpkey cheader corder column;
run;
%let cpkeylist_maxlen = 1;
data _odmcpkeylist (keep=table cpkeylist)
     _odmcolumns_oids (drop=cpkeylist cpkeylist_len cpkeylist_maxlen);
  if eof & cpkeylist_maxlen > 0 then
   call symput('cpkeylist_maxlen',trim(left(put(cpkeylist_maxlen,8.0))));
  set _odmcolumns_oids (drop=corder) end=eof;
  by table;
  if first.table then corder = 1;
  else corder + 1;
  output _odmcolumns_oids;
  length cpkeylist $ 2000;
  if first.table then cpkeylist = ' ';
  if cpkey > 0 then do;
    if cpkeylist ^= ' ' then
     cpkeylist = trim(left(cpkeylist)) || ', ' || trim(left(column));
    else cpkeylist = trim(left(column));
  end;
  if last.table then do;
    cpkeylist_len = length(cpkeylist);
    if cpkeylist_len > cpkeylist_maxlen then cpkeylist_maxlen = cpkeylist_len;
  end;
  if last.table then output _odmcpkeylist;
  retain cpkeylist cpkeylist_maxlen;
run;
data _odmcolumns_oids;
  %if &cpkeylist_maxlen > 0 %then %do;
    length cpkeylist $ &cpkeylist_maxlen;
  %end;
  merge _odmcolumns_oids _odmcpkeylist;
  by table;

  if Structure = ' ' then Structure = 'One observation per: ' || cpkeylist;

run;
*==============================================================================;
* Add codelist OIDs to columns and values information;
*==============================================================================;
proc sort data = _odmcolumns (keep=cformat ctype cformatflag
 where = (cformat ^= ' ' & cformatflag ^= 1))  out = _odmfmttypes;
  by cformat;
run;
data _odmfmttypes;
  set _odmfmttypes;
  by cformat;

%* do for text float integer, not just n and c;

  if first.cformat then do;
    ftypen = 0;
    ftypec = 0;
  end;
  if upcase(ctype) =: 'N' then ftypen = 1;
  else if upcase(ctype) =: 'C' then ftypec = 1;
  if last.cformat;
  retain ftypen ftypec;
  keep cformat ftypen ftypec;
run;

%* Need to add generation of enumeratedList for formatflag = 3 and 4
   in addition to CodeList for formatflag = 2;

data _odmformatOIDs;
  merge _odmvalues (in=fromvals)
        _odmfmttypes (in=fromtypes rename=(cformat=format));
  by format;
  if first.format then do;
    if ^ fromvals then put '(md2odm) columns cformat not' ' found in values ' format=;

    else if ^ fromtypes then
     put '(md2odm) values format not' ' found in columns ' format=;

  end;
  if fromvals & fromtypes;
  if first.format then do;
    has_flabel = 0;
    has_flabellong = 0;
    has_end = 0;
  end;
  if flabel ^= ' ' then has_flabel = 1;
  if flabellong ^= ' ' then has_flabellong = 1;
  if end ^= ' ' then has_end = 1;
  length codelist_OIDn codelist_OIDc $ 25 codelist_type $ 10;
  if last.format then do;
    if ftypen then do;
      cidn + 1;
      codelist_OIDn = 'CODELISTN' || trim(left(put(cidn,8.0)));
    end;
    if ftypec then do;
      cidc + 1;
      codelist_OIDc = 'CODELISTC' || trim(left(put(cidc,8.0)));
    end;

%* cformatflag ?;

    if has_flabel | has_flabellong then codelist_type = 'codelist';
    else do;
      if has_end then codelist_type = 'rangecheck';
      else codelist_type = 'enumerated';
    end;
    output;
  end;
  retain has_flabel has_flabellong has_end;
  keep format codelist_OIDn codelist_OIDc codelist_type;
run;
proc sort data = _odmcolumns_oids;
  by cformat;
run;
data _odmcolumns_oids;
  merge _odmcolumns_oids (in=fromcols)
        _odmformatOIDs   (in=fromfoids rename=(format=cformat));
  by cformat;
  if cformat ^= ' ' & cformatflag ^= 1 then do;
    if ^ fromcols then put 'Format name found in VALUES but not in COLUMNS '
     cformat= /;
    if ^ fromfoids then put 'Format name found in COLUMNS but not in VALUES ' 
     table= column= cformat= cformatflag= /;
  end;
  if fromcols;
  if upcase(ctype) =: 'N' then codelist_OID = codelist_OIDn;
  else if upcase(ctype) =: 'C' then codelist_OID = codelist_OIDc;
  drop codelist_OIDn codelist_OIDc;
run;
proc sort data = _odmcolumns_oids;
  by table corder column;
run;
proc sort data = _odmvalues;
  by format;
run;
data _odmvalues_oids;
  merge _odmvalues     (in=fromvals)
        _odmformatOIDs (in=fromfoids);
  by format;
  if fromvals;

  if codelist_OIDn = ' ' & codelist_OIDc = ' ' then
   put 'UWAR' 'NING: (md2odm)' _all_ /;

  length codelist_OID $ 25;
  do cltype = 1 to 2;
    if cltype = 1 & codelist_OIDn ^= ' ' then do;
      codelist_OID = codelist_OIDn;
      DataType = 'integer';
      output;
    end;
    else if cltype = 2 & codelist_OIDc ^= ' ' then do;
      codelist_OID = codelist_OIDc;
      DataType = 'text';
      output;
    end;
  end;

%* how many datatypes and how many possible duplicates per values list?;
%*  if codelist_OIDc ^= ' ' then DataType = 'text';
%*  else if 0 then DataType = 'float';
%*  else if 0 then DataType = 'integer';
%*  else DataType = 'integer';

  drop codelist_OIDn codelist_OIDc;
run;
*==============================================================================;
* Add MethodDef OIDs;
*==============================================================================;
data _odmcolumns_oids;
  set _odmcolumns_oids;
  if cexist('work._odmdescriptions.' || trim(left(cdescription)) || '.source')
   then cdescription = cdescription;
  else if cexist('work._odmdescriptions.' || trim(left(column)) || '.source')
   then cdescription = column;
  else cdescription = ' ';
run;
proc sort data = _odmcolumns_oids (keep=cdescription MethodDefType
 where = (cdescription ^= ' '))    out = _odmcdescs  nodupkey;
  by cdescription;
run;
data _odmcdescs;
  set _odmcdescs;
  length MethodDefOID $ 25;
  if cdescription ^= ' ' then do;
    cdid + 1;
    MethodDefOID = 'METHDEF' || trim(left(put(cdid,8.0)));
  end;
  keep cdescription MethodDefOID MethodDefType;
run;
proc sort data = _odmcolumns_OIDs;
  by cdescription;
run;
data _odmcolumns_OIDs;
  merge _odmcolumns_OIDs  _odmcdescs;
  by cdescription;
run;
proc sort data = _odmcolumns_OIDs;
  by table column;
run;
*==============================================================================;
* Write the ItemGroupDef and ItemRef tags;
*==============================================================================;
proc sort data = _odmcolumns_oids;

  by    torder    table corder;

run;
data _null_;
  set _odmcolumns_oids;

  by    torder    table;

  file &outfile mod;
  if first.table then do;
    put
     "<!-- ************************************************************** -->" /
     "<!-- Defining ItemGroupDef for data set " table "                   -->" /
     "<!-- ************************************************************** -->" /
     '<ItemGroupDef OID="' table_oid +(-1) '"'
     ' Name="' table +(-1) '"';

%* need to add StudyIdentifierOID attribute to ItemGroupDef ?;
%*    put " StudyIdentifierOID=""&studyname"" ";

    if Repeating ^= ' ' then put ' Repeating="' repeating +(-1) '"';
    if IsReferenceData ^= ' ' then
     put ' IsReferenceData="' IsReferenceData +(-1) '"';
    if tshort ^= ' ' then put ' SASDatasetName="' tshort +(-1) '"';
    else put ' SASDatasetName="' table +(-1) '"';
    if Domain ^= ' ' then put ' Domain="' Domain +(-1) '"';

%*    if Origin ^= ' ' then put ' Origin="' Origin +(-1) '"';

    if purpose ^= ' ' then put ' Purpose="' purpose +(-1) '"';

%* comment - get this from tdescription or is that too long?;

    if tlabel ^= ' ' then put " &crt_prefix:Label=""" tlabel +(-1) '"';
    if Structure ^= ' ' then
     put " &crt_prefix:Structure=""" Structure +(-1) '"';
    if cpkeylist ^= ' ' then
     put " &crt_prefix:DomainKeys=""" cpkeylist +(-1) '"';
    if class ^= ' ' then put " &crt_prefix:Class=""" class +(-1) '"';

    if table_oid ^= ' ' then
     put " &crt_prefix:ArchiveLocationID=""Location." table_oid +(-1) '"';

    put '>';
  end;
  put '<!-- ItemRef in data set ' table 'for variable ' column '-->' /
   ' <ItemRef ItemOID="' column_oid +(-1) '"';
  if corder ^= . then put '  OrderNumber="' corder +(-1) '"';
  put '  Mandatory="' Mandatory +(-1) '"';
  if cpkey ^= . then put '  KeySequence="' cpkey +(-1) '"';


%* This did not pass validation - why? ;
  if MethodDefOID ^= ' ' then put ' MethodOID="' MethodDefOID +(-1) '"';

%* Role cannot be a comma delimited list according to schema and did not 
   validate this may be a schema problem;

  if role ^= ' ' then do;
    if index(role,',') > 0 then Role = left(compbl(translate(Role,' ',',')));
    put '  Role="' role +(-1) '"';
    if rolecodelistOID ^= ' ' then
     put '  RoleCodeListOID="' rolecodelistoid +(-1) '"';
  end;

  %* CollectionExceptionConditionOID;

  put ' />';
  if last.table then do;

    if location ^= ' ' then put 
     " <&crt_prefix:leaf ID=""Location." table_oid +(-1) '" '
     'xlink:href="' location +(-1) '">' /
     " <&crt_prefix:title>" location "</&crt_prefix:title>" /
     " </&crt_prefix:leaf>"
    ;

    %* else put    location is required !;

    put '</ItemGroupDef>';
  end;
run;
*==============================================================================;
* Write the ItemDef tags;
*==============================================================================;
proc sort data = _odmcolumns_oids;
  by column_oid_sort;
run;
data _null_;
  set _odmcolumns_oids;
  file &outfile mod;
  if _n_ = 1 then put
   "<!-- **************************************************************** -->" /
   "<!-- Defining ItemDef for all variables                               -->" /
   "<!-- **************************************************************** -->"
  ;
   put '<ItemDef OID="' column_oid +(-1) '" Name="' column +(-1) '"';
   put ' DataType="' datatype +(-1) '"';
   if clength ^= . then put ' Length="' clength '"';
   if significantdigits ^= ' ' then
    put ' SignificantDigits="' +(-1) significantdigits +(-1) '"';

%* why is column and cshort both missing sometimes?;
   if cshort ^= ' ' then put ' SASFieldName="' cshort +(-1) '"';
   else if column ^= ' ' then put ' SASFieldName="' column +(-1) '"';

   if SDSVarName ^= ' ' then put ' SDSVarName="' SDSVarName +(-1) '"';

   if Origin ^= ' ' then put ' Origin="' Origin +(-1) '"';

   if Comment ^= ' ' then put ' Comment="' Comment +(-1) '"';
   if clabel ^= ' ' then put " &crt_prefix:Label=""" clabel +(-1) '"';
   if displayformat ^= ' ' then
    put " &crt_prefix:DisplayFormat=""" displayformat +(-1) '"';
   put '>';
   if codelist_OID ^= ' ' then put
    ' <CodeListRef CodeListOID="' codelist_OID +(-1) '"/>';

%*   if ValueListOID ^= ' ' then
    put " <ValueListRef &crt_prefix:ValueListOID=""" ValueListOID +(-1) '"/>';

   put '</ItemDef>';
run;

proc sort data = _odmvalues_OIDs;
  by format DataType start;
run;
proc print;
  by format;
run;
data _null_;
  set _odmvalues_OIDs;
  by format DataType;
  file &outfile mod;
  if _n_ = 1 then put
   "<!-- **************************************************************** -->" /
   "<!-- Defining CodeList elements                                       -->" /
   "<!-- **************************************************************** -->"
  ;
/*
  do cltype = 1 to 2;
    length codelist_OID $ 25;
    if cltype = 1 & codelist_OIDn ^= ' ' then codelist_OID = codelist_OIDn;
    else if cltype = 2 & codelist_OIDc ^= ' ' then codelist_OID = codelist_OIDc;
    else codelist_OID = ' ';
*/

    if codelist_OID ^= ' ' then do;

%* Should SASFormatName include leading $ ?;

      if first.DataType then put
       '<CodeList OID="' codelist_OID +(-1) '"' /
       ' Name="' format +(-1) '"' /
       ' DataType="' datatype +(-1) '"' /
       ' SASFormatName="' format +(-1) '"' /
       '>'
      ;

%* make sure var length is adequate for new expanded value;

      start_encode = start || repeat(' ',200);
      end_encode = end || repeat(' ',200);
      %if &sysver = 8.2 %then %do;
        start_encode = htmlencode(start);
        start_encode = tranwrd(start_encode,'"','&quot;');
        end_encode = htmlencode(end);
        end_encode = tranwrd(end_encode,'"','&quot;');
      %end;
      %else %do;
        start_encode = htmlencode(start,'amp gt lt apos quot');
        end_encode = htmlencode(end,'amp gt lt apos quot');
      %end;

      *------------------------------------------------------------------------;
      * Generate element for CodeListItem, EnumeratedItem or RangeCheck;
      *------------------------------------------------------------------------;
      if codelist_type = 'codelist' then do;

        flabel_encode = flabel || repeat(' ',200);
        %if &sysver = 8.2 %then %do;
          flabel_encode = htmlencode(flabel);
          flabel_encode = tranwrd(flabel_encode,'"','&quot;');
        %end;
        %else %do;
          flabel_encode = htmlencode(flabel,'amp gt lt apos quot');
        %end;

        put ' <CodeListItem CodedValue="' start_encode +(-1) '" ';
        if rorder ^= . then put "Rank=""" rorder +(-1) '"';
        put '>' /
         '  <Decode> <TranslatedText xml:lang="en">' flabel_encode +(-1)
         '  </TranslatedText></Decode>' / ' </CodeListItem>';
      end;
      else if codelist_type = 'enumerated' then do;
        put ' <EnumeratedItem CodedValue="' start_encode +(-1) '" />';
      end;
      else if codelist_type = 'rangecheck' then do;

%* Assuming the comparators here as GE and LE - need more metadata;

        put ' <RangeCheck';
        if start ^= ' ' then put 'Comparator="GE" SoftHard="Soft">' /
         '  <CheckValue>' start_encode '/CheckValue>';
        if end   ^= ' ' then put 'Comparator="LE" SoftHard="Soft">' /
         '  <CheckValue>' end_encode '</CheckValue>';
        put '</RangeCheck>';
      end;
      if last.DataType then put '</CodeList>';
    end;
* end;
run;
*==============================================================================;
* Create MethodDef elements;
*==============================================================================;
filename _odmdcat catalog "work._odmdescriptions";
%let numentries = 0;
data _null_;
  if eof then call symput('numentries',trim(left(put(entry,8.0))));
  set _odmcdescs end=eof;
  entry + 1;
  call symput('entry' || trim(left(put(entry,8.0))),trim(left(cdescription)));
  call symput('cmeth' || trim(left(put(entry,8.0))),
   trim(left(MethodDefOID)));
  call symput('MethodDefType' || trim(left(put(entry,8.0))),
   trim(left(MethodDefType)));
run;
%if &numentries > 0 %then %do;
  data _null_;
    file &outfile mod;
    if _n_ = 1 then put
     "<!-- ************************************************************** -->" /
     "<!-- Defining MethodDef                                             -->" /
     "<!-- ************************************************************** -->"
    ;
    stop;
  run;
  %do entrynum = 1 %to &numentries;
    data _null_;
      file &outfile mod;
      if _n_ = 1 then put
       "<MethodDef OID=""&&cmeth&entrynum"" Name=""&&entry&entrynum"" "
       "Type=""&&MethodDefType&entrynum"">";
      infile _odmdcat(&&entry&entrynum...source) end=eof length=entrylen;
      input @1 line $varying200. entrylen;
      if _n_ = 1 & upcase(left(line)) ^=: 'DETAILED DESCRIPTION' then do;
        ODMelement = 'Description     ';
        put ' <Description>' / '  <TranslatedText xml:lang="en">';
      end;
      else if upcase(left(line)) =: 'DETAILED DESCRIPTION' then do;
        if ODMelement = 'Description' then
         put '  </TranslatedText>' / ' </Description>';
        put ' <FormalExpression>';
        ODMelement = 'FormalExpression';
      end;

%* make sure var length is adequate for new expanded value;
      line_encode = line || repeat(' ',200);
      %if &sysver = 8.2 %then %do;
        line_encode = htmlencode(line);
        line_encode = tranwrd(line_encode,'"','&quot;');
      %end;
      %else %do;
        line_encode = htmlencode(line,'amp gt lt apos quot');
      %end;

      curlinelen = length(line_encode);
      put line_encode $varying200. curlinelen;
      if eof then do;
        if ODMelement = 'Description' then
         put '  </TranslatedText>' / ' </Description>';
        else if ODMelement = 'FormalExpression' then put ' </FormalExpression>';
        put '</MethodDef>';
      end;
      retain ODMelement;
    run;
  %end;
%end;
filename _odmdcat clear;
*==============================================================================;
* Close the container elements;
*==============================================================================;
data _null_;
  file &outfile mod;
  if _n_ = 1 then put
   "<!-- **************************************************************** -->" /
   "<!-- Close the container elements                                     -->" /
   "<!-- **************************************************************** -->"
  ;
  put
   '</MetaDataVersion>' /
   '</Study>' /
   '</ODM>' /
  ;
  stop;
run;
%if ^ &debug %then %do;
  proc datasets lib=work nolist;
    delete _odm:;
  run; quit;
%end;
%endmac:
%mend;
