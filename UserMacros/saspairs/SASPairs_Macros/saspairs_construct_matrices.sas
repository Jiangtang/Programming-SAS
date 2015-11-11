
%macro saspairs_construct_matrices (NMats, Mnames, Mrows, MCols);
%* --- sizes a matrix from a vector: used in SASPairs Projects;
	%local thisMat thisSize thisRow thisCol imlcmnd;
	%do i=1 %to &Nmats;
		%let thisMat = %scan(&Mnames, &i, ' ');
		%let thisRow = %scan(&MRows, &i, ' ');
		%let thisCol = %scan(&MCols, &i, ' ');
		%let thisSize = %eval(&thisRow * &thisCol);
		%let imlcmnd = %str(temp = value[&i, 1:&thisSize]; &thisMat=shape(temp, &thisRow, &thisCol););
%*put imlcmd = &imlcmnd;
		&imlcmnd
	%end;
%mend;
