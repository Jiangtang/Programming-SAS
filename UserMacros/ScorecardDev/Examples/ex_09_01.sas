/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example: 9.1  */
/*******************************************************/

%macro CalcWOE(DsIn, IVVar, DVVar, WOEDS, WOEVar, DSout);
/* Calculating the WOE of an Independent variable IVVar and 
adding it to the data set DSin (producing a different output 
dataset DSout). The merging is done using PROC SQL to avoid 
the need to sort for matched merge. The new woe variable
is called teh WOEVar. The weight of evidence values
are also produced in the dataset WOEDS*/

/* Calculate the frequencies of the categories of the DV in each
of the bins of the IVVAR */

PROC FREQ data =&DsIn noprint;
  tables &IVVar * &DVVar/out=Temp_Freqs;
run;

/* sort them */
proc sort data=Temp_Freqs;
 by &IVVar &DVVar;
run;

/* Sum the Goods and bads and calcualte the WOE for each bin */
Data Temp_WOE1;
 set Temp_Freqs;
 retain C1 C0 C1T 0 C0T 0;
 by &IVVar &DVVar;
 if first.&IVVar then do;
      C0=Count;
	  C0T=C0T+C0;
	  end;
 if last.&IVVar then do;
       C1=Count;
	   C1T=C1T+C1;
	   end;
 
 if last.&IVVar then output;
 drop Count PERCENT &DVVar;
call symput ("C0T", C0T);
call symput ("C1T", C1T);
run;

/* summarize the WOE values ina woe map */ 
Data &WOEDs;
 set Temp_WOE1;
  GoodDist=C0/&C0T;
  BadDist=C1/&C1T;
  if(GoodDist>0 and BadDist>0)Then   WOE=log(BadDist/GoodDist);
  Else WOE=.;
  keep &IVVar WOE;
run;

proc sort data=&WOEDs;
 by WOE;
 run;

/* Match the maps with the values and create the output
dataset */
proc sql noprint;
	create table &dsout as 
	select a.* , b.woe as &WOEvar from &dsin a, &woeds b where a.&IvVar=b.&IvVar; 
quit;

/* Clean the workspace */
proc datasets library=work nodetails nolist;
 delete Temp_Freqs Temp_WOE1;
run; quit;
%mend;

/*******************************************************/
/* Macro EqWbinn  */ 
/*******************************************************/
%macro EqWBinn(DSin, XVar, Nb, XBVar, DSout, DSMap);
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


/***********************************************/
/* Use EqWBinn to bin all continuous variables 
   in the dataset CreditCard  and CalcWOE to 
   calculate the WOE transforms of ALL the 
   variables */
/***********************************************/
/* You may want to suppress the notes to shorten the SAS log
   (and speed up execution) */
 options nonotes;  
/*******************************************************/
/* Load the CreditCard dataset */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
%include "&dir\CC_Dataset.sas";

/* Customer Age: 5 EQUAL WIDTH bins */ 
%EqWBinn(CreditCard, CustAge,     5,CustAge_b,  CC1, Age_Map);
%EqWBinn(CC1,TmAtAddress,5,TmAtAddress_b,CC2,TmAtAddress_Map);
%EqWBinn(CC2,CustIncome ,5,CustIncome_b ,CC3,CustIncome_Map );
%EqWBinn(CC3,TmWBank    ,5,TmWBank_b    ,CC4,TmWBank_Map    );
%EqWBinn(CC4,AmBalance  ,5,AmBalance_b  ,CC5,AmBalance_Map  );
%EqWBinn(CC5,UtilRate   ,5,UtilRate_b   ,CC6,UtilRate_Map   );

/* WOE's for binned variables */
%CalcWOE(CC6 ,CustAge_b    ,status,CustAge_WOE    ,CustAge_WOE    ,CC7);
%CalcWOE(CC7 ,TmAtAddress_b,status,TmAtAddress_WOE,TmAtAddress_WOE,CC8);
%CalcWOE(CC8 ,CustIncome_b ,status,CustIncome_WOE ,CustIncome_WOE ,CC9);
%CalcWOE(CC9 ,TmWBank_b    ,status,TmWBank_WOE    ,TmWBank_WOE    ,CC10);
%CalcWOE(CC10,AmBalance_b  ,status,AmBalance_WOE  ,AmBalance_WOE  ,CC11);
%CalcWOE(CC11,UtilRate_b   ,status,UtilRate_WOE   ,UtilRate_WOE   ,CC12);
/* WOE's for nominal variables */
%CalcWOE(CC12,EmpStatus    ,status,EmpStatus_WOE  ,EmpStatus_WOE  ,CC13);
%CalcWOE(CC13,ResStatus    ,status,ResStatus_WOE  ,ResStatus_WOE  ,CC14);
%CalcWOE(CC14,OtherCC      ,Status,OtherCC_WOE    ,OtherCC_WOE    ,CC15);

options notes;  /* reset the notes */
/* Store the last dataset to use in subsequent examples */
libname cc "&dir"; /* the same folder as the examples */
data cc.CC_WOE; 
 set cc15; /* the last dataset with WOE variabls */
run;

/* Store the variable names in a macro varible VarList */

%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;

/* Using option NONE */
proc logistic data=cc.CC_WOE;
 model Status (event='1')=&VarList / 
          SELECTION=NONE;
run;

/* Using option STEPWISE (S) */
proc logistic data=cc.CC_WOE;
 model Status (event='1')=&VarList / 
          SELECTION=S SLE=0.05 SLS=0.05;
run;

/*********************************************/
/* Clean the workspace */
/*********************************************/

proc catalog catalog=work.sasmacr force kill;  /* delete all macros */
run; quit;
proc datasets library=work nolist nodetails kill; /* delete all datasets i WORK */
run; quit;

/*******************************************************/
/* End of the example. */
/*******************************************************/

