/*<pre><b>
/ Program   : vwlist.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : To list all the views in a libref.
/ SubMacros : none
/ Notes     : This is NOT a function-style macro. See usage notes.
/             You can set an option to prefix the view names with the libref.
/             The list of views will be written to the global macro variable
/             _vwlist_.
/ Usage     : %vwlist(work);
/             %let vwlist=&_vwlist_;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ libref            (pos) Libref name for which all datasets are to be listed
/ prefix            (pos) Set this to anything at all and all view names will
/                   be prefixed with the libref name.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: vwlist v1.0;

%macro vwlist(libref,prefix);
  %global _vwlist_;
  %let _vwlist_=;
  %if not %length(&libref) %then %let libref=%sysfunc(getoption(user));
  %if not %length(&libref) %then %let libref=work;
  %let libref=%upcase(&libref);

  proc sql noprint;
    select distinct memname into :_vwlist_ separated by
    %if %length(&prefix) %then %do;
      " &libref.."
    %end;
    %else %do;
      ' '
    %end;
    from dictionary.tables
    where memtype='VIEW'
    and libname="&libref";
  quit;

  %if %length(&prefix) %then %let _vwlist_=&libref..&_vwlist_;
  run;
%mend vwlist;
