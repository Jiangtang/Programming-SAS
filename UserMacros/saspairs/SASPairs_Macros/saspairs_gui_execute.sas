%macro saspairs_gui_execute (data_set_in);
%* --------------- MAIN MACRO FOR EXECUTING A SASPAIRS MACRO ---------------;

	%* check that the model_data_set_in exists and get the model definitions;
	%let model_data_set = &data_set_in;
	%saspairs_model_definitions;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* parse the matrix definitions, mx definitions, and iml definitions;
	%saspairs_parse_model;
	%if &abort_job = YES %then %goto final;  %* bug out if error;
	%* call to the minimizer;
	%if &optimize = YES %then %saspairs_minimization_call;
	%if &abort_job = YES %then %goto final;  %* bug out if error;
	%let last_macro_name = &macro_name;

%final:
%mend saspairs_gui_execute;
