/* ---------------------------------------------------------------------------
        Create a TYPE=CORR data set from twindata1
   -------------------------------------------------------------------------- */
%saspairs_initialization_check;
%let dataset = %quote(spothstf.twindata1);
%let phenotypes_in = %quote(iq -- civics);
%let covariates_in=;
%let missing_values=;
%let vardef = N;
%let relation_data_set = %quote(spothstf.twins_no_sex_differences);
%let cov_data_set_name = %quote(spothstf.twindata1_corr);
%saspairs_create_type_eq_corr (&dataset, twinpair, zygosity2, &phenotypes_in,
                &covariates_in, &missing_values, &vardef,
                &relation_data_set, &cov_data_set_name);
