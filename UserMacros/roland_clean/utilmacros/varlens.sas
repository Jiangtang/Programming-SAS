/*<pre><b>
/ Program   : varlens.sas
/ Version   : 2.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-May-2014
/ Purpose   : Function-style macro to return a list of variables with their
/             lengths than can be used in a LENGTH statement.
/ SubMacros : none
/ Notes     : Dataset modifiers are not allowed. The variables are listed in the
/             same order as they exist in the input dataset. If the vars=
/             parameter is used then no checking will be done to make sure any
/             of the variables actually exist in the input dataset.
/ Usage     : data test;
/               length %varlens(sashelp.class, weight xxxx  name);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name (no modifiers)
/ vars              (pos) Optional limiting list of variables you want the
/                   LENGTH attributes for (separated by spaces - case is not
/                   important).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Apr14         New (v1.0)
/ rrb  01May14         vars= parameter added (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: varlens v2.0;

%macro varlens(ds,vars);
  %local dsid rc nvars i varlens err varname vartype varlen dollar;
  %let err=ERR%str(OR);
  %let vars=%upcase(&vars);
  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (varlens) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let nvars=%sysfunc(attrn(&dsid,nvars));
    %if &nvars LT 1 %then %put &err: (varlens) No variables in dataset &ds;
    %else %do;
      %let varlens=;
      %do i=1 %to &nvars;
        %let varname=%sysfunc(varname(&dsid,&i));
        %let vartype=%sysfunc(vartype(&dsid,&i));
        %let varlen=%sysfunc(varlen(&dsid,&i));
        %if &vartype EQ C %then %let dollar=$;
        %else %let dollar=;
        %if not %length(&vars) or %sysfunc(indexw(&vars,%upcase(&varname)))
         %then %let varlens=
          %sysfunc(strip(%sysfunc(compbl(&varlens &varname &dollar &varlen))));
      %end;
    %end;
    %let rc=%sysfunc(close(&dsid));
  %end;
&varlens
%mend varlens;
