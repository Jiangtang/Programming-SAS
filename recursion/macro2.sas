%global value;
%let value = 1;

%macro fact(n);
%if &n = 0 %then %return ;
%else %do;
	 %let value = %eval(&value * &n);
	 &n*%fact(%eval(&n - 1));
%end;
%mend fact;

%fact(8);
%put value = &value;
