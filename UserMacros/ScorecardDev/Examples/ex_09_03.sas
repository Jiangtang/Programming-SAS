/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 9.3  */
/*******************************************************/

/*******************************************************/
/* The folder where the dataset CC_WOE was stored  */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir"; 

/* Forcing the selection to follow the specified 
   order using the option SEQ */
%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;
proc logistic data=cc.CC_WOE;
 model Status (event='1')=&VarList / 
           selection =stepwise  sls=0.05 sle=0.05 SEQ;
run;

/*******************************************************/
/* End of the example. */
/*******************************************************/






