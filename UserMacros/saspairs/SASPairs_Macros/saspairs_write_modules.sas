%macro saspairs_write_modules (same_iml);
	%* write the function modules -- NOTE WELL: cannot do this in iml because
       iml will not accept file names longer than 64 characters;

	%put NOTE: saspairs_write_modules STARTING;
	%if &abort_job = YES %then %goto final; %* bug out on error;

	%* always write out the put_x_file;
	data _null_;
		set temp_put_x;
		file "&put_x_file";
		put Card $char80.;
	run;
	%let thissyserr = &syserr;
	%saspairs_syserr(&thissyserr);
	%if &abort_job = YES %then %goto final; %* bug out on error;

	%if &same_iml = NO %then %do;
		%* write module predicted_stats;
		data _null_;
			set temp_predicted;
			file "&predicted_stats";
			put Card $char80.;
		run;
		%let thissyserr = &syserr;
		%saspairs_syserr(&thissyserr);
		%if &abort_job = YES %then %goto final; %* bug out on error;

		%* get the function here;
		%let temp = %str(.sas);
		%let function_file = &saspairs_source_dir&function&temp;
		data temp_function_file;
			length card $96.;
			infile "&function_file" length=reclen;
			input @;
			len = reclen;
			input @1 card $varying96. len;
		run;
		%let thissyserr = &syserr;
		%saspairs_syserr(&thissyserr);
		%if &abort_job = YES %then %goto final; %* bug out on error;

		%* write module test_users_module;
		data _null_;
			length Card $96.;
			set spimlsrc.testuser1 temp_function_file spimlsrc.testuser2
			    temp_testuser spimlsrc.testuser3;
			file "&test_users_module";
			put Card $char96. ;
		run;
		%let thissyserr = &syserr;
		%saspairs_syserr(&thissyserr);
	%end;

%final:
	%if &abort_job ^= YES %then %let iml_modules_written=1;
	%put NOTE: saspairs_write_modules FINISHED. abort_job=&abort_job;
%mend saspairs_write_modules; 
