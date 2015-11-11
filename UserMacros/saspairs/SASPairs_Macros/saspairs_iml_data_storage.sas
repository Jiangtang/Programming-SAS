%macro saspairs_iml_data_storage;
%* -----------------------------------------------------------------------------
	checks whether matrices are already stored, and if not then selects
	the appropriate macro to run to store them
   ----------------------------------------------------------------------------- ;

	%put NOTE: saspairs_iml_data_storage STARTING. SAME_DATA=&same_data;
	%if &same_data = 0 %then %do;
		%* initialize the storage variables;
		%let rel_data_stored = 0;
		%let cov_matrix_stored=0;
		%let saspairs_sscp_sumx_stored=0;
		%let saspeds_sscp_sumx_stored=0;
		%let saspairs_means_stored=0;
		%let model_matrices_stored=0;
		%let iml_modules_written=0;
		%let fit_indices_stored=0;
	%end;

	%* initialize the fit_indices_stored when macro calls are different;
	%if &macro_name ^= &last_macro_name %then
		%let fit_indices_stored = 0;

	%* relationship data set;
	%if &rel_data_stored = 0 %then %do;
		%put NOTE: saspairs_iml_data_storage CALLING RELATIONSHIP_DEFINITIONS BECAUSE rel_data_stored=0;
		%let temp = relationship_definitions.sas;
		%let temp = &saspairs_source_dir&temp;
		%include "&temp";
		%if &abort_job = YES %then %goto final;
	%end;

	%* covariance matrix and means;
	%if &cov_matrix_stored = 0 AND &macro_name ^= SASPEDS %then %do;
		%put NOTE: saspairs_iml_data_storage calling COVARIANCE_DATA BECAUSE cov_matrix_stored=0;
		%if &data_set_type = DATA %then %do;
			%* --- check the phenotypic data set for errors;
			%saspairs_check_type_eq_data;
			%if &abort_job=YES %then %goto final;
			%* --- construct the type=corr data set;
			%saspairs_create_type_eq_corr (&phenotypes_data_set, &family, &relation,
			&phenotypes_in, &covariate_phenotypes_in, &missing_values, &vardef,
			&relation_data_set, &cov_data_set);
			%if &abort_job = YES %then %goto final;
		%end;
		%else %do;
			%* --- check the users type=corr data set for errors;
			%saspairs_check_type_eq_corr;
			%if &abort_job=YES %then %goto final;
		%end;
		%* --- check and store the covariance matrix;
		%put NOTE: saspairs_iml_data_storage calling COVARIANCE_DATA;
		%let temp = covariance_data.sas;
		%let temp = &saspairs_source_dir&temp;
		%include "&temp";
		%if &abort_job = YES %then %goto final;
	%end;

	%* sums and sums of squares and cross products matrices and sums of X;
	%if &macro_name = SASPAIRS_RAW_NOMEANS %then %do;
		%if &saspairs_sscp_sumx_stored = 1 AND &saspairs_means_stored = 0 %then %goto final; *bug out;
		%put NOTE: saspairs_iml_data_storage CALLING saspairs_construct_sumx_sscp;
		%saspairs_construct_sumx_sscp;
	%end;
	%else %if &macro_name = SASPAIRS_RAW_MEANS %then %do;
		%if &saspairs_sscp_sumx_stored = 1 AND &saspairs_means_stored = 1 %then %goto final; *bug out;
		%put NOTE: saspairs_iml_data_storage CALLING saspairs_construct_sumx_sscp;
		%saspairs_construct_sumx_sscp;
	%end;

	%* other stuff for SASPEDS should go in here;
%final:
	%put NOTE: saspairs_iml_data_storage FINISHED. ABORT_JOB=&abort_job;
%mend saspairs_iml_data_storage;
