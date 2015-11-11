/* -----------------------------------------------------------------------
	Documentation Example 12.6: Using Auxiliary Macros: Assortative Mating
	Kay Phillips assortative mating data: taken from Mx Manual 
   ----------------------------------------------------------------------- */
data Example_12_dot_6;
	%saspairs_input_card(96);
datalines4;
BEGIN DATASETS
	        TYPE=CORR DATA SET = spothstf.kay_phillips
	       TYPE=CORR RELATIVE1 = relative1
	       TYPE=CORR RELATIVE2 = relative2
	       TYPE=CORR VARIABLES = h_iq -- w_ind
	TYPE=CORR PHENOTYPE LABELS = iq education extrav neurot tough_mind independ
         RELATIONSHIP DATA SET = spothstf.nuclear_families
END DATASETS
BEGIN MODEL   H Phenotypic = W Phenotypic, Standardized Diagonal D
	begin matrices
		fu L
		d d &np
	end matrices
	begin mx
		co fu
	end mx
	begin iml
		p1 = fu*t(fu);
		p2 = p1;
		/* inverse of the standard deviations */
		invstd = inv(sqrt(diag(p1)));
		/* unstandardized D matrix */
		d_unstandardized = invstd * d * invstd;
		r12 = p1*d_unstandardized*p2;
	end iml
END MODEL
;;;;
run;
%saspairs (Example_12_dot_6);
