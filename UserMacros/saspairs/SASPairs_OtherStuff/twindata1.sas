/* --------------------------------------------------------------------------
	Simulated Twin Data on Cognitive Abilities and Achievement
	used in the SASPairs Manual
   -------------------------------------------------------------------------- */
data spothstf.twindata1;
	infile "&infilename";
	input twinpair sex age zygosity1 zygosity2 iq reading writing vocab
		  math geometry science civics;
run;
