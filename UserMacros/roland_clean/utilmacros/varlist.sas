/*<pre><b>
/ Program   : varlist.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-May-2014
/ Purpose   : Function-style macro to return a list of variables in a dataset
/ SubMacros : none
/ Notes     : Variable names will be in uppercase. Variables will be listed in
/             the same order as they occur in the dataset.
/ Usage     : %let varlist=%varlist(dsname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name (no modifiers)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/ rrb  01May14         Initialised varlist macro variable and updated the header
/                      (v1.1)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: varlist v1.1;

%macro varlist(ds);
  %local dsid rc nvars i varlist err;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (varlist) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let nvars=%sysfunc(attrn(&dsid,nvars));
    %if &nvars LT 1 %then %put &err: (varlist) No variables in dataset &ds;
    %else %do;
      %let varlist=;
      %do i=1 %to &nvars;
        %if %length(&varlist) EQ 0 %then %let varlist=%sysfunc(varname(&dsid,&i));
        %else %let varlist=&varlist %sysfunc(varname(&dsid,&i));
      %end;
    %end;
    %let rc=%sysfunc(close(&dsid));
  %end;
&varlist
%mend varlist;
