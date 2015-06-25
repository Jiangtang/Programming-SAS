%* datasetxml_read                                                                *;
%*                                                                                *;
%* Creates a SAS data set or a library of SAS data sets from Dataset-XML files.   *;
%*                                                                                *;
%* Notes:                                                                         *;
%*   1. Any librefs referenced in the macro parameters must be pre-allocated.     *;
%*   2. Files that exist in the output location are overwritten.                  *;
%*   3. Either _cstSourceDatasetXMLFile or _cstSourceDatasetXMLLibrary must be    *;
%*      specified. If neither of these parameters is specified, the macro         *;
%*      attempts to get these parameter values from the SASReferences data set    *;
%*      that is specified by the macro variable _cstSASRefs (type=externalxml).   *;
%*      When multiple type=externalxml records are specified, filenames must be   *;
%*      defined (with reftype=fileref and filetype=file). If no filenames are     *;
%*      specified, only the first record is used, and reftype=libref,             *;
%*      filetype=folder must be used.                                             *;
%*   4. _cstOutputLibrary must be specified. If this parameter is not specified,  *;
%*      the macro attempts to get this parameter value from the SASReferences     *;
%*      data set that is specified by the macro variable _cstSASRefs              *;
%*      (type=targetdata, reftype=libref, filetype=folder).                       *;
%*   5. _cstSourceMetadataLibrary, _cstSourceMetadataDefineFile, or               *;
%*      _cstSourceMetadataDefineFileRef must be specified.                        *;
%*      If none of these parameters is specified, the macro first attempts to get *;
%*      _cstSourceMetadataLibrary from the SASReferences data set that is         *;
%*      specified by the macro variable _cstSASRefs (type=sourcemetadata,         *;
%*      subtype=, reftype=libref, filetype=folder).                               *;
%*      If that fails, the macro attempts to get _cstSourceMetadataDefineFileRef  *;
%*      from _cstSASRefs (type=sourcemetadata, subtyp=, reftype=fileref,          *;
%*      filetype=folder).                                                         *;
%*   6. If _cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef is     *;
%*      specified, _cstSourceMetadataMapFile must be specified. If this parameter *;
%*      is not specified, the macro attempts to get this parameter value from the *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=referencexml, subtype=metamap, reftype=fileref,         *;
%*      filetype=file).                                                           *;
%*      If the XML map file cannot be found, the datasetxml_createmap macro is    *;
%*      used to create the XML map file (_cstMapType=metamap).                    *;
%*   7. _cstSourceDataMapFile must be specified. If this parameter is not         *;
%*      specified, the macro attempts to get the parameter value from the         *;
%*      SASReferences data set that is specified by the macro variable            *;
%*      _cstSASRefs (type=referencexml, subtype=datamap, reftype=fileref,         *;
%*      filetype=file).                                                           *;
%*      If the XML map file is not found, the datasetxml_createmap macro is used  *;
%*      to create the XML map file (_cstMapType=datamap).                         *;
%*   8. If _cstSourceMetadataLibrary is specified, these data sets must exist in  *;
%*      this library:                                                             *;
%*        definedocument                                                          *;
%*        study                                                                   *;
%*        metadataversion                                                         *;
%*        itemgroupdefs                                                           *;
%*        itemgroupdefitemrefs (CRT-DDS 1.0)                                      *;
%*        itemgroupitemrefs (Define-XML 2.0)                                      *;
%*        itemdefs                                                                *;
%*        translatedtext (Define-XML 2.0)                                         *;
%*   9. The Define-XML metadata is used to look up ItemGroupDef/@OID and          *;
%*      ItemDef/@OID based on the data set name and variable name.                *;
%*                                                                                *;
%* @macvar _cstDebug Turns debugging on or off for the session. Set _cstDebug=1   *;
%*             before this macro call to retain work files created in this macro. *;
%* @macvar _cst_rc Task error status                                              *;
%* @macvar _cst_rcmsg Message associated with _cst_rc                             *;
%* @macvar _cstResultSeq Results: Unique invocation of macro                      *;
%* @macvar _cstSeqCnt Results: Sequence number within _cstResultSeq               *;
%* @macvar &_cstLRECL File record length                                          *;
%* @macvar _cstStandard Name of a standard registered to the SAS Clinical         *;
%*             Standards Toolkit                                                  *;
%* @macvar _cstStandardVersion Version of the standard referenced in _cstStandard *;
%*                                                                                *;
%* @param _cstSourceDatasetXMLFile - conditional - The complete path to the       *;
%*            the Dataset-XML file to convert.                                    *;
%*            Required if _cstSourceLibrary is not specified.                     *;
%* @param _cstSourceDatasetXMLLibrary - conditional - The libref of the source    *;
%*            DatasetXML folder/library. Required if _cstSourceDatasetXMLFile is  *;
%*            not specified.                                                      *;
%* @param _cstOutputLibrary - required - The libref of the output data folder/    *;
%*            library in which to create the dataset-XML files.                   *;
%* @param _cstSourceMetadataLibrary - conditional - The libref of the source      *;
%*            metadata folder/library.                                            *;
%* @param _cstSourceMetadataDefineFile - conditional - The path to the Define-XML *;
%*            file.                                                               *;
%* @param _cstSourceMetadataDefineFileRef - conditional - The file reference that *;
%*            specifies the location of the Define-XML file.                      *;
%* @param _cstSourceMetadataMapFile - conditional - The path to the map file to   *;
%*            read Define-XML metadata from an XML file.                          *;
%*            If not specified, the value is derived from SASReferences or is     *;
%*            created.                                                            *;
%* @param _cstSourceDataMapFile - optional - The path to the map file to read     *;
%*            Dataset-XML data from an Dataset-XML file.                          *;
%*            If not specified, the value is derived from SASReferences or is     *;
%*            created.                                                            *;
%* @param _cstMaxLabelLength - required - The maximum length of labels to create. *;
%*            Default: 256                                                        *;
%* @param _cstdatetimeLength - required - The length of date- and time-related    *;
%*            variables to create.                                                *;
%*            Default: 64                                                         *;
%* @param _cstAttachFormats - optional - Attach formats to the data.              *;
%*            These are the formats as defined in the ItemDef/@DisplayFormat      *;
%*            Define-XML attribute.                                               *;
%*            Values: Y | N                                                       *;
%*            Default:  Y                                                         *;
%* @param _cstNumObsWrite - required - The maximum number of observations to      *;
%*            write in the final data STEP (per loop). This can be used for       *;
%*            performance tuning.                                                 *;
%*            Default:  10000                                                     *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @history 2014-09-16 Removed the _cstNumObsWrite parameter.                     *;
%* @history 2014-10-13 Replace xmlv2 for Dataset-XML with javaobj.                *;
%*                                                                                *;
%* @since  1.7                                                                    *;
%* @exposure external                                                             *;

