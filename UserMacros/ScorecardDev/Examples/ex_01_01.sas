/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 1.1 */
/*******************************************************/

/*******************************************************/
/* The test macro */
/*******************************************************/
%macro test( VarX, M_VarY);

/* VarX is a normal macro variable, so it is passed by
   value. */
/* Modify the value of VarX */
%let VarX=Customer_Income; 
%put ********** Inside the macro test **************;
%put VarX=&VarX;

/* M_VarY is initialized as null and will be changed 
   here to return the value "Scorecard".  */
%put Initial value of M_VarY=&M_VarY;

%let &M_VarY=Scorecard; 

%put ********* Leaving macro test ******************;
%mend;

/* Using the macro test */

/* switch off the code echo */
option nosource;

%let VarX=Customer_Age; /* value of varX */
%let VarY=;    /* initializing VarY to a null string */

/* display the values before calling the macro */
%put ********  before calling the macro ************;
%put VarX=&VarX;
%put VarY=&VarY;

%test(&VarX, VarY);   /* Note that VarY is used without & */

/* display the values after executing the macro */
%put ********  after executing the macro ***********;
%put VarX=&VarX;
%put VarY=&VarY;

/* Reset the source listing */
option source; 

/* Clean the workspace */
proc catalog catalog=work.sasmacr force kill;  
run; quit;

