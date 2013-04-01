/*
Purpose: Reverse a macro variable's value.
Notes: For versions before v6.12. Otherwise use 
            %sysfunc(reverse(&<macro-variable>))

example:
    %put %reverse(gfee);



Credit: Richard A. DeVenezia
    http://www.devenezia.com/downloads/sas/macros/index.php?m=reverse

*/

%macro reverse (string);
  %local i rstring;
  %let rstring=;
  %let string=%quote(&string);
  %do i=%length(&string) %to 1 %by -1;%quote(%substr(&string,&i,1))%end;
%mend;


