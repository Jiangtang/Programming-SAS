%macro saspairs_call_corrit;
	%let matrix = matrix;
	%if &default_matrices = spimlsrc.default_matrices %then %do;
		%do i=1 %to &n_matrices;
			%let test = %upcase(%substr(&&matrix&i,1,1));
			%if &test = V AND &&mdefault&i = 1 %then %do;
				%let corrit = %str(call corrit (&&matrix&i) ) %str(;);
				&corrit
			%end;
		%end;
	%end;
%mend saspairs_call_corrit;
