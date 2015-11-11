  /*------------------------------------------------------------------*
   | MACRO NAME  : survcstd
   | SHORT DESC  : Calculates the C-statistic (concordance, descrimination
   |               idex) for survival data with time dependent
   |               covariates and corresponding SE and 100(1-alpha)%
   |               CI
   *------------------------------------------------------------------*
   | CREATED BY  : Kremers, Walter               (02/10/2006 15:27)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | To calculate the C-statistic (concordance) and standard errors
   | for survival data with time dependent covariates.
   |
   |
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Kremers, Walter               (10/26/2006 14:05)
   |
   | Generalized to provide standard error estimates.
   *------------------------------------------------------------------*
   | MODIFIED BY : Kremers, Walter               (09/18/2008 16:57)
   |
   | Add parameter to name output dataset.
   | Delete working datasets at end of program.
   *------------------------------------------------------------------*
   | OPERATING SYSTEM COMPATIBILITY
   |
   | UNIX SAS v8   :   YES
   | UNIX SAS v9   :   YES
   | MVS SAS v8    :
   | MVS SAS v9    :
   | PC SAS v8     :
   | PC SAS v9     :   YES
   *------------------------------------------------------------------*
   | MACRO CALL
   |
   | %survcstd(
   |            data= ,
   |            start= ,
   |            time= ,
   |            event= ,
   |            score= ,
   |            print=1,
   |            ID= ,
   |            Alpha=0.05,
   |            SEMethod=I,
   |            nadj=0,
   |            out=SurvCs_
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : The SAS data set for calculations
   |
   | Name      : start
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : the start time variable
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : The stop time variable
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : the event variable where 0 indicates censored and 1 indicates an event
   |
   | Name      : score
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : the predictor, a single varaible                                                        ;
   |
   | Name      : ID
   | Default   :
   | Type      : Text
   | Purpose   : Sampling unit (patient) identifier, required if (start, stop time) format used for data
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : print
   | Default   : 1
   | Type      : Number (Single)
   | Purpose   : takes the value 1 to print out summary output and c-statistis, 0 to suppress
   |
   | Name      : Alpha
   | Default   : 0.05
   | Type      : Number (Single)
   | Purpose   : Alpha level for 100(1-alpha)% two sided confidence intervals
   |
   | Name      : SEMethod
   | Default   : I
   | Type      : Text
   | Purpose   : - I (default) for an an approximate jackkinfe, J for Jackkinfe and D for direct method
   |             - Direct method is very time intensive for large samples, order (N**3)/2
   |             direct method should NOT BE USED FOR LARGE DATA SETS, e.g. more thatn 1000 subjects
   |             - I and J order N**2
   |             - When the Direct method is used CIs are also derived using Fieller s Theorem
   |
   | Name      : nadj
   | Default   : 0
   | Type      : Number (Single)
   | Purpose   : - 1 for (n-1)/n adjustment to approximate jackkinfe,
   |             0 (default, recomended) for no adjustment
   |
   | Name      : out
   | Default   : SurvCs_
   | Type      : Text
   | Purpose   : Output dataset
   |
   *------------------------------------------------------------------*
   | ADDITIONAL NOTES
   |
   | Runs under UNIX (tested) as well as PC.
   | Presumably runs under all SAS environments but not tested.
   |
   |
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | proc phreg data=phrtd1 ;
   |   model (start, time) * event(0) = x1 x2 / ties=efron ;
   |   id patient_id ;
   |   output out=out01 XBETA=score ;
   | run ;
   |
   | %SurvCsTD(data=out01, id=patient_id, start=start, time=time, event=event, score=score) ;
   |
   |
   |
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | Walter K Kremers, 2006, Concordance for Survival Time Data Including
   | Time-Dependent Covariates Accounting for Ties in Predictor and Time,
   | Technical Report
   |
   |
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
 
***** SurvCSTDSE_02_061024.sas ********************************************************************;
*****   (Survial C Statistic for Time Dependent with Standard Error Estimates )               *****;
***** Author: Walter K Kremers                                                                *****;
***** First Program Date: 8Mar2006                                                            *****;
***** Last update Date: 26Apr2006                                                             *****;
***** Macro and some datasets renamed for consistency with old version. 24OCT06               *****;
***** DESCRIPTION *********************************************************************************;
***** Calculates the C-statistic (concordance, descrimination index) for survival data        *****;
*****  with time dependent covariates and corresponding SE and 100(1-alpha)% CI               *****;
***** REFERENCE ***********************************************************************************;
***** Walter K Kremers, 2006, Concordance for Survival Time Data Including Time-Dependent     *****;
*****   Covariates Accounting for Ties in Predictor and Time, Technical Report                *****;
***************************************************************************************************;
 
****************************************************************************************************;
* This program takes data in the form you would expect to use for PROC PHReg using the (Start, Stop);
* format allowing the use of time dependent covariates.  This program does not perform a PHReg fit  ;
* but expects a single predictor for risk which could be obtained from a PHReg fit using an output  ;
* statement, e.g. OUTPUT OUT=OUT01 XBETA=SCORE ; * One may also use the ID statment to retain the   ;
* subject id's in the output data set, e.g. ID PATIENT_ID ;                                        *;
* Input variables for the macro are                                                                 ;
*	DATA  - The SAS data set for calculations                                                   ;
*       ID - sampling unit (patient) identifier, required if (start, stop time) format used for data;
*	START - the start time variable (optional)                                                  ;
*	TIME  - the stop time variable                                                              ;
*       EVENT - the event variable where 1 indicates an event and 0 indicates censored              ;
*       SCORE - the predictor, a single variable                                                    ;
*       OUT - output dataset (default= SurvCs_)                                                     ;
*	PRINT - 1 (default) to print out summary output and c-statistis, 0 to suppress output       ;
*       Alpha - alpha for confidence intervals, default 0.05                                        ;
*       SEMethod - I (default) for an an approximate jackknife, J for Jackknife, D for direct method;
*            - Direct method is very time intensive for large samples, order (N**3)/2               ;
*               direct method should NOT BE USED FOR LARGE DATA SETS, e.g. more thatn 1000 subjects ;
*            - I and J order N**2                                                                   ;
*            - When the Direct method is used CIs are also derived using Fieller s Theorem          ;
*       nadj  - 1 for (n-1)/n adjustment to approximate jackknife,                                  ;
*               0 (default, recomended) for no adjustment                                           ;
* Output                                                                                            ;
*   By default results are printed to the output window                                             ;
*   SurvCs_ -  a SAS data set containing the calculation results (called CSTAT in old version)      ;
*   _temp020-028, 035-037 - temporary data sets used in analysis (temp025 - basic dataset for calcs) ;
****************************************************************************************************;
 
****************************************************************************************************;
* As with most routines with time-dependent covariates, care should be taken with events or censor *;
* at time 0.  Usually the time for these events should be assigned a value between 0 and the first *;
* event after time 0.                                                                              *;
****************************************************************************************************;
* For calculations, this routine ignores (deletes from the data for analysis) records with         *;
* missing values for any of the required variables.                                                *;
****************************************************************************************************;
 
%macro SurvCsTD(data=, id=, start=, time=, score=, event=, print=1,
                alpha=0.05, SEMethod=I, nadj=0, out=SurvCs_) ;
%local i_id itzero mintime;
 
%if ((&start = ) & (&id = )) %then %do ;
  %let i_id = 1 ;
  %let id = ID ;
  %let idtype = 1 ;
  %put ;
  %put NOTE, In that the variable START for start time and ID for sampling unit ;
  %put %str(  ) identification are not specified, each record is treated as a separate  ;
  %put %str(  ) sampling unit and the covariates are treated as baseline (not time dependent). ;
  %put ;
  %end ;
%else %let i_id = 0 ;
 
%if (&start = ) %then %do ;
  proc means data=&data noprint ;
    var &time ;
    output out=_temp01 min=mintime ;
  data _null_ ;
    set _temp01 ;
    if (mintime > 0) then mintime = 0 ;
    else mintime = mintime - 0.01 ;
    call symput('mintime',trim(left(put(mintime,best8.)))) ;
  run ;
  %let itzero = 1 ;
  %let start = MinTime ;
  %end ;
%else %let itzero = 0 ;
 
%if ((&data =) | (&id = ) | (&start = ) | (&time= ) | (&score = ) | (&event = ) ) %then %do ;
  %put Error - ;
  %if (&data = ) %then
  %put Variable DATA which gives the data set for analysis must be specified in macro call ;
  %if (&id = ) %then
  %put Variable ID which identifies the sampling unit (patient) must be specified in macro call ;
  %if (&start = ) %then
  %put Variable START which identifies start time must be specified in macro call ;
  %if (&time= ) %then
  %put Variable TIME which identifies stop time must be specified in macro call ;
  %if (&score= ) %then
  %put Variable SCORE which identifies the predictor score variable must be specified in macro call ;
  %if (&event = ) %then
  %put Variable EVENT which identifies events must be specified in macro call ;
  %put ;
  %end ;
%else %do ;
 
%local IJK JK Direct idtype starttyp timetype eventtyp ;
%if (&SEMethod =) %then %let SEMethod = I ;
%else %let SEMethod = %upcase(&SEMethod) ;
%if (%index(&SEMethod,I) =0) %then %let Ijk   =0 ; %else %let IJK    = 1 ;
%if (%index(&SEMethod,J) =0) %then %let jk    =0 ; %else %let JK     = 1 ;
%if (%index(&SEMethod,D) =0) %then %let Direct=0 ; %else %let Direct = 1 ;
%if (^&jk & ^&IJK & ^&direct) %then %let IJK = 1 ;
%if &jk %then %let IJK = 1 ;
 
proc contents data=&data out=_temp020 noprint ;
data _temp020 ;
  set _temp020 ;
  %if ^&i_id %then if (upcase(name) = "%upcase(&id)") then call symput('idtype',trim(left(put(type,1.)))) ; ;
  if (upcase(name) = "%upcase(&start)") then call symput('starttyp',trim(left(put(type,1.)))) ;
  if (upcase(name) = "%upcase(&time)" ) then call symput('timetype',trim(left(put(type,1.)))) ;
  if (upcase(name) = "%upcase(&event)") then call symput('eventtyp',trim(left(put(type,1.)))) ;
run ;
 
%if ((&i_id = 1) & (&itzero = 1)) %then %do ;
  proc sort
    data=&data (where=((&time ^= .) & (&score ^= .) & (&event ^= .) ))
    out=_temp021
      (rename = (&time=time &score=score &event=event)
       keep = &time &score &event) ;
    by &time ;
  %end ;
%else %if ((&i_id = 0) & (&itzero = 1)) %then %do ;
  proc sort
    data=&data (where=(%if (&idtype=2) %then (&id ^= ' ') ; %else (&id ^= .) ;
                       & (&time ^= .) & (&score ^= .) & (&event ^= .) ))
    out=_temp021
      (rename=(&id=id_ &time=time &score=score &event=event)
       keep=&id &time &score &event) ;
    by &id &time ;
  %end ;
%else %do ;
  proc sort
    data=&data (where=(%if (&idtype=2) %then (&id ^= ' ') ; %else (&id ^= .) ;
                       & (&start ^= .) & (&time ^= .) & (&score ^= .) & (&event ^= .) ))
    out=_temp021
      (rename=(&id=id_ &start=start &time=time &score=score &event=event)
       keep=&id &start &time &score &event) ;
    by &id &time ;
  %end ;
run ;
 
  /*
proc sort
  data=&data (where=(
              %if (&i_id = 0) %then %do ; %if (&idtype=2) %then (&id ^= ' ') & ; %else (&id ^= .) & ; %end ;
              %if (&itzero = 0) %then (&start ^= .) & ;
              (&time ^= .) & (&score ^= .) & (&event ^= .) ))
  out=_temp021
  (rename=(%if (&i_id =0) %then &id=id_ ;
           %if (&itzero=0) %then &start=start ;
           &time=time &score=score &event=event)
  keep = %if (&i_id =0) %then &id ; %if (&itzero=0) %then &start ; &time &score &event) ;
  by %if (&i_id =0) %then &id ; &time ;
  */;
 
