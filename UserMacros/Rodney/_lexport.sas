%put NOTE: You have called the macro _LEXPORT, 2009-02-17.;
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

/* _LEXPORT Documentation
    Export a BUGS, JAGS or R/S/S+ data file of vectors from a SAS Dataset.
    Many recent changes/improvements are not also reflected in _SEXPORT;
    for the time-being, _LEXPORT and _SEXPORT will be out-of-synch until
    a comprehensive set of features/bug-fixes have been decided upon.
    
    REQUIRED Parameters  

    FILE=                   file to create
    
    VAR=                    list of variables to be included
                            
    Specific OPTIONAL Parameters
                            
    APPEND=                 append to data file, instead of creating
      
    CENTER=                 list of variables to center, i.e. their new mean is zero
                            
    CHAIN=1                 If CHAIN=1, then generate data file and init file,
                            if any.  Otherwise, generate init file only.
                            default number of chains to sample
                            MEAN/PROB summaries are unaltered by default
                            however, if CHAIN>1, they are calculated 
                            analogously to the chain initializations 
                            of the SAS Bayesian Procedures, i.e. 
                            MEAN+((-1)^(CHAIN-1))*(2+FLOOR(CHAIN/2))*SE
                            
    CLOSE=1                 defaults to closing data file on exit
                            
    FORMAT=best12.          default format for variables
                            
    INIT=                   default for data file creation rather
                            than an init file, set to a file name to
                            be created to over-ride
                            
    INITAPPEND=             append to init file, instead of creating
    
    INITCLOSE=1             defaults to closing init file on exit
        
    INITINSERT=             values to insert into INIT, see INSERT below
                            
    INSERT=                 values to insert into FILE, for TYPE=JAGS
                            / force out linefeeds
                            
    DATA=_LAST_             default SAS dataset used

    LINESIZE=80             default line length

    LOGBASE=e               default logarithm base for MEANLOG= option
                            
    LOGMEAN=                list of continuous and/or discrete variables
                            to compute the natural logarithm of the mean for
                            mutually exclusive option:  only provide one of 
                            LOGIT=, LOGMEAN=, MEAN= or MEANLOG= per variable)
                            
    LOGIT=                  list of indicator variables to compute the logit of the mean
                            for (mutually exclusive option:  only provide one of 
                            LOGIT=, LOGMEAN=, MEAN= or MEANLOG= per variable)
    
    LS=LINESIZE             alias
                            
    MEAN=                   list of continuous and/or discrete variables to compute the mean 
                            for (mutually exclusive option:  only provide one of 
                            LOGIT=, LOGMEAN=, MEAN= or MEANLOG= per variable)
                            
    MEANLOG=                list of continuous and/or discrete variables to compute the mean
                            of the logarithm for (mutually exclusive option:  only provide one of 
                            LOGIT=, LOGMEAN=, MEAN= or MEANLOG= per variable)
                            
    N=N                     default name of variable for number of
                            observations, set to blank for none
                            
    OUT=DATA                default name of object
                            
    PREC=                   list of continuous variables
                            to compute the precision for
                            
    PROB=                   list of discrete variables
                            to compute the probability for

    STANDARD=               additional options to pass to PROC STANDARD when you are
                            centering variables with CENTER=
                            
    TYPE=BUGS               by default create BUGS-style file
                            unless the file name extension starts with:
                            .dump, .dmp (for JAGS), .r, .R (for R), .s or .S (for S/S+) 
                            to over-ride:
                            set to JAGS for JAGS
                            set to R for R 
                            set to S or S+ for S/S+
    
    Common OPTIONAL Parameters
    
    LOG=                    set to /dev/null to turn off .log                            
*/

%macro _lexport(append=REQUIRED, file=&append, var=REQUIRED, data=&syslast, 
    center=, chain=1, close=1, format=best12., initappend=, init=&initappend, 
    initclose=1, initinsert=, insert=, linesize=80, logbase=e, logit=, logmean=, 
    ls=&linesize, mean=, meanlog=, n=N, out=&data, prec=, prob=, standard=, 
    type=BUGS, log=);

%_require(&file &var);

%if %length(&log) %then %_printto(log=&log);

%local nobs h i j k arg args var0 create miss scratch meanonly preconly savelast 
    stats closelast /*centerdata*/ logitonly logmeanonly meantype temp;

%let file=%scan(&file, 1, ''"");
%let type=%upcase(&type);
%let data=%upcase(&data);
%let savelast=&syslast; 

%if "&type"="BUGS" %then %do;
    %if %index(%lowcase(&file),.dump) %then %let type=JAGS;
    %else %if %index(%lowcase(&file),.dmp) %then %let type=JAGS;
    %else %if %index(%lowcase(&file),.r) %then %let type=R;
    %else %if %index(%lowcase(&file),.s) %then %let type=S;
