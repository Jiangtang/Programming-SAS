/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 10.3  */
/*******************************************************/

/*******************************************************/
/* Macro LiftChart  */
/*******************************************************/

%macro LiftChart(DSin, ProbVar, DVVar, DSLift);
/* Calculation of the Lift chart data from 
   the predicted probabilities DSin using 
   the PorbVar and DVVar. The lift chart data
   is stored in DSLift. We use 10 deciles. 
*/

/* Sort the observations using the predicted Probability in descending order*/
proc sort data=&DsIn;
	by descending &ProbVar;
run;

/* Find the total number of Positives */
%local P Ntot;
proc sql noprint;
	select sum(&DVVar) into:P from &DSin;
	select count(*) into: Ntot from &DSin;
quit;
%let N=%eval(&Ntot-&P); /* total Negative(Good) */

/* Get Count number of correct defaults per decile */
data &DSLift;
	set &DsIn nobs=nn ;
	by descending &ProbVar;
	retain Tile 1  SumP 0 TotP 0 SumN 0 TotN 0;
	Tile_size=ceil(NN/10);

	TilePer=Tile/10;

	label TilePer ='Percent of Population';
	label TileP='Percent of population';

	if &DVVar=1 then SumP=SumP+&DVVar;
	else SumN=SumN+1;

	PPer=SumP/&P;			/* Positive  %    */
	NPer=SumN/&N;           /* Negative % */

	label PPer='Percent of Positives';
	label NPer='Percent of Negatives';

	if _N_ = Tile*Tile_Size then 	do;
		output;
		if Tile <10 then  Tile=Tile+1;
	end;	

	keep TilePer PPer NPer;
run;

/* Add the zero value to the curve */
data temp;
 	TilePer=0;
	PPer=0;
	NPer=0;
run;
Data &DSLift;
  set temp &DSlift;
run;
%mend;

/*******************************************************/
/* Macro PlotLift  */
/*******************************************************/
%macro PlotLift(DSLift);
/* Plotting the lift report using gplot */

goptions reset=global gunit=pct border cback=white
         colors=(black blue green red)
         ftitle=swissb ftext=swiss htitle=6 htext=4;


symbol1 color=red
        interpol=join
        value=dot
        height=3;
 
  proc gplot data=&DSLift;
   plot PPer*TilePer / haxis=0 to 1 by 0.1
                    vaxis=0 to 1 by 0.1
                    hminor=3
                    vminor=1
 
                      vref=0.2 0.4 0.6 0.8 1.0
                    lvref=2
                    cvref=blue
                    caxis=blue
                    ctext=red;
run;
quit;
 
	goptions reset=all;
%mend;

/*******************************************************/
/* The folder where the dataset CC_WOE was stored  */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir"; 
/* Develop a model  */
%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;
proc logistic data=cc.CC_WOE OUTEST=cc.Model_Params;
model Status (event='1')=&VarList / selection =stepwise  sls=0.05 sle=0.05;
OUTPUT OUT=cc.Pred_Probs    P=Pred_Status;
run;


/* use the macro */
%let DSin=cc.Pred_Probs;
%let ProbVar=Pred_Status;
%let DVVar=Status;
%let DSLift=LiftChartDS;

/* Calculate the data of the Lift chart */
%LiftChart(&DSin, &ProbVar, &DVVar, &DSLift);

/* Display the content of the lift chart dataset */
proc print data=&DSLift;
run;


/* Plot the lift chart using PROC GPLOT */
%PlotLift(&DSLift);


/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc catalog catalog=work.Gseg force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/*  End of the example */
/*******************************************************/

