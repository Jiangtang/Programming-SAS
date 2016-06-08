/*<pre><b>
/ Program   : qcpcsafp.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 22-Jan-2012
/ Purpose   : To QC the XLAB 2 PCSAFP table
/ SubMacros : %mkformat %popfmt %age %words : %hasvars %match %varlist %nodup
/             %varlen %attrv %vartype
/ Notes     : This macro creates the table of possible clinically significant
/             abnormalities in an identical layout to the XLAB 2 macro using
/             XLAB 2 style datasets. Note that for the GENTRT dataset it
/             assumes the old structure such that the start of the period is
/             assumed to be the start of the analysis period and not the start
/             of screening as needed for XLAB 2.
/
/             There is no concept of REPEAT processing in this macro as all
/             values are potentially used. For last on treatment then if there
/             are multiple values for the last visit then a flagged value will
/             be picked if there is one.
/
/             This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             If you set debug=yes the _linder dataset will be kept which you
/             can then compare with the LINDER dataset from XLAB 2. All values
/             should match but the _linder dataset has less variables. This
/             macro reports from the _linder dataset as does XLAB 2.
/
/             All values count so REPEAT processing is not relevant
/
/             This macro was designed for use within the CARE/Rage environment.
/
/ Limitations:
/
/             CS processing has not yet been implemented for age ranges as 
/             no examples for this yet exist and it is unclear what form they
/             will take.
/
/ Usage     : %qcpcsafp(inlab=bilab2,inpopu=popu,popu=TS,instds=labstds,
/             intrt=gentrt,analno=3,inpatd=patd);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             Input BILAB2 style dataset
/ instds            Lab standards dataset (no modifiers)
/ intrt             Input treatment dataset
/ inpatd            Input patient dataset that must contain the variables 
/                   STUDY, PTNO, SEX and BTHDT.
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

%put MACRO CALLED: qcpcsafp v1.0;


%macro qcpcsafp(inlab=,
               instds=,
                intrt=,
               inpatd=,
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

  %local i err errflag repwidth studies studiesx titlepos repno popudc anallbl spat;

  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&msglevel) %then %let msglevel=X;
  %let msglevel=%upcase(%substr(&msglevel,1,1));
  %if "&msglevel" NE "N" and "&msglevel" NE "I" %then %let msglevel=X;


             /****************************
                  Save and set options
              ****************************/

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
    %put &err: (qcpcsafp) No lab dataset specified to inlab=;
  %end;

  %if not %length(&instds) %then %do;
    %let errflag=1;
    %put &err: (qcpcsafp) No lab standards dataset specified to instds=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (qcpcsafp) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpatd) %then %do;
    %let errflag=1;
    %put &err: (qcpcsafp) No patient dataset specified to inpatd=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (qcpcsafp) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (qcpcsafp) No population code specified to popu=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (qcpcsafp) No analno specified to analno=;
  %end;

  %if &errflag %then %goto exit;

  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&patient) %then %let patient=patient;
  %let patient=%lowcase(&patient);
  %if "&patient" EQ "healthy" %then %do;
    %let patient=healthy volunteer;
    %let spat=hel;
  %end;
  %else %if "&patient" EQ "patient" %then %let spat=pts;
  %else %let spat=%sysfunc(subpad(%sysfunc(compress(&patient,aeiou)),1,3));

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

  proc sql noprint;

    create table _patinfo as (
      select pop.study, pop.ptno, pop.popu, pop.popudc, pat.sex, pat.bthdt, pat.age,
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

      /*--- patient details ---*/
      left join &inpatd as pat
      on pop.study=pat.study and pop.ptno=pat.ptno

    ) order by study, ptno;

    select distinct(study)   into: studies separated by ", " from _patinfo;
    select distinct(popudc)  into: popudc  separated by " " from _patinfo;
    select distinct(anallbl) into: anallbl separated by " " from _patinfo;

    *- clinical significance rules -;
    create table _cs as (
      select labnm, sex as sexcs, agemin, agemax, upcase(flag) as _fgcs, var1, comp1, val1
      from &instds(where=(type='CS' and version=2))
    ) order by labnm;

    *- lab grouping variables -;
    create table _labgrp as (
      select labnm, labnmx, labgrp, labgrpx, labnmor from &instds(where=(type='LG'))
    );


    *- lab values -;
    create table _lab as (
      select a.study, a.ptno, a.labnm, a.lab, a.labun, a.labstd, a.labstdu,
      a.visno, a.cpevent, a.subevno, a.llc, a.ulc,
      dhms(labdt,0,0,labtm) format=datetime19. label="lab datetime" as labdttm
      from &inlab as a
    ) order by study, ptno, labnm, visno, subevno, labdttm;

  quit;

  *- replace last comma in studies list with an "and" -;
  %let studies=%comma2andmac(&studies);


                /**********************
                     Create formats
                 **********************/

  proc format;
    invalue $sexcs
      "M"="1"
      "F"="2"
      ;
    value csord
      1="Low"
      2="High"
      ;
  run;

  *- Create a format based on the coded and decoded treatment arm values -;
  *- for use in building the following format showing population totals. -;
  %mkformat(_patinfo,&trtvar,&trtdc,$atrfmt);

  *-Create an indented format with the population total shown -;
  %popfmt(dsin=_patinfo,trtvar=&trtvar,trtfmt=$atrfmt.,uniqueid=study ptno,
          split=%str( ),msgs=no,indent=4,msglevel=X);


                /************************
                      Extend patinfo
                 ************************/

  data _patinfo2;
    set _patinfo;
    *- combine post-treatment and post-study start and stop -;
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


        /************************************************
           Generate Clinical Significance (CS) SAS code
         ************************************************/

  *- set up a temporary file for the CS code -;
  filename _cscode TEMP;


  *- write the CS code to the temporary file -;
  data _null_;
    length str $ 256;
    file _cscode;
    set _cs;
    by labnm;
    if sexcs="B" then
    str='ELSE IF labnm="'||trim(left(labnm))||'" AND labstd '||left(trim(comp1))||
        " "||trim(left(val1))||' THEN _fgcs="'||trim(left(_fgcs))||'";';
    else
    str='ELSE IF labnm="'||trim(left(labnm))||'" AND sex='||input(sexcs,$sexcs.)||' AND labstd '||
        left(trim(comp1))||' '||trim(left(val1))||' THEN _fgcs="'||trim(left(_fgcs))||'";';
    put str;
    if last.labnm then do;
      str='ELSE IF labnm="'||trim(left(labnm))||'" THEN _fgcs="N";';
      put str;
    end;
  run;


  *- get a unique list of labnm and flags -;
  proc sort nodupkey data=_cs(keep=labnm _fgcs) out=_cs2;
    by labnm _fgcs;
  run;


  *- combine the flags into combflag;
  data _cs3;
    length combflag $ 2;
    set _cs2;
    by labnm;
    if last.labnm then do;
      if first.labnm then combflag=_fgcs;
      else combflag="HL";
      output;
    end;
    drop _fgcs;
  run;


                /********************
                     Add lab flags
                 ********************/

  data _lab2;
    length _fgcs $ 1 _fgprev _fgontv _fgpostv 3;
    merge _patinfo2(in=_a) _lab(in=_b);
    by study ptno;
    if _a and _b;
    currage=%age(bthdt,datepart(labdttm));
    _relday=datepart(labdttm)-datepart(ontdtst);
    if _relday >=0 then _relday=_relday+1;
    if predtst<labdttm<=ontdtst then _fgprev=1;
    else if ontdtst<labdttm<=ontdtsp then _fgontv=1;
    else if cmbdtst<labdttm<=cmbdtsp then _fgpostv=1;
    IF missing(labstd) THEN _fgcs=" ";
    %inc _cscode / nosource2;
    drop predtst ontdtst ontdtsp posdtst posdtsp
         pstdtst pstdtsp cmbdtst cmbdtsp;
    label _fgprev="Pre-treatment value flag"
          _fgontv="On-treatment value flag"
          _fgpostv="Post-treatment value flag"
          _fgcs="Clinically Significant Flag"
          _relday="Trial day"
          ;
    format _fgprev _fgontv _fgpostv 1. age 5.1 _relday 5.;
  run;

  filename _cscode clear;


                /************************
                  Create LINDER dataset
                 ************************/

  *- This extra data step is required to implement the  -;
  *- setting of variables to missing because it can not -;
  *- be done when merging with _patinfo2.               -;
  data _linder;
    set _lab2;
    *- A number of variables need to be set to missing -;
    *- if the timepoints fall outside the range.       -;
    if not (_fgprev or _fgontv or _fgpostv) then do;
      &trtvar=" ";&trtdc=" ";
    end;
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
                   Add a sorting variable
                 **************************/

  *- add _csord -;
  data _linder2;
    set _linder;
    if _fgcs in ("H", "L") then _csord=1;
    else _csord=0;
  run;


            /***************************************
               Count patients with CS on treatment
             ***************************************/

  *- CS values on treatment sorted by datetime -;
  proc sort data=_linder2(where=(_fgontv=1 and _fgcs in ("H" "L")))
             out=_csfirst;
    by study ptno labnm labdttm;
  run;


  *- pick the first CS value on treatment so we get onset days -;
  data _csfirst;
    set _csfirst;
    by study ptno labnm;
    if first.labnm;
  run;


  *- Count them and calculate median days to onset.    -;
  *- "ncs" will be the demoninator for the percentages -;
  proc summary missing nway data=_csfirst;
    class labnm &trtvar;
    output out=_csfirstsum(drop=_type_ rename=(_freq_=ncs)) median(_relday)=meddays;
  run;


       /*************************************
           On-treatment last visit values
        *************************************/

  *- sort so flagged values are last within a visit -;
  proc sort data=_linder2(where=(_fgontv)) out=_lastvis;
    by study ptno labnm visno _csord labdttm;
  run;


  *- Just keep the last within each visit. -;
  *- We will be using this dataset a lot.  -;
  data _lastvis2;
    set _lastvis;
    by study ptno labnm visno;
    if last.visno;
  run;


       /***************************************
          Count patients who always normalise
        ***************************************/

  *- Using those last visit values then check if  -;
  *- they always normalise at the following visit -;
  *- and stay normal.                             -;
  data _return;
    retain _flg _ret 0;
    set _lastvis2;
    by study ptno labnm;
    if first.labnm then do;
      _flg=0; *- no CS flagged -;
      _ret=0; *- assume not a normaliser -;
    end;
    if _fgcs in ("H", "L") and _flg=0 then do;
      _flg=1; *- CS flagged -;
      _ret=0; *- assume they will not normalise -;
    end;
    else if _fgcs in ("H", "L") and _flg=1 then do;
      _flg=2; *- two or more CS -;
      _ret=0; *- not a normaliser and will stay this way with_flg=2 -;
    end;
    *- first onset only return next visit and stayed normal after that -;
    else if _fgcs not in ("H", "L") and _flg=1 then _ret=1;
  /**  Use the following instead of the above line if repeat
      returns such as HNHN will be regarded as a returner 
    else if _fgcs not in ("H", "L") and _flg=1 then do;
      _ret=1; *- normalised -;
      _flg=0; *- unflag the CS -;
    end;
  **/
  run;


  *- keep the last obs per lab group for the last ratained _ret value -;
  data _return2(keep=study ptno labnm &trtvar _ret);
    set _return;
    by study ptno labnm;
    if last.labnm;
  run;


  *- sum of those who always normalised at the following visit -;
  proc summary nway data=_return2(where=(_ret=1));
    class labnm &trtvar;
    output out=_retsum(drop=_type_ rename=(_freq_=nreturn));
  run;


       /****************************************
           Count CS at last value on treatment
        ****************************************/  

  *- the last one on treatment of the last visit values -;
  data _cslast;
    set _lastvis2;
    by study ptno labnm;
    if last.labnm;
  run;


  *- keep the ones that are flagged -;
  data _cslast2;
    set _cslast;
    if _fgcs in ("H" "L");
  run;


  *- count them -;
  proc summary missing nway data=_cslast2;
    class labnm &trtvar;
    output out=_cslastsum(drop=_type_ rename=(_freq_=ncslast));
  run;


       /*************************************
            Count CS for multiple visits
        *************************************/  

  *- use the last on visit dataset for this -;
  proc sort NODUPKEY data=_lastvis2(keep=study ptno labnm visno _fgcs &trtvar
                                   where=(_fgcs in ("H", "L")))
                      out=_csmult(drop=_fgcs);
    by study ptno labnm visno;
  run;


  *- pick those who have a CS at more than one visit -;
  data _csmult2;
    set _csmult;
    by study ptno labnm visno;
    if first.labnm and not last.labnm;
  run;


  *- count them -;
  proc summary missing nway data=_csmult2;
    class labnm &trtvar;
    output out=_csmultsum(drop=_type_ rename=(_freq_=ncsmult));
  run;


         /****************************
            Count those on treatment
          ****************************/

  *- all patients with on-treatment values -;
  proc sort NODUPKEY data=_linder(keep=_fgontv study ptno labnm &trtvar &trtdc
                                 where=(_fgontv=1))
                      out=_labn;
    by study ptno labnm &trtvar &trtdc;
  run;


  *- count them -;
  proc summary nway missing data=_labn;
    class labnm &trtvar;
    output out=_labntot(drop=_type_ rename=(_freq_=_N));
  run;


      /*****************************************
            Combine counts into a dataset
       *****************************************/

  data _cscomb;
    merge _labntot _csfirstsum _retsum _csmultsum _cslastsum;
    by labnm &trtvar;
  run;


           /***************************
               Calculate Percentages
            ***************************/

  *- "ncs" (patients with CS on treatment) is the denominator -;
  data _cscomb2;
    length strncs strnret strnmult strnlast $ 13 ;
    set _cscomb;
    if ncs LE 0 then strncs="   0";
    else strncs=put(ncs,4.)||" ("||put(100*ncs/ncs,5.1)||")";
    if nreturn LE 0 then strnret="   0";
    else strnret=put(nreturn,4.)||" ("||put(100*nreturn/ncs,5.1)||")";
    if ncsmult LE 0 then strnmult="   0";
    else strnmult=put(ncsmult,4.)||" ("||put(100*ncsmult/ncs,5.1)||")";
    if ncslast lE 0 then strnlast="   0";
    else strnlast=put(ncslast,4.)||" ("||put(100*ncslast/ncs,5.1)||")";
  run;


            /***************************
                Merge with CS labnm
             ***************************/

  *- sort ready for a merge with CS flags -;
  proc sort data=_cscomb2;
    by labnm;
  run;


  *- Merge with CS flags and drop labnm  _;
  *- where there is no matching CS flag. -;
  data _cscomb3;
    merge _cs3(in=_a) _cscomb2(in=_b);
    by labnm;
    if _a and _b;
  run;


          /*******************************
               Merge with lab groupings
           *******************************/

  *- merge with lab groupings for report ordering -;
  proc sql noprint;
    create table _cscomb4 as (
      select a.*, labgrp, labgrpx, labnmor, labnmx
      from _cscomb3 as a
      left join _labgrp as b
      on a.labnm=b.labnm
    ) order by labgrp, labgrpx, labnmor, labnm;
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
  title&titlepos "&acctype &repno  Frequency of &patient.s [N(%)] with possible clinically significant 
