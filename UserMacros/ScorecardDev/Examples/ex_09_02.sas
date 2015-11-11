/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 9.2  */
/*******************************************************/

/*******************************************************/
/* The folder where the dataset CC_WOE was stored  */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir"; 

/* Store the variable names in a macro varible VarList */

%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;

/* Force the first three variables in order */
proc logistic data=cc.CC_WOE;
 model Status (event='1')=&VarList / 
           selection =stepwise sls=0.05 sle=0.05 INCLUDE=3;
run;


/*******************************************************/
/* End of the example. */
/*******************************************************/






