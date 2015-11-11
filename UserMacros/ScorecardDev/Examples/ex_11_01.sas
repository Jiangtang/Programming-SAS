/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Example 11.1 */
/*******************************************************/

/*******************************************************/
/* Macro CalcWOE */
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
/* Macro EqWBinn */
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
	 create table &DSMap (LL num, UL num, Bin num);
	  %do i=1 %to &Nb;
		  %let Bin_U=%sysevalf(&Vmin+&i*&Bs);
		  %let Bin_L=%sysevalf(&Bin_U - &Bs);
		  insert into &DSMap values(&Bin_L, &Bin_U, &i);
	  %end;
	quit;
%mend;  




/*******************************************************/
/* Macro DummyGrps */
/*******************************************************/
%macro dummyGrps(DSin, Xvar, DSOut, MapDS);
/* dummy grouping of a varible and generating its map
  the new variable name is the old variable name subscripted
  by _b and MapDS is the mapping between the categories
  the DSout contains all the variables of DSin in addition
  to  Xvar_b (the bin number)

  This macro is to be used with string variables */

/* create the map ds */
proc freq data=&DSin noprint;
table &Xvar/out=&MapDS;
run;
data &MapDS;
 set &MapDS;
  Category=&XVar;
  Bin=_N_;
  keep Category Bin;
run;
/* apply these maps to the dataset to generate DSout */
%local m i;
proc sql noprint;
 select count(Bin) into:m from &MapDS;
quit; 
%do i=1 %to &m;
 %local Cat_&i Bin_&i;
%end; 

data _null_;
 set &MapDS;
  call symput ("Cat_"||left(_N_), trim(Category));
  call symput ("Bin_"||left(_N_), bin);
run;

/* the actual replacement */
Data &DSout;
 set &DSin;
 %do i=1 %to &m;
   IF &XVar = "&&Cat_&i"		THEN &Xvar._b=&&Bin_&i;
 %end;
Run; 

%mend;


/*******************************************************/
/* Macro DummyGrpn */
/*******************************************************/
%macro dummyGrpn(DSin, Xvar, DSOut, MapDS);
/* dummy grouping of a varible and generating its map
  the new variable name is the old variable name subscripted
  by _b and MapDS is the mapping between the categories
  the DSout contains all the variables of DSin in addition
  to  Xvar_b (the bin number)

  This macro is to be used with numeric nominal  variables */

/* create the map ds */
proc freq data=&DSin noprint;
table &Xvar/out=&MapDS;
run;
data &MapDS;
 set &MapDS;
  Category=&XVar;
  Bin=_N_;
  keep Category Bin;
run;
/* apply these maps to the dataset to generate DSout */
%local m i;
proc sql noprint;
 select count(Bin) into:m from &MapDS;
quit; 
%do i=1 %to &m;
 %local Cat_&i Bin_&i;
%end; 

data _null_;
 set &MapDS;
  call symput ("Cat_"||left(_N_), trim(Category));
  call symput ("Bin_"||left(_N_), bin);
run;

/* the actual replacement */
Data &DSout;
 set &DSin;
 %do i=1 %to &m;
   IF &XVar = &&Cat_&i		THEN &Xvar._b=&&Bin_&i;
 %end;
Run; 

%mend;



/*******************************************************/
/* Macro SCScale */
/*******************************************************/
%macro SCScale(BasePoints, BaseOdds, PDO, M_alpha, M_beta);
/* this macro calculates alpha, beta to scale the scorecard
   such that points=alpha + beta (ln odds) 
   beta = pdo/ln(2)
   alpha=basePoints - beta * (ln base odds)
*/
%local bb;
%let bb=%sysevalf(&PDO / %sysfunc(log(2)));
%let &M_Beta = &bb;
%let &M_alpha= %sysevalf(&BasePoints - &bb * %sysfunc(log(&BaseOdds)));
%mend;




/*******************************************************/
/* Macro GenSCDS */
/*******************************************************/
%macro GenSCDS(ParamDS, Lib, DVName, BasePoints, BaseOdds, PDO, SCDS);
/*
Generation of a scorecard dataset using the predictive model stored in ParamDS
The datasets are in the library LIB
*/
 
