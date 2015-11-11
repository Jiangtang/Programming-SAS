/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.14 */
/*******************************************************/

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

/*******************************************************/
/* Generate a dataset using the frequency method */
/*******************************************************/
data Emp_Default1;
length EmploymentCat $20.;
infile datalines delimiter=',';
input Default EmploymentCat $ FR ;
datalines;
0,Full time,248
0,Part time,215
0,Self employed,321
0,Other,157
1,Full time,128
1,Part time,174
1,Self employed,75
1,Other,91
;
run;
DATA Emp_Default2;
 set Emp_Default1;
  do i=1 to FR;
   output;
  end;
drop i FR;
run;
/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=Emp_Default2;
%let XVar=EmploymentCat;
%let YVarBin=default;
%let IVx1=;
 %InfValue(&Dsin, &Xvar, &YVarBin, Ivx1);

/*******************************************************/
/* Display the Information Value in the SAS Log */
/*******************************************************/
%put IV=&IVx1;

/*******************************************************/
/* Clean the work space*/
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;


/*******************************************************/
/* End of the example. */
/*******************************************************/


