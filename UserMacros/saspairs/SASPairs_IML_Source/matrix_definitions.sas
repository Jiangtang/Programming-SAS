/* ---------------------------------------------------------------------
   THIS SECTION READS IN THE MATRIX DEFINITIONS
   --------------------------------------------------------------------- */
%put NOTE: MATRIX DEFINITIONS STARTING;
proc iml;
%include "&utilities";
/* ---------------------------------------------------
	MODULES USED IN THE MATRIX DEFINITION ROUTINE
   --------------------------------------------------- */
start setup_default_matrices (aborttest)
		GLOBAL (n_default_matrices, default_mnames, default_mtype, 
				default_rows, default_cols, must_be_present, error);
/* -----------------------------------------------------------------------
	SETS UP A DEFAULT MODEL SPECIFIED BY THE USER
   ----------------------------------------------------------------------- */
	if aborttest = "YES" then goto final;

	if "&default_matrices" = "&blank" then do; /* no defaultmatrices specified */
		n_default_matrices = 0;
		default_mnames = "dummy_matrix";
		default_mtype = "?";
		default_rows = 0;
		default_cols = 0;
		must_be_present=0;
	end;
	else do;
		call read_default_matrices (aborttest);
		default_mtype = upcase(default_mtype);
		default_rows = &n_phenotypes*default_rows;
		default_cols = &n_phenotypes*default_cols;
		/* check that a matrix that must be present has default rows and cols
		   and also that square matrices have default_row = default_cols */
		do i=1 to n_default_matrices;
			if (must_be_present[i] = 1) & (default_rows[i] = 0 | default_cols[i] = 0) then do;
				print , "*** ERROR *** A MUST_BE_PRESENT MATRIX MUST HAVE DEFAULT_ROWS AND",
					    "              DEFAULT_COLS = 1.";
				aborttest="YES";
				call symput ("abort_job", "YES");
				return;
			end;
			if (default_mtype[i] = "C" | default_mtype[i] = "S" | default_mtype[i] = "L" | default_mtype[i] = "D") & 
				(default_cols[i] ^= default_rows[i]) then do;
					thisname = default_mnames[i];
					thismtype = default_mtype[i];
					thisrow = default_rows[i];
					mattrib thisname label='' rowname='' colname='';
					mattrib thismtype label='' rowname='' colname='';
					mattrib thisrow label='' rowname='' colname='';
					print , "*** WARNING *** DEFAULT_ROWS ^= DEFAULT_COLS FOR SQUARE MATRIX" thisname,
					        "                WITH TYPE =" thismtype,
							"                DEFAULT_COLS SET TO DEFAULT_ROWS =" thisrow;
					default_cols[i] = default_rows[i];
			end;
		end;
	end;
*print "setup_default_matrices";
*print default_mnames default_mtype default_rows default_cols must_be_present;

final:
finish;

start read_default_matrices (aborttest) 
		GLOBAL (n_default_matrices, default_mnames, default_mtype, 
				default_rows, default_cols, must_be_present, error);
/* -----------------------------------------------------------------------
	READS IN A DEFAULT MODEL SPECIFIED BY THE USER
   ----------------------------------------------------------------------- */
	if aborttest = "YES" then goto final;
	use &default_matrices;
		read all var {matrix_name} into default_mnames;
		read all var {matrix_type} into default_mtype;
		read all var {default_rows} into default_rows;
		read all var {default_cols} into default_cols;
		read all var {must_be_present} into must_be_present;
	close &default_matrices;
	n_default_matrices = nrow(default_mnames);
final:
finish;

