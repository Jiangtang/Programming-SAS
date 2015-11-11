* --- Standardized solution for default SASPairs Models;
proc iml;

	load _all_;
	upname = Model_names[current_model];
	mattrib upname label='' rowname='' colname='';
	print '-------------------------------------------------',
		  'Standardized Solution',
		  upname,
		  '-------------------------------------------------';
	upname = compress(upcase(trim(left(upname))));
	upname = tranwrd(upname, ',', ' ');
*print upname;

	* --- initialize;
	matform = j(4, 1, 'ZE');
	matabbr = {'VA', 'VD', 'VC', 'VU'};
	hsq = j(n_phenotypes, 1, 0);
	dsq = j(n_phenotypes, 1, 0);
	csq = j(n_phenotypes, 1, 0);
	usq = j(n_phenotypes, 1, 0);

	* --- check if psychometric model;
	if index(upname, 'PSYCHOMETRIC') = 1 then do;
		do i=1 to 4;
			matform[i]='UN';
		end;
		matform[2]='ZE';
	end;

	else do;
		* --- otherwise, get the matrix type;
		count=0;
		word='xx';
		do until (word='');
			count=count+1;
			word = scan(upname, count, ' ');
			if word ^= '' then do;
				pos = index(word, '=');
				if pos > 0 then do;
					thismatrix = substr(word, 1, pos - 1);
					thisarg = substr(word, pos+1); 
*if count > 10 then word='';
*print count word thismatrix thisarg;
					if      thismatrix='VA' then i=1;
					else if thismatrix='VD' then i=2;
					else if thismatrix='VC' then i=3;
					else if thismatrix='VU' then i=4;
					if thisarg='0' then thisarg='ZE';
					else thisarg=substr(thisarg, 1, 2);
					if thisarg='DI' | thisarg='SC' then thisarg='UN';
					matform[i] = thisarg;
				end;
			end;
		end;
	end;
*print matform;

* --- modules;
start standardize (siginv, matrix, xsq, varnames);
	stmat = siginv * matrix * siginv;
	xsq = vecdiag(stmat);
	corrmat = stmat;
	do i=1 to nrow(xsq);
		do j=i to nrow(xsq);
			if xsq[i] > 0 & xsq[j] > 0 then corrmat[i,j] =
				stmat[i,j] / sqrt(xsq[i]*xsq[j]);
			else
				corrmat[i,j]=.;
			corrmat[j,i] = corrmat[i,j];
		end;
	end;
	mattrib corrmat label='' rowname=varnames colname=varnames format=7.3;
	print , 'Correlation Matrix:', corrmat;
finish;

start LD_standardize (siginv, ldmatrix, xsq, varnames);
	stmat = siginv * ldmatrix;
	mattrib stmat label='' rowname=varnames colname=varnames format=7.3;
	print , 'Standardized lower diagonal (Cholesky) matrix:', stmat;
	matrix = ldmatrix*t(ldmatrix);
	call standardize (siginv, matrix, xsq, varnames);
finish;

start FAC_Standardize (siginv, facmatrix, smatrix, xsq, varnames);
	stpat = siginv * facmatrix;
	stspec = siginv * smatrix * siginv;
	mattrib stpat label='' rowname=varnames colname='Factor1' format=7.3;
	mattrib stspec label='' rowname=varnames colname=varnames format=7.3;
	print , 'Standardized factor pattern:', stpat;
    print , 'Standardized specific variances:' , stspec;
	matrix = facmatrix*t(facmatrix) + smatrix;
	call standardize (siginv, matrix, xsq, varnames);
finish;

start ANTE_Standardize (siginv, antemat, smat, xsq, varnames);  
	tempinv = Inv(I(nrow(antemat)) - antemat);
	vcomp = tempinv * smat * t(tempinv);
	stdinv = j(nrow(antemat), 1, 0);
	do i=1 to nrow(stdinv);
		if vcomp[i,i] > 0 then stdinv[i] = 1/sqrt(vcomp[i,i]);
		else stdinv[i] = .;
	end;
	* --- standardized antemat matrix;
	Zantemat = 0*antemat;
	Zspecific = smat;
	do i=1 to nrow(antemat);
		if stdinv[i] = . then Zspecific[i,i]=.;
		else Zspecific[i,i] = smat[i,i] * stdinv[i] * stdinv[i];
		do j=1 to i-1;
			if stdinv[i] = . | stdinv[j] = . then Zantemat[i,j]=.;
			else zantemat[i,j] = stdinv[i] * antemat[i,j] / stdinv[j];
		end;
	end;
	mattrib Zantemat label='' rowname=varnames colname=varnames format=7.3;
	mattrib Zspecific label='' rowname=varnames colname=varnames format=7.3;
	print , 'Standardized antedependence (simplex) matrix:', Zantemat;
	print , 'Standardized specific variances', Zspecific;
    * --- correlation matrix and percent variance;
	call standardize (siginv, vcomp, xsq, varnames);
