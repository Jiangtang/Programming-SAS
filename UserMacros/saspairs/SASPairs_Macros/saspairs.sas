%macro saspairs (saspairs_data_set);
	%saspairs_initialization_check;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* initialize;
	%let macro_name = SASPAIRS;
	%let function = function_covmats;
	%let load_matrices = cov_mats df fdet;

	%* execute;
	%saspairs_execute (&saspairs_data_set);

%final:
%mend saspairs;
