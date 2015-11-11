%global value;
%let value = 1;
%macro cal_n(n);

%if &n = 0 %then %return ;
%else %do;
	 %let value = %eval(&value * &n);
	 %cal_n(%eval(&n - 1));
%end;
%mend cal_n;

%cal_n(10);
%put value = &value;