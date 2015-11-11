/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.6 */
/*******************************************************/

/*******************************************************/
/* Macro: ExtractCorr
/*******************************************************/
%macro ExtractCorr(DSCorr, DSOut);

data _Null_;
 set &DSCorr;
 if _TYPE_="CORR" then  call symput ("V_" || left(_N_-3), _NAME_);
 call symput("N" , compress(_N_));
run;

/* adjust number of variables */
%local N;
%let N=%eval(&N-3);

/* loop on the variables and generate the pairs and obtain
   their correlation coefficients */

    proc sql noprint;
	create table &DSOut (Var1 char(120), Var2 char(120), Coefficient num);
 %local i j;
%do i=1 %to %eval(&N-1);
  %do j=%eval(&i+1) %to &N;
     /* find the correlaion coefficient of variable V_i, V_j 
        and store them in the output dataset */

      select  &&V_&i into: corr from &DSCorr where _Name_="&&V_&j" and _type_="CORR";
	  insert into &DSout values("&&V_&i", "&&V_&j", &corr);
   %end;
%end;

/* Calculate the absolute value of the correlation coefficients */
data &DSout;
 set &DSout;
 ABSCoefficient=ABS(Coefficient);
 run;


/* Sort the output dataset in descending order of the coefficient */
proc sort data=&DSout;
 by descending ABScoefficient;
run;

%mend;



/*******************************************************/
/* Generate the Homes dataset */
/*******************************************************/
data Homes;
input Income Value1 Value2 @@;
datalines;
20 120 120   22 165 165   25 203 203
25 205 205   31 192 192   33 220 220  
36 129 129   36 269 269   37 136 136
40 364 364   48 194 759   52 285 285
55 279 279   59 320 320   64 370 370
81 448 448   83 514 514   98 419 419
99 613 613   99 526 667
;
run;

/*******************************************************/
/* Calculate the correlation coefficients using
   PROC FREQ */
/*******************************************************/
proc corr data=Homes Pearson Spearman OutS=SCorr;
var  Value1 Value2 Income;
run;

/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSCorr=SCorr;
%let DSout=Corr_values;
%ExtractCorr(&DSCorr, &DSout);


/*******************************************************/
/* Print the cresults dataset to the output window */
/*******************************************************/
proc print data=Corr_Values;
run;

/*******************************************************/
/* Print the results again in a nice format! */ 
/*******************************************************/
options linesize=120; 
proc print data=Corr_values split='*' ;
     var Var1 Var2 Coefficient AbsCoefficient;
     label Var1='First*Variable*========='
           Var2='Second*Variable*========='
		   Coefficient='Coefficient**============'
		   ABSCoefficient='Absolute*Value*============';
		   format Coefficient  f10.6; 
		   format ABsCoefficient  f10.6; 

   title 'Correlation Coefficients';
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

