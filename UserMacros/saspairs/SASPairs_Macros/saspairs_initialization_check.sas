%macro saspairs_initialization_check;
%* -----------------------------------------------------------------------
   This is the very first macro called. Its function is to check whether
	SASPairs needs to initialize IML Data Storage and the macro
	variables. It also checks that options are valid.
   -----------------------------------------------------------------------;

	%global blank abort_job saspairs_source_dir sproject_dir saspairs_version;

	%let saspairs_version = SASPairs 1.0;

	%let initialize = 0;

	%if &abort_job = &blank %then 
		%let initialize = 1;  %* this the very first call;
	%else %if &abort_job = YES %then
		%let initialize = 1;  %* previous job aborted;
	%else %if %quote(&saspairs_source_dir) = %quote(&blank) %then
		%let initialize = 1;  %* need to set/change libname spimlsrc;
	%else %if %quote(&sproject_dir) = %quote(&blank) %then
		%let initialize = 1;  %* need to set/change libname sproject;

	%if &initialize = 1 %then %saspairs_initialize;

	%* check for valid options.
	   NOTE: This needs to be done here in case a user sets an option
	         before the first call to SASPairs;
	%saspairs_check_options;

%mend saspairs_initialization_check;
