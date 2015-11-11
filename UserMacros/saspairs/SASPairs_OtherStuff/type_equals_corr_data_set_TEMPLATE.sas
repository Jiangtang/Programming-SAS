/* -----------------------------------------------------------------
	Template for Analyzing a TYPE=CORR Data Set
	NOTE WELL: The data set MUST contain covariances (i.e., it must
		have a _TYPE_ variable with the value COV and the entries
		must be covariances. Use the COV option on the PROC CORR
		command to construct such a data set:
		PROC CORR COV DATA=input_data_set OUT=output_data_set;
   ----------------------------------------------------------------- */
data corr_template;
    infile datalines4 truncover;
	length card $80;
	input card $char80.;
datalines4;

BEGIN DATASETS
	        TYPE=CORR DATA SET = spothstf.twindata1_corr
	       TYPE=CORR RELATIVE1 = relative1
	       TYPE=CORR RELATIVE2 = relative2
	       TYPE=CORR VARIABLES = r1_iq -- r1_writing r2_iq -- r2_writing
	TYPE=CORR PHENOTYPE LABELS = iq reading writing
         RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL   VA, VC, FU
	begin matrices
		va
		vc
		vu
		fu L
	end matrices

	begin mx
		co va fu
		fi vu
	end mx;

	begin iml
		if pair_number = 1 then do;
			vu = fu * t(fu);
			p1 = va + vc + vu;
			p2 = p1;
		end;
		r12 = gamma_a * va + gamma_c * vc;
	end iml
END MODEL
;;;;
run;
%saspairs (corr_template);