/* first, get alpha and beta from the base points and pdo */
%local alpha beta;
%let alpha=;
%let beta=;
%SCScale(&BasePoints, &BaseOdds, &PDO, alpha, beta);

/* read the model coefficients from the model dataset */

proc transpose data =&ParamDS out=temp_mpt;
run;


/* remove ignore variables and ln likeilhood value, and get the intercept */
%local Intercept;

data temp_mptc;
 set temp_mpt;
length VarName $32.;
length MapDS  $32.;
length WOEDS $32.;
if _Name_ eq 'Intercept' then do;
  call symput('Intercept', compress(&DVName));
  delete;
  end;
 /* Make all names upper case */
  *_Name_=upcase(_Name_);

 /* restore variable names, names of maps, WOE datasets */
  ix=find(upcase(_Name_),'_WOE')-1;
  if ix >0 then VarName=substr(_Name_,1,ix);
  MapDS=compress(VarName)||'_MAP';
  BinName=compress(VarName)||'_b';
  WOEDS=_Name_;
  Parameter=&DVName;

  if _Name_ ne '_LNLIKE_' and &DVName ne . ;
  keep VarName BinName MapDS WOEDS Parameter;
run;

/* Scorecard Base points = alpha + intercept * beta */
  %local SCBase; 
  %let SCBase = %sysfunc(int(&alpha + &beta * &Intercept));


%local i N;
data _null_;
 set temp_mptc;
  call symput('N',compress(_N_));
run;
%do i=1 %to &N;
 %local V_&i P_&i WOE_&i Map_&i;
%end;

/* Start merging the scorecard table */
data _null_;
 set temp_mptc;
  call symput('V_'||left(_N_),compress(VarName));
  call symput('B_'||left(_N_),compress(BinName));
  call symput('P_'||left(_N_),compress(Parameter));
  call symput('WOE_'||left(_N_),"&Lib.."||compress(WOEDS));
  call symput('Map_'||left(_N_),"&lib.."||compress(MapDS));
run;

proc sql noprint;
 create table &SCDS (VarName char(80), UL num, LL num,  Points num);
 insert into &SCDS values('_BasePoints_' , 0    , 0     ,  &SCBase);
run; quit;
%do i=1 %to &N;

   data temp1;
     set &&WOE_&i;
	   bin=&&B_&i;
	   VarName="&&V_&i";
	   ModelParameter=&&P_&i;
   run;

   proc sort data=temp1;
    by bin;
   run;
   /* check the type of the nominal variable */
	proc contents data=&&Map_&i out=temp_cont nodetails noprint;
	run;
	%local MapType;
	proc sql noprint; 
	 select Type into :MapType from temp_cont where upcase(Name)='CATEGORY';
	run; quit;
	%if &MapType =1 %then %do; /* numeric variable */
	 Data &&Map_&i;
	  set &&Map_&i;
	   N_category=Category;
	   drop category;
	 run;
	%end;

   proc sort data=&&Map_&i;
    by bin;
   run;

    data temp_v;
     merge temp1 &&Map_&i;
	  by bin;
	run;

	proc sort data=temp_v;
	 by VarName;
	run;

    proc sort data=&SCDS;
	 by VarName;
    run;

    data temp_all;
	 merge &&SCDS temp_v;
	  by VarName;
	run;

    Data &SCDS;
	  set temp_all;
	  drop &&B_&i;
	run;

%end;
/* Calculate the points and drop unnecessary varibles, 
   and setup the variable type for ease of generation of
   code: VarType 1 = continuous, 2=nominal string, 3=nominal numeric,
         0= Base Points */

data &SCDS;
  set &SCDS;
   if VarName = '_BasePoints_' then VarType=0;
   else do;
       Points=-WOE*ModelParameter * &beta ;
        if UL ne . and LL ne . then VarType=1;
          else if N_Category eq . then VarType=2;
	        else VarType=3;
	end;

   drop WOE bin ModelParameter;
run;

proc sort data=&SCDS;
 by VarType VarName;
run;



