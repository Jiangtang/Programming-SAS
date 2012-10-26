/*http://www.sascommunity.org/wiki/Get_Name_of_Program*/

%macro ___path;

	%let ___name0 = %sysget(sas_execfilename);
	%let ___name1 =%scan(&___name0,1,".");

	%let ___dir0 = %sysget(sas_execfilepath);


	%let ___dir1 = %substr(&___dir0,1,%eval(%length(&___dir0)
				   - %length(&___name0)-1));

	%let ___dir2 = %substr(&___dir0,1,%eval(%length(&___dir0)
				   - %length(%scan(&___dir0,-2,"\"))
				   - %length(%scan(&___dir0,-1,"\"))-2));

	%let ___dir3 = %substr(&___dir1,1,%eval(%length(&___dir1)
				   - %length(%scan(&___dir1,-2,"\"))
				   - %length(%scan(&___dir1,-1,"\"))-2));


	%let ___dir4 = %substr(&___dir2,1,%eval(%length(&___dir2)
				   - %length(%scan(&___dir2,-2,"\"))
				   - %length(%scan(&___dir2,-1,"\"))-2));

	%let ___dir5 = %substr(&___dir3,1,%eval(%length(&___dir3)
				   - %length(%scan(&___dir3,-2,"\"))
				   - %length(%scan(&___dir3,-1,"\"))-2));

	%put %nrstr(&___name0) = &___name0;
 	%put %nrstr(&___name1) = &___name1;
	%put %nrstr(&___dir0)  = &___dir0;
	%put %nrstr(&___dir1)  = &___dir1;
	%put %nrstr(&___dir2)  = &___dir2;
	%put %nrstr(&___dir3)  = &___dir3;
	%put %nrstr(&___dir4)  = &___dir4;
	%put %nrstr(&___dir5)  = &___dir5;


%mend ___path;

%___path
