/* ----------------------------------------------------------------------------
   Results after the minimizer
   ---------------------------------------------------------------------------- */

%let function_arg = %str("&function");
%let temp = %str(.sas);
%let function_include = &saspairs_source_dir&function&temp;
%put NOTE: RESULTS_AFTER_MINIMIZER STARTED.;
PROC IML;
%include "&put_x_file";
%include "&predicted_stats";
%include "&function_include";

/* ---------------------------------------------------------------------- 
	calculate the Hessian and final gradient
   ---------------------------------------------------------------------- */

	* --- load the matrices;
	load n_rel n_var n_cov n_covariates rel_pheno gamma fval;
	load nrows ncols index_x whereinx parm_value x0;
	load &load_matrices;
	load Rcode f xres;

	* --- initialize;
	_SP_Ng0 = .;
	_SP_Ngq = .;
	_SP_Maxg = .;
	_SP_BadHess = .;
	_SP_Norm = .;
	_SP_NegEvals = .;
	_SP_g = j(max(nrow(xres), ncol(xres)), 1, .);
	_SP_Span = _SP_g;
	_SP_SU20 =_SP_g;

	if (Rcode > 0 & Rcode < 10) | Rcode = -5 | Rcode = -8 then do;
		call NLPFDD(f, _SP_g, hess, &function_arg, xres);
		* check for row vs column vectors for printing;
		if ncol(xres) > nrow(xres) then xres = t(xres);
		if ncol(_SP_g) > nrow(_SP_g) then _SP_g = t(_SP_g);
		* --- stats for the gradient;
		_SP_Ng0 = 0;
		_SP_Ngq = 0;
		_SP_Maxg = 0;
		do i=1 to nrow(xres);
			_SP_Maxg = max(_SP_Maxg, abs(_SP_g[i]));
			if _SP_g[i] = 0 then _SP_Ng0=_SP_Ng0+1;
			if abs(_SP_g[i]) > .001 then _SP_Ngq=_SP_Ngq+1;
		end;
		* --- compute the norm and span, if possible;
		_SP_Span =j(nrow(xres), 1, .);
		evals = eigval(hess);
		if evals[nrow(xres)] > 0 then do;
			_SP_BadHess = 0;
			hessinv = inv(hess);
			_SP_norm = t(_SP_g) * hessinv * _SP_g;
			do i=1 to nrow(xres);
				if hessinv[i,i] > 0 then _SP_Span[i] = sqrt(hessinv[i,i]);
			end;
			_SP_SU20 = xres / _SP_Span;
			_SP_NegEvals=.;
		end;
		else do;
			_SP_BadHess = 1;
			_SP_norm=.;
			thisev = -1;
			do i=nrow(xres) to 1 by -1 until (thisev > 0);
				thisev = evals[i];
				if thisev < 0 then _SP_negevals = _SP_negevals // thisev;
			end;
			_SP_SU20 =j(nrow(xres), 1, .);
		end;
	end;

	* --- store the results for printing and AF routines;
 	store  _SP_g  _SP_Ng0  _SP_Ngq  _SP_Maxg  _SP_BadHess  _SP_norm
		   _SP_Span   _SP_SU20  _SP_NegEvals;

/* -------------------------------------------------------------------------------
   Calculate and Store the Fit Indices
   ------------------------------------------------------------------------------- */

START Cov_Fit_Indices (f);
* --- calculate and store fit indices for models fitted to covariance matrices;
	load n_rel Intraclass n_cov n_phenotypes df xres; 
	nfit = 5; /* number of fit indices */
	flabel = j(nfit, 1,'McDonald Measure of Centrality (MMoC)');
	fvalue = j(nfit, 1, 0);
	fdf    = j(nfit, 1, .);
	fp     = j(nfit, 1, .);
	/* chi square goodness of fit */
	flabel[1] = right('Chi2 Goodness-of-Fit');
	fvalue[1] = f;
	temp = 0;
	do i = 1 to n_rel;
		if Intraclass[i] = 0 then
			temp = temp + (n_cov*n_cov + n_cov)/2;
		else
			temp = temp + n_phenotypes*n_phenotypes + n_phenotypes;
	end; 
	fdf[1] = temp - max(nrow(xres), ncol(xres));
	if upcase("&macro_name") = "SASPAIRS_MEANS" then
		fdf[1] = fdf[1] + n_rel*n_cov;
	if f >=0 then fp[1] = 1 - probchi(f, fdf[1]);

	/* Akaike information criterion */
	flabel[2] = right('Akaike Information Criterion (AIC)');
	fvalue[2] = f - 2*fdf[1];

	/* consistent AIC */
	flabel[3] = right('Consistent AIC (CAIC)');
	ntotal = sum(df) + nrow(df);
	fvalue[3] = f - (log(ntotal) + 1)*fdf[1];

	/* bayesian */
	flabel[4] = right('Schwarz Bayesian Criterion (SBC)');
	fvalue[4] = f - (log(ntotal))*fdf[1];

	/* McDonalds Measure of Centrality */
	flabel[5] = right('McDonald Measure of Centrality (MMoC)');
	fvalue[5] = exp(-(f - fdf[1]) / (2*ntotal));

	/* --- store the fit indices for a summary table, if needed --- */
	store fvalue fdf fp;
FINISH;

	macro_name = upcase("&macro_name");
	load f xres;
	if macro_name = "SASPAIRS" | macro_name = "SASPAIRS_MEANS" then
		call cov_fit_indices (f);
	else do;
		number_of_parameters = nrow(xres);
		log_likelihood = f;
		store number_of_parameters log_likelihood;
	end;
QUIT;

%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: RESULTS_AFTER_MINIMIZER FINISHED. ABORT_JOB = &abort_job ;
