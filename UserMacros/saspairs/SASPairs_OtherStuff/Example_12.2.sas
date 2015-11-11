/* =======================================================================
	Documentation Example 12.2: Illustration of the Same Convention
   ======================================================================= */
data Example_12_dot_2;
	length card $80;
	input card $char80.;
datalines4;

=======================================================================
	McArthur Twin Project Data: Marcie Chambers Ph.D. Thesis
	The variables are Bayley Scales at 14, 20, & 24 months and
		Stanford-Binet IQ at 36 months 
=======================================================================

BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.marcie_chambers
	     FAMILY ID VARIABLE = pairnum
	  RELATIONSHIP VARIABLE = zygosity
	PHENOTYPES FOR ANALYSIS = bay14 -- sb36
	  RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL   VA, VC=simplex, FU, equal simplex paths for VC
=======================================================================
	Fit the easiest model first: a simplex for VC with all simplex
		coefficients being equal
=======================================================================
	begin matrices
		va
		vc
		simplex_c U &np &np
		sc
		vu
		fu L
	end matrices

	begin mx
		co va fu
		fi simplex_c vc vu
		fr autoreg(simplex_c 1)
		eq autoreg(simplex_c 1)
	end mx

	begin iml
		if pair_number = 1 then do;
			temp = I(&np) - simplex_c;
			tempinv = inv(temp);
			vc = tempinv * sc * t(tempinv);
			vu = fu * t(fu);
			p1 = va + vc + vu;
			p2 = p1;
		end;
		r12 = gamma_a * va + gamma_c * vc;
	end iml
END MODEL

BEGIN MODEL   VA, VC=simplex, FU, free simplex paths for VC
=======================================================================
	Now let the simplex paths all be free parameters
	Note that the starting values for the other matrices are taken from
		their final parameter estimates. This helps the current model
		to converge, although it does not guarantee convergence.
=======================================================================

	begin matrices
		same
	end matrices

	begin mx
		fr autoreg(simplex_c 1)
	end mx

	begin iml
		same
	end iml
END MODEL


BEGIN MODEL   VA=simplex, VC=simplex, VU, equal simplex parms for VA
=======================================================================
	Now let VA be also modeled by a simplex with equal coefficients
	Note that the starting values for the simplex coefficient is .5
		This is reasonable because one expects genetic covariances
		that will be greater than 0
=======================================================================

	begin matrices
		same
		simplex_a U &np &np
		sa
	end matrices

	begin mx
		fi va simplex_a
		fr autoreg(simplex_a 1)
		eq autoreg(simplex_a 1)
		st .5  simplex_a  2 1
		co sa
	end mx

	begin iml
		if pair_number = 1 then do;
			temp = I(&np) - simplex_a;
			tempinv = inv(temp);
			va = tempinv * sa * t(tempinv);
			temp = I(&np) - simplex_c;
			tempinv = inv(temp);
			vc = tempinv * sc * t(tempinv);
			vu = fu * t(fu);
			p1 = va + vc + vu;
			p2 = p1;
		end;
		r12 = gamma_a * va + gamma_c * vc;
	end iml
END MODEL

BEGIN MODEL   VA=simplex, VC=simplex, VU, free simplex parms for VA
=======================================================================
	Free the simplex parms for VA
=======================================================================

	begin matrices
		same
	end matrices

	begin mx
		fr simplex_a 3 2 4 3
	end mx

	begin iml
		same
	end iml
END MODEL

;;;;
run;
%saspairs_raw_nomeans(Example_12_dot_2);