%end;
%else %if "&type"="S+" %then %let type=S;
    
%if "&type"="R" | "&type"="S" %then %let n=;

%let nobs=%_nobs(data=&data);
%let var=%_blist(&var, data=&data);
%let prob=%_blist(&prob, data=&data, nofmt=1);
%let prec=%_blist(&prec, data=&data, nofmt=1);
%let mean=%_blist(&mean, data=&data, nofmt=1);
%let meanlog=%_blist(&meanlog, data=&data, nofmt=1);
%let logmean=%_blist(&logmean, data=&data, nofmt=1);
%let logit=%_blist(&logit, data=&data, nofmt=1);
%let args=%_count(&var);

%let var0=0;

%do i=1 %to &args;
    %let arg=%scan(&var, &i, %str( ));
    
    %if %index(&arg, .) %then %let format&var0=&arg;
    %else %do;
        %let var0=%eval(&var0+1);
        %local var&var0 format&var0;
        %let var&var0=&arg;
        %let format&var0=&format;
    %end;  
%end;

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

%let mean=&mean &meanlog &logmean &logit;
%let stats=%_count(&mean &prec &prob);
%let closelast=0;
%let h=0;

%if %length(&center) %then %do;
    %let scratch=%_scratch;
    
    proc standard mean=0 &standard data=&data out=&scratch;
        var &center;
    run;
    
    %let data=&scratch;
%end;

%if %length(&meanlog) %then %do;
    %let logbase=%upcase(&logbase);
    %let scratch=%_scratch;
    
    data &scratch;
        set &data;
        
        %do i=1 %to %_count(&meanlog);
            %let temp=%scan(&meanlog, &i, %str( ));
            
            %if "&logbase"="E" %then &temp=log(&temp);
            %else %if "&logbase"="2" | "&logbase"="10" %then &temp=log&logbase(&temp);
            %else %if "%datatyp(&logbase)"="NUMERIC" %then &temp=log(&temp)/log(&logbase);;
        %end;
    run;
    
    %let data=&scratch;
%end;

