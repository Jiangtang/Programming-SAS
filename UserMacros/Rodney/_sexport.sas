%put NOTE: You have called the macro _SEXPORT, 2009-02-17.;
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

/* _SEXPORT Documentation 
    Export a BUGS, JAGS or R/S/S+ data file of matrices from a SAS Dataset.
    
    REQUIRED Parameters  

    FILE=                   "structure" file to create

    VAR=                    list of arrays to be included
                            Ex. two arrays: VAR=one1-one5 two1-two8
                            
    Specific OPTIONAL Parameters
                            
    APPEND=                 append, rather than replace    

    BY=                     compute statistics according to a BY variable
                            i.e. summarize by row, rather than column
                            
    CHAIN=1                 If CHAIN=1, then generate data file and init file,
                            if any.  Otherwise, generate init file only.
                            MEAN/PROB summaries are unaltered by default
                            however, if CHAIN>1, they are calculated 
                            analogously to the chain initializations 
                            of the SAS Bayesian Procedures, i.e. 
                            MEAN+((-1)^(CHAIN-1))*(2+FLOOR(CHAIN/2))*SE                            

    CLOSE=1                 defaults to closing a file on exit

    DATA=_LAST_             default SAS dataset used
                            
    FORMAT=best12.          default format for variables
            
    INIT=                   default for data file creation rather
                            than an init file, set to a file name to
                            be created to over-ride                            
                            
    INITAPPEND=             append to init file, instead of creating                            
    
    INITCLOSE=1             defaults to closing init file on exit
        
    INITINSERT=             values to insert into INIT, see INSERT below
                            
    INSERT=                 values to insert into FILE, for TYPE=JAGS
                            / force out linefeeds
            
    LINESIZE=80             default line length

    LOGMEAN=                list of continuous and/or discrete variables
                            to compute the natural logarithm of the mean for
                            (mutually exclusive option to MEAN/LOGIT, i.e. only
                            provide one of LOGIT=, LOGMEAN= or MEAN=)
    
    LOGIT=                  list of indicator variables to compute the logit for 
                            (mutually exclusive option to MEAN/LOGMEAN, i.e. only
                            provide one of LOGIT=, LOGMEAN= or MEAN=)
    
    LS=LINESIZE             alias
                            
    MEAN=                   list of continuous and/or discrete variables
                            to compute the mean for
                            (mutually exclusive option to LOGMEAN/LOGIT, i.e. only
                            provide one of LOGIT=, LOGMEAN= or MEAN=)
                            
    N=N                     default name of variable for number of
                            observations
                            
    OUT=DATA                default name of object
                            
    PREC=                   list of continuous variables
                            to compute the precision for
                            
    PROB=                   list of discrete variables
                            to compute the probability for

    TYPE=BUGS               by default create a BUGS-style "structure"
                            unless the file name extension starts with:
                            .dump, .dmp (for JAGS), .r, .R (for R), .s or .S (for S/S+) 
                            to over-ride:
                            set to JAGS for JAGS
                            set to R for R
                            set to S or S+ for S/S+
                            (only JAGS is assumed to require column-major order,
                            i.e. the data is sequentially output by going down
                            the columns rather than across the rows)
    
    Common OPTIONAL Parameters
    
    LOG=                    set to /dev/null to turn off .log                            
*/

%macro _sexport(append=REQUIRED, file=&append, var=REQUIRED, data=&syslast, 
    by=, chain=1, close=1, format=best12., initappend=, init=&initappend, 
    initclose=1, initinsert=, insert=, linesize=80, logit=, logmean=&logit, 
    ls=&linesize, mean=&logmean, n=N, out=&data, prec=, prob=, type=BUGS, log=);

%_require(&file &var);

%local nobs h i j k var0 name create cols rows scratch meanonly preconly 
    savelast stats closelast logitonly logmeanonly meantype jags0;

%let file=%scan(&file, 1, ''"");
%let type=%upcase(&type);
%let data=%upcase(&data);
%let savelast=%upcase(&syslast);

%if "&type"="BUGS" %then %do;
    %if %index(%lowcase(&file),.dump) %then %let type=JAGS;
    %else %if %index(%lowcase(&file),.dmp) %then %let type=JAGS;
    %else %if %index(%lowcase(&file),.r) %then %let type=R;
    %else %if %index(%lowcase(&file),.s) %then %let type=S;
%end;
%else %if "&type"="S+" %then %let type=S;
    
%if "&type"="R" | "&type"="S" %then %let n=;   

%if %length(&log) %then %_printto(log=&log);

%let nobs=%_nobs(data=&data);
%let var0=%_count(&var);
%let j=0;
    
