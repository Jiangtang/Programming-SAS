data a;
	a=3.99999999999;
run;
proc print;
run;

/**********f_point**********/
data f_point;
	x=-255.75;
	put x=binary64.;
run;
data f_point2;
	a=1;
	b=2;
	c=0.1;
	d=0.5;
	put a=binary64. b=binary64. c=binary64. d=binary64.;
run;

/**********integer**********/
data int1;
	length a b c 3;
	a=8191;
	b=8192;
	c=8193;	
/*	put a=binary64. b=binary64. c=binary64.;*/
run;

data int2;
	length x 3;
	x=81933;
	y=81933;
/*	z=81920;*/
/*	put x=binary64. y=binary64. z=binary64.;*/
run;

/**********fraction**********/
data fra_p;
	a=0.1;
	b=a*3;
	if b=0.3 then put "EQUAL";
	else do;
		diff=b-0.3;
		put "UNEQUAL";
		put diff=;
	end;
run;

data fra_r;
	a=0.1;
	put a=binary64.;
run;

data fra_s;
	a=0.1;
	b=a*3;
	if round(b,0.0001)=0.3 then put "EQUAL";
	else do;
		diff=b-0.3;
		put "UNEQUAL";
		put diff=;
	end;
run;

/**********exception**********/
data ex1;
	length a 3;
	a=16384;
	b=16384;
/*	put a=binary64.;*/
run;
data ex2;
	a=0.25;
	b=a*10;
	if b=2.5 then put "EQUAL";
	else do;
		diff=b-2.5;
		put "UNEQUAL";
		put diff=;
	end;
/*	put a=binary64.;*/
run;

/**********gmt**********/
data gmt;
	test1=40;test2=80;test3=160;test4=320;
run;
data gmt1(drop=test:);
	set gmt;
	baseline=10**mean(log10(test1),log10(test2));
	result=10**mean(log10(test3),log10(test4));
	fold=result/baseline;
	diff=fold-4;
	fourfold=(fold>=4);
run;
data gmt2(drop=test:);
	set gmt;
	baseline=(test1*test2)**(1/2);
	result=(test3*test4)**(1/2);
	fold=result/baseline;
	diff=fold-4;
	fourfold=(fold>=4);
run;



data ex_trunc;
  length x 3;
  x=1/5;
/*  if x eq 1/5 then */
/*     put 'IN TEST2: x eq 1/5';*/
/*  if x ne trunc(1/5,3) then */
/*     put 'IN TEST2: x ne trunc(1/5,3)';*/
run;
data ex_trunc2;
  set ex_trunc;
  if x ne 1/5 then 
     put 'IN TEST2: x ne 1/5';
  if x eq trunc(1/5,3) then 
     put 'IN TEST2: x eq trunc(1/5,3)';
run;
