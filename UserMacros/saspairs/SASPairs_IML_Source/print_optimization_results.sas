/* ---------------------------------------------------------------------------
   IML code to print output from the minimizer
   --------------------------------------------------------------------------- */
%put NOTE: PRINT_OPTIMIZATION_RESULTS STARTED.;
PROC IML;
%include "&put_x_file";
%include "&predicted_stats";

START corrit (matrix);
* --- puts correlations in the upper triangle;
	do i=1 to nrow(matrix);
		do j=i+1 to nrow(matrix);
			if matrix[i,i] > 0 & matrix[j,j] > 0 then do;
				bottom = matrix[i,i]*matrix[j,j];
				matrix[i,j] = matrix[i,j] / sqrt(bottom);
			end;
			else 
				matrix[i,j] = .;
		end;
	end;
FINISH;

START uncorrit (matrix);
* --- transform back to a covariance matrix;
	do i=1 to nrow(matrix);
		do j = i+1 to nrow(matrix);
			matrix[i,j] = matrix[j,i];
		end;
	end;
FINISH;

START rcode_codes (rcode, gtol);
* --- return codes from NLPQN;
	pos_code = {'ABSTOL'  'ABXFTOL'  'ABSGTOL'  'ABSXTOL'  'FTOL'  'GTOL' 
				'XTOL'    'FTOL2'   'GTOL2'};
	neg_codes = {
		"Function cannot be evaluated at the STARTing point",
		"Gradient cannot be evaluated at the STARTing point",
		"Function could not be evaluated during an iteration",
		"Gradient could not be evaluated during an iteration",
		"Cannot improve on the current function value",
		"Problem with linearly dependent, active constraints",
		"Optimization stepped outside of feasible region and could not return",
		"Maximum number of iterations or function calls",
		"SAS has a big problem here",
		"Feasible STARTing point could not be computed"};

	mattrib msg label='';
	mattrib msg2 label='';
	mattrib gtol label='' format=E8.;
	if rcode > 0 & rcode < 10 then do;
		temp = trim(left(pos_code[rcode]));
		msg = concat(temp, ' ', 'convergence criterion satisfied.');
		if rcode=6 then
			print , msg "GTOL=" gtol;
		else
			print , msg;
	end;
	else if rcode < 0 then do;
		msg = "WARNING! ABNORMAL TERMINATION IN THE OPTIMIZER:";
		msg2 = neg_codes[-rcode];
		PRINT , msg, msg2;
	end;
	else do;
		msg = "Return code out of bounds--check sas manual.";
		print , msg rcode;
	end;

FINISH;


START opt_summary (model_output_label);
* --- summary of the optimization;
	mattrib model_output_label label='';
	print '---------------------------------------------------------------------',
	      "Minimization Results",
		  model_output_label,
	      '---------------------------------------------------------------------';

	* --- return code;
	load rcode gtol;
	call rcode_codes (rcode, gtol);

	* --- warning messages;
	if (rcode > 0 & rcode < 10) | rcode = -5 | rcode=-8 then do;
		load _SP_BadHess;
		if _SP_BadHess = . then
			print , 'WARNING: Gradient and Hessian could not be computed.';
		else if _SP_BadHess = 1 then do;
			load _SP_NegEvals;
			mattrib _SP_NegEvals label='';
			print , "WARNING: Hessian has an eigenvalue <= 0",
			        "         Solution may not be at a minimum.",
					"         Norm and Span not computed.",
				    "Negative Eigenvalues:", _SP_NegEvals;
		end;
	end;

	* --- initial output;
	load fstart f _SP_Norm;
	mattrib fstart   label='' format=best15.;
	mattrib f        label='' format=best15.;
	mattrib _SP_norm label='' format=E10.;
	print , "Initial function value =" fstart ,
	        "  Final function value =" f,
			"     t(g) * Inv(H) * g =" _SP_norm;
FINISH;