%if ((&i_id =1) | (&itzero = 1)) %then %do ;
  data _temp021 ;
    set _temp021 ;
    %if (&i_id =1) %then id_ = _n_ ; ;
    %if (&itzero=1) %then &start = &mintime ; ;
  %end ;
run ;
 
data _temp022 ;
  set _temp021 ;
  by id_ ;
  retain start_ time_ score_ event_ ;
  if first.id_ then do ;
    start_ = start ; time_ = time ; score_=score ; event_ = event ;
    end ;
  else if ((score  = score_) & (time_ = start)) then time_ = time ;
  else if ((score ^= score_) | (time_^= start)) then do ;
    output ;
    start_ = start ; time_ = time ; score_ = score ; event_ = event ;
    end ;
  if last.id_ then do ; event_ = event ; output ; end ;
data _temp023 ;
  set _temp022 ;
  drop start_ time_ score_ event_ ;
  start = start_ ; time = time_ ; score = score_ ; event = event_ ;
run ;
 
data _temp025 ;
  length id 8 ;
  set _temp023 end=eod ;
  by id_ ;
  retain id nevent NRecord 0 ;
  drop id_ nevent NRecord ;
  NRecord = NRecord + 1 ;
  if first.id_ then do ; id = id + 1 ; ifirst = 1 ; end ; else ifirst = 0 ;
  if last.id_ then do ; ilast = 1 ; end ;  else ilast = 0 ;
  if event then nevent = nevent + 1 ;
  if eod then do ;
    call symput('NRecord',trim(left(put(NRecord,best8.)))) ;
    call symput('nid',trim(left(put(id,best8.)))) ;
    call symput('Nevent',trim(left(put(nevent,best8.)))) ;
    end ;
