%put NOTE: You have called the macro _DECODA, 2009-02-17;
%put NOTE: Copyright (c) 2001-2009 Rodney Sparapani;
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

/* _DECODA Documentation
    Creates a SAS dataset from CODA files and provides summaries 
    if requested.
                
    REQUIRED Parameters  

    INFILE=                    CODA index file 
                               (NAMEIndex.txt, NAME.ind or NAME.ind.txt)
                               if you are combing multiple runs, then this
                               can be a list of files separated by the
                               SPLIT character
                
    FILE=INFILE                alias
                
    OUT=                       SAS dataset created
                            
    Specific OPTIONAL Parameters

    ALPHA=0.025                default significance level for
                               the Brooks-Gelman-Rubin test (one-tailed)
                                                        	    
    AUTOCORR=0                 autocorrelation statistics are not 
                               calculated unless AUTOCORR NE 0 
                               if SAS/ETS is installed, then it may 
			       be set to a list of chains, but
                               the output will be lengthy
                               AUTOCORR=1 for the first chain should
                               be sufficient in most instances
			       if GRAPHICS=1, then autocorrelations
			       are presented as graphs and the 
			       output is suppressed

    CHAINS=                    the number of CODA chain files
                               (NAME#.txt, NAME#.out or NAME#.out.txt)
                
    CHAIN#=                    if the CODA chain files do not follow the
                               standard naming convention, then you
                               must manually list them here (up to 10), also
                               if you are combing multiple runs, then this
                               must be a list of files separated by the
                               SPLIT character
                                
    CONTENTS=1                 by default, PROC CONTENTS
                               set to zero to over-ride
                                
    CROSSCORR=1                crosscorrelation statistics are not 
                               calculated unless CROSSCORR NE 0 
                               (SAS/ETS does NOT need to be installed) 
                               it may be set to a list of chains, but
                               the output will be lengthy
                               CROSSCORR=1 for the first chain should
                               be sufficient in most instances
                            
    DISCRETE=                  list of variables that are discrete
                               for summarization of the mode by the
			       PROC UNIVARIATE option MODES

    DROP=                      list of variables to drop from OUT=
                               besides actual variable names, you may 
                               also specify logical names like a[5]
                               which makes those vector positions missing
                               resulting in no summaries of them
                                
    EXP=                       list of variables that are logarithms base e
                               from which to create exponentiated variables
                               (EXP_VAR): useful for OR/RR/etc.
                            
    GRAPHICS=1                 if statistics are requested, then produce
                               graphics as well (v. 8 or higher only)
                            
    GSFMODE=REPLACE            default GSFMODE for first graph
                
    LOG=                       list of variables that are exponentiated base e
                               from which to create natural logarithm variables
                               (LOG_VAR)

    MARKER=0.5                 position to divide the sample into two parts 
                               expressed as a proportion <1 or an iteration 
                               number >1 :  the first part for burn-in and
                               the second for convergence testing and parameter 
                               estimation (assuming convergence holds)
                               set to blank to over-ride burn-in removal

    MU0=0                      default location for tests/tables

    NLAG=25                    default of up to 25 lag auto-correlation
                               if AUTOCORR NE 0

    OPTIONS=                   options to PROC UNIVARIATE
                
    PCTLDEF=5                  default percentile definition
                
    PCTLPTS=2.5 97.5           default percentiles to calcuate and present
       
    SPLIT=|                    default SPLIT character, do not use ampersand,
                               comma, parentheses, percent, etc. (macro-related
                               syntax characters not welcome)
                                
    SYMBOL=i=join v=none r=1   default SYMBOL statement for trace plots

    STATS=VAR		       alias

    TAIL=out                   default file extension for CODA chain files
                               (NAME.TAIL or NAME#.TAIL)
                
    THIN=1                     default thinning parameter, set to an integer
                               >1 for only keeping iterations where
                               MOD(ITER, THIN)=0
			       note that thinning can also be employed 
			       with MH sampling to remove stalls
                                
    TRACE=1		       default to produce trace plots 

    TYPE=                      if you set this parameter, then TYPE will be
                               used to name the graphics file (VAR.TYPE) for 
                               each summarized variable/vector
                
    VAR=                       list of variables to summarize/graph, if any
                               use _all_ for all variables
    
    WIDTH=4                    default width for graphics                

    WHERE=                     restrict the data with a WHERE clause,
                               useful for removing burn-in,
                               i.e. WHERE=iter>4000
                               see THIN= also
    
*/
                            
