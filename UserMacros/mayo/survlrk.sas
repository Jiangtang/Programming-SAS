  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : survlrk
   | SHORT DESC  : Calculates logrank statistics for the surv
   |               macro.
   *------------------------------------------------------------------*
   | CREATED BY  : Province, Michael             (04/12/2004  9:35)
   |             : Camp, David
   |             : Bergstralh, Erik
   |             : Offord, Jan
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Calculates logrank statistics for the surv macro.
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
   | %survlrk (
   |            data= ,
   |            time= ,
   |            death= ,
   |            censor= ,
   |            strata= ,
   |            out=
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : Input data set.
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : The time-to-event or last follow-up variable.
   |
   | Name      : death
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : The event indicator variable.
   |
   | Name      : censor
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Value indicating censoring.
   |
   | Name      : strata
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : The class variable. Survival is compared between the
   |             different levels of this variable.
   |
   | Name      : out
   | Default   :
   | Type      : Dataset Name
   | Purpose   : The output data set.
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | No printout. The output dataset will contain one observation with:
   |
   | &strata = the strata or class variable.
   | observed = the calculated number of observed.
   | expected = the calculated number of expected.
   | o_e = number observed - expected.
   | rr = the relative risk (observed/expected for this strata
   |         / observed/expected for strata 1).
   | chisq = the chi-square value.
   | df = degrees of freedom
   | pvalue = the p-value for the probability of a greater chisq.
   |
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | FROM - Implemented by David J. Camp,
   |        from instructions prepared by Michael A. Province
   |        under the supervision of J. Philip Miller
   |        all of the Division of Biostatistics, Box 8067
   |        Washington University Medical School
   |        660 South Euclid
   |        Saint Louis, MO 63110
   |  Modifed 6/2/93 by E. Bergstralh and Jan Offord.
   | Used by the %surv macro.
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
 
 
   /*
 
macro survlrk.SAS -- calculates logrank statistics for the surv macro.
   It created no printout, but returns an output dataset to the calling
   program.
 
 
  FROM - Implemented by David J. Camp,
         from instructions prepared by Michael A. Province
         under the supervision of J. Philip Miller
         all of the Division of Biostatistics, Box 8067
         Washington University Medical School
         660 South Euclid
         Saint Louis, MO 63110
 
     The following variables must be defined:
 
          data=         the data set to be analyzed;
          time=         the name of the TIME variable;
          death=        the name of the DEATH variable;
          censor=       the censor value, usually 0;
          strata=       the name of the STRATA  or class variable;
          out=          the name of the output dataset.  This dataset will
                        contain one observation with:
                &strata = the strata or class variable.
                observed = the calculated number of observed.
                expected = the calculated number of expected.
                o_e = number observed - expected.
                rr = the relative risk (observed/expected for this strata
                        / observed/expected for strata 1).
                chisq = the chi-square value.
                df = degrees of freedom
                pvalue = the p-value for the probability of a greater chisq.
 
 
 Modifed 6/2/93 by E. Bergstralh and Jan Offord
 
   */
 
%macro survlrk(data= ,time= ,death= ,censor= ,strata= ,out= );
run;
 
%let tol=1e-10;
 
  /*  check for only one strata */
 
data _lrmstr;
   set &data;
   if &time=. or &event=. then delete;
 
proc freq data=_lrmstr;
    tables &strata/ out=_lr1 noprint;
 
data &out;
    set _lr1 end=eof;
    keep &strata observed expected o_e rr chisq df pvalue;
    observed=.;
    expected=.;
    o_e=.;
    rr=.;
    chisq=.;
    df=.;
    pvalue=.;
    if eof=1 then do;
      call symput('num_st',left(put(_n_,2.)));
      end;
run;
 
%if &num_st<=1 %then %do;
    %put "WARNING - only one strata - log-rank test cannot be done";
    %end;
 
   /*  main processing */
 
%if &num_st>1 %then %do;
 
 
proc sort data=_lrmstr;
      by &time;
 
  /* Invoke IML for the rest of the processing. */
 
proc iml worksize=128;
   reset log;
 
   use _lrmstr;
   top = 0;
   obs = 0;
 
      /*  determine number and names of the strata */
 
   do data;
     read next;
     obs = obs + 1;
     this = 0;
     do i = 1 to top;
        if &strata = strats [i] then
                  this = i;
        end;
     if this = 0 then do;
        pop = pop // {0};
        strats = strats // &strata;
        top = top + 1;
        this = top;
        end;
 
     pop [this] = pop [this] + 1;
     end;
 
   close _lrmstr;
 
      /* Reopen dataset for calculation phase */
 
   use _lrmstr;
   d = j (top, 1, 0);      /* 'd' is deaths this time, each strata. */
   c = j (top, 1, 0);      /* 'c' is cases this time, each strata. */
   v = j (top, 1, 0);      /* 'v' is vector for Log Rank. */
   e_lr = j (top, 1, 0);   /* 'e_lr' is vector of expecteds --ejb */
   o_lr = j (top, 1, 0);   /* 'o_lr' is vector of obs  --ejb */
   w = j (top, 1, 0);      /* 'w' is vector for Wilcoxon. */
   sv = j (top, top, 0);   /* 'sv' is array for Log Rank. */
   sw = j (top, top, 0);   /* 'sw' is array for Wilcoxon. */
   n = pop;                /* 'n' is population left, each strata. */
   t = .;                  /* 't' is current time. */
   obs = 0;                /* 'obs' is observation counter. */
 
   do data;
     read next;
     obs = obs + 1;
 
     do i = 1 to top;
        if &strata = strats [i] then
            this = i;
        end;
 
     if t ^= . & t ^= &time then do;
        dc = sum (d);
        nc = sum (n);
 
        do i = 1 to top;
            temp = d [i] - n [i] * dc / nc;
            expd   =n[i]*dc/nc; **log rank expected events..ejb;
              if n[i]=nc then expd=0; **only one group left..ejb;
            obs = d[i];         **log rank observed events...ejb;
              if n[i]=nc then obs =0;
            o_lr [i] = o_lr [i]+ obs;  ** events for logrank test..ejb;
            e_lr [i] = e_lr[i] + expd;
            v [i] = v [i] + temp;
            w [i] = w [i] + nc * temp;
            end;
 
        do l = 1 to top;
            do j = l to top;
                delta = (j = l);
                temp = (nc * n[l] * delta - n [j] * n [l]) *
                        (dc * (nc - dc) / (nc * nc * (nc - 1)));
                sv [l, j] = sv [l, j] + temp;
                sw [l, j] = sw [l, j] + nc * nc * temp;
                end;
            end;
        n = n - c;
        c = j (top, 1, 0);
        d = j (top, 1, 0);
        end;
 
     t = &time;
     c [this] = c [this] + 1;
     if &death ^= &censor then
        d [this] = d [this] + 1;
     end;
 
     /* Fill in the bottom of the symmmetric arrays. */
 
   do l = 2 to top;
     do j = 1 to l - 1;
        sv [l, j] = sv [j, l];
        sw [l, j] = sw [j, l];
        end;
     end;
 
      /* Calculate the statistics. */
 
   o_e = j (top, 3, 0);   /* 'initialize to zero  --jro */
   stats = j (2, 3, 0);   /* 'initialize to zero  --jro */
 
   qv = v` * ginv (sv) * v;
   qw = w` * ginv (sw) * w;
   ev = eigval (sv);
   ew = eigval (sw);
   dv = 0;
   dw = 0;
   do i = 1 to top;
     if ev [i] > &tol then
        dv = dv + 1;
     if ew [i] > &tol then
        dw = dw + 1;
     end;
 
   pv = 1 - probchi (qv, dv);
   pw = 1 - probchi (qw, dw);
 
   o_e=o_lr || e_lr || (o_lr-e_lr);  *observed, expected, o-e, ejb;
 
   logrank = sv || v;
   wilcoxon = sw || w;
 
   varnames={"observed" "expected" "o_e"};
 
      /*  create the output datasets */
 
   create _lr1 from o_e [ rowname=strats colname=varnames];
   append from o_e [rowname=strats];
 
   names = {"Log Rank" "Wilcoxon"};
   stats = (qv // qw) || (dv // dw) || (pv // pw);
   varnames={"chisq" "df" "pvalue"};
 
   create _lr2 from stats [ rowname=names colname=varnames];
   append from stats [rowname=names];
 
   if (dv ^= top - 1) | (dw ^= top - 1) then
       print "Warning -- The degrees of freedom ^= strats-1.";
 
   quit;
 
   /*  merge the output datasets */
 
   data &out;
      set _lr1;
      keep &strata observed expected o_e chisq df pvalue;
      &strata=strats;
 
      if _n_=1 then do;
        set _lr2;
        end;
   proc sort;  by &strata;
 
   data &out;  set &out;
     drop rr1;
     retain rr1;
     if _n_=1 then do;
        if expected>0 then rr1=observed/expected;
           else rr1=.;
        end;
 
      if expected>0 and rr1>0 then rr=(observed/expected)/rr1;
        else rr=.;
     if _n_^=1 then do;
       df=.;
       chisq=.;
       pvalue=.;
       end;
 
%end;
 
    run;
 
%mend survlrk;
 
 
 
 
 
 

