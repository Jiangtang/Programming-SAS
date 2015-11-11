%macro saspairs_matrixn;
	%* assign global statis to matrixN macro names;
	%let matrix = matrix;
	%let mdefault = mdefault;
	%do i = 1 %to &n_matrices;
		%global &matrix&i &mdefault&i ;
	%end;
%mend saspairs_matrixn;
