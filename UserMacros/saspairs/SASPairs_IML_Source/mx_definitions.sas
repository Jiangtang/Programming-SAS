/* ---------------------------------------------------------------------------
	READ IN MX COMMANDS AND SET CONSTRAINTS
   --------------------------------------------------------------------------- */
%put NOTE: MX DEFINITIONS STARTING;
proc iml symsize=500;
%include "&utilities";

/* ---------------------------------------------------------
	MODULES FOR INPUTING AND PARSING MX COMMANDS
   --------------------------------------------------------- */

start input_mx_commands (aborttest, mxpresent)
				   GLOBAL (cards, ncard, number_of_cards, constraints, error);

	/* bug out if program aborted in an earlier phase */
	if aborttest = 'YES' then return;

	/* --- reopens model data set and input cards --- */
	use temp_thismodel;
		read all var {card} into cards;
	close temp_thismodel;

	/* stuff for printing */
	load model_output_label;
	mattrib model_output_label label = ''  rowname='' colname='';

	if "&SPPrint_ParmList" = "YES" | "&SPPrint_StartVal" = "YES" then do;
		print '---------------------------------------------------------------------',
		      "Mx Definitions in Model Data Set: &model_data_set",
			  model_output_label,
		      '---------------------------------------------------------------------';
		if "&SPPrint_EchoCards" = "YES" then do;
			mattrib cards label='' rowname='' colname='';
			print , cards;
		end;
	end;

	/* --- initialize constraints --- */
	constraints = j(1,2,0);

	call delimit ("BEGIN MX", "END MX", cards, aborttest);
	if aborttest = "YES" then return;

	if "&SPPrint_ParmList" = "YES" | "&SPPrint_StartVal" = "YES" then
		print , '---------------------------------------------------------------------',
		        "Parsing MX Definitions for",
			    model_output_label,
		        '---------------------------------------------------------------------';

	number_of_cards = nrow(cards);
	do ncard = 1 to nrow(cards);
		test = parse_mx_command (cards[ncard]);
		if test = 0 then error = error + 1;
	end;

	/* check whether errors have been found and abort if needed */
	if error > 0 then aborttest = "YES";
	final:
finish;

start parse_mx_command (phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, free, parm_value,
                        can_change, constraints, temp_constraints, error);

	/* remove semicolons */
	call change (phrase, ';', '', 0);

	mattrib phrase label='' rowname='' colname='';
	if "&SPPrint_ParmList" = "YES" | "&SPPrint_StartVal" = "YES" then print , phrase;

	command = first_word(phrase, 1); 
	command = trim(left(upcase(command)));
	command = substr(command,1,2);
	value = 0;
	     if command = 'FI' then call FI_command (phrase);
	else if command = 'FR' then call FR_command (phrase);
	else if command = 'VA' | command = 'ST' then call ST_or_VA_command (phrase);
	else if command = 'EQ' then do;
		call EQ_command (phrase);
		constraints = constraints // temp_constraints;
	end;
	else if command = 'PA' | command = 'MA' then do;
		test = PA_or_MA_command (command, phrase);
		return (test);
	end;
	else if command = "CO" then do;
		test = CO_command (command, phrase);
	end;
	else do;
		msg = concat('*** ERROR *** NOT AN MX COMMAND: ',command);
		mattrib msg label='' rowname='' colname='';
		print , msg;
		error = error + 1;
	end;
	return (1);
finish;

start initial_parse (phrase, value) GLOBAL (error);
/* --- check if the first word is a number
      if number ==> returned phrase is a matrix name or matrix elements
	  if not a number ==> phrase remains unchanged --- */

	word = first_word (phrase, 0);
	test = is_this_a_number(word, 1, 1, value);
	if test = 1 then do;
		word = first_word (phrase,1);
		return (1);
	end;
	return (0);
finish;

start parse_matrix_args (phrase, mnames, mtype, nrows, ncols, matvec)
						GLOBAL (error);
/* ----------------------------------------------------------------
	Parse the matrix arguments for FR FI ST VA and EQ commands
	Logic:
		(1) check for a DIAG, OFFDIAG, BLOCK command and parse that if present
		(2) check for a valid matrix name defined in the model
		(3) if matrix name is valid, then get a list of words after
			the matrix name until
				3.a) a string beginning with a letter or
				3.b) the end of the line
	Returns:
		matvec = (nrow x 3) matrix where
			matvec[,1] = the number of the matrix
			matvec[,2] = row number in the matrix_arg phrase
			matvec[,3] = the column number in the matrix_arg phrase
	NOTE WELL: Either an upper or lower element may be referenced for
		an S or C matrix. Routine CHECK_ALL fixes that.
   ----------------------------------------------------------------- */

	/* --- error on blank string --- */
	if phrase = ' ' then do;
		print , '*** ERROR *** NO MATRIX ELEMENTS SPECIFIED.';
		error = error + 1;
		return (0);
	end;

	/* set up matvec and temp */
	matvec = j(1,3,0);
	value = 0;
*print phrase;
	/* loop until blank */
	do while (phrase ^= ' ');
		word = first_word(phrase,0);
		test = matrix_elements_functions (word, phrase, matvec, mnames, mtype, nrows, ncols);
*print "test from diag_offdiag_block = " test;
		if test=0 then return (0);  /* there was an error in diag, offdiag, etc. */
		else if test = 1 then word = first_word(phrase,1); /* remove WORD from PHRASE */
		else goto cycle; /* A DIAG or OFFDIAG command was found, so skip the rest */

		/* test for a valid matrix name */
		matrix = get_matrix_name (word, mnames);
