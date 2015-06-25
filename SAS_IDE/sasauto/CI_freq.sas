/*
%CI_freq(r=81,n=263)

*/



%macro CI_freq(r=,n=,out=_CI);

data _test;
	outcome = "f";
	count = &r;
	output;

	outcome = "u";
	count = %eval(&n - &r);
	output;
;
run;


ods select none;
ods output BinomialCLs=_CI1 (drop =table  );
proc freq data=_test;
	tables outcome / binomial (CL=
							   AGRESTICOULL
							   BLAKER
							   CLOPPERPEARSON
							   JEFFREYS
							   LIKELIHOODRATIO
							   LOGIT
							   MIDP
							   WALD
							   WILSON	   
						     
							  );
	weight Count;
run;


ods output BinomialCLs=_CI2 (drop =table  );
proc freq data=_test; 
    tables outcome / binomial (CL = 							  
							  WALD(CORRECT)
							  WILSON(CORRECT) 
							  ); 
    weight Count; 
run;

ods select all; 

data &out;
	set _CI1 _CI2;
	p_CI=compress(catx("","[",put(round(LowerCL,0.0001),6.4),", ",put(round(UpperCL,0.0001),6.4),"]"));
	keep type Proportion p_CI;
run;

title "Confidence Intervals for Single Proportion";
title2 "by &SYSSCP SAS &SYSVLONG, PROC FREQ, r = &r, n = &n";

proc print data=&out;
run;
title;
%mend CI_freq;

