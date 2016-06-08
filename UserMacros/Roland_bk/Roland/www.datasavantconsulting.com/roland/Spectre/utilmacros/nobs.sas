/*<pre><b>
/ Program   : nobs.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the number of observations in a
/             dataset or view. This will either be a positive integer or forced
/             to zero.
/ SubMacros : none
/ Notes     : If a where clause is specified or the dataset is really a view 
/             then to count the number of observations, a forced read is done 
/             of the dataset using NLOBSF which can be slow for large datasets.
/             The where clause should be specified using the normal data step
/             style. See usage notes.
/ Usage     : %put >>>>>> %nobs(sashelp.class) >>>>;
/             %put >>>>>> %nobs(sashelp.class(where=(sex="M"))) >>>>;
/             %put >>>>>> %nobs(sashelp.vtable) >>>>;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset name (pos) (a where clause modifier is allowed)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  12Feb07         "macro called" message added
/ rrb  07May08         Version 2.0 allows for a where clause modifier
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: nobs v2.0;

%macro nobs(ds);

  %local nobs dsid rc err;
  %let err=ERR%str(OR);

  %let dsid=%sysfunc(open(&ds));

  %*---- if open fails then file handle value is zero -----;
  %if &dsid EQ 0 %then %do;
    %put &err: (nobs) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;

  %*---- Open worked so check for an active where clause or a  ----;
  %*---- view and use NLOBSF in that case, otherwise use NOBS. ----;
  %else %do;
    %if %sysfunc(attrn(&dsid,WHSTMT)) or
      %sysfunc(attrc(&dsid,MTYPE)) EQ VIEW %then %let nobs=%sysfunc(attrn(&dsid,NLOBSF));
    %else %let nobs=%sysfunc(attrn(&dsid,NOBS));
    %*-- close the dataset --;
    %let rc=%sysfunc(close(&dsid));
    %*-- reset negative values to zero --;
    %if &nobs LT 0 %then %let nobs=0;
    %*-- return the result --;
&nobs
  %end;

%mend nobs;
