/*<pre><b>
/ Program   : qcdstatstr.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 29-Jan-2012
/ Purpose   : To QC the XLAB 2 DSTATSTR table
/ SubMacros : %mkformat %popfmt %unistats %suffix %words %qcworst %qcmean
/             %qcmedian : %hasvars %match %varlist %nodup %words %varlen %attrv
/             %vartype %mvarlist %removew %noquote %quotecnt %remove %windex
/             %attrn %varnum %varfmt %quotelst %unimap
/ Notes     : This macro creates stratification table output in an identical
/             layout to the XLAB 2 macro using XLAB 2 style datasets. Note that
/             for the GENTRT dataset it assumes the old structure such that the
/             start of the period is assumed to be the start of the analysis
/             period and not the start of screening as is needed for XLAB 2.
/
/             This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             This macro adjusts the gap between blocks so that blocks will not
/             be split over pages.
/
/             The Minimum and Maximum values on treatment are calculated 
/             independently of the REPEAT algorithm. Those shown by visit have
/             the REPEAT algorithm applied.
/
/             Pre-treatment values for dates earlier than the start of analno=6
/             will be ignored.
/
/             Normalisation is done by adjusting the lab value based on its 
/             reference range converted to a standardized reference range. You
/             must supply a dataset to the instds= parameter to enable
/             normalisation values to be calculated.
/
/             Baseline is defined to be the last value before the start of the
/             period specified by the analno= number supplied.
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
/             STRAT= processing has only been implemented in the form
/             VAR VARNAME and the variable is assumed to be in the PATD
/             input dataset.
/
/             Multiple selection processing has not yet been implemented as
/             there seems to be no need.
/
/ Usage     : %qcdstatstr(inlab=bilab2,inpopu=popu,popu=TS,instds=labstds,
/             intrt=gentrt,analno=3,value=normalised,descstat=7)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             Input BILAB2-style dataset
/ strat             Stratification variable in the form VAR VARNAME
/ repeat=FIRST      By default, use the FIRST value within visit for on-
/                   treatment values (pre-treatment always selects the last
/                   value and no selection is applied to post-treatment values).
/                   Valid values are MEAN, MEDIAN, FIRST, LAST and WORST (full
/                   text but case-insensitive)
/ multiple=CLOSEST  By default use the closest value when we have multiple
/                   non-repeating values per timepoint. Valid values are
/                   CLOSEST. NOTE: Multiple selection processing has not been
/                   implemented yet in this macro !!!!
/ value             Type of values required (ORIGINAL, CONVERTED or NORMALISED)
/                   Default is CONVERTED (case and length ignored - just the
/                   first character counts),
/ instds            Lab standards dataset (no modifiers)
/ intrt             Input GENTRT treatment dataset (note that this must be the
/                   old-style GENTRT dataset such that starts of analnos are the
/                   start of treatment and not the screening date).
/ inpopu            Input population dataset
/ popu=TS           Population identifier string (unquoted) (defaults to TS)
/ inpatd            Input patient details dataset containing the stratification
/                   variable.
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
/ rrb  29Jan12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: qcdstatstr v1.0;


%macro qcdstatstr(inlab=,
                  strat=,
                 repeat=FIRST,
               multiple=CLOSEST,
                  value=NORMALISED,
                 instds=,
                  intrt=,
                 inpopu=,
                   popu=TS,
                 inpatd=,
                 analno=3,
               showmiss=no,
               descstat=1,
                 trtvar=PSORT,
                  trtdc=PTPATT,
                patient=Patient,
                bslnlbl=Baseline,
                lastlbl=Last value on treatment,
               trialsft=yes,
               msglevel=X,
                  debug=no
                  );

  %local i j key spac err errflag style1 style2 workds repwidth startcol colw ncolw
         valtype popudc anallbl savopts titlepos repno maxvis putx gap misstxt
         labval labunit studies reptval wherecls val vallist stratvar stratfmt
         blockw roomleft willfit studiesx
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
    %put &err: (qcdstatstr) No lab dataset specified to inlab=;
  %end;

  %if not %length(&instds) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No lab standards dataset specified to instds=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No population code specified to popu=;
  %end;

  %if not %length(&inpatd) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No patient details dataset specified to inpatd=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No analno specified to analno=;
  %end;

  %if not %length(&descstat) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No descriptive statistics number/labels specified to descstat=;
  %end;

  %let strat=%upcase(&strat);
  %if not %length(&strat) %then %do;
    %let errflag=1;
    %put &err: (qcdstatstr) No stratification definition specified to strat=;
  %end;
  %else %do;
    %if %words(&strat) LT 2 %then %do;
      %let errflag=1;
      %put &err: (qcdstatstr) STRAT value must have more than one part. You have strat=&strat;
    %end;
    %else %if "%scan(&strat,1,%str( ))" NE "VAR" %then %do;
      %let errflag=1;
      %put &err: (qcdstatstr) STRAT value must have "VAR" as the first word. You have strat=&strat;
    %end;
    %else %let stratvar=%scan(&strat,2,%str( ));
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


  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&multiple) %then %let multiple=closest;
  %let multiple=%upcase(&multiple);

  %if not %length(&value) %then %let value=normalised;
  %let value=%upcase(%substr(&value,1,1));

  %if &value EQ O %then %do;
    %let labval=lab;
    %let labunit=labun;
    %let valtype=original;
  %end;
  %else %if &value EQ C %then %do;
    %let labval=labstd;
    %let labunit=labstdu;
    %let valtype=converted;
  %end;
  %else %if &value EQ N %then %do;
    %let labval=labn;
    %let labunit=labstdu;
    %let valtype=normalised;
  %end;

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

  %if not %length(&trialsft) %then %let trialsft=yes;
  %let trialsft=%upcase(%substr(&trialsft,1,1));

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
      trt.&trtvar, trt.&trtdc, pat.&stratvar,
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

      /*--- patient details ---*/
      left join &inpatd as pat
      on pop.study=pat.study and pop.ptno=pat.ptno

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

    select distinct(study)     into: studies separated by ", " from _patinfo;
    select distinct(popudc)    into: popudc  separated by " " from _patinfo;
    select distinct(anallbl)   into: anallbl separated by " " from _patinfo;

    *- lab grouping variables -;
    create table _labgrp as (
      select labnm, labnmx, labgrp, labgrpx, labnmor from &instds(where=(type='LG'))
    );

    *- lab values -;
    create table _lab as (
      select a.study, a.ptno, a.labnm, a.lab, a.labun, a.labstd, a.labstdu,
      a.visno, a.cpevent, a.subevno, a.ll, a.ul, 
      b.rounding, b.worstdir,
      dhms(labdt,0,0,labtm) format=datetime19. label="lab datetime" as labdttm,
      b.lln+(a.labstd-a.llc)*(b.uln-b.lln)/(a.ulc-a.llc) 
        label="Lab value norm" format=15.5 as labn
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

  %let stratfmt=%varfmt(_patinfo,&stratvar);
  %adjfmt(&stratfmt,underscore=yes);

  *- create a format to map treatment code to the decode -;
  *- label for use in the %popfmt call that follows.     -;
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
    *- drop the format on the stratification variable -;
    format &stratvar;
    label cmbdtst="post-treatment/study start"
          cmbdtsp="post-treatment/study stop"
          ;
  run;

  *- keep a list of the raw stratification variable values -;
  proc sql noprint;
    select distinct(&stratvar) into: vallist separated by " " from _patinfo2;
  quit;


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
                  Min and Max on treatment
                 **************************/

  *- all values including repeat values are used for this -;
  proc sort data=_linder(drop=visno where=(_fgontv)) out=_labmax;
    by study ptno labnm &labval;
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

  data _laball2;
    set _laball;
    *- add back in the _period variable for proc report ordering -;
    if _period=. then do;
      if _fgprev then _period=1;
      else if _fgontv then _period=2;
      else if _fgpostv then _period=9;
    end;
    _phase=1;
    if _period GE 2 then _phase=2;
  run;


                /**************************
                         Summarize
                 **************************/

  %let wherecls=and _hasbase=1 and _haslast=1;
  %if &showmiss EQ Y %then %let wherecls=;

  *- Summarize and transpose by statistics name and stratification    -;
  *- value using the dpvar=rounding variable to control the number of -;
  *- decimal points shown in the output character variables.          -;
  *- padmiss=yes is used to place non-breaking spaces after a missing -;
  *- value in the character variables to preserve decimal point       -;
  *- alignment when proc report right-aligns them. plugtran=yes is    -;
  *- used to add 0 counts and missing values for report aesthetics.   -;
     
  %unistats(dsin=_laball2(where=((_fgprev or _fgontv) &wherecls and missing(_fgrept))),
  print=no,varlist=&labval,msglevel=X,padmiss=yes,msgs=no,
  trtvar=&stratvar,trtfmt=&stratfmt,dpvar=rounding,trtvallist=&vallist,
  byvars=&trtvar labnm &labunit _phase _period visno cpevent,
  nfmt=5.,stdfmt=5.,minfmt=5.,maxfmt=5.,meanfmt=5.,plugtran=yes,
  descstats=&descstat,dstranstattrt=_transtat,leftstr=yes);



                /**************************
                     Add lab group order
                 **************************/

  *- add in the lab group info for proc report ordering -;
  proc sql noprint;
    create table _transtat2 as (
    select a.*, b.labnmx, b.labgrp, b.labgrpx, b.labnmor,
    case when _period=3 then "  Min value on treatment"
         when _period=4 then "  Max value on treatment"
         when _period=5 then "  &lastlbl"
         else "  "||cpevent
    end length=60 as _vistext
    from _transtat as a
    left join _labgrp as b
    on a.labnm=b.labnm
    ) order by labgrp, labgrpx, labnmor, labnm, labnmx, &labunit;
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
  title&titlepos "&acctype &repno  Descriptive statistics by visit (&valtype), 
stratified by %varlabel(_patinfo,&stratvar) - &popudc";
  title%eval(&titlepos+2) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Treatment analysis: &anallbl";
  title%eval(&titlepos+4) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) #byval(labgrpx): #byval(labnmx) [#byval(&labunit)]";

  *- use a repeated mid-line long hyphen (byte(131)) for the first footnote -;
  footnote1 "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))";
  footnote2 "N* = Number of %lowcase(&patient)s with &misstxt per time-point or visit / summary visit";
  footnote3 "The selected algorithm for repeat values is &repeat..";
  footnote4 "The selected algorithm for multiple values is &multiple..";
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

                /**************************
                        Gap control
                 **************************/

  *- work out what gap to use so blocks are not split across pages -;

  *- The _statkeys_ content is dynamically handled in the proc report call. -;
  *- If it flows onto the following page then _vistext will be shown at the -;
  *- start of the following page because it is defined as an "id" variable. -;

  *- Most columns are 6 wide with a single space inbetween except for the -;
  *- "N" columns which is 4 wide -;
  %let blockw=%eval(%words(&_statkeys_)*7-3);

  *- give an extra column to NMISS since it usually has the label "Missing" -;
  %if %windex(&_statkeys_,NMISS) %then %let blockw=%eval(&blockw+1);

  %let roomleft=%eval(&repwidth-25);
  %let willfit=%eval(&roomleft/&blockw);

  %if &willfit GT %words(&vallist) %then %let willfit=%words(&vallist);

  %let gap=%eval((&roomleft-&willfit*&blockw)/&willfit);

  *- we might end up with a gap of zero and if so we will recalculate -;
  %if &gap EQ 0 %then %do;
    %let willfit=%eval(&willfit-1);
    %let gap=%eval((&roomleft-&willfit*&blockw)/&willfit);
  %end;


                /**************************
                       Produce report
                 **************************/

  *- for normalised values only show if we have a non-missing rounding variable value -;
  %let wherecls=;
  %if &value EQ N %then %let wherecls=(where=(not missing(rounding)));


  proc report missing headline headskip nowd split="@" spacing=1 data=_transtat2&wherecls;  
    by labgrp labgrpx labnmor labnm labnmx &labunit;
    columns ("%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
              &trtvar _phase _period visno _vistext

            /* NOTE: _statkeys_ contains a list of the transposed numeric */
            /* variables but the character variables end in STR. Also the */
            /* values in vallist will precede STR since we transposed by  */
            /* the stratification variable as well.                       */

            %if %vartype(_patinfo,&stratvar) EQ C %then %let putx=putc;
            %else %let putx=putn;

            %do i=1 %to %words(&vallist);
              %let val=%scan(&vallist,&i,%str( ));
              ("%sysfunc(&putx(&val,&_adjfmt_..))" %suffix(&val.STR,&_statkeys_)) 
            %end;
            );  
    define &trtvar / order order=internal noprint;
    define _phase  / order order=internal noprint;
    define _period / order order=internal noprint;
    define visno   / order order=internal noprint;
    define _vistext / id order width=25 "Treatment/" "  Visit" spacing=0;
    %do j=1 %to %words(&vallist);
      %let val=%scan(&vallist,&j,%str( ));
      %do i=1 %to %words(&_statkeys_);
        %let key=%scan(&_statkeys_,&i,%str( ));
        %if &key EQ N %then %let colw=4;
        %else %if &key EQ NMISS %then %let colw=7;
        %else %let colw=6;
        %let key=&key.&val.STR;
        %let spac=;
        %if &i EQ 1 %then %let spac=spacing=&gap;
        define &key / display width=&colw &spac right;
      %end;
    %end;
    compute before &trtvar;
      *- _popfmt_ contains the identity of the -;
      *- format created by the %popfmt call    -;
      line @1 &trtvar &_popfmt_;
    endcompute;
    break after _phase / skip;
  run;  


                /**************************
                      Tidy up and exit
                 **************************/

  *- keep the _linder dataset if debug is set to yes -;
  proc datasets nolist;
    delete _lab _lab2 _lab3 _laball _laball2 _bslval _lastval
           %if &repeat NE FIRST and &repeat NE LAST %then _lab4;
           _labbl _labgrp _lablast _lablast2 _labmax _minmax _labfin
           _patinfo _patinfo2 _popfmt _transtat _transtat2 _unistats
           %if &debug NE Y %then _linder;
           ;
  quit;


  %goto skip;
  %exit: %put &err: (qcdstatstr) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend qcdstatstr;
