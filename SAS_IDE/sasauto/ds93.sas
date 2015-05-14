/*EXTENDOBSCOUNTER*/
%macro ds93(librf);  
  %let librf = %upcase(&librf);

  proc sql noprint;
    select left(put(count(*),8.)) into :numds
    from dictionary.tables
    where libname="&librf";

    select memname into :ds1 - :ds&numds
    from dictionary.tables
    where libname="&librf";

  %do i=1 %to &numds;

     data &librf..&&ds&i;
        set &librf..&&ds&i;

        run;
  
  %end; 


%mend ds93;	
