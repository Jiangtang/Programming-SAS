/*<pre><b>
/ Program   : qcpcsaf.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 22-Jan-2012
/ Purpose   : To QC the XLAB 2 PCSAF table
/ SubMacros : %mkformat %popfmt %age : %hasvars %match %varlist %nodup %varlen
/             %attrv %vartype
/ Notes     : This macro creates the table of possible clinically significant
/             abnormalities in an identical layout to the XLAB 2 macro using
/             XLAB 2 style datasets. Note that for the GENTRT dataset it
/             assumes the old structure such that the start of the period is
/             assumed to be the start of the analysis period and not the start
/             of screening as needed for XLAB 2.
/
/             This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             Pre-treatment values for dates earlier than the start of analno=6
/             will be ignored.
/
/             Baseline is defined to be the last value before the start of the
/             period specified by the analno= number supplied.
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
/ Usage     : %qcpcsaf(inlab=bilab2,inpopu=popu,popu=TS,instds=labstds,
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
/ csbsl=no          By default, do not include patients with PCSA at baseline
/ showpats=yes      By default, list the patients in the High and Low categories
/ trtvar=PSORT      Treatment variable (default PSORT)
/ trtdc=PTPATT      Treatment decode variable (default PTPATT)
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

%put MACRO CALLED: qcpcsaf v1.0;


%macro qcpcsaf(inlab=,
              instds=,
               intrt=,
              inpatd=,
              inpopu=,
                popu=TS,
              analno=3,
               csbsl=no,
            showpats=yes,
              trtvar=ATRCD,
               trtdc=ATRSLBL,
             patient=Patient,
            trialsft=yes,
            msglevel=X,
               debug=no
               );

  %local i err errflag repwidth studies studiesx titlepos repno popudc anallbl uvars;

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
    %put &err: (qcpcsaf) No lab dataset specified to inlab=;
  %end;

  %if not %length(&instds) %then %do;
    %let errflag=1;
    %put &err: (qcpcsaf) No lab standards dataset specified to instds=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (qcpcsaf) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpatd) %then %do;
    %let errflag=1;
    %put &err: (qcpcsaf) No patient dataset specified to inpatd=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (qcpcsaf) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (qcpcsaf) No population code specified to popu=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (qcpcsaf) No analno specified to analno=;
  %end;

  %if &errflag %then %goto exit;

  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&csbsl) %then %let csbsl=no;
  %let csbsl=%upcase(%substr(&csbsl,1,1));

  %if not %length(&showpats) %then %let showpats=yes;
  %let showpats=%upcase(%substr(&showpats,1,1));

  %if not %length(&trialsft) %then %let trialsft=yes;
  %let trialsft=%upcase(%substr(&trialsft,1,1));

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));

  %let uvars=%words(study ptno);

  %macro onuvars(one,two);
    %local i;
    %do i=1 %to &uvars;
      %if &i EQ 1 %then on;
      %else and;
      &one..%scan(study ptno,&i,%str( ))=&two..%scan(study ptno,&i,%str( ))
    %end;
  %mend onuvars;

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
      select patd.study, patd.ptno, pop.ptproj, pop.popu, pop.popudc, pat.sex, pat.bthdt, pat.age,
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
      on pop.ptproj=trt.ptproj

      /*--- pre treatment ---*/
      left join &intrt(where=(analno=6)) as pre
      on pop.ptproj=pre.ptproj

      /*--- post treatment ---*/
      left join &intrt(where=(analno=1 and atrcd="90000003")) as pos
      on pop.ptproj=pos.ptproj

      /*--- post study ---*/
      left join &intrt(where=(analno=1 and atrcd="90000011")) as pst
      on pop.ptproj=pst.ptproj

      /*--- patient details ---*/
      left join &inpatd as pat
      on pop.ptproj=pat.ptproj

    ) order by study, ptno;

    select distinct(study)   into: studies separated by ", " from _patinfo;
    select distinct(popudc)  into: popudc  separated by " " from _patinfo;
    select distinct(anallbl) into: anallbl separated by " " from _patinfo;

    *- clinical significance rules -;
    create table _cs as (
      select study, labnm, sex as sexcs, agemin, agemax, upcase(flag) as csflag, var1, comp1, val1
      from &instds(where=(type='CS' and version=2))
    ) order by study, labnm;

    *- lab grouping variables -;
    create table _labgrp as (
      select labnm, labnmx, labgrp, labgrpx, labnmor from &instds(where=(type='LG'))
    );


    *- lab values -;
    create table _lab as (
      select a.study, a.ptno, a.ptproj, a.labnm, a.lab, a.labun, a.labstd, a.labstdu,
      a.visno, a.cpevent, a.subevno, a.llc, a.ulc,
      dhms(labdt,0,0,labtm) format=datetime19. label="lab datetime" as labdttm
      from &inlab as a
     ) order by study, ptno, labnm, visno, subevno, labdttm;

  quit;

  *- replace last comma in studies list with an "and" -;
  %let studies=%comma2andmac(&studies);

  proc sort nodupkey data=_labgrp;
    by labnm;
  run;
    


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
    by study labnm;
    if first.study then do;
      str='IF study="'||trim(study)||'" THEN DO;';
      put str;
    end;
    if first.labnm then do;
      str='IF labnm="'||trim(labnm)||'" THEN DO;';
      put str;
      str='_fgcs="N";';
      put str;
    end;

    if sexcs="B" then
    str='IF labstd '||left(trim(comp1))||
        " "||trim(left(val1))||' THEN _fgcs="'||trim(left(csflag))||'";';
    else
    str='IF sex='||input(sexcs,$sexcs.)||' AND labstd '||
        left(trim(comp1))||' '||trim(left(val1))||' THEN _fgcs="'||trim(left(csflag))||'";';
    put str;
    if last.labnm then do;
      str='END;';
      put str;
    end;
    if last.study then do;
      str='END;';
      put str;
    end;
  run;


  *- get a unique list of labnm and flags -;
  proc sort nodupkey data=_cs(keep=labnm csflag) out=_cs2;
    by labnm csflag;
  run;


  *- combine the flags into combflag;
  data _cs3;
    length combflag $ 2;
    set _cs2;
    by labnm;
    if last.labnm then do;
      if first.labnm then combflag=csflag;
      else combflag="HL";
      output;
    end;
    drop csflag;
  run;


                /********************
                     Add lab flags
                 ********************/

  data _lab2;
    length _fgcs $ 1 _fgprev _fgontv _fgpostv 3;
    merge _patinfo2(in=_a) _lab(in=_b);
    by study ptno;
    if _a and _b;
    *- recalculate age at lab sample date -;
    currage=%age(bthdt,labdt);
    if predtst<labdttm<=ontdtst then _fgprev=1;
    else if ontdtst<labdttm<=ontdtsp then _fgontv=1;
    else if cmbdtst<labdttm<=cmbdtsp then _fgpostv=1;
    *- claculate PCSA flag -;
    IF missing(labstd) THEN _fgcs=" ";
    %inc _cscode / nosource2;
    drop predtst ontdtst ontdtsp posdtst posdtsp
         pstdtst pstdtsp cmbdtst cmbdtsp;
    label _fgprev="Pre-treatment value flag"
          _fgontv="On-treatment value flag"
          _fgpostv="Post-treatment value flag"
          _fgcs="Clinically Significant Flag"
          ;
    format _fgprev _fgontv _fgpostv 1. age 5.1;
  run;

  filename _cscode clear;


                /*************************
                   Create LINDER dataset
                 *************************/

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


                   /*****************
                       Baseline CS
                    *****************/

  *- Sometimes this value is not in the correct visno order so it -;
  *- needs to be sorted in labdttm order. All values are used.    -;
  proc sort data=_linder(keep=study ptno labnm labdttm _fgprev _fgcs &trtvar &trtdc
                      where=(_fgprev=1)) out=_bslcs(drop=labdttm);
    by study ptno labnm &trtvar &trtdc labdttm;
  run;

  *- keep only the last and only flagged values -;
  data _bslcs;
    set _bslcs;
    by study ptno labnm;
    if last.labnm;
    if _fgcs in ("H","L");
    drop _fgcs;
  run;

                /**********************
                     On-treatment CS
                 **********************/

  *- all on-treatment values flagged as CS dropping any duplicates -;
  proc sort data=_linder(keep=study ptno labnm _fgontv _fgcs &trtvar &trtdc
                      where=(_fgontv=1 and _fgcs in ("H","L"))) 
                      out=_ontcs NODUPKEY;
    by study ptno labnm &trtvar &trtdc _fgcs;
  run;


                /***********************
                   Exclude baseline CS
                 ***********************/

  *- drop any on-treatment CS if they were CS at baseline -;
  data _ontcs2;
    merge _bslcs(in=_a) _ontcs(in=_b);
    by study ptno labnm &trtvar &trtdc;
    %if "&csbsl" EQ "Y" %then %do;
      if _b;
    %end;
    %else %do;
      if _b and not _a;
    %end;
    *- we want Low to go before High so set up _csord for ordering -;
    if _fgcs="L" then _csord=1;
    else if _fgcs="H" then _csord=2;
    else _csord=99;
  run;


  *- sort ready for the next step -;
  proc sort data=_ontcs2;
    by &trtvar &trtdc labnm _csord _fgcs study ptno;
  run;


              /***************************************
                 Generate totals and patient strings
               ***************************************/

  %let repwidth=%sysfunc(getoption(ls));

  *- reporting dataset 1 -;
  data _ontrep1;
    %if "&showpats" NE "N" %then %do;
      length patslo patshi pats $ 16000;
      retain patslo patshi " " ;
    %end;
    retain totlpats tothpats 0;
    set _ontcs2;
    by &trtvar &trtdc labnm _csord;
    if first.labnm then do;
      totlpats=0;
      tothpats=0;
      patslo="";
      patshi="";
    end;
    if _fgcs="H" then tothpats=tothpats+1;
    else if _fgcs="L" then totlpats=totlpats+1;
    %if "&showpats" NE "N" %then %do;
      if first._csord then do;
        if _csord=1 then patslo='L: '||trim(left(put(ptno,6.)));
        else if _csord=2 then patshi='H: '||trim(left(put(ptno,6.)));
      end;
      else if _csord=1 then patslo=trim(patslo)||', '||trim(left(put(ptno,6.)));
      else patshi=trim(patshi)||', '||trim(left(put(ptno,6.)));
    %end;
    if last.labnm then do;
      %splitvar(patslo,width=%eval(&repwidth-65),biglen=16000);
      %splitvar(patshi,width=%eval(&repwidth-65),biglen=16000);
      if patslo=" " then pats=patshi;
      else if patshi=" " then pats=patslo;
      else if index(patslo,"@") then pats=trim(patslo)||patshi;
      else pats=trim(patslo)||"@"||patshi;
      output;
    end;
    drop study ptno patslo patshi;
  run;


              /*******************************
                   Calculate patient count
               *******************************/

  *- all on-treatment patients -;
  proc summary nway missing data=_linder(keep=study ptno labnm &trtvar &trtdc _fgontv
                               where=(_fgontv=1));
    class study ptno labnm &trtvar &trtdc;
    output out=_ont(drop=_type_ _freq_);
  run;


  *- all on-treatment patients not CS at baseline -;
  data _labn;
    merge _bslcs(in=_a) _ont(in=_b);
    by study ptno labnm &trtvar &trtdc;
    if _b and not _a;
  run;


  *- count them -;
  proc summary nway missing data=_labn;
    class &trtvar &trtdc labnm;
    output out=_labntot(drop=_type_ rename=(_freq_=_N));
  run;


              /***************************
                  Calculate Percentages
               ***************************/

  *- reporting dataset 2 -;
  data _ontrep2;
    length strl strh $ 13 ;
    merge _ontrep1 _labntot;
    by &trtvar &trtdc labnm;
    if totlpats LE 0 then strl=put(0,4.);
    else strl=put(totlpats,4.)||" ("||put(100*totlpats/_N,5.1)||")";
    if tothpats LE 0 then strh=put(0,4.);
    else strh=put(tothpats,4.)||" ("||put(100*tothpats/_N,5.1)||")";
  run;


  *- sort ready for a merge with CS flags -;
  proc sort data=_ontrep2;
    by labnm;
  run;


  *- Reporting dataset 3 -;
  *- Merge with CS flags and drop labnm or   _;
  *- string where there is no matching flag. -;
  data _ontrep3;
    merge _cs3(in=_a) _ontrep2(in=_b);
    by labnm;
    if _a and _b;
    if not index(combflag,"H") then strh=" ";
    if not index(combflag,"L") then strl=" ";
  run;


  *- merge with lab groupings to create final reporting dataset 4 -;
  proc sql noprint;
    create table _ontrep4 as (
      select a.*, labgrp, labgrpx, labnmor, labnmx
      from _ontrep3 as a
      left join _labgrp as b
      on a.labnm=b.labnm
    ) order by labgrp, labgrpx, labnmor, labnm;
  quit;


                /**************************
                    Titles and Footnotes
                 **************************/

  *- make the report top line and the first footnote line a full page width -;

  *- pick up the CARE/Rage report number, title and footnote -;
  %let repno=&mrds;
  %let titlepos=1;
  %if "%substr(&mrds,1,4)" EQ "Erro" %then %do;
    %let repno=X.X.X;
    %let titlepos=4;
    title1 &title;
  %end;

  *- use "by" variable values in the titles -;
  title&titlepos "&acctype &repno  Frequency of %lowcase(&patient)s [N(%)] with possible clinically significant 
