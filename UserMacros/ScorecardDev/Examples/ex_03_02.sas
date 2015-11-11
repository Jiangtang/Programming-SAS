/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 3.2 */
/*******************************************************/

/*******************************************************/
/* Macro EqWbinn - Equal width binning */ 
/*******************************************************/
%macro EqWBinn(DSin, XVar, Nb,XBVar, DSout, DSMap);
/* extract max and min values */
	proc sql  noprint; 
		 select  max(&Xvar) into :Vmax from &dsin;
		 select  min(&XVar) into :Vmin from &dsin;
	run;
	quit;

	 /* calcualte the bin size */
	%let Bs = %sysevalf((&Vmax - &Vmin)/&Nb);

	/* Loop on each of the values, create the bin boundaries, 
	   and count the number of values in each bin */
	data &dsout;
	 set &dsin;
	  %do i=1 %to &Nb;
		  %let Bin_U=%sysevalf(&Vmin+&i*&Bs);
		  %let Bin_L=%sysevalf(&Bin_U - &Bs);
		  %if &i=1 %then  %do; 
				IF &Xvar >= &Bin_L and &Xvar <= &Bin_U THEN &XBvar=&i; 
						  %end;
		  %else %if &i>1 %then %do; 
				IF &Xvar > &Bin_L and &Xvar <= &Bin_U THEN &XBvar=&i;  
								 %end;
	  %end;
	run;
	/* Create the binning map and store the bin boundaries */
	proc sql noprint;
	 create table &DSMap (BinMin num, BinMax num, BinNo num);
	  %do i=1 %to &Nb;
		  %let Bin_U=%sysevalf(&Vmin+&i*&Bs);
		  %let Bin_L=%sysevalf(&Bin_U - &Bs);
		  insert into &DSMap values(&Bin_L, &Bin_U, &i);
	  %end;
	quit;
%mend;  

/*******************************************************/
/* Generate the data */
/*******************************************************/
data Test1;
 input x @@;
 datalines;
 1.45  0.73  2.43  3.89  3.86  3.96  2.41  2.29
 2.23  2.19  0.37  2.71  0.77  0.83  3.61  1.71
 1.06  3.23  0.68  3.15  1.83  3.37  1.60  1.17
 3.87  2.36  1.84  1.64  3.97  2.23  2.21  1.93
 ;
run;
/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=Test1;
%let DSout=Test1b;
%let XVar=x;
%let Nb=5;
%let XBvar=x_b;
%let DSMap=test1map;
%EqWBinn(&DSin, &XVar, &Nb, &XBvar, &DSout, &DSMap);

/*******************************************************/
/* Print the binning map dataset to the output window */
/*******************************************************/
proc print data=test1map;
run;
/*******************************************************/
/* Plot the histogram data */
/*******************************************************/
proc chart data=test1b;
vbar x_b;
run;

/*******************************************************/
/* Clean the work space */
/*******************************************************/
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/