*print 'matrix:' word matrix;
		if matrix = 0 then do;
			msg = concat('*** ERROR *** MATRIX NOT DEFINED: ',trim(left(word)) );
			mattrib msg label = ''  rowname='' colname='';
			print , msg;
			error = error + 1;
			return (0);
		end;

		/* loop through the subsequent words until the end of the phrase
			or until there is another word beginning with A-Z */
		words = " ";
		stopit = 0;
		do while (stopit=0);
			word = first_word (phrase, 0);
			if word = " " then stopit = 1; /* end condition for do while */
			else do;
				test = upcase(substr(word,1,1));
				if (test >= "A") & (test <= "Z") then stopit=1; /*begins with a letter */
				else do;
					words = words // word; /* add to vector words */
					word = first_word(phrase,1); /* remove WORD from PHRASE */
				end;
			end;
		end;

		/* parse the elements */
		test = parse_elements (matrix, words, mtype[matrix], nrows[matrix], ncols[matrix],
								matvec);
		if test=0 then return (0);
	cycle:
	end;
	
	matvec = matvec[2:nrow(matvec),]; /* removes the initial row */
	return (1);
finish;

start parse_elements (matrix, words, mtype, nrows, ncols, matvec) GLOBAL (error);
/* parses a list of elements after a matrix name */

	temp = j(1,3,matrix);
	/* if there are no words, then th reference is to a whole matrix */
	if nrow(words) = 1 then do;
		temp[2] = 0;
		temp[3] = 0;
		matvec = matvec // temp;
		return (1);
	end;

	/* eliminate the first row of words (which is blank) */
	words = words[2:nrow(words)];

	/* loop over all the indixes for this matrix */
	stopit = 0; /* initialize */
	count = 0;
	row = 0;
	col = 0;
	nwords = nrow(words);
	do while (stopit=0);
		/* these two elements are obligatory positive integers */
		count = count + 1;
		if count >= nwords then do;
			print , "*** ERROR *** MISSING ROW OR COLUMN INDEX.";
			error = error + 1;
			return (0);
		end;
		word = words[count];
		test = is_this_a_number (word, 1, 1, row);
		if test = 0 then do;
			msg = concat('*** ERROR *** ROW NUMBER NOT A POSITIVE INTEGER: ', word);
			print , msg;
			error = error + 1;
			return (0);
		end;
		count = count + 1;
		if count > nwords then do;
			print , "*** ERROR *** MISSING ROW OR COLUMN INDEX.";
			error = error + 1;
			return (0);
		end;
		word = words[count];
		test = is_this_a_number (word, 1, 1, col);
		if test = 0 then do;
			msg = concat('*** ERROR *** COLUMN NUMBER NOT A POSITIVE INTEGER: ', word);
			print , msg;
			error = error + 1;
			return (0);
		end;
		
		/* add to matvec */
		temp[2] = row;
		temp[3] = col;
		matvec = matvec //temp;

		/* check if this is the end */
		if count = nwords then stopit = 1;
	end;
	return (1);
finish;

start matrix_elements_functions (word, phrase, matvec, mnames, mtype, nrows, ncols)
		global (error);
/* --------------------------------------------------------------------------------
	parses DIAG, OFFDIAG, BLOCK and AUTOREG commands
   -------------------------------------------------------------------------------- */

	/* --- if the length is < 4 then cannot be a DIAG BLOCK or OFFDIAG --- */
	len_word = length(word);
	if len_word < 4 then return (1);

	/* --- check if the substring = DIAG --- */
	command = upcase(substr(word,1,4));
	if command ="DIAG" then do;
		argstart = 5; /* starting index for getting the argument */
	end;
	else do;
		if len_word < 5 then return (1); /* cannot be a BLOCK or OFFDIAG command*/
		command = upcase(substr(word,1,5));
		if command = "BLOCK" then do;
			argstart = 6;
		end;
		else do;
			if len_word < 7 then return (1); /* cannot be OFFDIAG command */
			command = upcase(substr(word,1,7));
			if command = "OFFDIAG" | command = "AUTOREG" then do;
				argstart = 8;
			end;
			else return (1); /* none of the commands have been found */
		end;
	end;
*print command argstart;
	/* find the argument to the command */

	open_parens = indexc(phrase,'(');
	close_parens = indexc(phrase, ')');
*print open_parens close_parens;
	/* --- error conditions ---*/ 
	if open_parens = 0 then do;
		print , "*** ERROR *** MISSING OPEN PARENTHESIS FOR DIAG/OFFDIAG/BLOCK COMMAND";
		error = error + 1;
		return (0);
	end;
	if open_parens > argstart + 1 then do;
		test = substr(phrase,argstart+1, open_parens-argstart-1);
		if test ^= " " then do;
*print "bad test between argstart and open parens: test=" test;
			print , "*** ERROR *** BAD DIAG/OFFDIAG/BLOCK SYNTAX";
			error = error + 1;
			return (0);
		end;
	end;

 	if close_parens = 0 then do;
		print , "*** ERROR *** MISSING CLOSE PARENTHESIS FOR DIAG/OFFDIAG/BLOCK COMMAND";
		error = error + 1;
		return (0);
	end;

	if close_parens = open_parens+1 then do;
		print , "*** ERROR *** BAD DIAG/OFFDIAG/BLOCK SYNTAX";
		error = error + 1;
		return (0);
	end;

	/* the argument to the command */
	arg = substr(phrase, open_parens+1, close_parens - open_parens -1);
*print arg;

	if command = "BLOCK" then do; /* BLOCK requires different parsing */
		test = block_command (arg, mnames, mtype, nrows, ncols, matvec);
		if close_parens = length(phrase) then phrase = " "; /* fix up phrase */
		else phrase = substr(phrase, close_parens+1);
		return (test);
	end;
	else if command = "AUTOREG" then do;
		test = autoreg_command (arg, mnames, mtype, nrows, ncols, matvec);
		if close_parens = length(phrase) then phrase = " "; /* fix up phrase */
		else phrase = substr(phrase, close_parens+1);
		return (test);
	end;

	/* this section for DIAG and OFFDIAG commands */
	do while (arg ^= " ");
		mnamein = first_word(arg,1);
		matrix = get_matrix_name (mnamein, mnames);
