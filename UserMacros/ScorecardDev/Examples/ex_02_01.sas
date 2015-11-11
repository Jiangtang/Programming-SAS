/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 2.1 */
/*******************************************************/


/*******************************************************/
/* The rollup macro */
/*******************************************************/
%macro TRollup( TDS, IDVar, TimeVar, 
               TypeVar, Nchars, Value, RDS);
/* Sort the transaction file using the ID, time, and type variables */
proc sort data=&TDS;
	by &IDVar &TimeVar &TypeVar;
run;

/* Accumulate the values over time to a temporary _TOT 
   variable  in a temporary dataset _Temp1 */
data _Temp1;
	retain _TOT 0;
	set &TDS;
	by &IDVar &TimeVar &TypeVar;
	if first.&TypeVar then _TOT=0;
	_TOT = _TOT + &Value;
	if last.&TypeVar  then output;
	drop &Value;
   run;

proc sort data=_Temp1;
	by &IDVar &TypeVar;
run;

/* Extract the categories of the TypeVar and store them in macro variables. 
   To do that, we use PROC FREQ to find all non-missing categories */

proc freq data =_Temp1 noprint;
	tables &TypeVar /out=_Types ;
run;

/* Convert the categories to macro variables  Cat_1, Cat_2, ... Cat_N */
data _null_;
 set _Types nobs=Ncount;
 if &typeVar ne '' then call symput('Cat_'||left(_n_), &TypeVar);
		if _n_=Ncount  then call symput('N', Ncount);
run;

/* Loop over these N categories and generate their rollup part */
%do i=1 %to &N;
proc transpose data =_Temp1 out=_R_&i  
     prefix=%substr(&&Cat_&i, 1, &Nchars)_;
	by &IDVar &TypeVar;
	ID &TimeVar ;
	var _TOT ;
	where &TypeVar="&&Cat_&i";
run;

%end;

/* Finally, assemble all these files by the ID variable */
data &RDS;
	 merge 
	 %do i=1 %to &N;
	 _R_&i 
	 %end ; ;
	 by &IDVar;
	 drop &TypeVar _Name_;
run;
/* clear workspace */
proc datasets library=work nodetails nolist;
	delete _Temp1 _Types 
		%do i=1 %to &N;
		    _R_&i  
		 %end; ;
	 ;
 run;
 quit;

%mend;

/*******************************************************/
/* Create the dataset for the example */
/*******************************************************/
Data Transactions;
informat TransDate Date9.;
format TransDate Date9.;
input CustomerID  TransDate  Amount  AccountType  $;
datalines;
1    11Jun2008      114.56      Savings  
1	 21Jun2008	 	56.78	 	Checking 
1	 07Jul2008	 	359.31	 	Savings 
1	 19Jul2008	 	89.56		Checking 
1	 03Aug2008	 	1000.00	 	Savings  
1	 17Aug2008	 	1200.00 	Checking 
2	 14Jun2008	 	122.51	 	Savings  
2	 27Jun2008	 	42.07		Checking 
2	 09Jul2008	 	146.30	 	Savings  
2	 09Jul2008	 	1254.48 	Checking 
2	 10Aug2008	 	400.00	 	Savings	  
2	 11Aug2008	 	500.00	 	Checking 
;
run;

/*******************************************************/
/* Calculate the transaction month */
/*******************************************************/
data Trans1;
set Transactions;
TMonth=MONTH(Transdate);
run;

/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=Trans1;         
%let IDVar=CustomerID;        
%let TimeVar=TMonth;      
%let TypeVar=AccountType; 
%let Nchars=1;            
%let ValueVar=Amount;     
%let DSout=RollupDS;      

%TRollup(&DSin, &IDVar,&TimeVar,&TypeVar,&Nchars, &ValueVar, &DSout);

/*******************************************************/
/* Print the results in the output window */
/*******************************************************/
proc print data=RollupDS;
run;

/*******************************************************/
/* Clean the work space from existing macros using 
   PROC CATALOG, and the datasets using PROC DATASETS */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  /* this will remove all stored macros */
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

