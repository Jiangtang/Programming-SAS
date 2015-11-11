start function_saspeds_nomeans (x)
		global (f, f_scale, fval, index_x, nrows, ncols, parm_value, whereinx,
			%saspairs_comma_list(&load_matrices) ,
			%saspairs_comma_list(&pmat_matrices) ,
			%saspairs_comma_list(&rmat_matrices) );
/* -------------------------------------------------------------------------
	ALGORITHM:
		(1) Loop through all pedigree types. For a single pedigree type:
			(1) Construct the predicted matrix as if all variables are present
				on all relatives
			(2) Remove those rows and columns to reflect missing values
   ------------------------------------------------------------------------- */

	/* put the iterated parameters into the vector of full parameter values */
	do i=1 to nrow(whereinx);
		if whereinx[i] ^= 0 then parm_value[i] = x[whereinx[i]];
	end;

	/* put the parameters into the user defined matrices */
	call put_x_into_matrices (parm_value, index_x, nrows, ncols);

	/* --- call predicted stats to get the matrix blocks --- */
	bad_f_value = 0;
	call predicted_stats (bad_f_value);
	if bad_f_value = 1 then return (.);

	/* --- place the phenotypic and the relative matrices into their calling matrices --- */
	/* ********* MUST DO THIS THROUGH A MACRO ************ */
	%saspeds_pmats;
	%saspeds_rmats;

	/* --- loop over pedigree types --- */
*pedsf=0;
*pedsdetpre = 0;
*pedstrace = 0;
	count = 0;
	do npt=1 to nrow(ifrl);
		/* --- construct the predicted matrix for this pedigree type --- */
		thisifrl = ifrl[npt,];
		call construct_pre (&n_phenotypes, n_within_pedigree[npt], thisifrl,
			index_pmats, pmats, index_rmats, rmats, index_rmats_ifrl, pre);
*print thisifrl;
*print pre;
		/* --- loop through the configurations for missing data --- */
		fval[npt] = 0;
		do ic = 1 to n_configs[npt];
			count = count + 1;
			thissscp = sscp[index_sscp[count,1]:index_sscp[count,2]];
*print thissscp;
			if n_missing[count] = 0 then
				thispre = pre;  /* no missing values */
			else do;  /* missing values */
				thisremove = remove_sscp[index_remove_sscp[count,1]:index_remove_sscp[count,2]];
*print "sscp remove = " thisremove;
				thispre = remove(pre, thisremove);
				n_nomiss = nrow(pre) - n_missing[count];
				thispre = shape(thispre, n_nomiss, n_nomiss);
			end;
*print thispre;
			detpre = det(thispre);
			if detpre <= 0 then return (.); /* return a missing value */
			preinv = inv(thispre);
			preinv = shape(preinv, 1, ncol(thispre)*ncol(thispre));
			thistrace = preinv * thissscp;
			thisf = sample_size[count] * log(detpre) + thistrace;
			fval[npt] = fval[npt] + thisf;
*pedsf = pedsf // thisf;
*pedsdetpre = pedsdetpre // detpre;
*pedstrace = pedstrace // thistrace;
*print thisf;
		end;
	end;
	f = sum(fval);
	f = f / f_scale;
*store pedsf pedsdetpre pedstrace;
*abort;
	return (f);
finish;

start construct_pre (n_phenotypes, n_within_pedigree, ifrl, index_pmats,
		pmats, index_rmats, rmats, index_rmats_ifrl, pre);

	/* --- dimension pre --- */
	n = n_within_pedigree * n_phenotypes;

	/* --- diagonal blocks NOTE: this sets the dimensions for pre --- */
	ptype = ifrl[1];
	pre = pmats[index_pmats[ptype,1]:index_pmats[ptype,2] , ];
	do i=2 to n_within_pedigree;
		ptype = ifrl[i];
		pre = block(pre, pmats[index_pmats[ptype,1]:index_pmats[ptype,2] , ]);
	end;

	/* --- off diagonal blocks --- */
	do i=1 to n_within_pedigree;
		rowstart = n_phenotypes*(i -1) + 1;
		rowstop = rowstart + &n_phenotypes - 1;
		do j = i+1 to n_within_pedigree;
			colstart = n_phenotypes*(j-1) + 1;
			colstop = colstart + &n_phenotypes - 1;
			rmatindex = index_rmats_ifrl[ifrl[i], ifrl[j]];
			thisrmat = rmats[index_rmats[rmatindex,1]:index_rmats[rmatindex,2],];
			pre[rowstart:rowstop, colstart:colstop] = thisrmat;
			pre[colstart:colstop, rowstart:rowstop] = t(thisrmat);
		end;
	end;
finish;
