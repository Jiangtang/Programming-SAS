/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 3.5 */
/*******************************************************/

/*******************************************************/
/* Generate the dataset Nominal2*/
/*******************************************************/
DATA Nominal2;
 input X $ Y $ @@;
 datalines;
A B B A B A C A B C C C C C B B A B 
A B C C C B B C C B C C B C C C C A
B B C C B C C B C C C C C B B C C B 
C C B C C A B C C C C C B B A B B C 
C B C C B C C A B C C C B B B A B C  
B B B B A A A A B A B C C A A B B C
A B C C C B B C C B C C B C C C C A
;
run;

/*******************************************************/
/* Cross tabulation of X by Y */
/*******************************************************/
PROC FREQ DATA=Nominal2;
TABLES X * Y;
run;


PROC FREQ DATA=Nominal2;
TABLES X * Y / NOPERCENT NOROW NOCOL;
run;

/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/


