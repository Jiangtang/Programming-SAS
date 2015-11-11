/* ---------------------------------------------------------------------
	Documentation Example 12.1: The Common Pathway or Psychometric Model
   --------------------------------------------------------------------- */
data Example_12_dot_1;
	infile datalines4 truncover;
	length card $80;
	input card $char80.;
datalines4;

BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.twindata1
	     FAMILY ID VARIABLE = twinpair
	  RELATIONSHIP VARIABLE = zygosity2
	PHENOTYPES FOR ANALYSIS = reading writing vocab
	  RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL   Psychometric Model: General
	begin matrices
		va
		sa
		vc
		sc
		vu
		su
		asq v 1
		csq v 1
		usq v 1
		fpat v &np
	end matrices

	begin mx
		fi va vc vu
		co sa su
		fi 1 usq
	end mx

	begin iml
		if pair_number = 1 then do;
			temp = fpat * t(fpat);
			va = asq * temp + sa;
			vc = csq * temp + sc;
			vu = usq * temp + su;
			p1 = va + vc + vu;
			p2 = p1;
		end;
		r12 = gamma_a * va + gamma_c * vc;
	end iml
END MODEL
;;;;
run;
%saspairs(Example_12_dot_1);
