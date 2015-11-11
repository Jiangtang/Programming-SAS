%macro saspairs_cov_varnames (varnames);
%* ----------------------------------------------------------------------
    PURPOSE: 
        Creates a list of variables in the form 
             R1_var1 R1_var2 ... R1_varN R2_var1 R2_var2 ... R2_varN
        to be used as variable names for a covariance data set for
        relative pairs

    USAGE:
        %let cov_names = %cov_variable_names (&varnames)

	NOTES:
        1. The elements of &varnames provide the suffices for R1_ and R2_
		2. hyphens in &varname will give unusable results
   ----------------------------------------------------------------------;
	%let nvar = %saspairs_nwords(&varnames);
	%let cn=;
	%let prefix=R1_;
	%do i = 1 %to &nvar;
		%let word = %scan(&varnames, &i, %str( ));
		%let cn = &cn &prefix&word;
	%end;
	%let prefix=R2_;
	%do i = 1 %to &nvar;
		%let word = %scan(&varnames, &i, %str( ));
		%let cn = &cn &prefix&word;
	%end;
	&cn
%mend saspairs_cov_varnames;
