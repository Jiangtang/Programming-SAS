*******************************************************************************************************************;
*Program    Name    : SAS_Blogs.sas                                                                               *;
*Programmer Name	: Jiangtang Hu                                                                                *;
*                     Jiangtanghu@gmail.com                                                                       *;
*                     Jiangtanghu.com/blog                                                                        *;
*Date		        : 20Jul2011                                                                                     *;
*******************************************************************************************************************;

%let URL=http://blogs.sas.com/iml/index.php?/archive;

/*read archive page;*/
filename archive URL "&URL";

data archive; 
	length text $1024;
    infile archive lrecl=1024; 
	input text $; 
	text= _infile_; 
	if index(text, ">view topics<") then output;
run;

data  archive1;
	set archive;
	summary=scan(text,4,'"');
run;

/*read all topics pages;*/
data _null_;
	set  archive1 end=eof;
	I+1;
	II=left(put(I,2.));
	call symputx('summary'||II,summary);
	if eof then call symputx('total',II);
run;

%macro readit;
	%do i=1 %to &total;
		filename f&i URL "&&summary&i";	

		data f&i;
			length text $1024;
		    infile f&i lrecl=1024; 
			input text $; 
			text= _infile_; 
			if index(text, "/iml/index.php?/archives/") or index(text, "posted_by_date") then output;
		run;

	/*remove HTML tags*/
	data ff&i;
		set f&i;  
		prx=prxparse("s/<.*?>//");
	  	call prxchange(prx,99,text);
		drop prx;

		flag=ifn(mod(_n_,2),1,2);
		grpn=&i;
		if index(text,"201") and length(text)<10 then delete;/*hard coding!;*/
		seq=_n_;
	 run;

	 data fff&i;
	 	set ff&i;
		by grpn seq flag;

		retain title;
		if first.flag then title=lag(text);
		if flag=1 then delete;
	 run;

	%end;

%mend readit;
%readit

%macro getall;
	data Rick;
		set %do i=1 %to &total; fff&i %end; ;
		seq=seq/2;	
		drop flag;
	run;	
%mend getall;
%getall

data rick2;
	set rick;

	datetime=scan(text,2,",");     *July 19. 2011;
	year=scan(text,2,".");         *2011;
	month=scan(scan(text,2,","),1);*July;
	day=scan(scan(text,2,","),2);  *19;	
    week=scan(text,6);             *Tuesday;
		
	dt=compress(catx("",day,substr(month,1,3),year));  *19Jul2011;
	worddat=input(dt,date9.);                         
	format worddat  ddmmyy10.;                         *19/07/2011;

	m=scan(put(worddat,ddmmyy10.),2);                  *07;
	my=compress(catx("",year,m));                      *201107;
run;

proc sort ;
	by  worddat descending seq ;
run;

/*get all calendar dates;*/
proc sort data=rick2 out=rick3 nodupkey;
	by my;
run;

data _null_;
	set rick3 end=eof;
	I+1;
	II=left(put(I,2.));
	call symputx('year'||II,year);
	call symputx('month'||II,m);
	if eof then call symputx('total',II);
run;

%macro getCalendar;
	%do i=1 %to &total;
		data calendar&i;
		    date1 = mdy (&&month&i,1,&&year&i);
		    date2 = intnx ('month', date1, 1) - 1;

		    do worddat = date1 to date2;
			      wim = intck ('week', date1, worddat);
			      dim = worddat-date1+1;				
			      output;
		    end;

			format worddat  ddmmyy10.;			
			keep   worddat  dim ;
	  run; 
	%end;
%mend getCalendar;
%getCalendar;

%macro allCalendar;
	data Calendar;
		set %do i=1 %to &total; calendar&i %end; ;	
	run;	
%mend allCalendar;
%allCalendar


/*add holiday;*/
filename hld url "http://jiangtanghu.com/docs/en/US_holiday.sas";

%include hld; 

%US_holiday(2010)
%US_holiday(2011) 

data holiday;
    set holiday2010 holiday2011;
run;

proc sort ;
    by  worddat;
run;

/*put all together;*/
data rick_all;
    merge rick2 calendar holiday;
    by worddat;
    today=today(); 

    if worddat <'03Sep2010'd then delete;     
    if worddat >today then delete; 
    drop today;
run;