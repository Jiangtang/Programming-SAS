*******************************************************************************;
* Location of the Dataset-XML root                                            *;
*******************************************************************************;
%let DatasetXMLRoot=c:/datasetxml;

%******************************************************************************;
%* Local Support macro                                                        *; 
%******************************************************************************;
%macro CIMPORTit(folder);
  libname  lib1 "&folder";
  filename stcFile "&folder/cported.stc";

  proc cimport lib=lib1
    file=stcFile;
  run;

  libname lib1;
  filename stcFile;
%mend cimportit;

%******************************************************************************;
%* Import the CPORT files                                                     *; 
%******************************************************************************;
%CIMPORTit(&DatasetXMLRoot/messages);
%CIMPORTit(&DatasetXMLRoot/results);
%CIMPORTit(&DatasetXMLRoot/sasdata/original/sdtm);
%CIMPORTit(&DatasetXMLRoot/sasdata/original/adam);
%CIMPORTit(&DatasetXMLRoot/sasdata/imported/sdtm);
%CIMPORTit(&DatasetXMLRoot/sasdata/imported/adam);
  