%macro datasetxml_read(
  _cstSourceDatasetXMLFile=,
  _cstSourceDatasetXMLLibrary=,
  _cstOutputLibrary=,
  _cstSourceMetadataLibrary=,
  _cstSourceMetadataDefineFile=,
  _cstSourceMetadataDefineFileRef=,
  _cstSourceMetadataMapFile=,
  _cstSourceDataMapFile=,
  _cstMaxLabelLength=256,
  _cstdatetimeLength=64,
  _cstAttachFormats=Y,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des="CST: Create SAS dataset from Dataset-XML";


  %********************************************************************************;
  %* Local Support macros                                                         *; 
  %********************************************************************************;
  %macro cstutil_cstDeleteMember(_cstMember=, _cstFunction=exist, _cstMemtype=data);
  %local _cstRDir _cstRMem;
  %if (%length(&_cstMember)>0) %then %do;
    %if (%upcase(&_cstFunction) eq EXIST and (%sysfunc(&_cstFunction(&_cstMember, &_cstMemtype)))) or
        (%upcase(&_cstFunction) eq CEXIST and (%sysfunc(&_cstFunction(&_cstMember)))) %then 
    %do;
      %if %eval(%index(&_cstMember,.)>0) %then %do;
        %let _cstRDir=%scan(&_cstMember,1,.);
        %let _cstRMem=%scan(&_cstMember,2,.);
      %end;
      %else %do;
        %let _cstRDir=work;
        %let _cstRMem=&_cstMember;
      %end;
      %if %eval(&SYSVER GE 9.4) %then %do;
        proc delete lib=&_cstRDir data=&_cstRMem (memtype=&_cstMemtype);
        run;
      %end;
      %else %do;
        proc datasets nolist lib=&_cstRDir;
          delete &_cstRMem / mt=&_cstMemtype;
        run;
      %end;
    %end;
    %else %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] &_cstMember (&_cstMemtype) does not exist;
  %end;
  %mend cstutil_cstDeleteMember;
  
  %********************************************************************************;


  %local rc
         _cstParseClass
         _cstJavaPicklist        
         _cstSaveOptFmtErr
         _cstSaveOptQuoteLenMax
         _cstSaveOptMPrint
         _cstSaveOptCompress
         _cstSaveOptReUse
         _cstRandom
         _cstXMLEngine
         _cstNeedToDeleteMsgs
         _cstNeedToDeleteMetaMap
         _cstNeedToCreateDataMap
         _cstSrcMacro
         _cstExpSrcTables
         _cstTableLabel
         _cstTableName
         _cstMissing
         _cstLengthIssues
         _cstInvalidYN
         _cstYN
         _cstMacParam
         _cstCounter
         _cstMaxValueLength
         _cstMaxTextLength
         _cstTable
         _cstItemGroupItemRef
         _cstSourceDatasetXMLsasref
         _cstSourceDatasetXMLmember
         _cstSourceOutputsasref
         _cstSourceMetadatasasref
         _cstSourceMetadatamember
         _cstMetadataSource
         _cstMapFileRef
         _cstMetadataCleanup
         _cstFileOID
         _cstStudyOID
         _cstStudyOID_meta
         _cstMetadataVersionOID
         _cstMetadataVersionOID_meta
         _cstDefineVersion
         _cstDefineStandardName
         _cstDefineStandardVersion
         _cstItemGroupOID
         _cstIsReferenceData
         _cstPathDelim
         _cstNobs
         _cstElapsed
         _cstThisMacroRC
         _cstThisMacroRCMsg

         _cstTypeSourceData
         _cstTypeSourceMetaData
         _cstTypeTargetData
         _cstTypeExtXML
         _cstTypeRefXML
         _cstSubtypeMetaMap
         _cstSubtypeDataMap
         _cstDatasetXMLTempFile
         _cstDelimeter
         ;

  %* retrieve static variables;
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_SOURCEDATA,_cstVar=_cstTypeSourceData);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_SOURCEMETADATA,_cstVar=_cstTypeSourceMetaData);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_TARGETDATA,_cstVar=_cstTypeTargetData);

  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_EXTXML,_cstVar=_cstTypeExtXML);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_REFXML,_cstVar=_cstTypeRefXML);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_SUBTYPE_METAMAP,_cstVar=_cstSubtypeMetaMap);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_SUBTYPE_DATAMAP,_cstVar=_cstSubtypeDataMap);

  %datasetxml_getStatic(_cstName=DATASET_JAVA_PARSEXML,_cstVar=_cstParseClass);
  %datasetxml_getStatic(_cstName=DATASET_JAVA_PICKLIST,_cstVar=_cstJavaPicklist);

  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));
  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstSrcMacro=&SYSMACRONAME;
  %let _cstMetadataCleanup=0;
  %let _cstNeedToDeleteMetaMap=0;
  %let _cstNeedToCreateDataMap=0;
  
  %let _cstMaxTextLength=0;
  %let _cstMaxValueLength=0;

  %let _cstSaveOptQuoteLenMax=%sysfunc(getoption(QuoteLenMax));
  %let _cstSaveOptMPrint=%sysfunc(getoption(MPrint));
  %let _cstSaveOptCompress=%sysfunc(getoption(Compress, keyword));
  %let _cstSaveOptReuse=%sysfunc(getoption(Reuse, keyword));
  options compress=yes reuse=yes;
  %* Turn off format errors;
  %let _cstSaveOptFmtErr=%sysfunc(getoption(fmterr));
  options nofmterr;

  %if  &sysscp ^= WIN
    %then %let _cstPathDelim=/;
    %else %let _cstPathDelim=\;

  %* Determine XML engine;
  %let _cstXMLEngine=xml;
  %if %eval(&SYSVER EQ 9.2) %then %let _cstXMLEngine=xml92;
  %if %eval(&SYSVER GE 9.3) %then %let _cstXMLEngine=xmlv2;

  %***************************************************;
  %*  Check _cstReturn and _cstReturnMsg parameters  *;
  %***************************************************;
  %if (%length(&_cstReturn)=0) or (%length(&_cstReturnMsg)=0) %then
  %do;
    %* We are not able to communicate other than to the LOG;
    %put [CSTLOG%str(MESSAGE).&sysmacroname] ERR%str(OR): %str
      ()macro parameters _CSTRETURN and _CSTRETURNMSG can not be missing.;
    %goto exit_macro_nomsg;
  %end;

  %if (%eval(not %symexist(&_cstReturn))) %then %global &_cstReturn;
  %if (%eval(not %symexist(&_cstReturnMsg))) %then %global &_cstReturnMsg;

  %*************************************************;
  %*  Set _cstReturn and _cstReturnMsg parameters  *;
  %*************************************************;
  %let &_cstReturn=0;
  %let &_cstReturnMsg=;

  %*************************************************;
  %*  Check for existence of _cstDebug             *;
  %*************************************************;
  %if ^%symexist(_cstDeBug) %then
  %do;
    %global _cstDeBug;
    %let _cstDebug=0;
  %end;

  %*************************************************;
  %*  Check for existence of _cstLRECL             *;
  %*************************************************;
  %if ^%symexist(_cstLRECL) %then
  %do;
    %global _cstLRECL;
    %let _cstLRECL=%str(LRECL=2048);
  %end;

  %*********************;
  %*  Reporting setup  *;
  %*********************;

  %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
  %do;
    %if %symexist(_cstSASRefs) %then 
    %do;
      %* Create a temporary messages data set if required;
      %cstutil_createTempMessages(_cstCreationFlag=_cstNeedToDeleteMsgs);
    %end;
  %end;

  %************************;
  %* Parameter checking   *;
  %************************;

  %if %sysevalf(%superq(_cstMaxLabelLength)=, boolean) %then
  %do;
    %* Rule: _cstMaxLabelLength must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstMaxLabelLength must be specified.;
    %goto exit_error;
  %end;

  %if %sysevalf(%superq(_cstdatetimeLength)=, boolean) %then
  %do;
    %* Rule: _cstdatetimeLength must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstdatetimeLength must be specified.;
    %goto exit_error;
  %end;

  %if %sysfunc(kverify(&_cstMaxLabelLength,'0123456789'))>0 %then
  %do;
    %* Rule: _cstMaxLabelLength must be integer   *;
    %let &_cstReturn=1;
    %let _cst_rcmsg=_cstMaxLabelLength must be set to an integer.;
    %goto exit_error;
  %end;

  %if %sysfunc(kverify(&_cstdatetimeLength,'0123456789'))>0 %then
  %do;
    %* Rule: _cstdatetimeLength must be integer   *;
    %let &_cstReturn=1;
    %let _cst_rcmsg=_cstdatetimeLength must be set to an integer.;
    %goto exit_error;
  %end;

  %if %sysevalf(%superq(_cstSourceDatasetXMLFile)=, boolean) and
      %sysevalf(%superq(_cstSourceDatasetXMLLibrary)=, boolean) %then
  %do;

    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
    %do;
      %* Try getting the source location from the SASReferences file;
      %cstUtil_getSASReference(
        _cstStandard=%upcase(&_cstStandard),
        _cstStandardVersion=&_cstStandardVersion,
        _cstSASRefType=&_cstTypeExtXML,
        _cstSASRefsasref=_cstSourceDatasetXMLsasref,
        _cstSASRefmember=_cstSourceDatasetXMLmember,
        _cstConcatenate=0,
        _cstFullname=1,
        _cstAllowZeroObs=1
        );
    %end;

    %if %sysevalf(%superq(_cstSourceDatasetXMLsasref)=, boolean)=0 %then 
    %do;
      %* First assume that a library of Dataset-XML files is meant and we will only use the first;
      %if %sysfunc(libref(%scan(&_cstSourceDatasetXMLsasref, 1, %str( )))) eq 0 %then 
      %do;
        %let _cstSourceDatasetXMLLibrary=%scan(&_cstSourceDatasetXMLsasref, 1, %str( ));
      %end;
      %else 
      %do;
        %if %sysevalf(%superq(_cstSourceDatasetXMLmember)=, boolean)=0 %then 
        %do;
          %let _cstSourceDatasetXMLFile=;
          %let _cstSourceDatasetXMLFile=%sysfunc(pathname(&_cstSourceDatasetXMLsasref));
        %end;
      %end;
    %end;

  %end;

  %if %sysevalf(%superq(_cstSourceDatasetXMLFile)=, boolean) and
      %sysevalf(%superq(_cstSourceDatasetXMLLibrary)=, boolean) %then
  %do;
    %* Rule: Either _cstSourceDatasetXMLFile or _cstSourceDatasetXMLLibrary must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Either _cstSourceDatasetXMLFile or _cstSourceDatasetXMLLibrary must be specified.;
    %goto exit_error;
  %end;

  %if ((not %sysevalf(%superq(_cstSourceDatasetXMLFile)=, boolean)) and
       (not %sysevalf(%superq(_cstSourceDatasetXMLLibrary)=, boolean))) %then
  %do;
    %* Rule: _cstSourceDatasetXMLFile and _cstSourceDatasetXMLLibrary must not be specified both *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstSourceDatasetXMLFile and _cstSourceDatasetXMLLibrary must not be specified both.;
    %goto exit_error;
  %end;

  %if not %sysevalf(%superq(_cstSourceDatasetXMLLibrary)=, boolean) %then
  %do;
    %if %sysfunc(libref(&_cstSourceDatasetXMLLibrary)) %then
    %do;
      %* Rule: If _cstSourceDatasetXMLLibrary is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The libref _cstSourceDatasetXMLLibrary=&_cstSourceDatasetXMLLibrary has not been pre-allocated.;
      %goto exit_error;
    %end;
  %end;

  %if not %sysevalf(%superq(_cstSourceDatasetXMLFile)=, boolean) %then
  %do;
    %if not %sysfunc(fileexist(&_cstSourceDatasetXMLFile)) %then
    %do;
      %* Rule: If _cstSourceDatasetXMLFile is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The file _cstSourceDatasetXMLFile=&_cstSourceDatasetXMLFile does not exist.;
      %goto exit_error;
    %end;
  %end;

  

  %if %sysevalf(%superq(_cstOutputLibrary)=, boolean) %then
  %do;
    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the target location from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstStandard),
          _cstStandardVersion=&_cstStandardVersion,
          _cstSASRefType=&_cstTypeTargetData,
          _cstSASRefsasref=_cstSourceOutputsasref,
          _cstAllowZeroObs=1
          );
      %end;

    %if %sysevalf(%superq(_cstSourceOutputsasref)=, boolean)=0 %then
      %let _cstOutputLibrary=&_cstSourceOutputsasref;

    %if %sysevalf(%superq(_cstOutputLibrary)=, boolean) %then
    %do;
      %* Rule: _cstOutputLibrary must be specified  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=_cstOutputLibrary must be specified.;
      %goto exit_error;
    %end;
  %end;

  %if not %sysevalf(%superq(_cstOutputLibrary)=, boolean) %then
  %do;
    %if %sysfunc(libref(&_cstOutputLibrary)) %then
    %do;
      %* Rule: If _cstOutputLibrary is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The libref _cstOutputLibrary=&_cstOutputLibrary has not been pre-allocated.;
      %goto exit_error;
    %end;
  %end;


  %if %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean) and
      %sysevalf(%superq(_cstSourceMetadataDefineFile)=, boolean) and
      %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean) %then
  %do;
    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the _cstSourceMetadataLibrary from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstStandard),
          _cstStandardVersion=&_cstStandardVersion,
          _cstSASRefType=&_cstTypeSourceMetaData,
          _cstSASRefSubType=,
          _cstSASRefsasref=_cstSourceMetadatasasref,
          _cstSASRefmember=_cstSourceMetadatamember,
          _cstFullname=1,
          _cstAllowZeroObs=1
          );
      %end;

      %if %sysevalf(%superq(_cstSourceMetadatasasref)=, boolean)=0 %then
      %do;
        %if %sysfunc(libref(&_cstSourceMetadatasasref))=0
          %then %let _cstSourceMetadataLibrary=&_cstSourceMetadatasasref;
          %else %if (%sysfunc(fileref(&_cstSourceMetadatasasref))=0 and 
                     %sysevalf(%superq(_cstSourceMetadatamember)=, boolean)=0)
            %then %let _cstSourceMetadataDefineFileRef=&_cstSourceMetadatasasref;
      %end;

      %if %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean) and
          %sysevalf(%superq(_cstSourceMetadataDefineFile)=, boolean) and
          %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean) %then
      %do;
        %* Rule: Either _cstSourceMetadataLibrary, _cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef must be specified  *;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Either _cstSourceMetadataLibrary, _cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef must be specified.;
        %goto exit_error;
      %end;

  %end;

  %if ( ((not %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean)) and (not %sysevalf(%superq(_cstSourceMetadataDefineFile)=, boolean))) or
        ((not %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean)) and (not %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean))) or
        ((not %sysevalf(%superq(_cstSourceMetadataDefineFile)=, boolean)) and (not %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean)))
       ) %then
  %do;
    %* Rule: Only one of _cstSourceMetadataLibrary, _cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef must be specified *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=Only one of _cstSourceMetadataLibrary, _cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef must be specified.;
    %goto exit_error;
  %end;

  %if not %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean) %then
  %do;
    %if %sysfunc(libref(&_cstSourceMetadataLibrary)) %then
    %do;
      %* Rule: If _cstSourceMetadataLibrary is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The libref _cstSourceMetadataLibrary=&_cstSourceMetadataLibrary has not been pre-allocated.;
      %goto exit_error;
    %end;
    %else 
    %do;
      %* Rule: If _cstSourceMetadataLibrary exists, so certain data sets must exist  *;
      %let _cstExpSrcTables=definedocument study metadataversion itemgroupdefs itemdefs;
      %let _cstMissing=;
      %do _cstCounter=1 %to %sysfunc(countw(&_cstExpSrcTables, %str( )));
        %let _cstTable=%scan(&_cstExpSrcTables, &_cstCounter);
        %if not %sysfunc(exist(&_cstSourceMetadataLibrary..&_cstTable)) %then
          %let _cstMissing = &_cstMissing &_cstTable;
      %end;

      %if %length(&_cstMissing) gt 0
        %then 
        %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected source metadata data set(s) not existing in library &_cstSourceMetadataLibrary: &_cstMissing;
          %goto exit_error;
        %end;

      %if (not %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupdefitemrefs))) and
          (not %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupitemrefs)))
        %then 
        %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected source data set(s) not existing in library &_cstSourceMetadataLibrary: itemgroupdefitemrefs or itemgroupitemrefs;
          %goto exit_error;
      %end;
      %if (%sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupitemrefs))) and
          (not %sysfunc(exist(&_cstSourceMetadataLibrary..translatedtext)))
        %then 
        %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected source data set not existing in library &_cstSourceMetadataLibrary: translatedtext;
          %goto exit_error;
      %end;

    %end;
  %end;

  %if not %sysevalf(%superq(_cstSourceMetadataDefineFile)=, boolean) %then
  %do;
    %if not %sysfunc(fileexist(&_cstSourceMetadataDefineFile)) %then
    %do;
      %* Rule: If _cstSourceMetadataDefineFile is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The file _cstSourceMetadataDefineFile=&_cstSourceMetadataDefineFile does not exist.;
      %goto exit_error;
    %end;
  %end;

  %if not %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean) %then
  %do;
    %if %sysfunc(fileref(&_cstSourceMetadataDefineFileRef)) gt 0 %then
    %do;
      %* Rule: If _cstSourceMetadataDefineFileRef is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The file reference _cstSourceMetadataDefineFileRef=&_cstSourceMetadataDefineFileRef has not been allocated.;
      %goto exit_error;
    %end;

    %if %sysfunc(fileref(&_cstSourceMetadataDefineFileRef)) ne 0 %then
    %do;
      %* Rule: If _cstSourceMetadataDefineFileRef is specified, it must reference an existing file  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The file reference _cstSourceMetadataDefineFileRef=&_cstSourceMetadataDefineFileRef does not reference an existing file.;
      %goto exit_error;
    %end;
  %end;

  %*************************************************;
  %* Get Metadata XML Map File                     *;
  %*************************************************;
  %* Metadata needs to come from Define-XML file, so check for Map file *;
  %* Check for Metadata Map file *;
  %if (not %sysevalf(%superq(_cstSourceMetadataDefineFile)=, boolean)) or
      (not %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean)) %then
  %do;
    %if %sysevalf(%superq(_cstSourceMetadataMapFile)=, boolean) %then
    %do;
      %* Rule: If _cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef is specified, *;
      %*       then _cstSourceMetadataMapFile must be specified                                 *;

      %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
        %do;
          %* Try getting the mapfile location from the SASReferences file;
          %cstUtil_getSASReference(
            _cstStandard=%upcase(&_cstStandard),
            _cstStandardVersion=&_cstStandardVersion,
            _cstSASRefType=&_cstTypeRefXML,
            _cstSASRefSubType=&_cstSubtypeMetaMap,
            _cstSASRefsasref=_cstMapFileRef,
            _cstAllowZeroObs=1
            );
        %end;

      %if %sysevalf(%superq(_cstMapFileRef)=, boolean) %then
      %do;
        %* Create Map File;
        %let _cstSourceMetadataMapFile=%sysfunc(pathname(work))/define&_cstRandom..map;
        %datasetxml_createmap(
          _cstMapFile=&_cstSourceMetadataMapFile,
          _cstMapType=metamap
          );
        %let _cstNeedToDeleteMetaMap=1;
      %end;
      %else %do;
        %let _cstSourceMetadataMapFile=%sysfunc(pathname(&_cstMapFileRef));
      %end;
    %end;

    %if not %sysevalf(%superq(_cstSourceMetadataMapFile)=, boolean) %then
    %do;
      %if not %sysfunc(fileexist(&_cstSourceMetadataMapFile)) %then
      %do;
        %* Rule: If _cstSourceMetadataMapFile is specified, it must exist  *;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=The map file _cstSourceMetadataMapFile=&_cstSourceMetadataMapFile does not exist.;
        %goto exit_error;
      %end;
    %end;

  %end;

  %*************************************************;
  %* Get Data XML Map File                         *;
  %*************************************************;
  %* Check for Data Map file *;
  %if %sysevalf(%superq(_cstSourceDataMapFile)=, boolean) %then
  %do;

    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the mapfile location from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstStandard),
          _cstStandardVersion=&_cstStandardVersion,
          _cstSASRefType=&_cstTypeRefXML,
          _cstSASRefSubType=&_cstSubtypeDataMap,
          _cstSASRefsasref=_cstMapFileRef,
          _cstAllowZeroObs=1
          );
      %end;

    %if %sysevalf(%superq(_cstMapFileRef)=, boolean) %then
    %do;
      %* Need to Create Map File;
      %let _cstNeedToCreateDataMap=1;
    %end;
    %else %do;
      %let _cstSourceDataMapFile=%sysfunc(pathname(&_cstMapFileRef));
    %end;
      
  %end;

  %if not %sysevalf(%superq(_cstSourceDataMapFile)=, boolean) %then
  %do;
    %if not %sysfunc(fileexist(&_cstSourceDataMapFile)) %then
    %do;
      %* Rule: If _cstSourceDataMapFile is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The data map file _cstSourceDataMapFile=&_cstSourceDataMapFile does not exist.;
      %goto exit_error;
    %end;
  %end; 

  %* Rule: These macro variables have to be Y or N  *;
  %let _cstYN=_cstAttachFormats;
  %let _cstInvalidYN=;
  %do _cstCounter=1 %to %sysfunc(countw(&_cstYN, %str( )));
    %let _cstMacParam=%scan(&_cstYN, &_cstCounter);
    %if %sysevalf(%superq(&_cstMacParam)=, boolean) %then
      %let _cstInvalidYN = &_cstInvalidYN &_cstMacParam;
    %else %if "%substr(%upcase(&&&_cstMacParam),1,1)" ne "Y" and "%substr(%upcase(&&&_cstMacParam),1,1)" ne "N" %then
      %let _cstInvalidYN = &_cstInvalidYN &_cstMacParam;
  %end;

  %if %length(&_cstInvalidYN) gt 0
    %then %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The following macro parameter(s) should be Y or N: &_cstInvalidYN;
      %goto exit_error;
    %end;

  %************************;
  %* Begin macro logic    *;
  %************************;

  %*************************************************;
  %* This section gets the metadata                *;
  %*************************************************;

  %if not %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean) %then
  %do;
    %let _cstSourceMetadatasasref=&_cstSourceMetadataLibrary;
    %let _cstMetadataSource=%sysfunc(pathname(&_cstSourceMetadataLibrary));
    %* We need to read from the SAS representation of a Define-XML file *;
    %if %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupdefitemrefs))
      %then %let _cstItemGroupItemRef = itemgroupdefitemrefs;
      %else %let _cstItemGroupItemRef = itemgroupitemrefs;
  %end;
  %else 
  %do;
    %* We need to read from a Define-XML file *;
    %let rc=%sysfunc(dcreate(md&_cstRandom, %sysfunc(pathname(work))));
    libname md&_cstRandom "%sysfunc(pathname(work))&_cstPathDelim.md&_cstRandom";
    %let _cstMetadataCleanup=1;
    %let _cstItemGroupItemRef = itemgroupitemrefs;
    %let _cstSourceMetadataLibrary=md&_cstRandom;

    %if not %sysevalf(%superq(_cstSourceMetadataDefineFileRef)=, boolean) %then %do;
      filename def&_cstRandom "%sysfunc(pathname(&_cstSourceMetadataDefineFileRef))";
      %let _cstSourceMetadatasasref=def&_cstRandom;
    %end;
    %else 
    %do;
      filename def&_cstRandom "&_cstSourceMetadataDefineFile";
      %let _cstSourceMetadatasasref=def&_cstRandom;
    %end;
    filename sxle&_cstRandom "&_cstSourceMetadataMapFile";
    libname def&_cstRandom &_cstXMLEngine xmlmap=sxle&_cstRandom access=readonly;
    %let _cstMetadataSource=%sysfunc(pathname(&_cstSourceMetadatasasref));

    *** Reading Define-XML files;
    proc copy in=def&_cstRandom out=md&_cstRandom memtype=data noclone;
    run;

    %if &_cstNeedToDeleteMetaMap %then 
    %do;
      %if %sysfunc(fdelete(sxle&_cstRandom)) %then %put %sysfunc(sysmsg());
    %end;

    data md&_cstRandom..translatedtext;
      length parent $32;
      set md&_cstRandom..ItemDefTranslatedText(in=tt_id rename=(FK_ItemDef=parentKey))
          md&_cstRandom..ItemGroupDefTranslatedText(in=tt_igd rename=(FK_ItemGroupDef=parentKey));
      if tt_id then parent="ItemDefs";
               else parent="ItemGroupDefs";
    run;    

    libname def&_cstRandom clear;
    filename def&_cstRandom clear;
    filename sxle&_cstRandom clear;

  %end;

  %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Metadata used from &_cstMetadataSource;
  %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
  %do;
    %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
    %cstutil_writeresult(
                _cstResultId=DATA0097
                ,_cstResultParm1=Metadata used from &_cstMetadataSource
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstSrcMacro
                ,_cstResultFlagParm=&_cst_rc
                ,_cstRCParm=&_cst_rc
                );
  %end;


  %let _cstFileOID=;
  %let _cstStudyOID_meta=;
  %let _cstMetadataVersionOID_meta=;
  %let _cstDefineVersion=;
  %let _cstDefineStandardName=;
  %let _cstDefineStandardVersion=;
  proc sql noprint;
    select FileOID into :_cstFileOID
    from &_cstSourceMetadataLibrary..definedocument
    ;
    select OID into :_cstStudyOID_meta
    from &_cstSourceMetadataLibrary..study
    ;
    select OID, scan(DefineVersion, 1, "."), StandardName, StandardVersion
      into :_cstMetadataVersionOID_meta, :_cstDefineVersion, :_cstDefineStandardName, :_cstDefineStandardVersion
    from &_cstSourceMetadataLibrary..metadataversion
    ;
  quit;
  %let _cstFileOID=&_cstFileOID;
  %let _cstStudyOID_meta=&_cstStudyOID_meta;
  %let _cstMetadataVersionOID_meta=&_cstMetadataVersionOID_meta;
  %let _cstDefineVersion=&_cstDefineVersion;
  %let _cstDefineStandardName=&_cstDefineStandardName;
  %let _cstDefineStandardVersion=&_cstDefineStandardVersion;

  %if &_cstDebug %then 
  %do;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Define-XML: %str
      ()_cstFileOID=&_cstFileOID _cstStudyOID_meta=&_cstStudyOID_meta %str
      ()_cstMetadataVersionOID_meta=&_cstMetadataVersionOID_meta;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Define-XML: %str
      ()_cstDefineVersion=&_cstDefineVersion _cstDefineStandardName=&_cstDefineStandardName %str
      ()_cstDefineStandardVersion=&_cstDefineStandardVersion;
  %end;
  
  *** Combine Metadata;
  proc sql;
    create table work._cst_metadata_&_cstRandom
    as select
      odm.fileoid    as __ODMFileOID,
      std.OID        as __StudyOID,
      mdv.OID        as __MetaDataVersionOID,
      igd.OID        as __ItemGroupOID,
      igdir.ItemOID  as __ItemOID,
      igd.Name       as igName,
      igd.SASDatasetName,
      itd.Name       as ItemName,
      itd.SASFieldName,
      %if %eval(&_cstDefineVersion)=1 %then %do;
        igd.Label      as ItemGroupLabel,
        itd.Label      as ItemLabel,
      %end;
      %else
      %do;
        "" as ItemGroupLabel,
        "" as ItemLabel,
      %end;
      %if %sysfunc(exist(&_cstSourceMetadataLibrary..translatedtext)) %then %do;
        tt_igd.TranslatedText as ItemGroupTranslatedText,
        tt_id.TranslatedText as ItemTranslatedText,
      %end;
      %else
      %do;
        "" as ItemGroupTranslatedText,
        "" as ItemTranslatedText,
      %end;
      
      igd.IsReferenceData,
      igdir.OrderNumber,
      itd.DataType,
      itd.Length,
      itd.DisplayFormat
    from &_cstSourceMetadataLibrary..DefineDocument odm
       inner join &_cstSourceMetadataLibrary..study std
     on std.FK_DefineDocument = odm.FileOID
       inner join &_cstSourceMetadataLibrary..metadataversion mdv
     on mdv.FK_Study = std.OID
       inner join &_cstSourceMetadataLibrary..itemgroupdefs igd
     on igd.FK_MetaDataVersion = mdv.OID
       inner join &_cstSourceMetadataLibrary..&_cstItemGroupItemRef igdir
     on igdir.FK_ItemGroupDefs = igd.OID
       inner join &_cstSourceMetadataLibrary..itemdefs itd
     on (itd.OID = igdir.ItemOID and itd.FK_MetaDataVersion = mdv.OID)
     %if %sysfunc(exist(&_cstSourceMetadataLibrary..translatedtext)) %then %do;
         left join &_cstSourceMetadataLibrary..translatedtext tt_igd
       on (igd.OID = tt_igd.parentKey and upcase(tt_igd.parent)="ITEMGROUPDEFS")  
         left join &_cstSourceMetadataLibrary..translatedtext tt_id
       on (itd.OID = tt_id.parentKey and upcase(tt_id.parent)="ITEMDEFS")  
     %end;     
     order by __ItemGroupOID, OrderNumber
     ;
  quit;

  data work._cst_metadata_&_cstRandom(drop=ItemGroupLabel ItemGroupTranslatedText ItemLabel ItemTranslatedText);
    attrib igText length=$1000
           itText  length=$1000;
    set work._cst_metadata_&_cstRandom;
     igText=ifc(not missing(ItemGroupLabel), ItemGroupLabel, ItemGroupTranslatedText);    
     itText=ifc(not missing(ItemLabel), ItemLabel, ItemTranslatedText);
  run;

  sasfile _cst_metadata_&_cstRandom open;


  %* Check for DisplayFormat when the standard is ADaM based;
  %if %kindex(%upcase(&_cstDefineStandardName), %str(ADAM)) gt 0 %then 
  %do;
    data _cstIssues_displayformat_&_cstRandom;
      set work._cst_metadata_&_cstRandom;
      if (upcase(DataType)="INTEGER" or upcase(DataType)="FLOAT") and
         (ksubstr(kleft(kreverse(ItemName)),1,2)="TD" or 
          ksubstr(kleft(kreverse(ItemName)),1,2)="MT" or 
          ksubstr(kleft(kreverse(ItemName)),1,2)="MTD") and
          missing(DisplayFormat) then output;
    run;      

    %let _cstDisplayFormatIssues=;
    proc sql noprint;
      select unique cats(igName, ".", ItemName) into: _cstDisplayFormatIssues separated by ' '
    from _cstIssues_displayformat_&_cstRandom;
    quit;  
    %if %sysevalf(%superq(_cstDisplayFormatIssues)=, boolean)=0 %then
    %do;  
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] The following ADaM variables need a DisplayFormat in the metadata: &_cstDisplayFormatIssues;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=The following ADaM variables need a DisplayFormat in the metadata: &_cstDisplayFormatIssues
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;

    %if not &_cstDebug %then %do;
      %cstutil_cstDeleteMember(_cstMember=_cstIssues_displayformat_&_cstRandom);
    %end;

  %end;  

  %*************************************************;
  %* This section gets the data from Dataset-XML   *;
  %*************************************************;

  %* Determine the maximum column length from the metadata.            ;
  %* As a safeguard we will use twice this length to avoid truncation. ;
  proc sql noprint;
    select max(length) into: _cstMaxTextLength
    from work._cst_metadata_&_cstRandom
    ;
  quit;
  %let _cstMaxTextLength=&_cstMaxTextLength;
  %if &_cstDebug %then
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Maximum metadata text length = &_cstMaxTextLength;
  %let _cstMaxTextLength=%eval(2 * &_cstMaxTextLength);

  %if &_cstNeedToCreateDataMap %then 
  %do;
    %let _cstSourceDataMapFile=%sysfunc(pathname(work))/data&_cstRandom..map;
    %datasetxml_createmap(
      _cstMapFile=&_cstSourceDataMapFile,
      _cstMapType=datamap,
      _cstNameSpace=data:,
      _cstValueLength=&_cstMaxTextLength
      );
  %end;

  filename sxle&_cstRandom "&_cstSourceDataMapFile";

  %*****************************************************************;
  %* This section creates a data set with the Dataset-XML files    *;
  %*****************************************************************;

  %let _cstDatasetXMLFiles=0;
  %if not %sysevalf(%superq(_cstSourceDatasetXMLFile)=, boolean) %then
  %do;
    data DatasetXMLfiles_&_cstRandom;
      length xmlfilepath xmlfilename $4000;
      xmlfilepath="&_cstSourceDatasetXMLFile";
      xmlfilename=scan(xmlfilepath, -1, "\/");
    run;
    %let _cstDatasetXMLFiles=1;      
  %end;
  %else %do;
    data DatasetXMLfiles_&_cstRandom(keep=xmlfilepath xmlfilename);
      length xmlfilepath xmlfilename $4000 rc did memcnt i _cstDatasetXMLFiles 8;
      rc=filename("fref", "%sysfunc(pathname(&_cstSourceDatasetXMLLibrary))");
      did=dopen("fref");
      memcnt=dnum(did);
      _cstDatasetXMLFiles=0;
      do i = 1 to memcnt;                                                                                                                
        xmlfilepath=cats("%sysfunc(pathname(&_cstSourceDatasetXMLLibrary))", "&_cstPathDelim", dread(did,i));
        xmlfilename=dread(did,i);
        if (index(upcase(xmlfilename), "DEFINE")=0) and (scan(upcase(xmlfilepath), -1, ".")="XML") then do;
          _cstDatasetXMLFiles=_cstDatasetXMLFiles + 1;
          output;
        end;
      end;
      rc=dclose(did);
      call symputx ('_cstDatasetXMLFiles', _cstDatasetXMLFiles);
    run;
  %end;

  %*************************************************;
  %* Loop through the Dataset-XML list             *;
  %*************************************************;
  %do _cstCounter=1 %to &_cstDatasetXMLFiles;

    %* Time the processing;
    %let _cstElapsed = %sysfunc(datetime());

    data _null_;
      set DatasetXMLfiles_&_cstRandom;
      if _n_=&_cstCounter;
      call symputx ('_cstDatasetXMLFile', xmlfilepath);
    run;

    %* We need to read from a Dataset-XML file *;
    %let rc=%sysfunc(dcreate(data&_cstRandom, %sysfunc(pathname(work))));
    libname data&_cstRandom "%sysfunc(pathname(work))&_cstPathDelim.data&_cstRandom";

