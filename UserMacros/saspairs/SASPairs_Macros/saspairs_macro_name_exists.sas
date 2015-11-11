%macro saspairs_macro_name_exists (name);
	%if %nrquote(&&&name) = %nrstr(&)&name %then
		%let yesno=NO;
	%else
		%let yesno=YES;
	&yesno
%mend saspairs_macro_name_exists;
