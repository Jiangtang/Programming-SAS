%macro saspairs_ghess;
%* --- force computation of the hessian and gradient;
	%let saspairs_ghess = YES;
	%let function_arg = %str("&function");
	%let temp = %str(.sas);
	%let function_include = &saspairs_source_dir&function&temp;

	%put NOTE: SASPairs_GHess STARTED.;
	%if %upcase(&macro_name) = SASPAIRS OR %upcase(&macro_name) = SASPAIRS_MEANS %then
		%let temp = covariance_output.sas;
	%else
		%let temp = likelihood_output.sas;
	%let includefile = &saspairs_source_dir&temp;
	%let temp = minimizer_output.sas;
	%let temp = &saspairs_source_dir&temp;
	%include "&temp";
	%put NOTE: SASPairs_GHess FINISHED.;
	%let thissyserr = &syserr;
	%saspairs_syserr(&thissyserr);

	%let saspairs_ghess = NO;
%mend;

