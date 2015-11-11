/* ------------------------------------------------------------------------------
	places matrices into storage for use in the subsequent IML calls
   ------------------------------------------------------------------------------ */
%put NOTE: STORE_MATRICES STARTING.;
proc iml;
start first_word (string, change);
/* --- extract the first word in a string and 
	(1) if chenge = 0 then leave the string alone
	(2) if change ne 0 then remove the word from the string --- */
	temp = trim(left(string));
	space = index(temp, ' ');
	if space <= 1 then do;
		word = trim(left(temp));
		if change ^= 0 then string = ' ';
	end;
	else do;
		word = substr(temp,1,space-1);
		if change ^= 0 then string = substr(temp,space);
	end;
	return (word);
finish;

start store_vars (aborttest);
	n_phenotypes=&n_phenotypes;;
	n_var = &n_var;

	string = "&phenotypes";
	varnames = " ";
	do until (string = " ");
		word = first_word(string, 1);
		varnames = varnames // word;
	end;
	varnames = varnames[2:nrow(varnames)];

	string = "&cov_phenotypes";
	svarnames = " ";
	do until (string = " ");
		word = first_word(string, 1);
		svarnames = svarnames // word;
	end;
	svarnames = svarnames[2:nrow(svarnames)];
	
	/* add covariates, if present */
	n_covariates = 0;
	if "&covariates" = "YES" then do;
		n_covariates = &n_covariates;
		string = "&covariate_phenotypes";
		cvarnames = " ";
		do until (string = " ");
			word = first_word(string, 1);
			cvarnames = cvarnames // word;
		end;
		cvarnames = cvarnames[2:nrow(cvarnames)];
		svarnames = svarnames // cvarnames;
	end;
	n_cov = n_var + n_covariates;
	store n_phenotypes n_var n_covariates n_cov varnames svarnames;
finish;

/* --- MAIN IML --- */
	aborttest = upcase(trim(left("&abort_job")));
	if aborttest ^= "YES" then call store_vars (aborttest);
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: STORE_MATRICES FINISHED. ABORT_JOB = &abort_job ;
