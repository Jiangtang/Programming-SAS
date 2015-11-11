/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/



/* The macros:
   These are FIVE macros used to find the rules to reduce
   the cardinality of a nominal variable with string 
   values. They are:
   GValue, CalcMErit, BestSplit, CandSplits, ReduceCats.
   Only ReduceCats is to be called to obain the mappings
   for the reduction of cardinality. 

   Applying the maps requires the final macro: ApplyMap1. */

/*******************************************************/
/* Macro GValue */
/*******************************************************/
%macro GValue(BinDS, Method, M_Value);
/* Calculation of the value of current split  */

/* Extract the frequency table values */
proc sql noprint;
  /* Count the number of obs and categories of X and Y */
   %local i j R N; /* C=2, R=Bmax+1 */
   select max(bin) into : R from &BinDS;
   select sum(total) into : N from &BinDS; 

   /* extract n_i_j , Ni_star*/
   %do i=1 %to &R; 
      %local N_&i._1 N_&i._2 N_&i._s N_s_1 N_s_2;
   Select sum(Ni1) into :N_&i._1 from &BinDS where Bin =&i ;
   Select sum(Ni2) into :N_&i._2 from &BinDS where Bin =&i ;
   Select sum(Total) into :N_&i._s from &BinDS where Bin =&i ;
   Select sum(Ni1) into :N_s_1 from &BinDS ;
   Select sum(Ni2) into :N_s_2 from &BinDS ;
%end;
quit;

%if (&method=1) %then %do; /* Gini */

	/* substitute in the equations for Gi, G */
	  %do i=1 %to &r;
	     %local G_&i;
	     %let G_&i=0;
	       %do j=1 %to 2;
	          %let G_&i = %sysevalf(&&G_&i + &&N_&i._&j * &&N_&i._&j);
	       %end;
	      %let G_&i = %sysevalf(1-&&G_&i/(&&N_&i._s * &&N_&i._s));
	   %end;

	   %local G; 
	    %let G=0;
	    %do j=1 %to 2;
	       %let G=%sysevalf(&G + &&N_s_&j * &&N_s_&j);
	    %end;
	    %let G=%sysevalf(1 - &G / (&N * &N));

	/* finally, the Gini ratio Gr */
	%local Gr;
	%let Gr=0; 
	 %do i=1 %to &r;
	   %let Gr=%sysevalf(&Gr+ &&N_&i._s * &&G_&i / &N);
	 %end;

	%let &M_Value=%sysevalf(1 - &Gr/&G); 
    %return;
					%end;

%if (&Method=2) %then %do; /* Entropy */

/* Check on zero counts or missings */
   %do i=1 %to &R; 
    %do j=1 %to 2;
	      %local N_&i._&j;
	      %if (&&N_&i._&j=.) or (&&N_&i._&j=0) %then %do ; /* return a missing value */ 
	         %let &M_Value=.;
	      %return; 
		                          %end;
     %end;
   %end;
  
/* substitute in the equations for Ei, E */
  %do i=1 %to &r;
     %local E_&i;
     %let E_&i=0;
       %do j=1 %to 2;
          %let E_&i = %sysevalf(&&E_&i - (&&N_&i._&j/&&N_&i._s)*%sysfunc(log(%sysevalf(&&N_&i._&j/&&N_&i._s))) );
       %end;
      %let E_&i = %sysevalf(&&E_&i/%sysfunc(log(2)));
   %end;
   %local E; 
    %let E=0;
    %do j=1 %to 2;
       %let E=%sysevalf(&E - (&&N_s_&j/&N)*%sysfunc(log(&&N_s_&j/&N)) );
    %end;
    %let E=%sysevalf(&E / %sysfunc(log(2)));

/* finally, the Entropy ratio Er */
	%local Er;
	%let Er=0; 
	 %do i=1 %to &r;
	   %let Er=%sysevalf(&Er+ &&N_&i._s * &&E_&i / &N);
	 %end;
	%let &M_Value=%sysevalf(1 - &Er/&E); 
	 %return;
					   %end;

