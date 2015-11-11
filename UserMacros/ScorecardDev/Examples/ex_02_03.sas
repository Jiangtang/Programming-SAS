/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 2.3 */
/*******************************************************/

/*******************************************************/
/* Generate the datasets LEFT and RIGHT */
/*******************************************************/
data LEFT;
 input ID Age Status $;
 datalines;
 1  30  Gold
 2  20  . 
 4  40  Gold
 5  50  Silver
 ;
run;

data RIGHT;
 input ID Balance Status $;
 datalines;
 2  3000  Gold
 4  4000  Silver
 ;
run;
/*******************************************************/
/* Do the merging */
/*******************************************************/

data BOTH;
 MERGE Left Right;
 BY ID;
run;

/*******************************************************/
/* Print the results to the output window */
/*******************************************************/
proc print data=BOTH;
run;

/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

