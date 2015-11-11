/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

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
