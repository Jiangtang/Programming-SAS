/*<pre><b>
/ Program   : qcdstatbe.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 26-Jan-2012
/ Purpose   : To QC the XLAB 2 DSTATBE table
/ SubMacros : %mkformat %popfmt %unistats %suffix %words %qcworst %qcmean
/             %qcmedian : %unimap %mvarlist %removew %noquotes %quotecnt
/             %remove %windex %attrn %varnum %varfmt %quotelst
/ Notes     : This macro creates the change from baseline table in an identical
/             layout to the XLAB 2 macro using XLAB 2 style datasets. Note that
/             for the GENTRT dataset it assumes the old structure such that the
/             start of the period is assumed to be the start of the analysis
/             period and not the start of screening as needed for XLAB 2.
/
/             This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             Normalisation is done by adjusting the lab value based on its 
/             reference range converted to a standardized reference range. You
/             must supply a dataset to the instds= parameter to enable
/             normalization values to be calculated.
/
/             Baseline is defined to be the last value before the start of the
/             period specified by the analno= number supplied.
/
/             There are two styles of reports: style=1 has the timepoints as
/             the across variable (XLAB 1 style); style=2 has the treatment arm
/             as the across variable (XLAB 2 style). If you set style= to null
/             then both reports will be produced. The default is style=2.
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
/
/ Usage     : %qcdstatbe(inlab=bilab2,inpopu=popu,popu=TS,instds=labstds,
/             intrt=gentrt,analno=3,value=normalised,descstat=7)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             Input BILAB2 style dataset
/ repeat=FIRST      By default, use the FIRST value within visit for on-
/                   treatment values (pre-treatment always selects the last
/                   value and no selection is applied to post-treatment values).
/                   Valid values are MEAN, MEDIAN, FIRST, LAST and WORST (full
/                   text but case-insensitive)
/ value             Type of values required (ORIGINAL, CONVERTED or NORMALIZED)
/                   Default is CONVERTED (case and length ignored - just the
/                   first character counts),
/ instds            Lab standards dataset (no modifiers)
/ intrt             Input treatment dataset
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
/ descstat=1        Descriptive statistics number/labels (you can put footnote
/                   symbols after the labels such as use N* instead of N). You
/                   can use stats labels as well as the following numbers:
/                   1 = N* Mean SD Min P25% Median P75% Max
/                   2 = N* Min P25% Median P75% Max
/                   3 = N* Min Median Max
/                   4 = N* Mean SD
/                   5 = N* Mean SD P25% Median P75%
/                   6 = N* P25% Median P75%
/                   7 = N* Mean SD Min Median Max
/ style=2           Report style. 1=timepoint across (XLAB 1 style), 2=treatment
/                   across (XLAB 2 style), null=show both
/ trtvar=PSORT      Treatment variable (default PSORT)
/ trtdc=PTPATT      Treatment decode variable (default PTPATT)
/ gap=3             Spacing between groups of descriptive statistics columns
/ patient=Patient   What to call the patients
/ bslnlbl=Baseline                      Label for baseline
/ lastlbl=Last value on treatment       Label for last value on treatment
/ trialsft=yes      By default, list the trials in a footnote
/ ------------------- the following parameters are for debugging only ----------
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/ debug=no          Set this to yes to keep all the macro work datasets
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  26Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qcdstatbe v1.0;


%macro qcdstatbe(inlab=,
                repeat=FIRST,
                 value=CONVERTED,
                instds=,
                 intrt=,
                inpopu=,
                  popu=TS,
                analno=3,
              showmiss=no,
              descstat=1,
                 style=2,
                trtvar=PSORT,
                 trtdc=PTPATT,
                   gap=3,
               patient=Patient,
               bslnlbl=Baseline,
               lastlbl=Last value on treatment,
              trialsft=yes,
              msglevel=X,
                 debug=no
                );

  %local i key spac err errflag style1 style2 repwidth startcol colw ncolw
         valtype popudc anallbl savopts titlepos repno wherecls reptval
         labval labunit studies studiesx spat workds misstxt
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
                  Check the parameters
                ************************/

  %if not %length(&inlab) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No lab dataset specified to inlab=;
  %end;

  %if not %length(&instds) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No lab standards dataset specified to instds=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No population code specified to popu=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No analno specified to analno=;
  %end;

  %if not %length(&descstat) %then %do;
    %let errflag=1;
    %put &err: (qcdstatbe) No descriptive statistics number/labels specified to descstat=;
  %end;

  %if not %length(&repeat) %then %let repeat=first;
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


  %if not %length(&patient) %then %let patient=patient;
  %let patient=%lowcase(&patient);
  %if "&patient" EQ "healthy" %then %do;
    %let patient=healthy volunteer;
    %let spat=hel;
  %end;
  %else %if "&patient" EQ "patient" %then %let spat=pts;
  %else %let spat=%sysfunc(subpad(%sysfunc(compress(&patient,aeiou)),1,3));


  %if not %length(&style) %then %do;
    %let style1=Y;
    %let style2=Y;
  %end;
  %else %if &style EQ 1 %then %let style1=Y;
  %else %if &style EQ 2 %then %let style2=Y;

  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&value) %then %let value=converted;
  %let value=%upcase(%substr(&value,1,1));

  %if &value EQ O %then %do;
    %let labval=lab;
    %let labunit=labun;
  %end;
  %else %if &value EQ C %then %do;
    %let labval=labstd;
    %let labunit=labstdu;
  %end;
  %else %if &value EQ N %then %do;
    %let labval=labn;
    %let labunit=labstdu;
  %end;
  %if &value EQ C %then %let valtype=converted;
  %else %if &value EQ O %then %let valtype=original;
  %else %if &value EQ N %then %let valtype=normalised;

  %if not %length(&trialsft) %then %let trialsft=yes;
  %let trialsft=%upcase(%substr(&trialsft,1,1));

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));

  %if not %length(&showmiss) %then %let showmiss=no;
  %let showmiss=%upcase(%substr(&showmiss,1,1));
  %if &showmiss EQ Y %then %let misstxt=at least one baseline or last value;
  %else %let misstxt=non-missing lab values;

  %if       "&descstat" EQ "1" %then %let descstat=N* Mean SD Min P25% Median P75% Max;
  %else %if "&descstat" EQ "2" %then %let descstat=N* Min P25% Median P75% Max;
  %else %if "&descstat" EQ "3" %then %let descstat=N* Min Median Max;
  %else %if "&descstat" EQ "4" %then %let descstat=N* Mean SD;
  %else %if "&descstat" EQ "5" %then %let descstat=N* Mean SD P25% Median P75%;
  %else %if "&descstat" EQ "6" %then %let descstat=N* P25% Median P75%;
  %else %if "&descstat" EQ "7" %then %let descstat=N* Mean SD Min Median Max;

  %if &showmiss EQ Y %then %let descstat=Missing &descstat;




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
      select a.study, a.ptno, a.labnm, a.lab, a.labun, a.labstd, a.labstdu,
      a.visno, a.cpevent, a.subevno, a.ll, a.ul, 
      dhms(labdt,0,0,labtm) format=datetime19. label="lab datetime" as labdttm,
      b.rounding, b.worstdir,
      b.lln+(a.labstd-a.llc)*(b.uln-b.lln)/(a.ulc-a.llc) 
        label="Lab value norm" format=15.5 as labn
      from &inlab as a
      left join &instds(where=(type='RR' and version=5)) as b
      on a.labnm=b.labnm
     ) order by study, ptno, labnm, visno, subevno, labdttm;

  quit;

  *- replace last comma in studies list with an "and" -;
  %let studies=%comma2andmac(&studies);


               /***********************
                    Create formats
                ***********************/

  proc format;
    value tpfmt
    1="_&bslnlbl._"
    2="_%sysfunc(propcase(&lastlbl))_"
    3="_Difference from &bslnlbl._"
    ;
    value tpind
    1="  &bslnlbl"
    2="  &lastlbl"
    3="  Difference from &bslnlbl"
    ;
  run;

  *- Create two formats based on the coded and decoded      -;
  *- treatment arm values (one is undented, the other not). -;
  %mkformat(_patinfo,&trtvar,&trtdc,$atrind,indent=1);
  %mkformat(_patinfo,&trtvar,&trtdc,$atrfmt,indent=0);


  *- style 2 needs a format with the population total shown so call popfmt -;
  %if &style2 EQ Y %then %do;
    %popfmt(dsin=_patinfo,trtvar=&trtvar,trtfmt=$atrfmt.,uniqueid=study ptno,
            underscore=yes,msgs=no);
  %end;


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
  proc sort data=&workds(keep=study ptno labnm _period visno subevno labdttm
                      where=(_period=1)) out=_bslval(drop=labdttm);
    by study ptno labnm _period labdttm;
  run;

  *- keep only the last -;
  data _bslval;
    set _bslval;
    by study ptno labnm _period;
    if last.labnm;
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
    merge _bslval(in=_a) _lastval(in=_b) &workds;
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
  data _labbl(rename=(&labval=_bl));
    set _labfin(where=(_fgbslv=1));
    keep study ptno labnm &labval;
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
    merge _labbl(keep=study ptno labnm _bl) _linder;
    by study ptno labnm;
    *- generate change from baseline values -;
    _chg=&labval-_bl;
  run;


                /**************************
                     Prepare for summary
                 **************************/

  *- generate change from baseline observations -;
  data _labfin;
    set _laball(where=(_fgbslv or _fglastv));
    if _fgbslv then do;
      _tp=1; *- BASE -;
      _val=&labval;
      output;
    end;
    else do;
      _tp=2; *- LAST -;
      _val=&labval;
      output;
      _tp=3; *- DIFF -;;
      _val=_chg;
      output;
      %if "&showmiss" EQ "Y" %then %do;
        if not _hasbase then do;
          _tp=1; *- BASE -;
          _val=.;
          output;
        end;
      %end;
    end;

    %if "&showmiss" EQ "Y" %then %do;
      if not _haslast then do;
        _tp=2; *- LAST -;
        _val=.;
        output;
        _tp=3; *- DIFF -;
        output;
      end;
    %end;

  run;


        /************************************
           Calculate Descriptive Statistics
         ************************************/

  %let wherecls=(where=(_hasbase=1 and _haslast=1));
  %if &showmiss EQ Y %then %let wherecls=;

  *- Call unistats to calculate descriptive statistics with -;
  *- a transposed-by-statistic output dataset produced.     -;

  %unistats(dsin=_labfin&wherecls,
  print=no,msgs=no,varlist=_val,
  trtvar=&trtvar,trtfmt=$atrfmt.,leftstr=yes,
  byvars=_tp labnm &labunit,dpvar=rounding,
  nfmt=5.,stdfmt=5.,minfmt=5.,maxfmt=5.,meanfmt=5.,
  descstats=&descstat,dstranstat=_transtat);


           /************************
               Add Lab Group Info
            ************************/

  *- add in the lab group info -;
  proc sql noprint;
    create table _transtat2 as (
    select a.*, b.labnmx, b.labgrp, b.labgrpx, b.labnmor,
    trim(b.labnmx)||"  ["||trim(a.&labunit)||"]" length=80 as _labstr
    from _transtat as a
    left join _labgrp as b
    on a.labnm=b.labnm
    ) order by labgrp, labgrpx, labnmor, labnm;
  quit;


              /************************
                 Titles and Footnotes
               ************************/

  %let repwidth=%sysfunc(getoption(ls));
  %let repno=&mrds;
  %let titlepos=1;
  %if "%substr(&mrds,1,4)" EQ "Erro" %then %do;
    %let repno=X.X.X;
    %let titlepos=4;
    title1 &title;
  %end;
  title&titlepos "&acctype &repno  Descriptive statistics for %lowcase(&bslnlbl), 
