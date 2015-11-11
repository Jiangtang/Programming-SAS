%macro saspairs_check_varlist (dataset, varlist);
*% --- (1) checks that all variables in &varlist are in &dataset
       (2) creates macro name long_varlist that has all variable
           names without double hyphens
       (3) NOTE: declare macro variable Long_Varlist in the
           calling routine to get the full variable list without
           double hyphens
       (3) NOTE WELL: if varlist is not a macro variable, then it
           cannot be longer than 32 characters;

	%* --- check for null varlist;
	%if %quote(&varlist) ne %then %let nwords = 0;
	%else %do;
		%put ERROR: Null variable list.;
		%let abort_job=YES;
		%goto final;
	%end;

	%* --- open the data set;
	%if %sysfunc(exist(&dataset)) = 0 %then %do;
		%let ABORT_JOB=YES;
		%put ERROR: Data set &dataset not found.;
		%goto final;
	%end;
	%let dsid = %sysfunc(open(&dataset));

	%* --- initialize long_varlist;
	%let long_varlist=;

	%* --- make certain that double hyphens are delimited by blanks;
	%let string2 = %sysfunc(tranwrd(&varlist, %str(--), %str( -- )) );

	%let nwords = %saspairs_nwords(&string2);
	%do i = 1 %to &nwords;
		%let thisvar = %scan(&string2, &i, %str( ));
		%if %quote(&thisvar) = %str(--) %then %do;
			%if &i = 1 %then %do;
				%let abort_job = YES;
				%put ERROR: Illegally placed double hyphen: &varlist;
			%end;
			%else %if &i = &nwords %then %do;
				%let abort_job = YES;
				%put ERROR: Illegally placed double hyphen: &varlist;
			%end;
			%else %do;
				%let thisvar = &savevar;
				%let thatnum = 0;
				%let i = %eval(&i + 1);
				%let thatvar = %scan(&string2, &i, %str( ));
				%let thatnum = %sysfunc(varnum(&dsid, &thatvar));
				%if %eval(&thatnum = 0 | &thatnum = .) %then %do;
					%let abort_job = YES;
					%put ERROR: Variable &thatvar not found in data set &dataset.;
				%end;
				%else %if %eval(&thatnum < &thisnum) %then %do;
					%let abort_job = YES;
					%put ERROR: Variable &thatvar does not come after variable &thisvar in data set &dataset.;
				%end;
				%else %do j = %eval(&thisnum + 1) %to &thatnum;
					%let thisvar = %sysfunc(varname(&dsid, &j));
					%let long_varlist = &long_varlist &thisvar;
				%end;
				%if %eval(&thatnum > 0) %then %let thisnum = &thatnum;
			%end;
		%end;
		%else %do;
			%let thisnum = %sysfunc(varnum(&dsid, &thisvar));
			%if %eval(&thisnum = 0 | &thisnum = .) %then %do;
				%let abort_job = YES;
				%put ERROR: Variable &thisvar not found in data set &dataset.;
			%end;
			%else %do;
				%let savevar = &thisvar;
				%let long_varlist = &long_varlist &thisvar;
			%end;
		%end;
	%end;
	%let dsid = %sysfunc(close(&dsid));

%final:
	%if &abort_job=YES %then %do;
		%put ERROR: Bad variable list for data set &dataset.;
		%put ERROR: Variable list = &varlist;
		%put ERROR: Program will abort after all variable lists are checked.;
	%end;
%mend;
