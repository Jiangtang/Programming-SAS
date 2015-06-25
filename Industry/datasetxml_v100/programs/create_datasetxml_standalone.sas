**********************************************************************************;
* create_datasetxml_standalone.sas                                               *;
*                                                                                *;
* Sample driver program to create Dataset-XML V1.0.0 files from a library of SAS *;
* data sets.                                                                     *;
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
* Make messages available and Initialize results dataset                         *;
**********************************************************************************;
libname messages "&DatasetXMLRoot/messages";
%let _cstMessages=messages.messages;

libname results "&studyOutputPath/results";
%let _cstResultsDS=results.write_results;

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
* Create SDTM Dataset-XML files                                                  *;
**********************************************************************************;
libname sdtmdata  "&studyRootPath/sasdata/original/sdtm";
filename defxml "&studyOutputPath/xmldata/sdtm/define.xml";
libname dataxml  "&studyOutputPath/xmldata/sdtm";

%datasetxml_write(
  _cstSourceLibrary=sdtmdata,
  _cstOutputLibrary=dataxml,
  _cstSourceMetadataDefineFileRef=defxml,
  _cstCheckLengths=Y,
  _cstIndent=N,
  _cstZip=Y,
  _cstDeleteAfterZip=N
  );  
  
libname sdtmdata clear;
filename defxml clear;
libname dataxml clear;

**********************************************************************************;
* Create ADaM Dataset-XML files                                                  *;
**********************************************************************************;
libname adamdata  "&studyRootPath/sasdata/original/adam";
filename defxml "&studyOutputPath/xmldata/adam/define_adam.xml";
libname dataxml  "&studyOutputPath/xmldata/adam";

%datasetxml_write(
  _cstSourceLibrary=adamdata,
  _cstOutputLibrary=dataxml,
  _cstSourceMetadataDefineFileRef=defxml,
  _cstCheckLengths=Y,
  _cstIndent=N,
  _cstZip=Y,
  _cstDeleteAfterZip=N
  );
  
libname adamdata clear;
filename defxml clear;
libname dataxml clear;

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
