/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro ROC  */
/*******************************************************/
%macro ROC(DSin, ProbVar, DVVar, DSROC, M_CStat);
/* 
Calculation of the ROC Chart from the input dataset DSIn
with a probability variable ProbVar, and the actual dependent
variable DVVar. Iplot=1 will plot the ROC in the output window,
and DSROC will store the resulting ROC data

The calculation is done with a precision of delta (eg. 0.1 or 0.01)
*/
%let delta=0.01;

/* Sort the dataset using the probability in descending order */

proc sort data=&DSin;
by descending &ProbVar;
run;

/* compute the total number of observations, total number of positives
   and negatives */

proc sql noprint;
 select sum(&DVVar) into :NP from &DSin;
 select count(*) into :N from &DSin;
quit;
%let NN=%eval(&N-&NP);



/* This is the main calculation loop for the elements of the 
  confusion matrix */

data temp1;
 set &DSin;
  by descending &ProbVar;

retain TP 0 FP 0 TN &NN FN &NP level 1.0;

  NN=&NN;
  NP=&NP;

  Sensitivity=TP/NP;
  Specificity1=FP/NN;

/* and their labels */
  label Sensitivity ='Sensitivity';
  label Specificity1 ='1-Specificity';

if &ProbVar<level then 
   do;
	  output;
	  level=level-&Delta;
   end;


  if &DVVar=1 then TP=TP+1;
  if &DVVar=0 then FP=FP+1;


  FN=&NP-TP;
  TN=&NN-FP;
keep TP FP TN FN NN NP Level Sensitivity Specificity1;	
run;

/* The last entry in the ROC Data */

data temp2;
	level=0;
	TP=&NP;
	FP=0;
	TN=0;
	FN=&NN;
	NP=&NP;
	NN=&NN;
	Sensitivity=1;
	Specificity1=1;
run;

/* Append the last row */
data &DSROC;
 set temp1 temp2;
 run;

 /* Calculate the area under the curve using the 
   trapezoidal integration approximation.
   C=0.5 * Sum_(k=1)^(n)[X_k - X_(k-1)]*[Y_k + Y_(k-1)]
*/
%local C;
data _null_; /* use the null dataset for the summation */
retain Xk 0 Xk1 0 Yk 0 Yk1 0 C 0;
set &DSROC;

Yk=Sensitivity;
Xk=Specificity1;

C=C+0.5*(Xk-Xk1)*(Yk+Yk1);

/* next iteration */
Xk1=Xk;
Yk1=Yk;

/* output the C-statistic */
call symput ('C', compress(c) );
run;

/* Store the value of C in the output macro parameter M_CStat */

%let &M_CStat=&C;

/* Clean workspace */
proc datasets library=work nodetails nolist;
delete temp1 temp2;
run;
quit;


%mend;
