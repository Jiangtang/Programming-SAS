%macro saspairs_create_type_eq_corr (dataset, family_id, relation_code, phenotypes_in, 
		covariate_phenotypes_in, missing_values, vardef, relation_data_set,
        cov_data_set_name);
%*  ------------------------------------------------------------------------
	PURPOSE:
		Constructs a TYPE=CORR data set of relative pairs from a data set
		of individuals

	INPUT ARGUMENTS:
		dataset = name of the data set of individuals
		family_id = family_id ID variable
		relation_code = relation_codeship variable
		phenotypes_in = list of variables for analysis
		covariate_phenotypes_in = list of variates
		missing values = nomiss for listwise deletion
		vardef = divisor for variance (=N or =df)
		relation_data_set = name of the relationship data set
		cov_data_set_name = name of the resulting TYPE=CORR data set

	NOTES:
		1. input arguments do not have to be macro names
		2. there must be no more than two relatives per &family_id
		3. families with only one relative are deleted
		4. assumes few missing values and nonpatterned missing values
		5. default vardef for TYPE=CORR is N, not N - 1
		6. NOTE WELL: if an argument is not a macro name, then it cannot
		   be 32 characters
   ------------------------------------------------------------------------;

	%put NOTE: saspairs_create_type_eq_corr STARTING;
	%* --- error flag;
	%if &abort_job=YES %then %goto final;

%*put dataset=&dataset;
%*put family_id=&family_id;
%*put relation_code=&relation_code;
%*put phenotypes_in=&phenotypes_in;
%*put cov_phenotypes_in=&cov_phenotypes_in;
%*put covariate_phenotypes_in=&covariate_phenotypes_in;
%*put missing_values=&missing_values;
%*put vardef=&vardef;
%*put cov_data_set_name=&cov_data_set_name;

	%* --- initialize global macro variable same_data;
	%let same_data=0;

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
	%else %let vardef=N;

	%* --- check whether the variables names are in the dataset
	   NOTE: this macro also sets the following macro variables:
	   n_phenotypes, n_var, n_covariates, phenotypes, cov_phenotypes,
	   and covariate_phenotypes;

	%saspairs_check_varlist (&dataset, &family_id &relation_code);

	%* --- phenotypes;
	%let long_varlist=;
	%saspairs_check_varlist (&dataset, &phenotypes_in);
	%let phenotypes = &long_varlist;
	%let n_phenotypes = %saspairs_nwords(&phenotypes);
	%let n_var = %eval(2 * &n_phenotypes);
%*put check for phenotypes. abort_job = &abort_job;

	%* --- covariates;
	%if %quote(&covariate_phenotypes_in) ne %then %do;
%*put covariate_phenotypes_in=&covariate_phenotypes_in 123;
		%let long_varlist=;
		%saspairs_check_varlist (&dataset, &covariate_phenotypes_in);
		%let covariate_phenotypes = &long_varlist;
		%let n_covariates = %saspairs_nwords(&covariate_phenotypes); 
	%end;
	%else %do;
		%let n_covariates=0;
		%let covariate_phenotypes=;
	%end;
%*put after varlist abort_job = &abort_job;

	%* --- check for duplicate names;
	%saspairs_check_dups(&family_id &relation_code &phenotypes &covariate_phenotypes);

	%* --- bug out if there was an error in any of the varlists; 
	%if &abort_job=YES %then %goto final;

	%* --- construct macro variables;
	%let rel1 =;
	%let rel2 =;
	%do i=1 %to &n_phenotypes;
		%let thisvar = %scan(&phenotypes, &i, %str( ));
		%let rel1 = &rel1 R1_&thisvar;
		%let rel2 = &rel2 R2_&thisvar;
	%end;
	%let cov_phenotypes = &rel1 &rel2;
