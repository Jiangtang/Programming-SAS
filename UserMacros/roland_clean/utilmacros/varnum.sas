/*<pre><b>
/ Program   : varnum.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return the variable position in a dataset
/             or 0 if not in dataset.
/ SubMacros : none
/ Notes     : Since only 0 or a positive integer is returned you can use this
/             like a truth statement such as %if %varnum(dsname,varnam) %then...
/ Usage     : %let varnum=%varnum(dsname,varname);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name
/ var               (pos) Variable name
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: varnum v1.0;

%macro varnum(ds,var);
  %local dsid rc varnum err;
  %let varnum=0;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (varnum) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let varnum=%sysfunc(varnum(&dsid,&var));
    %let rc=%sysfunc(close(&dsid));
  %end;
&varnum
%mend varnum;
