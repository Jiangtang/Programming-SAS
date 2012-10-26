%macro ___path;
	%global dir;

	%let file_name = %sysget(sas_execfilename);
	%let file_path = %sysget(sas_execfilepath);

	%let dir  = %substr(&file_path,1,%eval(%length(&file_path)
				   - %length(&file_name)-1));
%mend ___path;
%___path

libname func "&dir";
options cmplib=func.func;


/*study_day: study day for clinical trial
test study_day:

data _null_;
   RFSTDTC   = '14Mar2009'd;
   DMDTC     = '15Mar2009'd;
   study_day = study_day(RFSTDTC, DMDTC);
   put study_day=;
run;
*/

proc fcmp outlib=func.func.trial;
   function study_day(intervention_date, event_date) label = "Study Day";
      n = event_date - intervention_date;
      if n >= 0 then n = n + 1;
      return (n);
   endsub;
run;

