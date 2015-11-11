%macro saspairs_check_relationship_ds;
%* ------------------------------------------------------------------
	checks the relationship data set
   ------------------------------------------------------------------;
	%if &relation_data_set ne %then %do;
		%let test = %sysfunc(exist(&relation_data_set));
		%if &test = 0 %then %do;
			%put ERROR: DATA SET &relation_data_set NOT FOUND;
			%let printit = &printit %str(print , "*** ERROR *** DATA SET &relation_data_set NOT FOUND";);
			%let abort_job = YES;
			%goto final;
		%end;
	%end;
	%else %do;
			%put ERROR: MACRO VARIABLE &relation_data_set NOT DEFINED;
			%let printit = &printit %str(print , '*** ERROR *** MACRO VARIABLE &relation_data_set NOT DEFINED';);
			%let abort_job = YES;
			%goto final;
	%end;

	%macro errorit (vname);
		%let abort_job = YES;
		%put ERROR: Variable &vname not found;
		%let printit = &printit %str(print , "*** ERROR *** VARIABLE &vname NOT FOUND";);
	%mend errorit;

	%let dsid = %sysfunc(open(&relation_data_set));
	%if %saspairs_vname_triage(relative1, &dsid) = 0 %then %errorit(Relative1);
	%if %saspairs_vname_triage(relative2, &dsid) = 0 %then %errorit(Relative2);
	%if %saspairs_vname_triage(label1, &dsid)    = 0 %then %errorit(Label1);
	%if %saspairs_vname_triage(label2, &dsid)    = 0 %then %errorit(Label2);
	%if %saspairs_vname_triage(gamma_a, &dsid)   = 0 %then %errorit(Gamma_a);
	%if %saspairs_vname_triage(gamma_c, &dsid)   = 0 %then %errorit(Gamma_c);
	%if %saspairs_vname_triage(gamma_d, &dsid)   = 0 %then %errorit(Gamma_d);
	%let dsid = %sysfunc(close(&dsid));
%final:
%mend saspairs_check_relationship_ds;
