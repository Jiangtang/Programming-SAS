/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro ApplyMap2 */
/*******************************************************/
%macro ApplyMap2(DSin, VarX, NewVarX, DSVarMap, DSout);
/* Applying a mapping scheme; to be used with 
 macro BinContVar */

/* Generating macro variables to replace the cetgories with their bins */
%local m i;
proc sql noprint;
 select count(Bin) into:m from &DSVarMap;
quit; 
%do i=1 %to &m;
 %local Upper_&i Lower_&i Bin_&i;
%end; 
data _null_;
 set &DSVarMap;
  call symput ("Upper_"||left(_N_), UL);
  call symput ("Lower_"||left(_N_), LL);
  call symput ("Bin_"||left(_N_), Bin);
run;
/* the actual replacement */
Data &DSout;
 set &DSin;
 /* first bin - open left */
 IF &VarX < &Upper_1 Then &NewVarX=&Bin_1;
 /* intermediate bins */
 %do i=2 %to %eval(&m-1);
   if &VarX >= &&Lower_&i and &VarX < &&Upper_&i Then &NewVarX=&&Bin_&i;
 %end;
/* last bin - open right */
   if &VarX >= &&Lower_&i  Then &NewVarX=&&Bin_&i;  
Run; 
%mend;
