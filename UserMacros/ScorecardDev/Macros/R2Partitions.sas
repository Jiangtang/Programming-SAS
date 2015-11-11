/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro: R2Partitions
/*******************************************************/
%macro R2Partitions(DSIn,IDVar,DS1,DS2,N1,N2,M_Error);

/* this macro extracts two partition two at random (if possible)
 The two partitions are of sizes N1, N2. The macro then merges all 
 the fields  from the original dataset into the new partitions. */ 

/* First check whether it is possible or not to extract the two 
   partitions with the specified sizes N1, N2. */

/* Step 1: Calculate N of the population*/
proc sql noprint;
 select count(*)into : N from &DSin;		/* Size of population */
 run;
 quit;

/* Step 2: Check the consistency condition */
%let Nx=%eval(&N1 + &N2);
 %if &Nx > &N %then %do;
 	 %let &M_Error = Error not enough records in input dataset - Sampling canceled ;
	 %goto Exit;
				   %end;
/* Otherwise, OK */
%let &M_Error=OK;
/* Step 3: Draw the sample temp_1 with size N1 */
 proc surveyselect noprint
		data =&DSin
    method = srs
	  n= &N1
		out=temp_1;
 run;
/* Step 4: Add a new field to temp_1 call it (Selected) 
   and give it a value of 1. */
 data temp_1; 
 set temp_1;
  selected =1;
  keep &IDVar Selected;
 run;

/* Step 5:  Merge temp_1 with the population S to find 
   the already selected fields.*/
 proc sort data=&DSin;
	by &IDVar;
 run;
 proc sort data=temp_1;
 	by &IDVar;
 run;
 Data temp;
  merge &DSin temp_1;
  by &IDvar;
   keep &IDVar Selected;
 run;

/* Step 6: Draw the sample temp_2 with size N2 under 
   the condition that Selected is NOT 1 */
   
 proc surveyselect noprint
	    data =temp
        method = srs
	    n=&N2
		out=temp_2;
		where Selected NE 1;
 run;

/* clean S1, S2  and workspace*/
 Data temp_1;
  set temp_1;
  keep &IDvar;
 run;

 Data temp_2;
  set temp_2;
  keep &IDVar;
 run;

/* merge with temp_1 , temp_2 */
proc sort data=&DSIn; 
 by &IDvar; 
run;
proc sort data=Temp_1;
 by &IDvar; 
run;
proc sort data=temp_2;
 by &IDvar; 
run;

data &DS1; 
merge Temp_1(in=x) &DSin; 
by &IDvar; 
if x; 

run;
data &DS2;
 merge temp_2(in=x)&DSin;
 by &IDvar;
 if x;
run;
 proc datasets library=work nodetails;
  delete temp temp_1 temp_2;
 quit;

 %exit: ;  /* finish the macro */
%mend;
