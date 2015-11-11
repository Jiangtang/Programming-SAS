/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.8 */
/*******************************************************/

/*******************************************************/
/* Generate a dataset */
/*******************************************************/
data CreditCards ;
input Region $ Status $ Wt;
datalines;
Europe Bad   3425
US     Bad   3719
Europe Good 71254
US     Good 69845
;
run;

/*******************************************************/
/* Calculate the odds ratio using PROC FREQ */
/*******************************************************/
proc Freq Data=CreditCards order=data;
table Region * Status/measures chisq;
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
