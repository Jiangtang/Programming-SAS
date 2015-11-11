/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 4.15 */
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
/* Macro : PowerIV */
/*******************************************************/
%macro PowerIV(DSin, DV, IVList, DSout);
/* Decompose the input IVList into tokens and store variable
   names into macro variables */

%local i N condition VarX; 
%let i=1;
%let N=0;
%let condition = 0; 
%do %until (&condition =1);
   %let VarX=%scan(&IVList,&i);
   %if "&VarX" =""  %then %let condition =1;
  	        %else %do;
				%local Var&i;
                %let Var&i =&VarX; 
                %let N=&i;
                %let i=%eval(&i+1); 
                  %end;  
%end;

/* now we have a total of N variables
   Loop on their  names and calculate the Information value
   between the DV and each of the variables */

proc sql noprint;
 create table &DSout (VariableName char(200), 
                      InformationValue  num);
quit;

%do i=1 %to &N;
   %local IV&i;
   %let IV&i=;
	%InfValue(&DSin, &&Var&i, &DV, IV&i);
	proc sql noprint; 
     insert into &DSout  values("&&Var&i",&&IV&i);
    quit; 	 
%end;


proc sort data=&dsout;
 by descending InformationValue; 
 run;

%mend; 


/*******************************************************/
/* Macro : ExtractTop */
/*******************************************************/

%macro ExtrctTop(DSin, VarCol, SelVar, Method, NTop, CutOff, M_VarList);

/* sort the dataset using the selection criteria in descending order */
proc sort data=&Dsin;
by descending &SelVar;
run;


%local Nact; 

 data _null_;
  set &DSin;
   by descending &SelVar;
%if (&Method=1) %then %do;
        if (_N_ le &NTop) then do;
		call symput("Var"||compress(_N_), &VarCol); 
		call symput("Nact", compress(_N_));
							  end;
%end;

%else %do;
	if (&SelVar ge &CutOff) then  do;
      call symput("Var"||compress(_N_), &VarCol); ; 
	  call symput("Nact", compress(_N_));
	                              end;
%end;

run;

 /* initialize the list and compose it using the extracted names*/
%local List;
%let List=;
 %local i;
  %do i=1 %to &Nact;
    %let List=&List &&Var&i;
  %end;

  %let &M_VarList=&List; 


%mend;


/*******************************************************/
/* Generate a dataset with 5 nominal variables and a 
    dependent variable (using the frequency method) */
/*******************************************************/
data CardInfo1;
length EmpType $10.;		/* Applicant employment type*/
length Gender $6.;			/* Applicant Gender */
length ResType $10.;		/* Applicant Residential status */
length AppChannel $10.; 	/* Application channel */
length TelType  $10.;		/* Type of contact tel number */