run ; %put N Records = &NRecord N IDs = &Nid N Events = &Nevent ;
 
%if (&jk | &ijk) %then %do ;
*111111111111111111111111111111111111111111111111111111111111111111;
 
data _temp026 (keep=sumc sumd sump sumt sumnt sumnh sumnn sumdt sumdh sumdn
                   sumn2t sumn2h sumn2n sumd2t sumd2h sumd2n sumNDT sumNDH sumNDN
                   CT CH CN SDCTI SDCHI SDCNI
                   CTIlo CTIup CHIlo CHIup CNIlo CNIup)
     %if (&jk = 1) %then _temp027 (keep=idi ci di pi ti) ; ;
  drop start time score event nevent ;
  retain nevent ci di pi ti
         sumc sumd sump sumt sumnt sumnh sumnn sumdt sumdh sumdn
         sumn2t sumn2h sumn2n sumd2t sumd2h sumd2n sumNDT sumNDH sumNDN 0 ;
  length idi idj 4 ;
  clock0 = time() ;
  do i_ = 1 to n_ ;
    set _temp025 point=i_ nobs=n_ ;
	if (ifirst = 1) then do ;
	  ci = 0 ; di = 0 ; pi = 0 ; ti = 0 ; end ;
    idi = id ; lasti = ilast ; starti = start ; timei = time ; scorei = score ; eventi = event ;
    do j_ = 1 to n_ ;
      set _temp025 point=j_ ;
      idj = id ; lastj = ilast ; startj = start ; timej = time ; scorej = score ; eventj = event ;
	  if (idi ^= idj) then do ;
        *----------------------------------------------------------------------;
        if ((eventi=1) | (eventj=1)) then do ;
          if (eventi & eventj) then do ;
            if      (timei = timej)                                        then ti = ti + 1 ;
            else if (starti < timej) & (timei > timej) & (scorej > scorei) then ci = ci + 1 ;
            else if (startj < timei) & (timej > timei) & (scorei > scorej) then ci = ci + 1 ;
            else if (starti < timej) & (timei > timej) & (scorej < scorei) then di = di + 1 ;
            else if (startj < timei) & (timej > timei) & (scorei < scorej) then di = di + 1 ;
            else if (starti < timej) & (timei > timej) & (scorej = scorei) then pi = pi + 1 ;
            else if (startj < timei) & (timej > timei) & (scorei = scorej) then pi = pi + 1 ;
            end ;
          if ((eventi=1) & (eventj=0)) then do ;
            if      (startj < timei) & (timej >= timei) & (scorei > scorej) then ci = ci + 1 ;
            else if (startj < timei) & (timej >= timei) & (scorei < scorej) then di = di + 1 ;
            else if (startj < timei) & (timej >= timei) & (scorei = scorej) then pi = pi + 1 ;
            end ;
          if ((eventi=0) & (eventj=1)) then do ;
            if      (starti < timej) & (timei >= timej) & (scorej > scorei) then ci = ci + 1 ;
            else if (starti < timej) & (timei >= timej) & (scorej < scorei) then di = di + 1 ;
            else if (starti < timej) & (timei >= timej) & (scorej = scorei) then pi = pi + 1 ;
            end ;
          end ;
        *----------------------------------------------------------------------;
		end ;
      end ;
    if ( (i_ = 1) | (i_=10) | (i_=100) | (i_=1000) | (mod(i_,10000) = 0) ) then do ;
      clock1 = time() - clock0 ;
      x = time() ;
      put "At "  x time. " after processing " i_ "of " n_ " records clock elapsed= " clock1 time. ;
      end ;
    if (lasti = 1) then do ;
      sumc = sumc + Ci ;
      sumd = sumd + Di ;
      sump = sump + Pi ;
      sumt = sumt + Ti ;
	  NT = Ci + 0.5*Pi + 0.5*Ti ;
	  NH = Ci + 0.5*Pi          ;
	  NN = Ci                   ;
	  DT = Ci + Di + Pi + Ti ;
	  DH = Ci + Di + Pi      ;
	  DN = Ci + Di           ;
	  sumNT = sumNT + NT ;
	  sumNH = sumNH + NH ;
	  sumNN = sumNN + NN ;
      sumDT = sumDT + DT ;
      sumDH = sumDH + DH ;
      sumDN = sumDN + DN ;
	  sumN2T = sumN2T + NT**2 ;
	  sumN2H = sumN2H + NH**2 ;
	  sumN2N = sumN2N + NN**2 ;
	  sumD2T = sumD2T + DT**2 ;
	  sumD2H = sumD2H + DH**2 ;
	  sumD2N = sumD2N + DN**2 ;
	  sumNDT = sumNDT + NT*DT ;
	  sumNDH = sumNDH + NH*DH ;
	  sumNDN = sumNDN + NN*DN ;
      %if (&jk = 1) %then output _temp027 ; ;
      end ;
    end ;
  sumc = sumc/2 ;
  sumd = sumd/2 ;
  sump = sump/2 ;
  sumt = sumt/2 ;
  CT = sumNT/sumDT ;
  CH = sumNH/sumDH ;
  CN = sumNN/sumDN ;
  SDCTI = sumD2T*sumNT**2 - 2*sumDT*sumNT*sumNDT + sumN2T*sumDT**2 ;
  SDCHI = sumD2H*sumNH**2 - 2*sumDH*sumNH*sumNDH + sumN2H*sumDH**2 ;
  SDCNI = sumD2N*sumNN**2 - 2*sumDN*sumNN*sumNDN + sumN2N*sumDN**2 ;
  %if (&nadj = 1) %then %do ;
    SDCTI = 2*sqrt(((&Nid-1)/&Nid)*SDCTI)/(sumDT*sumDT) ;
    SDCHI = 2*sqrt(((&Nid-1)/&Nid)*SDCHI)/(sumDH*sumDH) ;
    SDCNI = 2*sqrt(((&Nid-1)/&Nid)*SDCNI)/(sumDN*sumDN) ;
    %end ;
  %else %do ;
    SDCTI = 2*sqrt(SDCTI)/(sumDT*sumDT) ;
    SDCHI = 2*sqrt(SDCHI)/(sumDH*sumDH) ;
    SDCNI = 2*sqrt(SDCNI)/(sumDN*sumDN) ;
    %end ;
  CTIlo = CT - probit(1-&alpha/2)*sdctI ;
  CTIup = CT + probit(1-&alpha/2)*sdctI ;
  CHIlo = CH - probit(1-&alpha/2)*sdcHI ;
  CHIup = CH + probit(1-&alpha/2)*sdcHI ;
  CNIlo = CN - probit(1-&alpha/2)*sdcnI ;
  CNIup = CN + probit(1-&alpha/2)*sdcnI ;
  output _temp026 ;
  stop ;
