/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro: OddsRatio */
/*******************************************************/

%macro OddsRatio(DSin, XVar, DV, M_Odds, M_OddsU, M_OddsL);

proc freq data = &DSin noprint ;
tables &DV * &Xvar/measures;
output out=temp_odds measures;
run;

data _Null_;
 set temp_odds;
  call symput("&M_Odds"  , _RROR_);
  call symput("&M_OddsU" , U_RROR);
  call symput("&M_OddsL" , L_RROR);
run;

proc datasets library=work nolist;
delete temp_odds;
quit;
%mend;

