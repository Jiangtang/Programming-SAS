  /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : vmatch
   | SHORT DESC  : Match cases to controls using variable optimal
   |               matching. Replaces OPTIMAL matching option
   |               from %MATCH macro.
   *------------------------------------------------------------------*
   | CREATED BY  : Kosanke, Jon                  (03/25/2004  8:49)
   |             : Bergstralh, Erik
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Match cases to controls using variable optimal matching.
   |
   | Replaces OPTIMAL matching option from %MATCH macro.
   |
   | The vmatch macro matches each of N cases with a minimum of "a"
   | controls to a maximum of "b" controls from a total pool of M controls.
   | The vmatch macro uses the case-contol "distance matrix" as input. This
   | matrix has on row per case and on column per potential control. Each
   | cell entry is the distance, Dij, between the i-th case and the j-th
   | potential control. Output includes the assignments of cases to controls
   | and summaries of the matching efficacy.
   |
   | The "dist" macro can be used to calculate the distance matrix. Controls
   | may be matched to cases by one or more factors(X's).  With optimal
   | matching, the control selected for a particular case will be the one
   | closest to the case in terms of distance(Dij), subject to the goal of
   | minimizing the total Dij over all cases.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :
   | MVS SAS v8    :   YES
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %vmatch  (
   |            dist= ,
   |            idca= ,
   |            a= ,
   |            b= ,
   |            lilm= ,
   |            n= ,
   |            firstco= ,
   |            lastco= ,
   |            out=_match,
   |            print= ,
   |            fixprt=n
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : dist
   | Default   :
   | Type      : Dataset Name
   | Purpose   : Name of distance matrix(SAS dataset). Dist must include
   |             the case id as the first column and have only M
   |             additional columns identifying the M potential controls.
   |             The value of the i-th row of the j-th control column is
   |             the distance from the i-th case to the j-th potential
   |             control. It is recommended that no other variables be
   |             included.
   |
   | Name      : idca
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : ID variable for cases
   |
   | Name      : a
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Minimun no. controls to match to each case.
   |
   | Name      : b
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Maximum no. controls to match to each case.
   |
   | Name      : lilm
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Total number of controls to be matched.
   |
   | Name      : n
   | Default   :
   | Type      : Number (Single)
   | Purpose   : Number of cases to be matched=no. rows of distance matrix.
   |
   | Name      : firstco
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable name of first control column.
   |
   | Name      : lastco
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : Variable name of last control column.
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : out
   | Default   : _match
   | Type      : Dataset Name
   | Purpose   : Name of output dataset containing case/control matches.
   |
   | Name      : print
   | Default   :
   | Type      : Text
   | Purpose   : Print case/control assignment data set(Y).
   |
   | Name      : fixprt
   | Default   : n
   | Type      : Text
   | Purpose   : Y if you are calling VMATCH from the %DIST macro and
   |             want actual control variable names added to output
   |             dataset*(Y).
   |
   *------------------------------------------------------------------*
   | RETURNED INFORMATION
   |
   | Assignments of cases to controls and summaries of the matching efficacy.
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | *** 7 treated power plants, 19 potential controls, Dij ****;
   | data a1;
   |
   |  input trt c1 c2 c4 c6 c7 c8  c10
   |   c11 c12 c13 c14 c15 c16 c17 c19 c21 c23 c25 c26;
   |   array cont{*}
   |   c1 c2 c4 c6 c7 c8  c10
   |   c11 c12 c13 c14 c15 c16 c17 c19 c21 c23 c25 c26 ;
   | cards;
   |  3 28  0 3  22 14 30 17 28 26 28 20 22 23 26 21 18 34 40 28
   |  5 24  3 0  22 10 27 14 26 24 24 16 19 20 23 18 16 31 37 25
   |  9 10 18 14 18  4 12  5 11 9  10 14 12  5 14 22 10 16 22 28
   | 18  7 28 24  8 14  2 10  6 12  0 24 22  4 24 32 20 18 16 38
   | 20 17 20 16 32 18 26 20 18 12 24  0  2 20  6  7  4 14 20 14
   | 22 20 31 28 35 20 29 22 20 14 26 12  9 22  5 15 12  9 11 12
   | 24 14 32 29 30 18 24 17 16  9 22 12 10 17  6 16 14  4  8 17
   |  run;
   | proc print;
   |   run;
   |
   |    *** Table 3 Rosenbaum---1:n, n varies,match all controls***;
   |  *%vmatch(dist=a1,idca=trt,a=1,b=13,lilm=19,n=7,firstco=C1,lastco=C26
   |      ,print=y); **dij=87;
   |  run;
   |  %vmatch(dist=a1,idca=trt,a=1,b=4,lilm=19,n=7,firstco=C1,lastco=C26
   |  ,print=y); **dij=91;
   |  run;
   |
   |  *%vmatch(dist=a1,idca=trt,a=2,b=3,lilm=19,n=7,firstco=C1,lastco=C26
   |  ,print=y); **dij=118;
   |  run;
   |
   | **Table 2 Rosenbaum, 1:2 fixed***;
   | %vmatch(dist=a1,idca=trt,a=2,b=2,lilm=14,n=7,firstco=C1,lastco=C26
   | print=y); **dij=71;
   | run;
   |
   | options  mprint macrogen;
   | ** 2:1 with variable....14 total....beats fixed!!***;
   | %vmatch(dist=a1,idca=trt,a=1,b=3,lilm=14,n=7,firstco=C1,lastco=C26
   | print=y); **dij=45;
   | run;
   | * %vmatch(dist=a1,idca=trt,a=1,b=4,lilm=14,n=7,firstco=C1,lastco=C26
   | print=y); **dij=43;
   | run;
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Ming/Rosenbaum. Substantial gains in bias reduction
   | from matching with a variable number of controls.
   | Biometrics 56, 118-124, March 2000.
   |
   | Ming/Rosenbaum. A note on optimal matching with variable
   | controls using the assignment algorithm.
   | JCGS, Sept 2001.
   |
   | Bergstralh/Kosanke/Jacobsen.  Software for optimal
   | matching in observational studies.
   | Epidemilogy 7, 331-332, 1996.
   |
   | Bergstralh/Kosanke. Mayo Clinic Biostatistic TR 56, 1995.
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
 
/* ***vmatch macro***********************************************;
 
 Purpose: Match cases to controls using variable optimal matching.
 
          Replaces OPTIMAL matching option from %MATCH macro.
 
 The vmatch macro matches each of N cases with a minimum of "a"
 controls to a maximum of "b" controls from a total pool of M controls.
 The vmatch macro uses the case-contol "distance matrix" as input. This
 matrix has on row per case and on column per potential control. Each
 cell entry is the distance, Dij, between the i-th case and the j-th
 potential control. Output includes the assignments of cases to controls
 and summaries of the matching efficacy.
 
 The "dist" macro can be used to calculate the distance matrix. Controls
 may be matched to cases by one or more factors(X's).  With optimal
 matching, the control selected for a particular case will be the one
 closest to the case in terms of distance(Dij), subject to the goal of
 minimizing the total Dij over all cases.
 
 Programmer: E. Bergstralh, J. Kosanke
 
 Date written: 11/15/2001 draft, 11/15/2002 finished.
               7/23/2003 minor changes to output
               10/27/2003 minor changes to output dataset option
 
 Call statement: %vmatch(dist=,idca=,a=,b=,lilm=,n=,firstco=,lastco=,
               out=,print=,fixprt=);
 
 Parameter definitions(*=required):
 
  *dist         Name of distance matrix(SAS dataset). Dist must include
                the case id as the first column and have only M
                additional columns identifying the M potential controls.
                The value of the i-th row of the j-th control column is
                the distance from the i-th case to the j-th potential
                control. It is recommended that no other variables be
                included.
 
  *idca         ID variable for cases
 
  *a            Minimun no. controls to match to each case.
  *b            Maximum no. controls to match to each case.
 
  *lilm         Total number of controls to be matched.
  *n            Number of cases to be matched=no. rows of distance
                matrix.
 
  *firstco      Variable name of first control column.
  *lastco       variable name of last control column.
 
   out          Name of output dataset containing case/control matches.
                Default is _match.
 
   print        Print case/control assignment data set(Y). Default is
                not to print.
 
   fixprt       Y if you are calling VMATCH from the %DIST macro and
                want actual control variable names added to output
                dataset*(Y). Default is no(n).
 
References: Ming/Rosenbaum. Substantial gains in bias reduction
            from matching with a variable number of controls.
            Biometrics 56, 118-124, March 2000.
 
            Ming/Rosenbaum. A note on optimal matching with variable
            controls using the assignment algorithm.
            JCGS, Sept 2001.
 
            Bergstralh/Kosanke/Jacobsen.  Software for optimal
            matching in observational studies.
            Epidemilogy 7, 331-332, 1996.
 
            Bergstralh/Kosanke. Mayo Clinic Biostatistic TR 56, 1995.
 
Example: Power plant example from Rosenbaum(JASA, December 1999).
         n=7 treated/case plants
         m=19 potential control plants
         match ALL 19 controls with 1 to 4 controls matched to each case.
 
  %vmatch(dist=a1,idca=trt,a=1,b=4,lilm=19,n=7,firstco=C1, lastco=C26,
          print=y);
    **see sample data at end of program**;
 
 
  ****************************************************************** */
%macro vmatch(dist=,idca=,a=,b=,lilm=,n=,firstco=,lastco=,
               out=_match,print=,fixprt=n);
 
  data dist1; set &dist;
    alpha=&a;      **min no. controls/case;
    beta=&b;       **max no. controls/case;
    lilm=&lilm;    **total number of controls to be matched;
    N=&n;
    k=n*beta-lilm; **number of sink colums;
    if k lt 0 then k=0;
    call symput('kmv',left(put(k,6.)));
  run;
 
   %put &kmv;
   %macro doit(xx);
      %do x=1 %to &kmv; __s&x=&xx; %end;
   %mend doit;
 
  ***add beta repeat case rows and k sink colums;
 data dist2; set dist1;
  do j=1 to beta;
    if j le alpha then do;
      %if &kmv gt 0 %then %do; %doit(.); %end;
      output;
    end;
    if j gt alpha then do;
      %if &kmv gt 0 %then %do; %doit(0); %end;
      output;
    end;
 end;
*title2 " a=&a b=&b  variable optimal matching";
 
proc assign data=dist2 out=__outt;
 cost &firstco--&lastco
 %if &kmv gt 0 %then %do; __s1-__s&kmv %end;
 ;
 id &idca;
 
data &out; set __outt;
 length __contid $ 12; *10.27.2003;
 drop &firstco--&lastco _assign_ _fcost_
      %if &kmv gt 0 %then %do; __s1-__s&kmv %end;
     ; *10.22.03;
 
  if upcase(left(substr(_assign_,1,3)))="__S" then delete;
                          **remove dummy assignments;
  idcont=_assign_;
  __contid=idcont;
  dij=_fcost_;
  idca=&idca;
  run;
 
  %if %upcase(&fixprt)=Y %then %do;
   ***get real control id****;
  proc sort data=_cont; by __contid;
  proc sort data=&out; by __contid;
  data &out; merge &out(in=inm) _cont(keep=__contid __id); by __contid;
      idco=__id;
      if inm;
      drop __contid __id; **10.22.03;
  proc sort data=&out; by idca idco;
  %end;
 
  run;
 
 %if %upcase(&print)=Y %then %do;
proc print data=&out;  id &idca;
  by &idca;
  var
      %if %upcase(&fixprt)=Y %then %do; idco %end;
      idcont dij;
  sum dij;
footnote
  "Macro vmatch: dist=&dist ,idca=&idca ,a=&a ,b=&b ,lilm=&lilm, n=&n";
 run;
 %end;
 footnote;
 run;
 %mend vmatch;
 
 
 /*
options nocenter ps=58 mprint macrogen;
 
data test;
  %macro doit2(xx);
      %do x=1 %to &xx; c&x=.; %end;
   %mend doit2;
  %doit2(685);
 
 
 do i=1 to 38;
  caseid=i; output;
 end;
 run;
proc print;
%vmatch(test,caseid,1,4,114,38,685);
proc print data=match(obs=20);
run;
endsas;
 */
 
 
  /* *example from Rosenabaum, JASA, Dec 1989 ****;
 *** 7 treated power plants, 19 potential controls, Dij ****;
data a1;
 
 input trt c1 c2 c4 c6 c7 c8  c10
  c11 c12 c13 c14 c15 c16 c17 c19 c21 c23 c25 c26;
  array cont{*}
  c1 c2 c4 c6 c7 c8  c10
  c11 c12 c13 c14 c15 c16 c17 c19 c21 c23 c25 c26 ;
cards;
 3 28  0 3  22 14 30 17 28 26 28 20 22 23 26 21 18 34 40 28
 5 24  3 0  22 10 27 14 26 24 24 16 19 20 23 18 16 31 37 25
 9 10 18 14 18  4 12  5 11 9  10 14 12  5 14 22 10 16 22 28
18  7 28 24  8 14  2 10  6 12  0 24 22  4 24 32 20 18 16 38
20 17 20 16 32 18 26 20 18 12 24  0  2 20  6  7  4 14 20 14
22 20 31 28 35 20 29 22 20 14 26 12  9 22  5 15 12  9 11 12
24 14 32 29 30 18 24 17 16  9 22 12 10 17  6 16 14  4  8 17
 run;
proc print;
  run;
 
   *** Table 3 Rosenbaum---1:n, n varies,match all controls***;
 *%vmatch(dist=a1,idca=trt,a=1,b=13,lilm=19,n=7,firstco=C1,lastco=C26
     ,print=y); **dij=87;
 run;
 %vmatch(dist=a1,idca=trt,a=1,b=4,lilm=19,n=7,firstco=C1,lastco=C26
 ,print=y); **dij=91;
 run;
 
 *%vmatch(dist=a1,idca=trt,a=2,b=3,lilm=19,n=7,firstco=C1,lastco=C26
 ,print=y); **dij=118;
 run;
 
 **Table 2 Rosenbaum, 1:2 fixed***;
 %vmatch(dist=a1,idca=trt,a=2,b=2,lilm=14,n=7,firstco=C1,lastco=C26
,print=y); **dij=71;
 run;
 
 options  mprint macrogen;
 ** 2:1 with variable....14 total....beats fixed!!***;
 %vmatch(dist=a1,idca=trt,a=1,b=3,lilm=14,n=7,firstco=C1,lastco=C26
,print=y); **dij=45;
 run;
 * %vmatch(dist=a1,idca=trt,a=1,b=4,lilm=14,n=7,firstco=C1,lastco=C26
,print=y); **dij=43;
 run;
  */
      run;
 
 

