/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro DummyGrpn */
/*******************************************************/
%macro dummyGrpn(DSin, Xvar, DSOut, MapDS);
/* dummy grouping of a varible and generating its map
  the new variable name is the old variable name subscripted
  by _b and MapDS is the mapping between the categories
  the DSout contains all the variables of DSin in addition
  to  Xvar_b (the bin number)

  This macro is to be used with numeric nominal  variables */

/* create the map ds */
proc freq data=&DSin noprint;
table &Xvar/out=&MapDS;
run;
data &MapDS;
 set &MapDS;
  Category=&XVar;
  Bin=_N_;
  keep Category Bin;
run;
/* apply these maps to the dataset to generate DSout */
%local m i;
proc sql noprint;
 select count(Bin) into:m from &MapDS;
quit; 
%do i=1 %to &m;
 %local Cat_&i Bin_&i;
%end; 

data _null_;
 set &MapDS;
  call symput ("Cat_"||left(_N_), trim(Category));
  call symput ("Bin_"||left(_N_), bin);
run;

/* the actual replacement */
Data &DSout;
 set &DSin;
 %do i=1 %to &m;
   IF &XVar = &&Cat_&i		THEN &Xvar._b=&&Bin_&i;
 %end;
Run; 

%mend;

