%* datasetxml_write                                                               *;
%*                                                                                *;
%* Creates a Dataset-XML file from a SAS data set or a library of SAS data sets.  *;
%*                                                                                *;
%* Notes:                                                                         *;
%*   1. Any librefs referenced in macro parameters must be pre-allocated.         *;
%*   2. Files that exist in the output location are overwritten.                  *;
%*   3. Either _cstSourceDataSets or _cstSourceLibrary must be specified.         *;
%*      If neither of  these parameters is specified, the macro attempts to get   *;
%*      these parameter values from the SASReferences data set that is specified  *;
%*      by the macro variable _cstSASRefs (type=sourcedata).                      *;
%*      If multiple type=sourcedata records are specified, memnames must be       *;
%*      defined. If no memnames are specified, only the first record is used.     *;
%*   4. _cstOutputLibrary must be specified. If this parameter is not specified,  *;
%*      the macro attempts to get this parameter value from the SASReferences     *;
%*      data set that is specified by the macro variable _cstSASRefs              *;
%*      (type=externalxml).                                                       *;
%*   5. _cstSourceMetadataLibrary, _cstSourceMetadataDefineFile, or               *;
%*      _cstSourceMetadataDefineFileRef must be specified.                        *;
%*      If none of these parameters are specified, the macro attempts to get      *;
%*      _cstSourceMetadataLibrary from the SASReferences data set that is         *;
%*      specified by the macro variable _cstSASRefs (type=sourcemetadata,         *;
%*      subtype=, reftype=libref).                                                *;
%*      If that fails, the macro attempts to get _cstSourceMetadataDefineFileRef  *;
%*      from _cstSASRefs (type=sourcemetadata, subtyp=, reftype=fileref).         *;
%*   6. If_cstSourceMetadataDefineFile or _cstSourceMetadataDefineFileRef has     *;
%*      been specified, _cstSourceMetadataMapFile must be specified. If this      *;
%*      parameter is not specified , the macro attempts to get this parameter     *;
%*      value from the SASReferences data set that is specified by the macro      *;
%*      variable _cstSASRefs (type=referencexml, subtype=metamap).                *;
%*      If the XML mapfile cannot be found, the datasetxml_createmap macro        *;
%*      is used to create the XML mapfile (_cstMapType=metamap).                  *;
%*   7. If _cstSourceMetadataLibrary is specified, these data sets must exist in  *;
%*      this library:                                                             *;
%*        definedocument                                                          *;
%*        study                                                                   *;
%*        metadataversion                                                         *;
%*        itemgroupdefs                                                           *;
%*        itemgroupdefitemrefs (CRT-DDS 1.0)                                      *;
%*        itemgroupitemrefs (Define-XML 2.0)                                      *;
%*        itemdefs                                                                *;
%*   8. The Define-XML metadata is used to look up ItemGroupDef/@OID and          *;
%*      ItemDef/@OID based on the data set name and variable name.                *;
%*      If the data set cannot be matched, a warning is written and the           *;
%*      ItemGroupData/@ItemGroupOID attribute is generated as "IG.<TABLE>". If    *;
%*      the data set variable cannot be matched, a warning is written and the     *;
%*      ItemData/@ItemOID attribute is generated as "IT.<TABLE>.<COLUMN>".        *;
%*      If this metadata cannot be found, it is generated:                        *;
%*        ODM/@FileOID as "DEFINE" (used as ODM/@PriorFileOID)                    *;
%*        ODM/Study/@OID as "STUDY1"                                              *;
%*            (used as [ReferenceData|ClinicalData]/@StudyOID)                    *;
%*        ODM/Study/MetaDataVersion/@OID as "MDV1"                                *;
%*            (used as [ReferenceData|ClinicalData]/@MetaDataVersionOID)          *;
%*   9. The macro allows for zipping the Dataset-XML file (_cstZip=Y), and        *;
%*      optionally deleting the Dataset-XML file after zipping                    *;
%*      (_cstDeleteAfterZip=Y).                                                   *;
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
%* @param _cstSourceDataSets - conditional - A list of source data sets to        *;
%*            convert. Specified as a blank-separated list of: (libref.)dataset   *;
%*            Required if _cstSourceLibrary is not specified.                     *;
%* @param _cstSourceLibrary - conditional - The libref of the source data folder/ *;
%*            library. Required if _cstSourceDataSets is not specified.           *;
%* @param _cstOutputLibrary - required - The libref of the output data folder/    *;
%*            library in which to create the dataset-XML files.                   *;
%* @param _cstSourceMetadataLibrary - conditional - The libref of the source      *;
%*            metadata folder/library.                                            *;
%* @param _cstSourceMetadataDefineFile - conditional - The path to the Define-XML *;
%*            file.                                                               *;
%* @param _cstSourceMetadataDefineFileRef - conditional - The file reference that *;
%*            specifies the location of the Define-XML file.                      *;
%* @param _cstSourceMetadataMapFile - optional - The path to the map file to      *;
%*            read Define-XML metadata from an XML file.                          *;
%*            If not specified, it is derived from SASReferences or is created.   *;
%* @param _cstOutputEncoding - optional - The XML encoding to use for the         *;
%*            Dataset-XML file to create.                                         *;
%*            Default: UTF-8                                                      *;
%* @param _cstCreationDateTime - optional - The date/time at which the XML        *;
%*            document was created. If no value is specified, the current date    *;
%*            and time are used (ISO 8601).                                       *;
%* @param _cstAsOfDateTime - optional - The date/time at which the source         *;
%*            database was queried in order to create this document (ISO 8601).   *;
%* @param _cstOriginator - optional - The organization that generated the ODM     *;
%*            file.                                                               *;
%* @param _cstSourceSystem - optional - The computer system or database           *;
%*            management system that is the source of the information in this     *;
%*            file.                                                               *;
%* @param _cstSourceSystemVersion - optional - The version of _cstSourceSystem.   *;
%* @param _cstHeaderComment - optional - The short comment that is added to the   *;
%*            top of the Dataset-XML file to produce.                             *;
%*            Default: Produced from SAS data using the SAS Clinical Standards    *;
%*            Toolkit                                                             *;
%* @param _cstNumericFormat - required - The format used to write numeric data.   *;
%*            Default: best32.                                                    *;
%* @param _cstCheckLengths - optional - The actual value lengths of variables     *;
%*            with DataType=text are checked against the lengths as defined in    *;
%*            the metadata. If the lengths as defined in the metadata are too     *;
%*            short, a warning is written to the log file.                        *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%* @param _cstIndent - optional - Indent the Dataset-XML file.                    *;
%*            Values:  N | Y                                                      *;
%*            Default: Y                                                          *;
%* @param _cstZip - optional - Zip the Dataset-XML file to a zip file in the same *;
%*            folder and with the same name as the Define-XML file.               *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%* @param _cstDeleteAfterZip - optional - Delete the Dataset-XML file after it is *;
%*            zipped (_cstZip=Y).                                                 *;
%*            Values:  N | Y                                                      *;
%*            Default: N                                                          *;
%* @param _cstReturn - required - The macro variable that contains the return     *;
%*            value as set by this macro.                                         *;
%*            Default: _cst_rc                                                    *;
%* @param _cstReturnMsg - required - The macro variable that contains the return  *;
%*            message as set by this macro.                                       *;
%*            Default: _cst_rcmsg                                                 *;
%*                                                                                *;
%* @since  1.7                                                                    *;
%* @exposure external                                                             *;

