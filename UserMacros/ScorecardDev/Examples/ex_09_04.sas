/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 9.4  */
/*******************************************************/

/*******************************************************/
/* The folder where the dataset CC_WOE was stored  */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir"; 

/* Storing the results of the model in a dataset */
%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;

proc logistic data=cc.CC_WOE
              OUTEST=Model_Params 
              ALPHA=0.05;
model Status (event='1')=&VarList / 
           selection =stepwise  sls=0.05 sle=0.05;

OUTPUT OUT=Pred_Probs
       P=Pred_Status
	   LOWER=Pi_L
	   UPPER=Pi_U
	   ;
run;

option linesize=min;

proc print data=Model_params;
run;

/*******************************************************/
/* End of the example. */
/*******************************************************/
