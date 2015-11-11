%put NOTE: You have called the macro _COUNT, 2008-08-27.;
%put NOTE: Copyright (c) 2001-2008 Rodney Sparapani;
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

/* _COUNT Documentation
    Returns the count of individual items in a list.

    POSITIONAL Parameters  
            
    ARG1            list to be counted

    NAMED Parameters
    
    NOTES=          default is to not display the returned value in a NOTE,
                    if set to something, then do display
                    
    SPLIT=          split character that separates items,
                    defaults to blank

    TEXT=ARG1       alias
*/

%macro _count(arg1, text=&arg1, notes=, split=%str( ));
    %local i;
    %let i=0;

    %*do %while(%length(%nrbquote(%scan(%nrbquote(&text), &i+1, &split))));
    %do %while(%length(%qscan(&text, &i+1, &split)));
	%let i=%eval(&i+1);
    %end;

&i

    %if %length(&notes) %then %put NOTE: _COUNT is returning the value: &i.;
%mend _count;

%*VALIDATION TEST STREAM.;

/* un-comment to re-validate

%put NOTE:  RETURN CODE=%_count('1 2 3 4 5');
%put NOTE:  RETURN CODE=%_count(1 2 3 4 5);
%put NOTE:  RETURN CODE=%_count( 1 2 3 4 5 );
%put NOTE:  RETURN CODE=%_count(  1  2  3  4  5  );
%put NOTE:  RETURN CODE=%_count( (1  2  3  4  5) );
%put NOTE:  RETURN CODE=%_count( (1  2  3  4  5) , split=());
%let test=1 2 3 4 5;
%put NOTE:  RETURN CODE=%_count(&test);
%put NOTE:  RETURN CODE=%_count(&test, notes=1);
%put NOTE:  RETURN CODE=%_count(1%str(,)2%str(,)3%str(,)4%str(,)5, split=%str(,));

endsas;

Local Variables:
ess-sas-submit-command-options: "-noautoexec"
End:
*/

