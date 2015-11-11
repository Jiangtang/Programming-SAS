/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 2.5 */
/*******************************************************/

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


/*******************************************************/
/* Generate the dataset MV */ 
/*******************************************************/
data MV;
 input ID Balance @@;
 datalines;
42064 8893.82 46435 5302.52 84024 1144.16 37548 3700.20 10391  395.97
40256 7647.45 20203   58.52 99909 8707.89 60944 8938.71 45932 5825.43
32746 6548.73 21938 7450.70 56091 2324.60 28893 3464.69 35951 5524.62
 3674 4503.98 61037 2407.79  8086 5768.94 81213  459.39 78612 6085.13
55820 2067.38 47473 3521.52 82819 3307.46  6221 4858.88 32831 8860.29
43878 3874.51  5874 6798.57 99340 1697.78 42050 4867.75  2536 6334.61
94739 2005.07 35905 6804.87  2851 6273.75  7578  533.62 48098 7069.35
52901  456.08 23864  860.97 64778 8438.81 58245 9387.52 51082 5602.17
66682 5076.08  3674 4590.38 53487 8778.49  3674 9390.33 82449 5482.56
62041 1439.22 33264 3770.28 38577 6589.67 98569 3042.09 67448 7307.46
60051 6788.91 39358 5690.82 85152 6555.83  5591 1026.79 70896 6848.56
 3240 2183.38 80797 8765.75 47873 2625.25 35096 7046.24 39935 2915.85
39017 9107.60   893 4006.84 40468 7858.81 21367 4363.45 25123 6382.16
55242 8151.36 58246 6344.01 59326 2970.05 77544 8996.88  6611 8441.40
97358 5928.46 56194 4176.03 63351 6685.58 32189 7784.85 48861 4738.88
59040 3447.86 67016 3735.63 23820 2890.45 59786 8361.78 81207 8408.48
68893 1313.22 77544 7644.83 23545 3862.25 90345 1396.61 20750 5125.52
20401 5240.54 84301 5270.70  1959 9335.50 86391 2612.06 80097 5889.77
22477 3666.04 59900 4148.98 64133 5851.88 84746 5953.18 22477 5567.81
51644 1127.43 71871 4671.31 27656 1192.03  4953 1834.32 16204 8726.62
;
run;

/*******************************************************/
/* Call the macro */
/*******************************************************/

%let IDVar=ID;
%let DSin=MV;
%let DSout=MV_id;
%let DSdup=Duplicate_ID;

%ExtUnique(&DSin, &IDVar, &DSout, &DSDup);

/*******************************************************/
/* Print the results  */
/*******************************************************/


proc print data=Duplicate_ID;
run;


/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/*******************************************************/

