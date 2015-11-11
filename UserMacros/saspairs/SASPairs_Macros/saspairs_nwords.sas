%macro saspairs_nwords (string);
	%* calculates the number of words in a string;
	%local  word;
	%let count = 1;
	%let word = %qscan(&string, &count, %str( ));
	%do %while (&word ne);
		%let count = %eval(&count + 1);
		%let word = %qscan(&string, &count, %str( ));
	%end;
	%let count = %eval(&count - 1);
	&count
%mend;
