/* ------------------------------------------------------------
   Documentation Example 12.4: Using Covariates
	National Merit Twins (Loehlin & Nichols, 1976)
   ------------------------------------------------------------ */
data Example_12_dot_4;
	length card $80;
	input card $char80.;
datalines4;

BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.nmtwins
	     FAMILY ID VARIABLE = pairnum
	  RELATIONSHIP VARIABLE = zygosity
	PHENOTYPES FOR ANALYSIS = english math socsci natsci vocab;
	             COVARIATES = moed faed faminc
	  RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL  Family Demographics as Covariates
=================================================================
   1. matrix b contains the regression coefficients from the
   demographics to the common environment
   2. matrix vdemo is the variance covariance matrix for the
   demographics
   3. matrix vcdue2demo is the variance in Vc due to the
   demographics
   4. matrix covpdemo is the covariance matrix between the
   phenotypes and the demographics
=================================================================

	Begin Matrices
		va
		vc
		residuals_c s &np
		vu
		fu L
		b U 5 3
		vdemo S &nc
		vcdue2demo S &np
		covpdemo u &np &nc
	End Matrices

	Begin Mx
		fi vc vu vcdue2demo covpdemo
		co va fu
		st 1 diag(vdemo)
	End Mx

	Begin IML
		if pair_number=1 then do;
			vccv = vdemo;
			covpdemo = b * vdemo;
			p1cv = covpdemo;
			p2cv = covpdemo;
			vcdue2demo = covpdemo * t(b);
			vc = vcdue2demo + residuals_c;
			vu = fu*t(fu);
			p1 = va + vc + vu;
			p2 = p1;
		end;
		r12 = gamma_a*va + vc;
	End Iml
END MODEL
;;;;
%saspairs(Example_12_dot_4);
