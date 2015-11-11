/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.10 */
/*******************************************************/

/* Generate the data */
data CreditCards ;
input Region  Status  Wt;
 datalines;
  0 1   3425
  1 1   3719
  0 0 71254
  1 0 69845
;
run;

/*******************************************************/
/* Invoke logistic regression */
/*******************************************************/
proc logistic Data=CreditCards;
  model Status (event='0')=Region;
  WEIGHT Wt;
run;

/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/
