%macro saspairs_create_cov_from_file(filename, mtype_in, n, cov_phenotypes,
	cov_data_set, relative1, relative2);
	%let nvar = %saspairs_nwords(&cov_phenotypes);
	%put nvar=&nvar;
	%let ninput = %eval( (&nvar*&nvar + &nvar)/2);
	%put ninput=&ninput;

	data temp_data;
		infile "&filename";
		input temp_v1 - temp_v&ninput;
		array temp_v temp_v1 - temp_v&ninput;
		do over temp_v;
			temp_var =temp_v;
			output;
		end;
		keep temp_var;
	run;
	/* --- syserr stuff in here --- */

	proc iml;
		start first_word (string, change);
		/* --- extract the first word in a string and 
			(1) if chenge = 0 then leave the string alone
			(2) if change ne 0 then remove the word from the string --- */
			temp = trim(left(string));
			space = index(temp, ' ');
			if space <= 1 then do;
				word = trim(left(temp));
				if change ^= 0 then string = ' ';
			end;
			else do;
				word = substr(temp,1,space-1);
				if change ^= 0 then string = substr(temp,space);
			end;
			return (word);
		finish;

		/* --- open the data set and read the variables --- */
		use temp_data;
			read all into linear;
		close temp_data;	

		/* --- create a symmetrix nvar by nvar covariance matrix --- */
		cov_data = j(&nvar,&nvar,0);
		count = 0;
		do i=1 to &nvar;
			if upcase(substr("&mtype_in",1,2)) = "FU" then do;
				do j = 1 to &nvar;
					count=count + 1;
					cov_data[i,j] = linear[count];
				end;
			end;
			else do;
				do j = 1 to i;
					count=count + 1;
					cov_data[i,j] = linear[count];
					cov_data[j,i] = linear[count];
				end;
			end;
		end;

		/* --- add the mean and sample size --- */
		mean = j(1,&nvar,0);
		n = j(1, &nvar, &n);
		cov_data = cov_data // mean // n;

		/* --- create variable labels and character variables for
				variables _type_ and _name_ used in a TYPE=CORR
				data set --- */
		string = "&cov_phenotypes";
		do i=1 to &nvar;
			labels = labels || first_word(string, 1);
		end;
		labels = t(labels);
		labels = labels // "MEAN" // "N";
		type = j(&nvar+2,1,"MEAN");
		type[1:&nvar] = "COV";
		type[&nvar+2] = "N";

		/* --- create the data sets --- */
		cn = labels[1:&nvar];
		create temp_cov from cov_data [colname=cn];
			append from cov_data;

		label_data = type || labels;
		cn = {"_type_" "_name_"};
		create temp_label from label_data [colname=cn];
			append from label_data;
	quit;

	data &cov_data_set (TYPE=CORR);
		merge temp_label temp_cov;
		/* --- variables Relative1 and Relative2 needed by SASPairs --- */
		relative1=&relative1;
		relative2=&relative2;
	run;
%mend saspairs_create_cov_from_file;
