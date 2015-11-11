/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro: ENomNom
/*******************************************************/
%macro ENomNom(DSin, XVar, YVar, M_Er);
/* Calculation of the Entropy variance ratio for two nominal variables
   with string values */

/* Extract the frequency table using proc freq, 
   and the categories of both variables */

proc freq data=&DSin noprint;
 table &XVar*&Yvar /out=Temp_freqs;
 table &XVar /out=Temp_Xcats;
 table &YVar /out=Temp_Ycats;
 run;
proc sql noprint;
  /* Count the number of obs and categories of X and Y */
   %local R C; /* rows and columns of freq table */
   select count(*) into : R from temp_Xcats;
   select count(*) into : C from temp_Ycats;
   select count(*) into : N from &DSin; 
quit;

  /* extract the categories of X and Y into CatX_i, CatY_j */
data _Null_;
  set temp_XCats;
   call symput("CatX_"||compress(_N_), &Xvar);
run;
data _Null_;
  set temp_YCats;
   call symput("CatY_"||compress(_N_), &Yvar);
run;

proc sql noprint; 
	/* extract n_i_j*/
%local i j;
   %do i=1 %to &R; 
    %do j=1 %to &c;
      %local N_&i._&j;
   Select Count into :N_&i._&j from temp_freqs where &Xvar ="&&CatX_&i" and &YVar = "&&CatY_&j";
    %end;
   %end;
quit;
  
  /* calculate Ni-star */
  %do i=1 %to &r; 
     %local N_&i._s;
      %let N_&i._s=0;
       %do j=1 %to &c;
        %let N_&i._s = %eval (&&N_&i._s + &&N_&i._&j);
       %end;
   %end;
  /* Calculate Nstar-j */
  %do j=1 %to &c; 
     %local N_s_&j;
      %let N_s_&j=0;
       %do i=1 %to &r;
        %let N_s_&j = %eval (&&N_s_&j + &&N_&i._&j);
       %end;
   %end;

/* substitute in the equations for Ei, E */
  %do i=1 %to &r;
     %local E_&i;
     %let E_&i=0;
       %do j=1 %to &c;
          %let E_&i = %sysevalf(&&E_&i - (&&N_&i._&j/&&N_&i._s)*%sysfunc(log(%sysevalf(&&N_&i._&j/&&N_&i._s))) );
       %end;
      %let E_&i = %sysevalf(&&E_&i/%sysfunc(log(&c)));
   %end;

   %local E; 
    %let E=0;
    %do j=1 %to &c;
       %let E=%sysevalf(&E - (&&N_s_&j/&N)*%sysfunc(log(&&N_s_&j/&N)) );
    %end;
    %let E=%sysevalf(&E / %sysfunc(log(&c)));

/* finally, the Gini ratio Er */
%local Er;
%let Er=0; 
 %do i=1 %to &r;
   %let Er=%sysevalf(&Er+ &&N_&i._s * &&E_&i / &N);
 %end;
%let &M_Er=%sysevalf(1 - &Er/&E); 

/* clean the workspace */
proc datasets library=work;
delete temp_freqs temp_Xcats temp_YCats;
quit;
%mend;
