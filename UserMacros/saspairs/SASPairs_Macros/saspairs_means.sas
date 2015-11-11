%macro saspairs_means (saspairs_data_set);
	%saspairs_initialization_check;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* initialize;
	%let macro_name = SASPAIRS_MEANS;
	%let function = function_covmats_means;
	%let load_matrices = cov_mats mean_vecs df fdet;

	%* execute;
	%saspairs_execute (&saspairs_data_set);

%final:
%mend saspairs_means;
