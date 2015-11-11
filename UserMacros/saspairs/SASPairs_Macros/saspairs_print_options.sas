%macro saspairs_print_options;
%* --- prints the option variables to the output window;

	%let count = %saspairs_nwords(&saspairs_options);
	%let prinitit=;
	%macro printvals;
		%do i = 1 %to &count;
			%let word = %scan(&saspairs_options, &i, %str( ));
            %let value = %nrquote(&)&word;
			%let printit = %str(put "&word = %unquote(&value)";);
			&printit
     %end;
     %mend printvals;
	data _null_;
		file print;
		put "SASPairs Options";
		%printvals;
		run;
 %mend saspairs_print_options;
