**********************************************************************************;
* compare_datasets.sas                                                           *;
*                                                                                *;
* Sample driver program to compare 2 folders with SAS data sets.                 *;
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
%let _cstResultsDS=results.compare_results;

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
* Compare SDTM SAS Data sets                                                     *;
**********************************************************************************;
libname database "&studyRootPath/sasdata/original/sdtm";
libname datacomp "&studyRootPath/sasdata/imported/sdtm";

%cstutilcomparedatasets(
  _cstLibBase=database,   
  _cstLibComp=datacomp, 
  _cstCompareLevel=16, 
  _cstCompOptions=%str(criterion=0.0000000000001 method=absolute),
  _cstCompDetail=Y
  ); 
  
**********************************************************************************;
* Compare ADaM SAS Data sets                                                     *;
**********************************************************************************;
libname database "&studyRootPath/sasdata/original/adam";
libname datacomp "&studyRootPath/sasdata/imported/adam";

%cstutilcomparedatasets(
  _cstLibBase=database,   
  _cstLibComp=datacomp, 
  _cstCompareLevel=16, 
  _cstCompOptions=%str(criterion=0.0000000000001 method=absolute),
  _cstCompDetail=Y
  ); 
  
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
