/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 6.1 */
/*******************************************************/


/*******************************************************/
/* Include file CC_Dataset.sas */
/*******************************************************/
/* folder where the examples code is stored */
%let dir =C:\ScorecardDev\Examples;   
%include "&dir\CC_Dataset.sas";


/* Frequency tables for ResStatus, EmpStatus */
proc freq data=CreditCard;
table ResStatus;
table EmpStatus;
run;

/* Univariate analysis of CustAge , AMBalance */
proc univariate data=CreditCard;
var CustAge AMBalance;
run;


/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



