/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro : PowerGini */
/*******************************************************/

%macro PowerGini(DSin, DV, IVList, DSout);


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

/* now we have a total of N variables
   Loop on their  names and calculate the Gini variance
   between the DV and each of the variables */

proc sql noprint;
 create table &DSout (VariableName char(200), GiniVariance num);
quit;

%do i=1 %to &N;
   %let G&i=;
	%GNomBin(&DSin, &&Var&i, &DV, G&i);
	proc sql noprint; 
     insert into &DSout  values("&&Var&i",&&G&i);
    quit; 	 
%end;



proc sort data=&dsout;
 by descending GiniVariance; 
 run;

%mend; 

