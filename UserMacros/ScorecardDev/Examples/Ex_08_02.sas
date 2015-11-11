/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 8.2 */
/*******************************************************/

/*******************************************************/
/* Generate the CreditCard dataset */
/*******************************************************/
/* Set the folder where the file is located */
%let dir=C:\scorecardDev\Examples;
/* the actual data definition */
%include "&dir\CC_Dataset.sas";

/* Explicit calculation of WOE for ResStatus */
Data CC1;
  set CreditCard;
        if ResStatus='Other' then RS_WOE=-0.200487;
   else if ResStatus='Home Owner' then RS_WOE=-0.019329;
   else RS_WOE=0.095564;
run;

/* Fit a logistic regression model with 
   RS_WOE as an indpendent variable */ 
proc logistic data=CC1;
 model Status(event='1')=RS_WOE;
 run;


/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/


