/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 7.4 */
/*******************************************************/


/*******************************************************/
/* Generate the CreditCard dataset */
/*******************************************************/
/* folder where the examples code is stored */
%let dir =C:\ScorecardDev\Examples;   
%include "&dir\CC_Dataset.sas";


/* A Model with R-Square calculation */
proc logistic data = CreditCard;
model status(event='1')=
           CustAge TmAtAddress CustIncome TmWBank
           / rsquare;
run;


/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



