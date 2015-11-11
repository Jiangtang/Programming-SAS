/* ---------------------------------------------------------------------------
   IML code to print results after refitting a model
   --------------------------------------------------------------------------- */
%put NOTE: PRINT_REFIT STARTED.;
PROC IML;
	LOAD _ALL_;
	* --- check dimensioning;
	if nrow(X0_Old) < ncol(X0_Old) then X0_Old = t(X0_Old);
	if nrow(X0) < ncol(X0) then X0 = t(X0);
	if nrow(Xres_Old) < ncol(Xres_Old) then Xres_Old = t(Xres_Old);
	if nrow(XRes) < ncol(Xres) then Xres = t(Xres);
	Diff_0 = X0_Old - X0;
	Diff_Res = Xres_Old - XRes;
	Norm_0 = t(Diff_0) * Diff_0;
	Norm_Res = t(Diff_Res) * Diff_Res;
	Diff_F = F_Old - F;

	MATTRIB Parm_label label='Parameter:';
	MATTRIB Diff_0 label='Diff(Start Vals):' [format=8.4];
	MATTRIB Diff_RES label='Diff(Final Vals):' [format=8.4];
	MATTRIB F_Old  label='';
	MATTRIB F      label='';
	MATTRIB Diff_f label='';
	PRINT , '--------------------------------------------------------------'
	       , 'Difference in Results after Refit'
	       , '--------------------------------------------------------------';
	PRINT , Parm_label Diff_0 [format=8.4] Diff_Res [format=8.4];
	PRINT
		, 'Function Value: Initial Solution =' F_Old [format=best15.]
		, 'Function Value: Current Solution =' F [format=best15.]
		, '                      Difference =' Diff_F [format=best15.];
QUIT;
%put NOTE: PRINT_REFIT ENDED.;
