/*
%compare_lib(%str(C:\Users\jhu\wrk1\), 
             %str(C:\Users\jhu\wrk2\));

*/

%macro _compare(file);
	title "Comparing *** &file. ***";

	proc compare data=lib1.&file compare=lib2.&file  MAXPRINT=32000;
	run;

	title;
%mend;

%macro compare_lib(dir1, dir2);

libname lib1 "&dir1";
libname lib2 "&dir2";


data _files1  ;
    length filename $200 ;
    rc=filename('temp',"&dir1") ;
    openid=dopen('temp') ;
    filenbr=dnum(openid) ;
    do i=1 to filenbr ;
        filename=dread(openid,i) ;
        if scan(upcase(filename),2) eq: 'SAS7BDAT' then do;            
            file=scan(filename,1) ;
            output;
        end;
    end;
	keep i file;
run;



data _null_; 
  set _files1; 
  call execute('%_compare('||trim(file)||')'); 
run;

libname lib1;
libname lib2;
%mend;



