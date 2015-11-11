%put NOTE: You have called the macro _EXIST, 2004-03-29.;
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

/* _EXIST Documentation
    Returns a one (true) if the requested file exists; 
    otherwise zero (false).  Shorthand for %SYSFUNC(FILEEXIST())
            
    POSITIONAL Parameters  
            
    ARG1             file to be checked for existence
*/

%macro _exist(arg1);

%sysfunc(fileexist(&arg1))

%mend _exist;

%*VALIDATION TEST STREAM;
/* uncomment to re-validate

%put RC=%_exist(~/autoexec.sas);

%put RC=%_exist(%_unwind(/usr/local/sasmacro/, c:\sasmacro\)_exist.sas);
*Result should be (this file exists):  RC=1;

%put RC=%_exist(%_unwind(/usr/local/sasmacro/, c:\sasmacro\));
*Result should be (this directory file exists):  RC=1;

%put RC=%_exist(this_file_does_not_exist);
*Result should be (this file does not exist):  RC=0;

*/
