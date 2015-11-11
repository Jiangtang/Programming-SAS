%macro saspairs_parse_model;
%* -----------------------------------------------------------------------
	parse the matrix definitions, mx definitions, and iml definitions
   -----------------------------------------------------------------------;
	%put NOTE: saspairs_parse_model STARTING;
	%let temp = matrix_definitions.sas;
	%let includefile = &saspairs_source_dir&temp;
	%include "&includefile";
	%if &abort_job = YES %then %goto final;  %* bug out;

	%let temp = mx_definitions.sas;
	%let includefile = &saspairs_source_dir&temp;
	%include "&includefile";
	%if &abort_job = YES %then %goto final;  %* bug out;

	%let temp = iml_definitions.sas;
	%let includefile = &saspairs_source_dir&temp;
	%include "&includefile";

%final:
	%put NOTE: saspairs_parse_model FINISHED. abort_job=&abort_job;
%mend saspairs_parse_model;
