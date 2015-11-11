/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro CalcBadRate  */
/*******************************************************/
%macro CalcBadRate(DSin, StatusVar, M_BadRate);
/* Calculate the bad rate in a dataset */
	proc freq noprint data=&DSin;
	table &StatusVar/out=temp;
	run;

	data _Null_;
	set temp;
	if &StatusVar=1 then call symput("Bad",count);
	if &StatusVar=0 then call symput("Good",count);
	run;

	%let &M_BadRate = %sysevalf(&Bad/(&Bad+&Good));
/* clean workspace */
	proc datasets library=work nodetails nolist;
	 delete temp;
	 run;quit;

%mend;



/*******************************************************/
/* Macro SAugment  */
/*******************************************************/

%macro SAugment(DsAccepts, DSRejects, StatusVar, ScoreVar, Factor, DSout, DSStats);

/* Simple Augmentation */

/*  find the bad rate in the accepts (BadRate)*/
%let AccBr =;
%CalcBadRate(&DSAccepts, &StatusVar, AccBr);

/* apply a multiplier */

%let RejBr=%sysevalf(&Factor * &AccBr);

/* Assign all records below this rate to Bad (1) and records above this rate to Good (0) after
   sorting the rejects by score*/

proc sort data=&DSRejects;
 by &ScoreVar;
run;

Data &DSRejects;
 set &DSRejects nobs=_Nx;
  by &ScoreVar;
  if _N_/_Nx>= &RejBr then &StatusVar=0;
   else &StatusVar=1;

/* Merge the two datasets */

Data &DSout;
 set &DSRejects &DSAccepts;
run;

/* Find the bad rate for the whole new population  */
%let AllBr=;
%CalcBadRate(&DSout, &StatusVar, AllBr);

Data &DSStats;
length Statistic $30.;
Statistic ="Accepted bad rate"; Value=&AccBr;output;
Statistic ="Rejected bad rate"; Value=&RejBr;output;
Statistic ="Total    bad rate"; Value=&AllBr;output;
run;
%mend;


