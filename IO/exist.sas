/*1-2 sas dataset*/
%macro printds(dset); 
	%if %sysfunc(exist(&dset)) %then %do; 
		proc print data=&dset (obs=10); 
		title1 "First 10 Observations from &dset"; 
		run; 
	%end; 
	%else %do; 
		%put Sorry, the data set &dset does not exist.; 
	%end; 
%mend printds;

%printds(sashelp.clas)

%printds(sashelp.class)



/*Terminating the Execution of a Macro*/

%macro printds(dset); 
	%if not %sysfunc(exist(&dset)) %then %do; 
		%put Sorry, &dset does not exist.; 
		%return;
	%end; 

	proc print data=&dset (obs=10); 
	title1 "First 10 Obs from &dset"; 
	run; 
%mend printds;

%printds(sashelp.clas)

%printds(sashelp.class)


/*2-2 sas external file*/

%macro viewfile(file); 
	%if %sysfunc(fileexist(&file)) %then %do; 
		proc fslist file="&file" ; 
		run; 
	%end; 
	%else %do; 
		%put Sorry, the file &file does not exist.; 
	%end; 
%mend viewfile;

%viewfile(raw2002.dat)

%viewfile(A:\sasDoc\webLiveCourse\1-Base\2Macro\amacr-SAS Macro Programming Advanced Topics-2006\raw2002.dat)

/**/