abnormalities - &popudc";
  title%eval(&titlepos+2) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Treatment analysis: &anallbl";
  title%eval(&titlepos+4) "%sysfunc(repeat(%str( ),%length(&acctype &repno))) Functional Group: #byval(labgrpx)";

  *- use a repeated mid-line long hyphen (byte(131)) for the first footnote -;
  footnote1 "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))";
  footnote2 "* = &patient.s with no possible clinically significant abnormality at baseline";
  footnote3 "The %lowcase(&patient)(s) who have low and high value at the same time will be counted twice.";
  footnote4 "Empty columns or lines indicate that there are no corresponding rules defined.";
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

  proc report missing headline headskip nowd split="@" data=_ontrep4 spacing=2;  
    by labgrp labgrpx;
    columns ( "%sysfunc(repeat(%sysfunc(byte(131)),%eval(&repwidth-1)))"
              labnmor labnmx labnm &trtvar _N strl strh 
              %if "&showpats" NE "N" %then %do;
                pats
              %end;
            ); 
    define labnmor / order noprint; 
    define labnmx / order noprint;  
    define labnm / order noprint;
    /* _popfmt_ contains the identity of the format created by the %popfmt call */
    define &trtvar / id order order=internal "Parameter/" "    Treatment"
                     format=&_popfmt_ width=27 spacing=0;
    define _N / order width=4 "N*";
    define strl / display "   Low" width=13; 
    define strh / display "   High" width=13;
    %if "&showpats" NE "N" %then %do;
      define pats / display flow "&patient-No" width=%eval(&repwidth-65);
    %end;
    compute before labnm;
      line @1 labnmx $char60.;
    endcompute;
    break after labnm / skip;
  run;


                /**************************
                      Tidy up and exit
                 **************************/
/****
  *- keep the _linder dataset if debug is set to yes -;
  proc datasets nolist;
    delete _cs _cs2 _cs3 _labgrp _bslcs _bslcs2
           _lab _lab2 _labn _labntot _ont _ontcs _ontcs2
           _ontrep1 _ontrep2 _ontrep3 _ontrep4
           _patinfo _patinfo2 _popfmt
    %if &debug NE Y %then _linder;
    ;
  quit;
***/

  %goto skip;
  %exit: %put &err: (qcpcsaf) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend qcpcsaf;
