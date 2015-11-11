%macro saspairs_check_options;
%* --- checks that values for options are valid;

	%global saspairs_options;
	%let saspairs_options = vardef missing_values set_n_to optimize negative_chi2 standardize opt2 gtol absgtol;
	%global &saspairs_options; 

	%let msg=;
	%if &vardef ne %then %do;
		%if %upcase(&vardef) NE N AND %upcase(&vardef) NE DF %then
			%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION vardef: &vardef";);
	%end;
	%else
		%let vardef=N;
	%let vardef = %upcase(&vardef);

	%if &missing_values ne %then %do;
		%if %upcase(&missing_values) ne NOMISS %then
			%let msg=%str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION missing_values: &missing_values";);
	%end;

	%if &opt2 ne %then %do;
		%if &opt2 NE 0 AND &opt2 NE 1 AND &opt2 NE 2 AND &opt2 NE 3 AND &opt2 NE 4 %then
			%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION opt2: &opt2";);
	%end;
	%else
		%let opt2 = 0;

	%if &set_n_to ne %then %do;
		%if %upcase(&set_n_to) NE N_MIN  AND
			%upcase(&set_n_to) NE N_MAX  AND
			%upcase(&set_n_to) NE N_AVERAGE %then
				%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION set_n_to: &set_n_to";);
	%end;
	%else
		%let set_n_to = N_MIN;
	%let set_n_to = %upcase(&set_n_to);

	%if &optimize ne %then %do;
		%if %upcase(&optimize) NE YES  AND
			%upcase(&optimize) NE NO %then
				%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION optimize: &optimize";);
	%end;
	%else
		%let optimize = YES;
	%let optimize = %upcase(&optimize);

	%if &negative_chi2 ne %then %do;
		%if %upcase(&negative_chi2) NE YES  AND
			%upcase(&negative_chi2) NE NO %then
				%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION negative_chi2: &negative_chi2";);
	%end;
	%else
		%let negative_chi2 = NO;
	%let negative_chi2 = %upcase(&negative_chi2);

	%if &standardize ne %then %do;
		%if %upcase(&standardize) NE YES  AND
			%upcase(&standardize) NE NO %then
				%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION standardize: &standardize";);
	%end;
	%else
		%let standardize = YES;
	%let standardize = %upcase(&standardize);
	
	%if %quote(&gtol) ne  %then %do;
		%if %eval(%sysevalf(&gtol, floor) < 0) %then
				%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION gtol: &gtol";);
	%end;
	%else
		%let gtol=0;

	%if %quote(&absgtol) ne %then %do;
		%if %eval(%sysevalf(&absgtol, floor) < 0) %then
				%let msg = &msg %str(put "*** ERROR *** ILLEGAL VALUE FOR OPTION absgtol: &absgtol";);
	%end;
	%else
		%let absgtol=0;

	%if &msg ne %then %do;
		data _null_;
			file print;
			&msg
		run;
		%let abort_job = YES;
	%end;
%mend saspairs_check_options;
