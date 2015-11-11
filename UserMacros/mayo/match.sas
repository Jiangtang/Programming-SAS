  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : match
   | SHORT DESC  : Match one or more controls to each of a set
   |               of cases (rendered somewhat obsolete by the
   |               newer macros %vmatch and %gmatch)
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (04/07/2004 16:15)
   |             : Kosanke, Jon
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | ***NOTE - This macro has been replaced by %gmatch and %vmatch,
   | depending on whether one wants greedy matching or optimal matching.
   |
   | Macro name: %match
   |
   | Authors: Jon Kosanke and Erik Bergstralh
   |
   | Date: April 25, 1995
   |
   | Macro function:
   |
   | The purpose of this macro is to match 1 or more controls(from a total
   | of M) for each of N cases.  The controls may be matched to the cases by
   | one or more factors(X's).  The control selected for a particular
   | case(i) will be the control(j) closest to the case in terms of Dij.
   | Dij is just the weighted sum of the absolute differences between the
   | case and control matching factors.  I.e.,
   |
   |     Dij= SUM { W.k*ABS(X.ik-X.jk) }, where the sum is over the number
   |                                      of matching factors X(with index
   |                                      k) and W.k = the weight assigned
   |                                      to matching factor k and X.ik =
   |                                      the value of variable X(k) for
   |                                      subject i.
   |
   | The control(j) selected for a case(i) is that with the smallest Dij
   | which is less than or equal DMAX(and which is compatible with the DMAXK
   | option below), where DMAX is defined by the user.  In the case of ties,
   | the first one encountered will be used.     The higher the user-defined
   | weight, the more likely it is that the case and control will be matched
   | on the factor.  Assign large weights (relative to the other weights) to
   | obtain exact matches for two-level factors such as gender.
   |
   | Using the GREEDY method, once a match is made it is never broken.  This
   | may result in inefficiencies if a previously matched control would be a
   | better match for the current case than those controls currently
   | available.
   |
   | The OPTIMAL method uses PROC NETFLOW from SAS/OR to find the set of
   | matches that minimizes the sum of Dij over all possible sets of
   | matches.  The OPTIMAL method also has an option for a variable number
   | of controls per case.
   |
   | The macro checks for missing values of matching variables and the time
   | variable(if specified) and deletes those observations from the case
   | and control datasets.
   |
   | Call statement:
   | %match(case=,control=,idca=,idco=,
   |       mvars=,wts=,dmaxk=,dmax=,
   |       time=,
   |       method=,
   |       ncontls=,seedca=,seedco=,
   |       mincont=,maxcont=,maxiter=,
   |       out=,outnmca=,outnmco=,print=);
   |
   | Parameter definitions(R=required parameter):
   |
   |  R     case=SAS data set of cases.  Must contain the IDCA variable and
   |             the matching variables.
   |
   |  R     control=SAS data set of possible controls.  Must contain the
   |             IDCO variable and the matching variables.  Note the macro
   |             assumes that the cases and controls are in different
   |             data sets.
   |         FOR RISK SET MATCHING THIS DATA SET SHOULD INCLUDE BOTH CASES
   |         AND CONTROLS.
   |
   |  R     idca=ID variable for the cases.
   |
   |  R     idco=ID variable for the controls.
   |
   |        time=time variable used to define risk sets.  Matches are only
   |             valid if the control time > case time.
   |
   |  R     mvars=list of numeric matching variables common to both case and
   |              control data sets.  For example, mvars=male age birthyr.
   |
   |  R     wts=list of non-negative weights corresponding to each matching
   |            variable.  For example wts=10 2 1 corresponding to male, age
   |            and birthyr as in the above example.
   |
   |        dmaxk=list of non-negative values corresponding to each matching
   |              variable.  These numbers are the largest possible absolute
   |              differences compatible with a valid match.  Cases will
   |              NOT be matched to a control if ANY of the INDIVIDUAL
   |              matching factor  differences are >DMAXK.  This optional
   |              parameter allows one to form matches of the type male+/-0,
   |              age+/-2, birth year+/-5 by specifying DMAXK=0 2 5.
   |              Given that a possible control meets the DMAXK criteria,
   |              the macro selects the control with the smallest Dij.
   |              If this list is shorter that the MVARS list, 1-1 matching
   |              will be done until the DMAXK list is exhausted.  If
   |              this list is longer, the extra DMAXK values are ignored.
   |
   |
   |        dmax=largest value of Dij considered to be a valid match.  If
   |             you want to match exactly on a two-level factor(such as
   |             gender coded as 0 or 1) then assign DMAX to be less than
   |             the weight for the factor.  In the example above, one could
   |             use wt=10 for male and dmax=9.  Leave DMAX blank if any
   |             Dij is a valid match.  One would typically NOT use both
   |             DMAXK and DMAX.  The only advantage to using both, would be
   |             to further restrict potential matches that meet the
   |             DMAXK criteria.
   |
   |  R     method= GREEDY or OPTIMAL.  See reference below.
   |
   |        ncontls=fixed number of controls to match to each case.  The
   |                default is 1.  Using the GREEDY method with multiple
   |                controls per case, the algorithm will first match every
   |                case to one control and then again match each case to a
   |                second control, etc.  Controls selected on the first
   |                pass will be stronger matches than those selected in
   |                later rounds.  The output data set contains a variable
   |                (cont_n) which indicates on which round the control was
   |                selected.  This option is ignored if a variable number
   |                of controls is to be used with the OPTIMAL method(see
   |                MINCONT and MAXCONT parameters below).
   |
   | **** Options specific to GREEDY method ******************************
   |  R     seedca=seed value used to randomly sort the cases prior to
   |               matching using the GREEDY method.  This positive integer
   |               must be less than (2**31)-1 and will be used as input to
   |               the RANUNI function.  The greedy matching algorithm is
   |               order dependent which, among other things means that
   |               cases matched first will be on average more similar to
   |               their controls than those matched last(as the number of
   |               control choices will be limited).  If the matching order
   |               is related to confounding factors (possibly age or
   |               calendar time) then biases may result.  Therefore it is
   |               generally considered good practice when using the GREEDY
   |               method to randomly sort both the cases and controls
   |               before beginning the matching process.
   |
   |   R    seedco=seed value used to randomly sort the controls prior to
   |               matching using the GREEDY method.  This seed value must
   |               also be an integer less than (2**31)-1.
   |
   | **** Options specific to OPTIMAL method ***************************
   |        mincont=minimum number of controls per case using the OPTIMAL
   |                method with a variable number of controls(see Section
   |                3.3 of Rosenbaum).  MINCONT must be >=1.
   |
   |        maxcont=maximum number of controls per case using the OPTIMAL
   |                method with a variable number of controls(see Section
   |                3.3 of Rosenbaum).
   |                MAXCONT must be >= MINCONT and <= M-N+1.
   |
   |        maxiter=maximum number of iterations for PROC NETFLOW to use
   |                under the OPTIMAL method.  Default value is 100000.
   |
   | **** OUTPUT options applicable to either method ******************
   | print= Option to print data for matched cases. Use PRINT=y to
   |        print data and PRINT=n or blank to not print.  Default is y.
   |
   |        out=name of SAS data set containing the results of the matching
   |            process.  Unmatched cases are not included.  See outnm
   |            below.  The default name is __out.  This data set will have
   |            the following layout:
   |
   |          Case_id  Cont_id  Cont_n  Dij  Delta_caco MVARS_ca  MVARS_co
   |             1        67      1     5.2  (Differences & actual
   |             1        78      2     6.1   values for matching factors
   |             2        52      1     2.9   for cases & controls)
   |             2        92      2     3.1
   |             .        .       .      .
   |             .        .       .      .
   |
   |        outnmca=name of SAS data set containing NON-matched cases.
   |                Default name is __nmca .
   |
   |        outnmco=name of SAS data set containing NON-matched controls.
   |                Default name is __nmco .
   |
   |
   |  References:  Bergstralh, EJ and Kosanke JL(1995).  Computerized
   |               matching of controls.  Section of Biostatistics
   |               Technical Report 56.  Mayo Foundation.
   |
   |               Paul R.  Rosenbaum.  Optimal matching for observational
   |               studies.  JASA, 84(408), pp. 1024-1032, 1989.
   |
   |  Example: 1-1 matching by male(exact), age(+-2) and year(+-5).
   |           The wt for male is not relevant, as only exact matches
   |           on male will be considered.  The weight for age(2) is
   |           double that for year(1).
   |
   |      A. Optimal method.
   |
   |       %match(case=case,control=cont,idca=clinic,idco=clinic,
   |              mvars=male age_od yr_od,maxiter=10000,
   |              wts=2 2 1, dmaxk=0 2 5,out=mtch,
   |              method=optimal);
   |
   |      B. Greedy method.
   |
   |       %match(case=case,control=cont,idca=clinic,idco=clinic,
   |              mvars=male age_od yr_od,
   |              wts=2 2 1, dmaxk=0 2 5,out=mtch,
   |              method=greedy,seedca=87877,seedco=987973);
   |
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
 
%MACRO MATCH(CASE=,CONTROL=,IDCA=,IDCO=,MVARS=,WTS=,DMAXK=,DMAX=,
             NCONTLS=1, TIME=,
             METHOD=,SEEDCA=,SEEDCO=,MAXITER=100000,PRINT=y,
             OUT=__OUT,OUTNMCA=__NMCA,OUTNMCO=__NMCO,MINCONT=,MAXCONT=);
 
   %LET BAD=0;
   %IF %LENGTH(&CASE)=0 %THEN %DO;
      %PUT ERROR: NO CASE DATASET SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %LENGTH(&CONTROL)=0 %THEN %DO;
      %PUT ERROR: NO CONTROL DATASET SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %LENGTH(&IDCA)=0 %THEN %DO;
      %PUT ERROR: NO IDCA VARIABLE SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %LENGTH(&IDCO)=0 %THEN %DO;
      %PUT ERROR: NO IDCO VARIABLE SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %LENGTH(&MVARS)=0 %THEN %DO;
      %PUT ERROR: NO MATCHING VARIABLES SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %LENGTH(&WTS)=0 %THEN %DO;
      %PUT ERROR: NO WEIGHTS SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %UPCASE(&METHOD)=GREEDY %THEN %DO;
      %IF %LENGTH(&SEEDCA)=0 %THEN %DO;
         %PUT ERROR: NO SEEDCA VALUE SUPPLIED;
         %LET BAD=1;
      %END;
      %IF %LENGTH(&SEEDCO)=0 %THEN %DO;
         %PUT ERROR: NO SEEDCO VALUE SUPPLIED;
         %LET BAD=1;
      %END;
   %END;
   %IF %LENGTH(&OUT)=0 %THEN %DO;
      %PUT ERROR: NO OUTPUT DATASET SUPPLIED;
      %LET BAD=1;
   %END;
   %IF %UPCASE(&METHOD)^=GREEDY & %UPCASE(&METHOD)^=OPTIMAL %THEN %DO;
      %PUT ERROR: METHOD MUST BE GREEDY OR OPTIMAL;
      %LET BAD=1;
   %END;
   %IF (&MINCONT=  AND &MAXCONT^= ) OR (&MINCONT^=  AND &MAXCONT= )
   %THEN %DO;
      %PUT ERROR: MINCONT AND MAXCONT MUST BOTH BE SPECIFIED;
      %LET BAD=1;
   %END;
   %LET NVAR=0;
   %DO %UNTIL(%SCAN(&MVARS,&NVAR+1,' ')= );
      %LET NVAR=%EVAL(&NVAR+1);
   %END;
   %LET NWTS=0;
   %DO %UNTIL(%QSCAN(&WTS,&NWTS+1,' ')= );
      %LET NWTS=%EVAL(&NWTS+1);
   %END;
   %IF &NVAR^= &NWTS %THEN %DO;
      %PUT ERROR: #VARS MUST EQUAL #WTS;
      %LET BAD=1;
   %END;
   %LET NK=0;
   %IF %QUOTE(&DMAXK)^=  %THEN %DO %UNTIL(%QSCAN(&DMAXK,&NK+1,' ')= );
      %LET NK=%EVAL(&NK+1);
   %END;
   %IF &NK>&NVAR %THEN %LET NK=&NVAR;
   %DO I=1 %TO &NVAR;
      %LET V&I=%SCAN(&MVARS,&I,' ');
   %END;
   %IF &NWTS>0 %THEN %DO;
        DATA _NULL_;
        %DO I=1 %TO &NWTS;
             %LET W&I=%SCAN(&WTS,&I,' ');
             IF &&W&I<0 THEN DO;
                  PUT 'ERROR: WEIGHTS MUST BE NON-NEGATIVE';
                  CALL SYMPUT('BAD','1');
             END;
        %END;
        RUN;
   %END;
   %IF &NK>0 %THEN %DO;
        DATA _NULL_;
        %DO I=1 %TO &NK;
             %LET K&I=%SCAN(&DMAXK,&I,' ');
             IF &&K&I<0 THEN DO;
                  PUT 'ERROR: DMAXK VALUES MUST BE NON-NEGATIVE';
                  CALL SYMPUT('BAD','1');
             END;
        %END;
        RUN;
   %END;
   %MACRO DIJ;
      %DO I=1 %TO &NVAR-1;
         &&W&I*ABS(__CA&I-__CO&I) +
      %END;
      &&W&NVAR*ABS(__CA&NVAR-__CO&NVAR);
   %MEND DIJ;
   %MACRO MAX1;
      %IF &DMAX^= %THEN %DO;
         & __D<=&DMAX
      %END;
      %DO I=1 %TO &NK;
         & ABS(__CA&I-__CO&I)<=&&K&I
      %END;
   %MEND MAX1;
   %MACRO MAX2;
      %IF &DMAX= & &NK=0 %THEN %DO;
         %IF &time^= %then %do;
            if __cotime>__catime then
         %end;
         output;
      %end;
      %IF &DMAX^= & &NK=0 %THEN %DO;
         IF _COST_<=&DMAX
         %if &time^= %then %do;
            & __cotime>__catime
         %end;
         THEN OUTPUT;
      %END;
      %IF &DMAX= & &NK>0 %THEN %DO;
         IF ABS(__CA1-__CO1)<=&K1
         %DO I=2 %TO &NK;
            & ABS(__CA&I-__CO&I)<=&&K&I
         %END;
         %if &time^= %then %do;
            & __cotime>__catime
         %end;
         THEN OUTPUT;
      %END;
      %IF &DMAX^= & &NK>0 %THEN %DO;
         IF _COST_<=&DMAX
         %DO I=1 %TO &NK;
            & ABS(__CA&I-__CO&I)<=&&K&I
         %END;
         %if &time^= %then %do;
            & __cotime>__catime
         %end;
         THEN OUTPUT;
      %END;
   %MEND MAX2;
   %MACRO LBLS;
      %DO I=1 %TO &NVAR;
         __CA&I="&&V&I/CASE"
         __CO&I="&&V&I/CONTROL"
         __DIF&I="&&V&I/ABS. DIFF "
         __WT&I="&&V&I/WEIGHT"
      %END;
   %MEND LBLS;
   %MACRO VBLES;
      %DO I=1 %TO &NVAR;
         __DIF&I
      %END;
      %DO I=1 %TO &NVAR;
         __CA&I __CO&I
      %END;
   %MEND VBLES;
   %MACRO GREEDY;
    %GLOBAL BAD2;
      DATA __CASE; SET &CASE;
           %DO I=1 %TO &NVAR;
                %LET MISSTEST=%SCAN(&MVARS,&I,' ');
                IF &MISSTEST=. THEN DELETE;
           %END;
           %IF &TIME^= %THEN %DO;
                IF &TIME=. THEN DELETE;
           %END;
      DATA __CASE; SET __CASE END=EOF;
       KEEP __IDCA __CA1-__CA&NVAR __R &mvars
       %if &time^= %then %do;
             __catime
          %end;
          ;
         __IDCA=&IDCA;
         %if &time^= %then %do;
            __catime=&time;
         %end;
         %DO I=1 %TO &NVAR;
            __CA&I=&&V&I;
         %END;
         SEED=&SEEDCA;
         __R=RANUNI( SEED  );
         IF EOF THEN CALL SYMPUT('NCA',_N_);
      PROC SORT; BY __R __IDCA;
      DATA __CONT; SET &CONTROL;
           %DO I=1 %TO &NVAR;
                %LET MISSTEST=%SCAN(&MVARS,&I,' ');
                IF &MISSTEST=. THEN DELETE;
           %END;
           %IF &TIME^= %THEN %DO;
                IF &TIME=. THEN DELETE;
           %END;
      DATA __CONT; SET __CONT END=EOF;
       KEEP __IDCO __CO1-__CO&NVAR __R &mvars
        %if &time^= %then %do;
           __cotime
        %end;
        ;
         __IDCO=&IDCO;
         %if &time^= %then %do;
            __cotime=&time;
         %end;
         %DO I=1 %TO &NVAR;
            __CO&I=&&V&I;
         %END;
         SEED=&SEEDCO;
         __R=RANUNI( SEED  );
         IF EOF THEN CALL SYMPUT('NCO',_N_);
      RUN;
      %LET BAD2=0;
      %IF &NCO < %EVAL(&NCA*&NCONTLS) %THEN %DO;
         %PUT ERROR: NOT ENOUGH CONTROLS TO MAKE REQUESTED MATCHES;
         %LET BAD2=1;
      %END;
      %IF &BAD2=0 %THEN %DO;
         PROC SORT; BY __R __IDCO;
         DATA __MATCH;
          KEEP __IDCA __CA1-__CA&NVAR __DIJ __MATCH __CONT_N
          %if &time^= %then %do;
             __catime __cotime
          %end;
          ;
          ARRAY __USED(&NCO) $ 1 _TEMPORARY_;
            DO __I=1 TO &NCO;
               __USED(__I)='0';
            END;
            DO __I=1 TO &NCONTLS;
               DO __J=1 TO &NCA;
                  SET __CASE POINT=__J;
                  __SMALL=.;
                  __MATCH=.;
                  DO __K=1 TO &NCO;
                     IF __USED(__K)='0' THEN DO;
                        SET __CONT POINT=__K;
                        __D=%DIJ
                        IF __d^=. & (__SMALL=. | __D<__SMALL) %MAX1
                        %if &time^= %then %do;
                           & __cotime > __catime
                        %end;
                        THEN DO;
                           __SMALL=__D;
                           __MATCH=__K;
                           __DIJ=__D;
                           __CONT_N=__I;
                        END;
                     END;
                  END;
                  IF __MATCH^=. THEN DO;
                     __USED(__MATCH)='1';
                     OUTPUT;
                  END;
               END;
            END;
            STOP;
         DATA &OUT;
          SET __MATCH;
          SET __CONT POINT=__MATCH;
          KEEP __IDCA __IDCO __CONT_N __DIJ __CA1-__CA&NVAR
               __CO1-__CO&NVAR __DIF1-__DIF&NVAR __WT1-__WT&NVAR
               %if &time^= %then %do;
                  __catime __cotime
               %end;
        ;
          LABEL __IDCA="&IDCA/CASE"
                __IDCO="&IDCO/CONTROL"
                %if &time^= %then %do;
                   __catime="&time/CASE"
                   __cotime="&time/CONTROL"
                %end;
                __CONT_N='CONTROL/NUMBER'
                __DIJ='DISTANCE/D_IJ'
                %LBLS;
             %DO I=1 %TO &NVAR;
                __DIF&I=abs(__CA&I-__CO&I);
                __WT&I=&&W&I;
             %END;
      %END;
   %MEND GREEDY;
   %MACRO OPTIMAL;
    %GLOBAL BAD2;
      DATA __CASE; SET &CASE;
           %DO I=1 %TO &NVAR;
                %LET MISSTEST=%SCAN(&MVARS,&I,' ');
                IF &MISSTEST=. THEN DELETE;
           %END;
           %IF &TIME^= %THEN %DO;
                IF &TIME=. THEN DELETE;
           %END;
      DATA __CASE; SET __CASE END=EOF;
       KEEP __IDCA __CA1-__CA&NVAR &mvars
         %if &time^= %then %do;
            __catime
         %end;
         ;
         __IDCA=&IDCA;
         %if &time^= %then %do;
            __catime=&time;
         %end;
         %DO I=1 %TO &NVAR;
            __CA&I=&&V&I;
         %END;
         IF EOF THEN CALL SYMPUT('NCA',_N_);
      DATA __CONT; SET &CONTROL;
           %DO I=1 %TO &NVAR;
                %LET MISSTEST=%SCAN(&MVARS,&I,' ');
                IF &MISSTEST=. THEN DELETE;
           %END;
           %IF &TIME^= %THEN %DO;
                IF &TIME=. THEN DELETE;
           %END;
      DATA __CONT; SET __CONT END=EOF;
       KEEP __IDCO __CO1-__CO&NVAR &mvars
         %if &time^= %then %do;
            __cotime
         %end;
         ;
         __IDCO=&IDCO;
         %if &time^= %then %do;
            __cotime=&time;
         %end;
         %DO I=1 %TO &NVAR;
            __CO&I=&&V&I;
         %END;
         IF EOF THEN CALL SYMPUT('NCO',_N_);
      RUN;
      %LET BAD2=0;
      %IF &NCO < %EVAL(&NCA*&NCONTLS) %THEN %DO;
         %PUT ERROR: NOT ENOUGH CONTROLS TO MAKE REQUESTED MATCHES;
         %LET BAD2=1;
      %END;
      %IF &BAD2=0 %THEN %DO;
         DATA __DIST1;
          SET __CASE;
          LENGTH __FROM __TO $ 80;
            DO I=1 TO &NCO;
               SET __CONT POINT=I;
               _COST_=%DIJ;
               __FROM=left(__IDCA);
               __TO=left(trim(__IDCO) || '_co');
               _CAPAC_=1;
               IF _COST_^=. THEN DO;
                  %MAX2
               END;
            END;
            DATA __GOODCO;
             SET __DIST1;
             KEEP __IDCO;
            PROC SORT; BY __IDCO;
            DATA __GOODCO;
             SET __GOODCO; BY __IDCO;
               IF FIRST.__IDCO;
            data _null_;
               i=1;
               set __goodco point=i nobs=n;
               call symput('newcont',n);
               stop;
            DATA __DIST2;
             LENGTH __FROM __TO $ 80;
               DO I=1 TO N;
                  SET __GOODCO POINT=I NOBS=N;
                  __FROM=left(trim(__IDCO) || '_co');
                  __TO='SK';
                  _COST_=0;
                  _CAPAC_=1;
                  OUTPUT;
               END;
            STOP;
            DATA __GOODCA;
             SET __DIST1;
             KEEP __IDCA;
            PROC SORT; BY __IDCA;
            DATA __GOODCA;
             SET __GOODCA; BY __IDCA;
               IF FIRST.__IDCA;
            DATA __DIST3;
             LENGTH __FROM __TO $ 80;
               DO I=1 TO N;
                  SET __GOODCA POINT=I NOBS=N;
                  __FROM='SC';
                  __TO=left(__idca);
                  _COST_=0;
                  %if &mincont= %then %do;
                     _CAPAC_=&NCONTLS;
                  %end;
                  %else %do;
                     _capac_=&mincont;
                  %end;
                  OUTPUT;
               END;
               %if &mincont^= %then %do;
                  __from='SC';
                  __to='EXTRA';
                  _capac_=&newcont-&mincont*n;
                  _cost_=0;
                  output;
                  do i=1 to n;
                     set __goodca point=i;
                     __from='EXTRA';
                     __to=left(__idca);
                     _cost_=0;
                     _capac_=&maxcont-&mincont;
                     output;
                  end;
               %end;
               CALL SYMPUT('NEWCASE',N);
            STOP;
            DATA __DIST;
             SET __DIST1 __DIST2 __DIST3;
         %LET DEM=%EVAL(&NEWCASE*&NCONTLS);
         PROC NETFLOW
            MAXIT1=&MAXITER
            %if &mincont= %then %do;
               DEMAND=&DEM
            %end;
            %else %do;
               demand=&newcont
            %end;
            SOURCENODE='SC'
            SINKNODE='SK'
            ARCDATA=__DIST
            ARCOUT=__MATCH;
          TAIL __FROM;
          HEAD __TO;
         DATA __OUT;
          SET __MATCH;
            IF _FLOW_>0 & __FROM^in ('SC' 'EXTRA') & __TO^='SK';
            __DIJ=_FCOST_;
            %DO I=1 %TO &NVAR;
               __DIF&I=abs(__CA&I-__CO&I);
               __WT&I=&&W&I;
            %END;
         PROC SORT; BY __IDCA __DIJ;
         DATA &OUT;
          SET __OUT; BY __IDCA;
            drop __from -- _status_;
            IF FIRST.__IDCA THEN __CONT_N=0;
            __CONT_N+1;
          LABEL __IDCA="&IDCA/CASE"
                __IDCO="&IDCO/CONTROL"
                %if &time^= %then %do;
                   __catime="&time/CASE"
                   __cotime="&time/CONTROL"
                %end;
                __CONT_N='CONTROL/NUMBER'
                __DIJ='DISTANCE/D_IJ'
                %LBLS;
      %END;
   %MEND OPTIMAL;
   %IF &BAD=0 %THEN %DO;
      %IF %UPCASE(&METHOD)=GREEDY %THEN %DO;
         %GREEDY
      %END;
      %ELSE %DO;
         %OPTIMAL
      %END;
      %IF &BAD2=0 %THEN %DO;
         PROC SORT DATA=&OUT; BY __IDCA __CONT_N;
         proc sort data=__case; by __IDCA;
         data &outnmca; merge __case
              &out(in=__inout where=(__cont_n=1)); by __idca;
              if __inout=0; **non-matches;
 
         proc sort data=__cont; by __IDCO;
         proc sort data=&out; by __IDCO;
         data &outnmco; merge __cont
              &out(in=__inout); by __idco;
              if __inout=0; **non-matched controls;
         proc sort data=&out; by __IDCA; **re-sort by case id;
 
         %if %upcase(&print)=Y %then %do;
         PROC PRINT data=&out LABEL SPLIT='/';
          VAR __IDCA __IDCO __CONT_N
          %if &time^= %then %do;
             __catime __cotime
          %end;
          __DIJ %VBLES;
          sum __dij;
         title9'Data listing for matched cases and controls';
         footnote
    "match macro: case=&case control=&control idca=&idca idco=&idco";
         footnote2
"   mvars=&mvars  wts=&wts dmaxk=&dmaxk dmax=&dmax ncontls=&ncontls";
         %if &time^= %then %do;
  footnote3"time=&time  method=&method  seedca=&seedca  seedco=&seedco";
         %end;
         %else %do;
           footnote3"   method=&method  seedca=&seedca  seedco=&seedco";
         %end;
         footnote4"   out=&out   outnmca=&outnmca  outnmco=&outnmco";
         run;
         title9'Summary data for matched cases and controls';
         proc means data=&out n mean sum min max; class __cont_n;
          var __dij
           %if &nvar >=2 %then %do; __dif1-__dif&nvar  __ca1-__ca&nvar
                             %if &time^= %then %do;
                                __catime
                             %end;
                             __co1-__co&nvar
                             %if &time^= %then %do;
                                __cotime
                             %end;
                             ;
           %end;
           %else %do;
                             __dif1 __ca1
                             %if &time^= %then %do;
                                __catime
                             %end;
                             __co1
                             %if &time^= %then %do;
                                __cotime
                             %end;
                             ;
           %end;
         run;
         proc means data=&outnmca n mean sum min max; var &mvars;
         title9'Summary data for NON-matched cases';
         run;
         proc means data=&outnmco n mean sum min max; var &mvars;
         title9'Summary data for NON-matched controls';
         run;
         %end;
      %END;
   %END;
    title9; footnote;
    run;
%MEND MATCH;
 

