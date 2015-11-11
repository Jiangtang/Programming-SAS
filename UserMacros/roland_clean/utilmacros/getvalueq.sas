/*<pre><b>
/ Program   : getvalueq.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 15-Sep-2012
/ Purpose   : Function-style macro to return a variable's value
/ SubMacros : none
/ Notes     : By default, character strings are returned in double quotes.
/             Use the macro %getvalue if you do not want character strings
/             returned in double quotes by default.
/ Usage     : %let value=%getvalueq(dsname,varname,1);
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                Dataset name (pos)
/ var               Variable name (pos)
/ obs               Observation number (pos). Defaults to 1.
/ usequotes=yes     By default, put character string in double quotes. Use the
/                   %getvalue macro if you do not want strings to be quoted.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  15Sep12         new (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: getvalueq v1.0;

%macro getvalueq(ds,var,obs,usequotes=yes);

  %local dsid rc varnum value err;
  %let err=ERR%str(OR);

  %if not %length(&usequotes) %then %let usequotes=yes;
  %let usequotes=%upcase(%substr(&usequotes,1,1));

  %if not %length(&obs) %then %let obs=1;


  %let dsid=%sysfunc(open(&ds,is));
  %if &dsid EQ 0 %then %do;
    %put &err: (getvalue) Dataset &ds not opened due to the following reason:;
    %put %sysfunc(sysmsg());
  %end;
  %else %do;
    %let varnum=%sysfunc(varnum(&dsid,&var));
    %if &varnum LT 1 %then %put &err: (getvalue) Variable &var not in dataset &ds;
    %else %do;
      %let rc=%sysfunc(fetchobs(&dsid,&obs));
      %if &rc = -1 %then %put &err: (getvalue) Observation &obs is beyond dataset end;
      %else %do;
        %if "%sysfunc(vartype(&dsid,&varnum))" EQ "C" %then %do;
          %let value=%sysfunc(getvarc(&dsid,&varnum));
          %if "&usequotes" EQ "N" %then %do;
&value
          %end;
          %else %do;
"&value"
          %end;
        %end;
        %else %do;
          %let value=%sysfunc(getvarn(&dsid,&varnum));
&value
        %end;
      %end;
    %end;
    %let rc=%sysfunc(close(&dsid));
  %end;

%mend getvalueq;
