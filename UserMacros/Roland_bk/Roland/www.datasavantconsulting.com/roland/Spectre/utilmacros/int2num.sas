/*<pre><b>
/ Program      : int2num.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 27-Nov-2012
/ Purpose      : To convert variables to numeric where you know they should be
/                integer variables.
/ SubMacros    : %editlist
/ Notes        : Especially when importing from spreadsheets, it can sometimes
/                happen that columns you know should be numeric turn out to be
/                character. This macro accepts a list of variables you want to
/                be numeric and transforms them into numeric variables of the
/                same name. They must all be variables you expect to be
/                integers. For non-integer variables use the %vars2num macro.
/
/ Usage        : data test2;
/                  set test1;
/                  %int2num(vara varb varc vard)
/                run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ varlist           (pos) List of variables separated by spaces that you want to
/                   ensure are numeric integer variables.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27Nov12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: int2num v1.0;

%macro int2num(varlist); 
%editlist(&varlist,'__&item=input(put(&item,32.),32.);drop &item;rename __&item=&item;') 
%mend int2num;
