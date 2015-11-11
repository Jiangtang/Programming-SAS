%macro saspairs_check_type_eq_corr;
%* --- --process the users data set if it is a type=CORR;
	%put NOTE: saspairs_check_type_eq_corr_ds STARTING;
	%if &same_data=1 %then %goto final;

	%* sort the data set, outputing a new data set so that the users data set
	   is not changed;
	proc sort data=&users_cov_data_set out=saspairs_cov_data;
		by &relative1 &relative2;
	run;

	%* make certain that variable _type_ is uppercase and check that the
	   mean, n, and cov are present;
	data saspairs_cov_data;
		set saspairs_cov_data end=eof;
		if _N_ = 1 then do;
			temp_meanfound=0;
			temp_nfound=0;
			temp_covfound=0;
		end;
		retain temp_meanfound temp_nfound temp_covfound;
		_type_ = upcase(_type_);
		if _type_ = "COV" then
			temp_covfound=1;
		else if _type_ = "MEAN" then
			temp_meanfound=1;
		else if _type_ = "N" then
			temp_nfound=1;

		if eof then do;
			file print;
			if temp_nfound = 0 then do;
				put "*** ERROR *** _type_ = N MISSING IN TYPE=CORR DATA SET &cov_data_set";
				call symput ("abort_job", "YES");
			end;
			if temp_meanfound = 0 then do;
				put "*** ERROR *** _type_ = MEAN MISSING IN TYPE=CORR DATA SET &cov_data_set";
				call symput ("abort_job", "YES");
			end;
			if temp_covfound = 0 then do;
				put "*** ERROR *** _type_ = COV MISSING IN TYPE=CORR DATA SET &cov_data_set";
				call symput ("abort_job", "YES");
			end;
		end;
		drop temp_meanfound temp_nfound temp_covfound;
	run;

	%* --- check that the variable names are in the data set;
	%saspairs_check_varlist(&users_cov_data_set, &Relative1 &Relative2);
	%let long_varlist=;
	%saspairs_check_varlist(&users_cov_data_set, &cov_phenotypes_in);
	%let cov_phenotypes = &long_varlist;
	%if %quote(&covariate_phenotypes_in) ne %then %do;
		%let long_varlist=;
		%saspairs_check_varlist(&users_cov_data_set, &covariate_phenotypes_in);
		%let covariate_phenotypes = &long_varlist;
		%let n_covariates=%saspairs_nwords(&covariate_phenotypes);
	%end;
	%else %do;
		%let covariate_phenotypes=;
		%let n_covariates=0;
	%end;

	%* --- check for duplicate variable names;
	%saspairs_check_dups (&Relative1 &Relative2 &cov_phenotypes &covariate_phenotypes);

	%* --- set macro variables;
	%let n_phenotypes = %saspairs_nwords(&phenotypes);
	%let n_var = %saspairs_nwords(&cov_phenotypes);
	%let cov_data_set = saspairs_cov_data;
	%let same_data=0;

	%* --- error checks;
	%if %sysfunc(mod(&n_var,2)) = 1 %then %do;
		%let abort_job = YES;
		%let printit = &printit %str(print , "*** ERROR *** ODD NUMBER OF PHENOTYPES FOR TYPE=CORR DATA SET:", "&cov_phenotypes";);
	%end;
	%if %eval(2*&n_phenotypes - &n_var ^= 0) %then %do;
		%let abort_job = YES;
		%let printit = &printit %str(print , "*** ERROR *** NO. OF PHENOTYPE LABELS NE .5*NO. OF TYPE=CORR VARIABLES";);
	%end;
	%if abort_job=YES %then %goto final;

	%* --- create & store the IML variables for future IML calls;
	%let temp=store_matrices.sas;
	%let temp=&saspairs_source_dir&temp;
	%include "&temp";
	%let thissyserr = &syserr;
	%saspairs_syserr(&thissyserr);

%final:
	%put NOTE: saspairs_check_type_eq_corr_ds FINISHED. abort_job=&abort_job;
%mend saspairs_check_type_eq_corr;