start input_matrix_definitions (aborttest)
	  GLOBAL (default_mnames, default_mtype, default_rows, default_cols, must_be_present,
			  mnames, mtype, nrows, ncols, mdefault, n_default_matrices, possible_mtypes,
              startnew, error);

	/* bug out if program aborted in an earlier phase */
	if aborttest = 'YES' then goto final;

	/* --- open model data set created from model definitions --- */
	use temp_modelcards;
		read all var {card} into cards;
	close temp_modelcards;
	call remove_blanks(cards);
	load current_model number_of_models model_position model_names;
	current_model = current_model + 1;
	if current_model > number_of_models then do;
		aborttest = "YES";
		return;
	end;
	store current_model;
	startcards = model_position[current_model,1];
	stopcards  = model_position[current_model,2];
	cards = cards[startcards:stopcards];
	/* change pseudo pseudo macro variables */
	load n_rel n_phenotypes n_covariates;
	nr = trim(left(char(n_rel)));
	np = trim(left(char(n_phenotypes)));
	twonp = 2*n_phenotypes;
	np2 = trim(left(char(twonp)));
	nc = trim(left(char(n_covariates)));
	ngok = 0;
	if upcase("&macro_name") = "SASPAIRS" | upcase("&macro_name") = "SASPAIRS_MEANS" then ngok=1;
	do i=1 to nrow(cards);
		card = cards[i];
		if index(card, '&') > 0 then do;
			* --- change to upper case;
			call change(card, '&n', '&N', 0);
			call change(card, '&Np', '&NP', 0);
			call change(card, '&Ng', '&NG', 0);
			call change(card, '&Nc', '&Nc', 0);
			* --- substitute numbers;
			call change(card, '&NP2', np2, 0);
			call change(card, '&NP', np, 0);
			call change(card, '&NC', nc, 0);
			if ngok=1 then call change(card, '&NG', nr, 0);
		end;
		cards[i] = card;
	end;
	/* create a temporary data set from current cards to make it easier for
		the mx definitions and the iml definitions */
	cn = "card";
	create temp_thismodel from cards [colname=cn];
		append from cards;
	close temp_thismodel;

	/* get the name of the model and the label for output */
	thismodel_name = model_names[current_model];
	model_output_label = concat("Model Number ", trim(left(char(current_model))), ": ", thismodel_name);
	store model_output_label;
	mattrib model_output_label label = '' rowname='' colname='';

	if "&SPPrint_EchoCards" = "YES" then do;
		print '---------------------------------------------------------------------',
		      "Matrix Definitions in Model Data Set: &model_data_set",
			  model_output_label,
		      '---------------------------------------------------------------------';
		mattrib cards label='' rowname='' colname='';
		print , cards;
	end;

	/* --- get the matrix definitions --- */
	call delimit ("BEGIN MATRICES", "END MATRICES", cards, aborttest);
	if aborttest = "YES" then return;

	if "&SPPrint_MatDefSum" = "YES" then
		print '---------------------------------------------------------------------',
		      "Parsing Matrix Definitions for",
			  model_output_label,
		      '---------------------------------------------------------------------';

	/* --- check for a SAME statement --- */
	phrase = upcase(trim(left(cards[1])));
	if phrase = "SAME" & "&model_matrices_stored" ^= "1" then do;
		print , "*** ERROR *** Same COMMAND USED BUT NO MODEL MATRICES STORED.";
		aborttest = "YES";
		return;
	end;
	else if phrase = "SAME" then do;
		print , "NOTE: THE MATRICES IN THE PREVIOUS MODEL WILL BE USED.";  
		load mnames mtype nrows ncols mdefault;
		/* --- put a dummy in the first row --- */
		mnames = " " // mnames;
		mtype = " " // mtype;
		nrows = 0 // nrows;
		ncols = 0 // ncols;
		mdefault = 0 // mdefault;
		if nrow(cards) = 1 then do;
			startnew = 1;
			return;
		end;
		startnew = nrow(mnames);
		cards = cards[2:nrow(cards)];
	end;
	else do;
		startnew = 0;
		mnames = " "; 
		mtype = " "; 
		nrows = 0;
		ncols = 0;
		mdefault = 0;
	end;

	/* --- parse the cards --- */
	use spimlsrc.reserved_matrix_names;
		read all var {rsvd_mname} into reserved_names;
		reserved_names = upcase(trim(left(reserved_names)));
	close spimlsrc.reserved_matrix_names;
	do i=1 to nrow(cards);
		test = parse_matrix_command (cards[i], reserved_names);
	end;
	if error > 0 then aborttest = 'YES';

final:
finish;

