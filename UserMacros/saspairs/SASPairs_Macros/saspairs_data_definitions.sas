%macro saspairs_data_definitions;
%* -----------------------------------------------------------------------
	check the input model data set exists and run the data definitions
   ----------------------------------------------------------------------- ;
	%put NOTE: saspairs_data_definitions STARTING.;
	%if %sysfunc(exist(&model_data_set)) %then %do;
		%* input the commands to define the phenotypic data set and its variables;
		%let temp = dataset_definitions.sas;
		%let temp = &saspairs_source_dir&temp;
		%include "&temp";
	%end;
	%else %do;
		%put ERROR: DATA SET &model_data_set NOT FOUND;
		%let abort_job=YES;
	%end;

%final:
	%put NOTE: saspairs_data_definitions FINISHED. abort_job=&abort_job;
%mend saspairs_data_definitions;
