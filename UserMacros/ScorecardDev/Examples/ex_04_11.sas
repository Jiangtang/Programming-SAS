/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.11 */
/*******************************************************/

/*******************************************************/
/* Macro: CalcGrF
/*******************************************************/
%macro  CalcGrF(DSin, Xvar, YVar, M_Gr, M_Fstar, M_Pvalue);

/* Get the categories of the XVar*/
	proc freq data=&DSin noprint ;
	tables &XVar /missing out=Temp_Cats;
	run;
	/* Convert the categories (X_i) and their frequencies 
	  n_i to macro variables */
	Data _null_;
	retain N 0;
	  set Temp_Cats;
	   N=N+count;
	       call symput ("X_" || left(_N_), compress(&XVar));	
       	       call symput ("n_" || left(_N_), left(count));
	       call symput ("K", left(_N_));
		   call symput ("N", left(N));
        Run;
	/* Calculate the quantities needed to substitute in 
	   SSTO, SSR, SSE, MSR, MSE, F*, Gr */
   proc sql noprint;
   /* Ybar */
    select avg(&YVar) into :Ybar from &DSin;
	%local i;
   %do i=1 %to &K;
	/* Ybar_i */
	select avg(&YVar) into :Ybar_&i 
	          from &DSin where &XVar = "&&X_&i";  
   %end;	
	/* SSTO, SSR, SSE */
    select var(&YVar) into: SSTO from &DSin;
	%let SSTO=%sysevalf(&SSTO *(&N-1));
	%let SSR=0;
	%let SSE=0;
    %do i=1 %to &K;
	  select var(&YVar) into: ssei 
	            from &DSin where &Xvar="&&X_&i";
      %let SSE=%sysevalf(&SSE + &ssei * (&&n_&i - 1)) ; 

	  %let SSR=%sysevalf(&SSR+ &&n_&i * (&&Ybar_&i - &Ybar)*
	                                    (&&Ybar_&i - &Ybar));
    %end;

  quit; /* end of Proc SQL */

	/* MSR, MSE , F*, Gr, Pvalue */
	%let MSR=%sysevalf(&SSR/(&K-1));
	%let MSE=%sysevalf(&SSE/(&N-&K));
	%let &M_Gr=%Sysevalf(1-(&SSE/&SSTO));
	%let &M_Fstar=%sysevalf(&MSR/&MSE);
	%let &M_PValue=%sysevalf(%sysfunc(probf(&Fstar,&K-1,&N-&K)));
/* clean workspace */
	proc datasets library=work nolist;
	 delete temp_cats;
	run; quit;
%mend;


/*******************************************************/
/* Generate dataset with a nominal variable Default, and 
 a continuous variable AvgBalance */
/*******************************************************/
data CC;
 input Default $ AvgBalance @@;
 datalines;
N 1132.37 N 1118.39 Y  336.17 N  775.64 N  519.49
N  303.34 N 1418.00 N 1372.85 N 1363.32 N  244.29
N  624.70 N 1191.22 N 1536.35 N  752.05 N 1013.60
N 1394.93 N  688.43 N  557.26 N  773.99 N 1302.07
N 1241.23 N  765.49 N  775.11 N  683.23 N  922.97
N 1095.69 N  752.59 N 1488.18 N  687.98 N  901.57
N 1761.56 N  861.63 N 1095.73 N 1626.03 N  498.24
N 1139.91 N 1524.18 N  387.17 N 1313.15 N 1155.98
N  727.66 N  689.59 N 1577.18 N 1522.56 Y  225.92
Y  279.63 N  261.39 N  874.46 N 1352.64 N 1898.72
N  622.42 N 1791.32 N 1497.03 N  913.54 N  861.12
Y  539.82 N  886.68 N  499.23 N  942.35 N  515.34
Y  462.33 N 1618.78 N 1392.00 N 1113.60 N  765.68
N 1119.53 N  906.02 N  884.23 N  901.92 Y  556.98
N  633.66 N  343.12 N 1036.54 N  498.94 Y  238.26
Y   19.41 N 1492.44 N  545.95 N 1776.19 N 1048.82
N 1270.68 N  897.63 N 1194.00 N  422.45 N  500.44
N 1602.12 N 1135.93 N  900.85 Y  134.19 N  598.06
N 1009.30 N  618.23 N 1855.87 N 1074.82 Y  401.79
N 1139.86 N  568.81 N  913.48 N 1470.60 N 1468.44
;
run;

/*******************************************************/
/* Call the macro: the variables in the macro header 
   with the prefix M_ are to be initialized to null 
   strings  before calling the macro */
/*******************************************************/
 %let DSin=CC;
 %let Xvar=default;
 %let YVar=AvgBalance;
 %let Gr=;
 %let Fstar=;
 %let Pvalue=;
%CalcGrF(&DSin, &Xvar, &YVar, Gr, Fstar, Pvalue);

/*******************************************************/
/* output the values to the SAS-Log window */
/*******************************************************/
%put Gr=&Gr     Fstar=&Fstar     Pvalue=&Pvalue;

/*******************************************************/
/* Map the default variable to numeric dummy variable */
/*******************************************************/
data CC1;
 set CC;
 if Default='Y' then default1=1;
 else default1=0;
run;

/*******************************************************/
/* Use linear regression to replicate the results */
/*******************************************************/
proc reg data=CC1;
 model avgBalance=default1;
run;


/*******************************************************/
/* Clean the work space/
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;


/*******************************************************/
/* End of the example. */
/*******************************************************/


