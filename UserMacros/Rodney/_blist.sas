%put NOTE: You have called the macro _BLIST, 2008-03-03.;
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

/*  _BLIST Documentation 
    
    Expands variable lists with formats padded, if any:  
    VAR1-VAR10 1. -> VAR1 1. ... VAR10 1.  PDV lists like 
    VAR1X--VAR3X and VAR1: are also expanded with formats padded, 
    if any:  VAR1X--VAR3X 1. -> VAR1X 1. VAR2X 1. VAR3X 1.  
    Note that variable lists are handled by assuming that they are
    PDV lists (usually the case), e.g. VAR1-VAR10 <-> VAR1--VAR10  
    Duplicates are not detected nor removed!  
    _ALL_, _NUMERIC_ and _CHARACTER_ are also supported.

    The name of this macro is a little confusing and requires some
    explanation.  _LIST was originally written to expand variable
    lists.  However, it also found a secondary use as expanding lists
    of anything such as diagnosis codes: %_LIST('694.0'-'694.5') This
    secondary use was so powerful that it became almost as common as
    the primary use.  Also, the primary use of _LIST needed some
    improvements in the special circumstance of expanding lists of
    variable names according to a SAS Dataset provided.  So, _BLIST
    was created and named according to the convention of the quote
    macros: %QUOTE being the first (and no longer recommended for 
    its original purpose) and %BQUOTE, new and improved.  However, 
    in hindsight, a better name for _BLIST may have been _VLIST or
    _VARLIST since _LIST, often, can and must still be used for its
    original purpose, but I digress.
            
    POSITIONAL Parameters  
            
    ARGS            lists to be expanded

    NAMED Parameters

    DATA=_LAST_     default SAS dataset
                    
    NOFMT=0         by default, formats are added to the
                    variable list, NOFMT=1 suppresses them
                    
    SPLIT=          split character that separates items,
                    defaults to blank

    VAR=ARGS        alias
*/

%macro _blist(args, var=&args, data=&syslast, nofmt=0, split=%str( ));
    %local i i1 j k var0 start stop max return fmt0;

%if %_dsexist(&data)=0 %then %do;
    %put ERROR: The requested SAS Dataset, &data, does not exist.;
            
    %_abend;
%end;
%else %if %length(&var) %then %do;
    %*let data=%_lib(&data).%_data(&data);
    %let args=%lowcase(&var);
    %let max=%_count(&args);
    %let dsid=%sysfunc(open(&data));
    
    %let var0=%sysfunc(attrn(&dsid, nvars));

    %do j=1 %to &var0;
        %local var&j fmt&j type&j;
        %let var&j=%lowcase(%sysfunc(varname(&dsid, &j)));
        %let fmt&j=%sysfunc(varfmt(&dsid, &j));
        %let type&j=%sysfunc(vartype(&dsid, &j));

        %if "&&type&j"="C" & %length(&&fmt&j)=0 %then 
            %let fmt&j=$%sysfunc(varlen(&dsid, &j)).;
    %end;
    
    %let dsid=%sysfunc(close(&dsid));
    
    %do i=1 %to &max;
        %let i1=%eval(&i+1);
        %local arg&i arg&i1;
        %let arg&i=%scan(&args, &i, %str( ));
        %let arg&i1=%scan(&args, &i1, %str( ));
            
        %if &nofmt %then %let fmt0=;
        %else %if %index(&&arg&i1, .) %then %let fmt0=&&arg&i1;
        %else %let fmt0=;
            
        %if "&&arg&i"="_all_" %then %do;
            %do j=1 %to &var0;
                %if &nofmt %then %let return=&return &&var&j;
                %else %if %length(&fmt0)=0 %then %let return=&return &&var&j &&fmt&j;
                %else %let return=&return &&var&j &fmt0;
            %end;
        %end;
        %else %if "&&arg&i"="_character_" %then %do j=1 %to &var0;
            %if "&&type&j"="C" %then %do;
                %if &nofmt %then %let return=&return &&var&j;
                %else %if %length(&fmt0)=0 %then %let return=&return &&var&j &&fmt&j;
                %else %let return=&return &&var&j &fmt0;
            %end;
        %end;
        %else %if "&&arg&i"="_numeric_" %then %do j=1 %to &var0;
            %if "&&type&j"="N" %then %do;
                %if &nofmt %then %let return=&return &&var&j;
                %else %if %length(&fmt0)=0 %then %let return=&return &&var&j &&fmt&j;
                %else %let return=&return &&var&j &fmt0;
            %end;
        %end;
        %else %if %index(&&arg&i, :) %then %do;
            %let arg&i=%scan(&&arg&i, 1, :);
            
            %do j=1 %to &var0;
                %if %index(&&var&j, &&arg&i)=1 %then %do;
                    %if &nofmt %then %let return=&return &&var&j;
                    %else %if %length(&fmt0)=0 %then %let return=&return &&var&j &&fmt&j;
                    %else %let return=&return &&var&j &fmt0;
                %end;
            %end;
        %end;
        %else %if %index(&&arg&i,-) %then %do;
            %let k=0;
            %let start=%scan(&&arg&i, 1, -);
            %let stop=%scan(&&arg&i, 2, -);
        
            %do j=1 %to &var0;
                %if "&start"="&&var&j" | &k %then %do;
                    %let k=1;
                    
                    %if &nofmt %then %let return=&return &&var&j;
                    %else %if %length(&fmt0)=0 %then %let return=&return &&var&j &&fmt&j;
                    %else %let return=&return &&var&j &fmt0;
                %end;
                
                %if "&stop"="&&var&j" %then %let k=0;
            %end;
        %end;
        %else %do j=1 %to &var0;
            %if "&&var&j"="&&arg&i" %then %do;
                %if &nofmt %then %let return=&return &&var&j;
                %else %if %length(&fmt0)=0 %then %let return=&return &&var&j &&fmt&j;
                %else %let return=&return &&var&j &fmt0;
            %end;
        %end;
    %end;
    
    &return
%end;    
%mend _blist;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
        
data ;
    length one1-one10 two1-two10 8;
    retain one1-one10 two1-two10 8 a 'a' z 'z';
    attrib one1-one10 two1-two10 format=8. dgy format=z5.;
    dgy=1999;
    output;
    stop;
run;

%put %_blist(var=dgy);
%put %length(%_blist(var=none));
%put %_blist(dgy best7.);
%put %_blist(_all_);
%put %_blist(_all_ 2.);
%put %_blist(_numeric_);
%put %_blist(_numeric_ 2.);
%put %_blist(_character_);
%put %_blist(_character_ $2.);
%put %_blist(one: two: 1.);
%put %_blist(one: 1. two:);
%put %_blist(one: 2. two: 1.);
%put %_blist(one1-one10);
%put %_blist(one1-one10 3.);
%put %_blist(one1--two10);
%put %_blist(one1--two10 3.);
                        
%put %_blist(_numeric_, nofmt=1);
%put %_blist(_numeric_ 2., nofmt=1);
%put %_blist(one: two: 1., nofmt=1);
%put %_blist(one: 1. two:, nofmt=1);
%put %_blist(one: 2. two: 1., nofmt=1);
%put %_blist(one1-one10, nofmt=1);
%put %_blist(one1-one10 3., nofmt=1);
%put %_blist(one1--two10, nofmt=1);
%put %_blist(one1--two10 3., nofmt=1);

*/
