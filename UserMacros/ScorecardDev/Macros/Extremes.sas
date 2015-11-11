/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


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
