%put NOTE: You have called the macro _INDEXC, 2004-03-29.;
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

/* _INDEXC Documentation
    Similar to the DATASTEP function INDEXC.  It returns the position
    of the first instance, if any, of one of the characters provided.

    POSITIONAL Parameters  
            
    ARG1    string of characters to be searched
       
    ARG2    list of characters to search for
*/

%macro _indexc(source, excerpt);

%local i l;
%let i=1;
%let l=%length(&source);

%do %while(&i<=&l & %index(&excerpt, %bquote(%_substr(&source, &i, 1)))=0);
	%let i=%eval(&i+1);
%end;

%if &i<=&l %then &i;
%else 0;

%mend _indexc;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
%put RESULT=%_indexc('    ', ''"");
%put RESULT=%_indexc("    ", ''"");
*/
