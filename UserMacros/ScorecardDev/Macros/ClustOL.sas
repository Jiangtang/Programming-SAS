/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

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