%macro _decoda(infile=REQUIRED, file=&infile, out=REQUIRED, alpha=0.025, autocorr=0, 
    chains=, contents=1, crosscorr=1, debug=, discrete=, drop=, exp=, graphics=%_version(8), 
    gsfmode=replace, marker=0.5, mu0=0, nlag=25, options=, pctldef=5, pctlpts=2.5 97.5, 
    split=|, symbol=i=join v=none r=1, stats=, tail=out, thin=1, trace=1, type=, 
    var=&stats, where=, width=4, log=, chain1=, chain2=, chain3=, chain4=, chain5=, 
    chain6=, chain7=, chain8=, chain9=, chain10=);
    
    %_require(&out &file);

    %local i j head nobs scratch explabel loglabel dsid nvars nexp nlog ndrop offset runs;
    
    %if %length(&chains)=0 %then %let chains=%_count(&chain1 &chain2 
        &chain3 &chain4 &chain5 &chain6 &chain7 &chain8 &chain9 &chain10);
        
    %if &chains=0 %then %let chains=1;
    
    %do i=1 %to &chains;
        %if %length(&&chain&i)=0 %then %do;
            %let j=%index(&file, Index.txt);
            
            %if &j %then %let head=%_substr(&file, 1, &j-1);
            %else %let head=%scan(&file, 1, .);

            %if &chains=1 %then %do;            
                %let chain1=&head..&tail;
            
                %if %_exist(&chain1)=0 %then %do;
                    %let chain1=&head..out;
            
                    %if %_exist(&chain1)=0 %then %do;
                        %let chain1=&head..out.txt;
            
                        %if %_exist(&chain1)=0 %then %let chain1=&head..txt;
                    %end;
                %end;
            %end;
            %else %do;
                %let chain&i=&head.&i..&tail;
            
                %if %_exist(&&chain&i)=0 %then %do;
                    %let chain&i=&head.&i..out;
                
                    %if %_exist(&&chain&i)=0 %then %do;
                        %let chain&i=&head.&i..out.txt;
            
                        %if %_exist(&&chain&i)=0 %then %do;
                            %let chain&i=&head.&i..txt;
                         %end;
                    %end;
                %end;
            %end;                       

            %if %_exist(&&chain&i)=0 %then %do;
                %put ERROR: Chain file(s) not found, specify manually by CHAIN1=, etc.;
                %_abend;
            %end;
        %end;
        
        %let runs=%_count(&file, split=&split);
            
        %do j=1 %to &runs;
            %local run&j;
            %let run&j=%_scratch;
            
        data &&run&j;
            infile "%scan(&&chain&i, &j, ''""&split)" dlm='090D20'x end=last;
            input iter value;
            
            %if &j>1 %then %do;
                drop offset;
                retain offset;
                
                if _n_=1 then offset=&offset-iter+1;
                
                iter=iter+offset;
            %end;
                                
            if last then call symput('offset', trim(left(iter)));;
        run;

        %let nobs=%_nobs(data=&&run&j);
        
        data &&run&j;
	    length var label index1 index2 $ 32;
            drop start stop index1 index2;
	    infile "%scan(&file, &j, ''""&split)" dlm='090D20'x missover;
	    input var start stop;
        
            retain chain &i;
                
            obs=index(var, "[");
                
            if obs then do;
                index1=scan(var, 2, "[,]");
                index2=scan(var, 3, "[,]");
                var=scan(var, 1, "[,]");
                obs=index1;
                
                if index2>'' then do;
                    label=trim(var)||'[obs,'||trim(index2)||']';
                    var=trim(var)||index2;
                end;
                else label=trim(var)||'[obs]';
            end;
            
            var=lowcase(translate(var, '_', '.'));
        
            if stop>&nobs then goto error;
            else do row=start to stop by &thin;
                %*prev=value;
                set &&run&j point=row;
            
                %if &i=1 & &j=1 & %length(&marker) & %sysevalf(&marker<=1) %then 
		    if row<=((stop-start)*&marker) then call symput('marker', trim(left(iter)));;
		/*
                else %if %length(&discrete) %then %do;
                    %let discrete=%lowcase(&discrete);
                    if var not in("%scan(&discrete, 1, %str( ))"
                    %do k=2 %to %_count(&discrete);
                        , "%scan(&discrete, &k, %str( ))"
                    %end; ) then                        
                %end; repeat=(fuzz(value-prev)=0);
		*/
                
                output;
            end;
            
            return;
            
            error:
            
            put 'ERROR: POINT > NOBS ' start= stop=;
            stop;
        run;
    
        proc sort data=&&run&j out=&&run&j;
            where &where;
            by obs iter var;
        run;
        %end;
            
        %local data&i;
        
        %if &chains=1 %then %let data1=&out;
        %else %let data&i=&run1;
        
        %if &runs>1 %then %do;
            data &&data&i;
                set %do j=1 %to &runs; &&run&j %end;;
                by obs iter var;
            run;
        %end;
    %end;
            
    %if &chains>1 %then %do;
    data &out;
        set %do i=1 %to &chains; &&data&i %end;;
        by obs chain iter var; %*weight;
    run;
    %end;
     
    proc transpose data=&out out=&out(drop=_name_ sortedby=obs chain iter 
        %if %length(&exp)=0 & %length(&log)=0 %then index=(ci=(chain iter));
        );
        by obs chain iter; %*weight;
        var value;
        id var;
        idlabel label;
    run;

    %if %length(&exp) | %length(&log) | %length(&drop) %then %do;
        %let exp=%lowcase(%_blist(data=&out, var=&exp));
        %let log=%lowcase(%_blist(data=&out, var=&log));
        %let nexp=%_count(&exp);
        %let nlog=%_count(&log);
        %let ndrop=%_count(&drop);
        %let dsid=%sysfunc(open(&out));
        %let nvars=%sysfunc(attrn(&dsid, nvars));

        %do j=1 %to &nvars;
            %local var&j;
            %let var&j=%lowcase(%sysfunc(varname(&dsid, &j)));
        
            %do i=1 %to &nexp;
                %if &j=1 %then %do;
                    %local exp&i;
                    %let exp&i=%scan(&exp, &i, %str( ));
                %end;
                
                %if "&&var&j"="&&exp&i" %then
                    %let explabel=&explabel exp_&&var&j="exp(%sysfunc(varlabel(&dsid, &j)))";
            %end;
            
            %do i=1 %to &nlog;
                %if &j=1 %then %do;
                    %local log&i;
                    %let log&i=%scan(&log, &i, %str( ));
                %end;
                
                %if "&&var&j"="&&log&i" %then
                    %let loglabel=&loglabel log_&&var&j="log(%sysfunc(varlabel(&dsid, &j)))";
            %end;            
        %end;
    
        %let dsid=%sysfunc(close(&dsid));
    
        data &out(sortedby=obs chain iter index=(ci=(chain iter)));
            set &out;
        
            label &explabel &loglabel;
            
            %do i=1 %to &ndrop;
                %local drop&i obs&i;
                %let drop&i=%scan(&drop, &i, %str( ));
                %let obs&i=%scan(&&drop&i, 2, []);
                %let drop&i=%scan(&&drop&i, 1, []);
            
                %if %length(&&obs&i) %then if obs=&&obs&i then;
                %else %do;
                    drop &&drop&i;
                %end; 
                
                &&drop&i=.;
            %end;
            
            %if &ndrop %then if n(of _numeric_)=3 then delete;;
            
            %do i=1 %to &nexp;
                if n(&&exp&i) then exp_&&exp&i=exp(&&exp&i);
            %end;
         
            %do i=1 %to &nlog;
                if n(&&log&i) then log_&&log&i=log(&&log&i);
            %end;      
        run; 
    %end;
    
    %if &contents %then %do;
    proc contents;
    run;
    %end;

    %if %length(&var) %then %_debugs(data=&out, var=&var, alpha=&alpha, autocorr=&autocorr, 
            chains=&chains, crosscorr=&crosscorr, debug=&debug, discrete=&discrete, graphics=&graphics, 
            gsfmode=&gsfmode, marker=&marker, mu0=&mu0, nlag=&nlag, options=&options, 
            pctldef=&pctldef, pctlpts=&pctlpts, symbol=&symbol, trace=&trace, type=&type, 
            width=&width);

    %if %length(&marker) %then %do;
    data &out(sortedby=obs chain iter index=(ci=(chain iter)));
	set &out;
	where iter>&marker;
    run;
    %end;
    %else %let syslast=&out;
%mend _decoda;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

%_decoda(out=mydata, chains=2, infile=head.txt);

*/