start construct_model_matrices (aborttest)
	  GLOBAL (mnames, mtype, default_rows, default_cols, must_be_present,
	  		  found, nrows, ncols, mdefault, n_default_matrices, possible_mtypes,
			  index_x, free, parm_value, can_change, equality_constraints, error);

	/* bug out if program aborted in an earlier phase */
	if aborttest = 'YES' then goto final;

	/* add obligatory matrices */
	call obligatory_matrices (default_mnames, default_mtype, default_rows, default_cols,
				n_default_matrices, must_be_present, mnames, mtype, nrow, ncols, mdefault);

	/* eliminate the first row */
	n = nrow(mnames);
	mnames = mnames[2:n];
	mtype = mtype[2:n];
	nrows = nrows[2:n];
	ncols = ncols[2:n];
	mdefault = mdefault[2:n];

	/* create macro variables global_arg */
	call create_global_arg (mnames, added_matrices);

	/* -------------------------------------------------------------------------
	   index_x gives the start and the stop values of a parameter matrix in the
	   full parameter vector X
       ------------------------------------------------------------------------- */
	call setup_index_x (nrows, ncols, index_x);

	if "&SPPrint_MatDefSum" = "YES" then do;
		print , 'Matrix Definitions parsed without error.';
		/* print matrix definitions */
		mattrib mnames    label='Matrix';
		mattrib mtype     label='Type';
		mattrib mdefault  label='Default?';
		mattrib nrows     label='N_Rows';
		mattrib ncols     label='N_Cols';
		mattrib index_x colname = {'XStart' ' XStop'} label = '';
		load model_output_label;
		mattrib model_output_label label='' rowname='' colname='';
		print   '---------------------------------------------------------------------',
		        "Matrix Definitions for",
			    model_output_label,
		        '---------------------------------------------------------------------';
		print , mnames mdefault mtype nrows ncols index_x;
	end;

/* ---------------------------------------------------------------------------------
	setup vectors free, parm_value and can_change along with matrix
	equality constraints
   --------------------------------------------------------------------------------- */
	call setup_initial_parameter_vector (mtype, nrows, ncols, index_x, free,
						parm_value, can_change, equality_constraints);
/* needed only for debugging */
/*
pnum = 0*free;
matlab = j(nrow(free), 1, mnames[1]);
mt = j(nrow(free), 1, 'X');
row = 0*free;
col=0*free;
n=0;
do matrix = 1 to nrow(mnames);
	do i=1 to nrows[matrix];
		 do j = 1 to ncols[matrix];
			n = n + 1;
			pnum[n] = n;
			matlab[n] = mnames[matrix];
			mt[n] = mtype[matrix];
			row[n] = i;
			col[n] = j;
		end;
	end;
end;
print pnum matlab mt row col free can_change parm_value;
print equality_constraints;
*/

	/* store matrices for the next call to iml */
	store mnames mtype nrows ncols mdefault index_x free parm_value 
		  can_change equality_constraints;
	call symput ("model_matrices_stored", "1");
final:
finish;

start parse_matrix_command (card, reserved_names)
		GLOBAL (mnames, found, mtype, nrows, ncols, 
				default_mnames, default_mtype, default_rows, default_cols,
				n_default_matrices, mdefault, possible_mtypes, error);

*print "parse_matrix_command";
*print mnames mtype default_rows default_cols found nrows ncols;

	/* read in the command */
	string = card;
	mattrib string label='' rowname='' colname='';
	if "&SPPrint_MatDefSum" = "YES" then print , string;

	/* get the matrix name */
	word = first_word(string, 1);
	/* test if the first chatacter is a letter */
	test = upcase(substr(word,1,1));
	if (test < 'A' | test > 'Z') & (test ^= '_') then do;
		print , '*** ERROR *** FIRST CHARACTER OF MATRIX NAME IS NOT A LETTER OR UNDERSCORE.';
		error = error + 1;
		return (0);
	end;

	/* check to see ithe matrix has alread been defined */
	test = get_matrix_number (word, mnames, 1, nrow(mnames));
	if test ^= 0 then do;
		print , '*** ERROR *** MATRIX HAS ALREADY BEEN DEFINED.';
		error = error + 1;
		return (0);
	end;

	/* is this a reserved matrix name? */
	count=1;
	thisname = upcase(word);
	do until (thisname < reserved_names[count] | count > nrow(reserved_names));
		if thisname = reserved_names[count] then do;
			mattrib word label='' rowname='' colname='';
			print , "*** ERROR ***" word "IS A RESERVED MATRIX NAME.";
			error = error + 1;
			return (0);
		end;
		count = count + 1;
	end;

	/* check if this is a default matrix */
	test = get_matrix_number (word, default_mnames, 1, n_default_matrices);
	if test = 0 then
		test2 = add_a_new_matrix (string, word); /* add a new matrix */
	else
		test2 = default_matrix_found (string, test); /*matrix is a default matrix */
	return (test2);
