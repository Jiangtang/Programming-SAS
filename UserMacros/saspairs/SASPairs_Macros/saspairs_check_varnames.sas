%macro saspairs_check_varnames (dsname);
%* ----------------------------------------------------------------------------
   checks for valid variable names in the phenotypic or the TYPE=CORR data set
   NOTE: This macro is necessary because the varnum function does not work
         in IML
   ----------------------------------------------------------------------------;
%put NOTE: saspairs_check_varnames STARTING;
	%* forget it, if it is the same data;
	%if &same_data = 1 %then %goto final;
	%if &abort_job = YES %then %goto final;

	%macro errorit (vname);
		%let abort_job=YES;
		%put ERROR: Variable &vname not found in data set &dsname;
		%let printit = &printit %str(print , "*** ERROR *** VARIABLE &vname NOT FOUND IN DATA SET &dsname";);
	%mend errorit;

	%let printit=;
	%if %sysfunc(exist(&dsname)) = 0 %then %do;
		%let abort_job=YES;
		%put ERROR: Data set &dsname not found;
		%let printit = &printit %str(print , "*** ERROR *** DATA SET &dsname NOT FOUND.";);
		%goto final;
	%end;

	%let dsid = %sysfunc(open(temp_varnames));
	%let nobs = %sysfunc(attrn(&dsid,nobs));
	%let dsid2 = %sysfunc(open(&dsname));
	%do i = 1 %to 2;
		%let rc = %sysfunc(fetchobs(&dsid,&i));
		%let vname = %sysfunc(getvarc(&dsid,1));
		%if %saspairs_vname_triage(&vname, &dsid2) = 0 %then %errorit(&vname);
	%end;

	%* check variable names and create a list;
	%let varlist=;
	%do i=3 %to &nobs;
		%let rc = %sysfunc(fetchobs(&dsid,&i));
		%let vname = %sysfunc(getvarc(&dsid,1));
		%let vnum = %saspairs_vname_triage(&vname, &dsid2);
		%if &vnum = 0 %then
			%errorit(&vname);
		%else %do;
			%let varlist = &varlist &vname;
			%let vname2 = %sysfunc(getvarc(&dsid,2));
			%if &vname2 ^= &vname %then %do;
				%let vnum2 = %saspairs_vname_triage(&vname2, &dsid2);
				%if &vnum2 = 0 %then
					%errorit(&vname2);
				%else %if %eval(&vnum2 < &vnum) %then %do;
					%let abort_job = YES;
					%put ERROR: Variable &vname2 is not located after variable &vname;
					%let printit = &printit %str(print , "*** ERROR *** VARIABLE &vname2 IS NOT LOCATED AFTER &vname";);
				%end;
				%else %do;
					%do j=%eval(&vnum+1) %to &vnum2;
						%let vname = %sysfunc(varname(&dsid2, &j));
						%let varlist = &varlist &vname;
					%end;
				%end;
			%end;
		%end;
	%end;
	%* close the data sets;
	%let dsid = %sysfunc(close(&dsid));
	%let dsid = %sysfunc(close(&dsid2));
	%if &abort_job = YES %then %goto final; %* bug out;

	%* check for covariates;
%*put check_varnames: covariates=&covariates;
	%if &covariates = YES %then %do;
		%let first_cv =  %scan(&covariate_phenotypes_in, 1, %str( ));
		%let varlist1 =;
		%let covariate_phenotypes =;
		%let word=;
		%let switch=0;
		%do i=1 %to %saspairs_nwords(&varlist);
			%let word =  %scan(&varlist, &i, %str( ));
			%if &word = &first_cv %then %let switch = 1;
			%if &switch = 0 %then %let varlist1 = &varlist1 &word;
			%else %let covariate_phenotypes = &covariate_phenotypes &word;
		%end;
		%let n_covariates = %saspairs_nwords(&covariate_phenotypes);
	%end;
	%else %do;
		%let n_covariates = 0;
		%let covariate_phenotypes=;
		%let varlist1 = &varlist;
	%end;

	%* set macro variables;
	%if &data_set_type = DATA %then %do;
		%let phenotypes = &varlist1;
		%saspairs_check_dups(&phenotypes);
		%let n_phenotypes = %saspairs_nwords(&phenotypes);
		%let n_var = %eval(2 * &n_phenotypes);
		%let cov_phenotypes = %saspairs_cov_varnames (&phenotypes);
	%end;
	%else %do;
		%let cov_phenotypes = &varlist1;
		%saspairs_check_dups(&cov_phenotypes);
		%let n_var = %saspairs_nwords(&cov_phenotypes);
		%let odd = %sysfunc(mod(&n_var,2));
		%if &odd = 1 %then %do;
			%let abort_job = YES;
			%let printit = &printit %str(print , "*** ERROR *** ODD NUMBER OF VARIABLES FOR TYPE=CORR DATA SET:", "&cov_phenotypes";);
			%goto final;
		%end;
		%let n_phenotypes = %saspairs_nwords(&phenotypes);
		%if %eval(2*&n_phenotypes - &n_var ^= 0) %then %do;
			%let abort_job = YES;
			%let printit = &printit %str(print , "*** ERROR *** NO. OF PHENOTYPE LABELS NE .5*NO. OF TYPE=CORR VARIABLES";);
		%end;
	%end;
%*put n_phenotypes n_var = &n_phenotypes &n_var;
%*put phenotypes = &phenotypes;
%*put cov_phenotypes=&cov_phenotypes;	
%final:
	%if &printit ne %then %do;
		proc iml;
			&printit ;
		quit;
	%end;
	%put NOTE: saspairs_check_varnames FINISHED. abort_job=&abort_job;
%mend saspairs_check_varnames;
