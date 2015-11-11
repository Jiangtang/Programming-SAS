/*<pre><b>
/ Program   : labncfb.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 05-Dec-2011
/ Purpose   : To produce a table of lab (normalized) change from baseline
/ SubMacros : %unistats %popfmt %words %mkformat
/ Notes     : This is an example macro that is meant to serve as an illustration
/             of how %unistats is called within a lab reporting macro and the
/             output dataset displayed using proc report. This macro produces a
/             LAB table of (optionally Normalized) Change From Baseline.
/
/             Normalization is done by adjusting the lab value based on its 
/             reference range converted to a standardized reference range. You
/             must supply a dataset to the innorm= parameter for normalization
/             values to be calculated.
/
/             Baseline is defined to be the last value before the start of the
/             period specified by the analno= number supplied. Only the first
/             value within the same "visno" is kept. If you have different
/             requirements then you will need to change the macro logic which
/             should be clear in the code.
/
/             You will need to change this macro to get it to work on your 
/             standard datasets and variable naming conventions. This macro is
/             only meant to be an illustration of how the %unistats macro can be
/             used with lab data.
/
/             There are two styles of reports: style=1 has the timepoints as the
/             across variable; style=2 has the treatment arm as the across
/             variable. If you set style= to null then both reports will be
/             produced.
/
/             If you set debug=yes then the intermediate datasets will be kept
/             which you can then use to debug the logic.
/
/ Usage     : options nocenter nobyline;
/             title "Functional Group: #byval(labgrpx)";
/
/             %labncfb(inlab=lab,inpopu=popu,popu=TS,intrt=gentrt,analno=3,
/             descstats=N Min Mean SD Max,innorm=labref(where=(type="RR")),
/             ingrp=labref(where=(type="LG")));
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlab             Input lab dataset
/ labval            Lab value variable
/ labunit           Lab unit variable
/ repeat=first      By default, use the first non-missing value within visit.
/                   Valid values are first, last and all.
/ rangelo           Lab range low variable
/ rangehi           Lab range high variable
/ innorm            Input normalization dataset (should only have one entry per
/                   lab unit). Normalization will only be done if this dataset
/                   is specified.
/ normlo            Normalized range low variable
/ normhi            Normalized range high variable
/ intrt             Input treatment dataset
/ inpopu            Input population dataset
/ popu              Population identifier string
/ analno            Analysis number in intrt dataset to use
/ ingrp             Dataset that contains the lab grouping variables LABGRP,
/                   LABGRPX and LABNMOR
/ descstats=N Min Mean SD Max      Descriptive statistics labels
/ style=1           Report style. 1=timepoint across, 2=treatment across,
/                   null=show both
/ trtvar            Treatment variable
/ trtdc             Treatment decode variable
/ labparm           Lab parameter variable
/ labparmdc         Lab parameter decode variable
/ spacing=2         Spacing between descriptive statistics columns
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  05Dec11         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: labncfb v1.0;


%macro labncfb(inlab=,
              labval=labstd,
             labunit=labstdu,
              repeat=first,
             rangelo=llc,
             rangehi=ulc,
              innorm=,
              normlo=lln,
              normhi=uln,
               intrt=,
              inpopu=,
                popu=,
              analno=,
               ingrp=,
           descstats=N Min Mean SD Max,
               style=1,
              trtvar=atrsort,
               trtdc=atrlbl,
             labparm=labnm,
           labparmdc=labnmx,
             spacing=2,
               debug=no
               );

  %local i key spac err errflag style1 style2 workds;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&inlab) %then %do;
    %let errflag=1;
    %put &err: (labncfb) No lab dataset specified to inlab=;
  %end;

  %if not %length(&intrt) %then %do;
    %let errflag=1;
    %put &err: (labncfb) No gentrt dataset specified to intrt=;
  %end;

  %if not %length(&inpopu) %then %do;
    %let errflag=1;
    %put &err: (labncfb) No population dataset specified to inpopu=;
  %end;

  %if not %length(&popu) %then %do;
    %let errflag=1;
    %put &err: (labncfb) No population code specified to popu=;
  %end;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (labncfb) No analno specified to analno=;
  %end;

  %if not %length(&descstats) %then %do;
    %let errflag=1;
    %put &err: (labncfb) No descriptive statistics labels specified to descstats=;
  %end;

  %if &errflag %then %goto exit;

  %if not %length(&style) %then %do;
    %let style1=Y;
    %let style2=Y;
  %end;
  %else %if &style EQ 1 %then %let style1=Y;
  %else %if &style EQ 2 %then %let style2=Y;

  %let popu=%upcase(%sysfunc(dequote(&popu)));

  %if not %length(&repeat) %then %let repeat=first;
  %let repeat=%upcase(&repeat);

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));


  *- create needed formats -;
  proc format;
    value tpfmt
    1="_Baseline_"
    2="_Last Value on Treatment_"
    3="_Difference from Baseline_"
    ;
    value tpind
    1="  Baseline"
    2="  Last Value on Treatment"
    3="  Difference from Baseline"
    ;
  run;


  *- extract the data -;
  proc sql noprint;
    *- lab grouping variables -;
    create table _labgrp as (
      select labnm, labgrp, labgrpx, labnmor from &ingrp
    );

    *- patients in the population -;
    create table _pop as (
      select study, ptno from &inpopu(where=(popu="&popu" and popuny=1))
    );

    *- treatment arm -;
    create table _tmtarm as (
      select study, ptno, &trtvar, &trtdc 
      from &intrt(where=(analno=&analno))
    );

    *- patients and their treatment arm -;
    create table _poptmt as (
      select a.study, a.ptno, &trtvar, &trtdc 
      from _pop as a
      left join _tmtarm as b
      on a.study=b.study and a.ptno=b.ptno
    );

    *- on treatment start and stop -;
    create table _ontrt as (
      select a.study, a.ptno, atrstdt, atrsttm, atrspdt, atrsptm, 
      &trtvar, &trtdc
      from &intrt(where=(analno=&analno)) as a
      inner join _pop as b
      on a.study=b.study and a.ptno=b.ptno
    );

    sasfile _ontrt load;

    *- baseline (actually pre-treatment) lab values -;
    create table _labbl as (
      select a.study, a.ptno, &labparm, &labparmdc, 
      &labval, &labunit, &rangelo, &rangehi, labdt, labtm, visno, subevno
      from &inlab as a
      inner join _ontrt as b
      on a.study=b.study and a.ptno=b.ptno and a.usable=1
         and not missing(&labval)
         and (labdt<atrstdt or (labdt=atrstdt and labtm<=atrsttm))
     ) order by study, ptno, &labparm, visno, subevno, labdt;

    *- on-treatment lab values -;
    create table _labont as (
      select a.study, a.ptno, &labparm, &labparmdc, 
      &labval, &labunit, &rangelo, &rangehi, labdt, labtm, visno, subevno
      from &inlab as a
      inner join _ontrt as b
      on a.study=b.study and a.ptno=b.ptno and a.usable=1
         and not missing(&labval)
         and (labdt<atrspdt and (labdt>atrstdt or (labdt=atrstdt and labtm>atrsttm)))
     ) order by study, ptno, &labparm, visno, subevno, labdt;
  quit;


  *- Create two formats based on the coded and decoded      -;
  *- treatment arm values (one is undented, the other not). -;
  %mkformat(_tmtarm,&trtvar,&trtdc,$atrind,indent=1);
  %mkformat(_tmtarm,&trtvar,&trtdc,$atrfmt,indent=0);


  *- style 2 needs a format with the population total shown so call popfmt -;
  %if &style2 EQ Y %then %do;
    %popfmt(dsin=_poptmt,trtvar=&trtvar,trtfmt=$atrfmt.,uniqueid=study ptno,underscore=yes);
  %end;


  *- keep the first, last or all within visno for baseline and on-treat -;
  data _labbl2;
    set _labbl;
    by study ptno &labparm visno;
    %if &repeat NE ALL %then %do;
      if &repeat..visno;
    %end;
  run;

  data _labont2;
    set _labont;
    by study ptno &labparm visno;
    %if &repeat NE ALL %then %do;
      if &repeat..visno;
    %end;
  run;


  *- keep only the last for overall baseline and on-treat -;
  data _labbl3;
    set _labbl2;
    by study ptno &labparm;
    if last.&labparm;
  run;

  data _labont3;
    set _labont2;
    by study ptno &labparm;
    if last.&labparm;
  run;


  *- bring the baseline and on-treatment data together -;
  data _laball;
    set _labbl3 _labont3;
    by study ptno &labparm;
  run;


  *- Get rid of the cases where you only have one observation and      -;
  *- hence you do not have both a baseline and a last treatment value. -;
  data _laball2;
    set _laball;
    by study ptno &labparm;
    if first.&labparm and last.&labparm then delete;
  run;


  %let workds=_laball2;


  *- calculate normalized values if dataset is specified -;
  %if %length(&innorm) %then %do;
    proc sql noprint;
      create table _labnorm as (
        select a.*, b.&normlo as _rnglo, b.&normhi as _rnghi, b.&labunit as _normunit,
        b.&normlo+(&labval-a.&rangelo)*(b.&normhi-b.&normlo)/(a.&rangehi-a.&rangelo) as _normval
        from _laball2 as a
        left join &innorm as b
        on a.&labparm=b.&labparm
      ) order by study, ptno, &labparm, visno, subevno, labdt;
    quit;
    %let labval=_normval;
    %let labunit=_normunit;
    %let workds=_labnorm;
  %end;


  *- generate change from baseline observations -;
  data _laball3;
    length tpx $ 4 labparmstr $ 80;
    retain bl .;
    set &workds;
    by study ptno &labparm;
    labparmstr=trim(&labparmdc)||" ["||trim(&labunit)||"]";
    if first.&labparm then do;
      bl=&labval;
      tp=1;
      tpx="BASE";
      output;
    end;
    else do;
      tp=2;
      tpx="LAST";
      output;
      tp=3;
      tpx="DIFF";
      &labval=&labval-bl;
      output;
    end;
    drop bl;
  run;


  *- merge in the treatment arm -;
  proc sql noprint;
    create table _laball4 as (
    select a.*, &trtvar, &trtdc 
    from _laball3 as a
    left join _tmtarm as b
    on a.study=b.study and a.ptno=b.ptno
    );
  quit;


  *- Call unistats to calculate descriptive statistics with -;
  *- a transposed-by-statistic output dataset produced.     -;
  %unistats(dsin=_laball4,print=no,varlist=&labval,
  trtvar=&trtvar,trtfmt=$atrfmt.,
  byvars=tp &labparm labparmstr,
  descstats=&descstats,dstranstat=_transtat);


  *- add in the lab group info -;
  proc sql noprint;
    create table _transtat2 as (
    select a.*, b.labgrp, b.labgrpx, b.labnmor
    from _transtat as a
    left join _labgrp as b
    on a.&labparm=b.&labparm
    ) order by labgrp, labgrpx;
  quit;


  *- style=1 report with timepoint as the across variable -;
  %if &style1 EQ Y %then %do;
    proc report missing headline headskip nowd split="@" data=_transtat2 spacing=&spacing;  
      by labgrp labgrpx;
      columns ( "__" labnmor labparmstr &labparm &trtvar tp,(&_statkeys_) _foolrep); 
      define labnmor / group noprint; 
      define labparmstr / group noprint;  
      define &labparm / group noprint;  
      define &trtvar / group order=internal "Parameter/" " Treatment"
                       format=$atrind. width=20 spacing=0;
      define tp / across " " order=internal format=tpfmt. ; 
      %do i=1 %to %words(&_statkeys_);
        %let key=%scan(&_statkeys_,&i,%str( ));
        %let spac=;
        %if &i EQ 1 %then %let spac=spacing=3;
        define &key / display &spac;
      %end;
      define _foolrep / noprint; 
      compute before &labparm;
        line @1 labparmstr $char60.;
      endcompute;
      break after &labparm / skip;
    run;  
  %end;


  *- style=2 report with treatment arm as the across variable -;
  %if &style2 EQ Y %then %do;
    proc report missing headline headskip nowd split="@" data=_transtat2 spacing=&spacing;  
      by labgrp labgrpx;
      columns ( "__" labnmor labparmstr &labparm tp &trtvar,(&_statkeys_) _foolrep);  
      define labnmor / group noprint;
      define labparmstr / group noprint;  
      define &labparm / group noprint;  
      define tp / group order=internal "Parameter/" "  Visit/" "  Difference from Baseline"
                  format=tpind. width=30 spacing=0 left;
      define &trtvar / across " " order=internal format=&_popfmt_ ; 
      %do i=1 %to %words(&_statkeys_);
        %let key=%scan(&_statkeys_,&i,%str( ));
        %let spac=;
        %if &i EQ 1 %then %let spac=spacing=3;
        define &key / display &spac;
      %end;
      define _foolrep / noprint; 
      compute before &labparm;
        line @1 labparmstr $char60.;
      endcompute;
      break after &labparm / skip;
    run;  
  %end;


  sasfile _ontrt close;

  *- tidy up -;
  %if &debug NE Y %then %do;
    proc datasets nolist;
      delete _ontrt _transtat _transtat2 _labbl _labbl2 _labbl3 
             _labont _labont2 _labont3
             _laball _laball2 _laball3 _laball4 _labgrp
             _pop _poptmt _tmtarm
           %if %length(&innorm) %then %do;
             _labnorm
           %end;
      ;
    quit;
  %end;


  %goto skip;
  %exit: %put &err: (labncfb) Leaving macro due to problem(s) listed;
  %skip:

%mend labncfb;

