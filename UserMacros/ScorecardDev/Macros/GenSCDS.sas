/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


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