*print mnamein;
*print "matrix number is" matrix;
		if matrix = 0 then do;
			msg = concat('*** ERROR *** MATRIX NOT DEFINED: ',trim(left(mnamein)) );
			mattrib msg label = ''  rowname='' colname='';
			print , msg;
			error = error + 1;
			return (0);
		end;
		if mtype[matrix] = "V" | (mtype[matrix] = "U" & nrows[matrix] ^= ncols[matrix]) then do;
			print , "*** ERROR *** ILLEGAL MATRIX TYPE FOR DIAG/OFFDIAG FUNCTION";
			error = error + 1;
			return (0);
		end;
		if mtype[matrix] = "C" & command = "DIAG" then do;
			print , "*** ERROR *** ATTEMPT TO REFERENCE DIAGONALS OF A CORRELATION MATRIX.";
			error = error + 1;
			return (0);
		end;
		call diag_offdiag_command (command, matrix, nrows[matrix], ncols[matrix], matvec);
	end;

	/* --- fixup the phrase --- */
	if close_parens = length(phrase) then phrase = " ";
	else phrase = substr(phrase, close_parens+1);
	return (2);
finish;

start diag_offdiag_command (command, matrix, nrows, ncols, matvec);
/* --- places elements into matvec for DIAG or OFFDIAG command --- */
	temp = j(1,3,matrix);
	if command="DIAG" then do;
		do row = 1 to nrows;
			temp[2] = row;
			temp[3] = row;
			matvec = matvec // temp;
		end;
	end;
	else do; 
		/* NOTE WELL: only lower elements are set so that there is not an
			error for an L matrix. routine CHECK_ALL will fix this up for
			an S or a C matrix */
		do row = 1 to nrows;
			do col = row + 1 to ncols;
				temp[2] = col;
				temp[3] = row;
				matvec = matvec // temp;
			end;
		end;
	end;
finish;

start block_command (arg, mnames, mtype, nrows, ncols, matvec) GLOBAL (error);
/* --- places elements in matvec for BLOCK command --- */
	mnamein = first_word(arg,1);
	matrix = get_matrix_name (mnamein, mnames);
*print mnamein;
*print "matrix number is" matrix;
	if matrix = 0 then do;
		msg = concat('*** ERROR *** MATRIX NOT DEFINED: ',trim(left(mnamein)) );
		mattrib msg label = ''  rowname='' colname='';
		print , msg;
		error = error + 1;
		return (0);
	end;
	
	/* the next four arguments must be positive integers */
	integer = j(4,1,0);
	value = 0;
	do i = 1 to 4;
		word = first_word(arg, 1);
		if word = " " then do;
			print , "*** ERROR *** NOT ENOUGH ROW/COLUMN INDICES FOR BLOCK COMMAND.";
			error = error + 1;
			return (0);
		end;
		test = is_this_a_number(word, 1, 1, value);
		if test = 0 then do;
			print , "*** ERROR *** A ROW/COLUMN INDEX IS NOT A POSITIVE INTEGER.";
			print msg;
			error = error + 1;
			return (0);
		end;
		integer[i] = value;
	end;

	if arg ^= " " then do;
		print , "*** ERROR *** EXTRANEOUS INFORMATION IN THE ARGUMENT TO A BLOCK COMMAND.";
		error = error + 1;
		return (0);
	end;

	rowstart = integer[1];
	colstart = integer [2];
	rowend = integer[3];
	colend = integer[4];

	/* error check */
	if rowend < rowstart then do;
		print , "*** ERROR *** ENDING ROW < STARTING ROW IN BLOCK COMMAND.";
		error = error + 1;
		return (0);
	end;
	if colend < colstart then do;
		print , "*** ERROR *** ENDING COLUMN < STARTING COLUMN IN BLOCK COMMAND.";
		error = error + 1;
		return (0);
	end;

	if rowstart < colstart then upper = 1;
	else upper = 0;

	if mtype[matrix] = "S" | mtype[matrix] = "C" | mtype[matrix] = "L" then type = 1;
	else type = 0;  /* to check whether a diagonal boundary is exceeded */

	warning = 0;
	if type=1 then do;
		if upper=1 & rowend >= colstart then warning=1;
		if upper=0 & colend >= rowstart then warning=1;
	end;
	if warning = 1 then
		print , "*** WARNING *** BLOCK COMMAND: DIAGONAL ELEMENTS REFERENCED. LOTSA LUCK.";

	temp = j(1, 3, matrix);

	do row = rowstart to rowend;
		do col = colstart to colend;
			temp[2] = row;
			temp[3] = col;
			matvec = matvec // temp;
		end;
	end;

	return (2);
finish;

start AUTOREG_command (arg, mnames, mtype, nrows, ncols, matvec) GLOBAL (error);
/* ------------------- AUTOREG = Autoregression Command ----------------------- */

	/* first argument must be a matrix name */
	mnamein = first_word(arg, 1);
	matrix = get_matrix_name(mnamein, mnames);
	if matrix=0 then do;
		mattrib mnamein label=''  rowname='' colname='';
		print , "*** ERROR *** MATRIX NOT DEFINED:" mnamein;
		error = error + 1;
		return (0);
	end;
	/* check for matrix type (must be U) */
	if mtype[matrix] ^= "U" & mtype[matrix] ^= "L" then do;
		print , "*** ERROR *** MATRIX ARGUMENT FOR AUTOREG FUNCTION MUST BE TYPE U OR L.";
		error = error + 1;
		return (0);
	end;

	/* next value must the the order of the autoregressive process */
	word = first_word(arg,1);
	n_order = 0;
	test = is_this_a_number(word, 1, 1, n_order);
	if test = 0 then do;
		print , "*** ERROR *** ORDER OF AUTOREGRESSION MUST BE A POSITIVE INTEGER.";
		error = error + 1;
		return (0);
	end;

	if n_order >= nrows[matrix] then do;
		print , "*** ERROR *** ORDER >= NUMBER OF MATRIX ROWS.";
		error = error + 1;
		return (0);
	end;

	col = 0;
	temp = j(1,3,matrix);
	do row = n_order+1 to nrows[matrix];
		col = col+1;
		temp[2] = row;
		temp[3] = col;
		matvec = matvec // temp;
	end;
	return (2);

