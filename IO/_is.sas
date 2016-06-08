%macro _is(dir);
	%local filrf VarList;
	%let rc=%sysfunc(filename(filrf,&dir));
	%let did=%sysfunc(dopen(&filrf));
	%let dcnt=%sysfunc(dnum(&did));
	
	%do i = 1 %to &dcnt;
		%let VarList = &VarList %sysfunc(dread(&did,&i));
	%end;
 
	%let rc=%sysfunc(dclose(&did));
	&VarList
%mend _is;

%*put %_is(c:\);
