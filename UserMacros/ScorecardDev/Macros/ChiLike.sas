/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro : ChiLike */
/*******************************************************/
%macro ChiLike(DSin, XVar, DV, M_chi, M_Chipval, M_Like, M_LikePval);

proc freq data = &DSin noprint;
tables &DV * &Xvar/CHISQ ;
output out=temp_chiL chisq;
run;

data _Null_;
 set temp_ChiL;
  call symput("&M_Chi"     , _PCHI_);
  call symput("&M_ChiPval" , P_PCHI);
  call symput("&M_Like"    , _LRCHI_);
  call symput("&M_LikePval", P_PCHI);
run;
proc datasets nolist library=work;
delete temp_chiL;
run; quit;
%mend;