finish;

start add_a_new_matrix (string, word)
			GLOBAL (mnames, mtype, nrows, ncols, mdefault, possible_mtypes, 
					mtypein, rowsin, colsin, error);
/* ---------------------------------------------------------------------------------
	PARAMETER MATRIX IS A NEW MATRIX
   --------------------------------------------------------------------------------- */

	/* add to the size of the vectors */
	mnames = mnames // word;
	mtype = mtype // ' ';
	value = 0;
	nrows = nrows // value;
	ncols = ncols // value;
	mdefault = mdefault // 0;
	nmats = nrow(mnames);

	test = get_type_rows_cols (string);
	if test=0 then do;
		error=error+1;
		return (0);
	end;
*print "add_a_new_matrix" mtypein rowsin colsin;

	/* --- check if matrix type is legit --- */
	if mtypein = ' ' then do;
		print , "*** ERROR *** MATRIX TYPE MISSING.";
		error=error+1;
		return(0);
	end;
	test = parse_matrix_type(mtypein, possible_mtypes);
	if test=0 then do;
		print , "*** ERROR *** ILLEGAL MATRIX TYPE.";
		error=error+1;
		return(0);
	end;
	mtype[nmats] = mtypein;

	/* --- do rows and columns --- */
	if mtypein="U" then do;
		if rowsin=0 | colsin=0 then do;
			print , "*** ERROR *** NUMBER OF ROWS OR COLUMNS MISSING FOR A U MATRIX.";
			error=error+1;
			return (0);
		end;
		else do;
			nrows[nmats] = rowsin;
			ncols[nmats] = colsin;
			return (1);
		end;
	end;
	else if mtypein = "V" then do;
		if rowsin = 0 then do;
			print , "*** ERROR *** NUMBER OF ROWS MISSING FOR A VECTOR";
			error=error+1;
			return (0);
		end;
		if colsin = 0 then colsin = 1;
		if rowsin > 1 & colsin > 1 then do;
			print , "*** ERROR *** ROW > 1 AND COL > 1 FOR A VECTOR.";
			error = error + 1;
			return (0);
		end;
		nrows[nmats] = rowsin;
		ncols[nmats] = colsin;
		return (1);
	end;
	else do;
		if rowsin=0 then do;
			print , "*** ERROR *** NUMBER OF ROWS MISSING.";
			error=error+1;
			return (0);
		end;
		if colsin=0 then colsin=rowsin;
		if rowsin ^= colsin then do;
			print , "*** ERROR *** NUMBER OF ROWS NE NUMBER OF COLUMNS FOR A SQUARE MATRIX.";
			error=error+1;
			return (0);
		end;
		nrows[nmats] = rowsin;
		ncols[nmats] = colsin;
		return (1);
	end;
finish;


start default_matrix_found (string, matrix)
			GLOBAL(mnames, mtype, found, nrows, ncols, mdefault,
					default_mnames, default_mtype, default_rows, default_cols,
					possible_mtypes, mtypein, rowsin, colsin, error);
/* ---------------------------------------------------------------------------------
	PARAMETER MATRIX IS A DEFAULT MATRIX
   --------------------------------------------------------------------------------- */

	/* --- if no arguments, then set to default values and return --- */
	if string= ' ' & default_rows[matrix] ^= 0 & default_cols[matrix] ^= 0 then do;
		if default_mtype[matrix] = "?" then do;
			print , "*** ERROR *** MATRIX TYPE NOT SPECIFIED.";
			error = error + 1;
			return (0);
		end;
		else do;
			mnames = mnames // default_mnames[matrix];
			mtype = mtype // default_mtype[matrix];
			nrows = nrows // default_rows[matrix];
			ncols = ncols // default_cols[matrix];
			mdefault = mdefault // 1;
			return (1);
		end;
	end;

	/* get the arguments from string */
	test = get_type_rows_cols (string);
	if test=0 then do;
		error=error+1;
		return (0);
	end;