run ;
 
data _temp029 ;
  Data  = "&data " ;
  nadj  = &nadj ;
  set _temp026 ;
  sumN2Nx = sumN2N/((&nid**2)*(&nid-1)) ;
run ;
 
%if (&jk = 1) %then %do ;
  data _temp028  ;
    set _temp029 ;
    retain sumcloT sumcloT2 sumcloH sumcloH2 sumcloN sumcloN2 0 ;
    keep SDCTJ SDCHJ SDCNJ CTJlo CTJup CHJlo CHJup CNJlo CNJup ;
    do i_ = 1 to n_ ;
      set _temp027 point=i_ nobs=n_ ;
      cloT = (sumc + 0.5*sump + 0.5*sumt - (Ci + 0.5*Pi + 0.5*Ti))
           / (sumc + sumd + sump + sumt - (Ci + Di + Pi + Ti)) ;
      sumcloT  = sumcloT  + cloT ;
      sumcloT2 = sumcloT2 + cloT**2 ;
      cloH = (sumc + 0.5*sump - (Ci + 0.5*Pi))
           / (sumc + sumd + sump - (Ci + Di + Pi)) ;
      sumcloH  = sumcloH  + cloH ;
      sumcloH2 = sumcloH2 + cloH**2 ;
      cloN = (sumc - Ci) / (sumc + sumd - (Ci + Di)) ;
      sumcloN  = sumcloN  + cloN ;
      sumcloN2 = sumcloN2 + cloN**2 ;
      end ;
    SDCTJ = sqrt(((&Nid-1)/&Nid)*(sumcloT2 - (sumcloT**2)/n_)) ;
    SDCHJ = sqrt(((&Nid-1)/&Nid)*(sumcloH2 - (sumcloH**2)/n_)) ;
    SDCNJ = sqrt(((&Nid-1)/&Nid)*(sumcloN2 - (sumcloN**2)/n_)) ;
    CTJlo = CT - probit(1-&alpha/2)*sdctJ ;
    CTJup = CT + probit(1-&alpha/2)*sdctJ ;
    CHJlo = CH - probit(1-&alpha/2)*sdcHJ ;
    CHJup = CH + probit(1-&alpha/2)*sdcHJ ;
    CNJlo = CN - probit(1-&alpha/2)*sdcnJ ;
    CNJup = CN + probit(1-&alpha/2)*sdcnJ ;
    output ;
  data _temp029 ;
    pointer = 1 ;
    set _temp029 point=pointer ;
    set _temp028 point=pointer ;
    output ;
    stop ;
  run ;
  %end ;
 
