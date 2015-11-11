%macro saspairs_execute (data_set_in);
%* --------------- MAIN MACRO FOR EXECUTING A SASPAIRS MACRO ---------------;

	%* check that the model_data_set_in exists and get the data definitions;
	%let model_data_set = &data_set_in;
	%saspairs_data_definitions;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* store matrices, if needed;
	%saspairs_iml_data_storage;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* get the model defintions;
	%saspairs_model_definitions;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* loop over models;
	%do model_number = 1 %to &number_of_models;
		%* parse the matrix definitions, mx definitions, and iml definitions;
		%saspairs_parse_model;
		%if &abort_job = YES %then %goto final;  %* bug out if error;
		%* call to the minimizer;
		%if &optimize = YES %then %do;
			%saspairs_minimization_call;
			%if &abort_job = YES %then %goto final;  %* bug out if error;
			%* automatically append fit indices when more than 1 model is fit;
			%if %eval(&number_of_models > 1) %then %saspairs_append_fit_indices;
			%if &abort_job = YES %then %goto final;  %* bug out if error;
		%end;
	%end;

	%* automatically print summary of fit indices when number of models > 1;
	%if %eval(&number_of_models > 1) AND &optimize = YES %then
		%saspairs_print_summary;

	%let last_macro_name = &macro_name;

%final:
%mend saspairs_execute;
