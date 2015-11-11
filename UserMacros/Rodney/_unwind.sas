%put NOTE: You have called the macro _UNWIND, 2004-11-23.;
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

/* _UNWIND Documentation
    This handles OS-specific code.  If you are running on
    Unix, then the Unix branch is executed, etc. 
            
    POSITIONAL Parameters  
            
    ARG1             to be executed on Unix
       
    ARG2             to be executed on DOS, OS/2, Windows
            
    ARG3             to be executed on Mac

    ARG4             to be executed on VMS
                        
    ARG5             to be executed on CMS
    
    ARG6             to be executed on MVS
                        
    NAMED Parameters
    
    UNIX=ARG1       alias
                
    DOS    =ARG2    alias
    OS2    =ARG2    alias
    WINDOWS=ARG2    alias
                
    MAC=ARG3        alias
    
    VMS=ARG4        alias
                    
    CMS=ARG5        alias
                    
    MVS=ARG6        alias
*/

%macro _unwind(arg1, arg2, arg3, arg4, arg5, arg6,
    unix=&arg1, dos=&arg2, os2=&dos, windows=&os2, mac=&arg3,
    vms=&arg4, cms=&arg5, mvs=&arg6);

%if "&sysscp"="WIN" | "&sysscp"="" | "&sysscp"="PC DOS" |
    "&sysscp"="OS2" %then &windows;
%else %if "&sysscp"="MAC" %then &mac;
%else %if "&sysscp"="VMS" | "&sysscp"="VMS_AXP" %then &vms;
%else %if "&sysscp"="CMS" %then &cms;
%else %if "&sysscp"="OS" %then &mvs;
%else &unix;

%mend _unwind;

%*VALIDATION TEST STREAM;

/* un-comment to re-validate
%put This program is running under %_unwind(UNIX, WINDOWS, MAC):  &sysscp..;
%put This directory symbol is %_unwind(/, \, :);
*/