*111111111111111111111111111111111111111111111111111111111111111111;
%end ;
%else %do ;
  data _temp029 ;
    Data  = "&data " ;
  run ;
  %end ;
 
%if &direct %then %do ;
%if (%eval(&nid-1000) > 0) %then %do ;
  %put For this data set with &nid (>1000) subjects computations may require substantial memory and time. ;
  %put Consider using the jackknife or the approximate jackknife method. ;
  %end ;
 
*222222222222222222222222222222222222222222222222222222222222222222;
 
data _temp036 (keep=idi idj agr dis tiep tiet) ;
  array c_v(&Nid,&Nid) _temporary_ ;
  array d_v(&Nid,&Nid) _temporary_ ;
  array p_v(&Nid,&Nid) _temporary_ ;
  array t_v(&Nid,&Nid) _temporary_ ;
  drop jlo start time score event nevent ;
  retain nevent 0 ;
  length idi idj 4 ;
  do idi = 1 to &Nid ;
    jlo = idi + 1 ;
    do idj = jlo to &Nid ;
      c_v(idi,idj) = 0 ;
      d_v(idi,idj) = 0 ;
      p_v(idi,idj) = 0 ;
      t_v(idi,idj) = 0 ;
      end ;
    end ;
  do i_ = 1 to n_ ;
    set _temp025 point=i_ nobs=n_ ;
    idi = id ; starti = start ; timei = time ; scorei = score ; eventi = event ;
    jlo = i_ + 1 ;
    do j_ = jlo to n_ ;
      set _temp025 point=j_ ;
      idj = id ; startj = start ; timej = time ; scorej = score ; eventj = event ;
      *----------------------------------------------------------------------;
      if ((eventi=1) | (eventj=1)) then do ;
        if (eventi & eventj) then do ;
          if      (timei = timej)                                        then t_v(idi,idj) = 1 ;
          else if (starti < timej) & (timei > timej) & (scorej > scorei) then c_v(idi,idj) = 1 ;
          else if (startj < timei) & (timej > timei) & (scorei > scorej) then c_v(idi,idj) = 1 ;
          else if (starti < timej) & (timei > timej) & (scorej < scorei) then d_v(idi,idj) = 1 ;
          else if (startj < timei) & (timej > timei) & (scorei < scorej) then d_v(idi,idj) = 1 ;
          else if (starti < timej) & (timei > timej) & (scorej = scorei) then p_v(idi,idj) = 1 ;
          else if (startj < timei) & (timej > timei) & (scorei = scorej) then p_v(idi,idj) = 1 ;
          end ;
        if ((eventi=1) & (eventj=0)) then do ;
          if      (startj < timei) & (timej >= timei) & (scorei > scorej) then c_v(idi,idj) = 1 ;
          else if (startj < timei) & (timej >= timei) & (scorei < scorej) then d_v(idi,idj) = 1 ;
          else if (startj < timei) & (timej >= timei) & (scorei = scorej) then p_v(idi,idj) = 1 ;
          end ;
        if ((eventi=0) & (eventj=1)) then do ;
          if      (starti < timej) & (timei >= timej) & (scorej > scorei) then c_v(idi,idj) = 1 ;
 
else if (starti < timej) & (timei >= timej) & (scorej < scorei) then d_v(idi,idj) = 1 ;
 
else if (starti < timej) & (timei >= timej) & (scorej = scorei) then p_v(idi,idj) = 1 ;
          end ;
        end ;
      *----------------------------------------------------------------------;
      end ;
    end ;
  do idi = 1 to &Nid ;
    jlo = idi + 1 ;
    do idj = jlo to &Nid ;
      agr = c_v(idi,idj) ;
      dis = d_v(idi,idj) ;
      tiep= p_v(idi,idj) ;
      tiet= t_v(idi,idj) ;
      output ;
      end ;
    end ;
  stop ;
run ;
 
data _temp037 (drop=c_ref d_ref p_ref t_ref idi idj agr dis tiep tiet aa_ bb_ cc_) ;
  array c_v(&Nid,&Nid) _temporary_ ;
  array d_v(&Nid,&Nid) _temporary_ ;
  array p_v(&Nid,&Nid) _temporary_ ;
  array t_v(&Nid,&Nid) _temporary_ ;
  do i_ = 1 to n_ ;
    set _temp036 point=i_ nobs=n_ ;
	c_v(idi,idj) = agr ;
	d_v(idi,idj) = dis ;
	p_v(idi,idj) = tiep ;
	t_v(idi,idj) = tiet ;
	C_ = C_ + agr ;
	D_ = D_ + dis ;
	P_ = P_ + tiep ;
	T_ = T_ + tiet ;
	end ;
