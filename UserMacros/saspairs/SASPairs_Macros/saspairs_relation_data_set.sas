%macro saspairs_relation_data_set;
%* ----- Relationship Data Set -------------------------------------;
	%if %sysfunc(exist(&relation_data_set)) %then %do;
		%let relation_vars = Relative1 Relative2 Label1 Label2 gamma_a gamma_c gamma_d;
		%let ok=;
		%saspairs_test_variables(&relation_data_set, &relation_vars);
		%if &ok ^= 1 %then
			%let abort_job = YES;
		%else %do;
			%let temp = relationship_definitions.sas;
			%let temp = &saspairs_source_dir&temp;
			%include "&temp";
		%end;
	%end;
	%else %do;
		%put ERROR: RELATION DATA SET &relation_data_set NOT FOUND;
		%let abort_job = YES;
	%end;
%mend saspairs_relation_data_set;
