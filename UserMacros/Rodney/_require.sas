%put NOTE: You have called the macro _REQUIRE, 2004-03-29.;
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

/* _REQUIRE Documentation
    Checks all parameters for the string REQUIRED.  If it is
    found, then ABEND the SAS program.  This is used to check
    for NAMED Parameters that are REQUIRED, i.e. default to
    REQUIRED, but not given a value when called.  For example,
    a SAS program like the following will abend since OUT=
    defaults to REQUIRED, but it is not provided a value:
    %_DECODA(INFILE=aIndex.txt);
    This is due to the following code which is included in
    _DECODA:
    %_REQUIRE(&OUT);
*/

%macro _require/parmbuff;

%if %index(&syspbuff, REQUIRED) %then %do;
    %put ERROR: One or more required parameters not provided.;
    
    %_abend;
%end;

%mend _require;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

%_require(REQUIRED);

*/
