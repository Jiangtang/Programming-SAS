/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro : GrFBinDV */
/*******************************************************/


%macro  GrFBinDV(DSin, Xvar, BinDV, M_Gr, M_Fstar, M_Pvalue);
/* Calculation of the Gr and F* values for a continuous 
   variable Xvar and a binary DV
	DSin = input dataset
	BinDV = binary dependent variable (1/0 only)
	XVar = X Variable - continuous
	M_GR = returned Gr Gini ratio
	M_Fstar= returned F* 
	M_Pvalue= returned p-value of F*
*/


/* Get the categories of the BinDV*/
	proc freq data=&DSin noprint ;
	tables &BinDV /missing out=Temp_Cats;
	run;

	/* Convert the categories (Y_i) and their frequencies 
	  n_i to macro variables */

	%local N_1 N_2 N;

	Data _null_;
	retain N 0;
	  set Temp_Cats;
	   N=N+count;
       	       call symput ("n_" || left(_N_), left(count));
		   call symput ("N", left(N));
        Run;

	/* Calculate the quantities needed to substitute in 
	   SSTO, SSR, SSE, MSR, MSE, F*, Gr */

   proc sql noprint;
   /* xbar */
   %local xbar i; 
    select avg(&xVar) into :xbar from &DSin;
 
   %do i=1 %to 2;
	/* Ybar_i */
	select avg(&XVar) into :Xbar_&i 
	          from &DSin where &BinDV = %eval(&i-1);  

   %end;	

	/* SSTO, SSR, SSE */
   %local SSTO SSR SSE;
    select var(&XVar) into: SSTO from &DSin;
	%let SSTO=%sysevalf(&SSTO *(&N-1));
	%let SSR=0;
	%let SSE=0;

	%local SSEi;
    %do i=1 %to 2;
	  select var(&XVar) into: SSEi 
	            from &DSin where &BinDV=%eval(&i-1);
      %let SSE=%sysevalf(&SSE + &ssei * (&&n_&i - 1)) ; 

	  %let SSR=%sysevalf(&SSR+ &&n_&i * (&&Xbar_&i - &Xbar)*
	                                    (&&Xbar_&i - &Xbar));
    %end;

  quit; /* end of Proc SQL */

	/* MSR, MSE , F*, Gr, Pvalue */
    %local MSR MSE Fstar;
	%let MSR=&SSR;
	%let MSE=%sysevalf(&SSE/(&N-2));
	%let &M_Gr=%Sysevalf(1-(&SSE/&SSTO));
	%let Fstar=%sysevalf(&MSR/&MSE);
	%let &M_Fstar=&Fstar;
	%let &M_PValue=%sysevalf(%sysfunc(probf(&Fstar,1,&N-2)));

/* clean workspace */
	proc datasets library=work nolist;
	 delete temp_cats;
	run; quit;
%mend;