/* ---------------------------------------------------------------------------------
	THIS SECTION FOR THE MATRIX TYPE
   --------------------------------------------------------------------------------- */
	if default_mtype[matrix] = "?" then do;
		if mtypein = ' ' then do;
			print , "*** ERROR *** MATRIX TYPE NOT SPECIFIED.";
			error = error + 1;
			return (0);
		end;
		else do;
			test = parse_matrix_type (mtypein, possible_mtypes);
			if test = 0 then do;
				print , "*** ERROR *** ILLEGAL MATRIX TYPE";
				error = error + 1;
				return (0);
			end; 
		end;
	end;
	else if mtypein = ' ' then
		mtypein = default_mtype[matrix];
	else do;
		/* --- check if it differs from the default type --- */
		if mtypein ^= default_mtype[matrix] then do;
			print , '*** WARNING *** INPUT MATRIX TYPE DIFFERS FROM DEFAULT',
		          , '                MATRIX TYPE. INPUT MATRIX TYPE IGNORED.';
			mtypein = default_mtype[matrix];
		end;
	end;

/* ---------------------------------------------------------------------------------
	THIS SECTION FOR SETTING ROWS AND COLUMNS
   --------------------------------------------------------------------------------- */
	test = setup_rows_and_cols (mtypein, default_rows[matrix], default_cols[matrix],
			rowsin, colsin);
*print "after setup_rows_and_cols" mtypein rowsin colsin;
	if test=0 then do;
		error = error + 1;
		return (0);
	end;

	/* add the matrix */
	mnames = mnames // default_mnames[matrix];
	mtype = mtype // mtypein;
	nrows = nrows // rowsin;
	ncols = ncols // colsin;
	mdefault = mdefault // 1;
*print mnames mtype nrows ncols mdefault;
	return (1);
finish;

start get_type_rows_cols(string) GLOBAL (mtypein, rowsin, colsin);
/* ---------------------------------------------------------------------------------
	READ IN AND PARSE MATRIX TYPE AND THE NUMBER OF ROWS AND COLUMNS
   --------------------------------------------------------------------------------- */

	/* test if blank */
	if string = " " then do;
		mtypein = " ";
		rowsin = 0;
		colsin = 0;
		return (1);
	end;

	mtypein = upcase(first_word(string, 1));
	value=0;
	test = is_this_a_number(mtypein, 0, 0, value);
	if test = 0 then do;
		/* --- first argument is not a positive integer, so interpret it as a matrix type */
		rowsin = first_word(string, 1);
		if rowsin = ' ' then do;
			rowsin=0;
			colsin=0;
			return (1);
		end;
		else do;
			test2 = is_this_a_number(rowsin, 0, 0, value);
			if test2 = 0 then do;
				print , "*** ERROR *** ILLEGAL VALUE FOR NUMBER OF ROWS";
				return (0);
			end;
			else rowsin = value;
			colsin = first_word(string, 1);
			if colsin = ' ' then do;
				colsin = 0;
				return (1);
			end;
			else do;
				test2 = is_this_a_number(colsin, 0, 0, value);
				if test2 = 0 then do;
					print , "*** ERROR *** ILLEGAL VALUE FOR NUMBER OF COLUMNS";
					return (0);
				end;
				else colsin = value;
				return (1);
			end;
		end;
	end;
	else do;
		/* --- first argument is an integer, so interpret it as the number of rows --- */
		mtypein = ' ';
		rowsin = value;
		colsin = first_word(string, 1);
		if colsin = ' ' then do;
			colsin = 0;
			return (1);
		end;
		else do;
			test2 = is_this_a_number(colsin, 0, 0, value);
			if test2 = 0 then do;
				print , "*** ERROR *** ILLEGAL VALUE FOR NUMBER OF COLUMNS";
				return (0);
			end;
			else colsin = value;
			return (1);
		end;
	end;
