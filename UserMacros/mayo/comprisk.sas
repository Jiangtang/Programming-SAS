  /*------------------------------------------------------------------*
   | MACRO NAME  : comprisk
   | SHORT DESC  : Compute cumulative incidence in the presence
   |               of competing risks
   *------------------------------------------------------------------*
   | CREATED BY  : Bergstralh, Erik              (03/25/2004 17:31)
   *------------------------------------------------------------------*
   | PURPOSE
   |
   | Macro for cumulative incidence(CI)
   | in presence of competing risks.
   |
   | date written= 7/17/2000
   |
   *------------------------------------------------------------------*
   | MODIFIED BY : Bergstralh, Erik              (08/29/2008 14:55)
   |
   | Added labels to output dataset. Modified printed output.
   | Perform input checks, made GROUP optional, and restored user footnotes.
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
   | %comprisk(
   |            data= ,
   |            time= ,
   |            event= ,
   |            group=_all,
   |            print=N,
   |            outdata=_crisk
   |          );
   *------------------------------------------------------------------*
   | REQUIRED PARAMETERS
   |
   | Name      : data
   | Default   :
   | Type      : Dataset Name
   | Purpose   : SAS data set to use for competing risk analysis
   |
   | Name      : time
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : follow-up time to event, pts can have only one event as
   |             defined below. Time must be >=0.
   |
   | Name      : event
   | Default   :
   | Type      : Variable Name (Single)
   | Purpose   : 0 if no event
   |             1 if event of type 1, typically event of interest
   |             2 if event of type 2, competing risk
   |             3 if event of type 3, competing risk
   |
   *------------------------------------------------------------------*
   | OPTIONAL PARAMETERS
   |
   | Name      : group
   | Default   : _all
   | Type      : Variable Name (Single)
   | Purpose   : variable for doing by-group processing
   |
   | Name      : print
   | Default   : N
   | Type      : Text
   | Purpose   : N or Y to suppress or print final results
   |
   | Name      : outdata
   | Default   : _crisk
   | Type      : Dataset Name
   | Purpose   : Name of output dataset, default is _crisk.
   |             CI1, CI2 and CI3 are the CI estimates for
   |             causes 1, 2 and 3 respectively.
   |
   *------------------------------------------------------------------*
   | EXAMPLES
   |
   | Example located at bottom of code.
   |
   *------------------------------------------------------------------*
   | REFERENCES
   |
   | REFERENCE: Gooley, et al. Estimation of failure probabilities in
   | the presence of competing risks. Statist. Med. 18, 695-706(1999).
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
 
%macro comprisk(data=,time=,event=,group=_all,print=NO,outdata=_crisk);
 
  *** Input checks ***;
  %let errorflg=0;
  %if &time=  %then %do;
    %put  ERROR - Variable <TIME> not defined;
   %LET  errorflg = 1;
  %end;
  %if &event= %then %do;
   %put  ERROR - Variable <EVENT> not defined;
   %LET  errorflg = 1;
  %end;
  %IF &errorflg=1 %THEN %DO;
     %put ERROR: Macro COMPRISK not run due to input errors;
     %go to exit;
   %end;
 
  ***** Save current footnotes -- reset later *****;
  proc sql ;
    create table work._f as select * from dictionary.titles
     where type='F';
    reset noprint;
   quit;
  ***** How many footnotes are being used? *****;
  proc sql;
   reset noprint;
   select nobs into :F from dictionary.tables
   where libname="WORK" & memname="_F";
 quit;
  ***** Store footnotes in macro variables *****;
  %LET FOOTNOTE1= ; /* Initialize at least one footnote */
  data _null_;
    set _f;
    %IF (&F>=1) %THEN %DO I=1 %TO &F;
       if number=&I then call symput("FOOTNOTE&I", trim(left(text)));
       %END;
   run;
 **********************************************;
 
 **** add up events with common time ****;
data _wk; set &data;
 keep &time _event &group;
 
 *drop bad time or event data;
 if &time lt 0 or &event ^ in(0,1,2,3) then do;
     PUT "NOTE: OBS deleted as TIME<0 or EVENT not 0,1,2,3:" &time= &event=;
     delete;
  end;
 
  %if &group=_all %then %do;
 _all=1;
 Label _all="Total";
  %end;
 
 _event=&event;
 run;
 *** total number censor & events of each type per unique time values;
proc sort data=_wk; by &group &time;
data _sumt; set _wk; by &group &time;
 keep &group &time  c e1 e2 e3;
 retain c e1 e2 e3;
 if first.&time then do;
   c=0;e1=0;e2=0;e3=0;
 end;
 if _event=0 then c=c+1;
 if _event=1 then e1=e1+1;
 if _event=2 then e2=e2+1;
 if _event=3 then e3=e3+1;
 if last.&time then output;
 
 **** figure number at risk *******;