%macro datasetxml_write(
  _cstSourceDataSets=,
  _cstSourceLibrary=,
  _cstOutputLibrary=,
  _cstSourceMetadataLibrary=,
  _cstSourceMetadataDefineFile=,
  _cstSourceMetadataDefineFileRef=,
  _cstSourceMetadataMapFile=,
  _cstOutputEncoding=UTF-8,
  _cstCreationDateTime=,
  _cstAsOfDateTime=,
  _cstOriginator=,
  _cstSourceSystem=,
  _cstSourceSystemVersion=,
  _cstHeaderComment=Produced from SAS data using SAS Clinical Standards Toolkit,
  _cstNumericFormat=best32.,
  _cstCheckLengths=Y,
  _cstIndent=Y,
  _cstZip=N,
  _cstDeleteAfterZip=N,
  _cstReturn=_cst_rc,
  _cstReturnMsg=_cst_rcmsg
  ) / des="CST: Create Dataset-XML file from SAS";


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
         _cstRegex
         _cstRegexID
         _cstSaveOptMissing
         _cstSaveOptQuoteLenMax
         _cstSaveOptCompress
         _cstSaveOptReUse
         _cstRandom
         _cstXMLEngine
         _cstNeedToDeleteMsgs
         _cstNeedToDeleteMetaMap
         _cstMetadataCleanup
         _cstSrcMacro
         _cstExpSrcTables
         _cstColumns
         _cstMissing
         _cstLengthIssues
         _cstDisplayFormatIssues
         _cstMissingOID
         _cstInvalidYN
         _cstYN
         _cstMacParam
         _cstCounter
         _cstTable
         _cstNobs
         _cstDatasetXMLFile
         _cstDatasetZIPFile
         _cstSrcLibref
         _cstSourceTableList
         _cstItemGroupItemRef
         _cstSourceDatasasref
         _cstSourceDatamember
         _cstSourceOutputsasref
         _cstSourceMetadatasasref
         _cstSourceMetadatamember
         _cstMetadataSource
         _cstMapFileRef
         _cstFileOID
         _cstStudyOID
         _cstMetadataVersionOID
         _cstDefineVersion
         _cstDefineStandardName
         _cstDefineStandardVersion
         _cstItemGroupOID
         _cstIsReferenceData
         _cstReferenceOrClinical
         _cstPathDelim
         _indent2
         _indent4
         _indent6
         _cstElapsed

         _cstTypeSourceData
         _cstTypeSourceMetaData
         _cstTypeExtXML
         _cstTypeRefXML
         _cstSubtypeMetaMap
         ;

  %* retrieve static variables;
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_SOURCEDATA,_cstVar=_cstTypeSourceData);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_SOURCEMETADATA,_cstVar=_cstTypeSourceMetaData);

  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_EXTXML,_cstVar=_cstTypeExtXML);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_TYPE_REFXML,_cstVar=_cstTypeRefXML);
  %datasetxml_getStatic(_cstName=DATASET_SASREF_SUBTYPE_METAMAP,_cstVar=_cstSubtypeMetaMap);

  %let _cstRandom=%sysfunc(putn(%sysevalf(%sysfunc(ranuni(0))*10000,floor),z4.));
  %let _cstResultSeq=1;
  %let _cstSeqCnt=0;
  %let _cstSrcMacro=&SYSMACRONAME;
  %let _cstMetadataCleanup=0;
  %let _cstNeedToDeleteMetaMap=0;

  %let _cstSaveOptCompress=%sysfunc(getoption(Compress, keyword));
  %let _cstSaveOptReuse=%sysfunc(getoption(Reuse, keyword));
  options compress=yes reuse=yes;
  %let _cstSaveOptQuoteLenMax=%sysfunc(getoption(QuoteLenMax));
  %* Missing numerics should convert to a blank *;
  %let _cstSaveOptMissing=%sysfunc(getoption(Missing));
  options missing=" ";
                                     
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

  %let _cstRegex=/^((([0-9][0-9][0-9][0-9])-(([0][0-9])|([1][0-2]))-(([0-2][0-9])|([3][0-1])))T%str
                 ()(((([0-1][0-9])|([2][0-3])):([0-5][0-9]):([0-5][0-9])(\.[0-9]+)?)(((\+|-)(([0-1][0-9])|([2][0-3])):[0-5][0-9])|(Z))?))$/;
  %let _cstRegexID=%sysfunc(PRXPARSE(&_cstRegex)); 

  %if %sysevalf(%superq(_cstCreationDateTime)=, boolean)=0 %then
  %do;
    %if %sysfunc(PRXMATCH(&_cstRegexID, &_cstCreationDateTime))=0 %then
    %do;
      %put WAR%STR(NING): [CSTLOG%str(MESSAGE).&sysmacroname] _cstCreationDateTime=&_cstCreationDateTime is an incorrect xs:dateTime value.;
    %end;
  %end;
  %if %sysevalf(%superq(_cstAsOfDateTime)=, boolean)=0 %then
  %do;
    %if %sysfunc(PRXMATCH(&_cstRegexID, &_cstAsOfDateTime))=0 %then
    %do;
      %put WAR%STR(NING): [CSTLOG%str(MESSAGE).&sysmacroname] _cstAsOfDateTime=&_cstAsOfDateTime is an incorrect xs:dateTime value.;
    %end;
  %end;


  %if %sysevalf(%superq(_cstNumericFormat)=, boolean) %then
  %do;
    %* Rule: _cstNumericFormat must be specified  *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstNumericFormat must be specified.;
    %goto exit_error;
  %end;


  %if %sysevalf(%superq(_cstSourceDataSets)=, boolean) and
      %sysevalf(%superq(_cstSourceLibrary)=, boolean) %then
  %do;

    %if %symexist(_CSTSASRefs) %then %if %sysfunc(exist(&_CSTSASRefs)) %then
      %do;
        %* Try getting the source location from the SASReferences file;
        %cstUtil_getSASReference(
          _cstStandard=%upcase(&_cstStandard),
          _cstStandardVersion=&_cstStandardVersion,
          _cstSASRefType=&_cstTypeSourceData,
          _cstSASRefsasref=_cstSourceDatasasref,
          _cstSASRefmember=_cstSourceDatamember,
          _cstConcatenate=1,
          _cstAllowZeroObs=1
          );
      %end;


    %if %sysevalf(%superq(_cstSourceDatasasref)=, boolean)=0 %then %do;
      %if %sysevalf(%superq(_cstSourceDatamember)=, boolean)=0 %then 
      %do;
        %let _cstSourceDataSets=;
        %do _cstCounter=1 %to %sysfunc(countw(&_cstSourceDatamember, %str( )));
           %let _cstSourceDataSets = &_cstSourceDataSets %scan(&_cstSourceDatasasref, &_cstCounter, %str( )).%scan(&_cstSourceDatamember, &_cstCounter, %str( ));
        %end;
      %end;
      %else
      %do; 
        %let _cstSourceLibrary=%scan(&_cstSourceDatasasref, 1, %str( ));
      %end;
    %end;

    %if %sysevalf(%superq(_cstSourceDataSets)=, boolean) and
        %sysevalf(%superq(_cstSourceLibrary)=, boolean) %then
    %do;
      %* Rule: Either _cstSourceDataSets or _cstSourceLibrary must be specified  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=Either _cstSourceDataSets or _cstSourceLibrary must be specified.;
      %goto exit_error;
    %end;
  %end;

  %if ((not %sysevalf(%superq(_cstSourceDataSets)=, boolean)) and
       (not %sysevalf(%superq(_cstSourceLibrary)=, boolean))) %then
  %do;
    %* Rule: _cstSourceDataSets and _cstSourceLibrary must not be specified both *;
    %let &_cstReturn=1;
    %let &_cstReturnMsg=_cstSourceDataSets and _cstSourceLibrary must not be specified both.;
    %goto exit_error;
  %end;

  %if not %sysevalf(%superq(_cstSourceDataSets)=, boolean) %then
  %do;
    %let _cstMissing=;
    %do _cstCounter=1 %to %sysfunc(countw(&_cstSourceDataSets, %str( )));
      %let _cstTable=%scan(&_cstSourceDataSets, &_cstCounter, %str( ));
      %if not %sysfunc(exist(&_cstTable)) %then
        %let _cstMissing = &_cstMissing &_cstTable;
    %end;

    %if %length(&_cstMissing) gt 0
      %then %do;
        %let &_cstReturn=1;
        %let &_cstReturnMsg=Expected source data set(s) do not exist: &_cstMissing..;
        %goto exit_error;
      %end;
  %end;

  %if not %sysevalf(%superq(_cstSourceLibrary)=, boolean) %then
  %do;
    %if %sysfunc(libref(&_cstSourceLibrary)) %then
    %do;
      %* Rule: If _cstSourceLibrary is specified, it must exist  *;
      %let &_cstReturn=1;
      %let &_cstReturnMsg=The libref _cstSourceLibrary=&_cstSourceLibrary has not been pre-allocated.;
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
          _cstSASRefType=&_cstTypeExtXML,
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
    %else %do;
      %* Rule: If _cstSourceMetadataLibrary exists, so certain data sets must exist  *;
      %let _cstExpSrcTables=definedocument study metadataversion itemgroupdefs itemdefs;
      %let _cstMissing=;
      %do _cstCounter=1 %to %sysfunc(countw(&_cstExpSrcTables, %str( )));
        %let _cstTable=%scan(&_cstExpSrcTables, &_cstCounter);
        %if not %sysfunc(exist(&_cstSourceMetadataLibrary..&_cstTable)) %then
          %let _cstMissing = &_cstMissing &_cstTable;
      %end;

      %if %length(&_cstMissing) gt 0
        %then %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected source metadata data set(s) not existing in library &_cstSourceMetadataLibrary: &_cstMissing;
          %goto exit_error;
        %end;

      %if (not %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupdefitemrefs))) and
          (not %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupitemrefs)))
        %then %do;
          %let &_cstReturn=1;
          %let &_cstReturnMsg=Expected source data set(s) not existing in library &_cstSourceMetadataLibrary: itemgroupdefitemrefs or itemgroupitemrefs;
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
  %* Create XML Map File                           *;
  %*************************************************;
  %* Metadata needs to come from Define-XML file, so check for Map file *;
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

  %* Rule: These macro variables have to be Y or N  *;
  %let _cstYN=_cstIndent _cstZip _cstDeleteAfterZip _cstCheckLengths;
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

  %if %upcase(%substr(&_cstIndent,1,1)) eq Y %then 
  %do;
    %let _indent2=+2;
    %let _indent4=%str(+4);
    %let _indent6=%str(+6);
  %end;
  %else %do;
    %let _indent2=;
    %let _indent4=;
    %let _indent6=;
  %end;

  %*************************************************;
  %* This section creates the list of data sets    *;
  %*************************************************;

  %if not %sysevalf(%superq(_cstSourceDataSets)=, boolean) %then
  %do;
    %let _cstSourceTableList=%upcase(&_cstSourceDataSets);
  %end;
  %else %do;
    %let _cstSrcLibref=%upcase(&_cstSourceLibrary);
    proc sql noprint;
      select upcase(catx('.',libname,memname)) into :_cstSourceTableList separated by ' '
      from dictionary.tables
      where upcase(libname) = upcase("&_cstSourceLibrary");
    quit;
  %end;

  %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] _cstSourceTableList=&_cstSourceTableList;

  %*************************************************;
  %* This section gets the metadata                *;
  %*************************************************;

  %if not %sysevalf(%superq(_cstSourceMetadataLibrary)=, boolean) %then
  %do;
    %let _cstSourceMetadatasasref=&_cstSourceMetadataLibrary;
    %* We need to read from the SAS representation of a Define-XML file *;
    %if %sysfunc(exist(&_cstSourceMetadataLibrary..itemgroupdefitemrefs))
      %then %let _cstItemGroupItemRef = itemgroupdefitemrefs;
      %else %let _cstItemGroupItemRef = itemgroupitemrefs;

  %end;
  %else %do;
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
    %else %do;
      filename def&_cstRandom "&_cstSourceMetadataDefineFile";
      %let _cstSourceMetadatasasref=def&_cstRandom;
    %end;
    filename sxle&_cstRandom "&_cstSourceMetadataMapFile";
    libname def&_cstRandom &_cstXMLEngine xmlmap=sxle&_cstRandom access=readonly;

    *** Reading Define-XML files;    
    proc copy in=def&_cstRandom out=md&_cstRandom memtype=data noclone;
    run;

    %if &_cstNeedToDeleteMetaMap %then 
    %do;
      %if %sysfunc(fdelete(sxle&_cstRandom)) %then %put %sysfunc(sysmsg());
    %end;
  
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Metadata used from %sysfunc(pathname(&_cstSourceMetadatasasref));
    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0097
                  ,_cstResultParm1=Metadata used from %sysfunc(pathname(&_cstSourceMetadatasasref))
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_rc
                  ,_cstRCParm=&_cst_rc
                  );
    %end;

    libname def&_cstRandom clear;
    filename def&_cstRandom clear;
    filename sxle&_cstRandom clear;

  %end;

  %let _cstFileOID=;
  %let _cstMetadataVersionOID=;
  %let _cstStudyOID=;
  %let _cstDefineVersion=;
  %let _cstDefineStandardName=;
  %let _cstDefineStandardVersion=;
  proc sql noprint;
    select FileOID into :_cstFileOID
    from &_cstSourceMetadataLibrary..definedocument
    ;
    select OID, scan(DefineVersion, 1, "."), StandardName, StandardVersion 
      into :_cstMetadataVersionOID, :_cstDefineVersion, :_cstDefineStandardName, :_cstDefineStandardVersion
    from &_cstSourceMetadataLibrary..metadataversion
    ;
    select OID into :_cstStudyOID
    from &_cstSourceMetadataLibrary..study
    ;
  quit;
  %let _cstFileOID=&_cstFileOID;
  %let _cstStudyOID=&_cstStudyOID;
  %let _cstMetadataVersionOID=&_cstMetadataVersionOID;
  %let _cstDefineVersion=&_cstDefineVersion;
  %let _cstDefineStandardName=&_cstDefineStandardName;
  %let _cstDefineStandardVersion=&_cstDefineStandardVersion;

  %if %sysevalf(%superq(_cstFileOID)=, boolean) %then %do;
    %let _cstFileOID=DEFINE;
    %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %str
      ()Missing ODM/@PriorFileOID will be generated as &_cstFileOID;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Missing ODM/@PriorFileOID will be generated as &_cstFileOID
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
  %end;  

  %if %sysevalf(%superq(_cstStudyOID)=, boolean) %then %do;
    %let _cstStudyOID=STUDY1;
    %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %str
      ()Missing @StudyOID will be generated as &_cstStudyOID;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Missing @StudyOID will be generated as &_cstStudyOID
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
  %end;  

  %if %sysevalf(%superq(_cstMetadataVersionOID)=, boolean) %then %do;
    %let _cstMetadataVersionOID=MDV1;
    %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %str
      ()Missing Study/MetaDataVersion/@OID will be generated as &_cstMetadataVersionOID;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Missing Study/MetaDataVersion/@OID will be generated as &_cstMetadataVersionOID
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
  %end;  
 
  %if &_cstDebug %then 
  %do;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Define-XML: %str
      ()_cstFileOID=&_cstFileOID _cstStudyOID=&_cstStudyOID %str
      ()_cstMetadataVersionOID=&_cstMetadataVersionOID;
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Define-XML: %str
      ()_cstDefineVersion=&_cstDefineVersion _cstDefineStandardName=&_cstDefineStandardName %str
      ()_cstDefineStandardVersion=&_cstDefineStandardVersion;
  %end;

  * Combine Metadata;
  proc sql;
    create table work._cst_metadata_&_cstRandom
    as select
      odm.fileoid    as __ODMFileOID,
      std.OID        as __StudyOID,
      mdv.OID        as __MetaDataVersionOID,
      igd.OID        as __ItemGroupOID,
      igdir.ItemOID  as __ItemOID,
      case when not missing(igd.SASDatasetName)
          then upcase(igd.SASDatasetName)
          else upcase(igd.Name)
        end as Table,
      case when not missing(itd.SASFieldName)
          then upcase(itd.SASFieldName)
          else upcase(itd.Name)
        end as Column,
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
     order by Table, OrderNumber
     ;
  quit;

  sasfile _cst_metadata_&_cstRandom open;

  %* Check for DisplayFormat when the standard is ADaM based;
  %if %kindex(%upcase(&_cstDefineStandardName), %str(ADAM)) gt 0 %then 
  %do;
    data _cstIssues_displayformat_&_cstRandom;
      set work._cst_metadata_&_cstRandom;
      if (upcase(DataType)="INTEGER" or upcase(DataType)="FLOAT") and
         (ksubstr(kleft(kreverse(column)),1,2)="TD" or 
          ksubstr(kleft(kreverse(column)),1,2)="MT" or 
          ksubstr(kleft(kreverse(column)),1,2)="MTD") and
          missing(DisplayFormat) then output;
    run;      

    %let _cstDisplayFormatIssues=;
    proc sql noprint;
      select unique cats(table, ".", column) into: _cstDisplayFormatIssues separated by ' '
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
  %* Loop through the dataset list                 *;
  %*************************************************;

  %do _cstCounter=1 %to %sysfunc(countw(&_cstSourceTableList, %str( )));

    %* Time the processing;
    %let _cstElapsed = %sysfunc(datetime());

    %let _cstTable=%scan(&_cstSourceTableList, &_cstCounter, %str( ));
    %if %sysfunc(indexc("&_cstTable",'.'))>0 %then
      %let _cstSrcLibref=%upcase(%scan(&_cstTable,1,'.'));
    %else
      %let _cstSrcLibref=WORK;
    %let _cstTable=%scan(&_cstTable, -1, %str(.));


    %let _cstNobs=%cstutilnobs(_cstDataSetName=&_cstSrcLibref..&_cstTable);
    
    %if &_cstNobs eq 0 %then %do;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %bquote
        (&_cstSrcLibref..&_cstTable has 0 records - No DatasetXML file created.);
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=%bquote(&_cstSrcLibref..&_cstTable has 0 records - No DatasetXML file created.)
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
      %goto exit_loop;
    %end;

    %let _cstDatasetXMLFile=%sysfunc(pathname(&_cstOutputLibrary))&_cstPathDelim.%lowcase(&_cstTable).xml;
    filename _xml&_cstRandom "&_cstDatasetXMLFile";

    %let _cstItemGroupOID=;
    %let _cstIsReferenceData=; 
    proc sql noprint;
      select OID, IsReferenceData into :_cstItemGroupOID, :_cstIsReferenceData
      from &_cstSourceMetadataLibrary..itemgroupdefs
      where ((upcase(SASDatasetName)=upcase("&_cstTable")) or 
             (upcase(Name)=upcase("&_cstTable"))
            )      
      ;
    quit;
    %let _cstItemGroupOID=&_cstItemGroupOID;
    %let _cstIsReferenceData=&_cstIsReferenceData;

    %if %sysevalf(%superq(_cstItemGroupOID)=, boolean) %then %do;
      %let _cstItemGroupOID=IG.&_cstTable;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] %str
        ()Missing ItemGroupData/@ItemGroupOID for table=&_cstTable will be generated as &_cstItemGroupOID;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Missing ItemGroupData/@ItemGroupOID for table=&_cstTable will be generated as &_cstItemGroupOID
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;  

    %if %sysevalf(%superq(_cstIsReferenceData)=, boolean) %then %do;
      %let _cstIsReferenceData=No;
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Missing ItemGroupData/@IsReferenceData for table=&_cstTable has been set to "No";
    %end;  

    %if &_cstIsReferenceData eq Yes 
      %then %let _cstReferenceOrClinical=ReferenceData;
      %else %let _cstReferenceOrClinical=ClinicalData;

    %if &_cstDebug %then %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] ItemGroupOID=&_cstItemGroupOID IsReferenceData=&_cstIsReferenceData;

    *** Transpose data;
    data work._cstTable_skinny_&_cstRandom / view=work._cstTable_skinny_&_cstRandom;
       length Table Column $ 32 ItemGroupDataSeq NVars 8 Value $ 2000;
       drop dsid i rc NVars;
       retain Table "&_cstTable";
       dsid=open("&_cstSrcLibref..&_cstTable", "i");
       NVars=attrn(dsid, "nvars");
       do while (fetch(dsid)=0);
        ItemGroupDataSeq+1;
          do i=1 to NVars;
             call missing(value);
             Column=upcase(varname(dsid, i));
             if (vartype(dsid, i)='C') then do;
                Value=strip(getvarc(dsid, i));
                if not missing(Value) then output;
             end;
             else do;
               Value=strip(put(getvarn(dsid, i), &_cstNumericFormat));
               if not missing(Value) then output;
             end;
          end;
       end;
       rc=close(dsid);
    run;

    *** Merge with Metadata;
    data work.itemdata_itemdefs_&_cstRandom(keep=ItemGroupDataSeq __ItemGroupOID __ItemOID value table column rc DataType Length) 
      /view=work.itemdata_itemdefs_&_cstRandom;
     length __ItemOID __ItemGroupOID $128 DataType $18 Length 8 value $2000 column table $32 ;
     if _n_=1 then do;
      declare hash ht(dataset:"work._cst_metadata_&_cstRandom(where=(table='&_cstTable')))", ordered: 'a');
      ht.defineKey("column");
      ht.defineData('table', 'column', '__ItemOID', '__ItemGroupOID', 'DataType', 'Length');
      ht.defineDone();
      call missing(table, column, __ItemOID, __ItemGroupOID, DataType, Length);
     end;
     set work._cstTable_skinny_&_cstRandom end=last;
     rc=ht.find(key: column);
    run;
    
    %************************;
    %*  Create output file  *;
    %************************;
    *** Create Dataset-XML file;
    data _cstIssues&_cstRandom(keep=__ItemOID column table) 
         %if %upcase(%substr(&_cstCheckLengths,1,1)) eq Y %then 
           _cstIssues_length_&_cstRandom(keep=table column __ItemGroupOID __ItemOID Length _valueLength value);;
      set work.itemdata_itemdefs_&_cstRandom end=last;
      length stringValue $1000;
      call missing(stringValue);

      by ItemGroupDataSeq notsorted;
      %if %sysevalf(%superq(_cstOutputEncoding)=, boolean)=0 %then %do;
        file _xml&_cstRandom encoding="&_cstOutputEncoding" &_cstLRECL;
      %end;
      %else %do;
        file _xml&_cstRandom &_cstLRECL;
      %end;
      if _n_=1 then do;
        %if %sysevalf(%superq(_cstOutputEncoding)=, boolean)=0 %then %do;
          put '<?xml version="1.0" encoding="' "&_cstOutputEncoding" '"?>';
        %end;
        %else %do;
          put '<?xml version="1.0"?>';
        %end;
        %if not %sysevalf(%superq(_cstHeaderComment)=, boolean) %then %do;
          put "<!-- %nrbquote(&_cstHeaderComment) -->";;
        %end;
        put "<ODM";
        put &_indent2 'xmlns="http://www.cdisc.org/ns/odm/v1.3"';
        put &_indent2 'xmlns:data="http://www.cdisc.org/ns/Dataset-XML/v1.0"';
        put &_indent2 'ODMVersion="1.3.2"';
        put &_indent2 'FileType="Snapshot"';
        put &_indent2 'FileOID="' "&&_cstStudyOID..&_cstTable" '"';
        put &_indent2 'PriorFileOID="' "&_cstFileOID" '"';
        %if %sysevalf(%superq(_cstCreationDateTime)=, boolean) %then 
          put &_indent2 'CreationDateTime="' "%sysfunc(datetime(), IS8601DT.)" '"';
          %else put &_indent2 'CreationDateTime="' "%nrbquote(&_cstCreationDateTime)" '"';;
        %if not %sysevalf(%superq(_cstAsOfDateTime)=, boolean) %then put &_indent2 'AsOfDateTime="' "%nrbquote(&_cstAsOfDateTime)" '"';;
        %if not %sysevalf(%superq(_cstOriginator)=, boolean) %then %do;
          stringValue=htmlencode("%superq(_cstOriginator)",'quot apos gt lt amp');
          put &_indent2 'Originator="' stringValue +(-1) '"';;
        %end;  
        %if not %sysevalf(%superq(_cstSourceSystem)=, boolean) %then %do;
          stringValue=htmlencode("%superq(_cstSourceSystem)",'quot apos lt gt amp');
          put &_indent2 'SourceSystem="' stringValue +(-1) '"';;
        %end;  
        %if not %sysevalf(%superq(_cstSourceSystemVersion)=, boolean) %then %do;
          stringValue=htmlencode("%superq(_cstSourceSystemVersion)",'quot apos gt lt amp');
          put &_indent2 'SourceSystemVersion="' stringValue +(-1) '"';;
        %end;  
          
        put &_indent2 'data:DatasetXMLVersion="1.0.0">';
        put &_indent2 "<&_cstReferenceOrClinical " @;
        put 'StudyOID="' "&_cstStudyOID" '" MetaDataVersionOID="' "&_cstMetadataVersionOID" '">';
      end;

      if first.ItemGroupDataSeq then 
        put &_indent4 '<ItemGroupData ItemGroupOID="' "&_cstItemGroupOID" '" data:ItemGroupDataSeq="' ItemGroupDataSeq +(-1) '">';      
      
      if missing(__ItemOID) then do;
        __ItemOID=cats("IT.&_cstTable..", column);
        output _cstIssues&_cstRandom;
      end;
        
      %if %upcase(%substr(&_cstCheckLengths,1,1)) eq Y %then 
      %do;
        if Datatype="text" and (. < length < length(value)) then do;
          _valueLength=length(value);
          putlog "WAR%str(NING): [CSTLOG" "MESSAGE.&sysmacroname] Length too short: " __ItemGroupOID= __ItemOID= Length= _valueLength= value=;
          output _cstIssues_length_&_cstRandom;
        end;   
        if Datatype="text" and missing(length) then do;
          _valueLength=length(value);
          putlog "WAR%str(NING): [CSTLOG" "MESSAGE.&sysmacroname] Length missing: " __ItemGroupOID= __ItemOID= Length= _valueLength= value=;
          output _cstIssues_length_&_cstRandom;
        end;   
      %end;

      value=htmlencode(value, 'amp lt gt quot');
      
      put &_indent6 '<ItemData ItemOID="' __ItemOID +(-1) '" Value="' value +(-1) '"/>';
      if last.ItemGroupDataSeq then 
        put &_indent4 '</ItemGroupData>';
      
      if last then do;
        put &_indent2 "</&_cstReferenceOrClinical>";
        put "</ODM>";
      end;  
    run; 
    
    %*****************************;
    %*  Report missing ItemOIDs  *;
    %*****************************;
    proc sort data=_cstIssues&_cstRandom nodupkey;
    by __ItemOID column;  
    run;

    options NoQuoteLenMax;  
    %let _cstMissingOID=;
    proc sql noprint;
      select unique cats(table, ".", column) into: _cstMissingOID separated by ' '
    from _cstIssues&_cstRandom;
    quit;  
    %if %sysevalf(%superq(_cstMissingOID)=, boolean)=0 %then
    %do;  
      %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Columns not found in metadata: &_cstMissingOID;
      %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
      %do;
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Columns not found in metadata: &_cstMissingOID
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
        %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
        %cstutil_writeresult(
                    _cstResultId=DATA0098
                    ,_cstResultParm1=Missing ItemData/@ItemOID for these columns will be generated as IT.<TABLE>.<COLUMN>
                    ,_cstResultSeqParm=&_cstResultSeq
                    ,_cstSeqNoParm=&_cstSeqCnt
                    ,_cstSrcDataParm=&_cstSrcMacro
                    ,_cstResultFlagParm=0
                    ,_cstRCParm=&_cst_rc
                    );
      %end;
    %end;

      
    data _null_;
      set _cstIssues&_cstRandom;
        putlog "WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Missing ItemData/@ItemOID for " column= "will be generated as " __ItemOID;
    run;        

    %*****************************;
    %*  Report length issues     *;
    %*****************************;
    %if %upcase(%substr(&_cstCheckLengths,1,1)) eq Y %then 
    %do;
      %let _cstLengthIssues=;
      proc sql noprint;
        select unique cats(table, ".", column) into: _cstLengthIssues separated by ' '
      from _cstIssues_length_&_cstRandom;
      quit;  
      %if %sysevalf(%superq(_cstLengthIssues)=, boolean)=0 %then
      %do;  
        %put WAR%str(NING): [CSTLOG%str(MESSAGE).&sysmacroname] Check Log for potential length issues when reading Dataset-XML: &_cstLengthIssues;
        %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
        %do;
          %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
          %cstutil_writeresult(
                      _cstResultId=DATA0098
                      ,_cstResultParm1=Check Log for potential length issues when reading Dataset-XML: &_cstLengthIssues
                      ,_cstResultSeqParm=&_cstResultSeq
                      ,_cstSeqNoParm=&_cstSeqCnt
                      ,_cstSrcDataParm=&_cstSrcMacro
                      ,_cstResultFlagParm=0
                      ,_cstRCParm=&_cst_rc
                      );
        %end;
      %end;
      
    %end;

    %if not &_cstDebug %then %do;
      %cstutil_cstDeleteMember(_cstMember=_cstIssues&_cstRandom);
      %if %upcase(%substr(&_cstCheckLengths,1,1)) eq Y %then 
      %do;
        %cstutil_cstDeleteMember(_cstMember=_cstIssues_length_&_cstRandom);
      %end;
      %cstutil_cstDeleteMember(_cstMember=_cstTable_skinny_&_cstRandom, _cstMemtype=view);
      %cstutil_cstDeleteMember(_cstMember=itemdata_itemdefs_&_cstRandom, _cstMemtype=view);
    %end;

    %* Time the processing;
    %let _cstElapsed=%sysfunc(putn(%sysevalf(%sysfunc(datetime())-&_cstElapsed), 8.2));
    %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] &_cstSrcLibref..&_cstTable converted %str
      ()to &_cstDatasetXMLFile in &_cstElapsed seconds (&_cstNobs records).;
    %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
    %do;
      %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
      %cstutil_writeresult(
                  _cstResultId=DATA0097
                  ,_cstResultParm1=&_cstSrcLibref..&_cstTable converted to &_cstDatasetXMLFile in &_cstElapsed seconds (&_cstNobs records).
                  ,_cstResultSeqParm=&_cstResultSeq
                  ,_cstSeqNoParm=&_cstSeqCnt
                  ,_cstSrcDataParm=&_cstSrcMacro
                  ,_cstResultFlagParm=&_cst_rc
                  ,_cstRCParm=&_cst_rc
                  );
    %end;
    

    %**************************;
    %*  Zip Dataset-XML file  *;
    %**************************;
    %if %upcase(%substr(&_cstZip,1,1)) eq Y %then 
    %do;
      
      %let _cstDatasetZIPFile=%sysfunc(pathname(&_cstOutputLibrary))&_cstPathDelim.%lowcase(&_cstTable).zip;
      
      ods package(ProdOutput) open nopf; 
      ods package(ProdOutput) add file="&_cstDatasetXMLFile"; 
      ods package(ProdOutput) publish archive properties(
        archive_name="%lowcase(&_cstTable).zip" 
        archive_path="%sysfunc(pathname(&_cstOutputLibrary))"
        );
      ods package(ProdOutput) close;

      %if %sysfunc(fileexist(&_cstDatasetZIPFile)) %then %do;
        %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Zip file &_cstDatasetZIPFile was created.;
        %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
        %do;
          %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
          %cstutil_writeresult(
                      _cstResultId=DATA0097
                      ,_cstResultParm1=Zip file &_cstDatasetZIPFile was created
                      ,_cstResultSeqParm=&_cstResultSeq
                      ,_cstSeqNoParm=&_cstSeqCnt
                      ,_cstSrcDataParm=&_cstSrcMacro
                      ,_cstResultFlagParm=&_cst_rc
                      ,_cstRCParm=&_cst_rc
                      );
        %end;
      %end;
      
      %if %upcase(%substr(&_cstDeleteAfterZip,1,1))=Y %then %do;
        %if %sysfunc(fileexist(&_cstDatasetZIPFile)) %then %do;
            %if %sysfunc(filename(fref,&_cstDatasetXMLFile)) %then %put %sysfunc(sysmsg());
            %if %sysfunc(fdelete(&fref)) 
              %then %put %sysfunc(sysmsg());
              %else 
              %do;
                %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Dataset-XML file &_cstDatasetXMLFile was deleted.;
                %if %symexist(_cstResultsDS) %then %if %sysfunc(exist(&_cstResultsDS)) %then
                %do;
                  %let _cstSeqCnt=%eval(&_cstSeqCnt+1);
                  %cstutil_writeresult(
                              _cstResultId=DATA0097
                              ,_cstResultParm1=Dataset-XML file &_cstDatasetXMLFile was deleted
                              ,_cstResultSeqParm=&_cstResultSeq
                              ,_cstSeqNoParm=&_cstSeqCnt
                              ,_cstSrcDataParm=&_cstSrcMacro
                              ,_cstResultFlagParm=&_cst_rc
                              ,_cstRCParm=&_cst_rc
                              );
                %end;
              %end;
        %end;
        %else %put NOTE: [CSTLOG%str(MESSAGE).&sysmacroname] Zip file &_cstDatasetZIPFile does not exist.;  
      %end;
      
    %end;
  
    filename _xml&_cstRandom clear; 

%exit_loop:

  %end;
  %*************************************************;
  %* End of Loop through the Dataset list          *;
  %*************************************************;

  %**************************;
  %*  Cleanup               *;
  %**************************;
  sasfile _cst_metadata_&_cstRandom close;

  %if not &_cstDebug %then %do;
    %cstutil_cstDeleteMember(_cstMember=_cst_metadata_&_cstRandom);
  %end;
  
  %if &_cstMetadataCleanup %then 
  %do;
    proc datasets lib=md&_cstRandom kill memtype=data nolist;
    run; quit;
    filename md&_cstRandom "%sysfunc(pathname(work))&_cstPathDelim.md&_cstRandom";
    %let rc=%sysfunc(fdelete(md&_cstRandom));
    filename md&_cstRandom clear;
    libname md&_cstRandom clear;
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
  options &_cstSaveOptQuoteLenMax;
  options &_cstSaveOptCompress &_cstSaveOptReuse;
  
  %if %sysevalf(%superq(_cstSaveOptMissing)=, boolean)
    %then options missing=" ";
    %else options missing=&_cstSaveOptMissing;

%mend datasetxml_write;
