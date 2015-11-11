%macro saspairs_mattrib_statements;
	%let matrix = matrix;
	%let mdefault = mdefault;
	%do i=1 %to &n_matrices;
		%if &default_matrices = spimlsrc.default_matrices %then %do;
			%if &&mdefault&i = 1 %then %do;
				%let test = %upcase(%substr(&&matrix&i,1,1));
				%if &test = V %then %do;
					%let label=%str(&&matrix&i (Cov\Corr));
					%let mattrib = mattrib &&matrix&i rowname=varnames colname=varnames format=8.3 label="&label" %str(;);
				%end;
				%else %if &test = S %then %do;
					%let mattrib = mattrib &&matrix&i rowname=varnames colname=varnames format=8.3 %str(;);
				%end;
				%else %if &test = F %then
					%let mattrib = mattrib &&matrix&i rowname=varnames format=8.3 %str(;);
				%else
					%let mattrib = mattrib &&matrix&i format=8.3 %str(;);
			%end;
			%else
				%let mattrib = mattrib &&matrix&i format=8.3 %str(;);
			&mattrib
		%end;
		%else
			%let mattrib = mattrib &&matrix&i format=8.3 %str(;);
			&mattrib
	%end;
%mend saspairs_mattrib_statements;
