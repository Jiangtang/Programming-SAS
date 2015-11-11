%put NOTE: You have called the macro _DEBUGS, 2009-02-19;
%put NOTE: Copyright (c) 2007-2009 Rodney Sparapani;
%put;

/*
Author:  Rodney Sparapani <rsparapa@mcw.edu>
Created: 2007-10-10

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

/* _DEBUGS Documentation
    Reads a SAS dataset and provides summaries as requested.            

    REQUIRED Parameters  

    DATA=REQUIRED              SAS input dataset
                            
    VAR=REQUIRED               list of variables to summarize/graph
                               use _all_ for all
                
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
                            
    CHAIN=CHAIN                default name of chain variable,
                               set to blank for none

    CHAINS=1                   default number of chains sampled
                               if CHAINS>1, calculate Gelman-Rubin statistic    
                                
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

    GRAPHICS=1                 if statistics are requested, then produce
                               graphics as well (v. 8 or higher only)
                            
    GSFMODE=REPLACE            default GSFMODE for first graph
                
    ITER=ITER                  default name of iteration variable,
                               set to blank for none
                                
    MARKER=                    iteration number corresponding to the
                               position that divides the sample
                               into two parts:  the first part for burn-in,
                               the second for convergence testing and parameter
                               estimation (assuming convergence holds)

    MU0=0                      default location for tests/tables

    NLAG=25                    default of up to 25 lag auto-correlation
                               if AUTOCORR NE 0
                            
    OBS=OBS		       default name of obs variable, 
		               set to blank for none

    OPTIONS=                   options to PROC UNIVARIATE
                
    OUT=                       dataset created by THIN>1 and/or WHERE= clause

    PCTLDEF=5                  default percentile definition
                
    PCTLPTS=2.5 97.5           default percentiles to calcuate and present
         
    SYMBOL=i=join v=none r=1   default SYMBOL statement for trace plots

    THIN=1                     default thinning parameter, set to an integer
                               >1 for only keeping iterations where
                               MOD(ITER, THIN)=0                   
             
    TRACE=1                    default to produce trace plots

    TYPE=                      if you set this parameter, then TYPE will be
                               used to name the graphics file (VAR.TYPE) for 
                               each summarized variable/vector
    
    WIDTH=4                    default width for graphics
                            
    WHERE=                     restrict the data with a WHERE clause,
                               useful for removing burn-in,
                               i.e. WHERE=iter>4000
*/
                            
