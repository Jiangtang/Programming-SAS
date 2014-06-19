/*
Reading an External File (Self-Study)
	Steps to read from an external file:
	1. Assign a fileref using the FILENAME function.
	2. Open the file using the FOPEN function. 
	3. Use the FREAD and FGET functions to read the file.
	4. Close the file using the FCLOSE function.
*/

%macro read(infile=test.txt,lookfor=The write is done); 
	%local filrf textrc rc fid text; 
	%let rc=%sysfunc(filename(filrf,&infile)) ; 
	%let fid=%sysfunc(fopen(&filrf)) ; 

	%if &fid > 0 %then %do; 
		/* Go ahead with read */ 
		%if %sysfunc(fread(&fid))=0 %then %let textrc=%qsysfunc(fget(&fid,text,200)) ; 
		%let rc=%sysfunc(fclose(&fid)); 
	%end; 

	%if &textrc=0 and &fid > 0 and 	%superq(text)=%superq(lookfor) %then %put We can proceed.; 
	%else %put We must wait.; 
	%let rc=%sysfunc(filename(filrf)); 
%mend read; 
%read() 
