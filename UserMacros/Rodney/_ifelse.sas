%put NOTE: You have called the macro _IFELSE, 2008-07-15.;
%put NOTE: Copyright (c) 2006-2008 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2006-02-15

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

/* _IFELSE Documentation
    Take care of boolean expressions with equal signs in them.  When 
    used as positional parameters, they will be flagged as invalid 
    macro parameter names.  Either use named parameters or wrap them 
    in an %eval( ).
            
    POSITIONAL Parameters  
            
    ARG1             condition to be evaluated
       
    ARG2             if ARG1 is true, then this
            
    ARG3             if ARG1 is false, then this

    NAMED Parameters
    
    IF=ARG1          alias
                
    THEN=ARG2        alias
                
    ELSE=ARG3        alias 
*/

%macro _ifelse(arg1, arg2, arg3, if=&arg1, then=&arg2, else=&arg3);

%if &if %then &then;
%else &else;

%mend _ifelse;

%*VALIDATION TEST STREAM;

/* un-comment to re-validate

%let j=5;

%put RESULT=%_ifelse(if=&j=5, then=true, else=false); %*does the right thing;
%put RESULT=%_ifelse(%eval(&j=5), true, false);       %*does the right thing;
%put RESULT=%_ifelse(&j=5, true, false);              %*generates an error;

*/
