%let abort_job=NO;
/* -----------------------------------------------------------------------------------
	STORE THE COVARIANCE MATRIX AND OTHER DATA
   ----------------------------------------------------------------------------------- */
%put NOTE: COVARIANCE_DATA STARTING.;

%* --- sort the relationship data set, outputing _TMP_RelDS to avoid changing users dataset;
proc sort data=&relation_data_set
	out=_TMP_RelDS (rename=(Label1=thisLabel1 Label2=thisLabel2));
	by Relative1 Relative2;
run;

%* --- first set lengths for the variables to make it easier to inspect the data set;
%let dsid = %sysfunc(open(_TMP_RelDS));
%let n1 = %sysfunc(varlen(&dsid, %sysfunc(varnum(&dsid, thisLabel1))) );
%let n2 = %sysfunc(varlen(&dsid, %sysfunc(varnum(&dsid, thisLabel2))) );
%let dsid = %sysfunc(close(&dsid));
%*put n1 n2 = &n1 &n2;
%let len = %sysfunc(max(&n1, &n2));
%let len = %sysfunc(max(&len, 8));
%let len = %sysfunc(min(&len, 16));
%*put len = &len;

%* --- merge TYPE=CORR with relationship data to get all the variables;
PROC SORT DATA=&cov_data_set;
	BY &Relative1 &Relative2;
RUN;

DATA &cov_data_set;
	LENGTH Label1 Label2 $&len Relative1 Relative2 Intraclass 3
           Gamma_A Gamma_C Gamma_D 8;  
	MERGE _TMP_RelDS(in=a) &cov_data_set(in=b);
	BY Relative1 Relative2;
	* --- correct sample size for intraclass relationships;
	Label1 = Right(thisLabel1);
	Label2 = Right(thisLabel2);
	DROP thisLabel1 thisLabel2;
	if Intraclass=. then Intraclass=0;
	if b=1 & a=0 then do;
		file log;
		put "ERROR: The following relationship pairing was not found in relationship "
		    "data set &relation_data_set:";
		put "Relative1=" Relative1 "    Relative2=" Relative2;
		call symput('abort_job', 'YES');
	end;
	if a=1 & b=1;
run;

* --- get the first instance of a relative pairing;
DATA _TMP_First;
	SET &cov_data_set;
	BY Relative1 Relative2;
	IF first.Relative1 & First.Relative2;
	KEEP Label1 Label2 Relative1 Relative2 Intraclass Gamma_A Gamma_C Gamma_D;
RUN;

* --- iml code to get the matrices etc to store;
proc iml;

start sample_size (n_min, n_max, n_average);
	/* --- get the sample size --- */
	use &cov_data_set where (_type_ = "N");
		read all var {&cov_phenotypes &covariate_phenotypes} into temp;
	close &cov_data_set;

	/* check for unequal n */
	nc = ncol(temp);
	n_min = j(nrow(temp), 1, 0);
	n_max = n_min;
	n_average = n_min;
	do i=1 to nrow(temp);
		n_min[i] = min(temp[i,1:nc]);
		n_max[i] = max(temp[i,1:nc]);
		n_average[i] = sum(temp[i,1:nc]) / nc;
	end;
	free temp;
finish;

start read_in_covs (rel_pheno, n_cov, cov_mats, svarnames, aborttest);
	use &cov_data_set where (_type_ = "COV");
		read all var {&cov_phenotypes &covariate_phenotypes} into x;
		read all var {_name_} into vname;
		read all var {&relative1 &relative2} into rel_input;
print vname svarnames , x [format = 8.2];
	close &cov_data_set;

	countx=0;
	same=1;
	do i=1 to nrow(rel_pheno);
		do until (same = 0 | countx = nrow(x));
			countx = countx + 1;
			if rel_input[countx,1] = rel_pheno[i,1] & rel_input[countx,2] = rel_pheno[i,2] then do;
				thisname = thisname // vname[countx];
				thisx = thisx // x[countx,];
			end;
			else;
				same=0;
		end;
print thisx;
		/* --- order the rows in x by the order of the variables in svarnames --- */ 
		call order_vectors (n_cov, svarnames, thisname, thisx, aborttest);
