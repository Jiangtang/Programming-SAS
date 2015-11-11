/* --------------------------------------------------------------------
	MODEL DEFINITIONS
   -------------------------------------------------------------------- */
%put NOTE: MODEL DEFINITIONS STARTING;
proc iml;
%include "&utilities";

start check_for_dataset (arg) GLOBAL (error);
/* -------------------------------------------------------------
	checks whether the argument to a BEGIN MODEL statement is a
	DATA = assignment
   ------------------------------------------------------------- */
	/* use the process of elimination to parse */
	if length(arg) < 5 then return ("$"); /* minimum length is DATA= */
	if upcase(substr(arg,1,4)) ^= "DATA" then return ("$");
	arg = left(substr(arg,5));
	if substr(arg, 1, 1) ^= "=" then return ("$");
	/* reaching here ==> DATA= */
	if length(arg) = 1 then do;
		print , "*** ERROR *** MISSING DATA SET NAME.";
		error = error + 1;
		return ("$");
	end;
	dsn = left(substr(arg, 2));
	/* check that the data set exists */
	if exist(dsn) = 0 then do;
		mattrib dsn label='';
		print ,"*** ERROR *** DATA SET" dsn "NOT FOUND.";
		error = error + 1;
		return ("$");
	end;
	/* return the data set name */
	return (dsn);
finish;

start check_recursion(thismodel_file, nmodel_files, model_files);
/* ------------------------------------------------------------------------
	CHECK WHETHER A DATA SET ABOUT TO BE INSERTED HAS ALREADY BEEN INSERTED
	NOTE: this could be legit, but it could also involve an infinite loop
		  if DATA1 calls DATA2 which calls DATA1
   ------------------------------------------------------------------------ */

	found = 0;
	testfile = upcase(thismodel_file);
	do i=1 to nmodel_files;
		if testfile = model_files[i] then found = 1;
	end;

	if found=0 then do;
		nmodel_files = nmodel_files + 1;
		model_files = model_files // upcase(thismodel_file);
	end;
	else do;
		mattrib thismodel_file label='';
		print , "*** ERROR *** DATA SET" thismodel_file "HAS ALREADY BEEN INSERTED.",
		        "              PROGRAM WILL BE ABORTED TO AVOID POSSIBLE RECURSION.";
	end;
	return (found);
finish;	

start insert_dataset (thismodel_file, count, input_cards, current_card) GLOBAL (error);
/* -------------------------------------------------------------
	inserts the contents of model_data_set thismodel_file into
	the input_cards vector
   ------------------------------------------------------------- */
	
	mattrib thismodel_file label='';

	dsid = open(thismodel_file,'I');
	nobs = attrn(dsid, 'nobs');
	vn = varnum(dsid, 'card');
	if vn = 0 then do;
		print , "*** ERROR *** DATA SET" thismodel_file "DOES NOT CONTAIN VARIABLE CARD.";
		error = error + 1;
		test = close(dsid);
		return;
	end;
	/* initialize cards */
	cards = " ";
	/* read in the observations */
	do i = 1 to nobs;
		test = fetchobs(dsid, i);
		temp = getvarc(dsid, vn);
		cards = cards // temp;
	end;
	/* close the data set */
	test = close(dsid);
*print 'cards read:' cards;
	/* remove blanks from cards */
	n = 0;
	do i=1 to nrow(cards);
		if cards[i] ^= " " then do;
			n=n+1;
			cards[n] = cards[i];
		end;
	end;
	if n = 0 then do;
		print , "*** ERROR *** DATA SET" thismodel_file "IS BLANK.";
		error = error + 1;
		return;
	end;
	cards = cards[1:n];
*print 'after removing blanks, cards=', cards;

	/* --- find the first card that starts with BEGIN MODEL --- */
	found = 0;
	n = 0;
	do until (found = 1 | n = nrow(cards));
		n = n + 1;
		test = upcase(trim(left(cards[n])));
		if length(test) < 11 then word = "X";
		else word = substr(test,1,11);
		if word = "BEGIN MODEL" then found=1;
	end;
	if n = 0 then do;
		print , "*** ERROR *** DATA SET" thismodel_file "DOES NOT HAVE A BEGIN MODEL STATEMENT.";
		error = error + 1;
		return;
	end;
	cards = cards[n:nrow(cards)];
	/* set the current first card */
	current_card = trim(left(cards[1]));
*print 'cards after searching for begin=' cards;

	/* insert the contents of the data set into input_cards */
	if count = 1 then
		begin = cards;
	else
		begin = input_cards[1:count-1] // cards;

	/* if the BEGIN MODEL statement was the last card then return */
	if nrow(input_cards) = count then do;
		input_cards = begin;
		return;
	end;
	/* otherwise, check if the next card is an END MODEL statement and if so,
		skip it */
	else do;
		test = upcase(trim(left(input_cards[count+1])));
		call change (test, ';', '', 0);
		if test = "END MODEL" then do;
			if nrow(input_cards) = count+1 then
				input_cards = begin;
			else
				input_cards = begin // input_cards[count+2 : nrow(input_cards)];
		end;
		else
			input_cards = begin // input_cards[count+1 : nrow(input_cards)];
		return;
	end;
