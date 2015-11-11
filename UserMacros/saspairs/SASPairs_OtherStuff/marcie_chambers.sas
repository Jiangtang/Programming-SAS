/* -------------------------------------------------------
	marcie chambers phd thesis data
	McArthur Longitudinal Twin Study data
   ------------------------------------------------------- */
data spothstf.marcie_chambers;
	infile "&infilename";
	input pairnum zygosity Bay14 Bay20 Bay24 SB36 SB48 WISC7 Math7 Reading7 Math9 Reading9;
	label 	bay14    = "Bayley: 14 months"
			bay20    = "Bayley: 20 months"
			bay24    = "Bayley: 24 months"
			sb36     = "Stanford-Binet: 36 months"
			sb48     = "Stanford-Binet: 48 months"
			wisc7    = "WISC: 7 years"
			math7    = "Math Achievement: 7 years"
			reading7 = "Reading Achievement: 7 years"
			math9    = "Math Achievement: 9 years"
			reading9 = "Reading Achievement: 9 years";
	/* NOTE: zygosity values: 1=mz, 2=dz */
run;
