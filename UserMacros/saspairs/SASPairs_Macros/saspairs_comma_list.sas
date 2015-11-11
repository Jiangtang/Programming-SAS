%macro saspairs_comma_list (list);
	%* separates the words in a list by a comma;
	%let comma = %str(,);
	%let count = %saspairs_nwords(&list);
	%let string = %scan(&list, 1, %str( ));
	%if &count > 1 %then %do;
		%let string = &string&comma;
		%do i = 2 %to %eval(&count-1);
			%let word = %scan(&list, &i, %str( ));
			%let string = &string &word&comma;
		%end;
		%let word = %scan(&list, &count, %str( ));
		%let string = &string &word;
	%end;
	&string
%mend saspairs_comma_list;
