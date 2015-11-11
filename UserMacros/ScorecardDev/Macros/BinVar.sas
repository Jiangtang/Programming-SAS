/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* The macros: GValue, CalcMerit, BestSplit, CandSplits,
   BinContVar, ApplyMap2 BinVar

  The binning macro is BinContVar, and to apply the binning
  maps, use ApplyMap2. All other macros are used by 
  BinContVar. 
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

%macro BinContVar(DSin, IVVar, DVVar, Method, MMax, Acc, DSVarMap);
/* 
Optimal binning of the continuous variable IVVar using the 
binary dependent variable DVVar and Method. The output 
is the variable mapping dataset DSVarMap. Acc is the level
of accuracy in defining the bins. it is a number between 
zero and 1. Acc=0.01 will make the accuracy in calculating the bin 
limits 1% of the total range of the variable. The smaller the value
of Acc, the longer it will take to do the binning, but the more
accurate the result. 

The method parameter controls the criterion used in the binning
as follows:
1=Gini 2=Entory 3=Pearson's Chi2 4=Information Value
*/

/* find the maximum and minimum values */
%local VarMax VarMin;
proc sql noprint;
 select min(&IVVar), max(&IVVar) into :VarMin, :VarMax from &DSin;
quit;
/* divide the range to a number of bins as needed by Acc */
%local Mbins i MinBinSize;
%let Mbins=%sysfunc(int(%sysevalf(1.0/&Acc)));
%let MinBinSize=%sysevalf((&VarMax-&VarMin)/&Mbins);
/* calculate the bin boundaries between the max, min */
%do i=1 %to %eval(&Mbins);
 %local Lower_&i Upper_&i;
 %let Upper_&i = %sysevalf(&VarMin + &i * &MinBinSize);
 %let Lower_&i = %sysevalf(&VarMin + (&i-1)*&MinBinSize);
%end;
%let Lower_1 = %sysevalf(&VarMin-0.0001);  /* just to make sure that no digits get trimmed */
%let Upper_&Mbins=%sysevalf(&VarMax+0.0001);
/* separate the IVVar, DVVAr in a small dataset for faster operation */
data Temp_DS;
 set &DSin;
 %do i=1 %to %eval(&Mbins-1);
  if &IVVar>=&&Lower_&i and &IVVar < &&Upper_&i Then Bin=&i;
 %end;
  if &IVVar>=&&Lower_&Mbins and &IVVar <= &&Upper_&MBins Then Bin=&MBins;
 keep &IVVar &DVVar Bin;
run;
/* Generate a dataset with the initial upper, lower limits per bin */
data temp_blimits;
 %do i=1 %to %Eval(&Mbins-1);
   Bin_LowerLimit=&&Lower_&i;
   Bin_UpperLimit=&&Upper_&i;
   Bin=&i;
   output;
 %end;
   Bin_LowerLimit=&&Lower_&Mbins;
   Bin_UpperLimit=&&Upper_&Mbins;
   Bin=&Mbins;
   output;
run;
proc sort data=temp_blimits;
by Bin;
run;
/* Find the frequencies of DV=1, DV=0 using freq */
proc freq data=Temp_DS noprint;
 table Bin*&DVvar /out=Temp_cross;
 table Bin /out=Temp_binTot;
 run;
/* Rollup on the level of the Bin */
proc sort data=temp_cross;
 by Bin;
run;
proc sort data= temp_BinTot;
by Bin;
run;
data temp_cont; /* contingency table */
merge Temp_cross(rename=count=Ni2 ) temp_BinTot(rename=Count=total) temp_BLimits ;
by Bin; 
Ni1=total-Ni2;
PDV1=bin; /* just for conformity with the case of nominal iv */
label  Ni2= total=;
if Ni1=0 then output;
else if &DVVar=1 then output;
drop percent &DVVar;
run;
data temp_contold;
set temp_cont;
run;

