%macro saspairs_jiggle (delta);
	%* ----- jiggles the existing vector of estimates and refits the model;
	%if &abort_job = YES %then %do;
		%put ERROR: saspairs_jiggle CANNOT BE EXECUTED WHEN THE JOB WAS ABORTED.;
		%goto final;  %* bug out if error;
	%end;

	proc iml;
		load xres;
		x0 = t(xres);
		rn = x0;
		call rannor(0, rn);
		s = &delta * abs(x0);
		x0 = x0 + s # rn;
		store x0;
	quit;
	%saspairs_minimization_call;

%final:
%mend saspairs_jiggle;

