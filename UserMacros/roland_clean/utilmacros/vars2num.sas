/*<pre><b>
/ Program      : vars2num.sas
/ Version      : 1.0
/ Author       : Roland Rashleigh-Berry
/ Date         : 27-Nov-2012
/ Purpose      : To convert variables to numeric where you know they should be
/                numeric variables.
/ SubMacros    : %editlist
/ Notes        : Especially when importing from spreadsheets, it can sometimes
/                happen that columns you know should be numeric turn out to be
/                character. This macro accepts a list of variables you want to
/                be numeric and transforms them into numeric variables of the
/                same name.
/
/                When this macro converts character values to numeric, a message
/                will be written to the log to this effect. If you do not want
/                that message in the log and your values are all integers then
/                use the %int2num macro.
/
/ Usage        : data test2;
/                  set test1;
/                  %vars2num(vara varb varc vard)
/                run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ varlist           (pos) List of variables separated by spaces that you want to
/                   ensure are numeric variables.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  27Nov12         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: vars2num v1.0;

%macro vars2num(varlist); 
%editlist(&varlist,'__&item=&item*1;drop &item;rename __&item=&item;') 
%mend vars2num;
