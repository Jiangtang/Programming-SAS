%put NOTE: You have called the macro _NOBS, 2007-07-11.;
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

/* _NOBS Documentation
    Returns the number of observations in a SAS DATASET.
    
    REQUIRED Parameters  
    
    DATA=_LAST_     default SAS DATASET
    
    Specific OPTIONAL Parameters
    
    NOTES=1         default is to display the returned value in a NOTE,
                    if set to nothing, then do not display
    
    Common OPTIONAL Parameters
    
    FIRSTOBS=
    
    DROP=
    
    KEEP=
    
    OBS=
    
    RENAME=
    
    WHERE=
*/

%macro _nobs(data=&syslast, firstobs=, drop=, keep=, obs=, rename=, where=, notes=1);

%local temp;

%if %_dsexist(&data) %then %do;
	%let temp=%_option(&data) &firstobs &obs &where;

	%if %length(&temp)=0 & "%upcase(%_lib(&data))"="SASHELP" %then %let firstobs=1;
	%if %length(&firstobs)	%then %let firstobs=firstobs=&firstobs;
	%if %length(&drop)	%then %let drop=drop=&drop;
	%if %length(&keep)	%then %let keep=keep=&keep;
	%if %length(&obs)	%then %let obs=obs=&obs;
	%if %length(&rename)	%then %let rename=rename=(%scan(&rename, 1, ()));
	%if %length(&where)	%then %let where=where=(&where);

	%let temp=%_option(&data) &firstobs &obs &where;
	%let data=&data (&temp &drop &keep &rename);
	%let data=%sysfunc(open(&data));

	%if %length(&temp) %then %do;
		%if %_version(7) %then %let temp=%sysfunc(attrn(&data, nlobsf));
		%else %let temp=-1;
	%end;
	%else %let temp=%sysfunc(attrn(&data, nlobs));

	%let data=%sysfunc(close(&data));
%end;
%else %let temp=0;

%if %length(&notes) %then %put NOTE: _NOBS is returning the value &temp;

&temp

%mend _nobs;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

options mprint;

data;
run;

%put NOTE:  RETURN CODE=%_nobs;

%put NOTE:  RETURN CODE=%_nobs(data=work._null_);

proc print data=sashelp.voption;
var optname;
run;

%put NOTE:  RETURN CODE=%_nobs(data=sashelp.voption);

%put NOTE:  RETURN CODE=%_nobs(data=sashelp.voption, obs=10);

%put NOTE:  RETURN CODE=%_nobs(data=sashelp.voption, firstobs=2, obs=10);

proc print noobs data=sashelp.voption;
var optname;
where length(optname)>8;
run;

%put NOTE:  RETURN CODE=%_nobs(data=sashelp.voption, where=length(optname)>8);
%put NOTE:  RETURN CODE=%_nobs(data=sashelp.voption(where=(length(optname)>8)));

*/
