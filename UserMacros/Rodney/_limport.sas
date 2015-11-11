%put NOTE: You have called the macro _LIMPORT, 2008-08-18.;
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

/* _LIMPORT Documentation
    Import a R/S+/BUGS "list" data file into a SAS Dataset.
    
    REQUIRED Parameters  

    INFILE=                 "list" file to read
                            
    N=N                     by default, removes scalar named N
                            which is often a member of BUGS "list"
                            data files; change the name if necessary
                            
    OUT=                    SAS dataset created
                            
    Specific OPTIONAL Parameters
                            
    AFTER=                  SAS/IML statements to run after import
                            
    BEFORE=                 SAS/IML statements to run before import
                            
    FILE=SYSJOBID.sas       SAS/IML program created to read
                            "list" file; run automatically;
                            if program fails, edit and run
                            manually
    
    RUN=1                   by default, run the import
                            
    RENAME=                 same as SAS statement except when no =NEW name 
                            provided; in that case, translates dots in OLD 
                            name to underscores
                    
                            
    Common OPTIONAL Parameters
    
    LOG=                    set to /dev/null to turn off .log                            
*/

%macro _limport(infile=REQUIRED, out=REQUIRED, file=&sysjobid..sas, n=N, 
    after=, before=, run=1, rename=, log=);

%_require(&infile &out);

%let infile=%scan(&infile, 1, ''"");
%let file=%scan(&file, 1, ''"");
    
%if %length(&log) %then %_printto(log=&log);

%local i var0 var old new;

%let rename=%lowcase(%str( )&rename); 
%let var0=%_count(%str( )&rename, split=%str( )); 

data _null_;
    file "&file";
    infile "&infile" length=pos dlm='0d0a'x end=lastrec;
    length string $ 200;
    retain paren 1 flag 0;

    input @;
    input string $varying. pos;
        
    pos=index(string, '#');
    
    if pos=1 then string='';
    else if pos>1 then string=substr(string, 1, pos-1); 
    
if string>'' then do;    
    if flag=0 then do;
        flag=1;
        put "proc iml; &before;";
        
        string=compress(lowcase(string), "'`""");
        
        pos=index(string, "<-");
        
        if pos then substr(string, pos, 2)=' =';
        
        pos=index(string, "list(&n=");
    
        if pos then substr(string, pos+5, index(string, ',')-pos-4)='';
        else pos=index(string, 'list(');

        if pos>1 then do;
            do i=1 to pos-1;
                paren=paren+(substr(string, i, 1)='(');
            end;
        end;

        if pos then do;
            if length(string)>pos+5 then string=substr(string, pos+5);
            else string='';
        end;
    end;

    pos=indexc(string, '()');

    do while(pos);
        if length(string)>=pos+2 & substr(string, pos, 3)=')),' then do;
            paren=paren-2;
            substr(string, pos, 3)=' };';
        end;
        else if length(string)>=pos+1 & 
            (substr(string, pos, 2)='),' | substr(string, pos, 2)='))') then do;
            paren=paren-1;
            substr(string, pos, 2)='};';
        end;
        else if substr(string, pos, 1)=')' then do;
            paren=paren-1;

            if paren=0 then substr(string, pos, 1)=';';
            else substr(string, pos, 1)='}';
        end;
        else do;
            paren+1;
            substr(string, pos-1, 2)=' {';
        end;
    
        pos=indexc(string, '()');
    end;

    pos=index(string, 'NA');
    
    do while(pos);
        substr(string, pos, 2)=' .';     
        pos=index(string, 'NA');
    end;
    
    pos=indexw(string, 'row.names');

    if pos then substr(string, pos, 9)=' rownames';
        
    %do i=1 %to &var0;
        %let var=%scan(%str( )&rename, &i, %str( ));
        
        %if %_count(=&var, split==)=1 %then %do;
            %let var=%scan(=&var, 1, =);

            pos=index(string, "&var");

            if pos then substr(string, pos, length("&var"))=translate("&var", '_', '.');
        %end;
        %else %do;
            %let old=%scan(&var, 1, =);
            %let new=%scan(&var, 2, =);
        
            pos=index(string, "&old");

            if pos=1 then string="&new"||substr(string, pos+length("&old"));
            else if pos>1 then 
                string=substr(string, 1, pos-1)||"&new"||substr(string, pos+length("&old"));
        %end;
   %end;
                
    put string;
end;
        
    if lastrec then 
        put "&after; create &out var _all_; append var _all_; quit;";
run;

%if &run %then %include "&file";

%if %length(&log) %then %_printto;

%mend _limport;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
%_limport(file=ratmis.sas, infile=ratmis-s.dat, out=ratmis);

proc print data=ratmis;
run;

%_limport(file=alc.sas, infile=alc.tbl, out=alc);

proc print data=alc;
run;
*/