finish;

start find_model_statements; 
	use &model_data_set;
		read all var {card} into input_cards;
	close &model_data_set;

	* --- remove all blank cards;
	call remove_blanks(input_cards);

	* --- initialize;
	number_of_cards = nrow(input_cards);
	default_model_position = 0;
	error = 0;

	/* --- initialize --- */
	model_position = j(1,2,0);
	model_names = " ";
	temp = j(1,2,0);
	number_of_models = 0;
	count = 0;
	/* NOTE model_files initialized to macro variable model_data_set to
	   prevent the data from calling itself */
	nmodel_files = 1;
	model_files="&model_data_set";
	fatalerror=0;
*print "before do until:";
*print number_of_cards;
*print input_cards;
	do until (count = number_of_cards);
		count = count + 1;
		card = trim(left(input_cards[count]));
		if length(card) < 11 then goto cycle; /* too short for BEGIN MODEL */
		if upcase(substr(card,1,11))="BEGIN MODEL" then do;
			mattrib card label='';		
cardloop:	* print , card;

			/* get the model name and check for DATA= */
			if length(card)=11 then 
				thismodel_name= " ";
			else
				thismodel_name = trim(left(substr(card,12)));
			call change(thismodel_name, ';', '', 0);
			thismodel_file = check_for_dataset (thismodel_name);
*print thismodel_name thismodel_file;

			/* if this is a DATA =, then 
				1. check for recursion (cant have DATA1 --> DATA2 --> DATA1)
				2. insert that data set */
			if thismodel_file ^= "$" then do;
				fatalerror = check_recursion(thismodel_file, nmodel_files, model_files);
				if fatalerror=0 then do; /* insert only if there have been no fatalerrors */
					mattrib thismodel_file label='';
					print,  "NOTE: MODEL(S) TAKEN FROM DATA SET" thismodel_file;
					call insert_dataset (thismodel_file, count, input_cards, current_card);
					card = current_card;
					number_of_cards = nrow(input_cards);
*print number_of_cards;
*print current_card;
*print input_cards;
				end;
			end;
			/* this statement starts parsing of the first BEGIN MODEL statement in
			   the newly inserted model_data_set */
 			if thismodel_file ^= "$" & fatalerror=0 then goto cardloop;

			/* perform the rest only if there has been no fatal error */
			if fatalerror = 0 then do;

				/* concantenate the vectors */
				number_of_models = number_of_models + 1;
				model_names = model_names // thismodel_name;

				/* find the end model statement */
				temp[1] = count;
				temp[2] = 0;
				found = 0;
				if count < number_of_cards then do;
					do until (found = 1 | count = number_of_cards);
						count = count + 1;
						card = trim(left(input_cards[count]));
						if length(card) >= 9 then word = upcase(substr(card,1,9));
						else word = " ";
						if word="END MODEL" then do;
*print , card;
							temp[2] = count;
							found = 1;
						end;
					end;
				end;
				if count = number_of_cards & found = 0 then do;
					print , "*** ERROR *** PROBABLE MISSING END MODEL STATEMENT.";
					error = error + 1;
				end;
				else 
					model_position = model_position // temp;
			end;
		end;
	cycle:
		/* stop the DO UNTIL if a fatal error was encountered */
		if fatalerror=1 then count = number_of_cards;
	end;

	if fatalerror=1 | error > 0 then do; /* bug out on error */
		call symput("abort_job", "YES");
		return;
	end;

	if number_of_models = 0 then do;
		print , "*** ERROR *** MO MODEL DEFINITIONS FOUND";
		call symput("abort_job", "YES");
		return;
	end;

	/* fix up arrays */
	model_position = model_position[2:nrow(model_position),];
	model_names = model_names[2:nrow(model_names)];
	current_model = 0;

	/* store the results for use in matrix, mx and iml definitions */
	store current_model number_of_models model_position model_names;

	/* create the macro variable number_of_models for loops in macros */
	call symput("number_of_models", char(number_of_models));

	/* save input_cards so that matrix definitions can read them */
	cn = "Card";
	create temp_modelcards from input_cards [colname=cn];
	append from input_cards;

*print "Model Definitions Parsed without Error.";
*print input_cards;
*print current_model number_of_models model_position model_names;
finish;


/* ----------------------------------------------------------------------
	MAIN IML
   ---------------------------------------------------------------------- */
	aborttest = upcase(trim(left("&abort_job")));
	if aborttest ^= "YES" then run find_model_statements;
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: MODEL DEFINITIONS FINISHED. ABORT_JOB = &abort_job ;
