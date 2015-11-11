%macro saspairs_vlist(root, n);
	%* generate a list from ROOT1 through ROOT&n;
	%let vlist =;
	%do i = 1 %to &n;
		%let vlist = &vlist &root&i;
	%end;
	&vlist
%mend;