abnormalities at last value on treatment and median time to";
  title%eval(&titlepos+1) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) possible clinically significant abnormalities - &popudc";
  title%eval(&titlepos+3) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Treatment analysis: &anallbl";
  title%eval(&titlepos+5) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Functional Group: #byval(labgrpx)";

  *- use a repeated mid-line long hyphen (byte(131)) for the first footnote -;
  footnote1 "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))";
  footnote2 "* All &patient.s at risk including &patient.s whose baseline value was abnormal and with non-missing lab values";
  footnote3 "Percentages are based on number of &patient.s with possible clinically significant abnormalities (PCSA) on treatment.";
  footnote4 "The &patient.s who have a missing value at baseline are counted and are considered to be normal at baseline.";
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
                       Produce report
                 **************************/

  proc report missing headline headskip nowd split="@" data=_cscomb4 spacing=2;  
    by labgrp labgrpx;
    columns ( "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
              labnmor labnmx labnm &trtvar _N strncs meddays strnret strnmult strnlast); 
    define labnmor / order noprint; 
    define labnmx / order noprint;  
    define labnm / order noprint;
    /* _popfmt_ contains the identity of the format created by the %popfmt call */
    define &trtvar / id order order=internal "Parameter/" "    Treatment"
                     format=&_popfmt_ width=24 spacing=0;
    define _N / display width=4 "N*";
    define strncs   / display "Number (%) &spat" "with PCSA" width=16;
    define meddays  / display "Median time to" "first occ. of" "PCSA on" "treatment [days]" format=9.1 width=16 left;
    define strnret  / display "Number (%) &spat" "with PCSA who" "normalised at"   "the following" "visits" width=16;
    define strnmult / display "Number (%) &spat" "with PCSA at"  "multiple visits"  width=16;
    define strnlast / display "Number (%) &spat" "with PCSA at"  "last value on"   "treatment" width=16;
    compute before labnm;
      line @1 labnmx $char60.;
    endcompute;
    break after labnm / skip;
  run;  


             /***************************
                   Tidy up and exit
              ***************************/

  *- keep the _linder dataset if debug is set to yes -;
  proc datasets nolist;
    delete _cs _cs2 _cs3 _cscomb _cscomb2 _cscomb3 _cscomb4 _csfirst _csfirstsum
           _cslast _cslast2 _cslastsum _csmult _csmult2 _csmultsum
            _lab _lab2 _labgrp _labn _labntot
           _lastvis _lastvis2 _linder2 _patinfo _patinfo2 _popfmt 
           _retsum _return _return2
    %if &debug NE Y %then _linder;
    ;
  quit;


  %goto skip;
  %exit: %put &err: (qcpcsafp) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend qcpcsafp;
