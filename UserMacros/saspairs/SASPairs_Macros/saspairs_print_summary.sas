%macro saspairs_print_summary;
	%if &abort_job = YES %then %goto final;
	%put NOTE: saspairs_print_summary STARTING.;

	%if &macro_name = SASPAIRS | &macro_name = SASPAIRS_MEANS %then
		%let temp = print_summary_covmats.sas;
	%else
		%let temp = print_summary_likelihood.sas;
	%let includefile = &saspairs_source_dir&temp;
	%include "&includefile";
	%let thissyserr = &syserr;
	%saspairs_syserr(&thissyserr);

%final:
	%put NOTE: saspairs_print_summary FINISHED. abort_job=&abort_job;
%mend saspairs_print_summary;
