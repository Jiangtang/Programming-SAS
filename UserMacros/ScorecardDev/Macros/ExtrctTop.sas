/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/


/*******************************************************/
/* Macro : ExtrctTop */
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
