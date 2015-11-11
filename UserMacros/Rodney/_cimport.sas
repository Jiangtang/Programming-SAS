%put NOTE: You have called the macro _CIMPORT, 2008-10-20.;
%put NOTE: Copyright (c) 2004-2008 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2004-00-00

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

/* _CIMPORT Documentation
    Import a CSV/Stata file into a SAS Dataset.  The following
    characters in variable names are converted to underscore:
    _.-[]()@ and space.  All other non-alphanumeric characters are 
    removed.
    
    REQUIRED Parameters  

    INFILE=                 CSV file to read
    OUT=                    SAS dataset created
                            
    Specific OPTIONAL Parameters
                            
    ATTRIB=                 ATTRIB statement;
                            see the SAS manual with respect to the
                            ATTRIB statement for more details
                            
    DAY0='01JAN1960'D       set to the date which represents 0
                            in the file which you are importing;
                            see also the NUMDATES= option;
                            the default is valid for SAS and Stata;
                            for Excel, try DAY0='30DEC1899'D
                            however, Excel dates prior to 01MAR1900  
                            are uncertain since the non-existant
                            leap year date of 29FEB1900 is a valid 
                            choice for day 60 in Excel, whereas other
                            Excel-compatible spreadsheet applications 
                            may have no leap year in 1900 and define 
                            day 60 as 28FEB1900 so that 01MAR1900, and 
                            beyond, agree 
    
    FILE=INFILE             alias
                            
    INFORMAT=               INFORMAT statement; for non-trivial data,
                            list the variables followed by their 
                            informat.  
                            Ex. INFORMAT=birthd date7. zip $5.
                            see the SAS manual with respect to the
                            INFORMAT statement for more details
    
    LINESIZE=32767          default line length
    LS=LINESIZE             alias
                            
    NUMDATES=               list of numeric dates containing
                            optional formats (rather than 
                            character dates, for those see
                            INFORMAT= above); supply these
                            for a DAY0= correction
                            
    Common OPTIONAL Parameters
    
    LOG=                    set to /dev/null to turn off .log                            

    IF=

    WHERE=IF                alias

    RASMACRO Dependencies
    _COUNT
    _LIST
    _PRINTTO
    _REQUIRE
*/

%macro _cimport(file=REQUIRED, infile=&file, out=REQUIRED, attrib=, day0='01JAN1960'd,
    informat=, linesize=32767, ls=&linesize, numdates=, obs=max, if=&where, where=, log=);

%_require(&infile &out);

%let infile=%scan(&infile, 1, ''"");
    
%if %length(&log) %then %_printto(log=&log);

%local i %_list(var0-var256);

data _null_;
    infile "&infile" dsd obs=1 ls=&ls dlm='0a0d2c'x missover;
    length var $ 64;
    i=0;
        
    do until(var=' ');
        i=i+1;
        input var @;

        if var>' ' then do;
            var=compress(var, '=\`;'',/!#$%^&*+|~:"?{}');
            
            if substr(var, 1, 1) in ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9') then
                var='_'||var;
                
            if length(var)>32 then var=substr(var, 1, 32);
            
            var=translate(trim(var), '________', ' -.[]()@');
            call symput('var'||left(i), var);
            call symput('var0', trim(left(i)));
        end;
    end;
run;

data &out;
    attrib &attrib;
    informat &informat;
    infile "&infile" dsd firstobs=2 obs=&obs ls=&ls dlm='0d2c'x missover;

    input %do i=1 %to &var0; &&var&i %end;;
    
    %if %length(&numdates) %then %do;
        *format &numdates;
        
        %let var0=%_count(&numdates);
        
        %do i=1 %to &var0;
            %let var&i=%scan(&numdates, &i, %str( ));
            
            %if %index(&&var&i,.)=0 %then &&var&i=&&var&i+&day0;;
        %end;
    %end;
                            
    %if %length(&where) %then if &if;;
run;
    
%if %length(&log) %then %_printto;

%mend _cimport;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
*/


