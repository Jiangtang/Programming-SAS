 /*Test for maximum level of embedding of SAS SQL queries.*/
 /*
 CDI: 376
 
 */
 data R;
	a=1;
 run;
 
 options mprint;
 
 %macro query;
	select 1 from R
 %mend;
 
 %macro subquery(__q);
	select 1 from (&__q)
 %mend;
 
 %macro subsubquery(__sq,__n);
 %do __i = 3 %to %eval(&__n - 1);
	%subquery(
 %end;
 
 &__sq
 
 %do __i = 3 %to %eval(&__n - 1);
    )
 %end;
 %mend;
 
 proc sql;
 %subsubquery(%query,113)
 ;
 quit;