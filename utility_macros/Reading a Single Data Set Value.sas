/*
Reading a Single Data Set Value (Self-Study) 
	1. open the data set using the OPEN function
	2. obtain a variable’s position using the VARNUM function
	3. read an observation using the FETCH function
	4. obtain a numeric value using the GETVARN function
	5. obtain a character value using the GETVARC function
	6. close the data set using the CLOSE function.
*/

%macro lookup(dsn,var,condition=1,format=best12.); 
	%local dsid rc varnum vartype value; 
	%let dsid=%sysfunc(open(&dsn (where=(&condition)) )); 
	%let varnum=%sysfunc(varnum(&dsid,&var)) ; 
	%let vartype=%sysfunc(vartype(&dsid,&varnum)) ; 

	%if %sysfunc(fetch(&dsid))=0 %then %do; 
		%if &vartype=C %then %let value=%sysfunc(getvarc(&dsid,&varnum)); 
		%else %let value=%sysfunc(getvarn(&dsid,&varnum),&format); 
		&value 
	%end; 
	%else **unknown**; 
	%let rc=%sysfunc(close(&dsid)) ; 
%mend lookup ; 

/* Generate Subset Report with Dynamic Title */ 
/* Obtain Days, Course_Title and Fee from perm.courses */ 
/* where Course_Code eq "&crsid" */ 

%let crsid=C002; 

proc print data=perm.schedule noobs label; 
	where Course_Code eq "&crsid"; 
	var Location Begin_Date Teacher; 

	%let cname=%lookup(perm.courses,Course_Title, 

	condition=Course_Code eq "&crsid"); 

	%let cfee=%lookup(perm.courses,Fee, condition=Course_Code eq "&crsid",format=dollar12.2); 

	%let cdays=%lookup(perm.courses,Days,condition=Course_Code eq "&crsid", format=1.); 
	title1 "Schedule for &cdays-day &cname course costing &cfee"; 
run;