print thisx;
		cov_mats = cov_mats // thisx;
		/* --- reinitialize --- */
		thisx = x[countx,];
		same = 1;
	end;
*print cov_mats [format=8.3];
finish;

start order_vectors (n_cov, svarnames, thisname, thisx, aborttest);
	temp = j(n_cov, n_cov, 0);
	do i=1 to n_cov;
		found=0;
		count=0;
		tempname = upcase(svarnames[i]);
		do until (found=1 | count = nrow(thisx));
			count=count+1;
			if tempname = upcase(thisname[count]) then do;
				found=1;
				temp[i,] = thisx[count,];
			end;
print , i count found tempname (thisname[count]);
		end;
		if count > nrow(thisx) then do;
			mattrib tempname label='';
			print , "*** ERROR *** VARIABLE" tempname "NOT A ROW NAME IN TYPE=CORR DATA SET.";
			aborttest = "YES";
			return;
		end;
	end;
	thisx = temp;
finish; 

start check_rel_sort (n_rel, rel_pheno, rel_label, n_phenotypes, n_var, n_cov, n_covariates, means, covmats);
/* --- makes certain that relative1 <= relative2 when a user
		inputs a TYPE=CORR data set --- */
	mattrib rel1 label='' format=3.0;
	mattrib rel2 label='' format=3.0;
	stop = 0;
	do i = 1 to n_rel;
		start = stop + 1;
		stop = stop + n_cov;
		if rel_pheno[i,1] > rel_pheno[i,2] then do;
			/* switch rel_pheno values */
			rel1 = rel_pheno[i,1];
			rel2 = rel_pheno[i,2];
			print , "NOTE: MEANS AND COV MATRIX BLOCKS SWITCH FOR &Relative1 =" rel1
			        " AND &relative2 =" rel2
				  , "      BECAUSE &Relative1 > &Relative2";
			rel_pheno[i,1] = rel2;
			rel_pheno[i,2] = rel1;
			temp = rel_label[i,1];
			rel_label[i,1] = rel_label[i,2];
			rel_label[i,2] = temp;
			/* switch means */
*print , "switch: Old means=" , (means[i,]);
			p2 = means[i,1:n_phenotypes];
			p1 = means[i,n_phenotypes+1:n_var];
			if n_covariates > 0 then do;
				p2cv = means[i, n_var+1 : n_var+n_covariates];
				p1cv = means[i, n_var+n_covariates+1:n_cov];
				means[i,] = p1 || p2 || p1cv || p2cv;
			end;
			else
				means[i,] = p1 || p2;
*print , "switch: New means=" , (means[i,]);
			/* switch cov matrix blocks */
*print , "switch: Old Covmat=" , (covmats[start:stop, 1:n_cov]);
			p2stop = start + n_phenotypes - 1;
			p1start = start + n_phenotypes;
			p1stop = p1start + n_phenotypes - 1;
			p2 = covmats[start:p2stop, 1:n_phenotypes];
			p1 = covmats[p1start:p1stop, n_phenotypes+1:n_var];
			r12 = covmats[p1start:p1stop, 1:n_phenotypes];
			if n_covariates > 0 then do;
				p2cv = covmats[start:p2stop, n_var+1:n_cov];
				p1cv = covmats[p1start:p1stop, n_var+1:n_cov];
				rest = covmats[p1stop+1:p1stop+n_covariates-1, n_var+1:n_cov];
				covmats[start:stop, 1:n_cov] = (p1 || r12 || p1cv) //
                                               (t(r12) || p2 || p2cv) //
                                               (t(p1cv) || t(p2vc) || rest);
			end;
			else
				covmats[start:stop, 1:n_var] = (p1 || r12) // (t(r12) || p2);
*print , "switch: New Covmat=" , (covmats[start:stop, 1:n_cov]);
		end;
	end;
finish;

start get_function_constant (n_cov, rel_label, cov_mats, fdet, error);
	error = 0;
	fdet = j(nrow(rel_label), 1, .);
	stop = 0;
print cov_mats;
	do i=1 to nrow(rel_label);
		start = stop + 1;
		stop  = stop + n_cov;
		x = cov_mats[start:stop,];
		test = eigval(x);