START parm_print (dummy);
* --- prints the final parameters; 

	* --- flag values;
	load xres parm_label _SP_g  _SP_Span  _SP_SU20  _SP_Ng0  _SP_ngq;
	if nrow(xres) = 1 then xres = t(xres);
	flag = j(nrow(xres), 1, " ");
	do i=1 to nrow(xres);
		if _SP_g[i] = 0 then flag[i] = '0';
		else if abs(_SP_g[i]) > .001 then flag[i] = '*';
	end;

	* --- list of parm values;
	pn = 1:nrow(xres);
	pn = t(pn);
	mattrib pn		    label="    N"			format=4.0;
	mattrib parm_label  label="Parameter";
	mattrib xres	    label="    Final_value"	format=15.4;
	mattrib _SP_Span    label="      Span" 		format=10.4;
	mattrib _SP_SU20    label=" SUnitsTo0"		format=10.2;
	mattrib _SP_g		label="       Gradient"	format=15.6;
	mattrib flag	    label='';
	mattrib _SP_Ngq		label=''				format=3.0;
	print , "Final Estimates:";
	print , pn parm_label xres  _SP_Span  _SP_SU20  _SP_g flag,
	       "Gradient Codes: blank ==> ok,  * ==> |g| > .001,  0 ==> g = 0";
	if _SP_Ngq > 0 then print , "WARNING:" _SP_Ngq "gradient elements with |g| > .001";

	if _SP_Ng0 > 0 then do;
		load x0;
		do i=1 to nrow(_SP_g);
			if _SP_g[i] = 0 & x0[i]=xres[i] then do;
				mattrib i label='' format=3.0;
				print , "WARNING: Parameter" i "may not be identified.";
			end;
		end;
	end;

FINISH;

START covariance_output (model_output_label, f, fval, rcode, xres);

	/* --- observed and predicted matrices --- */
	if "&SPPrint_ObsPre" = "YES" then
		call observed_and_predicted (xres, model_output_label);

	if "&SPPrint_FitIndex" = "YES" then do;
		mattrib model_output_label label='';
		print / '----------------------------------------------------------------------',
		        "Contribution of Each Group to Chi2 Goodness-of-Fit",
			    model_output_label,
		        '----------------------------------------------------------------------';

		mattrib rel_pheno    colname={'Relative1' 'Relative2'} label='';
		mattrib rel_label    colname={'  Label1' '  Label2'}   label='';
		mattrib df           colname='N'                       label='' format=6.0;
		if "&vardef" = "DF" then
		mattrib df           colname='df'                      label='' format=6.0;
		mattrib fval         colname='Chi2'                    label='' format=10.3;
		load rel_pheno rel_label df;
		print , rel_pheno rel_label df fval;

		print, '----------------------------------------------------------------------',
		       "Fit Indices",
			   model_output_label,
		       '----------------------------------------------------------------------';
		flabel = {
			'Chi Square Goodness-of-Fit',
		    'Akaike Information Criterion (AIC)',
			'Consistent AIC (CAIC)',
			'Schwarz Bayesian Criterion (SBC)', 
			'McDonald Measure of Centrality (MMoC)'};
		mattrib flabel colname='Fit Index' label='';
		mattrib fvalue colname='Value'     label='' format=12.3;
		mattrib fdf    colname='df'        label='' format=8.0;
		mattrib fp     colname = 'p'       label='' format=10.4;
		load fvalue fdf fp;
		print ,flabel fvalue fdf fp;
	end;
FINISH;

