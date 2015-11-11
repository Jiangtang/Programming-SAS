%macro saspairs_refit (number_of_refits);
	%* ----- takes an existing vector of estimates and refits the model;
	%if &abort_job = YES %then
		%put ERROR: saspairs_refit CANNOT BE EXECUTED WHEN THE JOB WAS ABORTED.;
	%else %do;
		%do refit_number = 1 %to &number_of_refits;
			proc iml;
				load xres;
				x0 = t(xres);
				store x0;
			quit;
			%saspairs_minimization_call;
			%if &abort_job = YES %then %goto final;
		%end;
	%end;
%final:
%mend saspairs_refit;
