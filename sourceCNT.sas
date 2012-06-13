
/*
http://blog.clinovo.com/megha-becomes-the-third-time-winner-june-programming-challenge-now-is-finished/
*/

/*version I*/
%let _=%sysfunc(time());

filename _ temp;

data _null_;
	infile 'dir/s/b "C:\Program Files\SASHome\*.sas"|findstr/v "sas7 sas~"' pipe end=EOF;
	input;
	if _n_=1 then call execute('proc printto log=_ new;');
	call execute('data _null_; infile "'||_infile_||'"; input;');
	if EOF then call execute('proc printto log=log;');
run;

data _null_;
	retain s;
	x=prxparse('/(\d+) records were read from the infile/');
	infile _ end=EOF;
	input;
	if prxmatch(x,_infile_) then s+input(prxposn(x,1,_infile_),best.);
	if EOF then put s=;
run;

%put %sysevalf(%sysfunc(time())-&_);


/*version II*/

%let _=%sysfunc(time());

data _null_; 
infile 'for /f "tokens=* usebackq" %f in (`dir/s/b "C:\Program Files\SASHome\*.sas"^|findstr /i /v "sas7 sas~"`) do @type "%f"' pipe;
input;
run;


%put %sysevalf(%sysfunc(time())-&_);
