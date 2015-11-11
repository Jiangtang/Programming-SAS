%macro saspairs_raw_means (model_data_set_in);
	%saspairs_initialization_check;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* initialize;
	%let macro_name = SASPAIRS_RAW_MEANS;
	%let function = function_raw_means;
	%let temp = n_configs sample_size n_nomiss sumx index_sumx index_remove_sumx remove_sumx;
	%let load_matrices = &temp sscp index_sscp index_remove_sscp remove_sscp;

	%* execute;
	%saspairs_execute (&model_data_set_in);

%final:
%mend saspairs_raw_means;
