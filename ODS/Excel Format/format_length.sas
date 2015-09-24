%global ct_list  ct_len ;

 ods output variables = _varlist;
   proc contents data = sashelp.class ; 
   run;

    proc sort data = _varlist;
      by  num;
   run;

   data _varlist;
      set _varlist;
      len_var = length(variable);
      len_lab = length(label);
      max_len = max(of len:);
   run;


    proc sql;
      select variable into: var_list separated by ' '
      from _varlist
      ;
      select max_len into: len_list separated by ','
      from _varlist
      ;
   quit;

   %put &var_list;
      %put &len_list;
/*
	http://www.sasanalysis.com/2011/05/make-excel-spreadsheet-for-reporting.html
absolute_column_width="&len_list"
*/
ods listing close;
	  %let inct=sashelp.class;

	 	    ods output variables =_ctlist;
	    proc contents data = &inct ; 
	    run;

		proc sort data=_ctlist;
			by num;
		run;

		data _null_;
			set _ctlist end=eof;
			i+1;
			II=left(put(i,2.));
			call symputx('ctvar'||II,Variable);
			if eof then call symputx('ctn',II); 

			if type = 'Char' then call symputx('ctfmt'||II,"text");
			else call symputx('ctfmt'||II,"0");
		run;


%put _user_;


		%macro doit;
		%global ctlen _ctlen;
			%do i=1 %to &ctn;				
				proc sql;	
					select max(max(%length(&&ctvar&i)),max(length(&&ctvar&i)))into:ctlen&i
					from &inct
					;
				quit;
				%let _ctlen = &_ctlen.&&ctlen&i;
				
			%end;

			%let ctlen1 = %qt(l=&_ctlen,osep=%str(,));
			%let ctlen2 = %uqt(lv=ctlen1, lsep=%str(,));
			%let ctlen  = %changesep(lv=ctlen2, lsep=%str( ),osep=%str(,));
		%mend;

		%doit

%put &_ctlen;
%put &ctlen;





%SYMDEL ctlen _ctlen;

/*

order of options
proc print numvar
proc contents noprint

*/

options validvarname=any ;
%let name1=a @ b ;
data x;
set sashelp.class ;
rename name=%sysfunc(quote(&name1))n ;
run;

proc sql ;
CREATE TABLE A AS
select max(length(strip(put(%sysfunc(quote(HEIGHT))n,best32.)))) as LEN
from x
;
quit;
