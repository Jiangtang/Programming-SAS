/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 10.6  */
/*******************************************************/

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

/*******************************************************/
/* Macro PlotROC  */
/*******************************************************/
%macro PlotROC(DSROC);
goptions reset=global gunit=pct border cback=white
         colors=(black blue green red)
         ftitle=swissb ftext=swiss htitle=6 htext=4;


symbol1 color=red
        interpol=join
;
 
  proc gplot data=&DSROC;
   plot Sensitivity*Specificity1 / haxis=0 to 1 by 0.1
                    vaxis=0 to 1 by 0.1
                    hminor=3
                    vminor=1
 
                      vref=0.2 0.4 0.6 0.8 1.0
                    lvref=2
                    cvref=blue
                    caxis=blue
                    ctext=red;
run;
quit;
 
	goptions reset=all;
%mend;

/*******************************************************/
/* The folder where the dataset CC_WOE was stored  */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir"; 
/* Develop a model  */
%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;
proc logistic data=cc.CC_WOE OUTEST=cc.Model_Params;
model Status (event='1')=&VarList / selection =stepwise  sls=0.05 sle=0.05;
OUTPUT OUT=cc.Pred_Probs    P=Pred_Status;
run;

/* Apply the macro */
%let DSin=cc.Pred_Probs;
%let ProbVar=Pred_Status;
%let DVVar=Status;
%let DSROC=DSROC;
%let cStat=;


%ROC(&DSin, &ProbVar, &DVVar, &DSROC, cStat);
%put>>>>>>>>>>>>>>>  c-Stat=&cStat  <<<<<<<<<<<<<<<<<<<  ;

%PlotROC(&DSROC);


/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc catalog catalog=work.Gseg force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;


/*******************************************************/
/*  End of the example */
/*******************************************************/




