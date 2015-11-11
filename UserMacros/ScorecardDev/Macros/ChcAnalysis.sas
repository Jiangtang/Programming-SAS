/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro: ChcAnalysis
/*******************************************************/

%macro ChcAnalysis(DSin, DVVar, VarX, NBins, Method, DSChc);
/* Sort the dataset using the VarX */
proc sort data=&DSin;
by &VarX;
run;

Data temp;
 set &DSin ; 
 by &VarX; 
 _Obs=_N_;
keep &DVVAr &VarX _Obs;  
run;

proc sql noprint;
/* Method =1 == equal number of observations in each bin */ 
%if &Method=1 %then %do; 
/* Divide the population into NBins and count the number of observations where DVVar=1 and DVVar=0 */
	select count(&DVVar) into :N from temp;
    select max(_Obs), min(_Obs) into :Vmax, :Vmin from temp;  
%let BinSize=%sysevalf((&Vmax)/&Nbins); 
	%let LB_1=0;
%do i=1 %to %eval(&Nbins-1);
	%let LB_&i=%sysevalf(&LB_1+(&i-1)*&BinSize);
	%let UB_&i=%sysevalf(&&LB_&i + &BinSize);

select sum(&DVVar) , count(*) into :Sum_&i , :N_&i from temp 
                           where _obs>=&&Lb_&i and _obs<&&Ub_&i;

	%end;
	/* Last Bin */
	%let LB_&NBins=%sysevalf(&LB_1+(&NBins-1)*&BinSize);
    %let UB_&NBins=&Vmax;
		select sum(&DVVar) , count(*) into :Sum_&i , :N_&i from temp 
                           where _obs>=&&Lb_&i and _obs<=&&UB_&i;


%end; /* End of equal count bins */ 

%else %do ; /* Method<>1  bins are of equal size in VarX */

	select count(&DVVar) into :N from temp;
    select max(&VarX), min(&VarX) into :Vmax, :Vmin from temp;  
%let BinSize=%sysevalf((&Vmax-&Vmin)/&Nbins); 
	%let LB_1=&Vmin;
%do i=1 %to %eval(&Nbins-1);
	%let LB_&i=%sysevalf(&LB_1+(&i-1)*&BinSize);
	%let UB_&i=%sysevalf(&&LB_&i + &BinSize);

select sum(&DVVar) , count(*) into :Sum_&i , :N_&i from temp 
                           where &VarX>=&&Lb_&i and &VarX<&&Ub_&i;

	%end;
	/* Last Bin */
	%let LB_&NBins=%sysevalf(&LB_1+(&NBins-1)*&BinSize);
    %let UB_&NBins=&Vmax;
		select sum(&DVVar) , count(*) into :Sum_&i , :N_&i from temp 
                           where &VarX>=&&Lb_&i and &VarX<=&&UB_&i;

%end;

quit;

/* write the output dataset with the counts, percentages of DV=1 and DV=0 for each bin of VArX */

 data &DSChc;
 	%do i=1 %to &NBins;
	 Bin=&i;
	 LowerBound=&&LB_&i; 
	 UpperBound=&&UB_&i;
	 if (&&sum_&i =. ) then N_1=0; else N_1=&&Sum_&i;
	 if &&N_&i=. then BinTotal=0; else BinTotal=&&N_&i;
	 N_0 = BinTotal-N_1;
	 Percent_1=100*N_1/BinTotal;
	 Percent_0=100*N_0/BinTotal;
	 output;
	%end;
 Run;

/* Clean the workspace */ 
proc datasets nodetails nolist library=work;
delete temp;
run;
quit;

%mend;
