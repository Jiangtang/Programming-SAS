%put NOTE: You have called the macro _SUFFIX, 2004-10-26.;
%put NOTE: Copyright (c) 2001-2004 Rodney Sparapani;
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

    /* _SUFFIX Documentation 
    Returns a list of OS-specific file name extensions for SAS
    DATASETs and SAS INDEXes.  Currently, only Unix, Windows and Mac
    are supported, but other platforms could be added provided that
    they exist on those platforms.
            
    POSITIONAL Parameters  
            
    ARG1             version for which you want the file name extensions,
                     if not given, then the current version is assumed
    
    NAMED Parameters
    
    VERSION=ARG1     alias 
*/

%macro _suffix(arg1, version=&arg1);

%if %length(&version) %then %do;
    %local i;
    %let version=%upcase(&version);
    %if %_substr(&version, 1, 1)=V %then %let version=%_substr(&version, 2);
    %let i=%index(&version, .);
    %if &i %then %let version=%_substr(&version, 1, &i-1)%_substr(&version, &i+1);
    %let version=&version%_repeat(0, 3-%length(&version));
    
    %if &version>=700 %then sas7bdat sas7bndx sas7bvew;
    %else %if &version=607 | &version=609 %then ssd?? snx??;
    %else %if &version=608 | &version=610 %then sd2 si2;
    %else %if &version=603 %then ssd;
    %else %_unwind(ssd?? snx??, sd2 si2, ssd?? snx??);
%end;
%else %do;
    %if %_version(7) %then sas7bdat sas7bndx sas7bvew;
    %else %_unwind(ssd?? snx??, sd2 si2, ssd?? snx??);
%end;

%mend _suffix;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

%put v6=%_suffix(v6);
%put V6=%_suffix(V6);
%put 6=%_suffix(6);
%put 6.=%_suffix(6.);
%put 6.0=%_suffix(6.0);
%put 6.03=%_suffix(6.03);
%put v6.03=%_suffix(v6.03);
%put V6.03=%_suffix(V6.03);
%put v603=%_suffix(v603);
%put V603=%_suffix(V603);
%put 6.04=%_suffix(6.04);
%put 604=%_suffix(604);
%put 6.06=%_suffix(6.06);
%put 606=%_suffix(606);
%put 6.07=%_suffix(6.07);
%put 607=%_suffix(607);
%put 6.08=%_suffix(6.08);
%put 608=%_suffix(608);
%put 6.09=%_suffix(6.09);
%put 609=%_suffix(609);
%put 6.10=%_suffix(6.10);
%put 610=%_suffix(610);
%put 6.11=%_suffix(6.11);
%put 611=%_suffix(611);
%put 6.12=%_suffix(6.12);
%put 612=%_suffix(612);
%put 7=%_suffix(7);
%put 7.=%_suffix(7.);
%put 8.=%_suffix(8.);
%put 8.0=%_suffix(8.0);
%put 80=%_suffix(80);
%put 8.1=%_suffix(8.1);
%put 81=%_suffix(81);
%put 8.2=%_suffix(8.2);
%put 82=%_suffix(82);
%put 9.=%_suffix(9.);
%put 9.0=%_suffix(9.0);
%put 90=%_suffix(90);

*/
