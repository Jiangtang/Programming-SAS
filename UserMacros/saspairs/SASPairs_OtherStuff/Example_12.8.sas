/* -------------------------------------------------------------------------
	Example 12.8 Fitting Models to Data on Individuals
	NOTE: Example is from SAS Online Documentation, SAS/STAT User's Guide,
		  Introcution to Structural Equations with Latent Variables
   ------------------------------------------------------------------------- */

data Example_12_dot_8;
	%saspairs_input_card(80);
datalines4;
BEGIN DATASETS
	        TYPE=CORR DATA SET = spothstf.aspire
	       TYPE=CORR RELATIVE1 = relative1
	       TYPE=CORR RELATIVE2 = relative2
	       TYPE=CORR VARIABLES = riq rpa rses fiq fpa fses rea roa fea foa
	TYPE=CORR PHENOTYPE LABELS = v1 v2 v3 v4 v5
         RELATIONSHIP DATA SET = spothstf.twins_sex_differences
END DATASETS

Begin Model SAS CALIS Example: Analysis 1
	Begin Matrices
		covx s 6 6
		gam u 6 2
		beta u 2 2
		v_latent s 2 2
		lambda u 4 2
		theta d 4
		wholepre s 10 10
	End Matrices
	Begin Mx
		st 1 diag(covx) theta
		fi wholepre  beta 1 1 2 2
		pa gam
			1 0
			1 0
			1 1
			0 1
			0 1
			1 1
		pa lambda
			0 0
			1 0
			0 0
			0 1
		fi 1 lambda 1 1 3 2
	End Mx
	Begin IML
		wholepre[1:6,1:6] = covx;
		temp = inv(I(2) - beta) * t(gam);
		vcov_latent = temp * covx * t(temp) + v_latent;
		wholepre[7:10, 7:10] = lambda * vcov_latent * t(lambda) + theta;
		tempcov = lambda * temp * covx;
		wholepre[7:10, 1:6] = tempcov;
		wholepre[1:6, 7:10] = t(tempcov);
		/* matrix partitions for SASPairs */
		p1 = wholepre[1:5, 1:5];
		p2 = wholepre[6:10, 6:10];
		r12 = wholepre[1:5, 6:10];
	End IML
End Model
;;;;
%saspairs(Example_12_dot_8);
