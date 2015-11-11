%macro saspairs_gui_create_project (data_set_in);
%* --------------- CREATE IML DATA STORAGE FOR A PROJECT ---------------;

	%* check that the model_data_set_in exists and get the data definitions;
	%let model_data_set = &data_set_in;
	%saspairs_data_definitions;
	%if &abort_job = YES %then %goto final;  %* bug out if error;

	%* store matrices, if needed;
	%saspairs_iml_data_storage;
%final:
%mend saspairs_gui_create_project;
