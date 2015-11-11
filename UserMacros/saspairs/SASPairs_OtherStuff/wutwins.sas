/* ---------------------------------------------------------------------
	WU Twins data set for Example 12.3
   --------------------------------------------------------------------- */
data spothstf.wutwins;
	infile "&infilename";
	length pair $3;
	input pair zygosity mpqf_pa mpqf_na mpqf_cn rasp ralcohol rdrugs;
	label
		mpqf_pa = "MPQ Positive Affect"
		mpqf_na = "MPQ Negative Affect"
		mpqf_cn = "MPQ Constraint"
		rasp    = "AntiSocial Personality"
		ralcohol= "Alcohol"
		rdrugs  = "Drugs";
	/* NOTE:
		zygosity: 1=mz, 2=dz
		MPQ = Multidimensional Personality Questinnaire, residuals from sex, age regression
				on factor scores
		rasp, ralcohol, rdurgs = residual from sex, age regression on combination of
								 diagnostic judgements and symptom counts 
	*/
run;

