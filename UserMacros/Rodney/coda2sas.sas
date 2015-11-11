%put NOTE: You have called the macro CODA2SAS, 2007-10-20;
%put NOTE: Copyright (c) 1999-2005 Matthew Hayat and 2005-2007 Rodney Sparapani;
%put;

/*
Author:  Matthew Hayat <hayatm@nidcd.nih.gov>
Created: 1999-00-00

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

/* CODA2SAS Documentation
    Creates a SAS dataset from CODA files and provides summaries 
    if requested.  Deprecated in favor of _DECODA.

    REQUIRED Parameters  

    OUT=                    SAS dataset to create
    
    INFILE=                 filename of the CODA index file
    
    CODAIND=INFILE          alias
                            
    OPTIONAL Parameters
    
    CHAIN=                  filename of the CODA chain file
                            you can skip it if you stick to 
                            the extensions of .ind and .out
    
    CODAOUT=CHAIN           alias
    
    GSFMODE=REPLACE         default GSFMODE for first graph
    
    STATS=                  if set to anything, produce stats/graphs   
    
    TYPE=                   if you set this parameter, then TYPE will be
                            used to name the graphics file (VAR.TYPE) for 
                            each summarized variable 
*/
    
%macro CODA2SAS(out=, infile=, codaind=&infile, chain=, codaout=&chain, gsfmode=replace,
    stats=, type=);
    
    %let stats=%length(&stats);
    %local i numrow;
    
    %if %length(&codaout)=0 %then %let codaout=%scan(&codaind, 1, .).out;
    
    data info ind(keep=last rename=(last=ratio)) ;
     length varname $ 32;
     infile "&codaind" dlm='090d0a'x ;
     input varname $ first last ;
      if _n_=1 then output ind ;
        
      if varname^='' then do;
        varname=lowcase(translate(varname, '___ ', '.[,]'));
        call symput("numrow", left(_n_));
        output info ;
      end;  
    run;
        
    data out (keep=value) ;
    infile "&codaout" dlm='090d0a'x  ;
     input sampnum value ;
    run;

    proc transpose data=info out=&out ;
     var first ;
     id varname ;
    run;
    
    data &out (drop=_name_) ;
     set &out ;
     if _n_ < 1 ;
    run;

    data all %if &stats %then temp;;
     if _n_ < 1 ;
    run;

    %do i = 1 %to &numrow ;
      %local label&i;
    
      data v&i ;
       if _n_ = 1 then do;
        set ind ;
        value=&i;
        set info(keep=varname) point=value;
        call symput("label&i", trim(varname));
       end;
        
       set out ;
       if (ratio*&i-ratio+1) le _n_ le (ratio*&i) ;
       v&i = value ;
      run;

      data all ;
       merge all v&i ;
      run;

        %if &stats %then %do ;
          %if &i=1 %then goptions gsfmode=&gsfmode;; 
            
          %if %length(&type) %then filename gsasfile "&&label&i...&type";
          %else %if &i=2 %then goptions gsfmode=append;;
            
          proc univariate noprint data=v&i ;
           label v&i="&&label&i";
           var v&i ;
           histogram v&i / kernel; 
           output out=v&i n=n mean=mean var=var std=std min=min max=max
                          range=range pctlpts=2.5 median=median pctlpts=97.5
                          kurtosis=kurtosis skewness=skewness pctlpre=p   ;
          run;

          data temp ;
           set temp v&i ;
          run;
        %end ;
    %end ;

    data &out ;
     set all (keep=v1-v&numrow) &out ;
    run;

      %if &stats %then %do ;
        data temp ;
         merge info (keep=varname) temp ;
        run;

        proc print label noobs uniform data=temp ;
         title "Summary Statistics" ;
         var n mean var std min max range p2_5 median p97_5 kurtosis skewness ;
         id varname ;
         label varname  = 'Variable'
               n        = 'N'
               mean     = 'Mean'
               var      = 'Variance'
               std      = 'Standard Deviation'
               min      = 'Minimum'
               max      = 'Maximum'
               range    = 'Range'
               p2_5     = '2.5%'
               median   = '50%'
               p97_5    = '97.5%'
               kurtosis = 'Kurtosis'
               skewness = 'Skewness' ;

        run;
      %end ;

    data &out (drop=i v1-v&numrow) ;
     set &out ;
     array numer(*) _numeric_ ;
     array vvec(*) v1-v&numrow ;
     do i = 1 to dim(vvec) ;
      numer(&numrow+i)= vvec(i) ;
     end ;
    run;

    proc datasets nolist;
     delete v1-v&numrow all out ind info temp ;
    run ;
%mend CODA2sas ;
