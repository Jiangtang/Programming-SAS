%macro varexist
/*----------------------------------------------------------------------
Check for the existence of a specified variable.
----------------------------------------------------------------------*/
(ds        /* Data set name */
,var       /* Variable name */
);
 
/*----------------------------------------------------------------------
Usage Notes:
 
%if %varexist(&data,NAME)
  %then %put input data set contains variable NAME;
 
The macro calls resolves to 0 when either the data set does not exist
or the variable is not in the specified data set.
----------------------------------------------------------------------*/
%local dsid rc ;
 
%*----------------------------------------------------------------------
Use SYSFUNC to execute OPEN, VARNUM, and CLOSE functions.
-----------------------------------------------------------------------;
%let dsid = %sysfunc(open(&ds));
 
%if (&dsid) %then %do;
  %if %sysfunc(varnum(&dsid,&var)) %then 1;
  %else 0 ;
  %let rc = %sysfunc(close(&dsid));
%end;
%else 0;
 
%mend varexist;
