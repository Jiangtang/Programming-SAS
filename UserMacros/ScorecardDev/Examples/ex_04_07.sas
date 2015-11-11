/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.7 */
/*******************************************************/

/*******************************************************/
/* Generate a dataset */
/*******************************************************/
data CreditApp;
length ResidenceCat $20.;
length EmploymentCat $20.;
infile datalines delimiter=',';
input ResidenceCat $ EmploymentCat $ Wt ;
datalines;
House,Full time,6248
House,Part time,4215
House,Self employed,4521
House,Other,857
Apartment,Full time,4128
Apartment,Part time,3874
Apartment,Self employed,1125
Apartment,Other,741
Other,Full time,3145 
Other,Part time,1780
Other,Self employed,452
Other,Other,2569
;
run;

/*******************************************************/
/* Calculate the Pearson Chi-squared statistic using
   PROC FREQ */
/*******************************************************/
proc freq data = CreditApp order=data;
tables ResidenceCat * EmploymentCat/CHISQ;
weight wt;
run;
 
/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

