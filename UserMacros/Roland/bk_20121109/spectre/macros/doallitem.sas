/*<pre><b>
/ Program   : doallitem.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Mar-2007
/ Purpose   : To execute code for each item in a space-delimited list
/ SubMacros : %words
/ Notes     : The code must be enclosed in single quotes. This can either be
/             macro code or SAS code. You can use this inside or outside a data
/             step. Refer to the elements as "&item". Do not worry that this is
/             surrounded by single quotes. These will be stripped inside the
/             macro.
/ Usage     : %doallitem(dsa dsb dsc,'proc sort data=&item;by var;run;')
/ 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ list              (pos) List of things to run code for for each item.
/ code              (pos) Code to run for each item. ENCLOSE IN SINGLE QUOTES.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  29Mar07         Put out "macro called" message plus header tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: doallitem v1.0;

%macro doallitem(list,code);
%local i item;
%if %qsubstr(&code,1,1) NE %str(%') 
or %qsubstr(&code,%length(&code),1) NE %str(%') %then 
%put ERROR: (doallitem) Code supplied to second parameter must be enclosed in single quotes; 
%else %do i=1 %to %words(&list); 
  %let item=%scan(&list,&i,%str( )); 
%substr(&code,2,%length(&code)-2) 
%end; 
%mend; 

  