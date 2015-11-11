/* ---------------------------------------------------------------------------- 
	CALL TO THE MINIMIZER
   ---------------------------------------------------------------------------- */
%let function_arg = %str("&function");
%let temp = %str(.sas);
%let function_include = &saspairs_source_dir&function&temp;
%put NOTE: CALL_TO_MINIMIZER STARTED.;
PROC IML;
%include "&put_x_file";
%include "&predicted_stats";
%include "&function_include";
start grd (x, nbad);
/* -----------------------------------------------------------
	Calculates the gradient using central differences
  ----------------------------------------------------------- */
	eps = constant("MACEPS");
	eta = eps**(1/3);
	n = max(nrow(x), ncol(x));
	nbad = 0;
	do i = 1 to n;
		h = eta*(1 + abs(x[i]));
		xsave = x[i];
		x[i] = x[i] - h;
		fmh = &function (x);
		x[i] = xsave + h;
		fph = &function (x);
		x[i] = xsave;
		g = (fph - fmh) / (2*h);
		if abs(g) > .001 then nbad=nbad+1;
	end;
finish;

/* ---------------------------------------------------------------------- 
	load matrices
   ---------------------------------------------------------------------- */
	load n_rel n_var n_cov n_covariates rel_pheno gamma;
	load nrows ncols index_x whereinx parm_value x0;
	load &load_matrices;
	load model_output_label;
	mattrib model_output_label label='';
	print , '----------------------------------------------------------------------',
	        "Minimizing Using NLPQN and &function ",
		    model_output_label,
	        '----------------------------------------------------------------------';
	free model_output_label;

/* ---------------------------------------------------------------------- 
	options for minimization: see SAS DOCUMENTATION
   ---------------------------------------------------------------------- */
	opt = {0 0};
	opt[2] = &opt2;       /* amount of printed output */
	tcopt = j(10, 1, .);     /* termination criteria */
/* ---------------------------------------------------------------------- 
	first call the function to check on the validity of start values
   ---------------------------------------------------------------------- */
	fval = j(n_rel,1,0);
	f_scale = 1;
	fstart = &function (x0);
	if fstart = . then do;
		print "*** ERROR *** STARTING VALUES GAVE DET(PREDICTED COV) <= 0.";
		call symput("abort_job", "YES");
	end;
	do; /* stupid do statement */
		if fstart = . then goto final; /* bug out */
/* ---------------------------------------------------------------------- 
	GTOL termination criterion = tc[4]
   ---------------------------------------------------------------------- */
		if &gtol > 0 then
			gtol = &gtol;
		else do;
			gtol = 1E-8;
			order = min(8, log10(abs(fstart)));
			if order > 3 then gtol = 10**(-6 - order);
		end;
		tcopt[4] = gtol;
/* ---------------------------------------------------------------------- 
	ABSGTOL termination criterion = tc[6]
   ---------------------------------------------------------------------- */
		if &absgtol > 0 then
			absgtol = &absgtol;
		else
			absgtol = 1E-4;
		tcopt[6] = absgtol;
/* ---------------------------------------------------------------------- 
	FTOL termination criterion = tc[7]
	NOTE: There is no option to change this yet
   ---------------------------------------------------------------------- */
		ftol = constant("MACEPS");
		tcopt[7] = ftol;
/* ---------------------------------------------------------------------- 
	call the minimizer
   ---------------------------------------------------------------------- */
		xstart = x0;
		nbad = 1;
		rcode = 0;
		mattrib i       label='' format=1.0;
		mattrib rcode   label='' format=3.0;
		mattrib nbad    label='' format=3.0;
		mattrib f       label='' format=best15.;
		mattrib gtol    label='' format=E10.;
		mattrib absgtol label='' format=E10.;
		mattrib ftol    label='' format=E10.;
		print , "Calls to NLPQN: Gtol=" gtol "  Absgtol=" absgtol "Ftol=" ftol;
		* --- calling the minimizer;
		do i=1 to 2 until (nbad=0);
			call nlpqn (rcode, xres, &function_arg, xstart, opt,, tcopt);
			*if (rcode > 0 & rcode < 10) then call grd (xres, nbad);
			call grd (xres, nbad);
			print , "Call" i "  RC=" rcode "  Bad Derivatives=" nbad "  f=" f;
			xstart = xres;
		end;
		print , "Minimization completed.";

		* --- store the results;
		store f_scale fstart gtol f fval rcode xres &global_arg2 parm_value;

	final:
	end;

QUIT;

%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: CALL_TO_MINIMIZER FINISHED. ABORT_JOB = &abort_job ;
