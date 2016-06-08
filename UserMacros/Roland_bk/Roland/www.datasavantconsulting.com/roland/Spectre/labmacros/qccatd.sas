/*<pre><b>
/ Program   : qccatd.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 22-Jan-2012
/ Purpose   : To QC the XLAB 2 CATD table
/ SubMacros : %mkformat %popfmt %qcworst %qcmean %qcmedian : %hasvars %match
/             %varlist %nodup %words %varlen %attrv %vartype
/ Notes     : This macro creates an identical layout to the XLAB 2 macro using
/             XLAB 2 style datasets.
/
/             Note that for the GENTRT dataset it assumes the old structure such
/             that the start of the period is assumed to be the start of the
/             analysis period and not the start of screening as is needed for
/             XLAB 2.
/
/             This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             The Minimum and Maximum values on treatment are calculated 
/             independently of the REPEAT algorithm. 
/
/             If you set debug=yes the _linder dataset will be kept which you
/             can then compare with the LINDER dataset from XLAB 2. All values
/             should match but the _linder dataset has less variables. This
/             macro reports from the _linder dataset as does XLAB 2.
/
/             This macro was designed for use within the CARE/Rage environment.
/
/ Limitations:
/
/             Multiple selection processing has not yet been implemented as
/             there seems to be no need.
/
/ Usage     : %qccatd(inlab=bilab2,inpopu=popu,popu=TS,instds=labstds,
/             intrt=gentrt,analno=3,repeat=worst)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             Input BILAB2-style dataset
/ delta             String that is a numeric integer percentage followed by a
/                   space followed by RR or BASELINE (must be specified - see
/                   XLAB 2 manual).
/ repeat=WORST      By default, use the WORST value within visit for on-
/                   treatment values (pre-treatment always selects the last
/                   value and no selection is applied to post-treatment values).
/                   Valid values are MEAN, MEDIAN, FIRST, LAST and WORST (full
/                   text but case-insensitive)
/ multiple=CLOSEST  By default use the closest value when we have multiple
/                   non-repeating values per timepoint. Valid values are
/                   CLOSEST. NOTE: Multiple selection processing has not been
/                   implemented yet in this macro !!!!
/ instds            Lab standards dataset (no modifiers)
/ intrt             Input GENTRT treatment dataset (note that this must be the
/                   old-style GENTRT dataset such that starts of analnos are the
/                   start of treatment and not the screening date).
/ inpopu            Input population dataset
/ popu=TS           Population identifier string (unquoted) (defaults to TS)
/ analno=3          Analysis number in intrt dataset to use (defaults to 3).
/                   Note that this macro works with the old definition of
/                   analno period start and end dates such that the start of the
/                   period is the start of treatment (or the start of the
/                   analysis period) and not the start of screening as is done
/                   for XLAB 2.
/ trtvar=PSORT      Treatment variable (default PSORT)
/ trtdc=PTPATT      Treatment decode variable (default PTPATT)
/ patient=Patient   What to call the patients
/ bslnlbl=Baseline                      Label for baseline
/ lastlbl=Last value on treatment       Label for last value on treatment
/ trialsft=yes      By default, list the trials in a footnote
/ ------------------- the following parameters are for debugging only ----------
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/ debug=no          Set this to yes to keep the _linder dataset
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  22Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qccatd v1.0;


%macro qccatd(inlab=,
             repeat=WORST,
           multiple=CLOSEST,
             instds=,
              delta=10 RR,
              intrt=,
             inpopu=,
               popu=TS,
             analno=3,
             trtvar=PSORT,
              trtdc=PTPATT,
            patient=Patient,
            bslnlbl=Baseline,
            lastlbl=Last value on treatment,
           trialsft=yes,
           msglevel=X,
              debug=no
              );

  %local i j key spac err errflag repwidth workds delta1 delta2 deltastr
         popudc anallbl savopts titlepos repno studies studiesx reptval 
         ;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&msglevel) %then %let msglevel=X;
  %let msglevel=%upcase(%substr(&msglevel,1,1));
  %if "&msglevel" NE "N" and "&msglevel" NE "I" %then %let msglevel=X;


                /*************************
                   Store and set options
                 *************************/

  %let savopts=%sysfunc(getoption(byline)) %sysfunc(getoption(date))
  %sysfunc(getoption(number)) %sysfunc(getoption(center)) 
  %sysfunc(getoption(notes))  %sysfunc(getoption(msglevel,keyword));

  options nobyline nodate nonumber nocenter;

  %if "&msglevel" EQ "N" or "&msglevel" EQ "I" %then %do;
    options msglevel=&msglevel;
  %end;
  %else %do;
    options nonotes;
  %end;


                /************************
                     Check parameters
                 ************************/

  %if not %length(&inlab) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No lab dataset specified to inlab=;
  %end;

  %if not %length(&instds) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No lab standards dataset specified to instds=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No population code specified to popu=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No analno specified to analno=;
  %end;

  %let delta=%upcase(&delta);
  %let delta1=%scan(&delta,1,%str( ));
  %let delta2=%scan(&delta,2,%str( ));

  %if not %length(&delta) %then %do;
    %let errflag=1;
    %put &err: (qccatd) No delta values specified to delta=;
  %end;
  %else %if not %length(&delta2) %then %do;
    %let errflag=1;
    %put &err: (qccatd) Delta value "&delta" should have two parts (number RR / BASELINE);
  %end;
  %else %if "&delta2" NE "RR" and "&delta2" NE "BASELINE" %then %do;
    %let errflag=1;
    %put &err: (qccatd) Delta value "&delta" should have RR or BASELINE as the second part;
  %end;
  %else %if %length(%sysfunc(compress(&delta1,0123456789))) %then %do;
    %let errflag=1;
    %put &err: (qccatd) Delta value "&delta" first part should be an integer percentage;
  %end;

  %if not %length(&repeat) %then %let repeat=worst;
  %let repeat=%upcase(&repeat);

  %if &repeat EQ MEAN %then %let reptval=1;
  %else %if &repeat EQ MEDIAN %then %let reptval=2;
  %else %if &repeat EQ FIRST %then %let reptval=3;
  %else %if &repeat EQ LAST %then %let reptval=4;
  %else %if &repeat EQ WORST %then %let reptval=5;

  %if not %length(&reptval) %then %do;
    %let errflag=1;
    %put &err: (qccatd) repeat=&repeat must be MEAN, MEDIAN, FIRST, LAST or WORST;
  %end;

  %if &errflag %then %goto exit;


  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&multiple) %then %let multiple=closest;
  %let multiple=%upcase(&multiple);

  %if not %length(&trialsft) %then %let trialsft=yes;
  %let trialsft=%upcase(%substr(&trialsft,1,1));

  %let patient=%lowcase(&patient);

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));




       /*================================================*
        *================================================*
                          BUILD LINDER
        *================================================*
        *================================================*/


                  /************************
                       Extract the data
                   ************************/

  *- extract the data -;
  proc sql noprint;

    create table _patinfo as (
      select pop.study, pop.ptno, pop.popu, pop.popudc,
      trt.analno, trt.anallbl, 
      trt.&trtvar, trt.&trtdc,
      case when sum(0,pre.atrstdt,pre.atrsttm) then dhms(pre.atrstdt,0,0,pre.atrsttm) else . end
      format=datetime19. label="pre-treatment start"  as predtst,
      case when sum(0,trt.atrstdt,trt.atrsttm) then dhms(trt.atrstdt,0,0,trt.atrsttm) else . end
      format=datetime19. label="on-treatment start"   as ontdtst,
      case when sum(0,trt.atrspdt,trt.atrsptm) then dhms(trt.atrspdt,0,0,trt.atrsptm) else . end
      format=datetime19. label="on-treatment stop"    as ontdtsp,
      case when sum(0,pos.atrstdt,pos.atrsttm) then dhms(pos.atrstdt,0,0,pos.atrsttm) else . end
      format=datetime19. label="post-treatment start" as posdtst,
      case when sum(0,pos.atrspdt,pos.atrsptm) then dhms(pos.atrspdt,0,0,pos.atrsptm) else . end
      format=datetime19. label="post-treatment stop"  as posdtsp,
      case when sum(0,pst.atrstdt,pst.atrsttm) then dhms(pst.atrstdt,0,0,pst.atrsttm) else . end
      format=datetime19. label="post-study start"     as pstdtst,
      case when sum(0,pst.atrspdt,pst.atrsptm) then dhms(pst.atrspdt,0,0,pst.atrsptm) else . end
      format=datetime19. label="post-study stop"      as pstdtsp

      /*--- population ---*/
      from &inpopu(where=(popu="&popu" and popuny=1)) as pop

      /*--- on treatment ---*/
      left join &intrt(where=(analno=&analno)) as trt
      on pop.study=trt.study and pop.ptno=trt.ptno

      /*--- pre treatment ---*/
      left join &intrt(where=(analno=6)) as pre
      on pop.study=pre.study and pop.ptno=pre.ptno

      /*--- post treatment ---*/
      left join &intrt(where=(analno=1 and atrcd="90000003")) as pos
      on pop.study=pos.study and pop.ptno=pos.ptno

      /*--- post study ---*/
      left join &intrt(where=(analno=1 and atrcd="90000011")) as pst
      on pop.study=pst.study and pop.ptno=pst.ptno

    ) order by study, ptno;

    select distinct(study)   into: studies separated by ", " from _patinfo;
    select distinct(popudc)  into: popudc  separated by " " from _patinfo;
    select distinct(anallbl) into: anallbl separated by " " from _patinfo;

    *- lab grouping variables -;
    create table _labgrp as (
      select labnm, labnmx, labgrp, labgrpx, labnmor from &instds(where=(type='LG'))
    );

    *- lab values -;
    create table _lab as (
      select a.study, a.ptno, a.visno, a.cpevent, a.subevno, a.labnm,
      a.lab, a.ll, a.ul, b.worstdir,
      dhms(labdt,0,0,labtm) format=datetime19. label="lab datetime" as labdttm
      from &inlab as a
      left join &instds(where=(type='RR' and version=5)) as b
      on a.labnm=b.labnm
     ) order by study, ptno, labnm, visno, subevno, labdttm;

  quit;

  *- replace last comma in studies list with an "and" -;
  %let studies=%comma2andmac(&studies);


                /************************
                      Create formats
                 ************************/

  *- Create a format to map treatment code to the  -;
  *- decode label for use in the following format. -;
  %mkformat(_patinfo,&trtvar,&trtdc,$atrfmt,indent=0);

  *- create a format for treatment arm totals -;
  %popfmt(dsin=_patinfo,trtvar=&trtvar,trtfmt=$atrfmt.,uniqueid=study ptno,
          split=%str( ),msgs=no);


                /************************
                      Extend patinfo
                 ************************/

  data _patinfo2;
    set _patinfo;
    *- combine post-treatment and post-study start and stop -;
    *- and make sure that the start is not before the       -;
    *- on-treatment stop datetime.                          -;
    cmbdtst=max(0,ontdtsp,min(0,posdtst,pstdtst));
    if cmbdtst=0 then cmbdtst=.;
    cmbdtsp=max(0,posdtsp,pstdtsp);
    if cmbdtsp=0 then cmbdtsp=.;
    format cmbdtst cmbdtsp datetime19.;
    *- these two no longer needed -;
    drop anallbl popudc;
    label cmbdtst="post-treatment/study start"
          cmbdtsp="post-treatment/study stop"
          ;
  run;

                /************************
                      Add lab flags
                 ************************/

  *- _period is used as a work variable which will be dropped -;
  *- from _linder and added again at a later stage. Only lab  -;
  *- values for the specified treatment population are kept.  -;
  data _lab2;
    length _fgprev _fgontv _fgpostv 3;
    merge _patinfo2(in=_a) _lab(in=_b);
    by study ptno;
    if _a and _b;
    if labdttm<=predtst then _period=0;
    else if predtst<labdttm<=ontdtst then do;
      _period=1;
      _fgprev=1;
    end;
    else if ontdtst<labdttm<=ontdtsp then do;
      _period=2;
      _fgontv=1;
    end;
    else if cmbdtst<labdttm<=cmbdtsp then do;
      _period=9;
      _fgpostv=1;
    end;
    else _period=99;
    drop predtst ontdtst ontdtsp posdtst posdtsp
         pstdtst pstdtsp cmbdtst cmbdtsp;
    label _fgprev="Pre-treatment value flag"
          _fgontv="On-treatment value flag"
          _fgpostv="Post-treatment value flag"
          ;
    format _fgprev _fgontv _fgpostv 1.;
  run;

  proc sort data=_lab2;
    by study ptno labnm _period visno subevno;
  run;


                /************************
                    Flag REPEAT values
                 ************************/

  data _lab3;
    length _fgrept 3;
    set _lab2;
    by study ptno labnm _period visno subevno;

    if _fgprev and not last.visno then _fgrept=&reptval;

    if _period=99 and not last.visno then _fgrept=&reptval;

    %if &repeat EQ FIRST or &repeat EQ LAST %then %do;
      else if _period=2 and not &repeat..visno then _fgrept=&reptval;
    %end;

    label _fgrept="Repeated Values";
    format _fgrept 4.;
  run;


                /*************************+********
                   Non FIRST/LAST Repeat Flagging
                 **********************************/

  %let workds=_lab3;

  %if &repeat NE FIRST and &repeat NE LAST %then %do;
    %qc&repeat(_lab3,_lab4);
    %let workds=_lab4;
  %end;
 

                /**********************************
                    Baseline and Last Value Flag
                 **********************************/

  *- Sometimes this value is not in the correct visno order so it -;
  *- needs to be sorted in labdttm order. All values are used.    -;
  proc sort data=&workds(keep=study ptno labnm _period visno subevno labdttm lab
                      where=(_period=1)) out=_bslval(drop=labdttm);
    by study ptno labnm _period labdttm;
  run;

  *- keep only the last -;
  data _bslval;
    set _bslval;
    by study ptno labnm _period;
    if last.labnm;
    rename lab=_bl;
  run;


  *- Sometimes this value is not in the correct visno order so it -;
  *- needs to be sorted in labdttm order. Only non-repeats used.  -;
  proc sort data=&workds(keep=study ptno labnm _period visno subevno labdttm _fgrept
                      where=(_period=2 and not _fgrept)) 
                      out=_lastval(drop=labdttm _fgrept);
    by study ptno labnm _period labdttm;
  run;

  *- keep only the last -;
  data _lastval;
    set _lastval;
    by study ptno labnm _period;
    if last.labnm;
  run;


  *- merge and set flags -;
  data _labfin;
    length _fgbslv _fglastv 3;
    merge _bslval(drop=_bl in=_a) _lastval(in=_b) &workds;
    by study ptno labnm _period visno subevno;
    if _a then _fgbslv=1;
    *- for MEAN and MEDIAN repeat processing we need to check _fgrept -;
    if _b and not _fgrept then _fglastv=1;
    label _fglastv="Last Value Flag"
          _fgbslv="Baseline Flag"
          ;
    format _fgbslv _fglastv 4.;
  run;


                /**************************
                      Baseline value
                 **************************/

  *- baseline to be used to calculate c-f-b -;
  data _labbl(rename=(lab=_baseline));
    set _labfin(where=(_fgbslv=1));
    keep study ptno labnm lab;
  run;


                /**************************
                   Last value on treatment
                 **************************/

  data _lablast;
    set _labfin(where=(_fglastv=1));
    keep study ptno labnm;
  run;


                /*************************
                   Create LINDER dataset
                 *************************/

  data _linder;
    length _hasbase _haslast 3;
    merge _labbl(keep=study ptno labnm in=_a) 
          _lablast(keep=study ptno labnm in=_b)
          _labfin(in=_c);
    by study ptno labnm;
    if _c;

    *- Create the variables that indicate whether -;
    *- baseline and on-tretment values exist.     -;
    if _a then _hasbase=1;
    if _b then _haslast=1;
    label _hasbase="Does Patient have Baseline Value?"
          _haslast="Does Patient have Last Value?"
          ;
    format _hasbase _haslast 4.;

    *- A number of variables have to be set to missing -;
    *- if the timepoints fall outside the range.       -;
    if not (_fgprev or _fgontv or _fgpostv) then do;
      &trtvar=" ";&trtdc=" ";
      _hasbase=.;_haslast=.;
    end;

    *- drop non-standard variables (add them later if needed) -;
    drop _period;
  run;




       /*================================================*
        *================================================*
                         PRODUCE REPORT
        *================================================*
        *================================================*/


  *- Note that the data in the final report ahould all come from -;
  *- the LINDER dataset (although we will be adding and merging  -;
  *- other information needed for the final presentation).       -;


                /**************************
                   Last value on treatment
                 **************************/

  data _lablast2;
    set _linder(where=(_fglastv=1));
    _period=5;
    visno=.;
    cpevent=" ";
  run;

                /**************************
                  Min and Max on treatment
                 **************************/

  *- all values including repeat values are used for this -;
  proc sort data=_linder(drop=visno where=(_fgontv)) out=_labmax;
    by study ptno labnm lab;
  run;

  data _minmax;
    set _labmax;
    by study ptno labnm;
    _fgrept=.;
    visno=.;
    cpevent=" ";
    if first.labnm then do;
      _period=3;
      output;
    end;
    if last.labnm then do;
      _period=4;
      output;
    end;
  run;

                /**************************
                   Bring the data together
                 **************************/

  data _laball;
    set _linder _minmax _lablast2;
  run;
  proc sort data=_laball;
    by study ptno labnm;
  run;


                /**************************
                    Merge with baseline
                 **************************/

  *- The baseline dataset _labbl from a pre-LINDER -;
  *- stage is reused to save processing time.      -;
  data _laball2;
    merge _labbl(in=_a) _laball(in=_b);
    by study ptno labnm;
    if _a and _b;
    *- generate change from baseline values -;
    _chg=lab-_baseline;
    _rr=ul-ll;
    if _chg < -&delta1 * _&delta2 / 100 then d1n=1;
    else if _chg > &delta1 * _&delta2 / 100 then d3n=1;
    else d2n=1;
  run;


                /**************************
                     Prepare for summary
                 **************************/

  *- we need to add some display and ordering variables for proc report -;
  data _laball3;
    set _laball2;

    *- add back in the _period variable for proc report ordering -;
    if _period=. then do;
      if _fgprev then _period=1;
      else if _fgontv then _period=2;
      else if _fgpostv then _period=9;
    end;
  run;


                /**************************
                         Summarize
                 **************************/

  proc summary nway missing data=_laball3(where=(_period in (2,3,4,5) and _hasbase and _haslast and not _fgrept));
    class labnm &trtvar _period visno cpevent;
    var _chg d1n d2n d3n;
    output out=_labsum(drop=_type_ _freq_) n(_chg)=ntot n(d1n)=nd1 n(d2n)=nd2 n(d3n)=nd3;
  run;


                /**************************
                    Calculate percentages
                 **************************/

  data _labsum2;
    length d1str d2str d3str $ 13;
    set _labsum;
    if nd1=0 then d1str=put(nd1,4.);
    else d1str=put(nd1,4.)||" ("||put(100*nd1/ntot,5.1)||")";
    if nd2=0 then d2str=put(nd2,4.);
    else d2str=put(nd2,4.)||" ("||put(100*nd2/ntot,5.1)||")";
    if nd3=0 then d3str=put(nd3,4.);
    else d3str=put(nd3,4.)||" ("||put(100*nd3/ntot,5.1)||")";
    label ntot="N"
          d1str="     < -d"
          d2str="   [-d, d]"
          d3str="     > d"
          ;
  run;


                /**************************
                     Add lab group order
                 **************************/

  *- add in the lab group info for proc report ordering -;
  proc sql noprint;
    create table _labsum3 as (
    select a.*, b.labgrp, b.labgrpx, b.labnmor, b.labnmx,
    case when _period=3 then "    Min value on treatment"
         when _period=4 then "    Max value on treatment"
         when _period=5 then "    &lastlbl"
         else "    "||cpevent
    end length=60 as _vistext
    from _labsum2 as a
    left join _labgrp as b
    on a.labnm=b.labnm
    ) order by labgrp, labgrpx, labnmor, labnm, labnmx;
  quit;


                /**************************
                    Titles and Footnotes
                 **************************/

  *- make the report top line and the first footnote line a full page width -;
  %let repwidth=%sysfunc(getoption(ls));

  *- pick up the CARE/Rage report number, title and footnote -;
  %let repno=&mrds;
  %let titlepos=1;
  %if "%substr(&mrds,1,4)" EQ "Erro" %then %do;
    %let repno=X.X.X;
    %let titlepos=4;
    title1 &title;
  %end;

  *- use "by" variable values in the titles -;
  title&titlepos "&acctype &repno  Frequency of &patient.s [N(%)] categorised by multiples of delta 
