/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 2.4 */
/*******************************************************/

/*******************************************************/
/* Generate the datasets TOP and BOTTOM */ 
/*******************************************************/
data TOP;
 input ID Age Status $;
 datalines;
 1  30  Gold
 2  20  . 
 3  30  Silver
 4  40  Gold
 5  50  Silver
 ;
run;
data BOTTOM;
input ID Balance Status $ ;
 datalines;
 6  6000  Gold
 7  7000  Silver
 ;
run;

/* use the data step SET command to concatenate TOP and BOTTOM */

data BOTH;
 set TOP BOTTOM;
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