%do i=1 %to &var0;
    %let j=%eval(&j+1);
    %local var&j format&j name&j;
    %let var&j=%scan(&var, &i, %str( ));
    %let format&j=&format;
        
    %if %index(&&var&j, .) %then %do;
        %let name=&&var&j;
        %let j=%eval(&j-1);
        %let format&j=&name;
    %end;
    %else %let name&j=%_substr(&&var&j, 1, %_indexc(&&var&j, 0123456789)-1);
%end;
        
%let var0=&j;

%if &var0=0 %then %do;
    %put ERROR: no variables found, DATA=&data, VAR=&var;
    %_abend;
%end;
%else %if &nobs=0 %then %do;
    %put ERROR: no observations found, DATA=&data, NOBS=&nobs;
    %_abend;
%end;

%if "&append"="REQUIRED" %then %let create=1;
%else %let create=0;

%let stats=%_count(&mean &prec &prob);
%let closelast=0;
%let h=0;
            
%do i=1 %to &var0;
    %let preconly=%sysfunc(indexw(%upcase(&prec), %upcase(&&var&i)));
    %let meanonly=%sysfunc(indexw(%upcase(&mean), %upcase(&&var&i)));
    %let logitonly=%sysfunc(indexw(%upcase(&logit), %upcase(&&var&i)));
        
    %if &logitonly %then %let logmeanonly=0; 
    %else %let logmeanonly=%sysfunc(indexw(%upcase(&logmean), %upcase(&&var&i)));
    
    %if &preconly | &meanonly %then %do;
        %if &preconly & &meanonly %then %do;
            %let preconly=0;
            %let meanonly=0;
            %let stats=%eval(&stats-1);
        %end;
        
        %let h=%eval(&h+1);
        %let scratch=%_scratch;
        %let cols=%_count(%_list(&&var&i));
        
        %if %length(&by) %then %do;
            data &scratch;
                set %do j=1 %to &cols;
                    &data(keep=&by &&name&i..&j rename=(&&name&i..&j=&&name&i))
                %end;;
                by &by;
            run;
            
            proc univariate normal plot data=&scratch;
                by &by;
                var &&name&i;
                output out=&scratch mean=mean_&&name&i var=var_&&name&i n=n_&&name&i;
            run;

            data &scratch;
                set &scratch;
                prec_&&name&i=1/var_&&name&i;
    
                drop &by n_&&name&i var_&&name&i
                %if &logmeanonly %then %do;
                    mean_&&name&i;
                        
                    %if &chain>1 %then mean_&&name&i=mean_&&name&i+
                        ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(mean_&&name&i/n_&&name&i);;
                    log_mean_&&name&i=log(mean_&&name&i);
                    %let meantype=log_mean;
                %end;                
                %else %if &logitonly %then %do;
                    mean_&&name&i;
                        
                    %if &chain>1 %then 
                        mean_&&name&i=mean_&&name&i+
                            ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(mean_&&name&i*(1-mean_&&name&i)/n_&&name&i);;
                    logit_&&name&i=log(mean_&&name&i/(1-mean_&&name&i));
                    %let meantype=logit;
                %end;
                %else %do;
                    ;
                    %if &chain>1 %then 
                        mean_&&name&i=mean_&&name&i+
                        ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(var_&&name&i/n_&&name&i);;
                    %let meantype=mean;
                %end;
            run;

            %if &meanonly %then %let var=&meantype._&&name&i;
            %else %if &preconly %then %let var=prec_&&name&i;
            %else %let var=&meantype._&&name&i prec_&&name&i;        
       
            %if %length(&init) %then %do;
                %if &h=&stats %then %let closelast=&initclose;
            
                %if &h=1 & %length(&initappend)=0 %then 
                    %_lexport(insert=&initinsert, file=&init, data=&scratch, n=, 
                        close=&closelast, var=&var, type=&type);
                %else %_lexport(append=&init, data=&scratch, n=, 
                        close=&closelast, var=&var, type=&type);
            %end;
            %else %do;
                %let append=&file;
    
                %if &h=1 & &create=1 %then %do; 
                    %_lexport(insert=&insert, file=&file, data=&scratch, var=&var, 
                        n=%_ifelse(%length(&n), then=&n=&nobs), close=0, type=&type);
                    %let insert=;
                %end;
                %else %_lexport(append=&file, data=&scratch, n=, 
                        close=0, var=&var, type=&type);
            %end;
        %end;
        %else %do;
            proc univariate normal plot data=&data;
                var &&var&i;
                output out=&scratch
                    mean=mean_&&name&i..1-mean_&&name&i..&cols
                    var=var_&&name&i..1-var_&&name&i..&cols
                    n=n_&&name&i..1-n_&&name&i..&cols
                ;
            run;

            data &scratch;
                set &scratch;
                    
                %do j=1 %to &cols;
                    prec_&&name&i..&j=1/var_&&name&i..&j;
    
                    %if &logmeanonly %then %do;
                        %if &chain>1 %then mean_&&name&i..&j=mean_&&name&i..&j+
                            ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(mean_&&name&i..&j/n_&&name&i..&j);;
                        log_mean_&&name&i..&j=log(mean_&&name&i..&j);
                    %end;
                    %else %if &logitonly %then %do;
                        %if &chain>1 %then mean_&&name&i..&j=mean_&&name&i..&j+
                            ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(mean_&&name&i..&j*(1-mean_&&name&i..&j)/n_&&name&i..&j);;
                        logit_&&name&i..&j=log(mean_&&name&i..&j/(1-mean_&&name&i..&j));
                    %end;
                    %else %if &chain>1 %then mean_&&name&i..&j=mean_&&name&i..&j+
                        ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(var_&&name&i..&j/n_&&name&i..&j);;                   
                %end;
                
                drop n_&&name&i: var_&&name&i:
                %if &logmeanonly %then %do;
                    mean_&&name&i:;
                    %let meantype=log_mean;
                %end;
                %else %if &logitonly %then %do;
                    mean_&&name&i:;
                    %let meantype=logit;
                %end;
                %else %let meantype=mean;;
            run;

            %if &meanonly %then 
                %let var=&meantype._&&name&i..1-&meantype._&&name&i..&cols;
            %else %if &preconly %then 
                %let var=prec_&&name&i..1-prec_&&name&i..&cols;
            %else %let var=&meantype._&&name&i..1-&meantype._&&name&i..&cols 
                prec_&&name&i..1-prec_&&name&i..&cols;
       
            %if %length(&init) %then %do;
                %if &h=&stats %then %let closelast=&initclose;
            
                %if &h=1 & %length(&initappend)=0 %then 
                    %_sexport(insert=&initinsert, file=&init, data=&scratch, n=, 
                        close=&closelast, var=&var, type=&type);
                %else %_sexport(append=&init, data=&scratch, n=, 
                        close=&closelast, var=&var, type=&type);
            %end;
            %else %do;
                %let append=&file;
    
                %if &h=1 & &create=1 %then %do; 
                    %_sexport(insert=&insert, file=&file, data=&scratch, 
                        n=%_ifelse(%length(&n), then=&n=&nobs), 
                        close=0, var=&var, type=&type);
                    %let insert=;
                %end;
                %else %_sexport(append=&file, data=&scratch, n=, 
                        close=0, var=&var, type=&type);
            %end;
        %end;
    %end;
    
    %if %sysfunc(indexw(%upcase(&prob), %upcase(&&var&i))) %then %do;
        %let h=%eval(&h+1);
        %let cols=%_count(%_list(&&var&i));
        
        %do j=1 %to &cols;
            %let scratch&j=%_scratch;
    
            proc freq data=&data(keep=&&name&i..&j);
                tables &&name&i..&j / out=&&scratch&j;
            run;
        %end;
        
        %do j=1 %to &cols;
            %local n_&&name&i..&j;
            
        data &&scratch&j;
            set &&scratch&j end=eof;
            where n(&&name&i..&j);
            rename &&name&i..&j=&&name&i percent=&&name&i..&j;
            retain n_&&name&i..&j 0;
            
            percent=percent/100;
            
            n_&&name&i..&j=n_&&name&i..&j+count;
            
            if eof then call symput("n_&&name&i..&j", trim(left(n_&&name&i..&j)));
        run;
        %end;
        
        data &scratch1;
            merge %_list(&scratch1-&&scratch&cols);
            by &&name&i;
        run;
            
        %let rows=%_nobs(data=&scratch1);
        
        data &scratch1;            
            %do j=1 %to &cols;
                tot_&&name&i=0;
                
                %do k=1 %to &rows-1;
                    k=&k;
                    set &scratch1 point=k;
            
                    %if &chain>1 %then 
                    &&name&i..&j=min(1, max(0, &&name&i..&j+
                    ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(&&name&i..&j*(1-&&name&i..&j)/&&&&n_&&name&i..&j)));;
            
                    prob_&&name&i..&k=input(put(sum(&&name&i..&j, 0), &format), &format);
    
                    tot_&&name&i=tot_&&name&i+prob_&&name&i..&k;
                %end;
                               
                %if &chain>1 %then %do;
                if tot_&&name&i>1 then do;
                    put "ERROR: CHAIN=&chain results in probabilities that sum to >1."; 
                    put "       Add 1 to CHAIN and try again.";
                end;
                %end;
             
                prob_&&name&i..&rows=1-tot_&&name&i;
                output;
            %end;
            
            stop;
        run;
        
        %if %length(&init) %then %do;
            %if &h=&stats %then %let closelast=&initclose;
            
            %if &h=1 & %length(&initappend)=0 %then 
                %_sexport(insert=&initinsert, file=&init, data=&scratch1, n=, 
                    close=&closelast, var=prob_&&name&i..1-prob_&&name&i..&rows, type=&type);
            %else %_sexport(append=&init, data=&scratch1, n=, close=&closelast, 
                var=prob_&&name&i..1-prob_&&name&i..&rows, type=&type);
        %end;
        %else %do;
            %let append=&file;
            
            %if &h=1 & &create=1 %then %do;
                %_sexport(insert=&insert, file=&file, data=&scratch1, 
                    n=%_ifelse(%length(&n), then=&n=&nobs), close=0, 
                    var=prob_&&name&i..1-prob_&&name&i..&rows, type=&type);
                %let insert=;
            %end;
            %else %_sexport(append=&file, data=&scratch1, n=, close=0, 
                var=prob_&&name&i..1-prob_&&name&i..&rows, type=&type);
        %end;
    %end;