finish;

start check_all (tempmat, mnames, mtype, nrows, ncols, bad) GLOBAL (error);
/* ----------------------------------------------------------------------------------
	Check the elements in matvec after the arguments to a FI FR ST VA or EQ command
	are parsed. Specific checks:
		(1) the number of rows and columns are within bounds
		(2) if row > col for S or a C then swap
		(3) if all rows and columns are affected (i.e., only a matrix name was given
		(4) various checks for specific matrix types
   ----------------------------------------------------------------------------------- */
	nrowtempmat = nrow(tempmat);
	bad = 0;
	msg = ' ';
	mattrib msg label=''  rowname='' colname='';
*print 'check_all' nrowtempmat tempmat;
	do i=1 to nrowtempmat;
		matrix = tempmat[i,1];
		mt = mtype[matrix];
		mname = mnames[matrix];
		row = tempmat[i,2];
		col = tempmat[i,3];
		if row=0 & col=0 then call add_the_whole_matrix (matrix, mt, 
										nrows[matrix], ncols[matrix], tempmat);
		else do;  /* error check here */
			/* check bounds */
			if (row > nrows[matrix] | row <= 0 ) then do;
				msg = concat('*** ERROR *** ILLEGAL ROW INDEX FOR MATRIX ', trim(left(mname)));
				print , msg;
				error = error + 1;
				bad = 1;   
			end;
			if (col > ncols[matrix] | col <= 0 ) then do;
				msg = concat('*** ERROR *** ILLEGAL COLUMN INDEX FOR MATRIX ', trim(left(mname)));
				print , msg;
				ERROR = ERROR + 1;
				bad = 1;
			end;

			/* other error checks */
			if mt = 'C' & (row=col) then do;
				msg = concat('*** ERROR *** DIAGONAL OF A CORRELATION MATRIX REFERENCED: ', trim(left(mname)));
				print , msg;
				ERROR = ERROR + 1;
				bad = 1;
			end;
			else if mt = 'L' & (row < col) then do;
				msg = concat('*** ERROR *** UPPER TRIANGLE OF AN L MATRIX REFERENCED: ', trim(left(mname)));
				print , msg;
				ERROR = ERROR + 1;
				bad = 1;
			end;
			else if mt = 'D' & (row ^= col) then do;
				msg = concat('*** ERROR *** NONDIAGONAL ELEMENT OF A D MATRIX REFERENCED: ', trim(left(mname)));
				print , msg;
				ERROR = ERROR + 1;
				bad = 1;
			end;
			else if mt = 'V' & col ^= 1 & row ^= 1 then do;
				msg = concat('*** ERROR *** VECTOR WITH ROW OR COL > 1 REFERENCED: ', trim(left(mname)));
				print , msg;
				ERROR = ERROR + 1;
				bad = 1;
			end;


			/* lower triangle of an S or C matrix */
			if (mt = 'S' | mt = 'C') & (row > col) then do;
				save = tempmat[i,2];
				tempmat[i,2] = tempmat[i,3];
				tempmat[i,3] = save;
			end;
		end;
	end;

	/* --- remove those rows with row=0 and col=0 */
	n = 0;
	do i = 1 to nrow(tempmat);
		if tempmat[i,2] ^= 0 & tempmat[i,3] ^= 0 then do;
			n=n+1;
			tempmat[n,] = tempmat[i,];
		end;
	end;
	tempmat = tempmat[1:n,];
*print 'check all:' tempmat bad;
finish;

start add_the_whole_matrix (matrix, type, nrows, ncols, tempmat);
/* adds the elements of a whole matrix */
	if type='U' | type = 'V' then do;
		size = nrows*ncols;
		temp = j(size, 3, matrix);
		count = 0;
		do row = 1 to nrows;
			do col = 1 to ncols;
				count = count + 1;
				temp[count,2] = row;
				temp[count,3] = col;
			end;
		end;
	end;
	else if type = 'D' then do;
		size = nrows;
		temp = j(size, 3, matrix);
		count = 0;
		do row = 1 to nrows;
			count = count + 1;
			temp[count,2] = row;
			temp[count,3] = row;
		end;
	end;
	else if type = "L" then do;
		size = (nrows*nrows + nrows) / 2;
		temp = j(size, 3, matrix);
		count = 0;
		do row = 1 to nrows;
			do col = 1 to row;
				count = count + 1;
				temp[count,2] = row;
				temp[count,3] = col;
			end;
		end;
	end;
	else do; /* C or S matrices */
		size = (nrows*nrows + nrows)/2;
		c = 0;
		if type = 'C' then do;
			size = size - nrows;
			c = 1;
		end;
		temp = j(size, 3, matrix);
		count = 0;
		do row = 1 to nrows;
			do col = row + c to ncols;
				count = count + 1;
				temp[count,2] = row;
				temp[count,3] = col;
			end;
		end;
	end;
	tempmat = tempmat // temp;
finish;

start FI_command (phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, free, parm_value,
                        can_change, constraints, temp_constraints, error);

	value = 0;
	save_value = initial_parse (phrase, value);

	matvec = j(1,3,0);
	test = parse_matrix_args (phrase, mnames, mtype, nrows, ncols, matvec);
	if test = 0 then return;

	/* perform checks on bounds, legitimate elements, etc. */
	call check_all (matvec, mnames, mtype, nrows, ncols, bad);
	if bad = 1 then return;
	do i=1 to nrow(matvec);
		matrix = matvec[i,1];
		row = matvec[i,2];
		col = matvec[i,3];
		pn = get_parameter_number (row, col, nrows[matrix], ncols[matrix], index_x[matrix,1]);
		if can_change[pn] = 0 then do;
			print , '*** ERROR *** ATTEMPT TO CHANGE A MATRIX ELEMENT THAT CANNOT BE CHANGED:',
			        'PROBABLE PROGRAMMING ERROR.';
			mattrib mname label=''  rowname='' colname='';
			mattrib row label=''  rowname='' colname='';
			mattrib col label=''  rowname='' colname='';
			mname = mnames[matrix];
			print , mname row col;
			error = error + 1;
		end;
		else do;
			free[pn] = 0;
			if save_value = 1 then parm_value[pn] = value;
		end;
	end;
