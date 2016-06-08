/*<pre><b>
/ Program   : trnslvls.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 28-Oct-2011
/ Purpose   : To transpose levels data from the %freqlvls macro
/ SubMacros : %varfmt
/ Notes     : This macro expects the variables LVL1ORD, LVL1, LVL2ORD etc. as
/             created by the %freqlvls macro.
/
/             Informats can be specified at each level to override the default
/             order sequence. The %mkordinfmt macro might be useful for
/             creating these informats.
/
/             If you set alllowlvl=yes then you have to specify an ordering
/             informat for that level.
/
/ Usage     : %trnslvls(dsin=myds,lvls=5,trtvar=trtarm,trtord=99,prefix=TRT,
/                       dsout=mydsout,plugwith="  0 (  0.0)   0")
/             %trnslvls(dsin=both,dsout=tranboth,var=str,trtvar=tpatt,
/                       trtord="XXX",alllowlvl=yes,alllowwhere=lvl5 ne ".",
/                       plugwith="   0 (  0.0)     0",lvls=5,lvl5infmt=int.,
/                       lvl1anylbl="Patients with any AE")
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ dsin              Input dataset
/ lvls              Number of levels
/ var               Variable to transpose
/ dsout             Output dataset
/ trtvar            Treatment variable
/ trtfmt            Treatment variable format (to override existing format)
/ trtord            Treatment value for ordering
/ prefix=TRT        Prefix for transposed variables
/ plugwith          Plugging value for transposed variables (optional)
/ byvars            By variables (optional)
/ alllowlvl=no      If this is set to yes then it will ensure the complete set
/                   of the lowest level values present is represented for the
/                   higher levels.
/ alllowwhere       An optional where clause to apply to the alllowlvl terms.
/ lowinfmt          The ordering informat for the lowest level (must be
/                   specified for alllowlvl=yes).
/ lvlv1-9infmt      Optional informats for changing the default LVL1ORD etc.
/                   values. Note that these values should end with a period.
/ lvl1anylbl        Quoted string to replace the "ANY " level 1 label. If you
/                   set this to " " then this high level total will be dropped.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  28Oct11         New (v1.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: trnslvls v1.0;

%macro trnslvls(dsin=,
                lvls=,
                 var=,
               dsout=,
              trtvar=,
              trtfmt=,
              trtord=,
              prefix=TRT,
            plugwith=,
              byvars=,
           alllowlvl=no,
         alllowwhere=,
            lowinfmt=,
           lvl1infmt=,
           lvl2infmt=,
           lvl3infmt=,
           lvl4infmt=,
           lvl5infmt=,
           lvl6infmt=,
           lvl7infmt=,
           lvl8infmt=,
           lvl9infmt=,
          lvl1anylbl=
                );

  %local i err errflag ;
  %let err=ERR%str(OR);
  %let errflag=0;

  %if not %length(&dsin) %then %do;
    %let errflag=1;
    %put &err: (trnslvls) No dataset supplied to dsin=;
  %end;

  %if not %length(&var) %then %do;
    %let errflag=1;
    %put &err: (trnslvls) No variable name to transpose supplied to var=;
  %end;

  %if not %length(&lvls) %then %do;
    %let errflag=1;
    %put &err: (trnslvls) No levels count supplied to lvls=;
  %end;

  %if not %length(&prefix) %then %do;
    %let errflag=1;
    %put &err: (trnslvls) No prefix supplied to prefix=;
  %end;

  %if not %length(&trtvar) %then %do;
    %let errflag=1;
    %put &err: (trnslvls) No treatment variable supplied to trtvar=;
  %end;

  %if not %length(&trtord) %then %do;
    %let errflag=1;
    %put &err: (trnslvls) No treatment ordering value supplied to trtord=;
  %end;

  %if %length(&trtvar) %then %do;
    %if not %length(&trtfmt) %then %let trtfmt=%varfmt(%scan(&dsin,1,%str(%()),&trtvar);
    %if not %length(&trtfmt) %then %do;
      %let errflag=1;
      %put &err: (trnslvls) No format assigned to treatment variable "&trtvar" and none specifed to trtfmt=;
    %end;
  %end;
    

  %if &errflag %then %goto exit;

  %if %length(&lowinfmt) %then %let lvl&lvls.infmt=&lowinfmt;

  %if not %length(&dsout) %then %let dsout=&dsin;

  %if not %length(&alllowlvl) %then %let alllowlvl=no;
  %let alllowlvl=%upcase(%substr(&alllowlvl,1,1));

  %if &alllowlvl EQ Y and not %length(lvl&lvls.infmt) %then %do;
    %put &err: (trnslvls) No informat specified to lvl&lvls.infmt for all-low-level ordering;
    %got exit;
  %end;

  %if &alllowlvl EQ Y %then %do;
    data _trnslow1;
      set &dsin
      %if %length(&alllowwhere) %then %do;
        (where=(&alllowwhere))
      %end;
      ;
      keep lvl&lvls;
    run;
    proc sort nodupkey data=_trnslow1;
      by lvl&lvls;
    run;
    data _trnslow2;
      set &dsin(where=(lvl%eval(&lvls-1)ord NE 0));
    run;
    proc sort nodupkey data=_trnslow2(keep=&byvars
      %do i=1 %to %eval(&lvls-1);
        lvl&i
      %end;
      );
      by &byvars
      %do i=1 %to %eval(&lvls-1);
        lvl&i
      %end;
      ;
    run;
    proc sql noprint;
      create table _trnslow3 as select * from
      (select * from _trnslow2),
      (select * from _trnslow1);
    quit;
    proc sort data=_trnslow3;
      by &byvars
      %do i=1 %to &lvls;
        lvl&i
      %end;
      ;
    run;
  %end;



  *- keep the sorting order for a later merge -;
  proc sort data=&dsin(keep=&byvars &trtvar lvl:
                     where=(&trtvar=&trtord
    %if &alllowlvl EQ Y %then %do;
      and lvl&lvls.ord=0
    %end;
            )) out=_lvlord(drop=&trtvar
    %if &alllowlvl EQ Y %then %do;
      lvl&lvls.ord lvl&lvls
    %end;
    );
    by &byvars
    %do i=1 %to &lvls;
      lvl&i
    %end;
      ;
  run;


  *- put the variable label into a variable -;
  data _lvltran;
    length _idlabel $ 120;
    set &dsin;
    _idlabel=put(&trtvar,&trtfmt);
  run;


  *- sort ready for the transpose -;
  proc sort data=_lvltran;
    by &byvars
    %do i=1 %to &lvls;
      lvl&i
    %end;
      &trtvar
      ;
  run;

  *- transpose -;
  proc transpose data=_lvltran prefix=&prefix 
                  out=_lvltran(drop=_name_);
    by &byvars
    %do i=1 %to &lvls;
      lvl&i
    %end;
      ;
    id &trtvar;
    idlabel _idlabel;
    var &var;
    format &trtvar;
  run;

  %if &alllowlvl EQ Y %then %do;
    data _lvltran;
      merge _lvltran _trnslow3;
      by &byvars
      %do i=1 %to &lvls;
        lvl&i
      %end;
        ;
    run;
  %end;

  *- merge the ordering back in and plug gaps -;
  data &dsout;
    merge _lvlord _lvltran;
    %if %length(&plugwith) %then %do;
      array _trt &prefix:;
    %end;
    by &byvars
    %if &alllowlvl EQ Y %then %do;   
      %do i=1 %to %eval(&lvls-1);
        lvl&i
      %end;
    %end;
    %else %do;
      %do i=1 %to &lvls;
        lvl&i
      %end;
    %end;
      ;
    %if %length(&plugwith) %then %do;
      do over _trt;
        if missing(_trt) then _trt=&plugwith;
      end;
    %end;
    %do i=1 %to &lvls;
      %if %length(&&lvl&i.infmt) %then %do;
        if lvl&i NE: "ANY " then lvl&i.ord=input(lvl&i,&&lvl&i.infmt);
      %end;
    %end;
    %if %length(&lvl1anylbl) %then %do;
      if lvl1=:"ANY " then lvl1=&lvl1anylbl;
      if lvl1=" " then delete;
    %end;
  run;


  *- delete work datasets -;
  proc datasets nolist;
    delete _lvlord _lvltran
    %if &alllowlvl EQ Y %then %do;
      _trnslow1 _trnslow2 _trnslow3
    %end;
    ;
  run;
  quit;


  %goto skip;
  %exit: %put &err: (trnslvls) Leaving macro due to problem(s) listed;
  %skip:
 
%mend trnslvls;