*  length nsamp nevent idi idj agr dis tiep tiet 8 ;
  retain nevent C_ D_ P_ T_ countb
         CC DD PP TT CD CP CT DP DT PT obsn 0 ;
  drop obsn ;
  nsamp = &Nid ;
  nevent = &nevent ;
  clock0 = time() ;
  do i_ = 1 to &Nid ;
    im1 = i_ - 1 ;
    ip1 = i_ + 1 ;
    do j_ = ip1 to &Nid ;
      c_ref=c_v(i_,j_) ; d_ref = d_v(i_,j_) ; p_ref = p_v(i_,j_) ; t_ref = t_v(i_,j_) ;
      jm1 = j_ - 1 ;
      jp1 = j_ + 1 ;
	  *----------------------------------------------------------------------------------;
      do k_ = 1 to im1 ;
        c_com=c_v(k_,i_) ; d_com = d_v(k_,i_) ; p_com = p_v(k_,i_) ; t_com = t_v(k_,i_) ;
        link count ;
        end ;
      do l_ = ip1 to &Nid ;
	    if (l_ ^= j_) then do ;
          c_com=c_v(i_,l_) ; d_com = d_v(i_,l_) ; p_com = p_v(i_,l_) ; t_com = t_v(i_,l_) ;
          link count ;
          end ;
        end ;
      do k_ = 1 to jm1 ;
	    if (k_ ^= i_) then do ;
          c_com=c_v(k_,j_) ; d_com = d_v(k_,j_) ; p_com = p_v(k_,j_) ; t_com = t_v(k_,j_) ;
          link count ;
          end ;
        end ;
      do l_ = jp1 to &Nid ;
        c_com=c_v(j_,l_) ; d_com = d_v(j_,l_) ; p_com = p_v(j_,l_) ; t_com = t_v(j_,l_) ;
        link count ;
        end ;
	  *----------------------------------------------------------------------------------;
      end ;
    if ( ((i_ = 1) | (i_ = 2) | (i_=10) | (i_=25) | (mod(i_,100) = 0)) & (&Nid > (i_+2)) ) then do ;
      clock1 = time() - clock0 ;
      put "After Processing " i_= "of &Nid individuals clock elapsed= " clock1 time. ;
      end ;
    end ;
  NA = (&Nid-1)*&Nid/2 ;
  NB = (2*&Nid - 4)*(&Nid-1)*&Nid/2 ;
  NC = NA**2 - NA - NB ;
  C_bar  = C_/NA ;
  D_bar  = D_/NA ;
  P_bar = P_/NA ;
  T_bar = T_/NA ;
  CCbar = CC/NB ;
  DDbar = DD/NB ;
  PPbar = PP/NB ;
  TTbar = TT/NB ;
  CDbar = CD/NB ;
  CPbar = CP/NB ;
  CTbar = CT/NB ;
  DPbar = DP/NB ;
  DTbar = DT/NB ;
  PTbar = PT/NB ;
  varc = NA*C_bar + NB*CCbar - (NA + NB)*C_bar**2 ;
  vard = NA*D_bar + NB*DDbar - (NA + NB)*D_bar**2 ;
  varp = NA*P_bar + NB*PPbar - (NA + NB)*P_bar**2 ;
  vart = NA*T_bar + NB*TTbar - (NA + NB)*T_bar**2 ;
  CovCD = NB*CDbar -(NA + NB)*C_bar*D_bar ;
  CovCP = NB*CPbar -(NA + NB)*C_bar*P_bar ;
  CovCT = NB*CTbar -(NA + NB)*C_bar*T_bar ;
  CovDP = NB*DPbar -(NA + NB)*D_bar*P_bar ;
  CovDT = NB*DTbar -(NA + NB)*D_bar*T_bar ;
  CovPT = NB*PTbar -(NA + NB)*P_bar*T_bar ;
  CorrCD = covCD/sqrt(varc*vard) ;
  CStatT = (C_ + 0.5*P_ + 0.5*T_) / (C_ + D_ + P_ + T_) ;
  CstatH = (C_ + 0.5*P_) / (C_ + D_ + P_) ;
  CStatN = C_ / (C_ + D_) ;
 
  VarNumT = varc + 0.25*varp + 0.25*vart + covcp + covct + 0.5*covpt ;
  VarDenT = varc + vard + varp + vart + 2*covcd + 2*covcp + 2*covct + 2*covdp + 2*covdt + 2*covpt ;
  covNuDeT = varc + 0.5*varp + 0.5*vart + covcd + 1.5*covcp + 1.5*covct + 0.5*covdp + 0.5*covdt + covpt ;
  if ((VarDenT < 0) & (VarDenT > -0.0000001)) then VarDenT = 0 ;
  if ((CovNuDeT < 0) & (CovNuDeT > -0.0000001)) then CovNuDeT = 0 ;
  if (VarDenT > 0) then CorNuDeT = CovNuDeT/sqrt(VarNumT*VarDenT) ;
  VarCTD = (CStatT**2)*(VarNumT/(C_ + 0.5*P_ + 0.5*T_)**2 + VarDenT/(C_ + D_ + P_ + T_)**2
           - 2*covNuDeT/ ((C_ + 0.5*P_ + 0.5*T_) * (C_ + D_ + P_ + T_)) ) ;
 
  VarNumH = varc + 0.25*varp + covcp ;
  VarDenH = varc + vard + varp + 2*covcd + 2*covcp + 2*covdp ;
  covNuDeH = varc + 0.5*varp + covcd + 1.5*covcp + 0.5*covdp ;
  if ((VarDenH < 0) & (VarDenH > -0.0000001)) then VarDenH = 0 ;
  if ((CovNuDeH < 0) & (CovNuDeH > -0.0000001)) then CovNuDeH = 0 ;
  if (VarDenH > 0) then CorNuDeH = CovNuDeH/sqrt(VarNumH*VarDenH) ;
  VarCHD = (cstatH**2)*(VarNumH/(C_ + 0.5*P_)**2 + VarDenH/(C_ + D_ + P_)**2
           - 2*covNuDeH/ ((C_ + 0.5*P_) * (C_ + D_ + P_)) ) ;
 
  VarNumN = varc ;
  VarDenN = varc + vard + 2*covcd ;
  covNuDeN = varc + covcd ;
  if ((VarDenN < 0) & (VarDenN > -0.0000001)) then VarDenH = 0 ;
  if ((CovNuDeN < 0) & (CovNuDeN > -0.0000001)) then CovNuDeH = 0 ;
  if (VarDenN > 0) then CorNuDeN = CovNuDeN/sqrt(VarNumN*VarDenN) ;
  VarCND = (CStatN**2)*(VarNumN/(C_)**2 + VarDenN/(C_ + D_)**2
           - 2*covNuDeN/ ((C_) * (C_ + D_)) ) ;
 
  SDCTD = sqrt(VarCTD) ;
  SDCHD = sqrt(VarCHD) ;
  SDCND = sqrt(VarCND) ;
 
  zalpha = probit(1-&alpha/2) ;
 
  aa_ = (C_ + D_ + P_ + T_)**2 - VarDenT*(zalpha**2) ;
  bb_ = - 2 * (C_ + 0.5*P_ + 0.5*T_) * (C_ + D_ + P_ + T_) + 2 * covNuDeT * (zalpha**2) ;
  cc_ = (C_ + 0.5*P_ + 0.5*T_)**2 - VarNumT * (zalpha**2) ;
  rr1 = ( - bb_ - sqrt(bb_**2 - 4*aa_*cc_) ) / (2*aa_) ;
  rr2 = ( - bb_ + sqrt(bb_**2 - 4*aa_*cc_) ) / (2*aa_) ;
  if (rr1 < rr2) then do ; CTFlo = rr1 ; CTFup  = rr2 ; end ; else do ; CTFlo = rr2 ; CTFup = rr1 ; end ;
 
  aa_ = (C_ + D_ + P_)**2 - VarDenH*(zalpha**2) ;
  bb_ = - 2 * (C_ + 0.5*P_) * (C_ + D_ + P_) + 2 * covNuDeH * (zalpha**2) ;
  cc_ = (C_ + 0.5*P_)**2 - VarNumH * (zalpha**2) ;
  rr1 = ( - bb_ - sqrt(bb_**2 - 4*aa_*cc_) ) / (2*aa_) ;
  rr2 = ( - bb_ + sqrt(bb_**2 - 4*aa_*cc_) ) / (2*aa_) ;
  if (rr1 < rr2) then do ; CHFlo = rr1 ; CHFup  = rr2 ; end ; else do ; CHFlo = rr2 ; CHFup = rr1 ; end ;
 
  aa_ = (C_ + D_)**2 - VarDenN*(zalpha**2) ;
  bb_ = - 2 * (C_) * (C_ + D_) + 2 * covNuDeN * (zalpha**2) ;
  cc_ = (C_)**2 - VarNumN * (zalpha**2) ;
  rr1 = ( - bb_ - sqrt(bb_**2 - 4*aa_*cc_) ) / (2*aa_) ;
  rr2 = ( - bb_ + sqrt(bb_**2 - 4*aa_*cc_) ) / (2*aa_) ;
  if (rr1 < rr2) then do ; CNFlo = rr1 ; CNFup  = rr2 ; end ; else do ; CNFlo = rr2 ; CNFup = rr1 ; end ;
 
  CTDlo = CStatT - zalpha*SDCTD ;
  CTDup = CStatT + zalpha*SDCTD ;
  CHDlo = cstatH - zalpha*SDCHD ;
  CHDup = cstatH + zalpha*SDCHD ;
  CNDlo = cstatN - zalpha*SDCND ;
  CNDup = cstatN + zalpha*SDCND ;
 
  output _temp037 ;
  stop ;
