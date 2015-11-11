/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


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