%if (&Method=3)%then %do; /* The Pearson's X2 statistic */
 %local X2;
	%let N=%eval(&n_s_1+&n_s_2);
	%let X2=0;
	%do i=1 %to &r;
	  %do j=1 %to 2;
		%local m_&i._&j;
		%let m_&i._&j=%sysevalf(&&n_&i._s * &&n_s_&j/&N);
		%let X2=%sysevalf(&X2 + (&&n_&i._&j-&&m_&i._&j)*(&&n_&i._&j-&&m_&i._&j)/&&m_&i._&j  );  
	  %end;
	%end;
	%let &M_value=&X2;
	%return;

%end; /* end of X2 */

%if (&Method=4) %then %do; /* Information value */
/* substitute in the equation for IV */
     %local IV;
     %let IV=0;
   /* first, check on the values of the N#s */
	%do i=1 %to &r;
	   	      %if (&&N_&i._1=.) or (&&N_&i._1=0) or 
                  (&&N_&i._2=.) or (&&N_&i._2=0) or
                  (&N_s_1=) or (&N_s_1=0)    or  
				  (&N_s_2=) or (&N_s_2=0)     
				%then %do ; /* return a missing value */ 
	               %let &M_Value=.;
	                %return; 
		              %end;
	    %end;
       %do i=1 %to &r;
          %let IV = %sysevalf(&IV + (&&N_&i._1/&N_s_1 - &&N_&i._2/&N_s_2)*%sysfunc(log(%sysevalf(&&N_&i._1*&N_s_2/(&&N_&i._2*&N_s_1)))) );
       %end;
    %let &M_Value=&IV; 
						%end;
%mend;

/*******************************************************/
/* Macro CalcMerit */
/*******************************************************/
%macro CalcMerit(BinDS, ix, method, M_Value);
/* claculation of the merit function for the current location 
   on a candidate bin. All nodes on or above the value
   are grouped together, and those larger up to the end 
   of the bin are together */

/*   Use SQL to find the frquencies of the contingency table  */
%local n_11 n_12 n_21 n_22 n_1s n_2s n_s1 n_s2; 
proc sql noprint;
 select sum(Ni1) into :n_11 from &BinDS where i<=&ix;
 select sum(Ni1) into :n_21 from &BinDS where i> &ix;

 select sum(Ni2) into : n_12 from &BinDS where i<=&ix ;
 select sum(Ni2) into : n_22 from &binDS where i> &ix ;

 select sum(total) into :n_1s from &BinDS where i<=&ix ;
 select sum(total) into :n_2s from &BinDS where i> &ix ;

 select sum(Ni1) into :n_s1 from &BinDS;
 select sum(Ni2) into :n_s2 from &BinDS;
quit;

/* Calcualte the merit functino according to its type */
/* The case of Gini */
%if (&method=1) %then %do;
    %local N G1 G2 G Gr;
	%let N=%eval(&n_1s+&n_2s);
	%let G1=%sysevalf(1-(&n_11*&n_11+&n_12*&n_12)/(&n_1s*&n_1s));
	%let G2=%sysevalf(1-(&n_21*&n_21+&n_22*&n_22)/(&n_2s*&n_2s));
	%let G =%sysevalf(1-(&n_s1*&n_s1+&n_s2*&n_s2)/(&N*&N));
	%let GR=%sysevalf(1-(&n_1s*&G1+&n_2s*&G2)/(&N*&G));
	%let &M_value=&Gr;
	%return;
				%end;
