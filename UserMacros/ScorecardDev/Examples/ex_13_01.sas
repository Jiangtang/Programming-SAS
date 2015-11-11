/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 13.1  */
/*******************************************************/

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


/*******************************************************/
/* Generate Acc and Rej datasets  */
/*******************************************************/

data acc;
 do i=1 to 1000;
  score = int(ranuni(0)*1000);
  status=0;
if score <200 and ranuni(0)>0.8 then status=1; 
if score>=200 and score<400 and ranuni(0)>0.85 then status=1; 
if score>=400 and score<600 and ranuni(0)>0.90 then status=1; 
if score>=600 and score<800 and ranuni(0)>0.95 then status=1; 
if score>=800 and ranuni(0)>0.98 then status=1; 

   output ;
end;
run;


data rej;
 do i=1 to 1000;
  score = int(ranuni(0)*1000);
   output ;
end;
run;


/*******************************************************/
/* Call the macro  */
/*******************************************************/

%let DSAccepts=acc;
%let DSRejects=rej;
%let statusVar=status;
%let Factor =1.5;
%let DSout=AllData;
%let DSStats=stats;

%PropAssign(&DsAccepts, &DSRejects, &StatusVar, &Factor, &DSout, &DSStats);

proc print data=stats;
run;



/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/