/* clean up workspace */
proc datasets library=work nodetails;
delete temp1 temp_all temp_cont temp_mpt temp_mptc temp_v;
run; quit;



%mend;



/*******************************************************/
/* Macro SCCCode */
/*******************************************************/
%macro SCCCode(SCDS,BasePoints, BaseOdds, PDO, IntOpt,FileName);
/* writing the scorecard generated by the scorecard dataset to an output
  file FileName generating C code
  If The option IntOpt=1 then we convert the points to integer values
  otherwise they are left as numbers */

/* direct the output to the filename */
proc sort data=&SCDS;
by VarType VarName;
run;

data _null_;
set &SCDS nobs=nx;
by VarType VarName;
file "&FileName";
length cond $300.;
length value $300.;
if _N_ =1 then do;
	put '/*********************************************/' ;
	put '/*********************************************/';
	put '/***** Automatically Generated Scorecard *****/';
	put '/*********************************************/';
	put '/**************     C CODE      **************/';
	put;
	put '/* Scorecard Scale : */';
	put "/*  Odds of [ 1 : &BaseOdds ] at  [ &BasePoints ] Points ";
    put "     with PDO of [ &PDO ] */";
	put; 
	put '/*********************************************/';
	put '/*********************************************/';
	put ;

	put '/*********************************************/';
	put '/*********************************************/';
	put;
	put '/****  Modify this part to input the data variables needed for  scoring ***/';
	put '/****  The implementation can be run within a for loop                  ***/';
	put;
	put '/*********************************************/';
	put '/* for (customer=0; customer<Total; customer++) */';
	put '/* {                                            */';
end; 

/* print the dataset RulesDS */


%if &IntOpt=1 %then xPoints=int(Points);
%else xPoints=Points; ;

if VarName="_BasePoints_" then do;
	put '/*********************************************/';
	put "/* Base Points   */";
	put '/*********************************************/';
    put "points=" xPoints ";";
                            end;
 else do;
   if first.VarName then do;
	put '/*********************************************/';
	put "/* Variable : " VarName "    *****/";
	put '/*********************************************/';
                      end;
    value= ")  points=points +("||compress(xPoints)||");";

    /* The rule */
    if VarType=1 then  do;/* continuous */
	if first.VarName then  cond='if( '||compress(VarName)||' <= ('||compress(UL) || ')'; 
	else if last.VarName then cond='if( '||compress(VarName)||' > ('|| compress(LL)||') ';
    else cond='if( '||compress(VarName)||' > ('|| compress(LL)||') && '||compress(VarName)||' <= ('||compress(UL) || ')'; 
                       end; 
    else if VarType=2 then /* nominal string */
	cond = 'if ('||compress(VarName)|| '==' || "'"||(compress(Category))||"'" ; 

	else /* nominal numeric */
	cond='if(' ||compress(VarName)|| '==' || compress(N_Category); 
	
	put "      " cond value;

 end;

	 if _N_=Nx then do;
			put '/* } */'; 
			put '/*************End of the scoring  Loop *******/';
			put;
	 end;
run;


%mend;





/*******************************************************/
/* Macro SCSQLCode */
/*******************************************************/
%macro SCSQLCode(SCDS,BasePoints, BaseOdds, PDO, IntOpt,FileName);
/* writing the scorecard generated by the scorecard dataset to an output
  file FileName generating SQL SELECT statement 
  If The option IntOpt=1 then we convert the points to integer values
  otherwise they are left as numbers */

/* direct the output to the filename */

proc sort data=&SCDS;
by VarType VarName LL;
run;

data _null_;
set &SCDS nobs=nx;
by VarType VarName LL;
file "&FileName";
length cond $300.;

if _N_ =1 then do;
	put '/*********************************************/' ;
	put '/*********************************************/';
	put '/***** Automatically Generated Scorecard *****/';
	put '/*********************************************/';
	put '/**************     SELECT Statement      **************/';
	put;
	put '/* Scorecard Scale : */';
	put "/*  Odds of [ 1 : &BaseOdds ] at  [ &BasePoints ] Points ";
    put "     with PDO of [ &PDO ] */";
	put; 
	put '/*********************************************/';
	put '/*********************************************/';
	put ;

	put '/*********************************************/';
	put '/*********************************************/';
	put;
	put '/****  Modify this code at the end to by adding the name of the  */';
	put '/****  the new score variable and the table name where these fields */';
	put '/****  would reside at time of deployment */';
	put;
	put '/*********************************************/';
    put;
    put 'SELECT (';
