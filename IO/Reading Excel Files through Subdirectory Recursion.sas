/*Reading Excel Files through Subdirectory Recursion

*/

%macro readraw(dir=.); 
	%local fileref rc did dnum dmem memname; 
	%put NOTE: Looking for Excel files in &dir folder...; 

	%let rc=%sysfunc(filename(fileref,&dir)); 
	%let did=%sysfunc(dopen(&fileref)); 
	%let dnum=%sysfunc(dnum(&did)); 

	%do dmem=1 %to &dnum; 
		%let memname=%sysfunc(dread(&did,&dmem)); 
		%if %upcase(%scan(&memname,-1,.)) = XLS %then %do; 
			proc import out=work.%scan(&memname,1,.) 
				datafile="&dir\&memname" 
				dbms=excel replace; 
				getnames=yes; 
				mixed=no; 
				scantext=yes; 
				usedate=yes; 
				scantime=yes; 
			run; 
			
			proc print data=work.%scan(&memname,1,.) (obs=5); 
				title "Data imported from &dir\&memname"; 
			run; 
		%end; 
		%else %if %scan(&memname,2,.)= %then %readraw(dir=&dir\&memname) ; 
	%end; 

	%let rc=%sysfunc(dclose(&did)); 
	%let rc=%sysfunc(filename(fileref)); 
%mend readraw;
 
options mprint; 

%readraw(dir=c:\workshop\winsas)
