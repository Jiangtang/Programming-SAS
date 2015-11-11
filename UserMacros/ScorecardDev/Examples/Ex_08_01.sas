/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 8.1 */
/*******************************************************/

/*******************************************************/
/* Generate the CreditCard dataset */
/*******************************************************/
/* Set the folder where the file is located */
%let dir=C:\scorecardDev\Examples;
/* the actual data definition */
%include "&dir\CC_Dataset.sas";

/* calculate the frequencies of the Good and bad 
   for the categories of the variable Res_Status 
*/

proc freq data=CreditCard;
 table ResStatus*Status
       /nocol norow nopercent;
 run;


/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/


