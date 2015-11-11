/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 3.3 */
/*******************************************************/

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

/*******************************************************/
/* Generate a dataset with dependent variable Status
   and an independent variable Income (monthly income) */
/*******************************************************/
data Customers;
 input Status Income @@;
 datalines;
0	1923.78	0	754.04	0	934.12	1	830.36	0	1749.9
0	1903.87	0	1835.18	1	2419.84	0	771.56	0	1945.69
0	1475.22	1	1117.34	0	1537.49	1	1141.03	0	733.04
0	870.65	0	2088.48	0	590.5	0	1509.77	1	1843.16
0	1380.64	0	662.58	0	301.79	0	1627.66	0	603.68
0	1022.61	0	2240.7	0	1401.81	1	1797.92	0	1933.54
0	2046.81	0	2204.92	0	1022.64	0	1411.42	1	1449.86
0	1615.16	0	1517.89	0	1812.05	0	1172.78	0	2296.67
1	865.35	0	310.7	0	1524.75	0	1039.29	0	596.35
0	1680.61	0	2104.21	0	1103.94	0	2239.71	0	1889.27
0	1007.24	1	1586.02	0	565.35	0	1720.2	1	2398.76
0	482.73	0	2247.51	0	1555.7	1	1869.64	0	724.54
0	621.16	0	356.17	0	1663.88	0	955.77	0	2024.46
0	822.99	0	554.11	0	1867.84	1	2468.87	0	893.19
0	630.12	0	1876.82	0	1436.33	0	1832.13	0	1157.21
0	1690.42	0	2141.84	1	1932.7	0	2298.38	0	1293.89
0	1035.24	0	981.24	0	2163.58	0	675.95	0	1216.15
0	2220.74	1	2153.51	0	901.71	1	1122.39	0	1801.04
0	1003.79	0	1510.24	0	898.5	0	1537.91	1	1635.87
0	1826.32	0	1247.07	0	2078.9	1	2310.28	0	456.06
;
run;

/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=Customers;
%let DVVar=Status;
%let VarX=Income;
%let NBins=5;
%let Method=2;
%let DSChc=Income_chc;
%ChcAnalysis(&DSin, &DVVar, &VarX, &NBins, &Method, &DSChc);

/*******************************************************/
/* Print the cresults dataset to the output window */
/*******************************************************/
proc print data=Income_chc;
run;

/*******************************************************/
/* Print the results again using a nice format */ 
/*******************************************************/
options linesize=120; 
proc print data=Avg_Income_chc split='*' ;
     var bin LowerBound UpperBound N_1 N_0 BinTotal Percent_1 Percent_0;
     label bin       ='Bin*Number*========='
           LowerBound='Lower*Bound*========='
           UpperBound='Upper*Bound*========='
           N_1       ='Number*of Bads*==========='
           N_0       ='Number*of Goods*==========='
           BinTotal  ='Bin*Total*=========='
           Percent_1 ='Bad*Percent*=========='
           Percent_0='Good*Percent*==========';
		   format LowerBound dollar10.2;
		   format UpperBound dollar10.2;
	       format Percent_1  f10.2; 
		   format Percent_0  f10.2; 

   title 'Characteristics Analysis for Average Monthly Income';
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

