/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


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


