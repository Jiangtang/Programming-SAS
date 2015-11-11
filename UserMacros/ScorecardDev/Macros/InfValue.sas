/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro: InfValue
/*******************************************************/
%macro InfValue(DSin, XVar, YVarBin, M_IV);

/* Extract the frequency table using proc freq, 
   and the categories of the X variable */

proc freq data=&DSin noprint;
 table &XVar*&YvarBin /out=Temp_freqs;
 table &XVar /out=Temp_Xcats;
 run;

proc sql noprint;
  /* Count the number of obs and categories of X */
   %local R C; /* rows and columns of freq table */
   select count(*) into : R from temp_Xcats;
   select count(*) into : N from &DSin; 
quit;

  /* extract the categories of X into CatX_i */
data _Null_;
  set temp_XCats;
   call symput("CatX_"||compress(_N_), &Xvar);
run;

proc sql noprint; 
	/* extract n_i_j*/
 %local i j;
   %do i=1 %to &R; 
    %do j=1 %to 2;/* we know that YVar is 1/0 - numeric */
      %local N_&i._&j;
   Select Count into :N_&i._&j from temp_freqs where &Xvar ="&&CatX_&i" and &YVarBin = %eval(&j-1);
    %end;
   %end;
quit;
  
  /* calculate N*1,N*2 */
     %local N_1s N_2s;
      %let N_1s=0;
	  %let N_2s=0;
  %do i=1 %to &r; 
	  %let N_1s=%sysevalf(&N_1s + &&N_&i._1);
	  %let N_2s=%sysevalf(&N_2s + &&N_&i._2);
   %end;

/* substitute in the equation for IV */
     %local IV;
     %let IV=0;
       %do i=1 %to &r;
          %let IV = %sysevalf(&IV + (&&N_&i._1/&N_1s - &&N_&i._2/&N_2s)*%sysfunc(log(%sysevalf(&&N_&i._1*&N_2s/(&&N_&i._2*&N_1s)))) );
       %end;

%let &M_IV=&IV; 

/* clean the workspace */
proc datasets library=work;
delete temp_freqs temp_Xcats;
quit;
%mend;
