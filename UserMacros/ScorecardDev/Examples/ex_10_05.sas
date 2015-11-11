/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 10.5  */
/*******************************************************/

/*******************************************************/
/* Macro KSStat  */
/*******************************************************/
%macro KSStat(DSin, ProbVar, DVVar, DSKS, M_KS);
/* Calculation of the KS Statistic from the results of 
   a predictive model. DSin is the dataset with a dependent
   variable DVVar, and a predicted probability ProbVar. 
   The KS statistic is returnd in the parameter M_KS. 
   DSKS contains the data of the Lorenz curve for good and bad
   as well as the KS Curve. 

*/

/* Sort the observations using the predicted Probability */
proc sort data=&DsIn;
by &ProbVar;
run;

/* Find the total number of Positives and Negatives */
proc sql noprint;
 select sum(&DVVar) into:P from &DSin;
 select count(*) into :Ntot from &DSin;
 quit;
 %let N=%eval(&Ntot-&P); /* Number of negative */


 /* The base of calculation is 100 tiles */

/* Count number of positive and negatives per tile, their proportions and 
    cumulative proportions decile */
data &DSKS;
set &DsIn nobs=NN;
by &ProbVar;
retain tile 1  totP  0 totN 0;
Tile_size=ceil(NN/100);

if &DVVar=1 then totP=totP+&DVVar;
else totN=totN+1;

Pper=totP/&P;
Nper=totN/&N;

/* end of tile? */
if _N_ = Tile*Tile_Size then 
  do;
  output;
   if Tile <100 then  
       do;
         Tile=Tile+1;
		 SumResp=0;
	   end;
  end;	
keep Tile Pper Nper;
run;

/* add the point of zero  */
data temp;
	 Tile=0;
	 Pper=0;
	 NPer=0;
run;

Data &DSKS;
  set temp &DSKS;
run;

 
/* Scale the tile to represent percentage and add labels*/
data &DSKS;
	set &DSKS;
	Tile=Tile/100;
	label Pper='Percent of Positives';
	label NPer ='Percent of Negatives';
	label Tile ='Percent of population';

	/* calculate the KS Curve */
	KS=NPer-PPer;
run;

/* calculate the KS statistic */

proc sql noprint;
 select max(KS) into :&M_KS from &DSKS;
run; quit;

/* Clean the workspace */
proc datasets library=work nodetails nolist;
 delete temp ;
run;
quit;

%mend;


/*******************************************************/
/* Macro PlotKS */
/*******************************************************/
%macro PlotKS(DSKS);
/* Plotting the KS curve using gplot using simple options */

 symbol1 value=dot color=red   interpol=join  height=1;
 legend1 position=top;
 symbol2 value=dot color=blue  interpol=join  height=1;
 symbol3 value=dot color=green interpol=join  height=1;

proc gplot data=&DSKS;

  plot( NPer PPer KS)*Tile / overlay legend=legend1;
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

/* Apply the macro */

%let DSin=cc.Pred_Probs;
%let ProbVar=Pred_Status;
%let DVVar=Status;
%let DSKS=DSKS;
%let KS=;

%KSStat(&DSin, &ProbVar, &DVVar, &DSKS, KS);
%put>>>>>>>>>>>>>>>  KS-Stat=&KS  <<<<<<<<<<<<<<<<<<<  ;

%PlotKS(&DSKS);

/* Display the content of the KS dataset */
proc print data=&DSKS;
run;


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




