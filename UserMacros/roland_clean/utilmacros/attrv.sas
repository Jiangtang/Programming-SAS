/*<pre><b>
/ Program   : attrv.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : Function-style macro to return a variable attribute
/ SubMacros : none
/ Notes     : This is a low-level utility macro that other shell macros will
/             call. The full list of variable attributes can be found in the
/             SAS documentation. The most common ones used will be VARTYPE,
/             VARLEN, VARLABEL, VARFMT and VARINFMT.
/
/             This macro will only work correctly for datasets (i.e. not views)
/             and where there are no dataset modifiers.
/
/ Usage     : %let vartype=%attrv(dsname,varname,vartype);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset name (pos) (do not use views or dataset modifiers)
/ var               Variable name (pos)
/ attrib            Attribute (pos)
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  13Feb07         "macro called" message added
/ rrb  30Jul07         Header tidy
/ rrb  17Dec07         Header tidy
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: attrv v1.0;

%macro attrv(ds,var,attrib);
  %local dsid rc varnum err;
  %let err=ERR%str(OR);
  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (attrv) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let varnum=%sysfunc(varnum(&dsid,&var));
    %if &varnum LT 1 %then %put &err: (attrv) Variable &var not in dataset &ds;
    %else %do;
%sysfunc(&attrib(&dsid,&varnum))
    %end;
    %let rc=%sysfunc(close(&dsid));
  %end;
%mend attrv;
