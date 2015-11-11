%put NOTE: You have called the macro _DIR, 2004-11-23.;
%put NOTE: Copyright (c) 2004 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2004-11-22

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

/* _DIR Documentation
            
    POSITIONAL Parameters  
            
    ARG1             directory name, if any
*/

%macro _dir(arg1);

%let arg1=%_file(&arg1);

%local len1;

%let len1=%length(&arg1);

%if %bquote(%_dirchar)=%bquote(%_substr(&arg1, &len1, 1)) %then &arg1;
%else %if &len1>0 %then &arg1%_dirchar;

%mend _dir;

%*VALIDATION TEST STREAM;

/* un-comment to re-validate
%put %_dir("inquotes");
%put %_dir("with space");
%put %_dir(withslash/);
%put %_dir();
*/

