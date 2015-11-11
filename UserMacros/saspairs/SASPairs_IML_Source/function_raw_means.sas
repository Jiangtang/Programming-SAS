start function_raw_means (x)
			GLOBAL (n_rel, n_cov, n_covariates, rel_pheno, gamma, f, f_scale,
					fval, index_x, nrows, ncols, parm_value, whereinx,
					n_configs, sample_size, n_nomiss,
					sumx, index_sumx, index_remove_sumx, remove_sumx,
					sscp, index_sscp, index_remove_sscp, remove_sscp);
/* ---------------------------------------------------------------------- 
	computes -2LOG(L) for pedigree configurations with an overall 
		predicted matrix but a series of missing values:
		n_configs = number of raw data configurations for a pair of
					relatives
		sample_size   = sample size
		n_nomiss = number of nonmissing values
		sumx = vector of observed sums of the raw data
		index_sumx = pointers to the section in vector sumx for a
					configuration for a pair of relatives
		index_remove_sumx = pointers to the section in vector
					remove_sumx for a configuration
		remove_sumx = variables to remove in in vector means
		sscp = SSCP matrices stored as a vector
		index_sumx = pointers to the section in vector sscp for a
					configuration for a pair of relatives
		index_remove_sscp = pointers to the section in vector
					remove_sscp for a configuration
		remove_sscp = variables to remove in in vector means
   ------------------------------------------------------------------------ */
	/* put the iterated parameters into the vector of full parameter values */
	do i=1 to nrow(whereinx);
		if whereinx[i] ^= 0 then parm_value[i] = x[whereinx[i]];
	end;

	/* put the parameters into the user defined matrices */
	call put_x_into_matrices (parm_value, index_x, nrows, ncols);

	/* function value */
	count = 0;
	do i = 1 to n_rel;
		pairnum=i; /*safety */
		bad_f_value = 0;
		call predicted_stats (pairnum, rel_pheno[i,1], rel_pheno[i,2], gamma[i,1],
							  gamma[i,2], gamma[i,3], p1, p2, r12, p1cv, p2cv, vccv,
							  mean_vector, bad_f_value);
		if bad_f_value = 1 then do;
			f = .;
			return (f);
		end;
		/* transpose mean_vector, if necessary */
		if ncol(mean_vector) > nrow(mean_vector) then mean_vector = t(mean_vector);
		if n_covariates = 0 then
			pre = (p1 || r12) // (t(r12) || p2);
		else
			pre = (p1 || r12 || p1cv) // (t(r12) || p2 || p2cv) //
				  (t(p1cv) || t(p2cv) || vccv) ;
		fval[i] = 0;
		/* --- now loop through the pairships dealing with missing values --- */
		do j = 1 to n_configs[i];
			count = count + 1;
			thissscp = sscp[index_sscp[count,1]:index_sscp[count,2]];
			thissumx = sumx[index_sumx[count,1]:index_sumx[count,2]];
			if n_nomiss[count] = n_cov then do; /* no missing values */
				thispre = pre;
				thismeans = mean_vector;
			end;
			else do;  /* missing values */
				thisremove = remove_sscp[index_remove_sscp[count,1]:index_remove_sscp[count,2]];
				thispre = remove(pre, thisremove);
				thispre = shape(thispre, n_nomiss[count], n_nomiss[count]);
				thisremove = remove_sumx[index_remove_sumx[count,1]:index_remove_sumx[count,2]];
				thismeans = t(remove(mean_vector, thisremove));
			end;
			detpre = det(thispre);
			if detpre <= 0 then do;
				f=.;
				return (f);
			end;
			preinv = inv(thispre);
			ftemp1 = preinv * thismeans;
			ftemp2 = sample_size[count] * thismeans;
			ftemp3 = t(ftemp2 - 2*thissumx) * ftemp1;
			preinv = shape(preinv, 1, ncol(thispre)*ncol(thispre));
			thistrace = preinv * thissscp;
			thisf = sample_size[count] * log(detpre) + thistrace + ftemp3;
			fval[i] = fval[i] + thisf;
		end;
	end;
	f = sum(fval);
	f = f / f_scale;
	return (f);
finish;
