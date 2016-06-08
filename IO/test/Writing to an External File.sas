/*Writing to an External File
	1. Assign a fileref using the FILENAME function.
	2. Open the file using the FOPEN function.
	3. Use the FPUT and FWRITE functions to write text.
	4. Close the file using the FCLOSE function.

*/


%macro write; 
	%local filrf rc fid; 
	%let filrf=myfile; 

	/* Assigning the fileref */ 
	%let RC=%sysfunc(filename(filrf,test.txt)); 

	/* Opening the external file */ 
	%let fid=%sysfunc(fopen(&filrf,output)); 

	/* Preparing the write */ 
	%let RC=%sysfunc(fput(&fid,The write is done)); 

	/* Performing the write */ 
	%let RC=%sysfunc(fwrite(&fid)); 

	/* Closing the file */ 
	%let RC=%sysfunc(fclose(&fid)); 

	/* Clearing the fileref */ 
	%let RC=%sysfunc(filename(filrf)); 

	proc fslist file="test.txt"; 
	run; 
%mend write; 
%write 