end; 

/* print the dataset RulesDS */


%if &IntOpt=1 %then xPoints=int(Points);
%else xPoints=Points; ;

if VarName="_BasePoints_" then do;
	put '/*********************************************/';
	put "/* Base Points   */";
	put '/*********************************************/';
    put "   "  xPoints ;
end;
else do;
   if first.VarName then do;
	put '/*********************************************/';
	put "/* Variable : " VarName "    *****/";
	put '/*********************************************/';
	put '+ (CASE ';
                      end;

    /* The rule */
    if VarType=1 then  do;/* continuous */
	if first.VarName then  cond='   WHEN '||compress(VarName)||' <= ('||compress(UL) || ') THEN ('||xPoints||')'; 
	else if last.VarName then cond='   ELSE ('||xPoints||')';
    else cond='   WHEN '||compress(VarName)||' > ('|| compress(LL)||') AND '||compress(VarName)||' <= ('||compress(UL) || ') THEN ('||xPoints||')'; 
                       end; 
    else if VarType=2 then do ; /* nominal string */
	if first.varName then cond = '   WHEN '||compress(VarName)|| '==' || "'"||(compress(Category))||"' THEN ("||xPoints||')' ; 
	else                  cond = '   ELSE ('||xPoints||')' ; 
						  end;
	else do;/* nominal numeric */
	if first.varName then cond='   WHEN ' ||compress(VarName)|| '==' || compress(N_Category)|| 'THEN ('||xPoints||')'; 
	else                  cond='   ELSE (' ||xPoints||')'; 
	     end;

	put "      " cond;

	if last.VarName then put '  END)';

 end;

	 if _N_=Nx then do;
	        put '  )';
			put ' AS    MyScore'; 
			put ' FROM  MyTable;';  
			put;
			put '/* Modify the variable name and the table to match the data schema */';
			put;
	 end;
run;


%mend;

/*******************************************************/
/* Macro SCSASCode */
/*******************************************************/
%macro SCSasCode(SCDS,BasePoints, BaseOdds, PDO, IntOpt,FileName);
/* writing the scorecard generated by the scorecard dataset to an output
  file FileName generating SAS code
  If The option IntOpt=1 then we convert the points to integer values
  otherwise they are left as numbers */

/* direct the output to the filename */

proc sort data=&SCDS;
by VarType VarName;
run;

data _null_;
set &SCDS nobs=nx;
by VarType VarName;
file "&FileName";
length cond $300.;
length value $300.;

if _N_ =1 then do;
	put '/*********************************************/' ;
	put '/*********************************************/';
	put '/***** Automatically Generated Scorecard *****/';
	put '/*********************************************/';
	put '/************    SAS CODE             ********/';
	put;
	put '/* Scorecard Scale : */';
	put "/*  Odds of [ 1 : &BaseOdds ] at  [ &BasePoints ] Points ";
    put "     with PDO of [ &PDO ] */";
	put; 
	put '/*********************************************/';
	put '/*********************************************/';
	put ;


	put '/********** START OF SCORING DATA STEP *******/';
	put '/*********************************************/';
	put '/*********************************************/';
	put;
	put 'DATA SCORING;        /********** Modify ************/';
	put ' SET ScoringDataset; /********** Modify ************/';
	put;
	put '/*********************************************/';
	put '/*********************************************/';
end; 

/* print the dataset RulesDS */


%if &IntOpt=1 %then xPoints=int(Points);
%else xPoints=Points; ;

if VarName="_BasePoints_" then do;
	put '/*********************************************/';
	put "/* Base Points   */";
	put '/*********************************************/';
