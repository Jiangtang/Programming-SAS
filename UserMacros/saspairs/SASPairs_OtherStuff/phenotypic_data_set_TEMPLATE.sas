/* -----------------------------------------------------------------
	Template for Analyzing a Phenotypic Data Set
   ----------------------------------------------------------------- */
data phenotypic_template;
    infile datalines4 truncover;
	length card $80;
	input card $char80.;
datalines4;

BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.twindata1
	     FAMILY ID VARIABLE = twinpair
	  RELATIONSHIP VARIABLE = zygosity2
	PHENOTYPES FOR ANALYSIS = iq reading writing
	  RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL   VA, FU
	begin matrices
		va
		vc
		vu
		fu L
	end matrices

	begin mx
		co va fu
		fi vc vu
	end mx

	begin iml
		if pair_number = 1 then do;
			vu = fu * t(fu);
			p1 = va + vc + vu;
			p2 = p1;
		end;
		r12 = gamma_a * va + gamma_c * vc;
	end iml
END MODEL


BEGIN MODEL   VA, VC, FU
	begin matrices
		same
	end matrices

	begin mx
		fr vc
	end mx;

	begin iml
		same
	end iml
END MODEL
;;;;
run;
%saspairs(phenotypic_template);
