/* -----------------------------------------------------------------------
	Create data set for Example 12.6: Assortative Mating
	NOTE: Data downloaded from Mx web site and are stored in
		flat file asmat.cov; program kay_phillips.sas was used to
		create the TYPE=CORR data set. This is used to read in the
		test file kay_phillips2.dat and create a TYPE=CORR data set
   ----------------------------------------------------------------------- */
data spothstf.kay_phillips(type=corr);
	infile "&infilename";
	length _type_ $4 _name_ $7;
	input relative1 relative2 _type_ $ _name_ $ 
			h_iq h_educ h_extra h_anx h_tm h_ind
			w_iq w_educ w_extra w_anx w_tm w_ind;
	label
		h_iq    = "Hubby_IQ"
		h_educ  = "Hubby_Education"
		h_extra = "Hubby_Extraversion"
		h_anx   = "Hubby_Anxiety"
		h_tm    = "Hubby_ToughMinded"
		h_ind   = "Hubby_Independence"
		w_iq    = "Wife_IQ"
		w_educ  = "Wife_Education"
		w_extra = "Wife_Extraversion"
		w_anx   = "Wife_Anxiety"
		w_tm    = "Wife_ToughMinded"
		w_ind   = "Wife_Independence";
run;

