/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

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

