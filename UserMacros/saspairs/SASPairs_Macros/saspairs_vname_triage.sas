%macro saspairs_vname_triage(vn, dsid);
	%let vnumbr = %sysfunc(varnum(&dsid, &vn));
	%if &vnumbr = . %then %let vnumbr = 0;
	&vnumbr
%mend saspairs_vname_triage;
