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
/* Macro PropAssign  */
/*******************************************************/
%macro PropAssign(DsAccepts, DSRejects, StatusVar, Factor, DSout, DSStats);
/* Proprtional assignement of Good/bad in DSRejects, and merging it to DSout 
   The assignement is done at random */

/* Calculate the rate of Bad in the accepts */
%let AccBr=;
 %CalcBadRate(&DSAccepts, &StatusVar, AccBr);

/* Calculate the number of bads we should have in the rejects to have the same bad rate 
   multiplied by Factor */
proc sql noprint;
	 select count(*) into :Nr from &DSRejects;
	 %let Nbr=%sysfunc(int(%sysevalf(&Nr * &Factor * &AccBr)));
run; quit;

/* shuffle the rejects at random */
data &DSRejects;
  set &DSRejects;
  _rand=ranuni(0);
run;
proc sort data=&DSRejects;
 by _rand;
run;

/* Assign the first Nbr to bad and the rest to goods in the rejects */
data &DSRejects;
	set &DSRejects;
	by _rand;
	if _N_ <= &Nbr then  &StatusVar=1;
	else &StatusVar=0;
	drop _rand;
run;

/* Find the bad rate in the rejects*/
%let RejBr=;
 %CalcBadRate(&DSRejects, &StatusVar, RejBr);

/* Merge the two datasets and find the bad rate in the combined dataset */

Data &DSout;
 set &DSRejects &DSAccepts;
run;

/* Find the bad rate for the whole new population  */
%let AllBr=;
%CalcBadRate(&DSout, &StatusVar, AllBr);


/* Generate the statistics dataset */
Data &DSStats;
length Statistic $30.;
Statistic ="Accepted bad rate"; Value=&AccBr;output;
Statistic ="Rejected bad rate"; Value=&RejBr;output;
Statistic ="Total    bad rate"; Value=&AllBr;output;
run;


%mend;

