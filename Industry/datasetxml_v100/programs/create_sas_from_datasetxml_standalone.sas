**********************************************************************************;
* create_sas_from_datasetxml_standalone.sas                                      *;
*                                                                                *;
* Sample driver program to create SAS data sets from a folder with Dataset-XML   *;
* V1.0.0 files.                                                                  *;
*                                                                                *;
* Assumptions:                                                                   *;
* The code, as written, is designed to be run as stand-alone code, with the user *;
* responsible for all library assignments. All information will be in the LOG.   *;
* A results data set will be created as well.                                    *;
*                                                                                *;
* CST version  1.7                                                               *;
*                                                                                *;
* The following filename and libname statements may need to be changed by the    *;
* user to ensure the correct paths.                                              *;
**********************************************************************************;

**********************************************************************************;
* Location of the Dataset-XML root                                               *;
**********************************************************************************;
%let DatasetXMLRoot=/datasetxml;

**********************************************************************************;
* Set Root paths for input and output                                            *;
**********************************************************************************;
%let studyRootPath=/datasetxml;
%let studyOutputPath=/datasetxml;

**********************************************************************************;
* Make the macros available                                                      *;
**********************************************************************************;
options mautosource sasautos=("&DatasetXMLRoot/macros", sasautos);

**********************************************************************************;
* Add the jar to the Classpath                                                   *;
**********************************************************************************;
%manageClasspath(Action=SAVE);
%manageClasspath(Action=ADD, ClassPath=&DatasetXMLRoot/lib/sas.cdisc.transforms.jar);

**********************************************************************************;
* Make messages available and Initialize results dataset                         *;
**********************************************************************************;
libname messages "&DatasetXMLRoot/messages";
%let _cstMessages=messages.messages;

libname results "&studyOutputPath/results";
%let _cstResultsDS=results.read_results;

data &_cstResultsDS;
  %cstutil_resultsdsattr;
  call missing(of _all_);
  stop;
run;  

************************************************************;
* Debugging aid:  set _cstDebug=1                          *;
************************************************************;
%let _cstDebug=0;
data _null_;
  _cstDebug = input(symget('_cstDebug'),8.);
  if _cstDebug then
    call execute("options mprint mlogic symbolgen mautolocdisplay;");
  else
    call execute("options nomprint nomlogic nosymbolgen nomautolocdisplay;");
run;

**********************************************************************************;
* Create SDTM SAS Data sets                                                      *;
**********************************************************************************;
libname dataxml  "&studyRootPath/xmldata/sdtm";
libname sdtmdata  "&studyRootPath/sasdata/imported/sdtm";
filename defxml  "&studyOutputPath/xmldata/sdtm/define.xml";

%datasetxml_read(
  _cstSourceDatasetXMLLibrary=dataxml,
  _cstOutputLibrary=sdtmdata,
  _cstSourceMetadataDefineFileRef=defxml,
  _cstdatetimeLength=64,
  _cstAttachFormats=Y
  );

libname dataxml clear;
libname sdtmdata clear;
filename defxml clear;


**********************************************************************************;
* Create ADaM SAS Data sets                                                      *;
**********************************************************************************;
libname dataxml "&studyRootPath/xmldata/adam";
libname adamdata "&studyRootPath/sasdata/imported/adam";
filename defxml "&studyOutputPath/xmldata/adam/define_adam.xml";

%datasetxml_read(
  _cstSourceDatasetXMLLibrary=dataxml,
  _cstOutputLibrary=adamdata,
  _cstSourceMetadataDefineFileRef=defxml,
  _cstdatetimeLength=64,
  _cstAttachFormats=Y
  );

libname dataxml clear;
libname adamdata clear;
filename defxml clear;


**********************************************************************************;
* Restore the Classpath                                                          *;
**********************************************************************************;
%manageClasspath(Action=RESTORE);


*******************************************************************************;
* Check results dataset for errors and warnings, and print in SAS log file.    ;
*******************************************************************************;
data _null_;
  format _character_;
  set &_cstResultsDS;
  if (resultflag ne 0) or (upcase(resultseverity) in ('WARNING' 'ERROR')) then do;
     resultseverity=upcase(resultseverity);
     putlog resultseverity +(-1) ": [CSTLOG%str(MESSAGE)] " message @;
     if not missing(resultdetails) then putlog ": "  resultdetails;
                                   else putlog;
  end;
run;
