
* xpt2_7dat ;
* by_FDA_SAS_macro;

%fromexp(A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_xpt_original,
A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_7dat_by_FDA_SAS_macro)


%fromexp(A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\analysis_xpt_original,
A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\analysis_7dat_by_FDA_SAS_macro)



* xpt2_7dat ;
* by_newExt_macro;

libname newET "A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_7dat_by_NewExt_macro";

filename ae "A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_xpt_original\ae.xpt";

%xpt2loc(libref=work,memlist=ae,filespec=ae);


options notes;

%let dir=A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_xpt_original;



options mlogic mprint symbolgen;

%macro xpt2dat(dir=A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_xpt_original,
todir=A:\sasDoc\SAS_TransportFile_V5\test\FDA_CDISCPILOT01_Data\tabulations_7dat_by_NewExt_macro);

libname newET "&todir";

/*get XML files list from OpenCDISC directory*/
filename XMLList pipe "dir /B &dir\*.xpt";

data XMLList;
	length XMLName $40;
	infile XMLList length=reclen;
	input XMLName $varying40. reclen;
run;

data _null_;
	set XMLList end=eof;
	II=left(put(_n_,2.));
	call symputx('XMLName'||II,compress(scan(XMLName,1,".")));
	if eof then call symputx('total',II);
run;

%put &total;


%do i=1 %to &total;
	%put &&XMLName&i;
	%put &&XMLName&i...xpt;

	filename &&XMLName&i "&dir.\&&XMLName&i...xpt";
	
	%xpt2loc(libref=newET,memlist=&&XMLName&i,filespec=&&XMLName&i);

%end;

%mend xpt2dat;




proc printto log="a:\test\log.log" new;
run; 	

%xpt2dat;

proc printto log=log;
run;

