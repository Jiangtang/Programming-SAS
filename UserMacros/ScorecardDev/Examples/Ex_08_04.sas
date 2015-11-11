/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 8.4 */
/*******************************************************/

/*******************************************************/
/* Macro: CalcWOE */
/*******************************************************/
%macro CalcWOE(DsIn, IVVar, DVVar, WOEDS, WOEVar, DSout);
/* Calculating the WOE of an Independent variable IVVar and 
adding it to the data set DSin (producing a different output 
dataset DSout). The merging is done using PROC SQL to avoid 
the need to sort for matched merge. The new woe variable
is called teh WOEVar. The weight of evidence values
are also produced in the dataset WOEDS*/

/* Calculate the frequencies of the categories of the DV in each
of the bins of the IVVAR */

PROC FREQ data =&DsIn noprint;
  tables &IVVar * &DVVar/out=Temp_Freqs;
run;

/* sort them */
proc sort data=Temp_Freqs;
 by &IVVar &DVVar;
run;

/* Sum the Goods and bads and calcualte the WOE for each bin */
Data Temp_WOE1;
 set Temp_Freqs;
 retain C1 C0 C1T 0 C0T 0;
 by &IVVar &DVVar;
 if first.&IVVar then do;
      C0=Count;
	  C0T=C0T+C0;
	  end;
 if last.&IVVar then do;
       C1=Count;
	   C1T=C1T+C1;
	   end;
 
 if last.&IVVar then output;
 drop Count PERCENT &DVVar;
call symput ("C0T", C0T);
call symput ("C1T", C1T);
run;

/* summarize the WOE values ina woe map */ 
Data &WOEDs;
 set Temp_WOE1;
  GoodDist=C0/&C0T;
  BadDist=C1/&C1T;
  if(GoodDist>0 and BadDist>0)Then   WOE=log(BadDist/GoodDist);
  Else WOE=.;
  keep &IVVar WOE;
run;

proc sort data=&WOEDs;
 by WOE;
 run;

/* Match the maps with the values and create the output
dataset */
proc sql noprint;
	create table &dsout as 
	select a.* , b.woe as &WOEvar from &dsin a, &woeds b where a.&IvVar=b.&IvVar; 
quit;

/* Clean the workspace */
proc datasets library=work nodetails nolist;
 delete Temp_Freqs Temp_WOE1;
run; quit;
%mend;


/*******************************************************/
/* Load the CreditCard dataset */
/*******************************************************/
/* Set the folder where the file is located */
%let dir=C:\scorecardDev\Examples;
/* the actual data definition */
%include "&dir\CC_Dataset.sas";

/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DsIn=CreditCard; 
%let DVVar=Status;
%let IVVar=ResStatus;
%let WOEDS=ResStatus_WOE;
%let DSout=CreditCard_WOE1; 
%let WOEVar=ResStatus_WOE;
%CalcWOE(&DsIn, &IVVar, &DVVar, &WOEDs,&woevar,&DSout);


/* Print the WOE values for the categories of ResStatus */
/* simple list */
proc print data=ResStatus_WOE;
run;

/* A nicer output ... */
options linesize=120 nodate; 
proc print data=ResStatus_WOE split='*' ;
     var ResStatus WOE ;
     label ResStatus='Residential*Status*========='
           WOE='Weight of*Evidence*=========';
		   format ResStatus  $12.; 
		   format WOE  f10.6; 

   title 'Weight of Evidence Transformation for Residential Status';
run;
 


/*******************************************************/
/* Clean the work space and reset the title*/
/*******************************************************/
title '';
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



