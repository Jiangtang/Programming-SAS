/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 10.1  */
/*******************************************************/

/*******************************************************/
/* Macro ConfMat  */
/*******************************************************/

%macro ConfMat(DSin, ProbVar, DVVar, Cutoff, DSCM);
/* 
Calculation of the Confusion matrix from the input dataset DSIn
with a probability variable ProbVar, and the actual dependent
variable DVVar. DSCM will store the resulting Confusion matrix

The calculation is done with a cutoff between 0,1.
*/

/* extract the actual DVVar, and the predicted outcome
   to a temp dataset to make the calculation faster, 
   calculate the predicted outcome */
data temp;
 set &DSin;
 if &ProbVar>=&Cutoff then _PDV=1;
  else _PDV=0;
 keep &DVVAR  _PDV;
run;

/* compute the total the elements of the confusion matrix
   using simple sql queries */
%local Ntotal P N TP TN FP FN;
proc sql noprint;
 select sum(&DVVar) into :P from temp;
 select count(*) into :Ntotal from temp;
 select sum(_PDV) into :TP from temp where &DVVar=1;
 select sum(_PDV) into :FP from temp where &DVVar=0; 
quit;
%let N=%eval(&Ntotal-&P);
%let FN=%eval(&P-&TP);
%let TN=%eval(&N-&FN);

/* Store the results in DSCM */
data &DSCM;
 TP=&TP;  TN=&TN;
 FP=&FP;  FN=&FN;
 P=&P;  N=&N;
 Ntotal=&Ntotal;
run;


/* Clean workspace */
proc datasets library=work nodetails nolist;
delete temp;
run; quit;

%mend;


/*******************************************************/
/* The folder where the dataset CC_WOE was stored  */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir"; 


/* Develop a logistic regression model and store 
   predicted probabilities in cc.Pred_probs dataset */

%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;
proc logistic data=cc.CC_WOE OUTEST=cc.Model_Params;
model Status (event='1')=&VarList / selection =stepwise  sls=0.05 sle=0.05;
OUTPUT OUT=cc.Pred_Probs    P=Pred_Status;
run;

%let DSin=cc.Pred_Probs; /* predicted probabilities*/
%let DVVar=status;
%let ProbVar=Pred_Status;
%let Cutoff=0.5;
%let DSCM=ConfusionMatrix;


%ConfMat(&DSin, &ProbVar, &DVVar, &Cutoff, &DSCM);

proc print data=ConfusionMatrix;
run;


/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;


/*******************************************************/
/*  End of the example */
/*******************************************************/