infile datalines delimiter=',';
input EmpType $  Gender $  ResType $  AppChannel $  TelType $  Status Freq;
datalines;
Full Time,Female,Home owner,Web,Home,1,35
Full Time,Female,Home owner,Web,Home,0,9
Full Time,Female,Home owner,Web,Mobile,1,18
Full Time,Female,Home owner,Web,Mobile,0,6
Full Time,Female,Home owner,Mail,Home,1,9
Full Time,Female,Home owner,Mail,Home,0,19
Full Time,Female,Home owner,Mail,Mobile,1,33
Full Time,Female,Home owner,Mail,Mobile,0,28
Full Time,Female,Tenant,Web,Home,1,8
Full Time,Female,Tenant,Web,Home,0,22
Full Time,Female,Tenant,Web,Mobile,1,25
Full Time,Female,Tenant,Web,Mobile,0,31
Full Time,Female,Tenant,Mail,Home,1,37
Full Time,Female,Tenant,Mail,Home,0,18
Full Time,Female,Tenant,Mail,Mobile,1,26
Full Time,Female,Tenant,Mail,Mobile,0,28
Full Time,Male,Home owner,Web,Home,1,12
Full Time,Male,Home owner,Web,Home,0,36
Full Time,Male,Home owner,Web,Mobile,1,2
Full Time,Male,Home owner,Web,Mobile,0,22
Full Time,Male,Home owner,Mail,Home,1,34
Full Time,Male,Home owner,Mail,Home,0,27
Full Time,Male,Home owner,Mail,Mobile,1,2
Full Time,Male,Home owner,Mail,Mobile,0,21
Full Time,Male,Tenant,Web,Home,1,32
Full Time,Male,Tenant,Web,Home,0,33
Full Time,Male,Tenant,Web,Mobile,1,1
Full Time,Male,Tenant,Web,Mobile,0,8
Full Time,Male,Tenant,Mail,Home,1,17
Full Time,Male,Tenant,Mail,Home,0,15
Full Time,Male,Tenant,Mail,Mobile,1,10
Full Time,Male,Tenant,Mail,Mobile,0,24
Other,Female,Home owner,Web,Home,1,21
Other,Female,Home owner,Web,Home,0,39
Other,Female,Home owner,Web,Mobile,1,28
Other,Female,Home owner,Web,Mobile,0,17
Other,Female,Home owner,Mail,Home,1,23
Other,Female,Home owner,Mail,Home,0,11
Other,Female,Home owner,Mail,Mobile,1,34
Other,Female,Home owner,Mail,Mobile,0,3
Other,Female,Tenant,Web,Home,1,21
Other,Female,Tenant,Web,Home,0,31
Other,Female,Tenant,Web,Mobile,1,18
Other,Female,Tenant,Web,Mobile,0,28
Other,Female,Tenant,Mail,Home,1,27
Other,Female,Tenant,Mail,Home,0,32
Other,Female,Tenant,Mail,Mobile,1,16
Other,Female,Tenant,Mail,Mobile,0,24
Other,Male,Home owner,Web,Home,1,11
Other,Male,Home owner,Web,Home,0,26
Other,Male,Home owner,Web,Mobile,1,19
Other,Male,Home owner,Web,Mobile,0,1
Other,Male,Home owner,Mail,Home,1,31
Other,Male,Home owner,Mail,Home,0,14
Other,Male,Home owner,Mail,Mobile,1,17
Other,Male,Home owner,Mail,Mobile,0,19
Other,Male,Tenant,Web,Home,1,35
Other,Male,Tenant,Web,Home,0,23
Other,Male,Tenant,Web,Mobile,1,12
Other,Male,Tenant,Web,Mobile,0,17
Other,Male,Tenant,Mail,Home,1,15
Other,Male,Tenant,Mail,Home,0,14
Other,Male,Tenant,Mail,Mobile,1,9
Other,Male,Tenant,Mail,Mobile,0,22
;
run;
/* Use the Freq field to generate the data */
DATA CardInfo2;
 set CardInfo1;
  do i=1 to Freq;
   output;
  end;
drop i Freq;
run;
/*******************************************************/
/* Call the macro */
/*******************************************************/
%let DSin=CardInfo2;
%let DV=Status;
%let IVList=EmpType Gender ResType AppChannel TelType;
%let DSOut=CardInfo_IVs;

%PowerIV(&DSin, &DV, &IVList, &DSout);
/*******************************************************/
/* Extract the top three variables */
/*******************************************************/
%let DSin=CardInfo_IVs;
%let VarCol=VariableName;
%let SelVar=InformationValue; 
%let Method=1;
%let Ntop=3;
%let Cutoff=0;
%let VarList=;
%ExtrctTop(&DSin, &VarCol, &SelVar, &Method, &NTop, &CutOff, VarList);
%put Selected Variables: &VarList;

/*******************************************************/
/* Extract the top variables with IV>=0.015*/
/*******************************************************/

%let DSin=CardInfo_IVs;
%let VarCol=VariableName;
%let SelVar=InformationValue; 
%let Method=2;
%let Ntop=0;
%let Cutoff=0.015;
%let VarList=;
%ExtrctTop(&DSin, &VarCol, &SelVar, &Method, &NTop, &CutOff, VarList);
%put Selected Variables: &VarList;


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