finish;

start setup_rows_and_cols (mtype, default_rows, default_cols, rowsin, colsin)
		GLOBAL (error);

	/* check for the most likely case first = all defaults */
	if default_rows > 0 & default_cols > 0 & rowsin=0 & colsin=0 then do;
		rowsin = default_rows;
		colsin = default_cols;
		return (1);
	end;

	/* if a vector and number of columns is not specified, set it to 1 */
	if mtype="V" & colsin=0 then
		colsin=1;

	/* fix a missing colsin if the matrix is square */
	if (mtype = "C" | mtype = "S" | mtype = "L" | mtype = "D")
		& rowsin > 0 & colsin = 0 then
			colsin = rowsin;

	/* if a default row is present and no columns have been specified,
		then interpret the rowsin as the colsin value and fix the rows to the
		default rows */
	if (default_rows > 0) & (colsin=0) then do;
		colsin = rowsin;
		rowsin = default_rows;
	end;

	/* --- create a temporary variable for default_cols so it can be changed --- */
	tempcol = default_cols;

	/* temporary fix for default columns for square matrices */
	if (default_rows > 0) & (mtype ^= "U" & mtype ^= "V") & (default_cols=0) then
		tempcol = default_rows;

	/* default vectors to column vectors */
	if mtype = "V" & default_cols = 0 & colsin = 0 then
		tempcol = 1;
		
	/* if no rows or cols were specified then fix to default values */
	if (rowsin=0) then rowsin = default_rows;
	if (colsin=0) then colsin = tempcol;

	/* warnings */
	if (default_rows > 0) & (rowsin ^= default_rows) then do;
		print , "*** WARNING *** INPUT NUMBER OF ROWS DIFFERS FROM DEFAULT VALUES",
			    "                DEFAULT VALUES USED.";
		rowsin = default_rows;
	end;
	if (tempcol > 0) & (colsin ^= tempcol) then do;
		print , "*** WARNING *** INPUT NUMBER OF COLUMNS DIFFERS FROM DEFAULT VALUES",
			    "                DEFAULT VALUES USED.";
		colsin = tempcol;
	end;

	/* error check */
	if (mtype="U") & (rowsin=0 | colsin=0) then do;
		print , "*** ERROR *** NUMBER OF ROWS OR COLUMNS MISSING FOR A U MATRIX.";
		return (0);
	end;
	else if (default_rows = 0) & (rowsin=0) then do;
		print , "*** ERROR *** NUMBER OF ROWS MISSING.";
		return (0);
	end;
	else if (tempcol = 0) & (colsin=0) then do;
		print , "*** ERROR *** NUMBER OF COLUMNS MISSING.";
		return (0);
	end;
	else if (mtype="S" | mtype="C" | mtype="L") & (rowsin ^= colsin) then do;
		print , "*** ERROR *** NUMBER OF ROWS ^= NUMBER OF COLUMNS FOR A SQUARE MATRIX.";
		return(0);
	end;
	else if (mtype="V" & rowsin ^= 1 & colsin ^= 1) then do;
		print , "*** ERROR *** Dimensions do not agree with a vector.";
		return (0);
	end;
	return (1);
finish;


start obligatory_matrices (default_mnames, default_mtype, default_rows, default_cols,
				n_default_matrices, must_be_present, mnames, mtype, nrow, ncols, mdefault);
	/* bug out if none present */
	if max(must_be_present) = 0 then return;

	do matrix=1 to n_default_matrices;
		if must_be_present[matrix]=1 then do;
			found=0;
			thismatrix = upcase(default_mnames[matrix]);
			do i=1 to nrow(mnames);
				if upcase(mnames[i]) = thismatrix then found=1;
			end;
			if found = 0 then do;
				mnames = mnames // default_mnames[matrix];
				mtype = mtype // default_mtype[matrix];
				nrows = nrows // default_rows[matrix];
				ncols = ncols // default_cols[matrix];
				mdefault = mdefault // 1;
			end;
		end;
	end;
