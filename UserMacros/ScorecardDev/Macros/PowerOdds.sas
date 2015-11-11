/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro: PowerOdds */
/*******************************************************/

%macro PowerOdds(DSin, DV, IVList, DSout);

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
					  OddsRatio          num ,
					  UL_95_OddsRatio    num ,
                      LL_95_OddsRatio    num);
quit;

%local Odds Uodds Lodds Xvar;
%do i=1 %to &N;
   %let Odds=;
   %let Uodds=;
   %let LOdds=;
   %let Xvar=&&Var&i;
   %OddsRatio(&DSin, &XVar, &DV, Odds, Uodds, LOdds);


proc sql noprint; 
insert into &DSout  values("&&Var&i", &Odds, &Uodds, &LOdds);
    quit; 	 
%end;

/* To allow the easy comparison of odds ratios, we calculate the NormOdds
   defined as: 
    norm odds= if odds <1 then Norm odds=1/Odds ratio
               else             Norm odds= odds ratio
*/
data &DSout;
 set &DSout;
  if OddsRatio<1 then NormOddsRatio=1/OddsRatio;
  else                NormOddsRatio=OddsRatio;
run;


%mend; 

