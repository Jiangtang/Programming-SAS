%put NOTE: You have called the macro _ABEND, 2009-02-17.;
%put NOTE: Copyright (c) 2001-2009 Rodney Sparapani;
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

/* _ABEND Documentation
    ABEND the SAS program if it is running in tha background
    
    POSITIONAL Parameter

    ARG1    return the following value to the OS,
            if not supplied, then return the default value
*/

%macro _abend(arg1);

;
%if "&sysenv"="BACK" %then %do;
data _null_;
    put 'ERROR: Your SAS program will ABEND.';
    abort abend &arg1;
run;
%end;
%else %do;
    %put ERROR: A request has been made to ABEND your program.;
    %put        However, since this appears to be an interactive session,;
    %put        the job will continue unless you halt it manually.;
    %put        Please inspect the LOG and LISTING windows carefully.;
%end;

%mend _abend;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

%*_abend;
%_abend(0);
%*_abend(1);
%_abend(2);
%_abend(3);
%_abend(4);
%_abend(5);

proc print data=sashelp.voption;
run;

*/
