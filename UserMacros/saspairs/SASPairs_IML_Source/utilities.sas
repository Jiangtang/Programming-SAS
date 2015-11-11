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

start get_matrix_number (word, mnames, start, stop);
	temp = upcase(word);
	do i = start to stop;
		if temp = upcase(trim(left(mnames[i]))) then return (i);
	end;
	return (0);
finish;

start is_this_a_number (word, ignoresign, ignoredecimal, value);
/* --- check whether this character string is a number */
	save = trim(left(word));
	temp = save;
	dosave = 0;
	value = 0;

	/* check if sign and decimals should be ignored */
	if ignoresign ^= 0 then do;
		dosave = 1;
		if substr(temp,1,1) = '-' then temp=substr(temp,2);
	end;
	if ignoredecimal ^= 0 then do;
		dosave=1;
		call change (temp, '.', '', 1);
	end;
	
	ok = 0;
	n = length(temp);
	do i=1 to n;
		c = substr(temp,i,1);
		if (c >= '0' & c <= '9') then ok=ok+1;
	end;
	if ok = n then do;
		if dosave = 0 then value = num(temp);
		else value = num(save);
		return (1);
	end;
	else return (0);
finish;

start parse_matrix_type (word, possible_mtypes);
/* find the matrix type for this matrix */
	temp = upcase(substr(word,1,1));
	do i=1 to nrow(possible_mtypes);
		if temp = possible_mtypes[i] then return (i);
	end;
	return (0);
finish;

start get_matrix_name (word, mnames);
/* --- find out if a word is a matrix name --- */
	temp = upcase(trim(left(word)));
	do i=1 to nrow(mnames);
		if temp = upcase(trim(left(mnames[i]))) then return (i);
	end;
	return (0);
finish;

start get_parameter_number (row, col, nrows, ncols, start);
	n = start + ncols*(row - 1) + col - 1;
	return (n);
finish;

start remove_blanks (cards);
/* removes blank cards for better printing */
	n = 0;
	do i=1 to nrow(cards);
		if cards[i] ^= ' ' then do;
			n=n+1;
			cards[n] = cards[i];
		end;
	end;
	if n > 0 then cards = cards[1:n];
finish;

start delimit (start_phrase, end_phrase, cards, aborttest);
	nsp = length(start_phrase);
	nep = length(end_phrase);
	start_card = 0;
	end_card = 0;
	count = 0;
	ncards = nrow(cards);
	do while (count < ncards);
		count = count + 1;
		phrase = upcase(trim(left(cards[count])));
		if length(phrase) >= nsp then do;
			if substr(phrase, 1, nsp) = start_phrase then do;
				start_card = count;
				count = ncards;
			end;
		end;
	end;
	if start_card = 0 then do;
		print , "*** ERROR ***" start_phrase "STATEMENT NOT FOUND.";
		aborttest = "YES";
		return;
	end;
	count = start_card;
	do while (count < ncards);
		count = count + 1;
		phrase = upcase(trim(left(cards[count])));
		if length(phrase) >= nep then do;
			if substr(phrase, 1, nep) = end_phrase then do;
				end_card = count;
				count = ncards;
			end;
		end;
	end;
	if end_card = 0 then do;
		print , "*** ERROR ***" end_phrase "STATEMENT NOT FOUND.";
		aborttest = "YES";
		return;
	end;
	else if end_card = start_card + 1 then do;
		print , "*** ERROR *** NO COMMANDS BETWEEN" start_phrase "AND" end_phrase;
		aborttest = "YES";
		return;
	end;
	cards = cards[start_card+1 : end_card-1];
finish;