*print free parm_value;
finish;

start FR_command (phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, free, parm_value,
                        can_change, constraints, temp_constraints, error);

	matvec = j(1,3,0);
	test = parse_matrix_args (phrase, mnames, mtype, nrows, ncols, matvec);
	if test = 0 then return;

	/* perform checks on bounds, legitimate elements, etc. */
	call check_all (matvec, mnames, mtype, nrows, ncols, bad);
	if bad = 1 then return;
*print 'FR command: matvec=' matvec;
	do i=1 to nrow(matvec);
		matrix = matvec[i,1];
		row = matvec[i,2];
		col = matvec[i,3];
		pn = get_parameter_number (row, col, nrows[matrix], ncols[matrix], index_x[matrix,1]);
*print matrix (mnames[matrix]) i pn;
		if can_change[pn] = 0 then do;
			print , '*** ERROR *** ATTEMPT TO CHANGE A MATRIX ELEMENT THAT CANNOT BE CHANGED:',
			        'PROBABLE PROGRAMMING ERROR.';
			mname = mnames[matrix];
			print , mname row col;
			error = error + 1;
		end;
		else do;
			free[pn] = 1;
		end;
	end;
*num=1:nrow(free);
*num=t(num);
*print 'FR Command:' num free parm_value;
finish;


start ST_or_VA_command (phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, free, parm_value,
                        can_change, constraints, temp_constraints, error);

	value = 0;
	save_value = initial_parse (phrase, value);
	if save_value = 0 then do;
		print , '*** ERROR *** NUMERIC VALUE NOT SPECIFIED.';
		error = error + 1;
		return;
	end;

	matvec = j(1,3,0);
	test = parse_matrix_args (phrase, mnames, mtype, nrows, ncols, matvec);
	if test = 0 then return;

	/* perform checks on bounds, legitimate elements, etc. */
	call check_all (matvec, mnames, mtype, nrows, ncols, bad);
	if bad = 1 then return;
*print matvec;
	do i=1 to nrow(matvec);
		matrix = matvec[i,1];
		row = matvec[i,2];
		col = matvec[i,3];
		pn = get_parameter_number (row, col, nrows[matrix], ncols[matrix], index_x[matrix,1]);
*print i pn;
		if can_change[pn] = 0 then do;
			print , '*** ERROR *** ATTEMPT TO CHANGE A MATRIX ELEMENT THAT CANNOT BE CHANGED:',
			        'PROBABLE PROGRAMMING ERROR.';
			mname = mnames[matrix];
			print , mname row col;
			error = error + 1;
		end;
		else do;
			if save_value = 1 then parm_value[pn] = value;
		end;
	end;
*print free parm_value;
finish;

start EQ_command (phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, free, parm_value,
                        can_change, constraints, temp_constraints, error);

	matvec = j(1,3,0);
	test = parse_matrix_args (phrase, mnames, mtype, nrows, ncols, matvec);
	if test = 0 then return;

	/* perform checks on bounds, legitimate elements, etc. */
	call check_all (matvec, mnames, mtype, nrows, ncols, bad);
	if bad = 1 then return;

	matrix = matvec[1,1];
	row = matvec[1,2];
	col = matvec[1,3];
	if mtype[matrix] = "S" | mtype[matrix] = "C" then do;
		if row > col then do; /* swap when row > col */
			save = col;
			col = row;
			row = save;
		end;
	end;
	firstparm = get_parameter_number (row, col, nrows[matrix], ncols[matrix], index_x[matrix,1]);
	temp = firstparm;
	do i=2 to nrow(matvec);
		matrix = matvec[i,1];
		row = matvec[i,2];
		col = matvec[i,3];
		if mtype[matrix] = "S" | mtype[matrix] = "C" then do;
			if row > col then do; /* swap when row > col */
				save = col;
				col = row;
				row = save;
			end;
		end;
		thistemp = get_parameter_number (row, col, nrows[matrix], ncols[matrix], index_x[matrix,1]);
		temp = temp // thistemp;
	end;
	temp2 = j(nrow(matvec),1,firstparm);
	temp_constraints = temp || temp2;
*print "EQ Command:";
*print temp_constraints;
finish;


/* --------------------------------------------------------------------------------------------
	PA or MA routines
   -------------------------------------------------------------------------------------------- */

start PA_or_MA_command (command, phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, free, parm_value,
                        can_change, constraints, temp_constraints, error,
						cards, ncard, number_of_cards);

	/* get the matrix number */
	mn = first_word(phrase, 1);
	if mn = " " then do;
		print , "*** ERROR *** MATRIX NAME MISSING ON PA OR MA COMMAND.";
		return (0);
	end;
	matrix = 0;
	test = upcase(mn);
	do i=1 to nrow(mnames);
		if test = upcase(mnames[i]) then matrix = i;
	end;
	if matrix = 0 then do;
		mattrib mn label=''  rowname='' colname='';
		print , "*** ERROR *** MATRIX NOT FOUND:" mn;
		return (0);
	end;

	/* check that there are no more elements beside PA (or MA) matrix_name */
	if phrase ^= " " then do;
		phrase = trim(left(phrase));
		mattrib phrase label=''  rowname='' colname='';
		print , "*** ERROR *** EXTRA CHARACTERS ON PA OR MA COMMAND:" phrase;
		return (0);
	end;

	/* --- read in the cards --- */
	call read_in_a_matrix (command, mtype[matrix], nrows[matrix], ncols[matrix], result, errorin);
	if errorin > 0 then return (0); /* this should abort the job */

	/* --- place the elements into the appropriate vectors --- */
	start = index_x[matrix,1];
	call set_pa_ma_values (command, start, mtype[matrix], nrows[matrix], ncols[matrix], result, 
				free, parm_value, errorin);
	if errorin = 0 then
		return (1);
	else
		return (0);