%end;

%if &chain=1 %then %do;
    %do i=1 %to &var0;
        proc format;
            value _&i._
                ._, .A-.Z, .='NA'
                other=[&&format&i]
            ;
        run;
    %end;
    
    data _null_;
    %if "&append"="REQUIRED" %then %do;     
        file "&file" linesize=&ls;
        
        put 
            %if "&type"="R" | "&type"="S" %then "%lowcase(%trim(&out)) <- list(";
            %else %if "&type"="BUGS" %then "list(";
            
            %if %length(&n) %then %do;
                %if "&type"="BUGS" %then %do;
                    %if %index(&n, =) %then "%upcase(&n), ";
                    %else "&n=&nobs, ";
                %end;
                %else "`&n` <- &nobs";
            %end;
        ;
    %end;
    %else file "&file" linesize=&ls mod;;
    
    %if %length(&insert) %then %do;
        put %if "&type"="JAGS" %then %do;
                %let k=%_count(&insert, split=/);
            
                %do j=1 %to &k-1;
                    "%left(%scan(&insert, &j, /))" /
                %end; "%left(%scan(&insert, &k, /))"
            %end;
            %else "&insert,";;
    %end;
            
    %do i=1 %to &var0;
        %if "&type"="JAGS" %then %do;
            put "`%_tr(&&name&i, from=_, to=.)` <- " /
                %if &nobs>1 %then "structure(c(";
                %else "c("; 
            @;
        
            %let jags0=%_count(%_list(&&var&i));
            
            %do j=1 %to &jags0;
                %local jags&j;
                %let jags&j=%scan(%_list(&&var&i), &j, %str( ));
                
                do i=1 to &nobs;
                    set &data(keep=&&jags&j) point=i;
            
                    put &&jags&j _&i._.-r @;
            
                    %if &j=&jags0 %then %do;
                        if i=&nobs then put ')' @;
                        else
                    %end; put ',' @;
                end;                
            %end;
    
            put %if &nobs>1 %then ", .Dim = c(&nobs.L, %_count(%_list(&&var&i))L))";; 
        %end;
        %else %do;
            put "%_tr(&&name&i, from=_, to=.) = "
                %if &nobs>1 %then "structure(.Data = c(";
                %else "c("; 
            @;
        
            do i=1 to &nobs;
                set &data(keep=&&var&i) point=i;
            
                put (&&var&i) (_&i._. ',') @;
            
                if i=&nobs then put
                    %if &nobs>1 %then '), ';
                    %else ')';
                @;
                else put ',' @;
            end;
    
            put %if &nobs>1 %then %do;
                    %if "&type"="S" %then ".Dim = c(%_count(%_list(&&var&i)), &nobs))";
                    %else ".Dim = c(&nobs, %_count(%_list(&&var&i))))";
                %end;
        
                %if &i=&var0 & &close=1 %then ')';
                %else ',';
            ; 
        %end;
    %end;
        
        stop;
    run;
%end;

%let syslast=&savelast;
%if %length(&log) %then %_printto;

%mend _sexport;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
            
data matrix;
    input col1-col5;
    datalines;
    1 2 3 4 5
    6 7 8 9 10
    3 . . 1 1
    . 3 1 . .
run;

%_sexport(data=matrix, var=col1-col5, file=_sexport.txt, format=2., 
    mean=col1-col5, prec=col1-col5, prob=col1-col5);
%*_sexport(data=matrix, var=col1-col5, file=_sexport.s, type=s+);
*/