print i start stop test;
		if ncol(test) > 1 then do;
			temp1 = trim(left(rel_label[i,1]));
			temp2 = trim(left(rel_label[i,2]));
			mattrib temp1 label='';
			mattrib temp2 label='';
			print , "*** ERROR *** COVARIANCE MATRIX FOR " temp1 " and " temp2 "IS NOT SYMMETRIC.";
			error=1;
		end;
		else if min(test[1:nrow(test)]) <= 0 then do;
			temp1 = trim(left(rel_label[i,1]));
			temp2 = trim(left(rel_label[i,2]));
			mattrib temp1 label='';
			mattrib temp2 label='';
			print , "*** ERROR *** COVARIANCE MATRIX FOR " temp1 " and " temp2 "IS NOT POSITIVE DEFINITE.";
			error = 1;
		end;
		else fdet[i] = log(det(x));
	end;
*print fdet;
finish;

start print_means_covcorr (cov_matrix, svarnames, rel_label1, rel_label2, means);
/* --- print out observed means and then the cov\corr matrix */
	matrix_label = concat('observed means: ', trim(left(rel_label1)),
					' with ', trim(left(rel_label2)) );
	maxlen = max(length(svarnames));
	rowlabel = "Means";
	if maxlen > 5 then do;
		do i = 6 to maxlen;
			rowlabel = concat(" ",rowlabel);
		end;
	end;
	mattrib means rowname=rowlabel colname=svarnames format=8.3 label=matrix_label;
	print , means;
	call print_covcorr (cov_matrix, svarnames, rel_label1, rel_label2);
finish;

start print_covcorr (cov_matrix, svarnames, rel_label1, rel_label2);
/* --- print out a covariance and correlation matrix, with covs below
		the diagonal and corrs above the diagonal */
	matrix = cov_matrix;
	do i=1 to nrow(cov_matrix);
		stdi = sqrt(cov_matrix[i,i]);
		do j=i+1 to nrow(cov_matrix);
			matrix[i,j] = cov_matrix[i,j] / (stdi * sqrt(cov_matrix[j,j])) ;
		end;
	end;
	matrix_label = concat('covariance \ correlation matrix: ', trim(left(rel_label1)),
					' with ', trim(left(rel_label2)) );
	mattrib matrix rowname=svarnames colname=svarnames format=8.3 label=matrix_label;
	print , matrix;
finish;