/*
    filename ds&_cstRandom "&_cstDatasetXMLFile";
    libname ds&_cstRandom &_cstXMLEngine xmlmap=sxle&_cstRandom access=readonly;

    *** Reading Dataset-XML files;
    proc copy in=ds&_cstRandom out=data&_cstRandom memtype=data noclone;
      select ReferenceItemData;
    run;
    proc copy in=ds&_cstRandom out=data&_cstRandom memtype=data noclone;
      select ClinicalItemData;
    run;

    %if (&syserr) %then 
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=%nrbquote(&syserrortext);
      %goto exit_error;
    %end;
    
    libname ds&_cstRandom clear;
    filename ds&_cstRandom clear;
    
    *** Combining ReferenceData and ClinicalData;
    data _cstItemData_&_cstRandom;
      length Element $20;
      set data&_cstRandom..ReferenceItemData(in=ref) 
          data&_cstRandom..ClinicalItemData(in=clin) end=end;
      if not missing(CalculatedSeq) then ItemGroupDataSeq=CalculatedSeq;      
      if ref then Element="ReferenceData";
             else Element="ClinicalData";
    run;
*/

    %if &_cstDebug eq 99 %then
    %do;
      %let _cstDatasetXMLTempFile = %sysfunc(pathname(&_cstOutputLibrary))/_dataxml_&_cstCounter._&_cstRandom..txt;
    %end;
    %else %do;
      %let _cstDatasetXMLTempFile = %sysfunc(pathname(work))/_dataxml_&_cstCounter._&_cstRandom..txt;
    %end;


    data _null_ %if not %sysevalf(%superq(_cstJavaPicklist)=, boolean) %then / picklist="&_cstJavaPicklist";;
      dcl javaobj j("&_cstParseClass");
      call j.callVoidMethod("parseDatasetXML", "&_cstDatasetXMLFile", "&_cstDatasetXMLTempFile");
    run;

    %if not %sysfunc(fileexist(&_cstDatasetXMLTempFile)) %then
    %do;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The file &_cstDatasetXMLTempFile does not exist.;
      %goto exit_error;
    %end;
    
    filename xmp_&_cstRandom "&_cstDatasetXMLTempFile" &_cstLRECL;

    data _cstItemData_&_cstRandom(drop=vlg txtline);
    attrib
      StudyOID length=$128
      MetaDataVersionOID length=$128
      ItemGroupOID length=$128
      ItemGroupDataSeq length=8
      CalculatedSeq length=8
      ItemOID length=$128
      Value length=$&_cstMaxTextLength
      FK_ODM length=$128
      Element length=$20
      ;
      retain StudyOID MetadataVersionOID ItemGroupOID ItemGroupDataSeq CalculatedSeq FK_ODM Element;  
      infile xmp_&_cstRandom missover length=lg end=end;
      input @;
      vlg=lg;
      input @1 txtline $varying9600. vlg;
      
      if index(txtline, '[]') then
      do; 
        txtline=ksubstr(txtline,3);
        ItemOID = kscan(txtline, 1, '|');
        Value = kscan(txtline, 2, '|');
      end;
      else if index(txtline, '[IG]') then
      do; 
        txtline=ksubstr(txtline,5);
        ItemGroupOID=kscan(txtline, 1, '|');
        ItemGroupDataSeq=input(kscan(txtline, 2, '|'), best32.);
        CalculatedSeq+1;
        if not missing(CalculatedSeq) then ItemGroupDataSeq=CalculatedSeq;
        delete;
        input @;
      end;
      else if index(txtline, '[CD]') then
        do; 
          Element='ClinicalData';
          txtline=ksubstr(txtline,5);
          StudyOID=kscan(txtline, 1, '|');
          MetaDataVersionOID=kscan(txtline, 2, '|');
          CalculatedSeq=0;
          delete;
          input @;
        end;
        else if index(txtline, '[RD]') then
          do; 
            Element='ReferenceData';
            txtline=ksubstr(txtline,5);
            StudyOID=kscan(txtline, 1, '|');
            MetaDataVersionOID=kscan(txtline, 2, '|');
            CalculatedSeq=0;
            delete;
            input @;
          end;
          else if index(txtline, '[ODM]') then 
            do;
              FK_ODM=ksubstr(txtline,6);
              delete;
              input @;
            end;    
      output;
    run;
    
    %if &_cstDebug eq 0 %then
    %do;
      %if %sysfunc(fdelete(xmp_&_cstRandom)) %then %put %sysfunc(sysmsg());
    %end;
    filename xmp_&_cstRandom clear;


    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data read from &_cstDatasetXMLFile;
    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0097
                  ,_cstResultParm1=Data read from &_cstDatasetXMLFile
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_rc
                  ,_cstRCParm=&_cst_rc
                  );
    %end;

    %let _cstNobs=%cstutilnobs(_cstDataSetName=_cstItemData_&_cstRandom);
    
    %if &_cstNobs eq 0 %then %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] No data found in &_cstDatasetXMLFile;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=No data found in &_cstDatasetXMLFile
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
      %goto exit_loop;
    %end;

    proc sql noprint;
      select max(length(value)) into: _cstMaxValueLength
      from _cstItemData_&_cstRandom(keep=value);
    quit;
    %let _cstMaxValueLength=&_cstMaxValueLength;
    %if &_cstDebug %then
      %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] &_cstItemGroupOID Maximum value length = &_cstMaxValueLength;
    %let _cstMaxValueLength=%eval(&_cstMaxValueLength+10);


    %let _cstStudyOID=;
    %let _cstMetadataVersionOID=;
    %let _cstItemGroupOID=;
    data _null_;
      set _cstItemData_&_cstRandom;
      if _n_=1 then do;
        call symputx ('_cstStudyOID', StudyOID);
        call symputx ('_cstMetadataVersionOID', MetadataVersionOID);
        call symputx ('_cstItemGroupOID', ItemGroupOID);
        stop;
      end;
    run;

    %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Dataset-XML: %str
      ()_cstStudyOID=&_cstStudyOID %str
      ()_cstMetadataVersionOID=&_cstMetadataVersionOID _cstItemGroupOID=&_cstItemGroupOID;
    
    %if (%bquote(&_cstStudyOID_meta) ne %bquote(&_cstStudyOID)) %then %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %str
      ()Differences in StudyOID: Define-XML: &_cstStudyOID_meta, Dataset-XML: &_cstStudyOID;
    %if (%bquote(&_cstMetadataVersionOID_meta) ne %bquote(&_cstMetadataVersionOID)) %then %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %str
      ()Differences in _cstMetadataVersionOID: Define-XML: &_cstMetadataVersionOID_meta, Dataset-XML: &_cstMetadataVersionOID;
    
    %****************************************************;
    %* Build labels and attributes                      *;
    %****************************************************;
    data work._cst_metadata_&_cstRandom._&_cstCounter
      (drop=_cstvalid x SASDatasetName IGName SASFieldName ItemName igText itText tableLabel tableName);
      attrib columnName  length=$32
             columnLabel length=$%eval(&_cstMaxLabelLength+10)
             tableName   length=$32
             tableLabel  length=$%eval(&_cstMaxLabelLength+10);
        retain tableName tableLabel;
      set work._cst_metadata_&_cstRandom(
        where=(__ItemGroupOID="&_cstItemGroupOID")
        );
      by __ItemGroupOID OrderNumber;
  
      %* Derive usable data set name and label *;
      if first.__ItemGroupOID then
      do;
  
        if missing(SASDatasetName) then tableName=IGName;
                                   else tableName=SASDatasetName;
        if missing(igText) then tableLabel=IGName;
                           else tableLabel=igText;
        if length(tableLabel) > &_cstMaxLabelLength then
            tableLabel = cats(substr(tableLabel,1, &_cstMaxLabelLength.-3), '...');
        tableLabel=tranwrd(tableLabel,'"',"'");
        call symputx ('_cstTableLabel',tableLabel);
        call symputx ('_cstTableName',tableName);
        call symputx ('_cstIsReferenceData', isReferenceData);
  
        %* Currently the output dataset name will be specified by the user *;
        _cstvalid=nvalid(tableName,'v7');
        if not _cstvalid then
        do;
          x=nvalid(substr(tableName,1,1));
          if x=0 then substr(tableName,1,1)='_';
          do until(x=0 or _cstvalid=1);
            x=notName(tableName);
            if x > 0 then
              tableName=translate(strip(tableName),'_', substr(tableName,x,1));
            _cstvalid=nvalid(tableName,'v7');
          end;
          _cstvalid=nvalid(tableName,'v7');
          putlog "[CSTLOG" "MESSAGE.&sysmacroname] NOTE: Modified tableName: " SASDatasetName= IGName= tableName= _cstvalid=;
        end;
      end;
  
  
      %* Derive usable column name and label *;
      if missing(SASFieldName) then columnName=itemname;
                               else columnName=SASFieldName;
      columnLabel=itText;
      if missing(columnLabel) then columnLabel=itemname;
  
      if length(columnLabel) > &_cstMaxLabelLength then
          columnLabel = cats(substr(columnLabel,1, &_cstMaxLabelLength.-3), '...');
      columnLabel=tranwrd(columnLabel,'"',"'");
  
      _cstvalid=nvalid(columnName,'v7');
      if not _cstvalid then
      do;
        x=nvalid(substr(columnName,1,1));
        if x=0 then substr(columnName,1,1)='_';
        do until(x=0 or _cstvalid=1);
          x=notName(columnName);
          if x > 0 then
            columnName=translate(strip(columnName),'_', substr(columnName,x,1));
          _cstvalid=nvalid(columnName,'v7');
        end;
        _cstvalid=nvalid(columnName,'v7');
        putlog "[CSTLOG" "MESSAGE.&sysmacroname] NOTE: Modified columnName: " SASFieldName= itemName= columnName= _cstvalid=;
      end;
  
      select(upcase(datatype));
        when ("DATE", "TIME", "DATETIME", "PARTIALDATE", "PARTIALTIME", "PARTIALDATETIME", "INTERVALDATETIME",
              "DURATIONDATETIME", "INCOMPLETEDATETIME", "INCOMPLETEDATE", "INCOMPLETETIME")
          do;
            if missing(length) then length=&_cstdatetimeLength;
          end;
       otherwise;
     end;     
  
    run;

    %let _cstNobs=%cstutilnobs(_cstDataSetName=_cst_metadata_&_cstRandom._&_cstCounter);
    
    %if &_cstNobs eq 0 %then %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] No metadata found for %bquote
        (StudyOID=&_cstStudyOID, MetaDataVersionOID=&_cstMetadataVersionOID, ItemGroupOID=&_cstItemGroupOID);
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=%bquote(No metadata found for StudyOID=&_cstStudyOID, MetaDataVersionOID=&_cstMetadataVersionOID, ItemGroupOID=&_cstItemGroupOID)
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
      %goto exit_loop;
    %end;

    %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] _cstTableLabel = %str(&_cstTableLabel);
  
    filename _cstattr CATALOG "work._cstextract.colattr.source" &_cstLRECL;
  

    %* Build the column attribute code for later use  *;
    data work._cst_metadata_&_cstRandom._&_cstCounter;
      set work._cst_metadata_&_cstRandom._&_cstCounter end=end;
        length tempvar $4000 type 8;
      file _cstattr;
  
      if _n_=1 then do;
        put "attrib";
      end;
      
      select(upcase(datatype));
        when ("TEXT", "STRING")
          do;
            type=2;
            if missing(length) then do;
              length=200;
              putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Missing length for " 
                __ItemOID "was set to 200."; 
            end;
            tempvar=catx(' ',columnName, cats('length=$',length));
            if not missing(columnLabel) then tempvar=catx(' ',tempvar,cats('label="',columnLabel,'"'));
          end;
        %* We are reading DATE, TIME and DATETIME as TEXT since we are not supporting partial *;
        %* DATETIME, DATE and TIME yet.                                                       *;
        when ("DATE", "TIME", "DATETIME", "PARTIALDATE", "PARTIALTIME", "PARTIALDATETIME", "INTERVALDATETIME",
              "DURATIONDATETIME", "INCOMPLETEDATETIME", "INCOMPLETEDATE", "INCOMPLETETIME")
          do;
            type=2;
            if missing(length) then tempvar=catx(' ', columnName, cats("length=$&_cstdatetimeLength"));
                               else tempvar=catx(' ', columnName, cats('length=$',length));
            if not missing(columnLabel) then tempvar=catx(' ',tempvar,cats('label="',columnLabel,'"'));
          end;
        when ("FLOAT", "INTEGER")
          do;
            type=1;
            tempvar=catx(' ', columnName, 'length=8');
            %if %upcase(%substr(&_cstAttachFormats,1,1)) = Y %then %do;
              %* Attach formats, but only for integers/floats;
              if not missing(DisplayFormat) then do;
                tempvar=catx(' ',tempvar, cats('format=', DisplayFormat));
                tempvar=tranwrd(tempvar, "..", ".");
              end;
            %end;
            if not missing(columnLabel) then tempvar=catx(' ',tempvar,cats('label="',columnLabel,'"'));
          end;
        otherwise
          do;
            type=2;
            if missing(length)
              then 
              do;
                tempvar=catx(' ', columnName, cats('length=$2000'),cats('label="',columnLabel,'"'));
                putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Missing length for " 
                  __ItemOID "was set to 200."; 
              end;
              else tempvar=catx(' ', columnName, cats('length=$',length),cats('label="',columnLabel,'"'));
          end;
      end;
      put @3 tempvar;
    run;

    *** Create format that maps ItemOID to OrderNumber;
    proc sql noprint;
      create table work._cst_Fmt_&_cstRandom as select 
        __ItemOID as start,
        "$_cst_&_cstTableName.f" as fmtname,
        "C" as type
      from work._cst_metadata_&_cstRandom._&_cstCounter
      order by OrderNumber
      ;  
    quit;    
        
    data _cst_Fmt_&_cstRandom;
      length label $10;
      set _cst_Fmt_&_cstRandom;
      label=strip(put(_n_, best.));
    run;
    
    proc format cntlin=work._cst_Fmt_&_cstRandom;
    run;

    %cstutil_cstDeleteMember(_cstMember=work._cst_Fmt_&_cstRandom);

    %let _cst_varNames=;
    %let _cst_varNames2=;
    %let _cst_varLengths=;
    %let _cst_varTypes=;
    %let _cst_varDataTypes=;
    %let _cstIsReferenceData=;
    proc sql noprint;
       select columnName, columnName, isReferenceData, length, type, DataType into 
              :_cst_varNames separated by " ", :_cst_varNames2 separated by '" ,"', :_cstIsReferenceData, 
              :_cst_varLengths separated by ",", :_cst_varTypes separated by ",",
              :_cst_varDataTypes separated by '" ,"'
       from work._cst_metadata_&_cstRandom._&_cstCounter
       order by OrderNumber
       ;
    quit;

    %if &_cstDebug=99 %then %do;
      %put &=_cst_varNames;
      %put _cst_varNames2="&_cst_varNames2";
      %put &=_cstIsReferenceData;
      %put &=_cst_varLengths;
      %put &=_cst_varTypes;
      %put _cst_varDataTypes="&_cst_varDataTypes";
    %end;

    %let _cstIsReferenceData=&_cstIsReferenceData;
    %let _cstNVars=%cstutilnobs(_cstDatasetName=work._cst_metadata_&_cstRandom._&_cstCounter);

    data work.itemdata_metadata_&_cstRandom(keep=Element ItemGroupDataSeq __ItemOID value rc)
          / view=work.itemdata_metadata_&_cstRandom;
     length __ItemOID $128 value $&_cstMaxValueLength Element $20 ItemGroupDataSeq 8;
     set work._cstItemData_&_cstRandom(rename=(ItemOID=__ItemOID value=value_old)) end=last;
     value=value_old;
     OrderNumber=put(__ItemOID, $_cst_&_cstTableName.f.);
     if not missing(OrderNumber) then rc=input(OrderNumber, ?? best4.);
     if not missing(rc) then rc=0;
    run;

    options NoQuoteLenMax;  
    %let _cstMissingOID=;
    proc sql noprint;
      select unique __ItemOID into: _cstMissingOID separated by ' '
    from work.itemdata_metadata_&_cstRandom(where=(rc ne 0));
    quit;  

    %if %sysevalf(%superq(_cstMissingOID)=, boolean)=0 %then
    %do;  
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Items not found in metadata: &_cstMissingOID;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Items not found in metadata: &_cstMissingOID
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;


    data work.itemdata_metadata_&_cstRandom._rc0
      / view=itemdata_metadata_&_cstRandom._rc0;
      set work.itemdata_metadata_&_cstRandom(where=(rc=0));
    run;
          
   %let _cstNobs=%cstutilnobs(_cstDataSetName=work.itemdata_metadata_&_cstRandom._rc0);
    %cstutil_cstDeleteMember(_cstMember=work.itemdata_metadata_&_cstRandom._rc0, _cstMemtype=view);

    %if &_cstNobs eq 0 %then %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] No metadata/data matches for %bquote
        (StudyOID=&_cstStudyOID, MetaDataVersionOID=&_cstMetadataVersionOID, ItemGroupOID=&_cstItemGroupOID);
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=%bquote(No metadata/data matches for StudyOID=&_cstStudyOID, MetaDataVersionOID=&_cstMetadataVersionOID, ItemGroupOID=&_cstItemGroupOID)
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
      %goto exit_loop;
    %end;

    %*****************;
    %* Generate code *;
    %*****************;
    options NoQuoteLenMax;
    %let _cstThisMacroRC=0;
    %let _cstThisMacroRCMsg=;

    *** Generate SAS datastep code;
    %let _cstDelimeter=%str(,);
    
    %if &_cstDebug eq 99 %then
    %do;
      filename _cstwr "%sysfunc(pathname(&_cstOutputLibrary))/&_cstTableName..sas" &_cstLRECL;
    %end;
    %else %do;
      filename _cstwr CATALOG "work._cstextract.writedata_&_cstRandom..source" &_cstLRECL;
    %end;
  
    data _null_;
      retain _cstissue_conversion _cstissue_truncation 0 ;
      set work.itemdata_metadata_&_cstRandom(where=(rc=0)) end=last;
      length columnName $32 _cstissue_conversion _cstissue_truncation _valueLength 8 isReferenceData $3 DataType $20 length 8;
      by ItemGroupDataSeq notsorted;
      
      array v {&_cstNVars} _temporary_;
      array vdt {&_cstNVars} _temporary_ (&_cst_varTypes);
      array vtype  {&_cstNVars} $20 _temporary_ ("&_cst_varDataTypes"); 
      array vname  {&_cstNVars} $32 _temporary_ ("&_cst_varNames2"); 
      array vn {&_cstNVars} $%eval(&_cstMaxValueLength+100)  _temporary_;
      array vl {&_cstNVars} _temporary_ (&_cst_varLengths);
      
      infile _cstattr end=done;
      file _cstwr;

      isReferenceData="&_cstIsReferenceData";
      if _n_=1 then do;
        if (missing(isReferenceData) and upcase(element)="REFERENCEDATA") or 
           (upcase(isReferenceData)="NO" and upcase(element)="REFERENCEDATA") or
           (upcase(isReferenceData)="YES" and upcase(element)="CLINICALDATA") then
          putlog "WAR" "NING: [CSTLOG" "MESSAGE).&sysmacroname] Data source " '"' Element +(-1) '" is not consistent with metadata ' isReferenceData=;

        put "data &_cstOutputLibrary..&_cstTableName (label=" '"' "&_cstTableLabel" '"' ");";
        put "infile datalines dsd truncover dlm='&_cstDelimeter';";

        do while(not done); 
         input @1;
         put _infile_;
        end;         

        put ';';
        put "input &_cst_varNames;";
        put "datalines4;";

      end;
      if first.ItemGroupDataSeq then do;
        do i=1 to &_cstNVars; v{i}=0; end;
      end;

      OrderNumber=input(put(__ItemOID, $_cst_&_cstTableName.f.), best4.);
      DataType=vtype{OrderNumber};
      columnName=vname{OrderNumber};
      Length=vl{OrderNumber};

      %* We are reading everything as TEXT except INTEGER and FLOAT *;
      select(upcase(DataType));
        when ("FLOAT", "INTEGER")
          do;
            if missing(value) then do;
              value='.';
              vn{Ordernumber}=".";
            end;
            else do;
              checknumeric=input(value, ?? best.);
              if missing(checknumeric) then do;
                putlog "WARNING: [CSTLOG" "MESSAGE.&sysmacroname] Missing value generated since datapoint could not be converted: "
                 ItemGroupDataSeq= __ItemOID= DataType= columnName +(-1) "=" value;
                putlog _all_;
                value='.';
                _cstissue_conversion=1;
              end;
              vn{Ordernumber}=value;
            end;
          end;
        otherwise
          do;
            if . < length < length(value) then do;
              _valueLength=length(value);
              putlog "WARNING: [CSTLOG" "MESSAGE.&sysmacroname] TRUNCATION occurred: " Length= "too short for " ItemGroupDataSeq= __ItemOID value= "(length=" _valueLength +(-1) ")";
              putlog _all_;
              _cstissue_truncation=1;
            end;   
            if index(value, '"')=0 and index(value, "'")=0 then do;
              vn{Ordernumber}=cats('"', value, '"');  
            end;
            else do;
              value=quote(value);
              vn{Ordernumber}=cats(value, '"');
            end;
          end;
      end;
      
      v{Ordernumber}=1;
      
      if (last.ItemGroupDataSeq) then 
      do;
        do i=1 to %eval(&_cstNVars-1); 
          if v{i} then put vn{i} +(-1) "&_cstDelimeter" @;
                  else if vdt{i}=2 then put '""' "&_cstDelimeter" @; 
                                   else put ".&_cstDelimeter" @; 
        end; 
        if v{&_cstNVars} then put vn{&_cstNVars};
                         else if vdt{&_cstNVars}=2 then put '""'; 
                                                   else put "."; 

      end;     
      
      if last then do;
        if _cstissue_conversion=1 or _cstissue_truncation=1 then 
          call symputx('_cstThisMacroRC',(_cstissue_conversion + (2*_cstissue_truncation)));
          
        put ";;;;" / "run;";
  
      end;
    run;

    %if %eval(&_cstThisMacroRC)=1 or %eval(&_cstThisMacroRC)=3 %then
    %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Please check the LOG. %str
        ()There were numeric data conversion issues for table &_cstTableName;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Please check the LOG. There were numeric data conversion issues for table &_cstTableName
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=1
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;
    %if %eval(&_cstThisMacroRC)=2 or %eval(&_cstThisMacroRC)=3 %then
    %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Please check the LOG. %str
        ()There were data truncation issues for table &_cstTableName;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Please check the LOG. There were data truncation issues for table &_cstTableName
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=1
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;


    %if &_cstDebug=0 %then 
    %do;
      %cstutil_cstDeleteMember(_cstMember=work.itemdata_metadata_&_cstRandom, _cstMemtype=view);    
    %end;

    %if &_cstDebug=0 %then 
    %do;
      %cstutil_cstDeleteMember(_cstMember=work._cst_metadata_&_cstRandom._&_cstCounter);
      %cstutil_cstDeleteMember(_cstMember=work._cstItemData_&_cstRandom); 
    %end;

    proc datasets lib=data&_cstRandom kill memtype=data nolist;
    run; 
    quit;

    *** Include SAS datastep code;

    options &_cstSaveOptCompress &_cstSaveOptReuse;
    %include _cstwr;

    options compress=yes reuse=yes;    
     
    filename _cstwr clear;
    filename _cstattr clear;
    options &_cstSaveOptQuoteLenMax;

    proc catalog cat=work.formats et=formatc;
      delete _cst_&_cstTableName.f;
    quit;
   
    %cstutil_cstDeleteMember(_cstMember=_cstextract, _cstFunction=cexist, _cstMemtype=catalog);
    
    %let _cstNobs=%cstutilnobs(_cstDataSetName=&_cstOutputLibrary..&_cstTableName);
    
    %* Time the processing;
    %let _cstElapsed=%sysfunc(putn(%sysevalf(%sysfunc(datetime())-&_cstElapsed), 8.2));
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Data set &_cstOutputLibrary..&_cstTableName %str
      ()created in &_cstElapsed seconds (&_cstNobs records).;
    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0097
                  ,_cstResultParm1=Data set &_cstOutputLibrary..&_cstTableName created in &_cstElapsed seconds (&_cstNobs records)
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_rc
                  ,_cstRCParm=&_cst_rc
                  );
    %end;

