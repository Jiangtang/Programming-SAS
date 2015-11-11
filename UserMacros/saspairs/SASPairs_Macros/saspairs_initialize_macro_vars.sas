%macro saspairs_initialize_macro_vars;
%* --------------- initialize the macro variables ---------------;

	%* -------- these are the required macro variables --------;
	%global phenotypes_data_set family relation phenotypes_in phenotypes
			users_cov_data_set cov_data_set relative1 relative2
			cov_phenotypes_in cov_phenotypes
			covariates covariate_phenotypes covariate_phenotypes_in
			relation_data_set  n_phenotypes n_var n_covariates
			model_data_set default_matrices
			global_arg1 global_arg2
			data_set_type number_of_models n_matrices
			macro_name function load_matrices
			same_data rel_data_stored cov_matrix_stored 
			saspairs_sscp_sumx_stored saspeds_sscp_sumx_stored
			saspairs_means_stored last_macro_name
			model_matrices_stored iml_modules_written
			fit_indices_stored;

	%* --- printed output macro variables;
    %global SPPrint_EchoCards SPPrint_DataDefs SPPrint_RelDSInfo SPPrint_DataSum SPPrint_MatDefSum
			SPPrint_ParmList 
		    SPPrint_StartVal SPPrint_FinalParms SPPrint_ParmMats SPPrint_ObsPre SPPrint_FitIndex;

	%* --- initialize;
	%let phenotypes_data_set=;
	%let family=;
	%let relation=;
	%let phenotypes_in=;
	%let phenotypes=;
	%let users_cov_data_set=;
	%let cov_data_set=;
	%let relative1=;
	%let relative2=;
	%let cov_phenotypes_in=;
	%let cov_phenotypes=;
	%let covariates=;
	%let covariate_phenotypes=;
	%let covariate_phenotypes_in=;
	%let n_phenotypes=;
	%let n_var=;
	%let n_covariates=;
	%let relation_data_set=;
	%let global_arg1=;
	%let global_arg2=;
	%let data_set_type=;
	%let number_of_models=0;
	%let same_data=0;
	%let rel_data_stored=0;
	%let cov_matrix_stored=0;
	%let saspairs_sscp_sumx_stored=0;
	%let saspeds_sscp_sumx_stored=0;
	%let saspairs_means_stored=0;
	%let last_macro_name=;
	%let model_matrices_stored=0;
	%let iml_modules_written=0;
	%let fit_indices_stored=0;
	%let SPPrint_EchoCards  = YES;
	%let SPPrint_DataDefs   = YES;
	%let SPPrint_RelDSInfo  = YES;
	%let SPPrint_DataSum    = YES;
	%let SPPrint_MatDefSum  = YES;
	%let SPPrint_ParmList   = YES;
	%let SPPrint_StartVal   = YES;
	%let SPPrint_FinalParms = YES;
	%let SPPrint_ParmMats   = YES;
	%let SPPrint_ObsPre     = YES;
	%let SPPrint_FitIndex   = YES;

	%* -------- a code used to abort the job when an error is detected --------;
	%let abort_job = NO;

	%* --- default_matrices ---;
	%let default_matrices = spimlsrc.default_matrices;
%mend saspairs_initialize_macro_vars;
