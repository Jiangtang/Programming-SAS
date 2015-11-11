/* ----------------------------------------------------------------------
	These are the Relationship Data Sets used in the SASPairs Manual
  ---------------------------------------------------------------------- */

/* --- MZ and DZ twins: no sex differences --- */
data spothstf.twins_no_sex_differences;
	length Relative1 Relative2 3.0 label1 label2 $2;
	input Relative1 Relative2 Label1 $ Label2 $ Gamma_A Gamma_C Gamma_D;
datalines;
1 1 mz mz 1.0 1.0 1.00
2 2 dz dz 0.5 1.0 0.25
run;

/* --- twins, no sex differenes, intraclass --- */
DATA spothstf.twins_no_sex_diffs_intraclass;
     LENGTH Relative1 Relative2 3 Label1 Label2 $2 Intraclass 3;
     INPUT Relative1 Relative2  Label1 $ Label2 $ Intraclass Gamma_A Gamma_C Gamma_D;
DATALINES;
1 1 MZ MZ 1 1.0000 1 1.00
2 2 DZ DZ 1 0.5000 1 0.25
RUN;

/* --- MX and DZ twins: sex differences --- */
data spothstf.twins_sex_differences;
	length Relative1 Relative2 3.0 label1 label2 $6;
	input Relative1 Relative2 @5 Label1 $char6. @12 Label2 $char6. Gamma_A Gamma_C Gamma_D;
datalines;
1 1   mz_f   mz_f 1.0 1 1
2 2   dz_f   dz_f 0.5 1 0.25
3 3   mz_m   mz_m 1.0 1 1
4 4   dz_m   dz_m 0.5 1 0.25
5 6 dzos_f dzos_m 0.5 1 0.25
run;


/* --- MX and DZ twins: sex differences, intraclass --- */
data spothstf.twins_sex_diffs_intraclass;
	length Relative1 Relative2 3.0 label1 label2 $6 Intraclass 3;
	input Relative1 Relative2 @5 Label1 $char6. @12 Label2 $char6. Intraclass Gamma_A Gamma_C Gamma_D;
datalines;
1 1   mz_f   mz_f 1 1.0 1 1
2 2   dz_f   dz_f 1 0.5 1 0.25
3 3   mz_m   mz_m 1 1.0 1 1
4 4   dz_m   dz_m 1 0.5 1 0.25
5 6 dzos_f dzos_m 0 0.5 1 0.25
run;

/* --- Nuclear Families, no sex differences  --- */
data spothstf.nuc_fams_no_sex_diffs;
	length Relative1 Relative2 3 label1 label2 $8;
	input Relative1 Relative2 @5 Label1 $char8. @14 Label2 $char8. Gamma_A Gamma_C Gamma_D;
datalines;
1 1   parent   parent  0.0 0 0
1 2   parent offsprng  0.5 1 0
2 2 offsprng offsprng  0.5 1 0.25
run;

/* --- Nuclear Families, no sex differences, Intraclass  --- */
data spothstf.nuc_fams_no_sex_diffs_Intraclass;
	length Relative1 Relative2 3 label1 label2 $8 Intraclass 3;
	input Relative1 Relative2 @5 Label1 $char8. @14 Label2 $char8. Intraclass Gamma_A Gamma_C Gamma_D;
datalines;
1 1   parent   parent  1 0.0 0 0
1 2   parent offsprng  0 0.5 1 0
2 2 offsprng offsprng  1 0.5 1 0.25
run;


/* --- Nuclear Families, sex differences  --- */
data spothstf.nuc_fams_sex_diffs;
	length Relative1 Relative2 3.0 label1 label2 $8;
	input Relative1 Relative2 @5 Label1 $char8. @14 Label2 $char8. Gamma_A Gamma_C Gamma_D;
datalines;
1 2   father   mother  0.0 0 0
1 3   father      son  0.5 1 0
1 4   father daughter  0.5 1 0
2 3   mother      son  0.5 1 0
2 4   mother daughter  0.5 1 0
3 3      son      son  0.5 1 0.25
3 4      son daughter  0.5 1 0.25
4 4 daughter daughter  0.5 1 0.25
run;

/* --- Nuclear Families, sex differences, Intraclass --- */
data spothstf.nuc_fams_sex_diffs_Intraclass;
	length Relative1 Relative2 3.0 label1 label2 $8 Intraclass 3;
	input Relative1 Relative2 @5 Label1 $char8. @14 Label2 $char8. Intraclass Gamma_A Gamma_C Gamma_D;
datalines;
1 2   father   mother  0 0.0 0 0
1 3   father      son  0 0.5 1 0
1 4   father daughter  0 0.5 1 0
2 3   mother      son  0 0.5 1 0
2 4   mother daughter  0 0.5 1 0
3 3      son      son  1 0.5 1 0.25
3 4      son daughter  0 0.5 1 0.25
4 4 daughter daughter  1 0.5 1 0.25
run;

/* -- Nuclear Families (to keep consistent with beta version) --- */
data spothstf.nuclear_families;
	set spothstf.nuc_fams_sex_diffs;
run;
