/* -------------------------------------------------------------------------
	Create SAS Data Set for Example 12.4
	National Merit Twin Data
  ------------------------------------------------------------------------- */
data spothstf.nmtwins;
	infile "&infilename";
	input pairnum zygosity english math socsci natsci vocab moed faed faminc;
	/* NOTE:
		zygosity: 1=mz, 2=dz
		english--vocab = substest of the Natinoal Merit Scholarship Qualifying Test
		moed faed faminc = mother's educatibon, father's education, family income
		seel Loehlin & Nichols (1976) for the codes for moed faed faminc
	*/
run;