finish;

start read_in_a_matrix (command, mtype, nrows, ncols, result, errorin)
                    GLOBAL(cards, ncard, number_of_cards, error);
/* read in the values for a PA or an MA card */

	/* number of elements to read in */
	if mtype = "V" | mtype = "U" then
		needed = nrows * ncols;
	else if mtype = "L" | mtype = "S" then
		needed = (nrows*nrows + nrows)/2;
	else if mtype = "C" then
		needed = (nrows*nrows - nrows)/2;
	else if mtype = "D" then
		needed = nrows;
	else
		print , "********** PROGRAMMING ERROR IN READ_IN_A_MATRIX **********";

	result = 0;
	n = 0;
	errorin = 0;
	do until (n >= needed | errorin > 0);
		ncard = ncard + 1;
		card = cards[ncard];
		mattrib card label=''  rowname='' colname='';
		print , card;
		call read_pa_ma_card (card, n, result, errorin);
		if errorin > 0 then return; /* input error in readin in matrix */
	end;

	if n > needed then do;
		print , "*** ERROR *** PA or MA COMMAND INPUT: TOO MANY ELEMENTS FOR MATRIX.";
		errorin = 1;
		return;
	end;

	if nrow(result) = 1 then do;
		print , "*** ERROR *** NO MATRIX ELEMENTS TO READ IN.";
		errorin=1;
		return;
	end;

	/* remove the first element in result */
	result = result[2:nrow(result)];
finish;

start read_pa_ma_card (card, n, result, errorin);
/* --- read in a line from a PA or MA command --- */
	value = 0;
	do while (card ^= " ");
		test = first_word(card, 1);
		n=n+1;
		test2 = is_this_a_number (test, 1, 1, value);
		if test2 = 0 then do;
			mattrib test label=''  rowname='' colname='';
			print , "*** ERROR *** PA or MA COMMAND INPUT NOT A NUMBER:" test;
			errorin = errorin + 1;
		end;
		else
			result = result // value;
	end;
finish;

start set_pa_ma_values (command, start, mtype, nrows, ncols, result, 
				free, parm_value, errorin);
/* --- check the matrix types and then put the value of result into the
		appropriate vector --- */

	n = 0;
	if mtype = "V" | mtype = "U" then do;
		pn = get_parameter_number(1, 1, nrows, ncols, start) - 1;
		do row=1 to nrows;
			do col=1 to ncols;
				pn = pn + 1;
				n=n+1;
				call put_pa_ma_in (command, pn, n, result, parm_value, free);
			end;
		end;
	end;
	else if mtype = "L" | mtype = "S" then do;
		do row=1 to nrows;
			do col=1 to row; /* note the transpose */
				pn = get_parameter_number(col, row, nrows, ncols, start);
				n=n+1;
				call put_pa_ma_in (command, pn, n, result, parm_value, free);
			end;
		end;
	end;
	else if mtype = "C" then do;
		do row=1 to nrows;
			do col = 1 to row-1; /* note the transpose */
				pn = get_parameter_number(col, row, nrows, ncols, start);
				n=n+1;
				call put_pa_ma_in (command, pn, n, result, parm_value, free);
			end;
		end;
	end;
	else if mtype = "D" then do;
		do row=1 to nrows;
			col = row;
			pn = get_parameter_number (row, col, nrows, ncols, start);
			n=n+1;
			call put_pa_ma_in (command, pn, n, result, parm_value, free);
		end;
	end;
finish;

start put_pa_ma_in (command, pn, n, result, parm_value, free);
	if command = "MA" then
		parm_value[pn] = result[n];
	else if result[n] = 0 then
		free[pn] = 0;
	else
		free[pn] = 1;
finish;
/* --------------------------------------------------------------------------------------------
	End of PA or MA routines
   -------------------------------------------------------------------------------------------- */



start CO_command (command, phrase)
			    GLOBAL (mnames, mtype, nrows, ncols, index_x, parm_value, error);
/* -------------------------------------------------------------------------------
	Compute starting values for _A, _U, and _E matrices
   ------------------------------------------------------------------------------- */

	/* get the matrix number */
	matvec = j(1,3,0);
	test = parse_matrix_args (phrase, mnames, mtype, nrows, ncols, matvec);
	if test = 0 then return (0);

	/* --- abort if a SASPeds macro was called --- */
	test = upcase(substr("&macro_name", 1, 7));
	if test = "SASPEDS" then do;
		print , "***  ERROR *** CO STATEMENT IS NOT IMPLEMENTED IN SASPeds MACROS";
		error = error + 1;
		return (0);
	end;

	/* --- matrices for which start values can be computed --- */
	goodnames = {"VA" "FA" "SA" "VU" "FU" "SU" "VE" "FE" "SE"};
	do i=1 to nrow(matvec);
		matrix = matvec[i,1];
		thisname = upcase(trim(left(mnames[matrix])));
		thisname = substr(thisname,1,2);

		/* test it this is a valid matrix for computing start values */
		found = 0;
		do j=1 to ncol(goodnames);
			if thisname = goodnames[j] then found=1;
		end;
		if found=0 then do;
			mattrib thisname label=''  rowname='' colname='';
			print , "*** ERROR *** START VALUES CANNOT BE COMPUTED FOR MATRIX" thisname;
			error = error + 1;
			return (0);
		end;

		/* check if this is a valid matrix type */
		thismtype = mtype[matrix];
		mattrib thismtype label=''  rowname='' colname='';
		if thismtype = "C" then do;
			print , "*** ERROR *** START VALUES CANNOT BE COMPUTED FOR MATRIX TYPE" thismtype;
			error = error + 1;
			return (0);
		end;
		else if substr(thisname,1,1) = "F" & thismtype = "S" then do;
			print , "*** ERROR *** START VALUES CANNOT BE COMPUTED FOR A SYMMETRIC F MATRIX";
			error = error + 1;
			return (0);
		end;


		/* compute the start values */
		call compute_start_values (thisname, thismtype, nrows[matrix], ncols[matrix], result);