%*put rel1=&rel1;
%*put rel2=&rel2;
%*put cov_phenotypes=&cov_phenotypes;

	%* --- create a temporary data set, leaving the users data set unchanged;
	data _TMP_individuals (keep = &family_id &relation_code &phenotypes &covariate_phenotypes);
		set &dataset;
	run;

	%* --- sort the data set by family and relation;
	proc sort;
		by &family_id &relation_code;
	run;

	%* --- test for more than two relatives per family and proper relationship code;
	data _TMP_individuals;
		set _TMP_individuals nobs=temp_nobs;
		by &family_id;
		if temp_nobs = 0 then do;
			file print;
			put "*** ERROR *** DATA SET &dataset HAS NO PAIRS OF RELATIVES.";
			call symput ("abort_job", "YES");
			abort;
		end;
		if first.&family_id then temp_n=0;
		retain temp_n;
		temp_n = temp_n + 1;
		if &relation_code > 99 then do;
			call symput("abort_job", "YES");
			file print;
			put "*** ERROR *** &relation_code > 99. &relation_code &family_id= " &relation_code &family_id;
		end;
		if last.&family_id then do;
			if temp_n = 1 then do;
				temp = &family_id;
				file print;
				put "WARNING: &family_id =" temp "DELETED BECAUSE IT CONTAINS ONLY ONE OBSERVATION.";
				delete;
			end;
			if temp_n > 2 then do;
				call symput("abort_job", "YES");
				file print;
				put "*** ERROR *** MORE THAN TWO RELATIVES IN FAMILY: " &family_id;
			end;
		end;
		drop temp_n;
	run;
	%if &abort_job = YES %then %goto final;

	%* --- create data set pairs. NOTE: temp_relative1 and temp_relative2 used
	       in case the user has a variable Relative1 or Relative2;
	data _TMP_Pairs (rename=(temp_relative1=Relative1 temp_relative2=Relative2));
		set _TMP_individuals nobs=temp_nobs;
		by &family_id;
		length temp_relative1 temp_relative2 3;
		array temp_rel1array &rel1;
		array temp_rel2array &rel2;		
		array temp_phenoarray &phenotypes;
		retain temp_relative1 &rel1;
		keep &family_id temp_relative1 temp_relative2 &rel1 &rel2 &covariate_phenotypes;
		if first.&family_id then do;
			temp_relative1 = &relation_code;
			do over temp_rel1array; temp_rel1array = temp_phenoarray; end;
		end;
		if last.&family_id then do;
			temp_relative2 = &relation_code;
			do over temp_rel2array; temp_rel2array = temp_phenoarray; end;
			output;
		end;
	run;
	%if &abort_job = YES %then %goto final;
	%if &syserr ^= 0 %then %do;
		%put ERROR: ERROR IN CREATING DATA SET _TMP_Pairs;
		%let abort_job = YES;
		%goto final;
	%end;

	proc sort;
		by Relative1 Relative2;
	run;

	%* --- prepare the relationship data set for merging;
	DATA _TMP_RelDS (rename=(Label1=thisLabel1 Label2=thisLabel2));
		SET &relation_data_set;
		if intraclass = . then intraclass = 0;
		if Relative1 > Relative2 then do;
			temp=Relative1;
			Relative1=Relative2;
			Relative2=temp;
			tempc = Label1;
			Label1 = Label2;
			Label2 = tempc;
		end;
		DROP temp tempc;
	RUN;

	PROC SORT;
		BY Relative1 Relative2;
	RUN;

	%* --- merge, and double output the intraclass relationshsips;
	DATA _TMP_pairs;
		MERGE _TMP_pairs _TMP_RelDS;
		BY Relative1 Relative2;
		ARRAY temp_rel1array &rel1;
		ARRAY temp_rel2array &rel2;
		OUTPUT;
		IF Intraclass=1 THEN DO;
			DO OVER temp_rel1array;
				temp = temp_rel1array;
				temp_rel1array = temp_rel2array;
				temp_rel2array = temp;
			END;
			OUTPUT;
		END;
	RUN;

	%* --- create the TYPE=CORR data set;
	PROC CORR DATA=_TMP_pairs OUT=&cov_data_set_name COV NOPRINT VARDEF=&vardef &missing_values;
		by Relative1 Relative2;
		var &rel1 &rel2 &covariate_phenotypes;
	run;
	%if &syserr ^= 0 %then %do;
		%put ERROR: ERROR IN PROC CORR CREATING DATA SET &cov_data_set_name;
		%let abort_job = YES;
		%goto final;
	%end;

	%* --- merge with relationship data to get all the variables;
	%* --- first set lengths for the variables to make it easier to inspect the data set;
	%let dsid = %sysfunc(open(_TMP_RelDS));
	%let n1 = %sysfunc(varlen(&dsid, %sysfunc(varnum(&dsid, thisLabel1))) );
	%let n2 = %sysfunc(varlen(&dsid, %sysfunc(varnum(&dsid, thisLabel2))) );
	%let dsid = %sysfunc(close(&dsid));
%*put n1 n2 = &n1 &n2;
	%let len = %sysfunc(max(&n1, &n2));
	%if &len < 8 %then %let len=8;
	%else %if &len > 16 %then %let len=16;
%*put len = &len;
	%let vnlen = %length(&phenotypes &covariate_phenotypes);

	DATA &cov_data_set_name;
		LENGTH Label1 Label2 $&len Relative1 Relative2 Intraclass 3
               Gamma_A Gamma_C Gamma_D 8 VarNames $&vnlen;  
		merge _TMP_RelDS(in=a) &cov_data_set_name(in=b);
		by Relative1 Relative2;
		* --- correct sample size for intraclass relationships;
		Label1 = right(thisLabel1);
		Label2 = right(thisLabel2);
		VarNames = "&phenotypes &covariate_phenotypes";
		DROP thisLabel1 thisLabel2;
		array temp &rel1 &rel2 &covariate_phenotypes;
		if _type_ = 'N' & Intraclass=1 then do over temp;
			temp = .5*temp;
		end;
		if b=1 & a=0 then do;
			file log;
			put "ERROR: The following relationship pairing was not found in relationship "
			    "data set &relation_data_set:";
			put "Relative1=" Relative1 "    Relative2=" Relative2;
			call symput('abort_job', 'YES');
		end;
		if a=1 & b=1;
	run;

%final:
	%* if there has been no error, delete temp_ datasets;
	%if &abort_job = YES %then %do;
		DATA _null_;
			file print;
			put "*** ERROR *** Covariance data set not constructed. See SAS Log for error messages.";
		RUN;
	%end;
	%else %do;
		proc datasets library=work nolist;
			delete _TMP_individuals _TMP_pairs _TMP_RelDS;
		run;
		quit;
	%end;
	%put NOTE: saspairs_create_type_eq_corr FINISHED. abort_job=&abort_job;
%mend saspairs_create_type_eq_corr;
