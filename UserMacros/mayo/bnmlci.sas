  /*------------------------------------------------------------------*
   | MACRO NAME  : bnmlci
   | SHORT DESC  : Calculate exact binomial confidence intervals
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (03/23/2004 12:30)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Caclulate exact binomial confidence intervals for
   | the binomial parameter P, after having observed
   | X successes in N trials. Output includes normal
   | and poisson approximation to the binomial.
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Erik              (08/28/2008 14:16)
   |
   | Added out option. Set min/max of all lower and upper limits to 0/1.
   | Used next available title. Corrected poisson lower limit when x=0.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %bnmlci  (
   |            WIDTH=95,
   |            X= ,
   |            N= ,
   |            NMIN= ,
   |            NMAX= ,
   |            OUT=_exact_
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : X
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Observed number of successes in N trials
   |
   | Name      : N
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Number of binomial trials
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : WIDTH
   | Default   : 95
   | Type      : Number (Single)
   | Purpose   : WIDTH =95, for a 95% CI, 99 for a 99% CI etc.
   |
   | Name      : NMIN
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Smallest value of N to table.
   |             Used to generate a TABLE of exact CIs for all
   |             values  of X for each N ranging from NMIN to NMAX.
   |             Note that the parameters X and N are
   |             ignored if one is creating a table.
   |
   | Name      : NMAX
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Largest value of N to table.
   |             Used to generate a TABLE of exact CIs for all
   |             values  of X for each N ranging from NMIN to NMAX.
   |             Note that the parameters X and N are
   |             ignored if one is creating a table.
   |
   | Name      : OUT
   | Default   : _exact_
   | Type      : Dataset Name
   | Purpose   : Dataset containing CI estimates for all 3 methods.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | Output        :  The results of a PRINT on the data set _exact_.
   |                  Upper & lower confidence limits for the 3 methods.
   |
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | Date written  :  10/11/88
   |
   | Dates modified:  8/23/90 Changed assignment of p(i) for exact
   |                          method when p(i) lt 0 or gt 1
   |
   |                  1/7/94  call statement changed to use keywords
   |                          results routed to output(print) file
   |
   |                  11/6/96 Exact limits in error because of zero
   |                          divide for large N(500+) with high
   |                          success rate(99%+). Program reset to
   |                          return missing values for exact limits
   |                          in this setting. Work around is to get
   |                          limits for 1-success rate and transfrom.
   |
   |                 02/13/98 Replaced secant method for exact CI with
   |                          the exact binomial/beta relationship from
   |                          Feller,Vol 1, 3r Ed, Wiley 1968, page
   |                          173, eqn 10.7.
   |
   |                          Added option to print table(nmin,nmax).
   |
   | Macro call    :  %BNMLCI(width=,x=,n=,nmin=,nmax=);
   |
   | Methodology   :  The macro is based on the exact relationship
   |                  between the beta dist'n and the cumulative
   |                  binomial as described in Feller(see above).
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | (6 successes in 93 trials)
   | %BNMLCI(x=6,n=93)
   |
   | (Table of exact 95pct CIs for all possible Xs for N=10 to 15)
   | %bnmlci(nmin=10,nmax=15)
   |
   *------------------------------------------------------------------*
   | Copyright 2008 Mayo Clinic College of Medicine.
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
 
%MACRO bnmlci(WIDTH=95,x=,n=,nmin=,nmax=,out=_exact_);
 
***** Make a data set of the current titles *****;
proc sql ;
  create table work._t as select * from dictionary.titles
     where type='T';
  reset noprint;
 quit;
***** Determine # current titles  *****;
proc sql;
   reset noprint;
   select nobs into :T from dictionary.tables
   where libname="WORK" & memname="_T";
 quit;
***** Store titles in macro variables *****;
%LET TITLE1= ;  *Initialize at least one title;
data _null_;
  set _t;
  %IF (&T>=1) %THEN %DO I=1 %TO &T;
     if number=&I then call symput("TITLE&I", trim(left(text)));
     %END;
 run;
***** Macro uses 3 titles: see how many current titles can be retained***;
%LET TNEW = 3;  **#macro titles;
%LET TOTALT = %EVAL(&T + &TNEW);
%IF &TOTALT<=10 %THEN %LET TSHOW=&T;
   %ELSE %LET TSHOW = %EVAL(10 - &TOTALT + &T);
 ***** Step 5) Add your own title(s) to previous titles *****;
%LET NEXTT1=%EVAL(&TSHOW+1);
%LET NEXTT2=%EVAL(&TSHOW+2);
%LET NEXTT3=%EVAL(&TSHOW+3);
** end title fix up **;
 
  Data &out;
   IF ^(10 LE &WIDTH LE 99) THEN DO;
     PUT "NOT EXECUTED: CONFIDENCE INTERVAL WIDTH IS LT 10 OR GT 99";
     STOP;
   END;
    %if &nmin= %then %do;
   IF &X GT &N OR &X LT 0 OR &N LT 2 THEN DO;
     PUT "NOT EXECUTED: X IS LT 0 OR X GT N OR N LT 2";
     STOP;
   END;
    %end;
 
   LPCT=(1-&WIDTH/100)/2;
   UPCT=1-LPCT;
 
   %if &x^= %then %do; x=&x; %end;
   %if &n^= %then %do; n=&n; %end;
 
     %if &nmin^= %then %do;
  do n=&nmin to &nmax;
   do x=0 to n;
     %end;
 
    Phat=x/n;
 
   **NORMAL APPROXIMATION;
    L_normal=PHAT+PROBIT(LPCT)*SQRT(PHAT*(1-PHAT)/N);  *LOWER LIMIT;
      if l_normal <0 then l_normal=0;
    U_normal=PHAT+PROBIT(UPCT)*SQRT(PHAT*(1-PHAT)/N);  *UPPER LIMIT;
      if u_normal>1 then u_normal=1;
 
   **POISSON APPROXIMATION;
    DF_LO=2*X;
    DF_UP=2*(X+1);
    IF X GT 0 THEN L_poissn=GAMINV(LPCT,DF_LO/2)/N;  *LOWER LIMIT;
     ELSE L_poissn=0;
    U_poissn=GAMINV(UPCT,DF_UP/2)/N;                 *UPPER LIMIT;
     if u_poissn>1 then u_poissn=1;
 
   *** EXACT BINOMIAL CONFIDENCE LIMITS ***equn 10.7 of Feller*;
     * Upper limit;
    if x<n then u_exact=1-betainv(lpct,n-x,  x+1);
     else u_exact=1;
     * Lower limit;
    if x>0 then l_exact=1-betainv(upct,n-x+1,x);
     else l_exact=0;
 
    output;
 
     %if &nmin^= %then %do;
   end;
  end;
    %end;
 
   FORMAT PHAT L_normal U_normal L_poissn U_poissn L_exact U_exact
   6.4;
   label phat='Phat*(x/N)'
         l_exact='Exact CI*Lower'
         u_exact='Exact CI*Upper'
         l_normal='Normal*Approx.*Lower'
         u_normal='Normal*Approx.*Upper'
         l_poissn='Poisson*Approx.*Lower'
         u_poissn='Poisson*Approx.*Upper';
 
 proc print data=&out split='*'; by n; id n;
      var x phat l_exact u_exact l_normal u_normal l_poissn
   u_poissn;
title&nextt1"BNMLCI Macro: &width% Confidence Int. for Binomial(P), N trials, x successes)";
title&nextt2"Exact intervals are based on Feller(Wiley 1968, eqn 10.7).        ";
title&nextt3"Also printed are Normal & Poisson approximations to the binomial.";
 run;
 ***** Restore the previous titles *****;
title1;
%IF (&T>=1) %THEN %DO I=1 %TO &T;
   title&I "&&TITLE&I";
  %END;
%mend bnmlci;
 
 