/* merge all bins that have either Ni1 or Ni2 or total =0 */
proc sql noprint;
%local mx;
 %do i=1 %to &Mbins;
  /* get all the values */
  select count(*) into : mx from Temp_cont where Bin=&i;
  %if (&mx>0) %then %do;
  select Ni1, Ni2, total, bin_lowerlimit, bin_upperlimit into 
         :Ni1,:Ni2,:total, :bin_lower, :bin_upper 
  from temp_cont where Bin=&i;
  	%if (&i=&Mbins) %then %do;
	   select max(bin) into :i1 from temp_cont where Bin<&Mbins;
	                      %end;
	%else %do;
	   select min(bin) into :i1 from temp_cont where Bin>&i;
	   %end;
   %if (&Ni1=0) or (&Ni2=0) or (&total=0) %then %do;
			update temp_cont set 
			           Ni1=Ni1+&Ni1 ,
					   Ni2=Ni2+&Ni2 , 
					   total=total+&Total 
			where bin=&i1;
			%if (&i<&Mbins) %then %do;
			update temp_cont set Bin_lowerlimit = &Bin_lower where bin=&i1;
			                      %end;
			%else %do;
			update temp_cont set Bin_upperlimit = &Bin_upper where bin=&i1;
				   %end;
		   delete from temp_cont where bin=&i;
      %end; 
  %end;
%end;
quit;
proc sort data=temp_cont;
by pdv1;
run;
%local m;
/* put all the category in one node as a string point */
data temp_cont;
 set temp_cont;
 i=_N_;
 Var=bin;
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
/* shape the output map */
data temp_Map1 ;
 set temp_cont(Rename=Var=OldBin);
 drop Ni2 PDV1 Ni1 i ;
 run;
proc sort data=temp_Map1;
by Bin OldBin ;
run;
/* merge the bins and calculate boundaries */
data temp_Map2;
 retain  LL 0 UL 0 BinTotal 0;
 set temp_Map1;
by Bin OldBin;
Bintotal=BinTotal+Total;
if first.bin then do;
  LL=Bin_LowerLimit;
  BinTotal=Total;
    End;
if last.bin then do;
 UL=Bin_UpperLimit;
 output;
end;
drop Bin_lowerLimit Bin_upperLimit Bin OldBin total;
 run;
proc sort data=temp_map2;
by LL;
run;
data &DSVarMap;
set temp_map2;
Bin=_N_;
run;
/* Clean the workspace */
proc datasets nodetails library=work nolist;
 delete temp_bintot temp_blimits temp_cont temp_contold temp_cross temp_ds temp_map1
    temp_map2 temp_splits;
run; quit;
%mend;

%macro ApplyMap2(DSin, VarX, NewVarX, DSVarMap, DSout);
/* applying the mapping scheme in the dataset
   DSVarMap on the ranges of the Continuous 
   variable VarX and producing an output dataset DSout 
   with the new variable name NewVarX containing the bin numbers
   use " options mprint " to print the binning statements to the 
   SAS Log window. */

/* Generating macro variables to replace the cetgories with their bins */
%local m i;
proc sql noprint;
 select count(Bin) into:m from &DSVarMap;
quit; 
%do i=1 %to &m;
 %local Upper_&i Lower_&i Bin_&i;
%end; 
data _null_;
 set &DSVarMap;
  call symput ("Upper_"||left(_N_), UL);
  call symput ("Lower_"||left(_N_), LL);
  call symput ("Bin_"||left(_N_), Bin);
run;
/* the actual replacement */
Data &DSout;
 set &DSin;
 /* first bin - open left */
 IF &VarX < &Upper_1 Then &NewVarX=&Bin_1;
 /* intermediate bins */
 %do i=2 %to %eval(&m-1);
   if &VarX >= &&Lower_&i and &VarX < &&Upper_&i Then &NewVarX=&&Bin_&i;
 %end;
/* last bin - open right */
   if &VarX >= &&Lower_&i  Then &NewVarX=&&Bin_&i;  
Run; 
%mend;





%macro BinVar(DSin, IVVar, DVVar, Method, MMax, Acc, DSVarMap, NewVar, DSout);
/* Binning of a continuous variable by calling the two macros
   BinContVar and ApplyMap2 */
/* Generate the binning map using BinContVar */ 
%binContVar(&DSin, &IVVar, &DVVar, &Method, &MMax, &Acc, &DSVarMap);
/* Apply the map */
%ApplyMap2(&DSin, &IVVar, &NewVar, &DSVarMap, &DSout);
%mend;

