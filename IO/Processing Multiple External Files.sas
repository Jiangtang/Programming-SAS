/*
Processing Multiple External Files 
	1. Assign a fileref to the directory using the FILENAME function.
	2. Open the directory using the DOPEN function.
	3. Use the DNUM function toidentify how many members are in the directory.
	4. Use the DREAD function to extract each member name.
	5. Process the external files.
	6. Close the directory using the DCLOSE function.
*/

%macro readraw(dir=.); 
	%local fileref rc did dnum dmem memname; 
	%let fileref=thisdir; 
	%let rc=%sysfunc(filename(fileref,&dir)); 
	%let did=%sysfunc(dopen(&fileref)); 
	%let dnum=%sysfunc(dnum(&did)); 

	%do dmem=1 %to &dnum; 
		%let memname=%sysfunc(dread(&did,&dmem)); 

		%if %upcase(%scan(&memname,-1,.)) = DAT %then %do; 
			%let dataset=%scan(&memname,1,.); 

			data &dataset; 
				infile "&dir\&memname"; 
				input Course_Code $4. Location $15. Begin_Date date9. Teacher $25.; 
				format Begin_Date date9.; 
			run; 

			proc print data=&dataset; 
			title "%trim(&syslast)"; 
			run; 
		%end;
	%end; 

	%let rc=%sysfunc(dclose(&did)); 
	%let rc=%sysfunc(filename(fileref)); 
%mend readraw; 

options mprint; 

%readraw(dir=A:\sasDoc\webLiveCourse\1-Base\2Macro\amacr-SAS Macro Programming Advanced Topics-2006) 

/**/
