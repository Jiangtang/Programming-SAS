%macro saspairs_check_type_eq_data;
%*  --- check variables for a type=data data set (i.e., a phenotypic data set)
	    NOTE: this macro also sets the following macro variables:
	    n_phenotypes, n_var, n_covariates, phenotypes, cov_phenotypes,
	    and covariate_phenotypes;

	%put NOTE: saspairs_check_type_eq_data STARTING;

	%* --- error flag;
	%if &abort_job=YES %then %goto final;

%*put phenotypes_data_set=&_phenotypes_data_set;
%*put family_id=&family_id;
%*put relation_code=&relation_code;
%*put phenotypes_in=&phenotypes_in;
%*put cov_phenotypes_in=&cov_phenotypes_in;
%*put covariate_phenotypes_in=&covariate_phenotypes_in;

	%* --- initialize global macro variable same_data;
	%if &same_data=1 %then %goto final;
	%let same_data=0;

	%* --- check whether the variables are in the dataset;
	%saspairs_check_varlist (&phenotypes_data_set, &family &relation);

	%* --- phenotypes;
	%let long_varlist=;
	%saspairs_check_varlist (&phenotypes_data_set, &phenotypes_in);
	%let phenotypes = &long_varlist;
	%let n_phenotypes = %saspairs_nwords(&phenotypes);
	%let n_var = %eval(2 * &n_phenotypes);
%*put check for phenotypes. abort_job = &abort_job;

	%* --- covariates;
	%if %quote(&covariate_phenotypes_in) ne %then %do;
%*put covariate_phenotypes_in=&covariate_phenotypes_in;
		%let long_varlist=;
		%saspairs_check_varlist (&phenotypes_data_set, &covariate_phenotypes_in);
		%let covariate_phenotypes = &long_varlist;
		%let n_covariates = %saspairs_nwords(&covariate_phenotypes); 
	%end;
	%else %do;
		%let n_covariates=0;
		%let covariate_phenotypes=;
	%end;
%*put after varlist abort_job = &abort_job;

	%* --- check for duplicate names;
	%saspairs_check_dups(&family &relation &phenotypes &covariate_phenotypes);
	%if &abort_job=YES %then %goto final;

	%* --- create macro variables;
	%let rel1=;
	%let rel2=;
	%do i=1 %to &n_phenotypes;
		%let thisvar = %scan(&phenotypes, &i, %str( ));
		%let rel1 = &rel1 R1_&thisvar;
		%let rel2 = &rel2 R2_&thisvar;
	%end;
	%let cov_phenotypes = &rel1 &rel2;
	%let Relative1 = Relative1;
	%let Relative2 = Relative2;
	%let cov_data_set = saspairs_cov_data;
%* put cov_phenotypes=&cov_phenotypes;

	%* --- create & store the IML variables for future IML calls;
	%let temp=store_matrices.sas;
	%let temp=&saspairs_source_dir&temp;
	%include "&temp";
	%let thissyserr = &syserr;
	%saspairs_syserr(&thissyserr);

%final:
	%* if there has been no error, delete temp_ datasets;
	%if &abort_job = YES %then %do;
		DATA _null_;
			file print;
			put "*** ERROR *** Errors in the phenotypic data set. See SAS Log for error messages.";
		RUN;
	%end;
	%put NOTE: saspairs_create_type_eq_corr FINISHED. abort_job=&abort_job;
%mend saspairs_check_type_eq_data;
