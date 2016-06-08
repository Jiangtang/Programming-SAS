/*
Obtaining Attribute Information
	1. open the data set using the OPEN function
	2. retrieve a numeric attribute using the ATTRN function 
	3. retrieve a character attribute using the ATTRC function
	4. close the data set using the CLOSE function.

*/


/*toDo
macro function
%open
%attrn
%attrc
%close

*/


%let dset=perm.students; 
%let dsid=%sysfunc(open(&dset)); 
%let nobs=%sysfunc(attrn(&dsid,nlobs)); 
%let crdate=%sysfunc(attrn(&dsid,crdte),datetime18.); 

%put &dsid &nobs;

%let dsid=%sysfunc(close(&dsid));
%put &dsid;

proc print data=&dset (obs=10) noobs; 
	title1 "First 10 Observations from &dset"; 
	title2 "(Created &crdate with &nobs total obs)"; 
run;