%exit_loop:

  %end;
  %*************************************************;
  %* End of Loop through the Dataset-XML list      *;
  %*************************************************;
  
  %**************************;
  %*  Cleanup               *;
  %**************************;
  sasfile _cst_metadata_&_cstRandom close;

  %if &_cstDebug=0 %then 
  %do;
    
    %cstutil_cstDeleteMember(_cstMember=work.DatasetXMLfiles_&_cstRandom);   
    %cstutil_cstDeleteMember(_cstMember=work._cst_metadata_&_cstRandom);
  
    libname data&_cstRandom clear;
    filename data&_cstRandom "%sysfunc(pathname(work))&_cstPathDelim.data&_cstRandom";
    %let rc=%sysfunc(fdelete(data&_cstRandom));
    filename data&_cstRandom clear;

    %if &_cstMetadataCleanup %then 
    %do;
      proc datasets lib=md&_cstRandom kill memtype=data nolist;
      run; quit;
      filename md&_cstRandom "%sysfunc(pathname(work))&_cstPathDelim.md&_cstRandom";
      %let rc=%sysfunc(fdelete(md&_cstRandom));
      libname md&_cstRandom;
    %end;

    %if &_cstNeedToCreateDataMap %then 
    %do;
      %if %sysfunc(fdelete(sxle&_cstRandom)) %then %put %sysfunc(sysmsg());
    %end;
    filename sxle&_cstRandom clear;

  %end;

  %goto exit_macro;

  %****************************;
  %*  Handle any errors here  *;
  %****************************;
