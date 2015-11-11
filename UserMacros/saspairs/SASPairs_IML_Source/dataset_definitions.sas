/* --------------------------------------------------------------------
	DATA SET DEFINITIONS
   -------------------------------------------------------------------- */
%put NOTE: DATA SET DEFINITIONS STARTING;
proc iml;
%include "&utilities";
start input_dataset_definitions (aborttest) GLOBAL (dscards, error);

	/* --- open model data set and input cards --- */
	use &model_data_set;
		read all var {card} into dscards;
	close &model_data_set;
	call remove_blanks(dscards);
	if "&SPPrint_DataDefs" = "YES" then
		print '---------------------------------------------------------------------',
			  "&saspairs_version",
			  'Dataset Definitions:',
		      "SASPairs Data Set: &model_data_set",
		      '---------------------------------------------------------------------';
	if "&SPPrint_EchoCards" = "YES" then do;
		mattrib dscards label='' rowname='' colname='';
		print , dscards;
	end;

	/* --- get the dataset definition cards --- */
	call delimit ("BEGIN DATASETS", "END DATASETS", dscards, aborttest);
	if aborttest = "YES" then return;
	/* --- remove semicolons --- */
	call change (dscards, ';', '', 0);
finish;

start parse_dscards (aborttest, same_data) GLOBAL (error, dscards, command_args);
/* ---------------------------------------------------------------------------------
	Gets the commands, their arguments and checks for errors
   --------------------------------------------------------------------------------- */
	if "&SPPrint_DataDefs" = "YES" then
		print , '---------------------------------------------------------------------',
		        "Parsing Data Set Definitions in SASPairs Data Set: &model_data_set",
		        '---------------------------------------------------------------------';

	/* --- check if the first card is Same --- */
	same_data=0;
	if upcase(trim(left(dscards[1]))) = "SAME" then do;
		temparg = trim(dscards[1]);
		mattrib temparg label='' rowname='' colname='';
		if "&SPPrint_DataDefs" = "YES" then print , temparg;
		if "&phenotypes_data_set" = '' & "&cov_data_set" = '' then do;
			print "*** ERROR *** Same COMMAND USED BUT NO PREVIOUS DATA STORED.";
			aborttest = "YES";
			return;
		end;
		same_data=1;
		call symput("same_data", "1");
		return;
	end;

	error = 0;
	commands = {"PHENOTYPIC DATA SET",
				"FAMILY ID VARIABLE",
				"RELATIONSHIP VARIABLE",
				"PHENOTYPES FOR ANALYSIS",
				"RELATIONSHIP DATA SET",
				"TYPE=CORR DATA SET",
				"TYPE=CORR RELATIVE1",
				"TYPE=CORR RELATIVE2",
				"TYPE=CORR VARIABLES",
				"TYPE=CORR PHENOTYPE LABELS",
				"COVARIATES"};
				
	command_found = j(nrow(commands), 1, 0);
	/* get rid of spaces */
	test_commands = commands;
	call change(test_commands, ' ', '', 0);

	dscards = left(trim(dscards));
	mattrib dscards label='';
	mattrib thiscommand label='';
	error = 0;
	ncommands = nrow(commands);
	temparg=' ';
	tempargnum = 0;
	do i=1 to nrow(dscards);
		if "&SPPrint_DataDefs" = "YES" then print , (dscards[i]);
		/* parse to get the command and the argument */
		call get_command_arg (dscards[i], thiscommand, thisarg, badcommand);
		if badcommand=1 then
			error = error + 1;
		else do;
			call change(thiscommand, ' ', '', 0);
			/* find the command */
			count = 0;
			found = 0;
			command_number = 0;
			do until (found ^= 0  |  count = ncommands);
				count = count + 1;
				if thiscommand = test_commands[count] then do;
					if command_found[count] = 1 then do;
						print , "*** ERROR *** DUPLICATE DATASET DEFINITION COMMAND.";
						error = error + 1;
					end;
					else do;
						found=1;
						command_found[count] = 1;
						temparg = temparg // thisarg;
						tempargnum = tempargnum // count;
					end;
				end;
			end;
			if found = 0 then do;
				print , "*** ERROR *** ILLEGAL COMMAND.";
				error = error + 1;
			end;
		end;
	end;

	/* bug out on error */
	if error > 0 then do;
		aborttest = "YES";
		return;
	end;

	/* get the command_args array
	   NOTE: command_args beginning with a "1" are missing */
	temparg = temparg[2:nrow(temparg)];
	tempargnum = tempargnum[2:nrow(tempargnum)];
	len = max(length(temparg));
	do i=1 to nrow(temparg);
		if length(temparg[i]) = len then thisarg = temparg[i];
	end;
	thisarg = concat("1", thisarg);
	command_args = j(ncommands, 1, thisarg);
	do i=1 to nrow(temparg);
		command_args[tempargnum[i]] = temparg[i];
	end;
	command_args = trim(left(command_args));

	/* --- check for errors --- */
	mattrib thiscommand label='';
	if command_found[1] = 1 then do;
		stopdo = 5;
		if upcase(substr("&macro_name", 1, 7)) = "SASPEDS" then stopdo = 4;
		do i = 2 to stopdo;
			if command_found[i] = 0 then do;
				thiscommand = commands[i];
				print , "*** ERROR *** COMMAND NOT FOUND: " thiscommand;
				error = error + 1;
			end;
		end;
		do i = 6 to 10;
			if command_found[i] = 1 then do;
				thiscommand = commands[i];
				print , "*** ERROR *** TYPE=CORR COMMAND FOUND WITH PHENOTYPIC DATASET COMMAND:" thiscommand;
				error = error + 1;
			end;
		end;
	end;
	else if command_found[6] = 1 then do;
		do i = 5 to 10;
			if command_found[i] = 0 then do;
				thiscommand = commands[i];
				print , "*** ERROR *** COMMAND NOT FOUND: " thiscommand;
				error = error + 1;
			end;
		end;
		do i = 2 to 4;
			if command_found[i] = 1 then do;
				thiscommand = commands[i];
				print , "*** ERROR *** PHENOTYPIC DATASET COMMAND WITH TYPE=CORR DATASET COMMAND:" thiscommand;
				error = error + 1;
			end;
		end;
	end;
	else do;
		print , "*** ERROR *** NEITHER PHENOTYPIC DATA SET NOR TYPE=CORR DATA SET SPECIFIED.";
		error = error + 1;
	end;
	if command_found[6] = 1 & upcase(substr("&macro_name", 1, 7)) = "SASPEDS" then do;
		print , "*** ERROR *** TYPE=CORR DATA SET CANNOT BE USED WITH SASPEDS.";
		error = error + 1;
	end;

	/* bug out on error */
	if error > 0 then aborttest = "YES";

