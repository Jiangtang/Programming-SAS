/* -----------------------------------------------------------------------------
	append fit indices for printing summary output
   ----------------------------------------------------------------------------- */
proc iml;
start append_covariance (thislabel);
/* --- store the fit indices, etc. for a summary table: Covariance Data --- */
	load rcode fvalue fdf fp;
	if "&fit_indices_stored" = "0" then do;
		save_fit_indices = j(1,8,0);
		save_fit_indices[1] = rcode;
		save_fit_indices[2] = fvalue[1];
		save_fit_indices[3] = fdf[1];
		save_fit_indices[4] = fp[1];
		save_fit_indices[5] = fvalue[2];
		save_fit_indices[6] = fvalue[3];
		save_fit_indices[7] = fvalue[4];
		save_fit_indices[8] = fvalue[5];
		fit_index_label = thislabel;
	end;
	else do;
		load save_fit_indices fit_index_label;
		temp = j(1,ncol(save_fit_indices),0);
		temp[1] = rcode;
		temp[2] = fvalue[1];
		temp[3] = fdf[1];
		temp[4] = fp[1];
		temp[5] = fvalue[2];
		temp[6] = fvalue[3];
		temp[7] = fvalue[4];
		temp[8] = fvalue[5];
		save_fit_indices = save_fit_indices // temp;
		fit_index_label = fit_index_label // thislabel;
	end;
	store save_fit_indices fit_index_label;
	call symput ("fit_indices_stored", "1");
finish;

start append_likelihood (thislabel);
/* --- store the fit indices, etc. for a summary table: Likelihood --- */
	load rcode number_of_parameters log_likelihood;
	if "&fit_indices_stored" = "0" then do;
		save_fit_indices = j(1,3,0);
		save_fit_indices[1] = rcode;
		save_fit_indices[2] = number_of_parameters;
		save_fit_indices[3] = log_likelihood;
		fit_index_label = thislabel;
	end;
	else do;
		load save_fit_indices fit_index_label;
		temp = j(1,ncol(save_fit_indices),0);
		temp[1] = rcode;
		temp[2] = number_of_parameters;
		temp[3] = log_likelihood;
		save_fit_indices = save_fit_indices // temp;
		fit_index_label = fit_index_label // thislabel;
	end;
	store save_fit_indices fit_index_label;
	call symput ("fit_indices_stored", "1");
finish;

/* --- MAIN IML --- */
	load current_model model_names;
	thislabel = model_names[current_model];

	if "&macro_name" = "SASPAIRS" | "&macro_name" = "SASPAIRS_MEANS" then
		call append_covariance (thislabel);
	else 
		call append_likelihood (thislabel);
quit;
