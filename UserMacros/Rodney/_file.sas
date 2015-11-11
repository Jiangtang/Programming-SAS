%put NOTE: You have called the macro _FILE, 2004-11-23.;
%put NOTE: Copyright (c) 2004 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2004-11-23

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

/* _FILE Documentation
            
    POSITIONAL Parameters  
            
    ARG1             file name
*/

%macro _file(arg1);

%*strip quoting since the returned value will be unquoted;
%scan(&arg1, 1, ''"")

%mend _file;

%*VALIDATION TEST STREAM;

/* un-comment to re-validate
%put %_file("inquotes");
%put %_file('with space');
%put %_file(withslash/);
%put %_file();
*/

