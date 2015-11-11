/*******
  Credit Risk Scorecards: Development and Implementation using SAS
  (c)  Mamdouh Refaat
********/

/*******************************************************/
/* Macro BSWeight
/*******************************************************/
%macro BSWeight(PopDS, SDS, DVVar, WTVar, DSout);
/* This macro calculates the weight variable values for the 
sample SDS taken from the population POPDS using the dependent variable
DVVAR. The wieghts are added to the sample dataset in the variable
WTVar. The results are written to the output dataset DSout (which
could be SDS itself).
*/
%local N P M Q;
/* Calculate N, P of the population and that of sample*/
proc sql noprint;
 select count(*)into : N from &PopDS;		/* Size of population */
 select count(*) into : P from &PopDS where &DVVar=1; /* count of "1" */

select count(*)into : M from &SDS;		/* Size of sample */
 select count(*) into : Q from &SDS where &DVVar=1; /* count of "1" */
run;
 quit;
 /* calculate the weight for Bad (1) and Good (0) W1, W0*/
%local W1 W0 denom;
%let denom=%sysevalf( (&P/&N)/(&Q/&M) + ((&N-&P)/&N)/((&M-&Q)/&M) ) ;
%let W1=%sysevalf( (&P/&N)/&denom  );
%let W0=%sysevalf( 1-&W1) ;

/* add the weight variable to the sample dataset */
data &DSout;
 set &SDS;
if DV=1 then &WTVar =&W1;
else &WTVar=&W0;
run;
%mend;