finish;

start create_global_arg (mnames, added_matrices);
/* --- create two macro variables for passing into function calculations
	global_arg1 = comma delimited list of matrices in the model
	global_arg2 = space deliminted list --- */
	global_arg1 = trim(left(mnames[1]));
	global_arg2 = global_arg1;
	do i=2 to nrow(mnames);
		global_arg1 = concat(global_arg1, ', ', trim(left(mnames[i])) );
	end;
	do i=2 to nrow(added_matrices);
		global_arg1 = concat(global_arg1, ', ', trim(left(added_matrices[i])) );
	end;
	global_arg2 = global_arg1;
	call change(global_arg2, ', ', ' ', 0);		
*print global_arg1 global_arg2;
	call symput ('global_arg1', global_arg1);
	call symput ('global_arg2', global_arg2);
finish;

start setup_index_x (nrows, ncols, index_x);
/* --- create the matrix index_x such that
		index_x[i,1] = starting value in vector x for the ith matrix
		index_x[i,2] = stopping value in vector x for the ith matrix
		where vector x is the full vector of parameters --- */
	n = nrow(nrows);
	index_x = j(n,2,0);
	count = 0;
	do i=1 to nrow(nrows);
		index_x[i,1] = count + 1;
		count = count + nrows[i]*ncols[i];
		index_x[i,2] = count;
	end;
finish;

start setup_initial_parameter_vector (mtype, nrows, ncols, index_x, free,
						parm_value, can_change, equality_constraints)
                        GLOBAL (startnew);
/* --- this initializes and constructs vectors free, parm_value, and
		can_change and matrix equality constraints 
		free: free[i] = 1 ==> parameter is free
			  free[i] = 0 ==> parameter is fixed
		parm_value: initial estimates (default = 0)
		can_change: can_change[i] = 1 ==> parameter allowed to be changed
                                          in subsequent statements
		            can_change[i] = 0 ==> parameter cannot change
		equality_constraints: equality_constraint[i,1] equality_constraint[i,2]
				===> parameter [i,1] = parameter [i,2] --- */

	if startnew = 0 then do; /* a SAME command was not found */
		n_parameters = t(nrows) * ncols;
		parm_value = j(n_parameters,1, 0);  /* default start values = 0 */
		free = j(n_parameters, 1, 1);
		can_change = free;
	end;
	else do; /* a SAME command was found */
		load parm_value free can_change;
		if startnew > 1 then do; /* new matrices have been added */
			n = nrow(mtype);
			nnew = t(nrows[startnew:n]) * ncols[startnew:n];
			print , "ADDING NEW MATRICES:" , startnew n nnew;
			temp = j(nnew, 1, 0);
			parm_value = parm_value // temp;
			temp = 1 + temp;
			free = free // temp;
			can_change = can_change // temp;
		end;
	end;

	/* set up the initial equality and fixed constraints implied by
		symmetric, correlation, and lower diagonal matrices
		NOTE WELL: the equality constraints imposed here are only those
				   that depend on the matrix type (e.g., diagonals of\
				   a correlation matrix = 1 */
	equality_constraints = j(1,2,0); /* this row will be ignored in Mx commands */
	count = 0;
*print mtype nrows ncols index_x;
	do i=1 to nrow(mtype);
*print , "initialconstraints matrix type newmatrix rows cols=" i (mtype[i]) (nrows[i]) (ncols[i]);
		call initial_constraints (count, mtype[i], index_x[i,1], nrows[i],
									ncols[i], free, can_change, parm_value,
									equality_constraints);
	end;
*num = 1:nrow(free);
*num = t(num);
*print num free parm_value can_change;
*print equality_constraints;
finish;

start initial_constraints (n, matrixtype, start, nrows, ncols, free,
							can_change, parm_value, equality_constraints);
/* sets up initial constraints from the type of matrix */

