/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 7.6 */
/*******************************************************/


/*******************************************************/
/* Generate the CreditCard dataset */
/*******************************************************/
/* folder where the examples code is stored */
%let dir =C:\ScorecardDev\Examples;   
%include "&dir\CC_Dataset.sas";


/* The likelihood ratio */
proc logistic data = CreditCard;
model status(event='1')=OtherCC;
run;

proc freq data=CreditCard;
table status*OtherCC / chisq;
run;



/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



