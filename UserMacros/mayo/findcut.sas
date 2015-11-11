  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : findcut
   | SHORT DESC  : Find the best cutpoint of a continuous variable
   |               for survival outcome
   *------------------------------------------------------------------*
   | CREATED BY  : Cha, Stephen                  (03/26/2004 12:36)
   |             : Mandrekar, Sumithra
   |             : Mandrekar, Jay
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Investigator: Jay & S Mandrekar
   | Programmer: Stephen Cha
   | Date Created: 11/04/2002
   |
   | This macro is designed to find a best cutpoint of a continous
   | variable when log-rank statistics is concerned
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %findcut (
   |            ds= ,
   |            time= ,
   |            stat= ,
   |            cutvar=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : ds
   | Default   :
   | Type      : Dataset Name
   | Purpose   : name of the dataset on which to perform the proc findcut
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : variable containing the time
   |             increments used for the lifetest
   |
   | Name      : stat
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : the stat variable for the lifetest, ex. fu_stat,
   |             having a value of 1=event or 0=no event
   |
   | Name      : cutvar
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : the variable you like to find the best cutpoint
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | %findcut(ds=use, time=fu_wks, event=Death, cutvar=&cutvar);
   *------------------------------------------------------------------*
   | Copyright 2004 Mayo Clinic College of Medicine.
   |
   | This program is free software; you can redistribute it and/or
   | modify it under the terms of the GNU General Public License as
   | published by the Free Software Foundation; either version 2 of
   | the License, or (at your option) any later version.
   |
   | This program is distributed in the hope that it will be useful,
   | but WITHOUT ANY WARRANTY; without even the implied warranty of
   | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   | General Public License for more details.
   *------------------------------------------------------------------*/
 
%macro findcut(ds=_last_, time=fu_time, stat=fu_stat, cutvar=age);
 
 *********************************************;
 * figure out dim(difage)                    *;
 *********************************************;
 
   PROC FORMAT;
   VALUE pf   -99='P>0.30';
 
   proc sort data=&ds; by &cutvar;
 
 data difage; set &ds; by &cutvar;
   title3 "step1: check no. of disticnt &cutvar";
   if first.&cutvar;
   proc sort; by &cutvar;
 
 data ttt; set difage; by &cutvar;
   cut=_N_;
   keep &cutvar cut;
   proc sort; by descending &cutvar;
 
 data cut; set ttt; by descending &cutvar;
   if _N_=1 then do;
     nocut=cut; retain nocut;
   end;
   somecut=&cutvar;
   drop &cutvar;
   output;
   proc sort; by somecut;
   /* proc print n; */
 
 data dim; set cut; by somecut;
   if last.somecut; dummy=1;
   keep nocut dummy;
   proc sort; by dummy;
 
 *********************************************;
 * find # of &stat at each time ti           *;
 *      # at risk at time ti                 *;
 *      ti are those distinct event time     *;
 *********************************************;
 
   proc sort data=&ds; by descending &time &stat;
 
 data step1; set &ds; by descending &time &stat;
   title3 "check step1";
   if _N_=1 then do;
     norisk=0; retain norisk;
   end;
   if first.&time then do;
     nodeath=0; retain nodeath;
   end;
   norisk=norisk+1;
   if &stat=1 then nodeath=nodeath+1;
   if last.&time and &stat=1 then output;
 
 data step1; set step1;
   keep &time norisk nodeath;
   proc sort; by &time;
   /* proc print n; */
 
 *********************************************;
 * find # of &stat at each time ti           *;
 *      # at risk at time ti                 *;
 *  == with c>=&cutvar                        *;
 *********************************************;
 
 data dummy; set &ds;
   dummy=1;
   proc sort; by dummy;
 
 data double; merge dummy dim; by dummy;
   do cut=1 to nocut;
     output;
   end;
   proc sort; by cut;
   proc sort data=cut; by cut;
 
 data comb; merge double cut; by cut;
   keep obsno &time &stat &cutvar somecut cut;
   proc sort; by cut descending &time &stat;
   /* proc print n; */
 
   proc sort data=comb; by cut descending &time &stat;
 data step2; set comb; by cut descending &time &stat;
   title3 "check step2";
   if first.cut then do;
     noriskc=0; retain noriskc;
   end;
   if first.&time then do;
     nodeathc=0; retain nodeathc;
   end;
   if &cutvar>=somecut then noriskc=noriskc+1;
   if &stat=1 and &cutvar>=somecut then nodeathc=nodeathc+1;
   if last.cut or (last.&time and &stat=1) then output;
   /* proc print n; */
 
 data step2; set step2;
   keep &time cut somecut noriskc nodeathc;
   proc sort; by &time;
 
 *********************************************;
 * compute Sk .. max(sk)                     *;
 *********************************************;
 
 data step3; merge step2 step1; by &time;
   title3 "step3";
   sik=nodeathc-nodeath*noriskc/norisk;
   /* proc print n; */
   proc sort; by cut somecut;
   proc univariate noprint; var sik; by cut;
     output out=step4 sum=sk;
   /* proc print n; */
 
 data step4; set step4;
   title3 "step4";
   abs_sk=abs(sk);
   dummy=1;
   proc sort; by dummy;
   /* proc print n; */
   proc univariate noprint; var abs_sk;
   output out=step5 max=maxsk;
 
 *********************************************;
 * compute S**2                              *;
 *********************************************;
  *********************************************;
 * figure out dim(&time where &stat=1)      *;
 *********************************************;
 
 data diftm; set &ds;
   title3 "step5";
   if &stat=1;
   proc sort; by &time;
   data ttt; set diftm; by &time;
   if first.&time;
   proc univariate noprint; var &time;
   output out=deathtim N=nodeath;
   /* proc print n; */
   data deathtim; set deathtim;
   dummy=1;
   keep nodeath dummy;
 
 data square; set deathtim;
   do i=1 to nodeath;
     do j=1 to i;
       frac=1/(nodeath-j+1);
       keep i j frac;
       output;
     end;
   end;
   /* proc print n; */
   proc sort; by i j;
 
 data sums2; set square; by i j;
   if first.i then do;
     sumi=0; retain sumi;
   end;
   sumi=sumi+frac;
   if last.i then do;
     sumi=(1-sumi)*(1-sumi);
     output;
   end;
   /* proc print n; */
   proc univariate noprint; var sumi;
   output out=d2 sum=s2 n=n2;
 
 data step5; set d2;
   ssquare=(1.0/(n2-1))*s2;
   dummy=1;
   proc sort; by dummy;
 
 data step5; merge step4 step5; by dummy;
   title3 "step 5";
   q=abs_sk/(sqrt(ssquare)*sqrt(n2-1));
   if q>1 then p=2*exp(-2*q*q);
   if q<=1 then p=-99;
   format p pf.;
   proc sort; by cut;
 
 data cut; set cut;
   &cutvar=somecut;
   keep cut &cutvar;
   proc sort; by cut;
 
 data temp; merge step5 cut; by cut;
   if _N_=1 then do;
     maxsk=0; maxcut=0; retain maxsk maxcut;
   end;
   if abs_sk>maxsk then do;
     maxsk=abs_sk;
     maxcut=cut;
   end;
   dummy=1;
   output;
   /* proc print n; */
   proc sort; by dummy;
 
 data temp; set temp; by dummy;
   cut=maxcut;
   if last.dummy then output;
   keep cut;
   proc sort; by cut;
 
 data final; merge step5 cut temp(in=in1); by cut;
   TITLE3 "Final Result";
   pick="     ";
   if in1 then Pick="<====";
   label cut="Cutpoint"
         sk="sk"
         abs_sk="ABS(sk)"
         Q="Q statistics"
         p="P-value";
   proc print label;
   var cut &cutvar sk abs_sk q p pick;
   run;
 
%mend;
 
 

