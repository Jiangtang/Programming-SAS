/* --------------------------------------------------
	sas data sets for dataset definitions help
   -------------------------------------------------- */
data spguihlp.fams;
	input FamName $ FamNum Rel1 Rel2 Do Re Mi;
datalines;
Smith 203 1 1 6.2 8.3 9.0
Smith 203 2 2 7.3 5.2 8.8
Smith 203 3 3 7.9 6.0 5.4
Jones 373 2 2 5.8 6.7 4.2
Jones 373 3 4 3.7 6.3 4.2
Jones 373 3 3 6.2 5.5 7.1
Jones 373 3 4 7.2 6.1 4.9
run;
*proc print;
*run;

data spguihlp.Nuclear_family1 (Label='Nuclear Family: No sex difference in offspring');
	length Relative1 Relative2 3 Label1 Label2 $9;
	input Relative1 Relative2 @5 Label1 $char9. @15 Label2 $char9. Gamma_A Gamma_D Gamma_C
		  Intraclass;
datalines;
1 2    Father    Mother 0.0 0.0  0 0
1 3    Father Offspring 0.5 0.0  1 0
2 3    Mother Offspring 0.5 0.0  1 0
3 3 Offspring Offspring 0.5 0.25 1 1
run;
*proc print;
*run;


data spguihlp.Nuclear_family2 (Label='Nuclear Family: Sex difference in offspring');
	length Relative1 Relative2 3 Label1 Label2 $8;
	input Relative1 Relative2 @5 Label1 $char8. @14 Label2 $char8. Gamma_A Gamma_D Gamma_C;
datalines;
1 2   Father   Mother 0.0 0.0  0
1 3   Father      Son 0.5 0.0  1
1 4   Father Daughter 0.5 0.0  1
2 3   Mother      Son 0.5 0.0  1
2 4   Mother Daughter 0.5 0.0  1
3 3      Son      Son 0.5 0.25 1
3 4      Son Daughter 0.5 0.25 1
4 4 Daughter Daughter 0.5 0.25 1
run;
*proc print;
*run;

data spguihlp.Twins1 (Label='Twins Raised Together: No sex differences');
	length Relative1 Relative2 3 Label1 Label2 $2;
	input Relative1 Relative2 Label1 $ Label2 $ Gamma_A Gamma_D Gamma_C
	      Intraclass;
datalines;
1 1 MZ MZ 1.0 1.0  1 1
2 2 DZ DZ 0.5 0.25 1 1
run;
*proc print;
*run;

data spguihlp.Twins2 (Label='Twins Raised Together and Apart: No sex differences');
	length Relative1 Relative2 3 Label1 Label2 $3;
	input Relative1 Relative2 Label1 $ Label2 $ Gamma_A Gamma_D Gamma_C
			Intraclass;
datalines;
1 1 MZT MZT 1.0 1.00 1 1
2 2 DZT DZT 0.5 0.25 1 1
3 3 MZA MZA 1.0 1.00 0 1
4 4 DZA DZA 0.5 0.25 0 1
run;
*proc print;
*run;

data spguihlp.Twins3 (Label='Twins Raised Together: Sex differences');
	length Relative1 Relative2 3 Label1 Label2 $9;
	input Relative1 Relative2 Label1 $ Label2 $ Gamma_A Gamma_D Gamma_C
		  Intraclass;
datalines;
1 1 MZ_female MZ_female 1.0 1.00 1 1
2 2 DZ_female DZ_female 0.5 0.25 1 1
3 3   MZ_male   MZ_male 1.0 1.00 1 1
4 4   DZ_male   DZ_male 0.5 0.25 1 1
2 4 DZ_female   DZ_male 0.5 0.25 1 0
run;
*proc print;
*run;

DATA spguihlp.type_eq_corr;
	input Relative1 1-2 Relative2 3-4 +1 _TYPE_ $4. +1 _NAME_ $10. (R1_IQ R1_Reading R1_Writing
		  R2_IQ R2_Reading R2_Writing) (6*8.3);
DATALINES;
 1 1 COV  R1_iq      222.506  87.430  86.476 187.871  81.109  79.052
 1 1 COV  R1_reading  87.430  98.387  60.608  84.073  57.399  46.740
 1 1 COV  R1_writing  86.476  60.608 100.500  81.609  46.794  54.750
 1 1 COV  R2_iq      187.871  84.073  81.609 240.610  97.385  99.647
 1 1 COV  R2_reading  81.109  57.399  46.794  97.385  95.738  63.207
 1 1 COV  R2_writing  79.052  46.740  54.750  99.647  63.207 101.441
 1 1 MEAN            100.132  50.476  50.185 100.007  50.573  49.973
 1 1 STD              14.917   9.919  10.025  15.512   9.785  10.072
 1 1 N               296.000 290.000 292.000 292.000 288.000 294.000
 1 1 CORR R1_iq        1.000   0.592   0.578   0.811   0.554   0.521
 1 1 CORR R1_reading   0.592   1.000   0.606   0.543   0.583   0.471
 1 1 CORR R1_writing   0.578   0.606   1.000   0.521   0.468   0.543
 1 1 CORR R2_iq        0.811   0.543   0.521   1.000   0.637   0.635
 1 1 CORR R2_reading   0.554   0.583   0.468   0.637   1.000   0.633
 1 1 CORR R2_writing   0.521   0.471   0.543   0.635   0.633   1.000
 2 2 COV  R1_iq      229.144  91.378  93.006  99.048  53.427  52.274
 2 2 COV  R1_reading  91.378  97.975  64.177  40.939  28.008  29.003
 2 2 COV  R1_writing  93.006  64.177 100.012  52.893  30.821  36.124
 2 2 COV  R2_iq       99.048  40.939  52.893 214.492  85.713  88.684
 2 2 COV  R2_reading  53.427  28.008  30.821  85.713  91.141  61.262
 2 2 COV  R2_writing  52.274  29.003  36.124  88.684  61.262  99.786
 2 2 MEAN            100.385  50.180  49.553 100.018  50.268  49.434
 2 2 STD              15.137   9.898  10.001  14.646   9.547   9.989
 2 2 N               558.000 555.000 562.000 556.000 559.000 553.000
 2 2 CORR R1_iq        1.000   0.606   0.608   0.447   0.367   0.345
 2 2 CORR R1_reading   0.606   1.000   0.647   0.283   0.299   0.291
 2 2 CORR R1_writing   0.608   0.647   1.000   0.362   0.323   0.359
 2 2 CORR R2_iq        0.447   0.283   0.362   1.000   0.612   0.614
 2 2 CORR R2_reading   0.367   0.299   0.323   0.612   1.000   0.646
 2 2 CORR R2_writing   0.345   0.291   0.359   0.614   0.646   1.000
RUN;
*proc print;
*run;