based on difference from %lowcase(&bslnlbl) by visit - &popudc";
  title%eval(&titlepos+2) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Treatment analysis: &anallbl";
  title%eval(&titlepos+4) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) #byval(labgrpx): #byval(labnmx)";

  *- use a repeated mid-line long hyphen (byte(131)) for the first footnote -;
  footnote1 "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))";
  %if &delta2 EQ RR %then %let deltastr=the span of the reference range;
  %else %let deltastr=%lowcase(&bslnlbl);
  footnote2 "d = %scan(&delta,1,%str( )) % of &deltastr";
  footnote3 "The selected algorithm for repeat values is &repeat..";
  %if "&trialsft" EQ "Y" %then %do;
    %if %length(Trial(s): &studies) GT &repwidth %then %do;
      %let studiesx=%splitmac(%nrbquote(Trial(s): &studies),&repwidth);
      footnote4 "%scan(&studiesx,1,*)";
      footnote5 "%scan(&studiesx,2,*)";
      footnote7 &footnote;
    %end;
    %else %do;
      footnote4 "Trial(s): &studies";
      footnote6 &footnote;
    %end;
  %end;
  %else %do;
    footnote5 &footnote;
  %end;

                /**************************
                       Produce report
                 **************************/

  proc report missing headline headskip nowd split="@" spacing=5 data=_labsum3;  
    by labgrp labgrpx labnmor labnm labnmx;
    columns ("%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
              &trtvar _period visno _vistext ntot d1str d2str d3str
            );  
    define &trtvar / order order=internal noprint;
    define _period / order order=internal noprint;
    define visno   / order order=internal noprint;
    define _vistext / id order width=28 "Treatment/" "    Visit" spacing=0;
    define ntot  / display;
    define d1str / display width=13 ;
    define d2str / display width=13 ;
    define d3str / display width=13 ;
    compute before &trtvar;
      *- _popfmt_ contains the identity of the -;
      *- format created by the %popfmt call    -;
      line @1 &trtvar &_popfmt_;
    endcompute;
    break after &trtvar / skip;
  run;  


                /**************************
                      Tidy up and exit
                 **************************/

  *- keep the _linder dataset if debug is set to yes -;
  proc datasets nolist;
    delete _patinfo _patinfo2 _lab _lab2 _lab3 
           %if &repeat NE FIRST and &repeat NE LAST %then _lab4;
           _labgrp _laball _laball2 _laball3
           _labbl _labfin _lablast _lablast2 _labmax _labsum _labsum2 _labsum3
           _lastval _minmax _popfmt _bslval
           %if &debug NE Y %then _linder;
           ;
  quit;


  %goto skip;
  %exit: %put &err: (qccatd) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend qccatd;
