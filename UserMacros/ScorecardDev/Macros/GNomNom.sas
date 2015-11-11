/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro: GNomNom */
/*******************************************************/
%macro GNomNom(DSin, XVar, YVar, M_Gr);

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

/* substitute in the equations for Gi, G */

  %do i=1 %to &r;
     %local G_&i;
     %let G_&i=0;
       %do j=1 %to &c;
          %let G_&i = %sysevalf(&&G_&i + &&N_&i._&j * &&N_&i._&j);
       %end;
      %let G_&i = %sysevalf(1-&&G_&i/(&&N_&i._s * &&N_&i._s));
   %end;

   %local G; 
    %let G=0;
    %do j=1 %to &c;
       %let G=%sysevalf(&G + &&N_s_&j * &&N_s_&j);
    %end;
    %let G=%sysevalf(1 - &G / (&N * &N));

/* finally, the Gini ratio Gr */

%local Gr;
%let Gr=0; 
 %do i=1 %to &r;
   %let Gr=%sysevalf(&Gr+ &&N_&i._s * &&G_&i / &N);
 %end;
%let &M_Gr=%sysevalf(1 - &Gr/&G); 
/* clean the workspace */
proc datasets library=work;
delete temp_freqs temp_Xcats temp_YCats;
quit;
%mend;

