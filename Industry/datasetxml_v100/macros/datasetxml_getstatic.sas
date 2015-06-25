%* datasetxml_getstatic                                                           *;
%*                                                                                *;
%* Returns constant values that are used by other macros.                         *;
%*                                                                                *;
%* @param _cstName The name of the value to retrieve.                             *;
%*         Values: DATASET_SASREF_TYPE_REFXML | DATASET_SASREF_TYPE_EXTXML |      *;
%*                 DATASET_SASREF_TYPE_SOURCEDATA |                               *;
%*                 DATASET_SASREF_TYPE_SOURCEMETADATA |                           *;
%*                 DATASET_SASREF_TYPE_TARGETDATA |                               *;
%*                 DATASET_SASREF_SUBTYPE_XML | DATASET_SASREF_SUBTYPE_METAMAP |  *;
%*                 DATASET_SASREF_SUBTYPE_DATAMAP |                               *;
%*                 DATASET_JAVA_PARAMSCLASS | DATASET_JAVA_IMPORTCLASS |          *;
%*                 DATASET_JAVA_EXPORTCLASS | DATASET_JAVA_PARSEXML               *;
%*                 DATASET_JAVA_PICKLIST                                          *;
%* @param _cstVar  The macro variable to populate with the value.                 *;
%*                                                                                *;
%* @since 1.7                                                                     *;
%* @exposure internal                                                             *;

%macro datasetxml_getStatic(
    _cstName=,
    _cstVar=
    ) / des="CST: CDISC-DEFINE-XML static variables";

  %*
  DATASETXML - sasreferences values.
  ;
  %if (&_cstName=DATASET_SASREF_TYPE_REFXML) %then %let &_cstVar=referencexml;
  %else %if (&_cstName=DATASET_SASREF_TYPE_EXTXML) %then %let &_cstVar=externalxml;
  %else %if (&_cstName=DATASET_SASREF_TYPE_SOURCEDATA) %then %let &_cstVar=sourcedata;
  %else %if (&_cstName=DATASET_SASREF_TYPE_SOURCEMETADATA) %then %let &_cstVar=sourcemetadata;
  %else %if (&_cstName=DATASET_SASREF_TYPE_TARGETDATA) %then %let &_cstVar=targetdata;
  %else %if (&_cstName=DATASET_SASREF_TYPE_EXTXML) %then %let &_cstVar=externalxml;
  %else %if (&_cstName=DATASET_SASREF_SUBTYPE_XML) %then %let &_cstVar=xml;
  %else %if (&_cstName=DATASET_SASREF_SUBTYPE_METAMAP) %then %let &_cstVar=metamap;
  %else %if (&_cstName=DATASET_SASREF_SUBTYPE_DATAMAP) %then %let &_cstVar=datamap;

  %*
  DATASETXML JAVA Information
  ;
  %else %if (&_cstName=DATASET_JAVA_PARAMSCLASS) %then %let &_cstVar=com/sas/ptc/transform/xml/StandardXMLTransformerParams;
  %else %if (&_cstName=DATASET_JAVA_IMPORTCLASS) %then %let &_cstVar=com/sas/ptc/transform/xml/StandardXMLImporter;
  %else %if (&_cstName=DATASET_JAVA_EXPORTCLASS) %then %let &_cstVar=com/sas/ptc/transform/xml/StandardXMLExporter;
  %else %if (&_cstName=DATASET_JAVA_PARSEXML) %then %let &_cstVar=com/sas/ptc/datasetxml/ParseXML;
  %else %if (&_cstName=DATASET_JAVA_PICKLIST) %then %let &_cstVar=/* cstframework/cstframework.txt */;

%mend datasetxml_getStatic;