*print thisname thismtype result;

		/* place the start values into parm_value */
		start = index_x[matrix,1];
		do row = 1 to nrows[matrix];
			if thismtype = "U" | thismtype = "V" then do;
				do col = 1 to ncols[matrix];
					pn = get_parameter_number(row, col, nrows[matrix], ncols[matrix], start);
					parm_value[pn] = result[row,col];
				end;
			end;
			else if thismtype = "S" then do;
				do col = row to ncols[matrix];
					pn = get_parameter_number(row, col, nrows[matrix], ncols[matrix], start);
					parm_value[pn] = result[row,col];
				end;
			end;
			else if thismtype = "L" then do;
				do col = 1 to row;
					pn = get_parameter_number(row, col, nrows[matrix], ncols[matrix], start);
					parm_value[pn] = result[row,col];
				end;
			end;
			else if thismtype = "D" then do;
				col = row;
				pn = get_parameter_number(row, col, nrows[matrix], ncols[matrix], start);
				parm_value[pn] = result[row,col];
			end;
			else print , "********** PROGRAMMING ERROR IN CO_Command **********";
		end;
	end;
	return (1);
finish;

start compute_start_values (matrix_name, mtype, nrows, ncols, result);
/* ---------------------------------------------------------------
	compute automatric starting values--only when models are
	fitted to covariance matrices
   --------------------------------------------------------------- */
	load n_rel n_var gamma cov_mats df;

	n_phenotypes = n_var / 2;
	weight = 0;
	vstart = j(n_phenotypes, n_phenotypes, 0);
	start = 1;
	mattrib matrix_name label=''  rowname='' colname='';

	/* find the initial matrix */
	second_letter = substr(matrix_name, 2, 1);
	if second_letter = "A" then do;
		do i=1 to n_rel;
			stop = start + n_var - 1;
			temp = cov_mats[start:stop,];
			start = stop + 1;
			gamma_a = gamma[i,1];
			vstart = vstart + gamma_a * df[i] * temp[1:n_phenotypes, n_phenotypes+1:n_var]
							+ gamma_a * df[i] * temp[n_phenotypes+1:n_var, 1:n_phenotypes];
			weight = weight + 2*gamma_a*df[i];
		end;
		vstart = vstart / weight;
	end;
	else if second_letter = "U" | second_letter = "E" then do;
	    /* this is for matrices _U or _E */
		do i=1 to n_rel;
			stop = start + n_var - 1;
			temp = cov_mats[start:stop,];
			start = stop + 1;
			vstart = vstart + df[i] * temp[1:n_phenotypes, 1:n_phenotypes]
							+ df[i] * temp[n_phenotypes+1:n_var, n_phenotypes+1:n_var];
			weight = weight + 2*df[i];
		end;
		vstart = vstart / weight;
	end;
	else print , "********** PROGRAMMING ERROR IN compute_start_values **********";

	first_letter = substr(matrix_name, 1, 1);
	if first_letter = "V" then do;
		result = vstart;
		return;
	end;
	if first_letter = "S" then do;
		result = diag(vstart);
		return;
	end;
	if first_letter = "F" & mtype = "D" then do;
		result = 0 * vstart;
		do i = 1 to nrow(vstart);
			if vstart[i,i] > 0 then result[i,i] = sqrt(vstart[i,i]);
		end;
		return;
	end;
	if first_letter = "F" & mtype = "L" then do;
		minev = min(eigval(vstart));
		if minev <= 0 then do;
			print , "WARNING: START VALUES CANNOT BE COMPUTED FOR MATRIX" matrix_name,
	                "         START VALUES SET TO sqrt(diag(" matrix_name "))";
			result = 0 * vstart;
			do i=1 to nrow(vstart);
				if vstart[i,i] > 0 then result[i,i] = sqrt(vstart[i,i]);
			end;
			return;
		end;
		else do;
			result = t(half(vstart));
			return;
		end;
	end;
	if first_letter = "F" & (mtype = "U" | mtype = "V") then do;
		/* matrix must be a factor pattern matrix of type = "V" or type = "U" */
		evec = eigvec(vstart);
		eval = eigval(vstart);
*print evec eval;
		if mtype="U" | (mtype="V" & ncols > nrows) then do;
			evec = evec[,1:ncols];
			eval = diag(eval[1:ncols]);
		end;
		else do;
			evec = evec[1:nrows,];
			eval = diag(eval[1:nrows]);
		end;
*print evec eval;
		if min(eval) < 0 then do;
			print , "WARNING: START VALUES CANNOT BE COMPUTED FOR AT LEAST ONE COLUMN OF MATRIX" matrix_name,
			        "         BECAUSE OF NEGATIVE EIGENVALUES. START VALUES FOT THIS COLUMN SET TO 0",
					"         RAW EIGENVECTORS AND EIGENVALUES OF THE PROBLEM ARE:";
			mattrib evec label = 'EigenVectors' format=12.3  rowname='' colname='';
			mattrib eval label = ' EigenValues' format=12.6  rowname='' colname='';
			print evec eval;
			do i = 1 to nrow(eval);
				if eval[i,i] <= 0 then eval[i,i] = 0;
			end;
		end;
		result = evec * sqrt(eval);
	end;
	else
		print "************* PROGRAMMING ERROR IN COMPUTE_START_VALUES *********";
	return;
finish;

