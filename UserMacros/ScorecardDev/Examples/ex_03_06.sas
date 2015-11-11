/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 3.6 */
/*******************************************************/

/*******************************************************/
/* Macro: Extremes
/*******************************************************/
%macro Extremes(DSin, VarX, IDVar, NSigmas, DSout);
/* Calculation of extreme values for a continuous variable 
   which are outside the range of NSigmas * STD from the 
   mean. */

/* First, extract XVar to a temp dataset, and keep the 
   observation number in the original dataset */
data temp;
 set &DSin;
 keep &VarX &IDVar;
run;

/* Calculate the mean and STD using proc univariate */
 proc univariate data=temp noprint;
 var &VarX;
 output out=temp_u   STD=VSTD   Mean=VMean;
run;

/* Extract upper and lower limits into macro variables */
data _null_;
 set temp_u;
 call symput('STD', VSTD);
 call symput('Mean', VMean);
run;
%let ULimit=%sysevalf(&Mean + &NSigmas * &STD);
%let LLimit=%sysevalf(&Mean - &NSigmas * &STD);

/* Extract extreme observations outside these limits */
data &DSout;
 set temp;
 if &VarX < &Llimit or &VarX > &ULimit;
run;

/* Clean workspace and finish the macro */
proc datasets library=work nodetails nolist ;
delete temp temp_u;
quit;

%mend;
/*******************************************************/
/* Generate a test dataset */
/*******************************************************/
data Test1;
 input ID x @@;
 datalines;
 1 1.45  2 0.73  3 2.43  4 3.89  5 3.86  
 6 3.96  7 2.41  8 2.29  9 2.23 10 2.19  
11 0.37 12 2.71 13 0.77 14 0.83 15 3.61 
16 1.71 17 1.06 18 3.23 19 0.68 20 3.15 
21 1.83 22 3.37 23 1.60 24 1.17 25 3.87  
26 2.36 27 1.84 28 1.64 29 3.97 30 2.23  
31 2.21 32 1.93 33 19.0 34 20.0 35 22.0
 ;
run;
/*******************************************************/
/* Call the macro */
/*******************************************************/
/* Identifying outliers using the mean and three 
   standard deviations */
%Extremes(Test1, x, ID, 3, Test1_out1);
/*******************************************************/
/* Print the cresults dataset to the output window */
/*******************************************************/
proc print data=test1_out1;
run;

/*******************************************************/
/* Clean the work space and reset the title*/
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

