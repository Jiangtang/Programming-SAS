

%macro ___path;
	%global ___dir1;

	%let ___name0 = %sysget(sas_execfilename);

	%let ___dir0  = %sysget(sas_execfilepath);	

	%let ___dir1  = %substr(&___dir0,1,%eval(%length(&___dir0) 
				   - %length(&___name0)-1));			
 
%mend ___path;
%___path

libname func "&___dir1";
options cmplib=func.func;


/*study_day: study day for clinical trial */
proc fcmp outlib=func.func.trial;
   function study_day(intervention_date, event_date) label = "study day";
      n = event_date - intervention_date;
      if n >= 0 then n = n + 1;
      return (n);
   endsub;
run;

/*test study_day*/
data _null_;
   RFSTDTC = '14Mar2009'd;
   DMDTC   = '15Mar2009'd;
   sd      = study_day(RFSTDTC, DMDTC);
   put sd=;
run;

