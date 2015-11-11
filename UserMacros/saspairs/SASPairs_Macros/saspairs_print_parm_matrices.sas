%macro saspairs_print_parm_matrices;
	%let comma = ,;
	%let print = print;
	%let matrix = matrix;
	%do i = 1 %to %eval(&n_matrices - 1);
		%let print = &print &&matrix&i &comma&comma;
	%end;
	%let print = &print &&matrix&n_matrices %str(;);
	&print
%mend saspairs_print_parm_matrices;
