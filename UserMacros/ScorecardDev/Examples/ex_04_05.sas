/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.5 */
/*******************************************************/


/*******************************************************/
/* Generate the Homes dataset */
/*******************************************************/
data Homes;
input Income Value1 Value2 @@;
datalines;
20 120 120   22 165 165   25 203 203
25 205 205   31 192 192   33 220 220  
36 129 129   36 269 269   37 136 136
40 364 364   48 194 759   52 285 285
55 279 279   59 320 320   64 370 370
81 448 448   83 514 514   98 419 419
99 613 613   99 526 667
;
run;

/*******************************************************/
/* Calculate both correlation coefficients using
   PROC FREQ */
/*******************************************************/
proc corr data=Homes Pearson Spearman OutP=PCorr OutS=SCorr;
var  Value1 Value2 Income;
run;

/*******************************************************/
/* Print the correlation datasets */ 
/*******************************************************/
proc print data=PCorr;
run;

proc print data=SCorr;
run;


/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

