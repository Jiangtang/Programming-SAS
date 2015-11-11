%put NOTE: You have called the macro _VERSION, 2006-02-15.;
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

/* _VERSION Documentation

    Returns a one (true) if the current version of SAS is equal to or
    greater than the version requested; zero (false) otherwise.
    
    POSITIONAL Parameters  
    
    ARG1            version requested
    
    Specific OPTIONAL Parameters
    
    NOTES=          default is to not display the returned value in a NOTE,
                    if set to something, then do display
                    
    VERSION=ARG1    alias 
*/

%macro _version(arg1, notes=, version=&arg1);

%local result;
%let result=%eval(%scan(&sysver, 1, .)*100+0%scan(&sysver, 2, .)>=%scan(&version, 1, .)*100+0%scan(&version, 2, .));
%if %length(&notes) %then %put NOTE: _VERSION is returning the value &result;

&result

%mend _version;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
                    
*VERSION 5 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(5, notes=1);

*VERSION 6 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6 notes=1);

*VERSION 6.03 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.03, notes=1);

*VERSION 6.04 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.04, notes=1);

*VERSION 6.06 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.06, notes=1);

*VERSION 6.07 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.07, notes=1);

*VERSION 6.08 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.08, notes=1);

*VERSION 6.09 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.09, notes=1);

*VERSION 6.10 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.10, notes=1);

*VERSION 6.11 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.11, notes=1);

*VERSION 6.12 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(6.12, notes=1);

*VERSION 7 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(7, notes=1);

*VERSION 7 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(7);

*VERSION 8 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(8, notes=1);

*VERSION 8 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(8);
                    
*VERSION 8.2 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(8.2, notes=1);

*VERSION 8.2 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(8.2);

*VERSION 9 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(9, notes=1);

*VERSION 9 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(9);
                    
*VERSION 9.1 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(9.1, notes=1);

*VERSION 9.1 OR HIGHER;
%put NOTE:  RETURN CODE=%_version(9.1);
                    
*/
                    
