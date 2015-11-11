%put NOTE: You have called the macro _PRINTTO, 2004-08-12.;
%put NOTE: Copyright (c) 2000-2004 Rodney Sparapani;
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

/* _PRINTTO Documentation
    Re-direct SAS LOG/OUTPUT to a file or device.  If called without
    any arguments, then clear former settings.  Patterned after
    PROC PRINTTO.

    NAMED Parameters
    
    APPEND=             file name or device to append SAS OUTPUT to
                    
    FILE=               file name or device to re-direct SAS OUTPUT to,
                        if a file name, then it will be emptied first
    NAME=FILE           alias
    PRINT=FILE          alias
                    
    FILENAME=           FILEREF to re-direct SAS OUTPUT to
    FILEREF=FILENAME    alias
    
    LOG=                file name or device to re-direct SAS LOG to,
                        if a file name, then it will be emptied first
    
    PAGENO=             number to set the SAS OUTPUT page number to
*/
    
%macro _printto(file=, name=&file, print=&name, filename=, fileref=&filename,
    formdlim=, log=, append=, pageno=);

    %local modifier;
    
    %let append=%scan(&append, 1, ""'');
    %let print=%scan(&print, 1, ""'');
    %let log=%scan(&log, 1, ""'');
    %let modifier=%scan(&formdlim, 2, ""'');
    %let formdlim=%scan(&formdlim, 1, ""'');

    %if %length(&append) %then %let print=print="&append";
    %else %if %length(&fileref) %then %let print=print=&fileref;
    %else %if %length(&print) %then %let print=print="&print" new;
    %else %if %length(&log) %then %let print=log="&log" new;

    proc printto &print;
    run;
    
    options 
        %if %length(&pageno) %then pageno=&pageno;
        %if %length(&formdlim) %then formdlim="&formdlim"&modifier;
    ;
%mend _printto;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

options ps=60 ls=80 mprint obs=10 nodate frmdlim='-';

title "TURN THE LOG OFF";
%_printto(log=%_null);

title "TURN THE LOG BACK ON";
%_printto;

title "PRINT TO THE FILE _printto.1";
%_printto(print=_printto.1);

proc print data=sashelp.voption;
var optname;
run;

filename printto "_printto.2";

title "PRINT TO THE FILEREF PRINTTO (FILENAME _printto.2)";
%_printto(fileref=printto new);

proc print data=sashelp.voption;
var optname;
run;

title "APPEND TO THE FILE _printto.1";
%_printto(append=_printto.1);

proc print data=sashelp.voption;
var optname;
run;
*/
