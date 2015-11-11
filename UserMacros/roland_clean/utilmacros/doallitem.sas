/*<pre><b>
/ Program   : doallitem.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 09-Jun-2011
/ Purpose   : To execute code for each item in a space-delimited list
/ SubMacros : %words
/ Notes     : The code must be enclosed in single quotes. This can either be
/             macro code or SAS code. You can use this inside or outside a data
/             step. Refer to the elements as "&item". Do not worry that this is
/             surrounded by single quotes. These will be stripped inside the
/             macro.
/ Usage     : %doallitem(dsa dsb dsc,'proc sort data=&item;by var;run;');
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ __dolist          (pos) List of things (separated by spaces) to run code on
/ code              (pos) Code to run for each item. ENCLOSE IN SINGLE QUOTES.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/ rrb  04May11         Code tidy
/ rrb  09Jun11         First parameter name changed to "__dolist" from "list" in
/                      case the user is using a macro variable of that name in
/                      a call to this macro.
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: doallitem v1.1;

%macro doallitem(__dolist,code);
  %local i item err;
  %let err=ERR%str(OR);
  %if %qsubstr(&code,1,1) NE %str(%') 
  or %qsubstr(&code,%length(&code),1) NE %str(%') %then 
  %put &err: (doallitem) Code supplied to second parameter must be enclosed in single quotes; 
  %else %do i=1 %to %words(&__dolist); 
    %let item=%scan(&__dolist,&i,%str( )); 
  %substr(&code,2,%length(&code)-2) 
  %end; 
%mend doallitem; 

  