%macro saspairs_initialize;
%* -----------------------------------------------------------------------
   This macro cleans out stored IML matrices and initializes the
	macro variable names
   -----------------------------------------------------------------------;

	%* this statement is redundant, but useful to avoid unresolved macro
		variables when a user calls this macro without involing saspairs;
	%global blank abort_job saspairs_source_dir sproject_dir;

	%* -------- clean out the matrix storage  --------;
	proc iml;
		remove _all_;
	quit;

	%* check on the existence of LIBNAME spimlsrc;
	%if %quote(&saspairs_source_dir) = %quote(&blank) %then %do;
		%let test = %sysfunc(pathname(spimlsrc));
		%if %quote(&test) = %quote(&blank) %then %do;
			%put ERROR: LIBNAME spimlsrc NOT ASSIGNED.;
			%let abort_job = YES;
			%goto final;
		%end;
		%else %do;
			%if &sysscp = WIN %then %let delim = \;
			%else %let delim = /;
			%let saspairs_source_dir = &test&delim;
			%put NOTE: saspairs_source_dir = &saspairs_source_dir;
			%* -------- these are IML source files for include statements --------;
			%global utilities minimizer_modules;

			%let temp = utilities.sas;
			%let utilities = &saspairs_source_dir&temp;

			%let temp = call_to_minimizer_modules.sas;
			%let minimizer_modules = &saspairs_source_dir&temp;
		%end;
	%end;

	%* check on the existence of LIBNAME sproject;
	%if %quote(&sproject_dir) = %quote(&blank) %then %do;
		%let test = %sysfunc(pathname(sproject));
		%if %quote(&test) = %quote(&blank) %then %do;
			%put ERROR: LIBNAME sproject NOT ASSIGNED.;
			%let abort_job = YES;
			%goto final;
		%end;
		%else %do;
			%if &sysscp = WIN %then %let delim = \;
			%else %let delim = /;
			%let sproject_dir = &test&delim;
			%put NOTE: sproject_dir = &sproject_dir;
			%* -------- these are IML modules written by the macros --------;
			%global put_x_file   predicted_stats    test_users_module;

			%let temp = put_x_into_matrices.sas;
			%let put_x_file = &sproject_dir&temp;

			%let temp = predicted_stats.sas;
			%let predicted_stats = &sproject_dir&temp;

			%let temp = test_users_module.sas;
			%let test_users_module = &sproject_dir&temp;

		%end;
	%end;

	%* initialize the macro variables;
	%saspairs_initialize_macro_vars;

%final:
%mend saspairs_initialize;
