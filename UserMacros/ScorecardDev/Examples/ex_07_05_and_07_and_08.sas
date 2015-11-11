/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 7.5, 7.7, 7.8 */
/*******************************************************/


/*******************************************************/
/* Generate the CreditCard dataset */
/*******************************************************/
/* folder where the examples code is stored */
%let dir =C:\ScorecardDev\Examples;   
%include "&dir\CC_Dataset.sas";


/* The Hosmer-Lemeshow lack of fit test */
proc logistic data = CreditCard;
model status(event='1')=
           CustAge TmAtAddress CustIncome TmWBank
           / LACTFIT(2);
run;


/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