start check_element (phrase, value);
	word = first_word(phrase,1);
	if word = ' ' then do;
		print , '*** ERROR *** PA OR MA COMMAND: NOT ENOUGH ELEMENTS IN THIS ROW.';
		error = error + 1;
		return (0);
	end;
	value=0;
	test = is_this_a_number (word, 1, 1, value);
	if test=0 then do;
		print , '*** ERROR *** PA OR MA COMMAND: ELEMENT IS NOT A NUMBER.';
		error = error + 1;
		return (0);
	end;
	return (1);
finish;

start fixup_equality_constraints (equality_constraints, constraints, free);
/* eliminate unneeded rows in the matrix and set elements in free */
	n = 0;
	equality_constraints = constraints // equality_constraints;
*print "fixup_equality_constraints";
*print constraints;
*print equality_constraints;
	do i=2 to nrow(equality_constraints);
		if (equality_constraints[i,1] ^= equality_constraints[i,2]) then do;
			n=n+1;
			equality_constraints[n,] = equality_constraints[i,];
		end;
	end;
	if n > 0 then equality_constraints = equality_constraints[1:n,];
				
	do i=1 to n;
		free[equality_constraints[i,1]] = 0;
	end;
finish;

start setup_whereinx (free, parm_value, equality_constraints, whereinx, nfree, x0);
/* get the positional vector whereinx that gives the position of a parameter
   in the vector x returned by the minimizer --- */
	nfree = sum(free);
	x0 = j(nfree,1,0);
	whereinx = j (nrow(free),1,0);

	/* set constant if a parameter is started at 0 */
	eta = constant("sqrtmaceps");
	sqrteta = sqrt(eta);

	n = 0;
	do i=1 to nrow(free);
		if free[i] = 1 then do;
			n = n + 1;
			whereinx[i] = n;
			x0[n] = parm_value[i];
			if x0[n] = 0 then x0[n] = sqrteta;
		end;
	end;

	if sum(equality_constraints) > 0 then do;
		do i = 1 to nrow(equality_constraints);
			whereinx[equality_constraints[i,1]] = whereinx[equality_constraints[i,2]];
			parm_value[equality_constraints[i,1]] = parm_value[equality_constraints[i,2]];
		end;
	end;
finish;

start print_summary (mnames, free, parm_value, index_x, nrows, ncols, 
					whereinx);
/* --- print a summary of where the paraemters are in x as well as
       the start values --- */

	/* free and fixed status */
	load model_output_label;
	mattrib model_output_label label = ''  rowname='' colname='';
	if "&SPPrint_ParmList" = "YES" then do;
		print , '---------------------------------------------------------------------',
		        "Parameter Matrices for:",
			    model_output_label,
		        '---------------------------------------------------------------------';
		do i=1 to nrow(mnames);
			label = trim(left(mnames[i]));
			temp = shape(whereinx[index_x[i,1]:index_x[i,2]], nrows[i], ncols[i]);
			mattrib temp label=label format=8.0  rowname='' colname='';
			print , temp;
		end;
	end;

	/* start values */
	if "&SPPrint_StartVal" = "YES" then do;
		print , '---------------------------------------------------------------------',
		        "Start Values for:",
			    model_output_label,
		        '---------------------------------------------------------------------';
		do i=1 to nrow(mnames);
			label = trim(left(mnames[i]));
			temp = shape(parm_value[index_x[i,1]:index_x[i,2]], nrows[i], ncols[i]);
			mattrib temp label=label format=8.3  rowname='' colname='';
			print , temp;
		end;
	end;
finish;

start construct_parm_label (mnames, nrows, ncols, free, parm_label);
	parm_label = " ";
	pn = 0;
	do i=1 to nrow(mnames);
		thismatrix = trim(left(mnames[i]));
		do row = 1 to nrows[i];
			do col = 1 to ncols[i];
				pn = pn + 1;
				if free[pn] = 1 then do;
					r = trim(left(char(row)));
					c = trim(left(char(col)));
					temp = concat(thismatrix, '[', r, ',', c, ']');
					parm_label = parm_label // temp;
				end;
			end;
		end;
	end;
	if nrow(parm_label) > 1 then parm_label = parm_label[2:nrow(parm_label)];
finish;

/* ---------------------------------------------------------------------------
	MAIN IML
   --------------------------------------------------------------------------- */
	do; /* stupid do statement */
		/* --- CHECK IF ABORT CODE IS PRESENT FROM AN EARLIER STEP --- */
		aborttest = upcase(trim(left("&abort_job")));
		if aborttest = 'YES' then;
			print '*** CALL TO READING IN MX CONSTRAINT COMMANDS HAS BEEN ABORTED',
			      '    BECAUSE OF PREVIOUS ERRORS.';
		if aborttest = "YES" then goto final;


		/* load the matrices from the matrix_definition routine */
		load mnames mtype nrows ncols index_x free parm_value can_change equality_constraints;
*print "Mx_defintions: equality_constraints", equality_constraints;
		/* initialize the error counter and call the module to read in mx commands */	 
		error = 0;
		call input_mx_commands (aborttest, mxpresent);

		if aborttest ^= 'YES' then do;
			call fixup_equality_constraints (equality_constraints, constraints, free);
			call setup_whereinx (free, parm_value, equality_constraints, whereinx, nfree, x0);
			call print_summary (mnames, free, parm_value, index_x, nrows, ncols, 
								whereinx);
			call construct_parm_label (mnames, nrows, ncols, free, parm_label);
			store free parm_value parm_label whereinx x0;
*num = 1:nrow(free);
*num = t(num);
*print num free parm_value whereinx;
		end;
	final:
		if aborttest="YES" then
			call symput("abort_job", "YES");
		else if "&SPPrint_ParmList" = "YES" | "&SPPrint_StartVal" = "YES" then
			print , "Mx Commands Parsed Without Errors.";
	end;
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: MX DEFINITIONS FINISHED. ABORT_JOB = &abort_job ;