finish;

start PM_Standardize (total, unique, varnames, name);
	common = total - unique;
	common = 100 * common / total;
	unique = 100 * unique / total;
	thisname = concat('Contributions to ', name, ' Variance:');
	mattrib thisname label='';
	mattrib common label='' rowname=varnames colname='Common:' format=7.1;
	mattrib unique label=''  colname=' Unique:' format=8.1;
	print , thisname , common unique;
finish;

* --- end of modules;


	* --- get the phenotypic covariance matrix;
	vp = j(n_phenotypes, n_phenotypes, 0);
	if matform[1] ^= 'ZE' then vp = vp + VA;
	if matform[2] ^= 'ZE' then vp = vp + VD;
	if matform[3] ^= 'ZE' then vp = vp + VC;
	if matform[4] ^= 'ZE' then vp = vp + VU;
*print vp;
	siginv = inv(sqrt(diag(vp)));

	if matform[1] ^= 'ZE' then print
		'Additive Genetic Matrices:' ,
		'--------------------------' ;
	if      matform[1] = 'UN' then call standardize (siginv, va, hsq, varnames);
	else if matform[1] = 'LD' then call LD_standardize (siginv, fa, hsq, varnames);
	else if matform[1] = 'GF' then call FAC_Standardize (siginv, fa, sa, hsq, varnames);
	else if matform[1] = 'SI' then call ANTE_Standardize (siginv, simplex_a, sa, hsq, varnames);  

	if matform[2] ^= 'ZE' then print
		'Dominance Genetic Matrices:' ,
		'---------------------------' ;
	if      matform[2] = 'UN' then call standardize (siginv, vd, dsq, varnames);
	else if matform[2] = 'LD' then call LD_standardize (siginv, fd, dsq, varnames);
	else if matform[2] = 'GF' then call FAC_Standardize (siginv, fd, sd, dsq, varnames);
	else if matform[2] = 'SI' then call ANTE_Standardize (siginv, simplex_d, sd, dsq, varnames);  

	if matform[3] ^= 'ZE' then print
		'Common Environment Matrices:' ,
		'----------------------------' ;
	if      matform[3] = 'UN' then call standardize (siginv, vc, csq, varnames);
	else if matform[3] = 'LD' then call LD_standardize (siginv, fc, csq, varnames);
	else if matform[3] = 'GF' then call FAC_Standardize (siginv, fc, sc, csq, varnames);
	else if matform[3] = 'SI' then call ANTE_Standardize (siginv, simplex_c, sc, csq, varnames);  

	if matform[4] ^= 'ZE' then print
		'Unique Environment Matrices:' ,
		'----------------------------' ;
	if      matform[4] = 'UN' then call standardize (siginv, vu, usq, varnames);
	else if matform[4] = 'LD' then call LD_standardize (siginv, fu, usq, varnames);
	else if matform[4] = 'GF' then call FAC_Standardize (siginv, fu, su, usq, varnames);
	else if matform[4] = 'SI' then call ANTE_Standardize (siginv, simplex_u, su, usq, varnames);  

	if index(upname, 'PSYCHOMETRIC') = 1 then do;	
		print 'Psychometric model:' ,
			  'Percentage contributions from common factor and unique variances' ,
		      '----------------------------------------------------------------';
		call PM_Standardize (vecdiag(va), vecdiag(sa), varnames, 'Additive Genetic');
		call PM_Standardize (vecdiag(vc), vecdiag(sc), varnames, 'Common Environmental');
		call PM_Standardize (vecdiag(vu), vecdiag(su), varnames, 'Unique Environmental');
	end;

	vcomp = hsq || dsq || csq || usq;
	vcomp = 100*vcomp;
	mattrib vcomp label='Variance Components:' format=6.1 colname={'Asq' 'Dsq' 'Csq' 'Usq'}
				  rowname=varnames;
	print vcomp;
quit;
