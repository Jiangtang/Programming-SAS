/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 5.5 */
/*******************************************************/

/*******************************************************/
/* Macro B2Partitions
/*******************************************************/
%macro B2Partitions(DSIn,IDVar,DVVar,DS1,N1,P1,DS2,N2,P2,M_Error);
/* This macro attempts to extract two balanced partitions S1, S2 of sizes
N1, N2 and proporations P1, P2, from a population (Dataset S). The balancing
is based on the values of the DV, which are restricted to "1","0".
Missing values of DV are ignored. */

/* Calculate N, P of the population*/
proc sql noprint;
 select count(*)into : N from &DSin;		/* Size of population */
 select count(*) into : NP from &DSin where &DVVar=1; /* count of "1" */
 run;
 quit;
%let NPc=%eval(&N - &NP);				/* Count of "0" (compliment)*/
/* Check the consistency conditions */

%let Nx=%eval(&N1 + &N2);
%if &Nx > &N %then %do;
	%let &M_Error = Not enough records in population to generate samples. Sampling cancelled. ;
	%goto Exit;
				   %end;


/* N1 P1 + N2 P2 <= N P */

%let Nx = %sysevalf((&N1*&P1+ &N2 * &P2), integer);
%if &Nx >&NP %then %do;
     %let &M_Error = Count of DV=1 in requested samples exceed total count in population. Sampling cancelled.;
	 %goto Exit;
	 			  %end;

/* N1(1-P1) + N2(1-P2) <= N(1-P)*/
%let Nx = %sysevalf( (&N1*(1-&P1) + &N2*(1-&P2) ), integer);
%if &Nx > &NPc %then %do;
     %let &M_Error = Count of DV=0 in requested samples exceed total count in population. Sampling cancelled.;
	 %goto Exit;
					%end;
/* Otherwise, OK */
%let &M_Error=OK;

/* Sort the population using the DV in ascending order*/
proc sort data=&DSin;
	by &DVVar;
run;

/* Draw the sample S1 with size N1 and number of records N1P1, N1(1-P1) 
   in the strata 1,0 of the DV */
%let Nx1=%Sysevalf( (&N1*&P1),integer);
%let Nx0=%eval(&N1 - &Nx1);

proc surveyselect noprint
		data =&DSin
        method = srs
	    n=( &Nx0 &Nx1)
		out=&DS1;
		strata &DVVar;
run;

/* Add a new field to S1 call it (Selected) and give it a value of 1. */
data &DS1; 
 set &DS1;
  selected =1;
  keep &IDVar &DVVar Selected;
 run;

/* Merge S1 with the population S to find the already selected fields.*/
proc sort data=&DSin;
	by &IDVar;
run;

proc sort data=&DS1;
	by &IDVar;
run;
Data temp;
 merge &DSin &DS1;
 by &IDvar;
  keep &IDVar &DVVar Selected;
run;

/* Draw the sample S2 with size N2 and number of records N2P2, N2(1-P2)
   in the strata 1,0 of the DV under the condition that Selected is 
   NOT 1 */
   
proc sort data=temp;
	by &DVVar;
run;
%let Nx1=%Sysevalf( (&N2*&P2),integer);
%let Nx0=%eval(&N2 - &Nx1);
proc surveyselect noprint
	    data =temp
        method = srs
	    n=( &Nx0 &Nx1)
		out=&DS2;
		strata &DVVar;
		where Selected NE 1;
run;

/* clean S1, S2  and workspace*/
Data &DS1;
 set &DS1;
 keep &IDvar &DVVar;
run;

Data &DS2;
 set &DS2;
 keep &IDVar &DVVar;
run;

proc datasets library=work nodetails;
 delete temp;
run;
quit;

%exit: ;
%mend;


/*******************************************************/
/* Generate a dataset with 1,500 records with 
   Bad rate of 20%  and a random variable X */
/*******************************************************/
	Data Population;
		 do ID=1 to 1500;
			   if ID <=300 then DV=1;
				  	    else DV=0;
		       x=ranuni(0); 
			output;
		end;
	run;

/*******************************************************/
/* Call the macro */
/*******************************************************/
   %let S=Population;
   %let IDVar=ID;    
   %let DV=DV;
/* The Modeling Sample */ 
   %let S1=Modeling;   
   %let N1=500;   
    %let P1=0.50;
/* The Validation Sample */ 
   %let S2=Validation; 
   %let N2=200;   
    %let P2=0.20;
   /* The error variable */
   %let Status=;

%B2Partitions(&S,&IDVar,&DV,&S1,&N1,&P1,&S2,&N2,&P2,Status);
/* Display the status variable in the SAS log. */
%put &status;

/*******************************************************/
/* Check the percentage of Bad in samples */
/*******************************************************/
proc freq data=Modeling;
table DV;
run;

proc freq data=Validation;
table DV;
run;

/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