/* The case of Entropy */
%if (&method=2) %then %do;
   %local N E1 E2 E Er;
	%let N=%eval(&n_1s+&n_2s);
	%let E1=%sysevalf(-( (&n_11/&n_1s)*%sysfunc(log(%sysevalf(&n_11/&n_1s))) + 
						 (&n_12/&n_1s)*%sysfunc(log(%sysevalf(&n_12/&n_1s)))) / %sysfunc(log(2)) ) ;
	%let E2=%sysevalf(-( (&n_21/&n_2s)*%sysfunc(log(%sysevalf(&n_21/&n_2s))) + 
						 (&n_22/&n_2s)*%sysfunc(log(%sysevalf(&n_22/&n_2s)))) / %sysfunc(log(2)) ) ;
	%let E =%sysevalf(-( (&n_s1/&n  )*%sysfunc(log(%sysevalf(&n_s1/&n   ))) + 
						 (&n_s2/&n  )*%sysfunc(log(%sysevalf(&n_s2/&n   )))) / %sysfunc(log(2)) ) ;
	%let Er=%sysevalf(1-(&n_1s*&E1+&n_2s*&E2)/(&N*&E));
	%let &M_value=&Er;
	%return;
				%end;
/* The case of X2 pearson statistic */
%if (&method=3) %then %do;
 %local m_11 m_12 m_21 m_22 X2 N i j;
	%let N=%eval(&n_1s+&n_2s);
	%let X2=0;
	%do i=1 %to 2;
	  %do j=1 %to 2;
		%let m_&i.&j=%sysevalf(&&n_&i.s * &&n_s&j/&N);
		%let X2=%sysevalf(&X2 + (&&n_&i.&j-&&m_&i.&j)*(&&n_&i.&j-&&m_&i.&j)/&&m_&i.&j  );  
	  %end;
	%end;
	%let &M_value=&X2;
	%return;
%end;

/* The case of the information value */

%if (&method=4) %then %do;
  %local IV;
  %let IV=%sysevalf( ((&n_11/&n_s1)-(&n_12/&n_s2))*%sysfunc(log(%sysevalf((&n_11*&n_s2)/(&n_12*&n_s1)))) 
                    +((&n_21/&n_s1)-(&n_22/&n_s2))*%sysfunc(log(%sysevalf((&n_21*&n_s2)/(&n_22*&n_s1)))) );
   %let &M_Value=&IV;
   %return;
%end;
%mend;

/*******************************************************/
/* Macro BestSplit */
/*******************************************************/
%macro BestSplit(BinDs, Method, BinNo);

/* find the best split for one bin dataset */
/* the bin size=mb */
%local mb i value BestValue BestI;
proc sql noprint;
 select count(*) into: mb from &BinDs where Bin=&BinNo; 
quit;

/* find the location of the split on this list */
%let BestValue=0;
%let BestI=1;
%do i=1 %to %eval(&mb-1);
  %let value=;
  %CalcMerit(&BinDS, &i, &method, Value);
  %if %sysevalf(&BestValue<&value) %then %do;
      %let BestValue=&Value;
	  %let BestI=&i;
	   %end;
%end;

/* Number the bins from 1->BestI =BinNo, and from BestI+1->mb =NewBinNo */

/* split the BinNo into two bins */ 
data &BinDS;
 set &BinDS;
  if i<=&BestI then Split=1;
  else Split=0;
drop i;
run;
proc sort data=&BinDS; 
by Split;
run;
/* reorder i within each bin */
data &BinDS;
retain i 0;
set &BinDs;
 by Split;
 if first.split then i=1;
 else i=i+1;
run;
%mend;

/*******************************************************/
/* Macro CandSplit */
/*******************************************************/
%macro CandSplits(BinDS, Method, NewBins);
/* Generate all candidate splits from current
   Bins and select the best new bins */

/* first we sort the dataset OldBins by PDV1 and Bin */
proc sort data=&BinDS;
by Bin PDV1;
run;
/* within each bin, separate the data into a candidate dataset */
%local Bmax i value;
proc sql noprint;
 select max(bin) into: Bmax from &BinDS;
%do i=1 %to &Bmax; 
%local m&i;
   create table Temp_BinC&i as select * from &BinDS where Bin=&i;
   select count(*) into:m&i from Temp_BinC&i; 
