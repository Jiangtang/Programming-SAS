%macro saspairs_variable_sibship_size (dataset, family, relation, phenotypes, 
		covariates, missing_values, vardef, relation_data_set, cov_data_set);
%* ------------------------------------------------------------------------
	PURPOSE:
		Constructs a TYPE=CORR data set for all possible sib
		pairs and changes the value of N to the ad hoc weight of
		k(hmean - 1) where k = number of families, and hmean =
		harmonic mean of sibship size

	INPUT ARGUMENTS:
		dataset = name of the data set of individuals
		family = family ID variable
		relation = relationship variable
		phenotypes = list of variables for analysis
		covariates = list of covariates
		vardef = divisor for CSSCP matrix (=N or df)
		missing_values = if blank , then pairwise if NOMISS, then listwise
		relation_data_set = relationship data set
		cov_data_set = name of the TYPE=CORR data set

	NOTES:
		1. the value of &relation must be less than 100
		2. assumes few missing values and nonpatterned missing values
		3. be very careful of using this for anything other than
		   sibships or other types of intraclass relationships.
		   the code will work, but there is no guarantee that the weights
		   will give a good approximation
		4. the value for the covariates must be the same for all
		   members of the family.
   ------------------------------------------------------------------------ ;

	%put NOTE: saspairs_variable_sibship_size STARTING;
	%* --- error flag;
	%let abort_job=NO;

	%* --- illegal parameters for PROC CORR;
	%if %quote(&missing_values) ne & %upcase(&missing_values) ^= NOMISS %then %do;
		%put ERROR: Illegal value for argument MISSING_VALUES: &missing_values;
		%put ERROR- Argument must be either null or NOMISS;
		%let abort_job=YES;
	%end;
	%if %quote(&vardef) ne %then %do;
		%if %upcase(&vardef) ^= N & %upcase(&vardef) ^= DF %then %do;
			%put ERROR: Illegal value for argument VARDEF: &vardef;
			%put ERROR- Valid values are N or DF;
			%let abort_job=YES;
		%end;
	%end;
	%else %let vardef = N;

	%* check variable names;
	%saspairs_check_varlist (&dataset, &family &relation);

	%* --- phenotypes;
	%let long_varlist=;
	%saspairs_check_varlist (&dataset, &phenotypes);
	%let phenotypes = &long_varlist;

	%* --- covariates;
	%if %quote(&covariates) ne %then %do;
		%let long_varlist=;
		%saspairs_check_varlist (&dataset, &covariates);
		%let covariates = &long_varlist;
	%end;

	%* --- skip on errors;
	%if &abort_job=YES %then %goto final;

	%* names for the covariance variables;
	%let rel1=;
	%let rel2=;
	%do i=1 %to %saspairs_nwords(&phenotypes);
		%let thisvar = %scan(&phenotypes, &i, %str( ));
		%let rel1 = &rel1 R1_&thisvar;
		%let rel2 = &rel2 R2_&thisvar;
	%end;
	%let cov_phenotypes = &rel1 &rel2;

	%* --- temporary data set so that users original data are preserved;
	PROC SORT DATA = &dataset
              OUT  = _TMP_individuals (keep = &family &relation &phenotypes);
		BY &family &relation;
	RUN;

	%* --- IML to create all possible pairs;
	proc iml;
	start addemupandspitemout (lastfamily, thisrel, thisx, data_family, data_relpairs,
					data_scores, temp_rel, temp_scores);
		n = nrow(thisrel);
		if n = 1 then return; /* ignore singletons */
		do i=1 to n;
			do j=i+1 to n;
				data_family = data_family // lastfamily;
				temp_rel[1] = thisrel[i];
				temp_rel[2] = thisrel[j];
				temp_rel[3] = 100*thisrel[i] + thisrel[j];
				data_relpairs = data_relpairs // temp_rel;
				temp_scores = thisx[i,] || thisx[j,];
				data_scores = data_scores // temp_scores;
			end;
		end;
	*print data_family data_relpairs;
	finish;
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

	/* --- MAIN IML --- */
		use _TMP_individuals;
			read all var {&family} into family;
			read all var {&relation} into relation;
			read all var {&phenotypes} into x;
		close _TMP_individuals;

		/* number of phenotypes */
		np = ncol(x);

		/* bug out if there is a relative value > 99
		   because it will mess up variable sort_rel */
		maxrel = max(relation[1:nrow(relation)]);
		if maxrel > 99 then call symput ('abort_job', 'YES');
		if maxrel > 99 then call goto final;

		data_family = j(1, 1, 0);
		data_relpairs = j(1, 3, 0);
		data_scores = j(1, 2*np, 0);
		temp_rel = j(1,3,0);
		temp_scores = j(1, 2*np, 0);
		lastfamily = family[1];
		thisrel = relation[1];
		thisx = x[1,];
		ninv = 0;
		totfams = 0;
		count = 1;
		do while (count < nrow(family));
			count = count + 1;
			if family[count] = lastfamily then do;
				thisrel = thisrel // relation[count];
				thisx = thisx // x[count,];
			end;
			else do;
				call addemupandspitemout (lastfamily, thisrel, thisx, data_family, 
					data_relpairs, data_scores, temp_rel, temp_scores);
				lastfamily = family[count];
				thisrel = relation[count];
				thisx = x[count,];
			end;
		end;
		/* output the last family */
		call addemupandspitemout (lastfamily, thisrel, thisx, data_family, 
					data_relpairs, data_scores, temp_rel, temp_scores);

		/* matrix for creating the data set */
		temp = data_family || data_relpairs || data_scores;
		/* eliminate the first row */
		temp = temp[2:nrow(temp),];
		/* labels for output */
		cn = {"&family" "Relative1" "Relative2" "sort_rel"};
		* --- NOTE WELL: if phrase is longer than 262 characters, you may get a
		warning message in the log;
		phrase = "&cov_phenotypes";
		do until (phrase = " ");
			word = first_word(phrase,1);
			cn = cn || word;
		end;
		create _TMP_allpairs from temp [colname=cn];
		append from temp;

		final:
	quit;

	%* skip if there is an error;
	%if &abort_job=YES %then %do;
		%put ERROR: VALUE OF &relation > 99.;
		%put ERROR- TYPE=CORR DATA SET &cov_data_set WILL NOT BE CREATED.;
		%goto final;
	%end;

	%* add covariates, if present;
	%if &covariates ne %then %do;
		%* create a data set of the covariates;
		PROC SORT DATA = &dataset
				  OUT  = _TMP_cv (keep = &family &covariates);
			BY &family;
		RUN;
		DATA _TMP_cv;
			SET _TMP_cv;
			BY &family;
			IF first.&family;
		RUN;
		PROC SORT DATA=_TMP_Allpairs;
			BY &family;
		RUN;
		DATA _TMP_allpairs;
			MERGE _TMP_allpairs _TMP_cv;
			BY &family;
		RUN;
		%let cov_phenotypes = &cov_phenotypes &covariates;
	%end;

	%* --- calculate the harmonic mean of sibship size and the weight
	       for the covariance matrix for a pair;
	PROC SORT DATA=_TMP_allpairs;
		BY sort_rel &family;
	RUN;

	data _TMP_hmean (keep = relative1 relative2 weight);
		set _TMP_allpairs;
		by sort_rel &family;
		if first.sort_rel then do;
			hmean = 0;
			ntot = 0;
			sum_ninv = 0;
			n = 0;
		end;
		retain hmean ntot sum_ninv n;
		if first.&family then do;
			ntot = ntot + 1;
			n = 0;
		end;
		n = n + 1;
		if last.&family then do;
			k = .5 * (1 + sqrt(1 +8*n) ); 
			sum_ninv = sum_ninv + 1/k;
		end;
		if last.sort_rel then do;
			hmean = sum_ninv / ntot;
			hmean = 1 / hmean;
			weight = ntot * (hmean - 1);
			output;
		end;
	run;

	* --- prepare the relationship data set for merging;
	DATA _TMP_RelDS (keep = Relative1 Relative2 Intraclass);;
		SET &relation_data_set;
		if Relative1 > Relative2 then do;
			temp = Relative1;
			Relative1 = Relative2;
			Relative2 = temp;
		end;
		DROP temp;
	RUN;

	PROC SORT;
		BY Relative1 Relative2;
	RUN;

	* --- merge and double output all intraclass relationships;
	DATA _TMP_allpairs;
		MERGE _TMP_Allpairs _TMP_RelDS;
		BY Relative1 Relative2;
		ARRAY Rel1 [*] &rel1;
		ARRAY Rel2 [*] &rel2;
		output;
		if Intraclass=1 then do;
			do i=1 to dim(Rel1);
				temp = Rel1[i];
				Rel1[i] = Rel2[i];
				Rel2[i] = temp;
			end;
			output;
		end;
		DROP i temp;
	RUN;

	%* --- covariance matrix;
	proc corr cov data=_TMP_allpairs vardef=&vardef &missing_values out=&cov_data_set noprint;
		by relative1 relative2;
		var &cov_phenotypes;
	run;

	%* --- Replace N by the weighted N;
	data &cov_data_set;
		merge &cov_data_set _TMP_hmean;
		by relative1 relative2;
		if _type_ = "N" then do;
			array v &cov_phenotypes;
			do over v; v = weight; end;
			drop weight;
		end;
	run;

%final:
	%if &abort_job=YES %then
		%put ERROR: TYPE=CORR data set &cov_data_set not created because of errors.;
	%else %do;
		%let blank =;
		%if &covariates = &blank %then %let varlist = _TMP_Individuals _TMP_Allpairs _TMP_Hmean _TMP_RelDS;
		%else %let varlist = _TMP_Individuals _TMP_Allpairs _TMP_Hmean _TMP_RelDS _TMP_cv;
		PROC DATASETS LIBRARY=work NOLIST NODETAILS;
			DELETE &varlist;
		RUN;
		QUIT;
	%end;
%mend saspairs_variable_sibship_size;
