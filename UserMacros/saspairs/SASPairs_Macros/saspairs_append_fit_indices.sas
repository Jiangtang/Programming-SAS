%macro saspairs_append_fit_indices;
	%if &abort_job = YES %then %goto final;
	%put NOTE: saspairs_append_fit_indices STARTING;

	%let temp = append_fit_indices.sas;
	%let temp = &saspairs_source_dir&temp;
	%include "&temp";
	%let thissyserr = &syserr;
	%saspairs_syserr(&thissyserr);

%final: 
	%put NOTE: saspairs_append_fit_indices FINISHED. abort_job=&abort_job;
%mend saspairs_append_fit_indices;
