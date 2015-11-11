%put NOTE: You have called the macro _DIFF, 2007-06-15;
%put NOTE: Copyright (c) 2007 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2007-06-14

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
    
/*  _DIFF Documentation
    Find the first difference in 2 arguments.
    
    REQUIRED Parameters
    
                
    NAMED Parameters
    
*/

%macro _diff(arg1, arg2);

%local i return len len1 len2;
%let i=0;
%let len1=%length(&arg1);
%let len2=%length(&arg2);
%let len=%_min(&len1, &len2);

%if &len1=&len2 %then %let return=0;
%else %if &len1<&len2 %then %let return=%eval(&len1+1);
%else %let return=%eval(&len2+1);

%if &len>0 %then %do %until(&i=&return | &i=&len);
    %let i=%eval(&i+1);

    %if "%_substr(&arg1, &i, 1)"^="%_substr(&arg2, &i, 1)" %then %let return=&i;
%end;

&return

%mend _diff;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
       
%put RC=%_diff(this, this);
%put RC=%_diff(this, that);
%put RC=%_diff(this,);
%put RC=%_diff(,);

*/
