/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro RandomSample  */
/*******************************************************/
%macro RandomSample(PopDS, SampleDS, SampleSize);
/* Extraction of random samples Sample SampleDS
   of size SampleSize from a population dataset DS */
    proc surveyselect 
        data=&PopDs
        method=srs 
        N=&SampleSize 
        noprint
        out=&SampleDS;
    run;
%mend;