proc sort data=_sumt; by &group descending &time;
data _test2; set _sumt; keep &group &time n_beg;
 by &group ;
 retain n_beg 0;
 if first.&group then n_beg=0;
 n_beg=n_beg+(c+e1+e2+e3);
proc sort data=_test2; by &group &time;
proc sort data=_sumt; by &group &time;
 
 **** add number at risk column to sumt dataset;
 **** do Kaplan-Meier(KM) overall and for each type event;
 **** do cumulative incidence (CI) for each type event;
 **** uses notation of Gooley;
data &outdata; merge _sumt _test2; by &group &time;
 retain km km1 km2 km3 1 ci1 ci2 ci3 0;
 if first.&group then do;
   km=1; km1=1; km2=1; km3=1; ci1=0; ci2=0; ci3=0;
 end;
 
 edot=e1+e2+e3;
 n_j=n_beg-(c+e1+e2+e3);
 
 km=km*(1 - (edot/n_beg));  ** KM after current events;
 L_Km=lag(km);              ** KM prior to current time;
  if first.&group then l_km=1;
 km1=km1*(1 - (e1/n_beg));  ** KM event type 1;
 km2=km2*(1 - (e2/n_beg));  ** KM event type 2;
 km3=km3*(1 - (e3/n_beg));  ** KM event type 3;
 _1m_km=1-km;               ** 1-overall kaplan-Meier;
 _1m_km1=1-km1;             ** 1- kaplan-Meier event type 1;
 _1m_km2=1-km2;             ** 1- kaplan-Meier event type 2;
 _1m_km3=1-km3;             ** 1- kaplan-Meier event type 3;
 kmp_m1=1-(km1*km2*km3);    ** 1-KM product = CI if no ties;
 
 ci1=ci1 + l_km*(e1/n_beg); ** CI type 1 events;
 ci2=ci2 + l_km*(e2/n_beg); ** CI type 2 events;
 ci3=ci3 + l_km*(e3/n_beg); ** CI type 3 events;
 ci=ci1+ci2+ci3;            ** Overall CI == 1-KM overall;
 
 _time=&time;
 
 format km l_km km1 km2 km3 ci1 ci2 ci3 ci
     _1m_km _1m_km1 _1m_km2 _1m_km3 kmp_m1 5.3;
 label _time="&time(t)"
       n_beg="No. at risk < time t"
         n_j="No. at risk after t"
         c= "No. censored at t"
        e1= "No. type 1 events at t"
        e2= "No. type 2 events at t"
        e3= "No. type 3 events at t"
      edot= "Total events at t"
      L_km= "KM < t"
       ci1= "CI1, <= t"
       ci2= "CI2, <= t"
       ci3= "CI3, <= t"
       ci = "CI any event, <= t"
    _1m_km= "1-KM any event, <= t"
        km= "KM any event, <= t"
       km1= "KM1, <= t"
       km2= "KM2, <= t"
       km3= "KM3, <= t"
   _1m_km1= "1-KM1, <= t"
   _1m_km2= "1-KM2, <= t"
   _1m_km3= "1-KM3, <= t"
    kmp_m1= "1-KM1*KM2*KM3, <= t";
 run;
  %if %upcase(&print)=Y or %upcase(&print)=YES  %then %do;
 proc print label data=&outdata; by &group; id _time; var  n_beg
  c e1 e2 e3 ci1 ci2 ci3 ci _1m_km1 _1m_km2 _1m_km3 _1m_km;
  %end;
footnote1"COMPRISK macro: data=&data time=&time event=&event group=&group";
footnote2" CIx = cumulative incidence for event type x";
footnote3" 1-KMx = 1 - Kaplan-Meier estimate for event type x (censor other events)";
  run;
  ***** Restore the previous footnotes *****;
  footnote1;
  %IF (&F>=1) %THEN %DO I=1 %TO &F;
   footnote&I "&&FOOTNOTE&I";
  %END;
 proc datasets; delete _f _wk _sumt _test2 ;
 %exit:
  run;
%mend comprisk;
 
   /* ****test data ***;
 options nocenter mprint macrogen;
data test;
input time evt all;
 tt=time; if evt in(2,3) then tt=25;
 e1=(evt=1);
 footnote3"FN3";
cards;
5 2 1
7 1 1
9 0 1
11 1 1
11 1 1
13 2 1
-1 8 1
15 3 1
17 0 1
19 1 1
21 0 1
5 2 22
7 1 22
9 0 22
11 1 22
11 1 22
13 2 22
15 3 22
17 0 22
19 1 22
21 0 22
proc print data=test;
  %comprisk(data=test,time=time,event=evt,group=all,print=Y);
 run;
 */
 
 
