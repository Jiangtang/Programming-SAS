/* -----------------------------------------------------------
   Documentation Example 12.9: Interactive SASPairs
	NOTE: This uses the code from Example 12.7
   ----------------------------------------------------------- */

/* --- Step 1: Submit the three data sets to SAS --- */
data Model1;
	length card $80;
	input card $char80.;
datalines4;
BEGIN DATASETS
	    PHENOTYPIC DATA SET = spothstf.twindata1
	     FAMILY ID VARIABLE = twinpair
	  RELATIONSHIP VARIABLE = zygosity1
	PHENOTYPES FOR ANALYSIS = iq reading math
	  RELATIONSHIP DATA SET = spothstf.twins_sex_differences
END DATASETS
BEGIN MODEL   VAf, VAm=Ta*VAf*Ta, VCf=Vcm, Vuf=Vum
=============================================================
	Diagonal scaling differences in VA, VC, and VU:
		VA_males = Ta * VA_females * Ta
		where Da = diagonal scaling matrix
		VC_males = Tc * VC_females * Tc
		VU_males = Tu * VU_females * Tu
=============================================================
	begin matrices
		vaf
		vam
		ta d &np
		vcf
		vcm
		tc d &np
		vuf
		vum
		fu L
		tu d &np
	end matrices
	begin mx
		co vaf fu
		fi vam vcm vuf vum
		st 1 ta tc tu
		fi tc tu
	end mx;
	begin iml
		/* --- constant matrices --- */
		if pair_number = 1 then do;
			vam = ta * vaf * ta;
			vcm = tc * vcf * tc;
			vuf = fu * t(fu);
			vum = tu * vuf * tu;
		end;
		/* --- predicted matrices --- */
		if pair_number <= 2 then do; * SS Females;
			p1 = vaf + vcf + vuf;
			p2 = p1;
			r12 = gamma_a * vaf + gamma_c * vcf;
		end;
		else if pair_number <= 4 then do; * SS Males;
			p1 = vam + vcm + vum;
			p2 = p1;
			r12 = gamma_a * vam + gamma_c * vcm;
		end;
		else do; * OS females\male;
			p1 = vaf + vcf + vuf;
			p2 = vam + vcm + vum;
			r12 = gamma_a * vaf * ta + gamma_c * vcf * tc;
		end;
	end iml
END MODEL
;;;;
run;

data Model2;
	length card $80;
	input card $char80.;
datalines4;
BEGIN DATASETS
	    SAME
END DATASETS
BEGIN MODEL   VAf, VAm=Ta*VAf*Ta, VCf, Vcm=Tc*Vcf*Tc, Vuf=Vum
	begin matrices
		same
	end matrices
	begin mx
		fr tc
	end mx;
	begin iml
		same
	end iml
END MODEL
;;;;
run;

data Model3;
	length card $80;
	input card $char80.;
datalines4;
BEGIN DATASETS
	    SAME
END DATASETS
BEGIN MODEL   VAf, VAm=Ta*VAf*Ta, VCf, Vcm=Tc*Vcf*Tc, Vuf, Vum=Tu*Vuf*Tu
	begin matrices
		same
	end matrices
	begin mx
		fr tu
	end mx;
	begin iml
		same
	end iml
END MODEL
;;;;
run;

/* --- reinitialize SASPairs to clear out the old IML Storage --- */
%saspairs_initialize;

/* --- call SAPairs for the first model --- */
%saspairs(Model1);

/* --- store the fit indices --- */
%saspairs_append_fit_indices;

/* --- fit the second model --- */
%saspairs(Model2);

/* --- try two refits --- */
%saspairs_refit(2);

/* --- try jiggling the parameter estimates --- */
%saspairs_jiggle(.02);

/* --- try a more stringent GTOL value --- */
%let gtol =1e-12;
%saspairs_refit(1);

/* --- this worked fine, so store the fit indices --- */
%saspairs_append_fit_indices;

/* --- reset GTOL to its default and fit the third model --- */
%let gtol = 0;
%saspairs(Model3);

/* --- try a different GTOL since that worked before --- */
%let gtol = 1e-12;
%saspairs_refit(1);

/* --- reset GTOL, append fit indices, and print the summary --- */
%let gtol = 0;
%saspairs_append_fit_indices;
%saspairs_print_summary;
