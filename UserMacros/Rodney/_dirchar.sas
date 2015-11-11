%put NOTE: You have called the macro _DIRCHAR, 2007-07-24.;
%put NOTE: Copyright (c) 2004-2007 Rodney Sparapani;
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

/* _DIRCHAR Documentation
    Emits the directory character appropriate for your
    operating system (note that only Unix, PC and Mac
    have a consistent notion of such).
    
    NO Parameters
*/

%macro _dirchar;
    
%_unwind(/, \, :)

%mend _dirchar;

%*VALIDATION TEST STREAM;

/* un-comment to re-validate
%put This program is running under %_unwind(UNIX, WINDOWS, MAC):  &sysscp..;
%put This directory character is "%_dirchar";
*/
