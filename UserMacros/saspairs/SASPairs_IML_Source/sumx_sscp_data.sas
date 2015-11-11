/* ---------------------------------------------------------------------------
	CONSTRUCT THE SUMX (IF NEEDED) AND THE SUMS OF SQUARED AND CROSS PRODUCTS
	FOR EACH FAMILY CONFIGURATION.
   --------------------------------------------------------------------------- */
%put NOTE: SASPAIRS_SUMX_SSCP_DATA STARTING;
proc iml;
%include "&utilities";

start initial_setup (relative1, relative2, sort_val, first, last, ntypes,
			 rel1, rel2, n_configs,	n_nomiss, sample_size, miss_pattern);
/* --- create variables first and last to make other code easier --- */
	first = j(nrow(sort_val),1,0);
	last = first;
	first[1]=1;
	last_sort_val = sort_val[1];

	do i=2 to nrow(sort_val);
		if sort_val[i] ^= last_sort_val then do;
			last[i-1] = 1;
			first[i] = 1;
			last_sort_val = sort_val[i];
		end;
	end;
	last[nrow(sort_val)]=1;

	/* --- get the types of relative pairs in this sample --- */
	ntypes = 0;
	last_relative1 = relative1[1]+1;
	last_relative2 = relative2[1];
	do i=1 to nrow(relative1);
		if relative1[i] ^= last_relative1 | relative2[i] ^= last_relative2 then do;
			ntypes = ntypes + 1;
			if ntypes = 1 then do;
				rel1 = relative1[i];
				rel2 = relative2[i];
				position = i;
			end;
			else do;
				rel1 = rel1 // relative1[i];
				rel2 = rel2 // relative2[i];
				position = position // i;
			end;
			last_relative1 = relative1[i];
			last_relative2 = relative2[i];
		end;
	end;
*print ntypes rel1 rel2 position;
	n_configs = j(ntypes,1,0);
	do i=1 to ntypes - 1;
		n_configs[i] = sum(first[position[i]:position[i+1]-1]);
	end;
*print n_configs;
	temp1 = position[ntypes];
	temp2 = nrow(relative1);
	n_configs[ntypes] = sum(first[temp1:temp2]);
*print ntypes rel1 rel1 n_configs;

	/* --- number of nonmissing values, sample size, and missing value pattern */
	n = sum(first);
	n_nomiss = j(n,1,0);
	sample_size = j(n,1,0);
	miss_pattern = j(n,1,substr(last_sort_val,5));
	count = 0;
	do i=1 to nrow(first);
		if first[i] = 1 then do;
			count = count + 1;
			miss_pattern[count] = substr(sort_val[i], 5);
			n = 0;
			do j=1 to length(miss_pattern[count]);
				if substr(miss_pattern[count],j,1) = '1' then n=n+1;
			end;
			n_nomiss[count] = n;
			nn = 0;
		end;
		nn = nn + 1;
		if last[i] = 1 then sample_size[count] = nn;
	end;
*print count n_nomiss sample_size miss_pattern;

	/* --- print the initial output --- */
	print '-----------------------------------------------------------------------',
	      "Summary of Raw Data Pair Configuration",
	      '-----------------------------------------------------------------------';
	mattrib thisrel1       label="Relative1";
	mattrib thisrel2       label="Relative2";
	mattrib thisn_configs  label="N_Configs";
	mattrib tempn          label="N" ;
	mattrib tempn_nomiss   label="N_Present";
	mattrib pattern        label = "Pattern";

	count = 0;
	do i=1 to ntypes;
		thisrel1 = rel1[i];
		thisrel2 = rel2[i];
		thisn_configs = n_configs[i];
		start = count + 1;
		stop = count + thisn_configs;
		count = stop;
		tempn = sample_size[start:stop];
		tempn_nomiss = n_nomiss[start:stop];
		pattern = miss_pattern[start:stop];
		print thisrel1 thisrel2 thisn_configs tempn tempn_nomiss pattern;
	end;
finish;


start construct_sscp (first, last, x, index_sscp, sscp);
/* calculate the sums of squares and cross products --- */

	index_sscp = j(1,2,0);
	tempvec = j(1,2,0);
	count = 0;
	do i=1 to nrow(x);
		thisx = get_thisx(x[i,]);
		if first[i] then do;
			n = 1;
			temp = t(thisx);
		end;
		else do;
			n = n + 1;
			temp = temp // t(thisx);
		end;
		if last[i] then do;
*print count;
*print temp;
			this_sscp = t(temp) * temp;
