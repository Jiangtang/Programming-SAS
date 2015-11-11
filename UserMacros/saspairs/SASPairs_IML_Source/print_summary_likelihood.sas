
%put NOTE: PRINT SUMMARY (LIKELIHOOD) STARTING;
proc iml;

	load fit_index_label save_fit_indices;
	number_of_models =nrow(fit_index_label);
	rc = save_fit_indices[,1];
	number_of_parameters = save_fit_indices[,2];
	log_likelihood = save_fit_indices[,3];

	/* get the labels for the output */
	do i=1 to number_of_models;
		chari = trim(left(char(i)));
		temp = concat(chari, ': ', fit_index_label[i]);
		biglabel = biglabel // temp;
		len = min(24, length(temp));
		temp = substr(temp, 1, len);
		smalllabel = smalllabel // temp;
	end;

	print , '---------------------------------------------------------------------',
	        "Summary of Model Fit Indices",
	        '---------------------------------------------------------------------';
	mattrib biglabel label ='' colname="Model Number and Title";
	print , biglabel;

	mattrib smalllabel             label="Model:";
	mattrib rc					 label='  RC'         format = 4.0;
	mattrib number_of_parameters label=' N_Parms'     format = 8.0;
	mattrib log_likelihood       label='    -2Log(L)' format = 12.3;
	print , smalllabel rc number_of_parameters log_likelihood;

	/* --- likelihood ratio statistics --- */
	n = (number_of_models*number_of_models - number_of_models) / 2;
	do i=1 to number_of_models;
		do j = i+1 to number_of_models;
			tr1 = smalllabel[i];
			tr2 = smalllabel[j];
			tdf = number_of_parameters[i] - number_of_parameters[j];
			tchi = log_likelihood[j] - log_likelihood[i];
			if tdf < 0 then do;
				/* reverse everything */
				tdf = -tdf;
				tchi = -tchi;
				tr1 = smalllabel[j];
				tr2 = smalllabel[i];
			end;
			if tdf > 0 & tchi > 0 then do;
				tp = 1 - probchi(tchi, tdf);
				row1 = row1 // tr1;
				row2 = row2 // tr2;
				lrdf = lrdf // tdf;
				lrchi = lrchi // tchi;
				lrp = lrp // tp;
			end;
		end;
	end;
	/* get rid of the first row */
	n = nrow(lrchi);
	if n >= 1 then do;
		mattrib row1   label="More General Model:";
		mattrib row2   label="Constrained Model:";
		mattrib lrdf   label="   LR_df"   format=8.0;
		mattrib lrchi  label="   LR_Chi2" format=10.2;
		mattrib lrp    label="   LR_p"    format=7.3;
		print ,
              '---------------------------------------------------------------------',
		      "Likelihood Ratio Statistics",
			  "***** NOTE WELL: THESE STATISTICS ARE INAPPROPRIATE FOR MODELS THAT",
			  "*****            ARE NOT NESTED",
		      '---------------------------------------------------------------------';
		print , row1 row2 lrdf lrchi lrp;
	end;

quit;
%put NOTE: PRINT SUMMARY (LIKELIHOOD) FINISHED. ABORT_JOB = &abort_job;