%exit_error:

  %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
  %do;
    %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
    %cstutil_writeresult(
                _cstResultId=DATA0099
                ,_cstResultParm1=%nrbquote(&_cst_rcmsg)
                ,_cstResultSeqParm=&_cstResultSeq
                ,_cstSeqNoParm=&_cstSeqCnt
                ,_cstSrcDataParm=&_cstSrcMacro
                ,_cstResultFlagParm=&_cst_rc
                ,_cstRCParm=&_cst_rc
                );
  %end;

  %if %length(&&&_cstReturnMsg)>0 %then
    %put ERR%STR(OR): [CSTLOG%str(MESSAGE).&_cstSrcMacro] &&&_cstReturnMsg;

%exit_macro:

  %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
  %do;
    %if %symexist(_cstSASRefs) %then 
    %do;
      %* Persist the results if specified in sasreferences  *;
      %cstutil_saveresults();
    %end;
  %end;

  %* Delete the temporary messages data set if it was created here;
  %if (&_cstNeedToDeleteMsgs=1) %then
  %do;
    %cstutil_cstDeleteMember(_cstMember=&_cstMessages);
  %end;

  %exit_macro_nomsg:

  %* Restore changed options;
  options &_cstSaveOptFmtErr;
  options &_cstSaveOptCompress &_cstSaveOptReuse;
  

%mend datasetxml_read;
