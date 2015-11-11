   /*------------------------------------------------------------------*
   | The documentation and code below is supplied by HSR CodeXchange.             
   |              
   *------------------------------------------------------------------*/
                                                                                      
                                                                                      
                                                                                      
  /*------------------------------------------------------------------*
   | MACRO NAME  : dist
   | SHORT DESC  : Computes a distance matrix between a set of
   |               cases and a set of potential controls
   *------------------------------------------------------------------*
   | CREATED BY  : Kosanke, Jon                  (03/25/2004 16:57)
   |             : Bergstralh, Erik
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Compute a distance matrix(SAS dataset) between a group of cases
   | and a group of potential controls.  The SAS dataset can be
   | used  as input for the variable optimal matching macro(vmatch).
   | Optionally, one can do optimal variable matching within the
   | DIST macro.
   |
   | Replacement for OPTIMAL matching using %MATCH macro.
   |
   | The distance between cases and controls, Dij, is defined as the weighted
   | sum of the absolute differences between the case and control matching
   | factors, i.e.,
   |
   |     Dij= SUM { W.k*ABS(X.ik-X.jk) }, where the sum is over the number
   |                                      of matching factors X(with index
   |                                      k) and W.k = the weight assigned
   |                                      to matching factor k and X.ik =
   |                                      the value of variable X(k) for
   |                                      subject i.
   | or the weighted Euclidean distance,
   |
   |    Dij= SQRT[ SUM{ W.k*(X.ik-X.jk)^2} ].
   |
   |
   | The higher the user-defined weight, the more likely it is that the case
   | and control will be matched on the factor.  Assign large weights (relative
   | to the other weights) to obtain exact matches for two-level factors such
   | as gender. Note that as an option to weights, all variables may be
   | transformed to mean 0 and variance 1 or to ranks using the TRANSF option.
   |
   | Calipers may be used to further restrict matching.  Specifically the
   | control(j) selected for a case(i) may be required to have Dij less than or
   | equal DMAX and/or differences in each variable k may be restricted to be
   | within the range specifed by the DMAXK option.
   |
   | Date written:  1/16/2001...finished 11/15/2002
   |                7/23/2003...minor updates to output
   |                11/27/2003..minor updates to ouput datasets
   |
   | Call Statement:
   |
   |      %dist(data=,id=,group=,mvars=,wts=,dmax=,dmaxk=,time=,transf=,dist=,out=,
   |            vmatch=,a=,b=,lilm=,outm=,printm=);
   |
   | Parameter Definitions: *=required
   |
   | *data    SAS dataset containing both cases and potenial controls.
   |
   | *id      SAS CHARACTER ID variable.
   |
   | *group   SAS variable defining cases. Group=1 if case, 0 if control.
   |
   | *mvars   List of numeric matching variables.
   |
   | *wts     List of positive weights associated with each matching
   |          variable.
   |
   | dmax    Maximum allowable distance. Distances>dmax will be set to missing.
   |         (Missing distances are not used in the vmatch macro.)
   |
   | dmaxk   List of calipers associated with each matching variable. Distances
   |         with absolute case/control differences>dmaxk for variable k will be
   |         set to missing.
   |
   | time    Time variable used to define risk sets.  Distances will only
   |         be calculated if the control time > case time.
   |
   | transf  Indicates whether all matching vars are to be transformed
   |         (using the combined case+control data) prior to
   |         computing distances.  0=no, 1=standardize to mean 0
   |         and variance 1, 2=use ranks of matching variables.
   |
   | dist    Indicates type of distance to calculate. Default=1.
   |
   |         1=weighted sum(over matching vars) of
   |           absolute case-control differences.
   |
   |         2=weighted Euclidean distance
   |
   | out     Name of output SAS dataset for distance matrix.  Dataset has one
   |         row for each case and one column for each potential control. The
   |         column names are _C1, _C2, ... , _CM for the M potential controls.
   |         With 1 million or more potential controls these variable names
   |         will exceed 8 characters, which is only supported in SAS Version 8.
   |         Variable labels are the original ID numbers for the controls.
   |         The value of the i-th row of the j-th control column is the distance
   |         between case i and control j.  Default name is _dist.
   |
   | printd  Print distance matrix. Indicate print=Y to print. Default is
   |         not to print.
   |
   |     ********** options related to variable optimal matching*****;
   |
   | vmatch  Indicates whether variable optimal matching between cases and
   |         controls is desired(Y) or not(N). Default is not to match.
   |
   |     a   Minimum number of controls to match to each case using variable
   |         optimal matching.
   |
   |     b   Maximum number of controls to match to each case using variable
   |         optimal matching.
   |
   |  lilm   Total number of controls to be matched. Must not exceed number
   |         of controls(&group=0) in &data.
   |
   |   outm  Name of output dataset for matching results. Default is
   |         _match.
   |
   | printm  Indicates whether(Y) or not(N) to print matching results.
   |         Default is not to print.
   |
   | summatch Indicates if a detailed summary of the matching results is
   |          to be printed(Y), including group means. Default is not
   |          to print.  Summary datasets are  __goodm (1 obs/control)
   |          and __camcon (1 obs/matched set).
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
   | EXAMPLES
   |
   | Calculate & print distance matrix with 2 matching vars,
   | perform variable(1 to 3) matching with 8 total controls
   | and print summaries.
   | (see sample data at end of program)
   |
   | %dist(data=all,group=group,id=mc,
   |       mvars=hypert hxmist, wts=1 1,
   |       dmax=, out=alld, printd=y,
   |       vmatch=y, a=1, b=3, lilm=8, printm=y, summatch=y);
   |
   | More examples located at bottom of code.
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
 
%macro dist(data=,id=,group=,mvars=,wts=,dmax=,dmaxk=,
            time=,transf=0,dist=1,out=_dist,printd=n,
            vmatch=n,a=,b=,lilm=,outm=_match,printm=n,summatch=n);
 
 
  %global firstco lastco nvar _match; *10.22.03--added _match;
 
 
  %let bad=0;
   %IF %LENGTH(&MVARS)=0 %THEN %DO;
      %PUT 'ERROR: NO MATCHING VARIABLES SUPPLIED';
      %LET BAD=1;
   %END;
 
   %IF %LENGTH(&WTS)=0 %THEN %DO;
      %PUT 'ERROR: NO WEIGHTS SUPPLIED';
      %LET BAD=1;
   %END;
   %LET NVAR=0;
   %DO %UNTIL(%SCAN(&MVARS,&NVAR+1,' ')= );
      %LET NVAR=%EVAL(&NVAR+1);
   %END;
   %LET NWTS=0;
   %DO %UNTIL(%SCAN(&WTS,&NWTS+1,' ')= );
      %LET NWTS=%EVAL(&NWTS+1);
   %END;
   %IF &NVAR^= &NWTS %THEN %DO;
      %PUT 'ERROR: #VARS MUST EQUAL #WTS';
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
 
   %IF %upcase(&vmatch)=Y
       and (&a= or &b= or &lilm= ) %then %do;
      %PUT 'ERROR: VMATCH option, but missing a, b, or lilm';
      %LET BAD=1;
   %END;
 
  %if &bad=0 %then %do;
 
 *** delete obs with missing mvar or id var from input dataset;
data _check;
 set &data;
 dum=.;
 __id=&id;
  if __id="" then delete;
  %do z=1 %to &nvar;
    if %scan(&mvars,&z)=. then delete;
  %end;
  %if &time^= %then %do;
      if &time lt 0 then delete;
  %end;
 keep __id &id &group dum &mvars &time;
 run;
 proc sort data=_check; by &group __id; **was &id;
*** transform data if requested/separate cases & controls;
 %if &transf=1 %then %do;
proc standard data=_check m=0 s=1 out=_stdzd; var &mvars;
 data _caco;
      set _stdzd;
 %end;
 
 %if &transf=2 %then %do;
proc rank data=_check out=_ranks; var &mvars;
data _caco;
       set _ranks;
 %end;
 
 %if &transf=0 %then %do;
data _caco;
       set _check;
 %end;
 
data _case; set _caco;
 if &group=1;
 rename
     %do k=1 %to &nvar;
       %scan(&mvars,&k)=__ca&k
     %end;
     ;
 %if &time^= %then %do;
  __tca=&time;
  drop &time;
 %end;
 %else %do;
  __tca=.;
 %end;
 run;
 
data _cont; set _caco;
 if &group=0;
 
 __contid="_C" || left(put( _n_,best10.)); *assign dummy names to controls;
 __labl="_L" || left(put( _n_,best10.)); *assign label names to controls;
 call symput(__labl,__id); *assign mvars _L1,_L2, etc to original var names;
 
 rename
     %do k=1 %to &nvar;
       %scan(&mvars,&k)=__co&k
     %end;
     ;
 %if &time^= %then %do;
  __tco=&time;
  drop &time;
 %end;
 %else %do;
  __tco=.;
 %end;
  run;
  %put &_L1 &_L2 &_L3 &_L4;
 * proc print data=_cont;
 
 %nobs(dsn=_case,macvar=ncase);
 %nobs(dsn=_cont,macvar=ncont);
run;
 
 
**compute distance matrix;
data &out;
 keep &id  _C1-_C&ncont;
 
 do i=1 to &ncase; **no. cases;
  set _case point=i;
  array dij[*] _C1-_C&ncont;
  do j=1 to &ncont; **no. controls;
   set _cont(drop=&id) point=j;
    %if &dist=2 %then %do;
      **wtd euclidian dist;
      dij[j]= sqrt(
        %do k=1 %to &nvar;
         %scan(&wts,&k)*(__ca&k - __co&k)**2
         %if &k<&nvar %then + ;
        %end;
       );
    %end;
    %else %do;
      **wtd sum absolute diff;
      dij[j]=
       %do k=1 %to &nvar;
         %scan(&wts,&k)*abs(__ca&k - __co&k )
         %if &k<&nvar %then + ;
         %end;
             ;
    %end;
    **total distance caliper;
    %if &dmax ^=  %then  %do;
      if dij[j]>&dmax then dij[j]=.; **distance too large;
    %end;
 
    ** case-control delta not within calipers for var k**;
    %if %quote(&dmaxk)^= %then %do;
      %do k=1 %to &nvar;
        if abs(__ca&k - __co&k)>%scan(&dmaxk,&k,' ') then dij[j]=.;
      %end;
    %end;
 
    %if &time ^= %then %do;
       if __tco le __tca then dij[j]=.; **control j not in risk set for
                                        case i;
    %end;
 
  end; ** end of loop for controls;
  output;
 end; ** end of loop for cases;
 stop;
 %end;
 run;
  %if %upcase(&printd)=Y %then %do;
 proc print label data=&out;
    label
  %do zz=1 %to &ncont; _C&zz=&&_L&zz %end;
 ;
 
 
  %end;
 footnote"Dist macro: data=&data  id=&id  group=&group  mvars=&mvars wts=&wts";
 footnote2"dmaxk=&dmaxk dmax=&dmax  time=&time  transf=&transf  dist=&dist  out=&out";
 run;
  %if %upcase(&vmatch)=Y %then %do;
         %vmatch(dist=&out,idca=&id,a=&a,b=&b,lilm=&lilm,n=&ncase,
         firstco=_C1,lastco=_C&ncont,
         print=&printm,fixprt=Y,out=&outm);
 
   %if %upcase(&summatch)=Y %then %do;
 
     data goodca; merge &outm(in=inm) _case(rename=(__id=idca)); by idca;
         if inm;
     proc sort data=goodca; by idca idco;
     * proc print;
     proc sort data=&outm; by idco;
     proc sort data=_cont; by __id;
     data goodco; merge &outm(in=inm) _cont(rename=(__id=idco)); by idco;
         if inm;
     proc sort data=goodco; by idca idco;
    * proc print;
 
     data __goodm; merge goodco goodca; by idca idco;
     keep idca idco __dij __dtime __tca __tco
          %do i=1 %to &nvar;
           __ca&i __co&i  __d&i __absd&i
          %end;
         ;
 
      __dij=dij;
     %do i=1 %to &nvar;
     __d&i=(__ca&i - __co&i); **raw diff;
     __absd&i=abs(__ca&i - __co&i); **abs diff;
     %end;
      __dtime=__tco-__tca;
 
    label
        idca="&id/CASE"
        idco="&id/CONTROL"
        __dij="Weighted/Difference"
        __dtime="&time/TIME DIFF"
        __tca="&time/CASE TIME"
        __tco="&time/CONT TIME"
 
      %do i=1 %to &nvar; %let vvar=%scan(&mvars,&i);
         __absd&i="&vvar/ABS. DIFF"
           __ca&i="&vvar/CASE"
           __co&i="&vvar/CONTROL"
      %end;
         ;
    title9"Listing of Matched Cases and Controls";
    footnote"Dist macro: data=&data  id=&id  group=&group  mvars=&mvars wts=&wts";
    footnote2"dmaxk=&dmaxk dmax=&dmax  time=&time  transf=&transf  dist=&dist  out=&out";
    footnote3" Variable Optimal Matching option: a=&a  b=&b m=&lilm N=&Ncase";
    proc print data=__goodm label split='/'; var idca idco __dij
    %do i=1 %to &nvar;
       __absd&i
    %end;
    %do i=1 %to &nvar;
      __ca&i __co&i
    %end;
     __dtime __tca __tco; sum __dij;
     run;
     title9"Summary statistics--case vs control, one obs per matched control";
     %if &sysver ge 8 %then %do;
    proc means data=__goodm maxdec=3 fw=8
        n mean median min p10 p25 p75 p90 max sum;
    %end;
    %else %do;
    proc means data=__goodm maxdec=3
        n mean min max sum;
    %end;
 
     var __dij
    %do i=1 %to &nvar;
       __absd&i
    %end;
    %do i=1 %to &nvar;
      __ca&i __co&i
    %end;
       __dtime   __tca __tco;
 
    *** estimate matching var means within matched sets for controls;
    proc means data=__goodm n mean noprint; by idca;
         var __dij
    %do i=1 %to &nvar;
      __co&i
    %end;
        __tco;
        output out=mcont n=n_co mean=__dijm
            %do i=1 %to &nvar;
        __com&i
          %end;
        __tcom;
     data onecase; set __goodm; by idca; if first.idca;
     data __camcon; merge onecase mcont; by idca;
 
          keep idca n_co __dijm __dtime __tca __tcom
          %do i=1 %to &nvar;
           __ca&i __com&i  __actd&i __absd&i
          %end;
         ;
 
     %do i=1 %to &nvar;
     __absd&i=abs(__ca&i - __com&i);
     __actd&i=(__ca&i - __com&i);
     %end;
      __dtime=__tcom-__tca;
 
    label
        n_co="No./CONTROLS"
        __dijm="Average/Dij"
        __dtime="&time/Mean Time DIFF"
        __tcom="&time/Mean CONT TIME"
 
      %do i=1 %to &nvar; %let vvar=%scan(&mvars,&i);
         __absd&i="&vvar/Mean ABS. DIFF"
           __com&i="&vvar/Mean CONTROL"
      %end;
         ;
        /*
    proc print data=__camcon label split='/'; var idca n_co
    %do i=1 %to &nvar;
       __absd&i
    %end;
     __dtime
    %do i=1 %to &nvar;
      __ca&i __com&i
    %end;
    __tca __tcom; sum __dijm;
       */
   title9"Summary statistics--case vs mean of matched controls, one obs per case";
   %if &sysver ge 8 %then %do;
    proc means data=__camcon maxdec=3 fw=8
        n mean median min p10 p25 p75 p90 max sum;
    %end;
    %else %do;
    proc means data=__camcon maxdec=3
        n mean min max sum;
    %end;
    var n_co __dijm
    %do i=1 %to &nvar;
       __absd&i
    %end;
    %do i=1 %to &nvar;
      __ca&i __com&i
    %end;
    __dtime   __tca __tcom;
 
   %end; **end  of loop for summatch=y;
  %end;  ** end of loop for vmatch=y;
   run;
 footnote;
 %mend dist;
 
 
  /*
options nocenter ls=130 mprint macrogen;
 
***simple example... 4 cases, 8 potential controls;
data all;
input group mc $2.  x1 tt;
x2=3;
 hypert=x1; hxmist=x2;
if group=0 then x2=4;
cards;
1 01 7  4
1 03 9  6
1 05 22 8
1 07 27 10
0 02 1  5
0 04 2  7
0 06 3  8
0 08 5  8
0 09 8  9
0 10 10 11
0 11 14  12
0 12 18 13
0 13 21 14
0 14 23 15
proc print;
proc means; by group notsorted; var x1 x2;
run;
  */
 
 /*
title"dist macro with vmatch options";
 %dist(data=all,group=group,id=mc,mvars=hypert hxmist,wts=1 1,dmax=,
       out=alld,printd=y,
       vmatch=y,a=1,b=3,lilm=8,printm=y,summatch=y,outm=xxx);
  run;
  proc print data=xxx;
      endsas;
 title"vmatch macro using distance matrix(alld) as input";
 %vmatch(dist=alld,idca=mc,a=1,b=3,lilm=8,n=4,
         firstco=_&firstco,lastco=_&lastco, print=y);
 
  run;
   */
  /*
* %dist(data=all,group=group,mvars=x1 x2,wts=1 1,id=mc,dmax=,time=tt,
                                     out=alldtt,print=y);
 *%dist(data=all,group=group,id=mc,transf=2,out=allr);
 *%dist(data=all,group=group,id=mc,transf=1,out=alls);
run;
 title"no transform...missing cells due to risk sets";
* %vmatch(dist=alldtt,idca=mc,a=1,b=3,lilm=8,n=4,firstco=_02,lastco=_12,
  print=y);
 run;
 title ranks;
* %vmatch(dist=allr,idca=mc,a=1,b=3,lilm=8,n=4,firstco=_02,lastco=_12);
 run;
 title standardized;
* %vmatch(dist=alls,idca=mc,a=1,b=3,lilm=8,n=4,firstco=_02,lastco=_12);
 
* %vmatch(dist=m20,idca=mc,a=1,b=3,lilm=8,n=4,firstco=_02,lastco=_12);
  */
run;
 

