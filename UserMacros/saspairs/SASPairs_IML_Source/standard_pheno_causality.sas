PROC IML;
	LOAD _ALL_;
	upname = Model_names[current_model];
	mattrib upname label='' rowname='' colname='';
	print '-------------------------------------------------',
		  'Phenotypic Causality Model: Standardized Solution',
		  upname,
		  '-------------------------------------------------';

	START Corrit (Cov, R);
		stdinv = j(nrow(Cov), 1, 0);
		do i=1 to nrow(Cov);
			if Cov[i,i] > 0 then stdinv[i] = 1 / sqrt(Cov[i,i]);
			else stdinv [i] = .;
		end;
		do i=1 to nrow(Cov)-1;
			do j=i+1 to nrow(Cov);
				if stdinv[i]=. | stdinv[j] = . then R[i,j] =.;
				else R[i,j] = Cov[i,j] * stdinv[i] * stdinv[j];
			end;
		end;
	FINISH;

	START CovCorr (Cov, IMBInv, name, labels, VecD1, VecD2);
		VecD1 = vecdiag(Cov);
		R = Cov;
		CALL Corrit (Cov, R);
		thismatrix = concat(name, ' Antecedent Covariance\Correlation Matrix:');
		MATTRIB R label=thismatrix rowname=labels colname=labels format=8.3;
		PRINT R;

		temp = IMBInv * Cov * t(IMBInv);
		VecD2 = vecdiag(temp);
		R = temp;
		CALL CORRIT (temp, R);
		thismatrix = concat(name, ' Consequent Covariance\Correlation Matrix:');
		PRINT R;
	FINISH;

	START B_Standardize (B, IMBInv, Vp0, labels);
		Vcomp = IMBInv * Vp0 * t(IMBInv);
		stdinvP = j(nrow(B), 1, 0);
		stdU = j(nrow(B), 1, 0);
		do i=1 to nrow(B);
			if vcomp[i,i] > 0 then stdinvP[i] = 1 / sqrt(vcomp[i,i]);
			else stdinvP[i]=.;
			if Vp0[i,i] > 0 then stdU[i] = sqrt(vp0[i,i]);
			else stdU[i]=.;
		end;

		ZB = B;
		do i=1 to nrow(B);
			do j=1 to nrow(B);
				if stdinvP[i] =. | stdU[j] =. then ZB[i,j]=.;
				else ZB[i,j] = stdinvP[i] * b[i,j] * StdU[j];
			end;
		end;
		MATTRIB ZB label='Standardized Phenotypic Causality Matrix (ZB):'
			rowname=labels colname=labels format=8.3;
		PRINT ZB; 
	FINISH;


	varcomp=0;
	big=0;
	bhere=0;
	do i=1 to nrow(mnames);
		thismat = upcase(mnames[i]);
		if thismat='VA' | thismat = 'VU' then varcomp=1;
		else if substr(thismat, 1, 3) = 'BIG' then big=1;
		else if thismat='B' then bhere=1;
	end;
	if big=1 then do;
		varcomp=1;
		labels = j(nrow(BIGVU), 1, '123456789012');
		do i=1 to nrow(BIGVU) - nrow(VarNames);
			labels[i] = concat('LatPheno', trim(left(char(i))));
		end;
		j=0;
		do i=nrow(BIGVU) - nrow(VarNames) + 1 to nrow(BIGVU);
			j=j+1;
			labels[i] = VarNames[j];
		end;
	end;
	else
		labels = varnames;

	if bhere=1 then CALL B_Standardize (B, IMBInv, ResidCov, labels);

	do i=1 to nrow(mnames);
		thismat = upcase(mnames[i]);
		if thismat = 'VA' then
			call covcorr(VA, IMBINV, 'Additive', labels, hsqa, hsqb);
		else if thismat = 'BIGVA' then
			call covcorr(BIGVA, IMBINV, 'Additive', labels, hsqa, hsqb);
		else if thismat = 'VD' then
			call covcorr(VD, IMBINV, 'Dominance', labels, dsqa, dsqb);
		else if thismat = 'BIGVA' then
			call covcorr(BIGVD, IMBINV, 'Dominance', labels, dsqa, dsqb);
		else if thismat = 'VC' then
			call covcorr(VC, IMBINV, 'Common Environment', labels, csqa, csqb);
		else if thismat = 'BIGVC' then
			call covcorr(BIGVC, IMBINV, 'Common Environment', labels, csqa, csqb);
		else if thismat = 'VU' then
			call covcorr(VU, IMBINV, 'Unique Environment', labels, usqa, usqb);
		else if thismat = 'BIGVU' then
			call covcorr(BIGVU, IMBINV, 'Unique Environment', labels, usqa, usqb);
		else if thismat = 'RESIDCOV' then
			call covcorr(ResidCov, IMBINV, 'Phenotypic (Residual)', labels, dummy1, dummy);
	end;

	do i=1 to nrow(mnames);
		thismat = upcase(mnames[i]);
		if substr(thismat, 1, 8) = 'RELTVCOV' then do;
			thisname = concat('Relative Pair (', trim(left(names[i])), ')');
			call covcorr (ResidCov, IMBINV, thisname, labels, dummy1, dummy2);
		end;
	end;

	if varcomp=1 then do;
		varP = vecdiag(VP);
		hsqA = hsqA / varP;
		hsqB = hsqB / varP;
		dsqA = dsqA / varP;
		dsqB = dsqB / varP;
		csqA = csqA / varP;
		csqB = csqB / varP;
		usqA = usqA / varP;
		usqB = usqB / varP;
		thisMat = hsqA  || dsqA || csqA ||  usqA;
		thismat = 100*thismat;
		mattrib thisMat label='Antecedent Variance Components:' rowname=varnames
				colname={'Asq'  'Dsq'  'Csq'  'Usq' }
				format=6.1;
		print thismat ;
		thismat = hsqB || dsqB || csqB || usqB;
		thismat = 100*thismat;
		mattrib thisMat label='Consequent Variance Components:' rowname=varnames
				colname={'Asq'  'Dsq'  'Csq'  'Usq' }
				format=6.1;
		print thismat ;
	end;

quit;