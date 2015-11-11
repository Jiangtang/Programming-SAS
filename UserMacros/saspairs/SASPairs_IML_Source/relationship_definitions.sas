/* ---------------------------------------------------------------------- 
	CONSTRUCTS THE MATRICES FROM RELATION_DATA_SET
   ---------------------------------------------------------------------- */
%put NOTE: RELATION DATA SET DEFINITIONS STARTING;
%let printit=;
%saspairs_check_relationship_ds;
proc iml; 
	do; /* very stupid do statement */
		aborttest = upcase(trim(left("&abort_job")));
		if aborttest = 'YES' then do;
			&printit ;
		end;
		if aborttest='YES' then goto final;
		
		use &relation_data_set;
			read all var {Relative1 Relative2} into rel_in;
			read all var {label1 label2} into label_in;
			read all var {gamma_a gamma_c gamma_d} into gamma_in;
		close &relation_data_set;

		/* swap relationship values so that the lowest comes first (to agree with
		   the order in the sorted phenotypic data set */
		n_relin = nrow(rel_in);
		do i=1 to n_relin;
			if rel_in[i,1] > rel_in[i,2] then do;
				save = rel_in[i,1];
				rel_in[i,1] = rel_in[i,2];
				rel_in[i,2] = save;
				save = label_in[i,1];
				label_in[i,1] = label_in[i,2];
				label_in[i,2] = save;
			end;
		end;

		/* printed output */
		if "&SPPrint_RelDSInfo" = "YES" then do;
			print , '---------------------------------------------------------------------',
			        "Relationship Data Set: &relation_data_set",
	 		        '---------------------------------------------------------------------';
			cn1 = {'Relative1' 'Relative2'};
			cn2 = {'  Label1' '  Label2'};
			cn3 = {'gamma_a' 'gamma_c' 'gamma_d'};
			mattrib rel_in   colname=cn1 label='';
			mattrib label_in colname=cn2 label='';
			mattrib gamma_in colname=cn3 label='';
			label_in = right(label_in);
			print  rel_in label_in gamma_in;
		end;

		store n_relin rel_in label_in gamma_in;
		call symput("rel_data_stored", "1");

	final:
	end;
quit;
%put NOTE: RELATION DATA SET DEFINITIONS FINISHED. ABORT_JOB = &abort_job ;
