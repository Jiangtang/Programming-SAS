%put NOTE: You have called the macro _TR, 2004-03-30.;
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

/*  _TR Documentation
    Similar to the DATASTEP function TRANSLATE().
    
    POSITIONAL Parameters
    
    ARG1        the text to be translated
                
    NAMED Parameters
    
    FROM=       the characters to be translated from
    
    TO=         the characters to be translated to
*/

%macro _tr(arg1, to=, from=);

%if %length(&to)^=%length(&from) %then %put ERROR: to-list and from-list must be of equal length.;
%else %do;
	%local i j k ch_to ch_from;
	%let k=%length(&arg1);

	%do i=1 %to %length(&from);
		%let ch_from=%substr(&from,&i,1);
		%let ch_to=%substr(&to,&i,1);
		%let j=%index(&arg1,&ch_from);

		%do %while(&j);
			%if &j=1 %then %let arg1=&ch_to%substr(&arg1,2);
			%else %if &j=&k %then %let arg1=%substr(&arg1,1,&k-1)&ch_to;
			%else %let arg1=%substr(&arg1,1,&j-1)&ch_to%substr(&arg1,&j+1);
			%let j=%index(&arg1,&ch_from);
		%end;
	%end;
&arg1

%end;

%mend _tr;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
%put %_tr(please dont eat the daisies,from=eai,to=xyz);
%put %_tr(please_dont_eat_the_daisies,from=_ai,to=...);
*/
