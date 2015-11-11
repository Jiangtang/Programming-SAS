/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 3.4 */
/*******************************************************/

/*******************************************************/
/* Generate the Nominal1 dataset */
/*******************************************************/
DATA Nominal1;
 input X $ @@;
 datalines;
A B B A B A C A B C C D D C E E A B 
A B C C D E E D D E C C E C D D C A
B B B B A A A A F A E C D A A B B D
;
run;

/*******************************************************/
/* Invoke PROC FREQ on the variable X */
/*******************************************************/
PROC FREQ DATA=Nominal1;
TABLES x;
run;

/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