count :
  countb = countb + 1 ;
  CC = CC + c_ref*c_com ;
  DD = DD + d_ref*d_com ;
  PP = PP + p_ref*p_com ;
  TT = TT + t_ref*t_com ;
  CD = CD + c_ref*d_com ;
  CP = CP + c_ref*p_com ;
  CT = CT + c_ref*t_com ;
  DP = DP + d_ref*p_com ;
  DT = DT + d_ref*t_com ;
  PT = PT + p_ref*t_com ;
  return ;
run ;
 
data _temp038 ;
  Data  = "&data " ;
  set _temp037 ;
run ;
 
*222222222222222222222222222222222222222222222222222222222222222222;
%end ;
%else %do ;
  data _temp038 ;
    Data  = "&data " ;
    ct = . ;
  run ;
  %end ;
 
data &out;
  Start = "&start " ;
  Time  = "&time " ;
  Score = "&score " ;
  Event = "&event " ;
  Nid = &Nid ;
  NRecord = &NRecord ;
  Nevent = &nevent ;
  merge _temp038 (rename=(ct=ct_)) _temp029 ;
  by data ;
  CIWDr = (CTDup - CTDlo)/(CTFup - CTFlo) ;
  CIWIr = (CTIup - CTIlo)/(CTFup - CTFlo) ;
  CIWJr = (CTJup - CTJlo)/(CTFup - CTFlo) ;
  format %if (&ijk   ) %then CT CH CN ;
         %if (&direct) %then cstatT cstatH CStatN ;
         %if (&ijk   ) %then SDCTI SDCHI SDCNI CTIlo CTIup CHIlo CHIup CNIlo CNIup ;
         %if (&jk    ) %then SDCTJ SDCHJ SDCNJ CTJlo CTJup CHJlo CHJup CNJlo CNJup  ;
         %if (&direct) %then SDCTD SDCHD SDCND       CTFlo CTFup CTDlo CTDup
                             CHFlo CHFup CHDlo CHDup CNFlo CNFup CNDlo CNDup ; 6.4 ; * 8.6 ; * 10.8 ;
