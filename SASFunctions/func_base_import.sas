data test;
length a $1024;
    infile "C:\Users\jhu\Documents\GitHub\Programming-SAS\SASFunctions\aaa.txt" lrecl=1024;

    input a $;
    a=_infile_;

run;

data t;
	set test;
	func=scan(a,1,"(");

	if scan(func,1)="call" then tmp=scan(func,2);
	else tmp=func;
run;

proc sort data=t out=t1;
	by tmp;
run;

data t2;
	set t1;
	by tmp;

	file "C:\Users\jhu\Documents\GitHub\Programming-SAS\SASFunctions\export.txt";

	retain seq;
	if first.tmp then seq=1;
	else seq=seq+1;

	if seq=1 then sq="";
	else sq=put(seq,1.);

	function=cats(tmp,sq);

	length rule $250.;

	*rule2=catx("","{ ",'"trigger":','"',function,'",','"contents":','"',a,'"},');
	rule=cats("{ ",'"trigger":','"',function,'",','"contents":','"',a,'"},');

	put rule;

run;