*print this_sscp;
			nthis = ncol(temp)*ncol(temp);
			this_sscp = shape(this_sscp, nthis, 1);
			sscp = sscp // this_sscp;
			count = count + 1;
			if count = 1 then do;
				index_sscp[1,1] = 1;
				index_sscp[1,2] = nthis;
				sscp = this_sscp;
			end;
			else do;
				tempvec[1] = index_sscp[count-1,2] + 1;
				tempvec[2] = index_sscp[count-1,2] + nthis;
				index_sscp = index_sscp // tempvec;
*print tempvec;
			end;
		end;
	end;
*print index_sscp;
finish;

start get_thisx (x);
/* --- accept only nonmising values
		NOTE WELL: THIS ASSUMES THAT CASES WITH ALL MISSING VALUES ARE EXCLUDED --- */
	nx = ncol(x);
	temp = j(1,nx);
	n=0;
	do i=1 to nx;
		if x[i] ^= . then do;
			n=n+1;
			temp[n] = x[i];
		end;
	end;
	temp = temp[1:n];
	return (temp);
finish;


start construct_sumx (first, last, x, index_sumx, sumx);
/* calculate the sums of squares and cross products --- */

	index_sumx = j(1,2,0);
	tempvec = j(1,2,0);
	count = 0;
	do i=1 to nrow(x);
		thisx = get_thisx(x[i,]);
		if first[i] then do;
			n = 1;
			temp = t(thisx);
		end;
		else do;
			n = n + 1;
			temp = temp // t(thisx);
		end;
		if last[i] then do;
			nx = ncol(temp);
			this_sumx = temp[+,];
			count = count + 1;
			if count = 1 then do;
				index_sumx[1,1] = 1;
				index_sumx[1,2] = nx;
				sumx = t(this_sumx);
			end;
			else do;
				tempvec[1] = index_sumx[count-1,2] + 1;
				tempvec[2] = index_sumx[count-1,2] + nx;
				index_sumx = index_sumx // tempvec;
				sumx = sumx // t(this_sumx);
			end;
		end;
	end;
*print index_sumx;
finish;


start construct_remove_sscp (first, last, x, n_remove_sscp, index_remove_sscp, remove_sscp);
/* vector of the element number within a matrix to remove */
	n_remove_sscp = 0;
	index_remove_sscp = j(1,2,0);
	remove_sscp = 0;
	tempvec = j(1,2,0);
	count = 1;

	do i=1 to nrow(x);
		if first[i] = 1 then do;
			call this_remove_sscp (x[i,], thisn, thisremove);
			count = count + 1;
			n_remove_sscp = n_remove_sscp // thisn;
			if thisn = 0 then do;
				tempvec[1] = index_remove_sscp[count-1,1];
				tempvec[2] = index_remove_sscp[count-1,2];
			end;
			else do;
				tempvec[1] = index_remove_sscp[count-1,2] + 1;
				tempvec[2] = index_remove_sscp[count-1,2] + thisn;
				remove_sscp = remove_sscp // thisremove;
			end;
			index_remove_sscp = index_remove_sscp // tempvec;
		end;
	end;
	/* delete first rows */
*print n_remove_sscp index_remove_sscp remove_sscp;
	n_remove_sscp = n_remove_sscp[2:nrow(n_remove_sscp)];
	index_remove_sscp = index_remove_sscp[2:nrow(index_remove_sscp),];
	if nrow(remove_sscp) > 1 then remove_sscp = remove_sscp[2:nrow(remove_sscp)];
*print n_remove_sscp index_remove_sscp remove_sscp;
finish;

start this_remove_sscp (x, n, remove);
	remove = 0;
	n=0;
	nx = ncol(x);
	do row=1 to nx;
		do col=1 to nx;
			if x[row] = . | x[col] = . then do;
				n=n+1;
				element = nx*(row - 1) + col;
				remove = remove // element;
			end;
		end;
	end;
	if n > 0 then remove = remove[2:nrow(remove)];
finish;

start construct_remove_sumx (first, last, x, n_remove_sumx, 
				index_remove_sumx, remove_sumx);
