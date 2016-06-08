
/**********************************************/
/* To compute if no observation in dataset ds */
/*http://support.sas.com/kb/24/671.html*/
/**********************************************/
%macro obsnvars(ds);
   %global nobs;
   %let dset=&ds;
   %let dsid = %sysfunc(open(&dset));
   %if &dsid %then
      %do;
         %let nobs =%sysfunc(attrn(&dsid,NOBS));
         %let rc = %sysfunc(close(&dsid));
      %end;
   %else
      %put Open for data set &dset failed - %sysfunc(sysmsg());
%mend obsnvars;