final:
finish;

start get_command_arg (string, command, arg, badcommand);
	test = upcase(trim(left(string)));
	thistest = test;
	call change(thistest, " ", '', 0); *remove blanks;
	typeequals = index(thistest, "TYPE=CORR");
	if typeequals = 0 then
		eqsign = index(test, "=");
	else do;
		eq1 = index(test, "=");
		eq2 = index(substr(test, eq1+1), "=");
		if eq2 = 0 then
			eqsign = 0;
		else
			eqsign = eq1 + eq2;
*print test, eqsign;
	end;
		badcommand = 0;
		if eqsign = 0 then do;
			print , "*** ERROR *** MISSING EQUALS SIGN (=).";
			badcommand=1;
		end;
		else if eqsign = 1 then do;
			print , "***  ERROR *** MISSING COMMAND";
			badcommand=1;
		end;
		else if eqsign = length(test) then do;
			print , "***  ERROR *** MISSING ARGUMENT TO COMMAND";
			badcommand=1;
		end;
		if badcommand=1 then return;
		command = substr(test, 1, eqsign-1);
		arg = substr(test, eqsign+1);
finish;	

start same_data (same_data, aborttest) GLOBAL (command_args);
/* -----------------------------------------------------------------------------------
	tests whether these are the same values previously input
  ----------------------------------------------------------------------------------- */
	if substr(command_args[1], 1, 1) ^= "1" then do;
		same_data = same_phenotypic (command_args);
		data_set_type = "DATA";
	end;
	else do;
		same_data = same_covdata (command_args);
		data_set_type = "CORR";
	end;

	call symput("same_data", trim(left(char(same_data))) );
	if same_data = 1 then return;

	/* --- create macro variables --- */
	call symput("data_set_type", data_set_type);
	macro_vars = {"phenotypes_data_set",
				  "family",
				  "relation",
				  "phenotypes_in",
				  "relation_data_set",
				  "users_cov_data_set",
				  "relative1",
				  "relative2",
				  "cov_phenotypes_in",
				  "phenotypes",
				  "covariate_phenotypes_in"};
	blank = '';
	do i=1 to 11;
		if substr(command_args[i],1,1) ^= "1" then
			call symput(macro_vars[i], trim(left(command_args[i])));
		else
			call symput(macro_vars[i], blank);
	end;

	/* covariates */
	if substr(command_args[11], 1, 1) = "1" then
		call symput("covariates", "NO");
	else
		call symput("covariates", "YES");
