/*<pre><b>
/ Program   : cvarlens.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 01-May-2014
/ Purpose   : Function-style macro to return a list of character variables with
/             their lengths that can be used in a LENGTH statement.
/ SubMacros : none
/ Notes     : Dataset modifiers are not allowed. The character variables are
/             listed in the same order as they exist in the input dataset. If
/             there are no character variables in the dataset then a null string
/             is returned which will not cause a syntax problem if used in a
/             LENGTH statement. If the cvars= parameter is used then no checking
/             will be done to make sure any of the variables actually exist in
/             the input dataset. No action is taken for variables in the list
/             that are numeric.
/ Usage     : data test;
/               length %cvarlens(sashelp.class,name weight);
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name (no modifiers)
/ cvars             (pos) Optional limiting list of character variables you want
/                   the LENGTH attributes for (separated by spaces - case is not
/                   important).
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  01May14         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: cvarlens v1.0;

%macro cvarlens(ds,cvars);
  %local dsid rc nvars i cvarlens err varname vartype varlen;
  %let err=ERR%str(OR);
  %let cvars=%upcase(&cvars);
  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (cvarlens) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let nvars=%sysfunc(attrn(&dsid,nvars));
    %if &nvars LT 1 %then %put &err: (cvarlens) No variables in dataset &ds;
    %else %do;
      %let cvarlens=;
      %do i=1 %to &nvars;
        %let varname=%sysfunc(varname(&dsid,&i));
        %let vartype=%sysfunc(vartype(&dsid,&i));
        %let varlen=%sysfunc(varlen(&dsid,&i));
        %if &vartype EQ C %then %do;
          %if not %length(&cvars) or %sysfunc(indexw(&cvars,%upcase(&varname)))
            %then %let cvarlens=
            %sysfunc(strip(%sysfunc(compbl(&cvarlens &varname $ &varlen))));
        %end;
      %end;
    %end;
    %let rc=%sysfunc(close(&dsid));
  %end;
&cvarlens
%mend cvarlens;