/* ----------------------------------------------------------------------- 
	MAIN IML CODE
	---------------------------------------------------------------------- */

	do; /* --- very stupid do statement --- */

		/* --- check if abort code --- */
		aborttest = upcase(trim(left("&abort_job")));
		if aborttest = 'YES' then 
			print , '*** CALL TO READING IN MATRIX DEFINITIONS HAS BEEN ABORTED',
			        '    BECAUSE OF PREVIOUS ERRORS.';
		if aborttest = 'YES' then goto final;

		/* --- print the header --- */
		if "&SPPrint_DataSum" = "YES" then 
			print , '-----------------------------------------------------------------------',
		        	"Processing TYPE=CORR Data Set: &cov_data_set",
		        	'-----------------------------------------------------------------------';

		* --- read in the vectors and matrices;
		USE _TMP_First;
			read all var {Relative1 Relative2} into rel_pheno;
			read all var {Label1 Label2} into rel_label;
			read all var {gamma_a gamma_c gamma_d} into gamma;
			read all var {Intraclass} into Intraclass;
		CLOSE _TMP_First;

		* --- n_rel;
		n_rel = nrow(rel_pheno);

		/* --- read in the covariance matrices --- */
		load n_phenotypes n_var n_covariates n_cov svarnames;
		call read_in_covs (rel_pheno, n_cov, cov_mats, svarnames, aborttest);
		if nrow(cov_mats) ^= n_rel*(n_cov) then do;
			print , "*** ERROR *** DISCREPANT NUMBER OF ROWS FOR COVARIANCE MATRICES IN"
			      , "              TYPE=CORR DATA SET &cov_data_set";
			aborttest = "YES";
		end;
		if aborttest = "YES" then goto final;

		/* --- read in means --- */
		use &cov_data_set where (_type_ = "MEAN");
		read all var {&cov_phenotypes &covariate_phenotypes} into mean_vecs;
		if nrow(mean_vecs) ^= n_rel then do;
			print , "*** ERROR *** NUMBER OF MEAN VECTORS ^= NUMBER OF UNIQUE PAIRS IN"
			      , "              TYPE=CORR DATA SET &cov_data_set";
			aborttest = "YES";
		end;
		if aborttest = "YES" then goto final;

		/* --- if a TYPE=CORR data set then check that relative1 <= relative2
				if not, then swap the means and cov matrix blocks --- */
		if "&data_set_type" = "CORR" then; 
			call check_rel_sort (n_rel, rel_pheno, rel_label, n_phenotypes, n_var, n_cov, 
					n_covariates, mean_vecs, cov_mats);

		/* --- read in N and compute min, max, and average sample size --- */
		call sample_size (n_min, n_max, n_average);
		if nrow(n_min) ^= n_rel then do;
			print , "*** ERROR *** NUMBER OF N VECTORS ^= NUMBER OF UNIQUE PAIRS IN"
			      , "              TYPE=CORR DATA SET &cov_data_set";
			aborttest = "YES";
		end;
		if aborttest = "YES" then goto final;

		/* --- constant for the likelihood --- */
		fdet = j(n_rel, 1, .);
		if "&macro_name" = "SASPAIRS" | "&macro_name" = "SASPAIRS_MEANS" then do;
			call get_function_constant (n_cov, rel_label, cov_mats, fdet, error);
			if error = 1 then do;
				print , "*** ERROR *** CANNOT FIT MODELS TO THESE MATRICES.";
				aborttest = "YES";
			end;
		end;
		if aborttest="YES" then goto final;

		if "&SPPrint_DataSum" = "YES" then do;
			cn1 = {'Relative1' 'Relative2'};
			cn2 = {'  Label1' '  Label2'};
			cn3 = {'gamma_a' 'gamma_c' 'gamma_d'};
			mattrib rel_pheno   colname=cn1 label='';
			mattrib rel_label   colname=cn2 label='';
			mattrib Intraclass  colname='Intraclass' label='';
			mattrib gamma       colname=cn3 label='';
			print , '-----------------------------------------------------------------------',
			        "Relationships Found in TYPE=CORR Data Set",
			        '-----------------------------------------------------------------------',
			        rel_pheno rel_label intraclass gamma;

			mattrib n_min colname="Minimum" label='' format=9.0;
			mattrib n_average colname = "Average" label='' format=9.1;
			mattrib n_max colname="Maximum" label='' format=9.0;
			print , '-----------------------------------------------------------------------',
	    	        "Sample Size: Divisor for CSSCP Matrix is &vardef",
		            '-----------------------------------------------------------------------',
			        rel_label n_min n_average n_max;
		end;

		/* --- check for unequal sample sizes and set the degrees of freedom --- */
		df = &set_n_to;
		if "&vardef" = "DF" then df = df - 1;
		test = sum(n_max - n_min);
		if test ^= 0 then
			print , "*** WARNING *** UNEQUAL SAMPLE SIZES BECAUSE OF MISSING VALUES.",
			        "                &set_n_to WILL BE USED AS THE ESTIMATE OF N.";

		/* -- store matrices --- */
		mean_vecs = t(mean_vecs); * NOTE: means stored as column vectors;
		store n_rel rel_pheno rel_label gamma intraclass cov_mats mean_vecs df fdet;
		call symput("cov_matrix_stored", "1");

		/* --- print out the cov\corr matrix --- */
		if "&SPPrint_DataSum" = "YES" then do;
			stop=0;
			do i=1 to n_rel;
				start = stop + 1;
				stop  = stop + n_cov;
				temp = cov_mats[start:stop,];
				if "&macro_name" = "SASPAIRS_MEANS" | "&macro_name" = "SASPAIRS_RAW_MEANS" then do;
					temp2 = t(mean_vecs[,i]);
					call print_means_covcorr(temp, svarnames, rel_label[i,1], rel_label[i,2], temp2);
				end;
				else
					call print_covcorr (temp, svarnames, rel_label[i,1], rel_label[i,2]);
			end;
		end;

	final:
		if aborttest="YES" then call symput("abort_job", "YES");
	end; /* --- end of very stupid do statement --- */
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: COVARIANCE_DATA FINISHED. ABORT_JOB = &abort_job ;
