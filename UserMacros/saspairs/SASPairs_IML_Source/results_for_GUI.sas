* ----------------------------------------------------------------
   Create the data sets for viewing in interactive SASPairs GUI;

%macro saspairs_matrix_ds_names;
%* --- put the contents of the matrices into matrix X;
	%let openp = (;
	%let closed = );
	%do i=1 %to &n_matrices;
		%let iml_line = %str(n=NRows[&i]*NCols[&i];);
		%let iml_line = &iml_line %str(x[&i,1:n] = shape&openp&&matrix&i, 1, n&closed;);
%*put &iml_line;
		&iml_line
	%end;
%mend;


* --- create the initial data for model title;
DATA _TMP_ModTitle;
	LENGTH ModN 3 Model $80;
	ModN=.;
RUN;

* --- create the initial data set for the summary statistics;
DATA _TMP_OptFit;
	LENGTH ModN RCode 3 Hess 3 NG0 NGq MaxG 8 Np 3 chi 8 df 3 p AIC CAIC SBC MMoC 8;
	FORMAT ModN RCode 6.0 Hess 3.0  NG0 NGq 6.0 MaxG Best8. Np 6.0 chi 8.3 df 6.0 p 5.4 AIC CAIC SBC 8.2 MMoC 8.3;
	LABEL
		Modn =	'Model'
		RCode=	'Return Code'
		Hess =  'Bad Hessian'
		NG0  =  'N(g = 0)'
		NGq  =  'N(|g| > .001)'
		MaxG =	'Max(g)'
		Np   =  'N Parm'
		chi  =	'Chi Square'
		df   =  'df'
		p    =  'p'
		AIC  =  'AIC'
		CAIC =	'CAIC'
		SBC  =	'SBC'
		MMoC =	'MMoC';
RUN;

* --- initial data for parameter values and labels;
DATA _TMP_Parameters;
	LENGTH ModN 3 Parameter $16 ParmValue Gradient Span SU20 8;
	FORMAT ModN 3.0 Parameter $16. ParmValue Span SU20 10.3 Gradient 8.5;
	LABEL
		ModN = 'Model'
		ParmValue = 'Value'
		SU20 = 'Span Units to 0';
RUN; 

* --- initial data for matrices;
DATA _TMP_Matrices;
	LENGTH ModN 3 Matrix $16 Type $1 NRows NCols 3;
	FORMAT Modn Nrows Ncols 6.0 Matrix $16. Type $1.;
	LABEL NRows='N(Rows)'
		  NCols='N(Cols)';
RUN;

proc iml;
	load;

	* --- make certain vectors are row vectors;
	if ncol(xres) > nrow(xres) then xres=t(xres);
	if ncol(_SP_g)    > nrow(_SP_g)    then _SP_g=t(_SP_g);
	if ncol(_SP_span) > nrow(_SP_span) then _SP_span=t(_SP_span);
	if ncol(_SP_su20) > nrow(_SP_su20) then _SP_su20=t(_SP_su20);

	* --- iml matrices to store for refit check;
	F_Old = F;
	if ncol(X0) > nrow(X0) then X0_Old = t(X0);
	else X0_Old = X0;
	Xres_Old = XRes;
	STORE F_Old X0_Old Xres_Old;

	* --- numeric variables for OptFit;
	modN=&current_ModN;
	cn = {'ModN' 'RCode' 'Hess' 'Ng0' 'Ngq' 'Maxg' 'Np' 'Chi' 'df' 'p' 'AIC' 'CAIC' 'SBC' 'MMoC'};
	sumstat = modN || Rcode || _SP_BadHess || _SP_Ng0 || _SP_Ngq || _SP_Maxg || Nrow(Xres) || f ||
			fdf[1] || fp[1] || fvalue[2] || fvalue[3] || fvalue[4] || fvalue[5];
*print sumstat [colname=cn];
	create _TMP_ThisSum from sumstat [colname=cn];
	append from sumstat;

	* --- title for OptFit;
	thisTitle=Model_Names[current_model];
	create _TMP_ThisTitle from thisTitle[colname='Model'];
	append from thisTitle;

	* --- parameter labels;
	temp = right(trim(Parm_Label));
	create _TMP_ThisParm from temp [colname='Parameter'];
	append from temp;

	* --- numeric results for parameter values;
	temp = j(nrow(xres), 1, modN);
	x = temp || xres || _SP_g || _SP_span || _SP_su20;
	cn = {'ModN' 'ParmValue' 'Gradient' 'Span' 'SU20'};
	create _TMP_PV from x [colname=cn];
	append from x;

	* --- Create the X matrix holding the matrix values;
	temp = nrows # ncols;
	Xmax = max(temp[1:nrow(temp)]);
	x=j(&n_matrices, Xmax, .);
	%saspairs_matrix_ds_names;

	* --- model number & rows and cols;
	temp = j(&n_matrices, 1, modN) || Nrows || Ncols;
	temp = temp || x;

	* --- variable names;
	cn = {'ModN' 'Nrows' 'Ncols'};
	do i=1 to Xmax;
		thisv = concat('Value', trim(left(char(i))) );
		cn = cn || thisv;
	end;

	* --- create the numeric data set;
	Create _TMP_MatNums from temp [colname=cn];
	append from temp;

	* ---- create the data set for the character variables;
	temp = right(mnames) || mtype;
	create _TMP_MatChar from temp [colname={'Matrix' 'Type'}];
	append from temp;

quit;


* --- OptFit statistics;
DATA _TMP_;
	MERGE _TMP_ThisTitle _TMP_ThisSum;
RUN;
DATA _TMP_OptFit;
	SET _TMP_OptFit _TMP_;
	LENGTH ModelType $8;
	ModelType = "&SPMODELTYPE";
	if ModN ^= .;
RUN;
*title data set _TMP_OptFit;
*proc print;
*run;

* ---- Final Parameter Values;
DATA _TMP_;
	MERGE _TMP_ThisParm _TMP_PV;
RUN;
DATA _TMP_Parameters;
	SET _TMP_Parameters _TMP_;
	if ModN ^= .;
RUN;
*title data set _TMP_Parameters;
*proc print;
*run;

* ---- Matrices;
DATA _TMP_;
	MERGE _TMP_MatChar _TMP_MatNums;
RUN;
DATA _TMP_Matrices;
	SET _TMP_Matrices _TMP_;
	if ModN ^= .;
RUN;
*title data set _TMP_Matrices;
*proc print;
*run;
