%macro saspairs_call_uncorrit;
	%let matrix = matrix;
	%if &default_matrices = spimlsrc.default_matrices %then %do;
		%do i=1 %to &n_matrices;
			%let test = %upcase(%substr(&&matrix&i,1,1));
			%if &test = V AND &&mdefault&i = 1 %then %do;
				%let uncorrit = %str(call uncorrit (&&matrix&i) ) %str(;);
				&uncorrit
			%end;
		%end;
	%end;
%mend saspairs_call_uncorrit;
