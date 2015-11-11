/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro ApplyMap1 */
/*******************************************************/
%macro ApplyMap1(DSin, VarX, NewVarX, DSVarMap, DSout);
/* applying the mapping scheme
   to be used with ReduceCats */

/* Generating macro variables to replace the cetgories with their bins */
%local m i;
proc sql noprint;
 select count(&VarX) into:m from &DSVarMap;
quit; 
%do i=1 %to &m;
 %local Cat_&i Bin_&i;
%end; 

data _null_;
 set &DSVarMap;
  call symput ("Cat_"||left(_N_), trim(&VarX));
  call symput ("Bin_"||left(_N_), bin);
run;

/* the actual replacement */
Data &DSout;
 set &DSin;
 %do i=1 %to &m;
   IF &VarX = "&&Cat_&i"		THEN &NewVarX=&&Bin_&i;
 %end;
Run; 

%mend;
