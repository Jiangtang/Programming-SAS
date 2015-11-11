%put NOTE: You have called the macro _SCRATCH, 2006-07-10.;
%put NOTE: Copyright (c) 2001-2006 Rodney Sparapani;
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

/* _SCRATCH Documentation 
    
    Returns the name of the next temporary SAS DATASET that will be
    created, i.e. DATAn.  But, it does not create the SAS DATASET
    which is left up to the user; it is assumed that the creation will
    occur immediately otherwise DATAn may arise in some other way and
    unintended consequences result.  However, even immediate creation
    is not always foolproof since some PROCs have a nasty side effect
    of destroying the next DATAn and even previous ones,
    i.e. DATA1-DATA(n-1).  The only workaround for these braindead 
    PROCs is to change the root of the temporary SAS DATASET names 
    via ROOT=, see below.  
    
    NAMED Parameters 
    
    ROOT=WORK   Default naming scheme
    START=1     Defaults to starting with DATA1
*/

%macro _scratch(root=work, data=&root, start=1);
    %local i;
    %let data=%upcase(&data);
    
    %if %index(&syslast, WORK.&data)=1 %then %do;
        %let i=%_substr(&syslast, %length(WORK.&data)+1);
        
        %if %datatyp(&i)=NUMERIC %then %let i=%eval(&i+1);
        %else %let i=&start;
    %end;
    %else %let i=&start;

    %do %while(%_dsexist(&data.&i));
	%let i=%eval(&i+1); %*put &data.&i;
    %end;

&data.&i

%mend _scratch;

%*VALIDATION TEST STREAM;
/*uncomment to re-validate

data %_scratch;
run;

data %_scratch;
run;

data %_scratch;
run;

data %_scratch;
run;

*/