run ;
 
%if (&print = 1) %then %do ;
  proc print data=&out ;
*    var data start time score event nsamp nevent c_ d_ p_ t_ cstatT cstatH CStatN SDCTD SDCHD CTDlo CTDup ;
*    var data start time score event nsamp nevent c_ d_ p_ t_ cstatT SDCTD CTDlo CTDup ;
  var data start time score event NID NRecord Nevent
      %if (&ijk   ) %then sumc sumd sump sumt CT CH CN ;
      %else c_ d_ p_ t_  cstatT cstatH CStatN ;
	  %if (&direct) %then SDCTD SDCHD SDCND ;
      %if (&ijk   ) %then SDCTI SDCHI SDCNI ;
      %if (&jk    ) %then SDCTJ SDCHJ SDCNJ ;
	  %if (&direct) %then CTFlo CTFup CTDlo CTDup CHFlo CHFup CHDlo CHDup CNFlo CNFup CNDlo CNDup ;
      %if (&ijk   ) %then CTIlo CTIup CHIlo CHIup CNIlo CNIup ;
      %if (&jk    ) %then CTJlo CTJup CHJlo CHJup CNJlo CNJup  ; ;
  %end ;
run ;
 
%end ;
 
proc datasets lib=work nofs;
  delete  _temp020 _temp021 _temp022 _temp023 _temp024 _temp025 _temp026 _temp027 _temp028
          _temp035 _temp036 _temp037 _temp01;
quit;
 
 
%mend ;
 
*---------------------------------------------------------------------------;
 
  /*
* some examples of the macro *;
%macro exgen21(seed, nid) ;
* Get dummy data for example calculation *;
data Ex21 ;
  drop i_ ;
  do i_ = 1 to &nid ; * 4, 5,  10, 20, 30, 40, 50, 100, 200 ;
    id = i_ ;
    event = ranbin(&seed,1,0.9) ;
*    event = 1 ; *<--------------------- for example calculations may comment out -----;
    zero = 0 ;
    time = ranexp(1) ;
	score = ranexp(1) ;
    time = round(time / (0.1+score),1) + 1 ;
    score = round(score,1) ;
    if (time > 10) then time = 10 ;
    if (score > 3) then score = 3 ;
    score = score + 1 ;
	output ;
	end ;
run ;
%mend ;
 
%exgen21(1,200) ;
 
data Ex22 ;
  drop i_ ;
  do i_ = 1 to 200 ;
    id = i_ ;
	event = 1 ;
    zero = 0 ;
    time = ranexp(1) ;
	score = ranexp(1) ;
    time = score + time/10 ;
    score = 5 - score ;
    score = score + 1 ;
	output ;
	end ;
run ;
 
proc gplot data=ex21 ;
  plot time * score ;
run ; quit ;
 
*proc freq data=Ex21 ;
*  table time*score / norow nocol nopercent ;
run ;
proc corr data=Ex21 kendall spearman ;
  var time score ;
run ;
 
%SurvCsTD(data=Ex21,start=zero,time=time,score=score,event=event,id=id,SEMethod=DIJ,nadj=0) ;
proc print data=SurvCs_ ;
  var ccbar sumn2n sumn2nx  ;
run ;
 
%SurvCsTD(data=Ex22,start=zero,time=time,score=score,event=event,id=id,SEMethod=DIJ,nadj=0) ;
proc print data=SurvCs_ ;
  var CIWDr CIWIr CIWJr ;
run ;
 
data _temp01 ;
  do factor = 0.9 to 1.1 by 0.01 ;
    alpha = 200*(1-probnorm(factor * probit(0.975))) ;
	output ;
	end ;
  format alpha 5.2 ;
proc print data=temp01 ;
run ;
 
proc print data=temp029 ;
run ;
 
%macro mulex() ;
data cstatsim ; if (ratio ^= .) ;
%do sim = 30 %to 40 ;
  %exgen21(&sim,80) ;
  %SurvCsTD(data=Ex21,start=zero,time=time,score=score,event=event,id=id,SEMethod=DIJ,nadj=0, print=0) ;
  data SurvCs_ ; set SurvCs_ ; ratio = sumn2nx/ccbar ;
  proc print data=SurvCs_ ; var ccbar sumn2nx ratio ; run ;
  data cstatsim ; set cstatsim SurvCs_ ; run ;
  %end ;
proc print data=cstatsim ; var cn ccbar sumn2nx ratio ;
run ;
%mend ;
 
%mulex ;
  */;
 
 
 
 
 
