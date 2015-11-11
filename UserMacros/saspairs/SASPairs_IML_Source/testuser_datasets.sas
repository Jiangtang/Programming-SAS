/* -----------------------------------------------------------------------
	THESE THREE DATA SET ARE REQUIRED FOR WRITING test_users_module
   ----------------------------------------------------------------------- */
data spimlsrc.testuser1;
	length card $80;
	input card $char80.;
DATALINES4;
/* =======================================================================
   *** DO NOT CHANGE ANY OF THE FOLLOWING CODE UNDER PENALITY OF DEATH *** 
   ======================================================================= */
proc iml;
%include "&put_x_file";
;;;;

data spimlsrc.testuser2;
	length card $80;
	input card $char80.;
DATALINES4;

start predicted_stats (pair_number, relative1, relative2, gamma_a, gamma_c,
     gamma_d, p1, p2, r12, p1cv, p2cv, vccv, mean_vector, bad_f_value)
     GLOBAL ( &global_arg1 );
/* =======================================================================
                        *** END OF DEATH PENALTY *** 
   ======================================================================= */
;;;;
run;

data spimlsrc.testuser3;
	length card $80;
	input card $char80.;
datalines4;
/* =======================================================================
   *** DO NOT CHANGE ANY OF THE FOLLOWING CODE UNDER PENALITY OF DEATH *** 
   ======================================================================= */
finish;

	/* load the stored matrices */
	load n_rel n_var n_cov n_covariates rel_pheno gamma;
	load nrows ncols index_x whereinx parm_value x0;
	load &load_matrices;

	/* 	first call to the function */
	fval = j(n_rel, 1, 0);
	f_scale = 1;
	xsave = x0;
	f = &function (x0);

/* =======================================================================
                        *** END OF DEATH PENALTY *** 
   ======================================================================= */
;;;;
run;
