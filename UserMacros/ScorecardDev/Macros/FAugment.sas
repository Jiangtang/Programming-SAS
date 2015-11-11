/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro FAugement */
/*******************************************************/

%macro FAugment(DsAccepts, DSRejects, StatusVar, ProbVar, DSIDVar, 
                Factor, WeightVar ,DSout, DSStats);

/* Fuzzy Augmentation */

data &DSout;
 set &DSAccepts(in=_acc) &DSRejects(in=_rej);
 if _rej then do;
   &StatusVar=1; &WeightVar=&Probvar;   &DSIDVar='Declined'; output;  /* inferred Bad */
   &StatusVar=0; &WeightVar=1-&Probvar; &DSIDVar='Declined'; output;  /* inferred Good */
             end;
 if _acc then do;
   &WeightVar=1; &DSIDVar='Accepted'; output;
            end;
 run;

/* generate statistics */
%local bad good AccBr RejBr AllBr;
proc sql noprint;
  select sum (&WeightVar) into :Bad from &DSOut where &StatusVar=1 and &DSIDVar='Accepted';
  select sum (&WeightVar) into :Good from &DSOut where &StatusVar=0 and &DSIDVar='Accepted';
	%let AccBr = %sysevalf(&Bad/(&Bad+&Good));

/* Bad rate for accepts */
select sum (&WeightVar) into :Bad from &DSOUt where &StatusVar=1 and &DSIDVar='Declined';
  select sum (&WeightVar) into :Good from &DSOut where &StatusVar=0 and &DSIDVar='Declined';
	%let RejBr1 = %sysevalf(&Bad/(&Bad+&Good));

/* Adjust the probabilities in the 'Declined' portion of the output dataset such that 
   the Bad Rate in them is Factor * Bad Rate in the Accepted */
/* The correction factor is calcualted from */
%let NewBR=%sysevalf(&Factor*&AccBr);
%let cf=%sysevalf(&NewBR * &good / (&bad - &NewBR * &Bad));
/* We apply this correction factor to the bads  */
update &DSOut set &WeightVar=&WeightVar* &cf where &StatusVar=1 and &DSIDVar='Declined';

/* Confirm the bad rate */

  select sum (&WeightVar) into :Bad from &DSOUt where &StatusVar=1 and &DSIDVar='Declined';
  select sum (&WeightVar) into :Good from &DSOut where &StatusVar=0 and &DSIDVar='Declined';
	%let RejBr2 = %sysevalf(&Bad/(&Bad+&Good));


/* Bad rate for the mix*/

  select sum (&WeightVar) into :Bad from &DSout where &StatusVar=1;
  select sum (&WeightVar) into :Good from &DSOut where &StatusVar=0;
	%let AllBr = %sysevalf(&Bad/(&Bad+&Good));

quit;

Data &DSStats;
length Statistic $30.;
Statistic ="Accepts  bad rate"; Value=&AccBr; output;
Statistic ="Rejects1 Bad rate"; Value=&RejBr1; output;
Statistic ="Rejects2 Bad rate"; Value=&RejBr2; output;
Statistic ="Total    bad rate"; Value=&AllBr; output;
run;

%mend;


