/*<pre><b>
/ Program   : sas2tabdlm.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 14-Oct-2011
/ Purpose   : To write the contents of a sas dataset to a tab-delimited file
/ SubMacros : %varlist %words
/ Notes     : If a variable is formatted then that format is applied to the 
/             value.
/
/             If you do not specify a destination file then the contents will
/             be written to the log but the tab characters will not be seen.
/
/             You can use the %dlm2sas macro to convert the output file back
/             into a sas dataset but all columns will be treated as character.
/
/ Usage     : %sas2tabdlm(sashelp.cars,,yes)
/             %sas2tabdlm(sashelp.cars,C:\mylib\myfile.txt,yes)
/             %sas2tabdlm(sashelp.cars,"C:\mylib\myfile.txt",no)
/             %sas2tabdlm(sashelp.cars,"C:\mylib\myfile.txt")
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ ds                (pos) Dataset name (no modifiers)
/ dest              (pos) Destination file (quoted or unquoted)
/ varnames          (pos) By default, show the variable names in the first row.
/                   Set to no to suppress this.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  14Oct11         New
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: sas2tabdlm v1.0;

%macro sas2tabdlm(ds,dest,varnames);

  %local i varlist numvars;

  %if not %length(&varnames) %then %let varnames=yes;
  %let varnames=%upcase(%substr(&varnames,1,1));

  %let varlist=%varlist(&ds);
  %let numvars=%words(&varlist);

  %if not %length(&dest) %then %let dest=log;
  %else %let dest="%sysfunc(dequote(&dest))";

  data _null_;
    file &dest;
    set &ds;
    %if &varnames NE N %then %do;
      if _n_=1 then do;
        %do i=1 %to %eval(&numvars-1);
          put "%scan(&varlist,&i,%str( ))" "09"x @;
        %end;
        put "%scan(&varlist,&numvars,%str( ))";
      end;
    %end;
    %do i=1 %to %eval(&numvars-1);
      put %scan(&varlist,&i,%str( )) +(-1) "09"x @;
    %end;
    put %scan(&varlist,&numvars,%str( ));
  run;

%mend sas2tabdlm;