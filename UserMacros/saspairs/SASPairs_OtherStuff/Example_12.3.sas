/* =======================================================================
	Documentation Example 12.3: Example of a Mediation Model
	Washington University Twin Study
   ======================================================================= */
data Example_12_dot_3;
	length card $80;
	input card $char80.;
datalines4;

BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.wutwins
	     FAMILY ID VARIABLE = pair
	  RELATIONSHIP VARIABLE = zygosity
	PHENOTYPES FOR ANALYSIS = mpqf_na mpqf_cn rasp ralcohol
	  RELATIONSHIP DATA SET = spothstf.twins_no_sex_differences
END DATASETS

BEGIN MODEL   Example of a Mediation Model

	begin matrices
		va
		vc
		vu
		fu L
		b U &np &np
		imbinv U &np &np
	end matrices

	begin mx
		co va fu
		fi 0 block (va 1 3 2 4) block (vc 1 3 2 4) block (fu 3 1 4 2)
		fi b imbinv vu
		fr block(b 3 1 4 2)

	end mx

	begin iml
		if pair_number = 1 then do;
			imbinv = inv(I(&np) - b);
			vu = fu * t(fu);
			p1 = imbinv * (va + vc + vu) * t(imbinv);
			p2 = p1;
		end;
		tempcov = gamma_a * va + gamma_c * vc;
		r12 = imbinv * tempcov * t(imbinv);
	end iml
END MODEL

;;;;
run;
%saspairs(Example_12_dot_3);

/* --- pos processing --- */
proc iml;
	/* this statement loads all the parameter matrices from the model
		it is equivalent to the statement
		load va vc vu fu b imbinv; */
	load &global_arg2;
	/* calculate the total additive genetic covariance matrix */
	va_total = imbinv * va * t(imbinv);
	/* print both va and va_total to illustrate the effect */
	mattrib va label="VA for A Variables in Figure X.X" format=8.3;
	mattrib va_total label="Total VA" format=8.3;
	print va,, va_total;
	/* calculate the mediated effect and the unique part of
		va_total for antisocial behavior and alcohol problems */
	temp = va_total[3:4, 3:4];
	va_unique = va[3:4, 3:4];
	va_mediated = temp - va_unique;
	/* convert these to percents of total genetic variance */
	pct_va_unique = 100 * va_unique / temp;
	pct_va_mediated = 100 * va_mediated / temp;
	/* print out the matrices */
	print , va_mediated [format=8.3] va_unique [format=8.3];
	print , "Percentages of total genetic variance mediated and unique:"
		  , pct_va_mediated [format=8.3] pct_va_unique[format=8.3];
	/* how much of the phenotypic variance and covariance is
		attributable to the mediated and the unique parts? */
	vp_total = imbinv*(va + vc + vu)*t(imbinv);
	temp = vp_total[3:4,3:4];
	hsq_unique = 100 * va_unique / temp;
	hsq_mediated = 100 * va_mediated / temp;
	print , "Heritability * 100 for mediated and unique parts:"
		  , hsq_mediated [format=8.3] hsq_unique [format=8.3];
quit;
