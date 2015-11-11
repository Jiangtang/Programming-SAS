%macro saspairs_model_definitions;
	%* get the model statements;
	%let temp = model_definitions.sas;
	%let includefile = &saspairs_source_dir&temp;
	%include "&includefile";
%final:
%mend saspairs_model_definitions;
