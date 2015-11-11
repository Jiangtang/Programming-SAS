/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 2.2 */
/*******************************************************/

/*******************************************************/
/* Macro VarMode */
/*******************************************************/
%macro VarMode(TransDS, IDVar, XVar, OutDS);
/* Calculation of the mode of a variable Xvar from a transaction 
   dataset using the classic implementation in ANSI SQL */
proc sql noprint;
	create table &OutDS as 
		SELECT &IDVar , MIN( &XVar ) AS mode
		FROM (
               SELECT &IDVar,  &XVar
               FROM &TransDS p1
               GROUP BY &IDVar, &XVar
               HAVING COUNT( * ) = 
                     (SELECT MAX( CNT )
                      FROM (SELECT COUNT( * ) AS CNT
                            FROM &TransDS p2
                            WHERE p2.&IDVar= p1.&IDVar
                            GROUP BY p2.&XVar
                            ) AS p3
                      )
              ) AS p
        GROUP BY p.&IDVar;
quit;
%mend;


/*******************************************************/
/* Generate the dataset */
/*******************************************************/

data Trans;
 informat TransDate date9.;
 format TransDate Date9.;
 informat PayType $10.;

 input CustID TransDate  PayType $ @@; 
 datalines;
 1 16Jan2008 Check    1 07Feb2008 Check
 1 09Mar2008 Check    1 18Apr2008 Check
 1 19May2008 Transfer 1 22Jun2008 Transfer
 1 08Jul2008 Check    1 23Aug2008 Transfer
 1 14Sep2008 Transfer 1 08Oct2008 Check 
 2 15Jan2008 Transfer 2 12Feb2008 Check
 2 12Mar2008 Transfer 2 19Apr2008 Check
 2 22May2008 Transfer 2 28Jun2008 Transfer
 2 26Jul2008 Transfer 2 25Aug2008 Transfer
 2 20Sep2008 Check    2 21Oct2008 Check
 3 04Jan2008 Check    3 17Feb2008 Check
 3 19Mar2008 Check    3 19Apr2008 Check
 3 25May2008 Check    3 23Jun2008 Transfer
 3 21Jul2008 Transfer 3 15Aug2008 Transfer
 3 11Sep2008 Check    3 19Oct2008 Transfer
;
run;

/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=Trans;
%let IDVar=CustID;
%let XVar=PayType;
%let DSout=ModePayType;

%VarMode(&DSin,  &IDVar, &XVar, &DSout);

/*******************************************************/
/* Print the results to the output window */
/*******************************************************/
proc print data=ModePayType;
run;

/*******************************************************/
/* Clean the work space from existing macros using 
   PROC CATALOG , and the datasets using PROC DATASETS */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  /* this will remove all stored macros */
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

