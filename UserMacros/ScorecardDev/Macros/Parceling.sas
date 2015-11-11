/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro Parceling  */
/*******************************************************/
%macro Parceling(DsAccepts, DSRejects, StatusVar, ScoreVar, Method, DSIDVar, 
                 DSSCRanges, Factor, DSout, DSStats);

/*  Augmentation by Parceling */

/* sort the ranges using the lower limit */
proc sort data=&DSSCRanges;
by LowerLimit;
run;

/* map the lower limits and upper limits in the DSSCRanges into macro variables */
data _NULL_;
 set &DSSCRanges;
call symput('L_'||compress(_N_), LowerLimit);
call symput('U_'||compress(_N_), UpperLimit);
  call symput('N', compress(_N_));
run;

/* find the number of Goods/Bads in the Accepts and the bad rates in each range 
   and the size of each of the ranges in the Rejects */
proc sql noprint;

%do i=1 %to &N;

%if &i=1 %then %do;
  select count(&StatusVar) into: Good from &DSAccepts where &StatusVar=0 and &ScoreVar<&U_1;
  select count(&StatusVar) into: Bad from &DSAccepts where &StatusVar=1 and &ScoreVar<&U_1;
  select count(*) into: NR from &DSRejects where &ScoreVar <&U_1;
  
               %end;
%else %if &i=&N %then %do;
  select count(&StatusVar) into: Good from &DSAccepts where &StatusVar=0 and &ScoreVar>=&&L_&N;
  select count(&StatusVar) into: Bad  from &DSAccepts where &StatusVar=1 and &ScoreVar>=&&L_&N;
  select count(*) into: NR from &DSRejects where &ScoreVar >=&&L_&N;
               %end;
%else %do;
  select count(&StatusVar) into: Good from &DSAccepts where &StatusVar=0 and &ScoreVar<&&U_&i and &ScoreVar>=&&L_&i;
  select count(&StatusVar) into: Bad  from &DSAccepts where &StatusVar=1 and &ScoreVar<&&U_&i and &ScoreVar>=&&L_&i;
  select count(*) into: NR from &DSRejects where &ScoreVar<&&U_&i and &ScoreVar>=&&L_&i;;
     %end;


  %let BR=%sysevalf(&Bad / (&Bad + &Good));
  %let NB_&i = %sysevalf((&BR * &NR * &Factor),floor); 
  %if &&NB_&i > &NR %then %let NB_&i=&NR; 

%put *****************************;
%put i=&i Bad Rate=&BR NR=&NR  NB=&&NB_&i;
%put *****************************;

%end;
quit;

/* Sort both the accepts and rejects by the score variable */
proc sort data=&DSRejects;
 by &ScoreVar;
run;
proc sort data=&DSAccepts;
 by &ScoreVar;
run;

/* Add the range id to the rejects dataset */
data temp;
 set &DSRejects;
 by &ScoreVar; 

 if &ScoreVar < &U_1 then _RangeID=1;
 if &ScoreVar >=&&L_&N then _RangeID=&N;
 %do i=2 %to %eval(&N-1);
 if &ScoreVar >= &&L_&i and &ScoreVar < &&U_&i then _RangeID=&i;
 %end;
run;

/* divide the Rejects into N datasets using _RangeID and 
   sort them */ 

%do i=1 %to &N;
/*********************** parcel i */
data temp_&i;
 set temp;
  by &ScoreVar;
  if _RangeID=&i then output;
  drop _RangeID;
Run;

/* work on each range and assign the bads */
 %if &Method=1 %then %do; /*score order */
proc sort data=temp_&i;
  by &ScoreVar;
run;
 %end;
 %else %do; /* Random order */
data temp_&i;
 set temp_&i;
  _rand=ranuni(0);
run;
proc sort data=temp_&i;
by _Rand;
run;
data temp_&i;
 set temp_&i;
 drop _Rand;
 run;
%end;
/* both cases */

data temp_&i;
 set temp_&i;
  %if &Method=1 %then by &ScoreVar;;
	  if _N_<=&&NB_&i then &StatusVar=1; /* inferred bad */
	  else &StatusVar=0; /* inferred good */
run;


/********************end of parcel i */
%end;

/* now collect all the parcels into one dataset with the accepts */
data &DSout;
 set &DSAccepts (in=acc)
  %do i=1 %to &N;    temp_&i   %end; ; 
  if acc then &DSIDVar='Accepted';
  else &DSIDVar='Declined';
run;


/* Calcualte the stats for the Good/Bad for the Accepts, Rejects and ALL */

/* generate statistics */
%local bad good AccBr RejBr AllBr;
proc sql noprint;
  select count (&StatusVar) into :Bad from &DSOut where &StatusVar=1 and &DSIDVar='Accepted';
  select count (&StatusVar) into :Good from &DSOut where &StatusVar=0 and &DSIDVar='Accepted';
	%let AccBr = %sysevalf(&Bad/(&Bad+&Good));

/* Bad rate for accepts */
  select count (&StatusVar) into :Bad from &DSOUt where &StatusVar=1 and &DSIDVar='Declined';
  select count (&StatusVar) into :Good from &DSOut where &StatusVar=0 and &DSIDVar='Declined';
	%let RejBr = %sysevalf(&Bad/(&Bad+&Good));

/* Bad rate for the mix*/

  select count (&StatusVar) into :Bad from &DSout where &StatusVar=1;
  select count (&StatusVar) into :Good from &DSOut where &StatusVar=0;
	%let AllBr = %sysevalf(&Bad/(&Bad+&Good));

quit;
%put &Bad &Good &accbr &rejbr &allbr;

Data &DSStats;
length Statistic $30.;
Statistic ="Accepts  bad rate"; Value=&AccBr; output;
Statistic ="Rejects Bad rate";  Value=&RejBr; output;
Statistic ="Total    bad rate"; Value=&AllBr; output;
run;

/* Clean the workspace */
proc datasets library=work nodetails nolist;
delete temp %do i=1 %to &N; temp_&i %end; ;
run; quit;

%mend;


