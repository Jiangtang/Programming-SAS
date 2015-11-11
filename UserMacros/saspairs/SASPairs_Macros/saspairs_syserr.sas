%macro saspairs_syserr(thissyserr);
	%if &thissyserr ^= 0 %then %do;
		%let abort_job = YES;
		%put ERROR: ABORT_JOB SET TO YES BECAUSE SYSERR ^= 0 ON THIS STEP;
	%end;
%mend saspairs_syserr;
