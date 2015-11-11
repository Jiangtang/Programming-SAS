%put NOTE: You have called the macro _DSEXIST, 2007-08-01.;
%put NOTE: Copyright (c) 2001-2007 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2001-00-00

This file is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

In short: you may use this file any way you like, as long as you
don't charge money for it, remove this notice, or hold anyone liable
for its results.
*/

/* _DSEXIST Documentation
    Returns a one (true) if the requested SAS DATASET exists;
    otherwise zero (false).
    
    POSITIONAL Parameters  
    
    ARG1            SAS DATASET requested
    
    Specific OPTIONAL Parameters
    
    DATA=ARG1       alias 
*/

%macro _dsexist(arg1, data=&arg1);

%local lib;

%let lib=%_lib(&data);
%let data=%_data(&data);

%if &lib=sashelp %then %do;
	%if &data=vcatalg | &data=vcolumn | &data=vextfl | &data=vindex |
		&data=vmacro | &data=vmember | &data=voption | &data=vtable |
		&data=vtitle | &data=vview | &data=vsacces | &data=vscatlg |
		&data=vslib | &data=vstable | &data=vstabvw | &data=vsview %then 1;
	%else 0;
%end;
%else %do;
    %local suffix1 suffix2;
    %let suffix1=%_suffix;
    %let suffix2=%scan(&suffix1, 3, %str( ));
    %let suffix1=%scan(&suffix1, 1, %str( ));
    %let data=%_dir(%sysfunc(pathname(&lib)))&data;    
    
    %if %_exist(&data..&suffix1) %then 1;
    %else %if %length(&suffix2) & %_exist(&data..&suffix2) %then 1;
    %else 0;
%end;

%mend _dsexist;

%*VALIDATION TEST STREAM;
/* uncomment to re-validate

libname pwd '.';

data;
run;

data pwd.test2;
run;

%put ATTN: %_dsexist(_null_);
%put ATTN: %_dsexist(data1);
%put ATTN: %_dsexist(sashelp.voption);
%put ATTN: %_dsexist(sashelp.voption(obs=1.));
%put ATTN: %_dsexist(sashelp.option);
%put ATTN: %_dsexist(work.data1);
%put ATTN: %_dsexist(work.data2);
%put ATTN: %_dsexist(pwd.test1);
%put ATTN: %_dsexist(pwd.test2);
%put ATTN: %_exist(test2.s*);

%_delete(data=pwd.test2);

*/
