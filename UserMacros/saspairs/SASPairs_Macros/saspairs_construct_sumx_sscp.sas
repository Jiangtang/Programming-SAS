%macro saspairs_construct_sumx_sscp;
%* ----------------------------------------------------------------------------
	construct the sums of X and the sums of squares and cross products to
	analyze pair data with missing values or to model means
   ----------------------------------------------------------------------------;

	%put NOTE: saspairs_construct_sumx_sscp STARTED;
	data temp_individuals (keep = &family &relation &phenotypes &covariate_phenotypes);
		set &phenotypes_data_set;
	run;
	%* if macro is saspairs_raw_nomeans then standardize the data;
	%if &macro_name = SASPAIRS_RAW_NOMEANS & &standardize = YES %then %do;
		%* NOTE: data set temp_individuals was created by macro saspairs_individuals_to_pairs;
		proc sort data=temp_individuals out=temp_individuals;
			by &relation;
		run;
		proc standard data=temp_individuals out=temp_individuals m=0;
			by &relation;
			var &phenotypes &covariate_phenotypes;
		run;
		%if &syserr ^= 0 %then %do;
			%put ERROR: PROBLEM WITH PROC STANDARD IN MACRO saspairs_individuals_to_pairs;
			%let abort_job=YES;
			%goto final;
		%end;
		proc sort data=temp_individuals out=temp_individuals;
			by &family;
		run;
	%end;

	%* variables for arrays;
	%let rel1 =;
	%do i=1 %to &n_phenotypes;
		%let word = %scan(&cov_phenotypes, &i, %str( ));
		%let rel1 = &rel1 &word;
	%end;
	%let rel2=;
	%do i = %eval(&n_phenotypes+1) %to &n_var;
		%let word = %scan(&cov_phenotypes, &i, %str( ));
		%let rel2 = &rel2 &word;
	%end;

	/* --- create data set pairs --- */
	data temp_rel1 (keep = &family temp_relative1 temp_relative2 &rel1) 
		 temp_rel2 (keep = &family temp_relative2save &rel2 &covariate_phenotypes);
		set temp_individuals;
		by &family;
		array temp_rel1array &rel1;
		array temp_rel2array &rel2;
		array temp_phenoarray &phenotypes;
		if first.&family then do;
			temp_relative1 = &relation;
			temp_relative2 = .;
			do over temp_rel1array; temp_rel1array = temp_phenoarray; end;
			output temp_rel1;
		end;
		if last.&family then do;
			temp_relative2save = &relation;
			do over temp_rel2array; temp_rel2array = temp_phenoarray; end;
			output temp_rel2;
		end;
	run;
	%if &syserr ^= 0 %then %do;
		%put ERROR: ERROR IN CREATING DATA SETS temp_rel1 AND temp_rel2;
		%let abort_job = YES;
		%goto final;
	%end;

	data temp_pairs;
		merge temp_rel1 temp_rel2;
		by &family;
		temp_relative2 = temp_relative2save; * just to position variables;
		drop temp_relative2save;
	run;
	%if &syserr ^= 0 %then %do;
		%put ERROR: ERROR IN CREATING DATA SET temp_pairs;
		%let abort_job = YES;
		%goto final;
	%end;

	%let misslength = %eval(2 * &n_phenotypes + &n_covariates);
	%let temp_sort_val_length = %eval(&misslength + 4);
	data saspairs_raw;
	/* --- find the pattern for missing data in a set of pedigrees --- */
		set temp_pairs;
		length temp_miss_val $&misslength temp_sort_val $&temp_sort_val_length temp_cr1 temp_cr2 $2;
		temp_miss_val = repeat("1", &misslength);
		array temp_missing &cov_phenotypes &covariate_phenotypes;
		temp_count = 0;
		temp_nmiss = 0;
		do over temp_missing;
			temp_count = temp_count + 1;
			if temp_missing = . then do;
				temp_nmiss = temp_nmiss + 1;
				substr(temp_miss_val, temp_count, 1) = "0";
			end;
		end;
		/* delete cases with all missing values */
		if temp_nmiss = &misslength then delete;
		/* create a sort index */
		temp_cr1 = temp_relative1;
		temp_cr2 = temp_relative2;
		temp_sort_val = temp_cr1 || temp_cr2 || temp_miss_val;
		rename temp_relative1 = relative1
		       temp_relative2 = relative2;
	run;
	%if &syserr ^= 0 %then %do;
		%put ERROR: PROBLEM CREATING DATA SET saspairs_raw IN MACRO saspairs_construct_sumx_sscp;
		%let abort_job=YES;
		%goto final;
	%end;

	proc sort;
		by temp_sort_val;
	run;
	%if &syserr ^= 0 %then %do;
		%put ERROR: PROBLEM SORTING DATA SET saspairs_raw IN MACRO saspairs_construct_sumx_sscp;
		%let abort_job=YES;
		%goto final;
	%end;

	%* --- IML code to get the sumx and sscp vectors;
	%let temp = sumx_sscp_data.sas;
	%let includefile = &saspairs_source_dir&temp;
	%include "&includefile";
%final:
	%put NOTE: saspairs_construct_sumx_sscp FINISHED. ABORT_JOB=&abort_job;
%mend saspairs_construct_sumx_sscp;
