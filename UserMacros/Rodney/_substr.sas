%put NOTE: You have called the macro _SUBSTR, 2004-03-29.;
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

/* _SUBSTR Documentation
    This is a fault-tolerant version of %SUBSTR which handles 
    special cases like ARG1 being nothing which returns nothing,
    ARG2 greater than the length of ARG1 which returns nothing,
    etc.
            
    POSITIONAL Parameters  
            
    ARG1    string of characters to be subset
       
    ARG2    number representing the beginning of the subset
            
    ARG3    if any, the number of characters in the subset
*/

%macro _substr(arg1, arg2, arg3);

%local length;
%let length=%length(&arg1);

%if 0<&length & &arg2<=&length & &arg2>0 %then %do;
    %if %length(&arg3)=0 %then %substr(&arg1, &arg2);
    %else %if &arg3>&length-&arg2+1 %then %substr(&arg1, &arg2);
    %else %if &arg3>0 %then %substr(&arg1, &arg2, &arg3);
%end;

%mend _substr;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

%put %_substr(1234, 4);
%put %_substr(1234, 5);
%put %_substr(123456, 1, 7);
%put %_substr(12345678, 1+1, 7);
%put %_substr(12'4', 4);
endsas;

*/
