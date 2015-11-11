%macro saspairs_raw_nomeans (model_data_set_in);
	%saspairs_initialization_check;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* initialize;
	%let macro_name = SASPAIRS_RAW_NOMEANS;
	%let function = function_raw_nomeans;
	%let load_matrices = n_configs sample_size n_nomiss sscp index_sscp index_remove_sscp remove_sscp;

	%* execute;
	%saspairs_execute (&model_data_set_in);

%final:
%mend saspairs_raw_nomeans;
