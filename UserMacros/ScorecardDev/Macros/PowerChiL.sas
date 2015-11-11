/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/



/*******************************************************/
/* Macro : PowerChiL */
/*******************************************************/
%macro PowerChiL(DSin, DV, IVList, DSout);
/* Calculation of the predictive power of a set of variables
   using the Pearson Chi-square and likelihood tests
    and storing the results in the output dataset DSout 
   The test is done for a binary DV and a set of nominal variables
*/

/* Decompose the input IVList into tokens and store variable
   names into macro variables */

%local i N condition VarX; 
%let i=1;
%let N=0;
%let condition = 0; 
%do %until (&condition =1);
   %let VarX=%scan(&IVList,&i);
   %if "&VarX" =""  %then %let condition =1;
  	        %else %do;
				%local Var&i;
                %let Var&i =&VarX; 
                %let N=&i;
                %let i=%eval(&i+1); 
                  %end;  
%end;

/* create the output dataset */ 
proc sql noprint;
 create table &DSout (VariableName   char(200),
					  ChiSquared          num ,
					  ChiSquared_PValue   num,
                      Likelihood          num ,
                      Likelihood_Pvalue   num);
quit;

%local chi chip L Lp Xvar;
%do i=1 %to &N;
   %let chi=;
   %let chip=;
   %let L=;
   %let Lp=;
   %let Xvar=&&Var&i;
   %ChiLike(&DSin, &XVar, &DV, chi, Chip, L, Lp);
	%if (&Chi=) %then %let chi=0;
    %if (&Chip=) %then %let chip=0;
    %if (&L=) %then %let L=0;
    %if (&Lp=) %then %let Lp=0;


proc sql noprint; 
insert into &DSout  values("&&Var&i", &chi, &Chip, &L, &Lp);
    quit; 	 
%end;


%mend; 


