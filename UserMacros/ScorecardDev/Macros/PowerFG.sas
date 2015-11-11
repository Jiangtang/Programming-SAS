/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro : PowerFG */
/*******************************************************/


%macro PowerFG(DSin, DV, IVList, DSout);

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


proc sql noprint;
 create table &DSout (VariableName char(200),
					  GiniRatio         num ,
                      FStar             num ,
                      Fstar_Pvalue      num);
quit;


%do i=1 %to &N;
   %local Gr&i Fstar&i pvalue&i;
   %let Gr&i=;
   %let Fstar&i=;
   %let Pvalue&i=;
    %GrFBinDV(&DSin, &&Var&i, &DV, Gr&i, Fstar&i, Pvalue&i);

proc sql noprint; 
insert into &DSout  values("&&Var&i", &&Gr&i, &&Fstar&i, &&Pvalue&i);
    quit; 	 
%end;


%mend; 

