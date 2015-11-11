start function_covmats_means (x) 
			GLOBAL (n_rel, n_cov, n_covariates, rel_pheno, cov_mats, mean_vecs, gamma, df, fdet,
					fval, f, index_x, nrows, ncols, parm_value, whereinx);
/* ------------------------------------------------------------------------------
	RELATIVE PAIRS MAXIMIM LIKELIHOOD FUNCTION MODULE: fit to covariance matrices
	and to vectors of observed means
   ------------------------------------------------------------------------------ */

	/* put the iterated parameters into the vector of full parameter values */
	do i=1 to nrow(whereinx);
		if whereinx[i] ^= 0 then parm_value[i] = x[whereinx[i]];
	end;

	/* put the parameters into the user defined matrices */
	call put_x_into_matrices (parm_value, index_x, nrows, ncols);

	/* loop to calculate the function value */
	stop = 0;
	do i = 1 to n_rel;
		pairnum=i; /* for safety in case the user changes pair_number */
		bad_f_value = 0;
		call predicted_stats (pairnum, rel_pheno[i,1], rel_pheno[i,2], gamma[i,1],
							  gamma[i,2], gamma[i,3], p1, p2, r12, p1cv, p2cv, vccv,
							  mean_vector, bad_f_value);
		if bad_f_value = 1 then do;
			f = .;
			return (f);
		end;
		if n_covariates = 0 then
			pre = (p1 || r12) // (t(r12) || p2);
		else
			pre = (p1 || r12 || p1cv) // (t(r12) || p2 || p2cv) //
				  (t(p1cv) || t(p2cv) || vccv) ;
		detpre = det(pre);
		if detpre <= 0 then do;
			f=.;
			return (f);
		end;
		start = stop + 1;
		stop = start + n_cov - 1;
		obs = cov_mats[start:stop,];
		if ncol(mean_vector) > nrow(mean_vector) then mean_vector = t(mean_vector);
		delta = mean_vecs[,i] - mean_vector;
		invpre = inv(pre);
		quad = t(delta) * invpre * delta;
		if "&vardef" = "N" then
			wt = 1;
		else
			wt = (df[i] + 1) / df[i];
		fval[i] = df[i] * (log(detpre) - fdet[i] + trace(obs * invpre) - n_cov + wt*quad);
	end;
	f = sum(fval);
	if "&negative_chi2" = "NO" & f < 0 then f = .;
	return (f);
finish;