*print , "ini_cons:" matrixtype  n;
	/* bow out if no free parameters or matrix must be unconstrained */
	if matrixtype = 'U' | matrixtype = 'V' then do;
		n = n + nrows*ncols;
		return;
	end;

	temp = {0 0 };
	/* correlation and symmetrix matrices */
	if matrixtype = 'C' | matrixtype = 'S' then do;
		do row=1 to nrows;
			do col = 1 to ncols;
				n = n + 1;
				if matrixtype = 'C' & row = col then do; /* diagonals for R must be 1 */
					free[n] = 0;
					parm_value[n] = 1;
					can_change[n] = 0;
				end;
				else if row > col then do;
					upper = start + ncols*(col - 1) + row - 1; /*location in upper triangle */
					free[n] = 0;
					can_change[n] = 0;
					temp[1] = n;
					temp[2] = upper;
					equality_constraints = equality_constraints // temp;
				end;
			end;
		end;
	end;

	/* lower diagonal matrix */
	else if matrixtype = 'L' then do;
		do row = 1 to nrows;
			do col = 1 to ncols;
				n = n + 1;
				if row < col then do;
					can_change[n] = 0;
					free[n] = 0;
				end;
			end;
		end;
	end;

	/* diagonal matrix */
	else if matrixtype = 'D' then do;
		do row = 1 to nrows;
			do col = 1 to ncols;
				n = n + 1;
				if row ^= col then do;
					can_change[n] = 0;
					free[n] = 0;
				end;
			end;
		end;
	end;
		
finish;

/* ---------------------------------------------------------------------
   MAIN IML CODE
   --------------------------------------------------------------------- */

	/* --- check if abort code --- */
	do; /* stupid do condition */
		aborttest = upcase(trim(left("&abort_job")));
		if aborttest = 'YES' then 
			print , '*** CALL TO READING IN MATRIX DEFINITIONS HAS BEEN ABORTED',
		     	    '    BECAUSE OF PREVIOUS ERRORS.';
		if aborttest = 'YES' then goto final;

/* ---------------------------------------------------------------------
   MATRICES
   --------------------------------------------------------------------- */
		/* --- allowable matrix types --- */
		possible_mtypes = {'S', 'U', 'C', 'L', 'D', 'V'};
		/* --- error indicator --- */
		error = 0;

/* ---------------------------------------------------------------------
   SETUP A DEFAULT MODEL, IF PRESENT
   --------------------------------------------------------------------- */
		call setup_default_matrices (aborttest);
		if aborttest = 'YES' then goto final;

/* ---------------------------------------------------------------------
   INPUT MATRIX DEFINITIONS
   --------------------------------------------------------------------- */
		call input_matrix_definitions (aborttest);
		if aborttest = 'YES' then goto final;

/* ---------------------------------------------------------------------
   CONSTRUCT THE MODEL
   --------------------------------------------------------------------- */
		call construct_model_matrices (aborttest);
		if aborttest = 'YES' then goto final;
		n = char(nrow(mnames));
		n = trim(left(n)); 
		call symput('n_matrices', n);

	final:
		if aborttest="YES" then call symput("abort_job", "YES");
	end;
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: MATRIX DEFINITIONS PART 1 DONE. ABORT_JOB = &abort_job;
/* ---------------------------------------------------------------------
   CREATE GLOBAL MACRO NAMES
   --------------------------------------------------------------------- */
%saspairs_matrixn;
proc iml;
%include "&utilities";
start macro_names (mnames, mdefault);
/* --- this module creates two sets of macro variables:
	(1) the single variable n_matrices which gives the number of parameter matrices
		in the model
	(2) a series of macro variables of the form matrixNN, the values of which are
		the names of the matrices in the model --- */
	zero = "0";
	one = "1";
	do i = 1 to nrow(mnames);
		chari = trim(left(char(i)));
		macro_var = concat('matrix', chari);
		call symput(macro_var, mnames[i]);
		macro_var = concat('mdefault', chari);
		arg = zero;
		if mdefault[i] = 1 then arg = one;
		call symput(macro_var, arg);
	end;
finish;

	aborttest = upcase(trim(left("&abort_job")));
	if aborttest ^= "YES" then do;
		load mnames mdefault;
		call macro_names (mnames, mdefault);
	end;
quit;
%let thissyserr = &syserr;
%saspairs_syserr(&thissyserr);
%put NOTE: MATRIX DEFINITIONS FINISHED. ABORT_JOB = &abort_job ;
