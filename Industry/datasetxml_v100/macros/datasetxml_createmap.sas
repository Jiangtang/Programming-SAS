%* datasetxml_createmap                                                           *;
%*                                                                                *;
%* Creates XML maps required by the Dataset-XML read and write macros.            *;
%*                                                                                *;
%* @macvar _cstDebug Turns debugging on or off for the session. Set _cstDebug=1   *;
%*             before this macro call to retain work files created by this macro. *;
%*                                                                                *;
%* @param _cstMapFile - required - The path to the XML map file to create.        *;
%* @param _cstMapType - required - The type of XML map file to create.            *;
%*            Values:  metamap | datamap                                          *;
%*            Default: metamap                                                    *;
%* @param _cstMapVersion - required - The version of the XML map file to create.  *;
%*            Default: 1.9                                                        *;
%* @param _cstOutputEncoding - optional - The XML encoding to use for the         *;
%*            XML map file to create.                                             *;
%*            Default: UTF-8                                                      *;
%* @param _cstValueLength - required - The length of the Value attribute.         *;
%* @param _cstNameSpace - optional - The extension namespace.                     *;
%*            Default: UTF-8                                                      *;
%*                                                                                *;
%* @since  1.7                                                                    *;
%* @exposure internal                                                             *;

%macro datasetxml_createmap(
  _cstMapFile=,
  _cstMapType=metamap,
  _cstMapVersion=1.9,
  _cstOutputEncoding=UTF-8,
  _cstValueLength=2000,
  _cstNameSpace=def:
  ) / des="CST: Create Dataset-XML file from SAS";

  %*************************************************;
  %*  Check for existence of _cstDebug             *;
  %*************************************************;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;

  %if %sysevalf(%superq(_cstMapFile)=, boolean) or
    %sysevalf(%superq(_cstMapType)=, boolean) or
    %sysevalf(%superq(_cstMapVersion)=, boolean) or
    %sysevalf(%superq(_cstValueLength)=, boolean)
    %then 
    %do;
      %put ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] _cstMapFile, _cstMapType, _cstMapVersion %str
        ()and _cstValueLength must be specified.;
      %goto exit_error;
    %end;  
    
  %if %sysfunc(kverify(&_cstValueLength,'0123456789'))>0 %then
  %do;
    %* Rule: _cstValueLength must be integer   *;
      %put ERR%str(OR): [CSTLOG%str(MESSAGE).&sysmacroname] _cstNumObsWrite must be set to an integer.;
      %goto exit_error;
  %end;

  %local _cstRandom;
  
  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));
  
  %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Creating &_cstMapFile;

  *** Create Map;
  proc sql;
    create table work.sxlemap&_cstRandom(
      table  char(32),
      tablepath char(200),
      tableendpath char(200),
      tablebeginend char(5),
      column char(32),
      columnclass char(20),
      columnpath char(200),
      columnretain char(3),
      columntype char(20),
      columndatatype char(20),
      columnlength num
    )
    ;

    %if %upcase(&_cstMapType) eq DATAMAP %then 
    %do;
      insert into work.sxlemap&_cstRandom
        values("ODM", "/ODM", "", "", "FileOID",            "", "/ODM/@FileOID", "", "character", "string", 128)
        values("ODM", "/ODM", "", "", "CreationDateTime",   "", "/ODM/@CreationDateTime", "", "character", "string", 32)
        values("ODM", "/ODM", "", "", "FileType",           "", "/ODM/@FileType", "", "character", "string", 13)
        values("ODM", "/ODM", "", "", "ODMVersion",         "", "/ODM/@ODMVersion", "", "character", "string", 32)
        values("ODM", "/ODM", "", "", "PriorFileOID",       "", "/ODM/@PriorFileOID", "", "character", "string", 128)
        values("ODM", "/ODM", "", "", "DatasetXMLVersion",  "", "/ODM/@&_cstNameSpace.DatasetXMLVersion", "", "character", "string", 32)

        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "StudyOID",           "",        "/ODM/ClinicalData/@StudyOID", "Yes", "character", "string", 128)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "MetaDataVersionOID", "",        "/ODM/ClinicalData/@MetaDataVersionOID", "Yes", "character", "string", 128)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "ItemGroupOID",       "",        "/ODM/ClinicalData/ItemGroupData/@ItemGroupOID", "Yes", "character", "string", 128)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "ItemGroupDataSeq",   "",        "/ODM/ClinicalData/ItemGroupData/@&_cstNameSpace.ItemGroupDataSeq", "Yes", "numeric", "integer", .)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "CalculatedSeq",      "ORDINAL", "/ODM/ClinicalData/ItemGroupData", "Yes", "numeric", "integer", .)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "ItemOID",            "",        "/ODM/ClinicalData/ItemGroupData/ItemData/@ItemOID", " ", "character", "string", 128)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "Value",              "",        "/ODM/ClinicalData/ItemGroupData/ItemData/@Value", " ", "character", "string", &_cstValueLength)
        values("ClinicalItemData", "/ODM/ClinicalData/ItemGroupData/ItemData", "", "", "FK_ODM",             "",        "/ODM/@FileOID", "Yes", "character", "string", 128)

        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "StudyOID",           "",        "/ODM/ReferenceData/@StudyOID", "Yes", "character", "string", 128)
        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "MetaDataVersionOID", "",        "/ODM/ReferenceData/@MetaDataVersionOID", "Yes", "character", "string", 128)
        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "ItemGroupOID",       "",        "/ODM/ReferenceData/ItemGroupData/@ItemGroupOID", "Yes", "character", "string", 128)
        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "ItemGroupDataSeq",   "",        "/ODM/ReferenceData/ItemGroupData/@&_cstNameSpace.ItemGroupDataSeq", "Yes", "numeric", "integer", .)
        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "CalculatedSeq",      "ORDINAL", "/ODM/ReferenceData/ItemGroupData", "Yes", "numeric", "integer", .)
        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "ItemOID",            "",        "/ODM/ReferenceData/ItemGroupData/ItemData/@ItemOID", " ", "character", "string", 128)
        values("ReferenceItemData", "/ODM/ReferenceData/ItemGroupData/ItemData", "/ODM/ClinicalData", "BEGIN", "Value",              "",        "/ODM/ReferenceData/ItemGroupData/ItemData/@Value", " ", "character", "string", &_cstValueLength)
        values("ReferenceItemData", "/ODM/ClinicalData/ItemGroupData/ItemData",  "/ODM/ClinicalData", "BEGIN", "FK_ODM",             "",        "/ODM/@FileOID", "Yes", "character", "string", 128)

    ;
    %end;
    
    %if %upcase(&_cstMapType) eq METAMAP %then 
    %do;
      insert into work.sxlemap&_cstRandom
        values("DefineDocument", "/ODM", "", "", "FileOID",          "", "/ODM/@FileOID", " ", "character", "string", 128)
        values("DefineDocument", "/ODM", "", "", "CreationDateTime", "", "/ODM/@CreationDateTime", "", "character", "string", 32)

        values("Study", "/ODM/Study", "", "", "OID",               "", "/ODM/Study/@OID", " ", "character", "string", 128)
        values("Study", "/ODM/Study", "", "", "StudyName",         "", "/ODM/Study/GlobalVariables/StudyName", " ", "character", "string", 128)
        values("Study", "/ODM/Study", "", "", "StudyDescription",  "", "/ODM/Study/GlobalVariables/StudyDescription", " ", "character", "string", 2000)
        values("Study", "/ODM/Study", "", "", "ProtocolName",      "", "/ODM/Study/GlobalVariables/ProtocolName", " ", "character", "string", 128)
        values("Study", "/ODM/Study", "", "", "FK_DefineDocument", "", "/ODM/@FileOID", "YES", "character", "string", 128)

        values("MetaDataVersion", "/ODM/Study/MetaDataVersion", "", "", "OID",             "", "/ODM/Study/MetaDataVersion/@OID", " ", "character", "string", 128)
        values("MetaDataVersion", "/ODM/Study/MetaDataVersion", "", "", "DefineVersion",   "", "/ODM/Study/MetaDataVersion/@&_cstNameSpace.DefineVersion", " ", "character", "string", 2000)
        values("MetaDataVersion", "/ODM/Study/MetaDataVersion", "", "", "StandardName",    "", "/ODM/Study/MetaDataVersion/@&_cstNameSpace.StandardName", " ", "character", "string", 2000)
        values("MetaDataVersion", "/ODM/Study/MetaDataVersion", "", "", "StandardVersion", "", "/ODM/Study/MetaDataVersion/@&_cstNameSpace.StandardVersion", " ", "character", "string", 2000)
        values("MetaDataVersion", "/ODM/Study/MetaDataVersion", "", "", "FK_Study",        "", "/ODM/Study/@OID", "YES", "character", "string", 128)

        values("ItemGroupDefs", "/ODM/Study/MetaDataVersion/ItemGroupDef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "OID",                "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@OID", " ", "character", "string", 128)
        values("ItemGroupDefs", "/ODM/Study/MetaDataVersion/ItemGroupDef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "Name",               "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@Name", " ", "character", "string", 128)
        values("ItemGroupDefs", "/ODM/Study/MetaDataVersion/ItemGroupDef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "Label",              "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@&_cstNameSpace.Label", " ", "character", "string", 2000)
        values("ItemGroupDefs", "/ODM/Study/MetaDataVersion/ItemGroupDef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "SASDatasetName",     "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@SASDatasetName", " ", "character", "string", 32)
        values("ItemGroupDefs", "/ODM/Study/MetaDataVersion/ItemGroupDef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "IsReferenceData",    "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@IsReferenceData", " ", "character", "string", 3)
        values("ItemGroupDefs", "/ODM/Study/MetaDataVersion/ItemGroupDef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "FK_MetadataVersion", "", "/ODM/Study/MetaDataVersion/@OID", "YES", "character", "string", 128)

        values("itemgroupitemrefs", "/ODM/Study/MetaDataVersion/ItemGroupDef/ItemRef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "ItemOID",          "", "/ODM/Study/MetaDataVersion/ItemGroupDef/ItemRef/@ItemOID", " ", "character", "string", 128)
        values("itemgroupitemrefs", "/ODM/Study/MetaDataVersion/ItemGroupDef/ItemRef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "OrderNumber",      "", "/ODM/Study/MetaDataVersion/ItemGroupDef/ItemRef/@OrderNumber", " ", "numeric", "integer", .)
        values("itemgroupitemrefs", "/ODM/Study/MetaDataVersion/ItemGroupDef/ItemRef", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "FK_ItemGroupDefs", "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@OID", "YES", "character", "string", 128)

        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "OID",                "", "/ODM/Study/MetaDataVersion/ItemDef/@OID", " ", "character", "string", 128)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "Name",               "", "/ODM/Study/MetaDataVersion/ItemDef/@Name", " ", "character", "string", 128)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "Label",              "", "/ODM/Study/MetaDataVersion/ItemDef/@&_cstNameSpace.Label", " ", "character", "string", 2000)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "SASFieldName",       "", "/ODM/Study/MetaDataVersion/ItemDef/@SASFieldName", " ", "character", "string", 32)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "Length",             "", "/ODM/Study/MetaDataVersion/ItemDef/@Length", " ", "numeric", "integer", .)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "DataType",           "", "/ODM/Study/MetaDataVersion/ItemDef/@DataType", " ", "character", "string", 18)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "DisplayFormat",      "", "/ODM/Study/MetaDataVersion/ItemDef/@&_cstNameSpace.DisplayFormat", " ", "character", "string", 32)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "SignificantDigits",  "", "/ODM/Study/MetaDataVersion/ItemDef/@SignificantDigits", " ", "numeric", "integer", .)
        values("ItemDefs", "/ODM/Study/MetaDataVersion/ItemDef", "/ODM/Study/MetaDataVersion/CodeList", "BEGIN", "FK_MetadataVersion", "", "/ODM/Study/MetaDataVersion/@OID", "YES", "character", "string", 128)

        values("ItemGroupDefTranslatedText", "/ODM/Study/MetaDataVersion/ItemGroupDef/Description/TranslatedText", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "TranslatedText",  "", "/ODM/Study/MetaDataVersion/ItemGroupDef/Description/TranslatedText", "", "character", "string", 2000)
        values("ItemGroupDefTranslatedText", "/ODM/Study/MetaDataVersion/ItemGroupDef/Description/TranslatedText", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "Lang",            "", "/ODM/Study/MetaDataVersion/ItemGroupDef/Description/TranslatedText/@xml:lang", "", "character", "string", 17)
        values("ItemGroupDefTranslatedText", "/ODM/Study/MetaDataVersion/ItemGroupDef/Description/TranslatedText", "/ODM/Study/MetaDataVersion/ItemDef", "BEGIN", "FK_ItemGroupDef", "", "/ODM/Study/MetaDataVersion/ItemGroupDef/@OID", "Yes", "character", "string", 128)
        
        values("ItemDefTranslatedText", "/ODM/Study/MetaDataVersion/ItemDef/Description/TranslatedText", "", "", "TranslatedText", "", "/ODM/Study/MetaDataVersion/ItemDef/Description/TranslatedText", "", "character", "string", 2000)
        values("ItemDefTranslatedText", "/ODM/Study/MetaDataVersion/ItemDef/Description/TranslatedText", "", "", "Lang",           "", "/ODM/Study/MetaDataVersion/ItemDef/Description/TranslatedText/@xml:lang", "", "character", "string", 17)
        values("ItemDefTranslatedText", "/ODM/Study/MetaDataVersion/ItemDef/Description/TranslatedText", "", "", "FK_ItemDef",     "", "/ODM/Study/MetaDataVersion/ItemDef/@OID", "Yes", "character", "string", 128)
    ;
  %end;
  quit;
  
  data _null_;
    set work.sxlemap&_cstRandom end=end;
    by table notsorted;
    file "&_cstMapFile";
    if _n_=1 then do;
      %if %sysevalf(%superq(_cstOutputEncoding)=, boolean) %then 
      %do;
        put '<?xml version="1.0" ?>';
      %end;
      %else 
      %do;
        put '<?xml version="1.0" encoding="' "&_cstOutputEncoding" '"?>';
      %end;  
      put '<SXLEMAP name="' "&_cstMapType" '" version="' "&_cstMapVersion" '">';
    end;
    if first.table then do;
      put '  <TABLE name="' table +(-1) '">';
      put '    <TABLE-PATH syntax="XPath">' tablepath +(-1) '</TABLE-PATH>';
      if not missing(tableendpath) then
        put '    <TABLE-END-PATH beginend="' tablebeginend +(-1) '" syntax="XPath">' tableendpath +(-1) '</TABLE-END-PATH>';
    end;
  
    put '    <COLUMN name="' column +(-1) '"' @;  
    if not missing(columnclass) then put ' class="' columnclass +(-1)'"' @;
    If upcase(columnretain)="YES" then put ' retain="YES"' @;
    put '>';
    select(upcase(columnclass));
      when ("ORDINAL") put '      <INCREMENT-PATH beginend="BEGIN" syntax="XPath">' columnpath +(-1) '</INCREMENT-PATH>';
      otherwise        put '      <PATH syntax="XPath">' columnpath +(-1) '</PATH>';
    end;
    put '      <TYPE>' columntype +(-1) '</TYPE>';
    put '      <DATATYPE>' columndatatype +(-1) '</DATATYPE>';
    if not missing(columnlength) then put '      <LENGTH>' columnlength +(-1) '</LENGTH>';
    put '    </COLUMN>';
  
    if last.table then put '  </TABLE>';
    if end then put '</SXLEMAP>';
  
  run;

  proc datasets lib=work nolist;
    delete sxlemap&_cstRandom;
  quit;
  run;

%exit_macro:

%mend datasetxml_createmap;