put "Points=" xPoints ";";
                            end;
 else do;
   if first.VarName then do;
	put '/*********************************************/';
	put "/* Variable : " VarName "    *****/";
	put '/*********************************************/';
                      end;
    value= "  THEN  Points=Points +("||compress(xPoints)||");";

    /* The rule */
    if VarType=1 then  do;/* continuous */
	if first.VarName then  cond='IF '||compress(VarName)||' LE ('||compress(UL) || ') '; 
	else if last.VarName then cond='IF '||compress(VarName)||' GT ('|| compress(LL)||')';
    else cond='IF '||compress(VarName)||' GT ('|| compress(LL)||') AND '||compress(VarName)||' LE ('||compress(UL) || ') '; 
                       end; 
    else if VarType=2 then /* nominal string */
	cond = 'IF '||compress(VarName)||' = '|| quote(compress(Category)) ; 

	else /* nominal numeric */
	cond='IF '||compress(VarName)||' = ('|| compress(N_Category)||') '; 
	
	put "      " cond value;

 end;

 if _N_=Nx then do;
	put 'RUN;'; 
	put;
	put '/*************END OF SCORING DATA STEP *******/';
	put '/*********************************************/';
	end;
run;


%mend;

/*******************************************************/
/* Macro SCCSV */
/*******************************************************/
%macro SCCSV(SCDS,BasePoints, BaseOdds, PDO, IntOpt,FileName);
/* writing the scorecard generated by the scorecard dataset to an output
  file FileName generating CSV format readable by MS Excel
  If The option IntOpt=1 then we convert the points to integer values
  otherwise they are left as numbers */

/* direct the output to the filename */

proc sort data=&SCDS;
by VarType VarName;
run;

data _null_;
set &SCDS nobs=nx;
by VarType VarName;
file "&FileName";
length cond $300.;

if _N_ =1 then do;
	put 'Automatically Generated Scorecard , , , , , ';
	put ', , , , ,';
	put 'Scorecard Scale, , , , ';
	put "Odds, 1, to,  &BaseOdds ,  at , &BasePoints , Points ";
    put " PDO,  &PDO, , , , ";
	put', , , ,'; 
end; 

%if &IntOpt=1 %then xPoints=int(Points);
%else xPoints=Points; ;

if VarName="_BasePoints_" then do;
    put ' ,,,,,, Points ';
	put ' ,,,,,, =======';
	put "Base Points, ,,,,," xPoints;
                            end;
 else do;
   if first.VarName then do;
	put VarName ", , , ,";
	put '--------------, , , ,';
                      end;

    /* The rule */
    if VarType=1 then  do;/* continuous */
	if      first.VarName then  cond=',,,,<=,'||UL ; 
	else if  last.VarName then  cond=',,,,> ,'||LL ;
    else cond=',>,'|| compress(LL)||', AND , <=,'||UL ; 
                       end; 
    else if VarType=2 then /* nominal string */
	cond = ',,, '|| (compress(Category))|| ",,"; 

	else /* nominal numeric */
	cond=' ,, ,'|| compress(N_Category)|| ",,"; 
	
	put "      " cond ", " xPoints;

 end;

run;


%mend;



/*******************************************************/
/* The include folder */
/*******************************************************/
%let dir=C:\scorecardDev\Examples;
libname cc "&dir";

/* Load the credit card dataset */
%include "&dir.\CC_Dataset.sas";

/* Bin all continuous variables */
%EqWBinn(CreditCard, CustAge    , 5,CustAge_b    , temp , cc.CustAge_Map);
%EqWBinn(temp      , TmAtAddress, 5,TmAtAddress_b, temp1, cc.TmAtAddress_Map);
%EqWBinn(temp1     , CustIncome , 5,CustIncome_b , temp , cc.CustIncome_Map);
%EqWBinn(temp      , TmWBank    , 5,TmWBank_b    , temp1, cc.TmWBank_Map);
%EqWBinn(temp1     , AmBalance  , 5,AmBalance_b  , temp , cc.AmBalance_Map);
%EqWBinn(temp      , UtilRate   , 5,UtilRate_b   , temp1, cc.UtilRate_Map);