%lowcase(&lastlbl), and difference from %lowcase(&bslnlbl) (&valtype) - &popudc";
  title%eval(&titlepos+2) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Treatment analysis: &anallbl";
  title%eval(&titlepos+4) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Functional Group: #byval(labgrpx)";

  footnote1 "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))";
  footnote2 "N* = Number of &patient.s with &misstxt per time-point or visit / summary visit";
  footnote3 "The selected algorithm for repeat values is &repeat..";
  footnote4 "The selected algorithm for multiple values is CLOSEST.";
  %if "&trialsft" EQ "Y" %then %do;
    %if %length(Trial(s): &studies) GT &repwidth %then %do;
      %let studiesx=%splitmac(%nrbquote(Trial(s): &studies),&repwidth);
      footnote5 "%scan(&studiesx,1,*)";
      footnote6 "%scan(&studiesx,2,*)";
      footnote8 &footnote;
    %end;
    %else %do;
      footnote5 "Trial(s): &studies";
      footnote7 &footnote;
    %end;
  %end;
  %else %do;
    footnote6 &footnote;
  %end;


             /*******************************
                Produce XLAB 1 style report
              *******************************/

  *- style=1 (XLAB 1) report with timepoint as the across variable -;
  %if &style1 EQ Y %then %do;

    %let ncolw=8;
    %if %words(&_statkeys_) GT 5 %then %let ncolw=6;

    *- for normalised values only show if we have a non-missing rounding variable value -;
    %let wherecls=;
    %if &value EQ N %then %let wherecls=(where=(not missing(rounding)));

    *- The _statkeys_ content is dynamically handled in the proc report call. -;
    *- If it flows onto the following page then &trtvar will be shown at the  -;
    *- start of the following page because it is defined as an "id" variable. -;

    proc report missing headline headskip nowd split="@" spacing=1 data=_transtat2&wherecls;  
      by labgrp labgrpx;
      columns ( "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
                labnmor _labstr labnm &trtvar _tp,(%suffix(STR,&_statkeys_)) _foolrep); 
      define labnmor / group noprint; 
      define _labstr / group noprint;  
      define labnm / group noprint;  
      define &trtvar / id group order=internal "Parameter/" " Treatment"
                       format=$atrind. width=20 spacing=0;
      define _tp / across " " order=internal format=tpfmt. ; 
      %do i=1 %to %words(&_statkeys_);
        %let key=%scan(&_statkeys_,&i,%str( ))STR;
        %let spac=;
        %if &i EQ 1 %then %let spac=spacing=&gap;
        %if &key EQ NMISSSTR %then %let colw=%sysfunc(max(7,&ncolw));
        %else %let colw=&ncolw;
        define &key / display width=&colw &spac right;
       %end;
      define _foolrep / noprint; 
      compute before labnm;
        line @1 _labstr $char60.;
      endcompute;
      break after labnm / skip;
    run;
  %end;


             /*******************************
                Produce XLAB 2 style report
              *******************************/

  *- style=2 (XLAB 2) report with treatment arm as the across variable -;
  %if &style2 EQ Y %then %do;

    %let ncolw=8;
    %if %words(&_statkeys_) GT 6 %then %let ncolw=6;

    *- for normalised values only show if we have a non-missing rounding variable value -;
    %let wherecls=;
    %if &value EQ N %then %let wherecls=(where=(not missing(rounding)));

    *- The _statkeys_ content is dynamically handled in the proc report call. -;
    *- If it flows onto the following page then _tp will be shown at the      -;
    *- start of the following page because it is defined as an "id" variable. -;

    proc report missing headline headskip nowd split="@" spacing=2 data=_transtat2&wherecls;  
      by labgrp labgrpx;
      columns ( "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
                labnmor _labstr labnm _tp &trtvar,(%suffix(STR,&_statkeys_)) _foolrep);  
      define labnmor / group noprint;
      define _labstr / group noprint;  
      define labnm / group noprint;  
      define _tp / id group order=internal "Parameter/" "  Visit/" "  Difference from %lowcase(&bslnlbl)"
                  format=tpind. width=30 spacing=0 left;
      /* _popfmt_ contains the identity of the format created by the %popfmt call */
      define &trtvar / across " " order=internal format=&_popfmt_ ; 
      %do i=1 %to %words(&_statkeys_);
        %let key=%scan(&_statkeys_,&i,%str( ))STR;
        %let spac=;
        %if &i EQ 1 %then %let spac=spacing=&gap;
        %if &key EQ NMISSSTR %then %let colw=%sysfunc(max(7,&ncolw));
        %else %let colw=&ncolw;
        define &key / display width=&colw &spac right;
      %end;
      define _foolrep / noprint; 
      compute before labnm;
        line @1 _labstr $char60.;
      endcompute;
      break after labnm / skip;
    run;
  %end;


              /********************
                 Tidy up and Exit
               ********************/

  *- keep the _linder dataset if debug is set to yes -;
  proc datasets nolist;
    delete _lab _lab2 _lab3 _laball _bslval _lastval
           %if &repeat NE FIRST and &repeat NE LAST %then _lab4;
           _labbl _labgrp _lablast _lablast2 _labfin
           _patinfo _patinfo2 _popfmt 
           _transtat _transtat2 _unistats
           %if &debug NE Y %then _linder;
           ;
  quit;


  %goto skip;
  %exit: %put &err: (qcdstatbe) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend qcdstatbe;
