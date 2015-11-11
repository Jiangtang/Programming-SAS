/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 3.7 */
/*******************************************************/

/*******************************************************/
/* Macro: ClustOL */
/*******************************************************/
%macro ClustOL(DSin, VarList, NClust, Pmin, DSout);
/* Infering outliers using k-means clustering */

/* Build a cluster model to identify outliers */
proc fastclus data=&DSin MaxC=&NClust maxiter=100 
cluster=_ClusterIndex_ out=Temp_clust noprint;
var &VarList;
run;

/* Analyze temp_clust and find the cluster indices with
   frequency percentage less than Pmin */
proc freq data=temp_clust noprint;
  tables _ClusterIndex_ / out=temp_freqs;
run;

data temp_low;
 set temp_freqs;
 if PERCENT <= &Pmin*100;
 _Outlier_=1;
 keep _ClusterIndex_ _Outlier_;
run;

/* Match-merge temp_low with the clustering output and drop the cluster index */
proc sort data=temp_clust;
by _ClusterIndex_;
run;
proc sort data=temp_low;
by _ClusterIndex_;
run;

data &DSout;
 merge temp_clust temp_Low;
 by _ClusterIndex_;
 drop _ClusterIndex_ DISTANCE;
 if _outlier_ = . then _Outlier_=0;
run;

/* Cleanup and finish the macro */
proc datasets library=work;
delete temp_clust temp_freqs temp_low;
quit;

%mend;


/*******************************************************/
/* Generate a dataset */
/*******************************************************/
data TestOL ; 
/* Create 1000 observations from three distributions */

do ObsNo=1 to 1000;

   /* Generate four varibles x1-X4*/ 
   x1=rannor(0); x2=rannor(0);  
   x3=rannor(0); X4=rannor(0);

/* In the first 50 observations, inflate x1, x2 variables 100 times */
  if ObsNo <= 50 then do;
    x1=100 * rannor(0);  
    x2=100 * rannor(0);  
  end; 

 /* Create a dependent variable y */
  y= 5 + 6*x1 + 7*x2 + 8*x3 +  .4 * X4;

 /* The last 50 observations y=100 */ 
 if ObsNo > 950 then y=100; 

 output; 
end; 
run; 


/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=TestOL;
%let VarList=x1 x2 x3 y;
%let NClust=50;
%let Pmin=0.05;
%let DSout=OL_CLusters;
%ClustOL(&DSin, &VarList, &NClust, &Pmin, &DSout);

/*******************************************************/
/* Sort the data by ObsNo to restore original order */
/*******************************************************/

proc sort data=&DSout;
by ObsNo;
run;


data outliers;
 set OL_clusters;
 if _Outlier_;
 run;

proc print data=outliers;
run;


/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/






