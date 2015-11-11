/* -----------------------------------------------------------------
	Template for Calling Model Data Sets from SPMDSLIB
   ----------------------------------------------------------------- */
data model_ds_template;
	length card $80;
	input card $char80.;
datalines4;

BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.twindata1
	     FAMILY ID VARIABLE = twinpair
	  RELATIONSHIP VARIABLE = zygosity2
	PHENOTYPES FOR ANALYSIS = iq reading writing
	  RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL data=spmdslib.acu_models
;;;;
run;
%saspairs(model_ds_template);
