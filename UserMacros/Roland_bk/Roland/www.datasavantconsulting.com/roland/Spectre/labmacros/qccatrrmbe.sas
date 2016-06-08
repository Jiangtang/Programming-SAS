/*<pre><b>
/ Program   : qccatrrmbe.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Jan-2012
/ Purpose   : To QC the XLAB 2 CATRRMBE table
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
/             There is currently no RRMCLASS parameter so Only the standard
/             reference range is implemented and the footnotes have been
/             simplified to reflect this.
/
/ Usage     : %qccatrrmbe(inlab=bilab2,inpopu=popu,popu=TS,instds=labstds,
/             intrt=gentrt,analno=3,repeat=worst)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             Input BILAB2-style dataset
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
/ showmiss=no       By default, ignore those patients who do not have both
/                   baseline and on-treatment values.
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
/ rrb  26Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qccatrrmbe v1.0;


%macro qccatrrmbe(inlab=,
               repeat=WORST,
             multiple=CLOSEST,
               instds=,
                intrt=,
               inpopu=,
                 popu=TS,
               analno=3,
             showmiss=no,
               trtvar=PSORT,
                trtdc=PTPATT,
              patient=Patient,
              bslnlbl=Baseline,
              lastlbl=Last value on treatment,
             trialsft=yes,
             msglevel=X,
                debug=no
                );

  %local i j key spac err errflag repwidth workds wherecls spat misstxt
         popudc anallbl savopts titlepos repno studies reptval studiesx
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
    %put &err: (qccatrrmbe) No lab dataset specified to inlab=;
  %end;

  %if not %length(&instds) %then %do;
    %let errflag=1;
    %put &err: (qccatrrmbe) No lab standards dataset specified to instds=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (qccatrrmbe) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (qccatrrmbe) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (qccatrrmbe) No population code specified to popu=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (qccatrrmbe) No analno specified to analno=;
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
    %put &err: (qccatrrmbe) repeat=&repeat must be MEAN, MEDIAN, FIRST, LAST or WORST;
  %end;

  %if &errflag %then %goto exit;


  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&multiple) %then %let multiple=closest;
  %let multiple=%upcase(&multiple);

  %if not %length(&trialsft) %then %let trialsft=yes;
  %let trialsft=%upcase(%substr(&trialsft,1,1));


  %if not %length(&patient) %then %let patient=patient;
  %let patient=%lowcase(&patient);
  %if "&patient" EQ "healthy" %then %do;
    %let patient=healthy volunteer;
    %let spat=hel;
  %end;
  %else %if "&patient" EQ "patient" %then %let spat=pts;
  %else %let spat=%sysfunc(subpad(%sysfunc(compress(&patient,aeiou)),1,3));
  %let spat=%sysfunc(propcase(&spat));


  %if not %length(&showmiss) %then %let showmiss=no;
  %let showmiss=%upcase(%substr(&showmiss,1,1));
  %if &showmiss EQ Y %then %let misstxt=at least one baseline or last value;
  %else %let misstxt=non-missing lab values;

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
      select a.study, a.ptno, a.visno, a.cpevent, a.subevno, a.labnm, a.rngflag,
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
  data _labbl(rename=(rngflag=_blflag));
    set _labfin(where=(_fgbslv=1));
    keep study ptno labnm rngflag &trtvar;
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
                    Merge with baseline
                 **************************/

  *- The baseline dataset _labbl from a pre-LINDER -;
  *- stage is reused to save processing time.      -;
  data _laball;
    length _flags $ 2;
    merge _labbl(in=_a) _lablast2(in=_b);
    by study ptno &trtvar labnm;
    %if &showmiss NE Y %then %do;
      if _hasbase and _haslast;
    %end;
    if rngflag EQ " " then rngflag="M"; *- missing -;
    if _blflag EQ " " then _blflag="M"; *- missing -;
    _flags=compress(_blflag||rngflag);
  run;



                /**************************
                         Summarize
                 **************************/

  proc summary nway data=_laball;
    class labnm &trtvar _flags;
    output out=_labsum(drop=_type_);
  run;


                /**************************
                         Transpose
                 **************************/

  proc transpose data=_labsum out=_labtran(drop=_name_);
    by labnm &trtvar;
    id _flags;
    var _freq_;
  run;

                /**************************
                         Transform
                 **************************/

  data _labtran2;
    retain hh hm hn ll lm ln nh nn mn hl ml mh lh nl nm mm 0;
    length _cat $ 20;
    set _labtran;
    %if &showmiss NE Y %then %do;
      lm=0;nm=0;hm=0;mm=0;ml=0;mn=0;mh=0;
    %end;
    _grp=1;
    _cat="  < LL";
    _ord=1;
    tom=sum(0,LM);
    tol=sum(0,LL);
    ton=sum(0,LN);
    toh=sum(0,LH);
    tot=sum(tom,tol,ton,toh);
    output;
    _cat="  [LL, UL]";
    _ord=2;
    tom=sum(0,NM);
    tol=sum(0,NL);
    ton=sum(0,NN);
    toh=sum(0,NH);
    tot=sum(tom,tol,ton,toh);
    output;
    _cat="  > UL";
    _ord=3;
    tom=sum(0,HM);
    tol=sum(0,HL);
    ton=sum(0,HN);
    toh=sum(0,HH);
    tot=sum(tom,tol,ton,toh);
    output;
    _grp=2;
    %if &showmiss EQ Y %then %do;
      _cat="  Missing";
      _ord=9;
      tom=sum(0,MM);
      tol=sum(0,ML);
      ton=sum(0,MN);
      toh=sum(0,MH);
      tot=sum(tom,tol,ton,toh);
      output;
    %end;
    _cat="  Total";
    _ord=8;
    tom=sum(0,LM,NM,HM,MM);
    tol=sum(0,LL,NL,HL,ML);
    ton=sum(0,LN,NN,HN,MN);
    toh=sum(0,LH,NH,HH,MH);
    tot=sum(tom,tol,ton,toh);
    output;
    drop hh hm hn ll lm ln nh nn mn hl ml mh lh nl nm mm;

  run;


                /**************************
                    Calculate percentages
                 **************************/

  data _labtran3;
    length tomstr tolstr tonstr tohstr totstr $ 13;
    set _labtran2;

    if tom=0 then tomstr=put(tom,4.);
    else tomstr=put(tom,4.)||" ("||put(100*tom/tot,5.1)||")";

    if tol=0 then tolstr=put(tol,4.);
    else tolstr=put(tol,4.)||" ("||put(100*tol/tot,5.1)||")";

    if ton=0 then tonstr=put(ton,4.);
    else tonstr=put(ton,4.)||" ("||put(100*ton/tot,5.1)||")";

    if toh=0 then tohstr=put(toh,4.);
    else tohstr=put(toh,4.)||" ("||put(100*toh/tot,5.1)||")";

    if tot=0 then totstr=put(tot,4.);
    else totstr=put(tot,4.)||" ("||put(100*tot/tot,5.1)||")";

    label tomstr="    Missing"
          tolstr="      < LL"
          tonstr="   [LL, UL]"
          tohstr="      > UL"
          totstr="    Total"
          ;
  run;


                /**************************
                     Add lab group order
                 **************************/

  *- add in the lab group info for proc report ordering -;
  proc sql noprint;
    create table _labrep as (
    select a.*, b.labgrp, b.labgrpx, b.labnmor, b.labnmx
    from _labtran3 as a
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
  title&titlepos "&acctype &repno  Frequency of &patient.s [N(%)] categorised by reference range and 
specified markers and %lowcase(&lastlbl) - &popudc";
  title%eval(&titlepos+2) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Treatment analysis: &anallbl";
  title%eval(&titlepos+4) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) #byval(labgrpx): #byval(labnmx)";

  *- use a repeated mid-line long hyphen (byte(131)) for the first footnote -;
  footnote1 "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))";
  footnote2 "Key: LL = Lower limit of normal, UL = Upper limit of normal";
  footnote3 "Categorisation is based on original lab values.";
  footnote4 "The selected algorithm for repeat values is &repeat..";
  footnote5 "The selected algorithm for multiple values is &multiple..";
  %if "&trialsft" EQ "Y" %then %do;
    %if %length(Trial(s): &studies) GT &repwidth %then %do;
      %let studiesx=%splitmac(%nrbquote(Trial(s): &studies),&repwidth);
      footnote6 "%scan(&studiesx,1,*)";
      footnote7 "%scan(&studiesx,2,*)";
      footnote9 &footnote;
    %end;
    %else %do;
      footnote6 "Trial(s): &studies";
      footnote8 &footnote;
    %end;
  %end;
  %else %do;
    footnote7 &footnote;
  %end;


                /**************************
                       Produce report
                 **************************/

  proc report missing headline headskip nowd split="@" spacing=3 data=_labrep;  
    by labgrp labgrpx labnmor labnm labnmx;
    columns ("%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
              &trtvar _grp _ord _cat 
              %if &showmiss EQ Y %then %do;
                tomstr 
              %end;
             ("_&lastlbl._" " " tolstr tonstr tohstr)
              totstr
            );  
    define &trtvar / order order=internal noprint;
    define _grp    / order order=internal noprint;
    define _ord    / order order=internal noprint;
    define _cat / id order width=20 "Treatment/" "  &bslnlbl RR" spacing=0;
    %if &showmiss EQ Y %then %do;
      define tomstr / display width=13;
    %end;
    define tolstr / display width=13;
    define tonstr / display width=13;
    define tohstr / display width=13;
    define totstr / display width=13;
    compute before &trtvar;
      *- _popfmt_ contains the identity of the -;
      *- format created by the %popfmt call    -;
      line @1 &trtvar &_popfmt_;
    endcompute;
    break after _grp / skip;
  run;  


                /**************************
                      Tidy up and exit
                 **************************/

  *- keep the _linder dataset if debug is set to yes -;
  proc datasets nolist;
    delete _patinfo _patinfo2 _lab _lab2 _lab3 
           %if &repeat NE FIRST and &repeat NE LAST %then _lab4;
           _labgrp _laball _labtran _labtran2 _labtran3
           _labbl _labfin _lablast _lablast2 _labsum _labrep
           _lastval _popfmt _bslval
           %if &debug NE Y %then _linder;
           ;
  quit;


  %goto skip;
  %exit: %put &err: (qccatrrmbe) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend qccatrrmbe;