START observed_and_predicted (x, model_output_label); 
/* ----------------------------------------------------------------------------
	Prints predicted and (observed - predicted) cov\corr matrices
   ---------------------------------------------------------------------------- */
	load n_rel n_var n_cov n_covariates rel_pheno cov_mats gamma
		 index_x rel_label whereinx parm_value nrows ncols svarnames &global_arg2;
	mattrib pre rowname=svarnames colname=svarnames format=8.3 
			label="Predicted Cov\Corr Matrix";
	mattrib dif rowname=svarnames colname=svarnames format=8.3
			label="Observed - Predicted Cov\Corr Matrix";
	mattrib rel1 colname='' rowname='' label='';
	mattrib rel2 colname='' rowname='' label='';
	mattrib label colname='' rowname='' label='';
	mattrib model_output_label colname='' rowname='' label='';

	/* put the iterated parameters into the vector of full parameter values */
	do i=1 to nrow(whereinx);
		if whereinx[i] ^= 0 then parm_value[i] = x[whereinx[i]];
	end;

	/* put the parameters into the user defined matrices */
	call put_x_into_matrices (parm_value, index_x, nrows, ncols);

	print / '----------------------------------------------------------------------',
	        "Predicted and (Observed - Predicted) Statistics",
		    model_output_label,
	        '----------------------------------------------------------------------';
	printmeans = 0;
	if "&macro_name" = "SASPAIRS_MEANS" then do;
		printmeans = 1;
		load mean_vecs;
		maxlen = max(length(svarnames));
		rowlabel = "Means";
		if maxlen > 5 then do;
			do i = 6 to maxlen;
				rowlabel = concat(" ",rowlabel);
			end;
		end;
		mattrib prem rowname=rowlabel colname=svarnames format=8.3 label="Predicted Means";
		mattrib difm rowname=rowlabel colname=svarnames format=8.3 
				label="Observed - Predicted Means";
	end;

	badsolution=0;
	stop = 0;
	do i = 1 to n_rel;
		pairnum = i;
		bad_f_value = 0;
		call predicted_stats (pairnum, rel_pheno[i,1], rel_pheno[i,2], gamma[i,1],
							  gamma[i,2], gamma[i,3], p1, p2, r12, p1cv, p2cv, vccv,
							  mean_vector, bad_f_value);
		if n_covariates = 0 then
			pre = (p1 || r12) // (t(r12) || p2);
		else
			pre = (p1 || r12 || p1cv) // (t(r12) || p2 || p2cv) //
				  (t(p1cv) || t(p2cv) || vccv) ;
		detpre = det(pre);
		minev = min(eigval(pre));
		call corrit (pre);
		start = stop + 1;
		stop = start + n_cov - 1;
		obs = cov_mats[start:stop,];
		call corrit (obs);
		dif = obs - pre;
		rel1 = trim(left(rel_label[i,1]));
		rel2 = trim(left(rel_label[i,2]));
		label = concat(rel1," and ", rel2);
		if printmeans = 1 then do;
			prem = mean_vector;
			if ncol(prem) < nrow(prem) then prem = t(prem);
			difm = t(mean_vecs[,i]) - prem;
			print , "-------------------------" label "-------------------------", prem, difm,
					pre, dif;
		end;
		else
			print , "-------------------------" label "-------------------------", pre, dif;
		if bad_f_value = 1 then do;
			badsolution = 1;
			print , "WARNING: bad_f_value=1 for this group.";
		end;
		if detpre <= 0 then do;
			badsolution = 1;
			mattrib detpre label='';
			print , "WARNING: Det(predicted) <= 0. Det =" detpre;
		end;
		if minev <= 0 then do;
			badsolution=1;
			mattrib minev label='';
			print , "WARNING: eigenvalue <= 0. Minimum eigenvalue =" minev;
		end;
	end;
	if badsolution = 1 then
		print , "WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING! WARNING!",
		        "This is an improper solution and results should not be interpreted.",
				"Check model identification / Try different starting values.";
FINISH;

START likelihood_output (model_output_label, f, fval, rcode, xres);
	mattrib model_output_label label='';
	print / '---------------------------------------------------------------------',
	        "Contribution of Each Group to the Overall Likelihood",
		    model_output_label,
	        '---------------------------------------------------------------------';

	/* calculate the sample size for each pair type */
	load n_rel n_configs sample_size;
	n = j(n_rel,1,0);
	count=0;
	do i=1 to n_rel;
		do j=1 to n_configs[i];
			count=count+1;
			n[i] = n[i] + sample_size[count];
		end;
	end;
	fval2 = fval / n;
	mattrib rel_pheno    colname={'Relative1' 'Relative2'} label='';
	mattrib rel_label    colname={'  Label1'  '  Label2'} label='';
	mattrib n            colname='     n'         label='' format = 6.0;
	mattrib fval         colname='    -2Log(L)'   label='' format = 12.3;
	mattrib fval2        colname='  -2Log(L)/n'   label='' format = 12.3;
	if upcase(substr("&macro_name", 1, 7)) = "SASPEDS" then do;
		load rel_pheno;
		print rel_pheno n fval fval2;
	end;
	else do;
		load rel_pheno rel_label;
		print rel_pheno rel_label n fval fval2;
	end;

	mattrib f colname='Sample -2Log(L)' label='' format=15.3;
	print f;
	
FINISH;

/* ---------------------------------------------------------------------------------------
   Main IML Code:
   --------------------------------------------------------------------------------------- */

	load model_output_label;
	CALL opt_summary (model_output_label);

	if "&SPPrint_FinalParms" = "YES" then CALL parm_print (model_output_label);

	if "&SPPrint_ParmMats" = "YES" then  do;
		mattrib model_output_label label='';
		print / '---------------------------------------------------------------------',
		        'Parameter Matrices',
			    model_output_label,
		        '---------------------------------------------------------------------';
		load &global_arg2 varnames;
		%saspairs_call_corrit;
		%saspairs_mattrib_statements;
		%saspairs_print_parm_matrices;
		%saspairs_call_uncorrit;
	end;

	load f fval rcode xres;
	macro_name = upcase("&macro_name");
	if macro_name = "SASPAIRS" | macro_name = "SASPAIRS_MEANS" then
		call covariance_output (model_output_label, f, fval, rcode, xres);
	else if "&SPPrint_FitIndex" = "YES" then
		call likelihood_output (model_output_label, f, fval, rcode, xres);
QUIT;

%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: PRINT_OPTIMIZATION_RESULTS FINISHED.;