finish;

start same_phenotypic (command_args);
	same=1;
	if command_args[1] ^= "&phenotypes_data_set" then same=0;
	else if command_args[2] ^= "&family" then same=0;
	else if command_args[3] ^= "&relation" then same=0;
	else if command_args[4] ^= "&phenotypes_in" then same=0;
	else if command_args[5] ^= "&relation_data_set" then same=0;
	if substr(command_args[11],1,1) ^= "1" then do;
		if command_args[11] ^= "&covariate_phenotypes_in" then same=0;
	end;
	return (same);
finish;

start same_covdata (command_args);
	same=1;
	if command_args[6] ^= "&users_cov_data_set" then same=0;
	else if command_args[7] ^= "&relative1" then same=0;
	else if command_args[8] ^= "&relative2" then same=0;
	else if command_args[9] ^= "&cov_phenotypes_in" then same=0;
	else if command_args[5] ^= "&relation_data_set" then same=0;
	if substr(command_args[11],1,1) ^= "1" then do;
		if command_args[11] ^= "&covariate_phenotypes_in" then same=0;
	end;
	return (same);
finish;

/* -----------------------------------------------------------------------
	MAIN IML CODE
   ----------------------------------------------------------------------- */
	do; /* stupid do condition */
		aborttest = upcase(trim(left("&abort_job")));
		if aborttest = "YES" then 
			print '*** CALL TO READING IN DATASET DEFINITIONS HAS BEEN ABORTED',
		     	  '    BECAUSE OF PREVIOUS ERRORS.';
		if aborttest = "YES" then goto final;

		/* --- input the data cards --- */
		call input_dataset_definitions (aborttest);
		if aborttest="YES" then goto final;

		/* --- parse the dataset definitions --- */
		call parse_dscards (aborttest, same_data);
		if aborttest = "YES" then goto final;

		/* --- is this the same data as input before? --- */
		if same_data = 0 then call same_data (same_data, aborttest);

	final:
		if aborttest="YES" then 
			call symput("abort_job", "YES");
		else if same_data = 1 then do;
			if ("&macro_name" = "&last_macro_name") |
			   ("&macro_name" = "SASPAIRS" & "&last_macro_name" = "SASPAIRS_MEANS") |
			   ("&macro_name" = "SASPAIRS_MEANS" & "&last_macro_name" = "SASPAIRS") then do;
					if "&SPPrint_DataDefs" = "YES" then
						print , "Dataset Definitions parsed without error."
							  , "Same dataset definitions as the last call."
							  , "Stored IML data matrices will be used.";
			end;
			else if "&SPPrint_DataDefs" = "YES" then
				print , "Dataset Definitions parsed without error."
					  , "Same dataset definitions as the last call."
					  , "Different IML matrices may be computed and stored because this"
					  , "macro call (&macro_name) differs from previous macro call (&last_macro_name)."
					  , "WARNING: Storage of fit indices will be reinitialized.";
		end; 
		else if "&SPPrint_DataDefs" = "YES" then
			print , "Dataset Definitions parsed without error."
				  , "New dataset definitions."
				  , "WARNING: Storage of fit indices will be reinitialized."
				  , "WARNING: Same command cannot be used in this data set in Begin Matrices."
				  , "WARNING: Same command cannot be used in this data set in Begin IML.";
	end;
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: DATA SET DEFINITIONS FINISHED. ABORT_JOB = &abort_job;
