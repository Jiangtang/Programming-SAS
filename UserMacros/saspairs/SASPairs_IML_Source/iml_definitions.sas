/* --------------------------------------------------------------------------------------
   THIS ROUTINE READS IN THE USERS IML CODE and writes out IML modules
   -------------------------------------------------------------------------------------- */
%put NOTE: IML DEFINITIONS STARTING;
proc iml;
%include "&utilities";

start input_iml_commands (aborttest);

	/* bug out if program aborted in an earlier phase */
	if aborttest = 'YES' then return;

	/* --- reopens model data set and input cards --- */
	use temp_thismodel;
		read all var {card} into cards;
	close temp_thismodel;

	call delimit ("BEGIN IML", "END IML", cards, aborttest);
	if aborttest = "YES" then return;

	/* --- check if the iml code is the same --- */
	same_iml = 0;
	phrase = upcase(trim(left(cards[1])));
	if phrase = "SAME" then do;
		if "&iml_modules_written" ^= "1" then do;
			print , '*** ERROR *** IML DEFINITIONS: "Same" USED BEFORE IML MODULES HAVE BEEN WRITTEN.';
			aborttest = "YES";
			call symput("same_iml", "NO");
			return;
		end;
		same_iml=1;
		call symput("same_iml", "YES");
	end;
	else
		call symput("same_iml", "NO");

	/* ---  here ==> file is written only if there are no errors
		    and there is new IML --- */
	if same_iml=0 then call temp_datasets (cards);

	/* --- create the data set for put_x_into_matrices module
	       NOTE: This is always written even if IML is the same
		         because new matrices may have been defined --- */
	load mnames;
	call put_x_into_matrices (mnames);

finish;

start temp_datasets (cardsout);
/* ---------------------------------------------------------------------
	creates a SAS data set that will be written out into IML modules in
	subsequent DATA steps from macro saspairs_write_modules
   --------------------------------------------------------------------- */

	/*	IML code for test_users_module */
	cn = 'Card';
	create temp_testuser from cardsout [colname=cn];
		append from cardsout;

	/* IML code for predicted_stats */
	if upcase(substr("&macro_name", 1, 8)) = "SASPAIRS" then do;
		cardsout1 = 'start predicted_stats (pair_number, relative1, relative2, gamma_a, gamma_c,';
		cardsout2 = '       gamma_d, p1, p2, r12, p1cv, p2cv, vccv, mean_vector, bad_f_value)';
		cardsout3 = '       GLOBAL ( &global_arg1 );';
		cardsout = cardsout1 // cardsout2 // cardsout3 // cardsout;
	end;
	else do;
		cardsout1 = 'start predicted_stats (bad_f_value) GLOBAL ( &global_arg1 ,';
		cardsout2 = ' %saspairs_comma_list(&pmat_matrices), %saspairs_comma_list(&rmat_matrices));';
		cardsout = cardsout1 // cardsout2 // cardsout;
	end;
	cardsout = cardsout // 'finish;';
	create temp_predicted from cardsout [colname=cn];
		append from cardsout;
finish;

start put_x_into_matrices (mnames);
	cards = 'start put_x_into_matrices (x, index_x, nrows, ncols)';
	cards = cards // '     GLOBAL ( &global_arg1 );';

	string1 = '     xstart = index_x[';
	string2 = ',1]; xstop = index_x[';
	string3 = ',2];';
	string4 = ' = shape(x[xstart:xstop],nrows[';
	string5 = '],ncols[';
	string6 = ']);';

	do i = 1 to nrow(mnames);
		chari = trim(left(char(i)));
		command1 = concat(string1, chari, string2, chari, string3);
		command2 = concat(trim(left(mnames[i])), string4, chari, string5, chari, string6);
		cards = cards // command1 // command2;
	end;
	cards = cards // 'finish;';
*print cards;
	cn = 'Card';
	create temp_put_x from cards [colname=cn];
	append from cards;
finish;


/* ----------------------------------------
   MAIN IML CODE
   ---------------------------------------- */

	/* --- check if abort code --- */
	aborttest = upcase(trim(left("&abort_job")));
	if aborttest = 'YES' then 
		print '*** CALL TO READING IN MATRIX DEFINITIONS HAS BEEN ABORTED',
		      '    BECAUSE OF PREVIOUS ERRORS.';
	else 
		call input_iml_commands (aborttest);
	if aborttest = "YES" then call symput("abort_job", "YES");
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%saspairs_write_modules (&same_iml);
%put NOTE: IML DEFINITIONS FINISHED. ABORT_JOB = &abort_job ;
