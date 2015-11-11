/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 10.4  */
/*******************************************************/

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


/*******************************************************/
/* Macro PlotLorenz*/
/*******************************************************/
%macro PlotLorenz(DSLorenz);
/* Plotting the lift report using gplot */

goptions reset=global gunit=pct border cback=white
         colors=(black blue green red)
         ftitle=swissb ftext=swiss htitle=6 htext=4;


symbol1 color=red
        interpol=join
        value=dot
        height=1;
 
  proc gplot data=&DSLorenz;
   plot TotRespPer*Tile / haxis=0 to 1 by 0.2
                    vaxis=0 to 1 by 0.2
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

/* Calculate the Gini statistic */
%let DSin=cc.Pred_Probs;
%let ProbVar=Pred_Status;
%let DVVar=Status;
%let DSLorenz=LorenzDS;
%let Gini=;

%GiniStat(&DSin, &ProbVar, &DVVar, &DSLorenz, Gini);
%put>>>>>>>>>>>>>>>   Gini=&Gini  <<<<<<<<<<<<<<<<<<<  ;


/* Plor the Lorenz curve */
%PlotLorenz(&DSLorenz);



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