%do i=1 %to &var0;
/*
    %if %sysfunc(indexw(%upcase(&center), %upcase(&&var&i))) %then %do;
        %let scratch=%_scratch;
        %let centerdata=&centerdata &scratch;
    
        proc univariate noprint data=&data;
            var &&var&i;
            output out=&scratch mean=_mean_&&var&i;
        run;
    %end;
    %else %let centerdata=&centerdata notcentered;
*/
                            
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
    
        proc univariate normal plot data=&data;
            var &&var&i;
            output out=&scratch mean=mean_&&var&i var=var_&&var&i n=n_&&var&i;
        run;
             
        data &scratch;
            set &scratch;
            prec_&&var&i=1/var_&&var&i;
    
            %if &chain>1 %then %do; 
                %if &logitonly %then mean_&&var&i=mean_&&var&i+
                    ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(mean_&&var&i*(1-mean_&&var&i)/n_&&var&i);
                %else %if &logmeanonly %then mean_&&var&i=mean_&&var&i+
                    ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(mean_&&var&i/n_&&var&i);
                %else mean_&&var&i=mean_&&var&i+
                    ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(var_&&var&i/n_&&var&i);;      
            %end;                

            drop n_&&var&i var_&&var&i
            %if &logmeanonly %then %do;
                mean_&&var&i;
                log_mean_&&var&i=log(mean_&&var&i)
                %let meantype=log_mean;
            %end;                
            %else %if &logitonly %then %do;
                mean_&&var&i;
                logit_&&var&i=log(mean_&&var&i/(1-mean_&&var&i))
                %let meantype=logit;
            %end;
            %else %let meantype=mean;;
        run;   
        
        %if &meanonly %then %let var=&meantype._&&var&i;
        %else %if &preconly %then %let var=prec_&&var&i;
        %else %let var=&meantype._&&var&i prec_&&var&i;
        
        %if %length(&init) %then %do;
            %if &h=&stats %then %let closelast=&initclose;
            
            %if &h=1 & %length(&initappend)=0 %then 
                %_lexport(insert=&initinsert, file=&init, data=&scratch, var=&var, n=, 
                    close=&closelast, type=&type);
            %else %_lexport(append=&init, data=&scratch, var=&var, n=, 
                    close=&closelast, type=&type);
        %end;
        %else %do;
            %let append=&file;
                
            %if &h=1 & &create=1 %then %do;
                %_lexport(insert=&insert, file=&file, data=&scratch, var=&var, 
                    n=%_ifelse(%length(&n), then=&n=&nobs), close=0, type=&type);
                %let insert=;
            %end;
            %else %_lexport(append=&file, data=&scratch, var=&var, n=, 
                    close=0, type=&type);
        %end; 
    %end;

    %if %sysfunc(indexw(%upcase(&prob), %upcase(&&var&i))) %then %do;
        %let h=%eval(&h+1);
        %let scratch=%_scratch;
        
        proc freq data=&data;
            tables &&var&i / out=&scratch;
        run;
        
        %local n_&&var&i;
        
        data &scratch;
            set &scratch end=eof;
            where n(&&var&i);
            retain n_&&var&i 0;
            
            percent=percent/100;
            
            n_&&var&i=n_&&var&i+count;
            
            if eof then call symput("n_&&var&i", trim(left(n_&&var&i)));
        run;
        
        %let miss=%_nobs(data=&scratch);
        
        data &scratch;
            drop total percent;
            total=0;
            
            %do j=1 %to &miss-1;
                j=&j;
                set &scratch point=j;
                
                %if &chain>1 %then 
                percent=min(1, max(0, percent+
                    ((-1)**(&chain-1))*(2+floor(&chain/2))*sqrt(percent*(1-percent)/&&&&n_&&var&i)));;
                
                percent=input(put(percent, &format), &format);
                total=total+percent;
                prob_&&var&i..&j=percent;
            %end;
            
            %if &chain>1 %then %do;
                if total>1 then do;
                    put "ERROR: CHAIN=&chain results in probabilities that sum to >1."; 
                    put "       Add 1 to CHAIN and try again.";
                end;
            %end;
            
            prob_&&var&i..&miss=1-total;
            output;
            stop;
        run;
        
        %if %length(&init) %then %do;
            %if &h=&stats %then %let closelast=&initclose;
            
            %if &h=1 & %length(&initappend)=0 %then 
                %_sexport(insert=&initinsert, file=&init, data=&scratch, n=, close=&closelast,
                    var=prob_&&var&i..1-prob_&&var&i..&miss, type=&type);
            %else %_sexport(append=&init, data=&scratch, n=, close=&closelast,
                    var=prob_&&var&i..1-prob_&&var&i..&miss, type=&type);
        %end;
        %else %do;
            %let append=&file;
        
            %if &h=1 & &create=1 %then %do; 
                %_sexport(insert=&insert, file=&file, data=&scratch, 
                    n=%_ifelse(%length(&n), then=&n=&nobs), close=0,
                    var=prob_&&var&i..1-prob_&&var&i..&miss, type=&type);
                %let insert=;
            %end;
            %else %_sexport(append=&file, data=&scratch, n=, close=0,
                    var=prob_&&var&i..1-prob_&&var&i..&miss, type=&type);
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
        
        %if %length(&n) & &var0>1 %then %do;
            put %do i=1 %to &var0-1; "#&&var&i, " %end; "#&&var&var0";
        %end;
    
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
        put %if "&type"="JAGS" %then "`%_tr(&&var&i, from=_, to=.)` <- " /;
            %else "%_tr(&&var&i, from=_, to=.) = ";
            @;          

        %if &nobs>1 %then put "c(";;
        
/*
        %if %sysfunc(indexw(%upcase(&center), %upcase(&&var&i))) %then %do;
            if _n_=1 then set %scan(&centerdata, &i, %str( )) point=_n_;
        %end;
*/
        
        do i=1 to &nobs;
            set &data(keep=&&var&i) point=i;
            
            %*if %sysfunc(indexw(%upcase(&center), %upcase(&&var&i))) %then 
                if n(&&var&i) then &&var&i=&&var&i-_mean_&&var&i;;
            
            if i=&nobs then put &&var&i _&i._.-r
                %if "&type"="JAGS" %then %do;
                    %if &nobs>1 %then ')';
                    %else ' ';
                %end;
                %else %if &i<&var0 %then %do;
                    %if &nobs>1 %then '), ';
                    %else ', ';
                %end;
                %else %do;
                    %if &nobs>1 %then %do;
                        %if &close=1 %then '))';
                        %else '),';
                    %end;
                    %else %if &close=1 %then ')';
                    %else ',';
                %end;
            ;
            else put &&var&i _&i._.-r ',' @;
        end;
    %end;

        stop;
    run;
%end;

%let syslast=&savelast;
%if %length(&log) %then %_printto;

%mend _lexport;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate
%_limport(infile=/usr/local/doc/jags/examples/vol1/rats/ratsmiss-data.R, file=ratmis.sas, out=ratmis);

proc print data=_last_;
run;
    
%_lexport(file=_lexport.txt, data=ratmis, format=3., var=x y, prob=x, mean=x y, prec=y);
*/

