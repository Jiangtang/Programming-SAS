/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro GiniStat*/
/*******************************************************/

%macro GiniStat(DSin, ProbVar, DVVar, DSLorenz, M_Gini);
/* Calculation of the Gini Statistic from the results of 
   a predictive model. DSin is the dataset with a dependent
   variable DVVar, and a predicted probability ProbVar. 
   The Gini coefficient is returnd in the parameter M_Gini. 
   DSLorenz contains the data of the Lorenz curve. 

*/

/* Sort the observations using the predicted Probability */
proc sort data=&DsIn;
by &ProbVar;
run;

/* Find the total number of responders */
proc sql noprint;
 select sum(&DVVar) into:NResp from &DSin;
 select count(*) into :NN from &DSin;
 quit;


 /* The base of calculation is 100  */

/* Get Count number of correct Responders per decile */
data &DSLorenz;
set &DsIn nobs=NN;
by &ProbVar;
retain tile 1  TotResp 0;
Tile_size=ceil(NN/100);

TotResp=TotResp+&DVVar;
TotRespPer=TotResp/&Nresp;

if _N_ = Tile*Tile_Size then 
  do;
  output;
   if Tile <100 then  
       do;
         Tile=Tile+1;
		 SumResp=0;
	   end;
  end;	
keep Tile TotRespPer;
run;
/* add the point of zero to the Lorenz data */
data temp;
 Tile=0;
 TotRespPer=0;
 run;
 Data &DSLorenz;
  set temp &DSLorenz;
run;


/* Scale the tile to represent percentage */
data &DSLorenz;
set &DSLorenz;
Tile=Tile/100;
label TotRespPer='Percent of Positives';
label Tile ='Percent of population';

run;

/* produce a simple plot of the Lorenze cruve the uniform response 
   if the IPlot is set to 1 */

/* Calculate the Gini coefficient from the approximation of the Lorenz
   curve into a sequence of straight line segments and using the 
   trapezoidal integration approximation.
   G=1 - Sum_(k=1)^(n)[X_k - X_(k-1)]*[Y_k + Y_(k-1)]
*/
data _null_; /* use the null dataset for the summation */
retain Xk 0 Xk1 0 Yk 0 Yk1 0 G 1;
set &DSLorenz;
Xk=tile;
Yk=TotRespPer;
G=G-(Xk-Xk1)*(Yk+Yk1);

/* next iteration */
Xk1=Xk;
Yk1=Yk;

/* output the Gini Coefficient */
call symput ('G', compress(G));
run;


/* store the Gini coefficient in the parameter M_Gini */

%let &M_Gini=&G;
/* Clean the workspace */
proc datasets library=work nodetails nolist;
 delete temp ;
run;
quit;

%mend;