/* vector of the element number within a matrix to remove */
	n_remove_sumx = 0;
	index_remove_sumx = j(1,2,0);
	remove_sumx = 0;
	tempvec = j(1,2,0);
	count = 1;

	do i=1 to nrow(x);
		if first[i] = 1 then do;
			call this_remove_sumx (x[i,], thisn, thisremove);
			count = count + 1;
			n_remove_sumx = n_remove_sumx // thisn;
			if thisn = 0 then do;
				tempvec[1] = index_remove_sumx[count-1,1];
				tempvec[2] = index_remove_sumx[count-1,2];
			end;
			else do;
				tempvec[1] = index_remove_sumx[count-1,2] + 1;
				tempvec[2] = index_remove_sumx[count-1,2] + thisn;
				remove_sumx = remove_sumx // thisremove;
			end;
			index_remove_sumx = index_remove_sumx // tempvec;
		end;
	end;
	/* delete first rows */
	if nrow(n_remove_sumx) > 1 then
		n_remove_sumx = n_remove_sumx[2:nrow(n_remove_sumx)];
	if nrow(index_remove_sumx) > 1 then
		index_remove_sumx = index_remove_sumx[2:nrow(index_remove_sumx),];
	if nrow(remove_sumx) > 1 then
		remove_sumx = remove_sumx[2:nrow(remove_sumx)];
*print n_remove_sumx index_remove_sumx;
finish;

start this_remove_sumx (x, n, remove);
	nx = ncol(x);
	remove = 0;
	n=0;
	do i=1 to nx;
		if x[i] = . then do;
			n=n+1;
			remove = remove // i;
		end;
	end;
	if n > 0 then remove = remove[2:nrow(remove)];
finish;

/* -----------------------------------------------------------
	MAIN IML
   ----------------------------------------------------------- */
	do; /* --- very stupid do statement --- */

		/* --- check if abort code --- */
		aborttest = upcase(trim(left("&abort_job")));
		if aborttest = 'YES' then 
			print '*** CALL TO READING IN SUMX and SSCP HAS BEEN ABORTED',
			      '    BECAUSE OF PREVIOUS ERRORS.';
		if aborttest = 'YES' then goto final;

		use saspairs_raw;
			read all var {relative1} into relative1;
			read all var {relative2} into relative2;
			read all var {temp_sort_val} into sort_val;

			/* --- initial setup to get first, last, n_configs, sample_size --- */
			call initial_setup (relative1, relative2, sort_val, first, last, 
				ntypes, rel1, rel2, n_configs, n_nomiss, sample_size, miss_pattern);
			free relative1 relative2 sort_val ntypes miss_pattern;
			read all var {&cov_phenotypes &covariate_phenotypes} into x;
		close saspairs_raw;

		/* --- sscp vectors --- */
		call construct_sscp (first, last, x, index_sscp, sscp);
		call construct_remove_sscp (first, last, x, n_remove_sscp,
				index_remove_sscp, remove_sscp);
		store n_configs sample_size n_nomiss index_sscp sscp n_remove_sscp
				index_remove_sscp remove_sscp;

		/* sumx vectors */
		call construct_sumx (first, last, x, index_sumx, sumx);
		call construct_remove_sumx (first, last, x, n_remove_sumx, 
					index_remove_sumx, remove_sumx);
		store index_sumx sumx n_remove_sumx index_remove_sumx remove_sumx;

		/* set macro variables */
		call symput("saspairs_sscp_sumx_stored", "1");
		call symput("saspeds_sscp_sumx_stored", "0");
		if "&macro_name" = "SASPAIRS_RAW_MEANS" then
			call symput("saspairs_means_stored", "1");
		else
			call symput("saspairs_means_stored", "0");

/* --- stuff for debugging --- */
/*
print n_nomiss miss_pattern index_sscp n_remove_sscp index_remove_sscp;
print n_nomiss miss_pattern index_sumx n_remove_sumx index_remove_sumx;
*/
/*
do i=1 to 5;
*do i=nrow(miss_pattern) -5  to nrow(miss_pattern);
	temp = remove_sscp[index_remove_sscp[i,1]: index_remove_sscp[i,2]];
	temp = t(temp);
print i temp;
end;
*/
/*
count=0;
do i = 1 to 5;
	temp = sumx[index_sumx[i,1]:index_sumx[i,2]];
	temp = t(temp);
	print i temp;
	do j = 1 to sample_size[i];
		count = count + 1;
		tempx = x[count,];
		print count tempx;
	end;
end;
*/
/*count=0;
do i = 1 to 5;
	temp = sscp[index_sscp[i,1]:index_sscp[i,2]];
	temp = t(temp);
	print i temp;
	do j = 1 to sample_size[i];
		count = count + 1;
		tempx = x[count,];
		print count tempx;
	end;
end;
*/
	final:
	end;
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: SASPAIRS_SUMX_SSCP_DATA FINISHED. ABORT_JOB = &abort_job ;