%end;
   create table temp_allVals (BinToSplit num, DatasetName char(80), Value num);
run;quit;

/* for each of these bins,*/
%do i=1 %to &Bmax;
 %if (&&m&i>1) %then %do;  /* if the bin has more than one category */
 /* find the best split possible  */
  %BestSplit(Temp_BinC&i, &Method, &i);
 /* try this split and calculate its value */
  data temp_trysplit&i;
    set temp_binC&i;
	if split=1 then Bin=%eval(&Bmax+1);
  run;

  Data temp_main&i;
   set &BinDS;
   if Bin=&i then delete; 
  run;
  Data Temp_main&i;
    set temp_main&i temp_trysplit&i;
  run;

 /* Evaluate the value of this split 
    as the next best split */
  %let value=;
 %GValue(temp_main&i, &Method, Value);

 proc sql noprint; 
  insert into temp_AllVals values(&i, "temp_main&i", &Value); 
 run;quit; 

 %end; /* end of trying for a bin wih more than one category */

%end;
 
/* find the best split  and return the new bin dataset */
proc sort data=temp_allVals;
by descending value;
run;
data _null_;
 set temp_AllVals(obs=1);
 call symput("bin", compress(BinToSplit));
run;

/* the return dataset is the best bin Temp_trySplit&bin */
Data &NewBins;
 set Temp_main&Bin;
 drop split;
run;

/* Clean the workspace */
proc datasets nodetails nolist library=work;
 delete temp_AllVals %do i=1 %to &Bmax; Temp_BinC&i  temp_TrySplit&i temp_Main&i %end; ; 
run;
quit;
%mend;

/*******************************************************/
/* Macro ReduceCats */
/*******************************************************/
%macro  ReduceCats(DSin, IVVar, DVVar, Method, Mmax,  DSVarMap);
/* Reducing the categories of a categorical variable */

/* Get the categories of the IV, and the percentage 
   of the DV=1 and DV=0 in each one of them */
	/* get the categories using CalcCats macro */

proc freq data=&DSin noprint;
 table &IVVar*&DVvar /out=Temp_cross;
 table &IVVar /out=Temp_IVtot;
 run;

/* Rollup on the level of the category */
proc sort data=temp_cross;
 by &IVVar;
run;

proc sort data= temp_IVTot;
by &IVvar;
run;

data temp_cont; /* contingency table */
merge Temp_cross(rename=count=Ni2 ) temp_IVTot (rename=Count=total);
by &IVVar; 
PDV1=Ni2/total;
Ni1=total-Ni2;
label  Ni2= total=;
if &DVVar=1 then output;
drop percent &DVVar;
run;

/* sort by the percentage of DV=1 */
proc sort data=temp_cont;
by PDV1;
run;

%local m;
/* put all the category in one node as a string point */
data temp_cont;
 set temp_cont (Rename=&IVVar=Var);
 i=_N_;
 Bin=1;
 call symput("m", compress(_N_)); /* m=number of categories */
run;

/* loop until  the maximum number of nodes has been reached */
%local Nbins ;
%let Nbins=1; /* Current number of bins */ 
%DO %WHILE (&Nbins <&MMax);
	%CandSplits(temp_cont, &method, Temp_Splits);
	Data Temp_Cont;
  		set Temp_Splits;
	run;
	%let NBins=%eval(&NBins+1);

%end; /* end of the WHILE splitting loop  */
/* the output dataset is DSVarMap */
data &DSVarMap ;
 set temp_cont(Rename=Var=&IVVar);
 drop Ni2 PDV1 Ni1 i ;
 label Bin      ='New Category Group' 
       Category ='Old Category Group'
        total   ='Number of Records';
 run;

proc sort data=&DSVarMap;
by Bin;
run;

 /* clean the workspace */
proc datasets library=work nodetails nolist;
 delete temp_cont temp_cross temp_ivtot temp_Splits;
run;quit;
%mend;
