%put NOTE: You have called the macro _CEXPORT, 2009-01-13.;
%put NOTE: Copyright (c) 2004-2009 Rodney Sparapani;
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

/* _CEXPORT Documentation
    Export a CSV/Stata file from a SAS Dataset.  Note that the Stata 
    missing value character is also . and spreadsheets seem to 
    tolerate it as well.  However, Stata treats any non-numeric text 
    (besides .) as a string, while spreadsheets treat as missing.  
    So . is used for missing data and ._, .A, ..., .Z are also 
    handled as missing.

    Other Stata notes: Stata only supports integers to 9 digits of
    precision; beyond that strings can be used if the numeric quality
    of the variable is not needed; otherwise, single/double precision
    floating point numbers can be used in exponential notation.  SAS
    and Stata treat dates the same way numerically, so output SAS
    dates as integers (which is the default) and format them as dates
    in Stata with statements like: . format DATE %d
    
    REQUIRED Parameters  

    FILE=                   CSV file to create

    Specific OPTIONAL Parameters

    CFORMAT=$quote24.   default format for character variables 

    CHAR=               default list of character variables to be included,
                        use _character_ for all 

    CNOFMT=0            by default, character formats from the SAS Dataset
                        are used since $LENGTH. is returned in the absence
                        of a true format, the length is needed to create quoted
                        CSV character variables, CNOFMT=1 does not use them

    DATA=_LAST_         default SAS dataset used
                        variables respectively
    
    EOL=                if blank, then defaults to native; on Unix, set to DOS
                        for CR/LF

    LINESIZE=32767      default line length

    LS=LINESIZE         alias

    NAMES=1             produces variable names on the first
                        line of CSV file, if set to anything
    NFORMAT=best9.      default format for numeric variables

    NNOFMT=1            by default, numeric formats from the SAS Dataset
                        are not used since dates are best handled as integers
                        when moving data to Stata, NNOFMT=0 uses them, if any
                    
    NUM=                default list of numeric variables to be included,
                        use _numeric_ for all 
                            
    Common OPTIONAL Parameters
    
    IF=
    
    WHERE=IF                ALIAS
                            
    LOG=                    set to /dev/null to turn off .log                            
*/

%macro _cexport(file=REQUIRED, data=&syslast, cformat=$quote24., char=, cnofmt=0,
    eol=, nformat=best9., nnofmt=1, num=, linesize=32767, ls=&linesize, names=1, 
    where=, if=&where, log=);

%_require(&file);

%let file=%scan(&file, 1, ''"");
    
%if %length(&log) %then %_printto(log=&log);

%local nobs i j arg args num0 var0 cor0 dsid;
%let nobs=%_nobs(data=&data);
%let num=%_blist(&num, data=&data, nofmt=&nnofmt);
%let num0=%_count(&num);
%let var=&num %_blist(&char, data=&data, nofmt=&cnofmt);
%let args=%_count(&var);
%let cor0=0;
%let var0=0;

%if &args %then %do;
    %do i=1 %to &args;
        %let arg=%scan(&var, &i, %str( ));
    
        %if %index(&arg, .) %then %do;
            %let format&var0=&arg;
        
            %if &i<=&num0 %then %let cor0=%eval(&cor0+1);
        %end;
        %else %do;
            %let var0=%eval(&var0+1);
            %local var&var0 format&var0;
            %let var&var0=%lowcase(&arg);
        
            %if &var0>(&num0-&cor0) %then %let format&var0=&cformat;
            %else %let format&var0=stata.;
        %end;
    %end;

    %let num0=%eval(&num0-&cor0);
%end;
%else %do;
    %put ERROR: you have not specified any variables!;
    %put ERROR: for all numeric variables, specify NUM=_numeric_;
    %put ERROR: for all character variables, specify CHAR=_character_;
    
    %_abend;
%end;

%if &var0>256 %then %do;
    %put ERROR: only 256 variables are supported by the CSV format!;
    
    %_abend;
%end;

%do i=&num0+1 %to &var0;
    %if %substr(&&format&i, 1, 1)=$ & 
        %index(0123456789, %substr(&&format&i, 2, 1)) %then
        
        %let format&i=$quote%sysevalf(%substr(&&format&i, 2)+2).;
%end;

proc format;
    value stata
        ._,.A-.Z,.='.'
        other=[&nformat]
    ;
run;

data _null_;
    set &data;
    
    array __string(&var0) $ 200 _string1-_string&var0;
    file "&file" linesize=&ls;
    
    if _n_=1 & %length(&names)>0 then put %do i=1 %to &var0-1; "&&var&i," %end; "&&var&var0";

    %do i=1 %to &var0; 
        __string(&i)=trim(put(&&var&i, &&format&i-l));
    %end; 
    
    %if %length(&if) %then if &if;;
    
    put _string1 %if &var0>1 %then (_string2-_string&var0) (+(-1) ',');;
run;

%if %length(eol) %then %do;
    %if " %upcase(&eol)"=" %_unwind(DOS)" %then x "unix2dos &file &file";;
%end;

%if %length(&log) %then %_printto;

%mend _cexport;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

*/