%macro _debugs(data=REQUIRED, var=REQUIRED, alpha=0.025, autocorr=0, 
    chain=chain, chains=1, crosscorr=1, debug=, discrete=, graphics=%_version(8), 
    gsfmode=replace, iter=iter, marker=, mu0=0, nlag=25, obs=obs, options=, 
    out=, pctldef=5, pctlpts=2.5 97.5, symbol=i=join v=none r=1, thin=1, 
    trace=1, type=, where=, width=4);
    
    %_require(&data &var);

    %local i j k l m scratch scratch0 lag nobs cl95 list bgr;
                        
	%*let chain=%upcase(&chain);
	%*let iter=%upcase(&iter);
	%*let obs=%upcase(&obs);
	%*let weight=%upcase(&weight);
        %*let var=%upcase(%_blist(var=&var, data=&data, nofmt=1));
        %let var=%_blist(var=&var, data=&data, nofmt=1);
            
        %if %_count(&pctlpts)=1 %then 
            %let pctlpts=&pctlpts %sysevalf(100-&pctlpts);
    
        %if &thin>1 | %length(&where) %then %do;
	    %if %length(&out)=0 %then %let out=%_scratch;

	    data &out(index=(ci=(chain iter)));
		set &data;	
		by obs chain iter;

		%if &thin>1 & %length(&where) %then where &where & mod(&iter, &thin)=0;
		%else %if &thin>1 %then where mod(&iter, &thin)=0;
		%else where &where;;
	    run;
	%end;
	%else %let out=&data;
                
        %let scratch=%_scratch;

        %let j=0;
        
        %do i=1 %to %_count(&var);
	    %local var&i;
            %let var&i=%scan(&var, &i, %str( ));
                            
	    %if "%upcase(&&var&i)"^="%upcase(&obs)" & "%upcase(&&var&i)"^="%upcase(&chain)" & 
                "%upcase(&&var&i)"^="%upcase(&iter)" %then %do;
                
                %let j=%eval(&j+1);
                %let list=&list &&var&i;
                
                %if &graphics %then %do;
		    symbol1 &symbol width=&width;
    
                    %if %length(&type) %then filename gsasfile "%lowcase(&&var&i).&type";;
                     
                    %if &j=1 %then goptions gsfmode=&gsfmode;
                    %else goptions gsfmode=append;;
                %end;
        
            proc univariate loccount mu0=&mu0 normal pctldef=&pctldef plot
		%if %sysfunc(indexw(%upcase(&discrete), %upcase(&&var&i))) %then modes; 
                &options data=&out(keep=&obs &chain &iter &&var&i 
		where=(n(&&var&i) %if %length(&marker) %then & &iter>&marker; ));
                
                id &chain &iter;
                by &obs;
                var &&var&i;
                output out=&scratch pctlpre=&&var&i.._ pctlpts=&pctlpts;
                
                %if &graphics %then histogram &&var&i / kernel;;
            run;
                
            proc print noobs data=&scratch;
            run;

            %if &chains>1 %then %do;
                proc univariate noprint data=&out(keep=&obs &chain &iter &&var&i
		    where=(&chain=1 & n(&&var&i)));
                    by &obs;
                    var &iter;
                    output out=&scratch pctlpre=_ pctlpts=0 to 100 by 2.5;
	    	run;    
                        
                %do k=1 %to 40;
                    %local start&k stop&k; 
                %end;
                
                data _null_;
                    set &scratch;
                    array _pctlpts(41) _0 _2_5 _5 _7_5 _10 _12_5 _15 _17_5 _20 _22_5 _25 _27_5 _30
                        _32_5 _35 _37_5 _40 _42_5 _45 _47_5 _50 _52_5 _55 _57_5 _60 _62_5 _65
                        _67_5 _70 _72_5 _75 _77_5 _80 _82_5 _85 _87_5 _90 _92_5 _95 _97_5 _100;
                    do k=1 to 20;
                        call symput('start'||left(k), trim(left(_pctlpts(k+1))));
                        call symput('stop' ||left(k), trim(left(_pctlpts(2*k+1))));
                    end;
                    stop;
                run;

		%let bgr=%_scratch;

		data &bgr;
		    set &scratch(keep=&obs);
		    retain k v 0; 
		run;

                %do k=1 %to 20;
	        proc univariate noprint data=&out(keep=&obs &chain &iter &&var&i
		    where=(n(&&var&i) & &&start&k<&iter<=&&stop&k ));
                    by &obs &chain;
                    var &&var&i;
                    output out=&scratch mean=mean_&&var&i var=var_&&var&i;
	    	run;    

                data &scratch;
                    set &scratch;
                    meansq_&&var&i=mean_&&var&i**2;
                run;
            
                %let scratch0=%_scratch;
            
                proc corr cov noprint data=&scratch outp=&scratch0;
                    by &obs;
                    var mean_&&var&i meansq_&&var&i var_&&var&i;
                run;
                
                proc glm noprint data=&out(keep=&obs &chain &iter &&var&i
		    where=(n(&&var&i) & &&start&k<&iter<=&&stop&k )) outstat=&scratch;
                
                    by &obs;
                    class &chain;
                    model &&var&i=&chain;
                run;
                
                data &scratch;
                    merge 
			&scratch0(keep=&obs _type_ _name_ var_&&var&i
		            where=(_type_='COV' & upcase(_name_)=upcase("MEAN_&&var&i"))
			    rename=(var_&&var&i=cov_mean_var_&&var&i))
			&scratch0(keep=&obs _type_ _name_ meansq_&&var&i var_&&var&i
		            where=(_type_='COV' & upcase(_name_)=upcase("VAR_&&var&i"))
			    rename=(var_&&var&i=var_var_&&var&i
				    meansq_&&var&i=cov_meansq_var_&&var&i))
			&scratch0(keep=&obs _type_ mean_&&var&i
		            where=(_type_='MEAN') 
                            rename=(mean_&&var&i=mean_mean_&&var&i))
			&scratch(where=(_type_ in('ERROR', 'SS1')))
                    ;
		    by &obs;
		    drop _type_ _name_ _source_ ss df f prob mp1 mm1 nm1 ntm dp1 dp3;
    
                    label
                         Rc     ="BGR for &&var&i"
                         RcUpper="&alpha cutoff under the null"
                         RcTest ="Test of the null (convergence)"
                         v      ='sqrt(V)'
                         w      ='sqrt(W)'
                    ;
                    
                    retain n b w;
                
                    if first.&obs then n=df+1;
                    else n=n+df;
                
                    if _type_='ERROR' then w=ss/df;
                    else b=ss/df;
                
                    if last.&obs & w>0 then do;
                        m=&chains;
                        mp1=%eval(&chains+1);
                        mm1=%eval(&chains-1);
                        ntm=n;
                        n=n/m;
                        nm1=n-1;
                        v=(nm1*w/n)+(mp1*b/ntm);
 
                        var_v=(((nm1/n)**2)*var_var_&&var&i/m)+
                            2*(((((mp1*b)/ntm)**2)/mm1)
                              +(mp1*nm1/(ntm*m))*(cov_meansq_var_&&var&i
                              -2*mean_mean_&&var&i*cov_mean_var_&&var&i));  

                        d=2*(v**2)/var_v;
                        dp1=d+1;
                        dp3=d+3;
                         Rc=sqrt((dp3*v)/(dp1*w));
                         Rcupper=sqrt(((nm1/n)+(mp1/ntm)*
                            finv(%sysevalf(1-&alpha), mm1, 2*(w**2)*m/var_var_&&var&i))*
                            (dp3/dp1));
                        if  Rc< Rcupper then  Rctest='Accept';
                        else  Rctest='Reject';
                        
                        v=sqrt(v);
                        w=sqrt(w);
			output;
                    end;
                run;
            
		data &bgr;
		    set &bgr &scratch(in=_in_) end=last;
		    by &obs;

		    if _in_ then do;
                        &iter=&&stop&k;
                        k=&k;
                    end;
		run;
                %end;

		%if &graphics=1 %then %do;
                    %if &j=1 %then goptions gsfmode=append;;
  
                    symbol1 &symbol width=&width;

		    proc gplot data=&bgr;
			plot (Rc RcUpper)*&iter / overlay vaxis=0.9 to 1.2 by 0.1;
			plot (v w)*&iter / overlay;
			by &obs;
                    
                        label v="sqrt(V), sqrt(W) for &&var&i";
		    run; 
                    quit;    
		%end;
                        
                proc print noobs label data=&bgr;
                    where k>10;
                    id &obs &iter k;
                    var  Rc: v w;
                run;
            %end;
                
                %if &graphics=1 & &trace=1 %then %do;
                    %if &j=1 %then goptions gsfmode=append;;

		    symbol1 &symbol width=&width;

		    proc gplot data=&data(keep=&obs &chain &iter &&var&i where=(n(&&var&i))); 
                	by &obs;
                	plot &&var&i*&iter=&chain;
		    run;
		    quit;
                %end;

                %if "&autocorr"^="0" %then %do k=1 %to %_count(&autocorr);
                    %local autocorr&k;
                    %let autocorr&k=%scan(&autocorr, &k, %str( ));
                    
		    %if &graphics=1 %then %_printto(file=.autocorr_debugs.txt);

                    proc arima data=&data(keep=&obs &chain &iter &&var&i 
                        where=(n(&&var&i) & &chain=&&autocorr&k));
                        by &obs &chain;
                        identify var=&&var&i nlag=&nlag;
                        %if &graphics=1 %then label &obs="&obs";;
                    run;
                    quit;

		    %if &graphics=1 %then %do;
			%_printto;
			%let scratch=%_scratch;

			proc sort data=&data(keep=&obs &chain &&var&i
                            where=(n(&&var&i) & &chain=&&autocorr&k))
                            nodupkey out=&scratch;
                            
                            by &obs;
			run;

			%let nobs=%_nobs(data=&scratch);
			%let scratch0=%_scratch;

			%do l=1 %to &nobs;
			data _null_;
			    l=&l;
			    set &scratch point=l;
			    call symput('m', trim(left(obs)));
			    stop;
			run;

			data &scratch0;
			    drop cov n;
			    retain &obs &m &chain &&autocorr&k;
			    label lag='Lag' corr="&&var&i";
			    infile ".autocorr_debugs.txt";
    
			    input @"&obs=&m ";
                            input @'Number of Observations' n;
			    input @'Lag';
                            call symput('cl95', trim(left(2/sqrt(n))));

			    %do lag=1 %to &nlag;
				input @"%_repeat(%str( ), %length(&nlag)-%length(&lag))&lag " cov corr;
				lag=&lag;
				output;
			    %end; 

			    stop;
			run;

                        %if &j=1 %then goptions gsfmode=append;;

		        symbol1 i=needle width=&width;

		        proc gplot data=&scratch0;
                    	    by &obs &chain;
                	    plot corr*lag / overlay vaxis=-1 to 1 by 0.1 vref=-&cl95 0 &cl95;
		        run;
		        quit;
			%end;
 
			&debug.x "%_unwind(rm, del) .autocorr_debugs.txt";
		    %end;
                %end;
	    %end;
        %end;
        
        %let scratch0=%_scratch;
        %let var=;
        
        %if &crosscorr^=0 %then %do k=1 %to %_count(&crosscorr);
            %local crosscorr&k;
            %let crosscorr&k=%scan(&crosscorr, &k, %str( ));
           
            proc sort data=&out out=&scratch0;
                by &iter;
                where &chain=&&crosscorr&k;
            run;
           
            %do i=1 %to &j;
                %let var&i=%scan(&list, &i, %str( ));
                %local scratch&i;
                %let scratch&i=%_scratch;
                
                proc transpose data=&scratch0 out=&&scratch&i prefix=&&var&i;
                    by &iter;
                    id &obs;
                    where n(&&var&i) & &obs>0;
                    var &&var&i;
                run;
        
                %if %_nobs(data=&&scratch&i)=0 %then %let scratch&i=;
                    
                %if %_nobs(data=&scratch0, where=n(&&var&i) & &obs=0)>0 %then %let var=&var &&var&i;
            %end;
            
            data &scratch0;
                merge &scratch0(keep=&obs &iter &var where=(&obs=0))
                    %do i=1 %to &j; &&scratch&i %end;;
                by &iter;
                drop &obs &iter;
            run;
           
            proc corr nosimple;
            run;
        %end;
%mend _debugs;

%*VALIDATION TEST STREAM;
/* un-comment to re-validate

*/
