/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 5.3 */
/*******************************************************/



/*******************************************************/
/* The macros: GValue, CalcMerit, BestSplit, CandSplits,
   BinContVar
   macro BinContVar needs all the above 4 macros to run
   and to apply the binning maps, use ApplyMap2. 
/*******************************************************/



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
/* claculation of the merit function for the current  */
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
/* Macro CandSplits */
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
/* Macro BinContVar */
/*******************************************************/
%macro BinContVar(DSin, IVVar, DVVar, Method, MMax, Acc, DSVarMap);
/* Optimal binning of the continuous variable */

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


/*******************************************************/
/* Macro ApplyMap2 */
/*******************************************************/
%macro ApplyMap2(DSin, VarX, NewVarX, DSVarMap, DSout);
/* Applying a mapping scheme; to be used with 
 macro BinContVar */

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

/*******************************************************/
/* Generate a dataset with dependent variable and a 
continuous independent variable with some correlation to 
the dependent variable categories */
/*******************************************************/
data Customers;
Input Income Default @@;
datalines;
2339.95	0	1578.3	0	1453.02	0	1398.77	1	2988.94	0      1970.5	0	1765.14	0	1016.64	1	1024.72	1	3731.1	0 
1296.54	1	1375.53	1	2454.93	0	1458.21	1	3607.17	0      1137.89	1	2618.88	0	3066.08	0	1651.19	0	2122.69	0 
2384.87	0	1117.99	1	3059.15	0	2632.47	0	1321.09	1      3481.08	0	2599.82	0	3421.61	0	2615.36	0	2177.07	0 
3129.73	0	1597.58	0	1996.46	0	2561.42	0	1143.17	0      3517.13	0	1044.27	1	2149.7	0	1062.72	1	2802.59	0 
1170.76	1	1839.54	1	1341.2	0	2687.47	0	1882.49	0      1001.02	1	1222.01	1	3773.33	0	2108.08	0	3555.37	0 
3860.08	0	3471.33	0	2836.04	0	3279.11	0	3359.93	0      2661.54	0	3075.54	0	3335.51	0	3615.98	0	2608.25	0 
3291.14	0	2738.75	0	3297.46	0	2329.84	0	1579.09	0      1005.38	1	3467.94	0	2460.84	0	3786.78	0	1697.54	0 
1344.75	0	2546.71	0	1044.77	1	1754.39	0	3088.03	0      3190.34	0	1643.03	0	1159.4	0	1594.84	1	2195.37	0 
2040.43	0	2288.39	0	1254.77	1	2177.82	0	1432.33	1      2090.93	0	1592.75	1	3649.18	0	1192.09	0	1870.53	0 
1344.73	0	3112.17	0	3594.69	0	1256.47	0	1884.62	0      2804.8	0	2397.37	0	3106.19	0	2153.69	0	2901.84	0 
1932.5	0	2967.7	0	3742.8	0	2741.32	0	3229.37	0      2955.23	0	3984	0	1764.69	0	3262.91	0	3556.29	0 
1371.41	0	1506.34	0	3835.23	0	1017.64	1	2786.11	0      1027.96	1	2705.19	0	1112.11	1	1345.8	1	3224.26	0 
3381.09	0	3564.85	0	3860.62	0	2039.35	0	2232.72	0      1755.91	1	2730.88	0	3071.92	0	3859.66	0	2728.11	0 
3908.71	0	1900.97	0	2365.91	0	1173.9	1	3046.59	0      3247.21	0	1765.75	1	1851.27	0	3168.86	0	1180.68	1 
1126.39	1	3716.19	0	3482.85	0	1177.04	1	2869.67	0      2112.35	0	1259.28	1	2034.07	0	2781.34	0	2650.68	0 
1098.68	1	3413.67	0	3832.62	0	1446.92	0	2823.57	0      2964.95	0	3480.61	0	3982.74	0	2223.56	0	2324.61	0 
1839.08	0	2816.05	0	2161.21	0	2215.25	0	1829.55	1      3088.54	0	2006.91	0	1895.16	0	3540.52	0	1159.11	1 
3753.1	0	2583.6	0	1694.81	0	1800.39	0	2831.79	0      1953.42	0	2326.95	0	3963.79	0	3478.85	0	1445.58	0 
1559.44	0	2785.78	0	1677.91	1	2529.97	0	1929.34	0      3347.23	0	2467.97	0	3704.05	0	1370.85	1	1324.15	0 
2131.14	0	3558.72	0	3580.39	0	1241.11	1	3914.43	0      2829.92	0	2112.3	0	1990.34	0	1265.65	1	3572.18	0 
;
run;

/*******************************************************/
/* Call the binning macro */
/*******************************************************/
%let DSin=Customers;
%let IVVar=Income;
%let DVVar=Default;
%let Method=1;
%let MMax=5;
%let Acc=0.01;
%let DSVarMap=Income_Map;
%BinContVar(&DSin, &IVVar, &DVVar, &Method, &MMax, &Acc, &DSVarMap);

/*******************************************************/
/* Print the binning map dataset  */
/*******************************************************/

/* A simple layout */
Proc print data=Income_Map;
run;
/* A more fancy printout */
options linesize=120; 
proc print data=Income_Map split='*' ;
     var bin LL UL BinTotal;
     label bin       ='Bin*Number*========='
           LL='Lower*Bound*========='
		   UL='Upper*Bound*========='
		   BinTotal='Bin*Size*=========';
		   format LL Comma10.2; 
		   format UL Comma10.2; 
		   format BinTotal Comma10.0; 
   title 'Mapping rules for binning variable: Income';
run;

/*******************************************************/
/* Apply the mapping scheme */
/*******************************************************/

/* use:
options mprint ;
   to see the binning statements in the SAS Log */

%let DSin=Customers;
%let VarX=Income;
%let NewVarX=Income_bin;
%let DSVarMap=Income_map;
%let DSout=Customers_Income_b;
%ApplyMap2(&DSin, &VarX, &NewVarX, &DSVarMap, &DSout);

/* If you used mprint, don't forget to de-activate it again using:
 options nomprint;  */

/*******************************************************/
/* Examine the distribution of records within the bins */
/*******************************************************/
proc freq data=customers_income_b;
table Income_bin * Default;
run;
/*******************************************************/
 
/*******************************************************/
/* Clean the work space and reset title */
/*******************************************************/
title ;
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