/* dummy grouping of nominal variables */
%dummyGrps(temp1,ResStatus,temp , cc.ResStatus_map);
%dummyGrps(temp ,empStatus,temp1, cc.empStatus_Map);
%dummyGrpn(temp1,OtherCC  ,temp , cc.OtherCC_Map);

/* Calculate the WOE for all independent variables */
%CalcWOE(temp ,  CustAge_b   , Status, cc.CustAge_WOE    , CustAge_WOE    , temp1);
%CalcWOE(temp1, TmAtAddress_b, Status, cc.TmAtAddress_WOE, TmAtAddress_WOE, temp );
%CalcWOE(temp ,  CustIncome_b, Status, cc.CustIncome_WOE , CustIncome_WOE , temp1);
%CalcWOE(temp1, TmWBank_b    , Status, cc.TmWBank_WOE    , TmWBank_WOE    , temp );
%CalcWOE(temp ,  AmBalance_b , Status, cc.AmBalance_WOE  , AmBalance_WOE  , temp1);
%CalcWOE(temp1, UtilRate_b   , Status, cc.UtilRate_WOE   , UtilRate_WOE   , temp );
%CalcWOE(temp , ResStatus_b  , Status, cc.ResStatus_WOE  , ResStatus_WOE  , temp1);
%CalcWOE(temp1, EmpStatus_b  , Status, cc.EmpStatus_WOE  , EmpStatus_WOE  , temp );
%CalcWOE(temp , OtherCC_b    , Status, cc.OtherCC_WOE    , OtherCC_WOE    , cc.CreditCard_WOE);

/***********************************************************/
/* develop a stepwise logistic regression model with the 
   woe variables and store the model parameters in a dataset */

%let VarList=CustAge_WOE   TmAtAddress_WOE CustIncome_WOE 
             TmWBank_WOE   AmBalance_WOE   UtilRate_WOE    
             ResStatus_WOE EmpStatus_WOE   OtherCC_WOE;
proc logistic data=cc.CreditCard_WOE
              OUTEST=cc.Model_Params ;
 model Status (event='1')=&VarList / 
           selection =stepwise  sls=0.05 sle=0.05;
run;

/* Generate the Scorecard Points dataset */
%let ModelDS=cc.Model_Params;
%let DVName=Status;
%let Lib=cc;
%let BasePoints=600;
%let BaseOdds=60;
%let PDO=20;
%let SCDSName=SCDS;
%GenSCDS(&MOdelDS,&Lib, &DVName, &BasePoints, &BaseOdds, &PDO, &SCDSName);

/* Use the scorecard points dataset to generate SAS code */
%let BasePoints=600;
%let BaseOdds=60;
%let PDO=20;
%let File=C:\scorecardDev\Examples\ScoreCard.sas;
%SCSasCode(SCDS,&BasePoints, &BaseOdds, &PDO, 1,&File);

/* and C code */
%let BasePoints=600;
%let BaseOdds=60;
%let PDO=20;
%let File=C:\scorecardDev\Examples\ScoreCard.c;
 %SCCCode(SCDS,&BasePoints, &BaseOdds, &PDO, 0,&File);

 /* and SQL code */
%let BasePoints=600;
%let BaseOdds=60;
%let PDO=20;
%let File=C:\scorecardDev\Examples\ScoreCard.SQL;
 %SCSQLCode(SCDS,&BasePoints, &BaseOdds, &PDO, 0,&File);

/* and CSV File to be read by MS Excel */
%let BasePoints=600;
%let BaseOdds=60;
%let PDO=20;
%let File=C:\scorecardDev\Examples\ScoreCard.CSV;
 %SCCSV(SCDS,&BasePoints, &BaseOdds, &PDO, 1,&File);

/*******************************************************/


/*******************************************************/
/* Clean all libraries and macros */
/*******************************************************/
title '';
proc catalog catalog=work.sasmacr force kill;  
run; quit;
proc datasets library=work nolist nodetails kill;
run; quit;
/* this will delete all datasets in the library cc */
proc datasets library=cc nolist nodetails kill;
run; quit;


/*******************************************************/
/*  End of the example */
/*******************************************************/
