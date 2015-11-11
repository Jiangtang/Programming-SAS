%macro saspairs_minimization_call;
	%* call the minimizer;	
	%put NOTE: SASPAIRS_MINIMIZATION_CALL STARTED.;
	%if &abort_job = YES %then %goto final;

	%let temp = call_to_minimizer.sas;
	%let temp = &saspairs_source_dir&temp;
	%include "&temp";
	%if &abort_job=YES %then %goto final;
	%let temp = results_after_minimizer.sas;
	%let temp = &saspairs_source_dir&temp;
	%include "&temp";
	%if &abort_job=YES %then %goto final;

	%* --- output from the minimization;
	%if &SPPrint_FinalParms = YES | &SPPrint_ParmMats = YES | &SPPrint_ObsPre = YES |
		&SPPrint_FitIndex = YES %then %do; 
		%let temp = print_optimization_results.sas;
		%let temp = &saspairs_source_dir&temp;
		%include "&temp";
	%end;

%final:
	%put NOTE: SASPAIRS_MINIMIZATION_CALL FINISHED. ABORT_JOB=&abort_job ;
%mend saspairs_minimization_call;
