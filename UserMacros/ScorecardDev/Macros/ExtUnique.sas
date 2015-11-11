/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro ExtUnique */ 
/*******************************************************/
%macro ExtUnique(DSin, IDVar, DSout, DSDup);
/* extracting the records with unique IDVar. 
   DSout stores the data with unique values of IDvar
   DSRep stores the data with repeated values of IDvar
*/

/* extract the id's only to speed calculations */
data temp_allids;
 set &dsin;
 keep &idvar;
 run;
/* extract the unique Id's and their counts */
proc sql noprint;
 create table temp_uid as 
   select &idvar, count(&idvar) as _count from temp_allids group by &IDvar;
 run; quit;

/* extract the  ID's with count>1  */
 data temp_nid;
  set temp_Uid;
  if _count>1 then output;
  keep &Idvar;
  run;

/* sort the data using IDvar and output only one row per IDVar value */
  proc sort data=&dsin;
  by &IDvar;
  run;
  data &dsout;
   set &dsin;
   by &IDvar;
   if first.&Idvar;
  run;

/* extract the full records for the repeated ID's */
  proc sql noprint;
  create table &DSdup as 
    select b.* from temp_nid a, &dsin b where a.&IDvar=b.&Idvar;
  run; quit;

/* clean the workspace */
  proc datasets nodetails nolist;
   delete temp_allids temp_uid temp_nid;
  run;quit;
%mend;

