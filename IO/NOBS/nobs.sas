%macro nobs(ds);
	%put >>>>>  Running &SYSMACRONAME;
    %local nobs;
    %let dset=&ds;

 %let dsid = %sysfunc(open(&dset));                                              
 %if &dsid %then %do;
      %let nobs =%sysfunc(attrn(&dsid,nobs));
      %let nvars=%sysfunc(attrn(&dsid,nvars));
      %let rc = %sysfunc(close(&dsid));
 %end;
 %else %put ERROR: open for data set &dset failed - %sysfunc(sysmsg());
 &nobs;
%mend nobs;