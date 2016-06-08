/*Reading Multiple Data Set Values */

%macro course_info(condition=1); 
	%local dsid rc fname lname; 

	%let dsid=%sysfunc(open(perm.courses(where=(&condition)) )); 

	%syscall set(dsid); 

	%if %sysfunc(fetch(&dsid))=0 %then %do; 
		%let feefmt=%sysfunc(putn(&Fee,dollar12.2)); 
		&Days-day &Course_Title course costing &feefmt 
	%end; 
	%else **unknown**; 

	%let rc=%sysfunc(close(&dsid)) ; 
%mend course_info; 

/* Generate Subset Report with Dynamic Title */ 
/* Obtain Days, Course_Title and Fee from perm.courses */ 
/* where Course_Code eq "&crsid" */ 

%let crsid=C002; 

proc print data=perm.schedule noobs label; 
	where Course_Code eq "&crsid"; 
	var Location Begin_Date Teacher; 
	title1 "Schedule for %course_info(condition=Course_Code eq '&crsid')"; 
run; 
