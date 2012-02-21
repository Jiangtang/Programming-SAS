/*Hadoop demo in Base SAS;*/
/*
http://www.jiangtanghu.com/blog/2011/10/04/map-and-reduce-in-mapreduce-a-sas-illustration/
;*/

data a;
	string="Hadoop";   *input;

	len=length(string);
	call symputx('len',len);	
run;

data b;
	set a;

	*capitalization: master method;
	STRING_master=upcase(string);

	*capitalization 1: Map;
	array str[&len] $;
	do i =1 to len;
		str[i]=upcase(substr(string,i,1));
	end;	

	*capitalization 2: Reduce;
	STRING_workers=catt("",of str1-str&len);

	drop len i;
run;

proc print data=b;
run;