/*<pre><b>
/ Program   : xpcsaf.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 17-Feb-2012
/ Purpose   : To QC the XLAB 2 PCSAF table
/ SubMacros : %mkformat %popfmt %age : %hasvars %match %varlist %nodup %varlen
/             %attrv %vartype %splitvar
/ Notes     : This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             This macro was designed for use within the CARE/Rage environment.
/
/ Limitations:
/
/             CS processing has not yet been implemented for age ranges as 
/             no examples for this yet exist and it is unclear what form they
/             will take.
/
/ Usage     : %xpcsaf(inlinder=linder,analno=3);
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlinder          Input LINDER dataset
/ whereli           Where clause to apply to the LINDER data
/ analno            The analno to use
/ csbsl=no          By default, do not include patients with PCSA at baseline
/ showpats=yes      By default, list the patients in the High and Low categories
/ trtvar=SORTREG    Treatment variable (default SORTREG)
/ trtdc=TRDTSFT     Treatment decode variable (default TRDTSFT)
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
/ rrb  17Feb12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: xpcsaf v1.0;


%macro xpcsaf(inlinder=,
               whereli=,
                analno=,
                 csbsl=no,
              showpats=yes,
                trtvar=SORTREG,
                 trtdc=TRDTSFT,
               patient=Patient,
              trialsft=yes,
              msglevel=X,
                 debug=no
               );

  %local i err errflag repwidth studies studiesx titlepos repno popudc anallbl
         multiple repeat;

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

  %if not %length(&inlinder) %then %do;
    %let errflag=1;
    %put &err: (xpcsaf) No LINDER input dataset specified to inlinder=;
  %end;

  %if %length(&whereli) %then %let whereli=&whereli and;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (xpcsaf) No analno specified to analno=;
  %end;


             /****************************
                  Copy lab data to WORK 
              ****************************/

  %if %upcase(&inlinder) NE _LAB %then %do;
    data _lab;
      set &inlinder(keep=analno study ptno labnm labnmx labnmor labgrp labgrpx 
                       labdttm _fgprev _fgcs &trtvar &trtdc _fgmulti _fgrept
                       anallbl popudc _fgontv _relvcs
                  where=(&whereli analno=&analno));
      drop analno;
    run;
  %end;


  *- only keep those with CS rules -;
  data _lab2;
    set _lab(where=(_relvcs ne " "));
  run;


  *- labnm and CS rule for later merging -;
  proc sort nodupkey data=_lab2(keep=labnm _relvcs) out=_relvcs;
    by labnm _relvcs;
  run;


  *- extract some information -;
  proc sql noprint;
    select _fgmulti into :multiple from _lab(keep=_fgmulti
           where=(not(missing(_fgmulti))) obs=1);
    select _fgrept into  :repeat   from _lab(keep=_fgrept
           where=(not(missing(_fgrept)))  obs=1);
    select anallbl into  :anallbl  from _lab(keep=anallbl obs=1);
    select popudc into   :popudc   from _lab(keep=popudc obs=1);
  quit;

    
  %if &repeat EQ 1 %then %let repeat=MEAN;
  %else %if &repeat EQ 2 %then %let repeat=MEDIAN;
  %else %if &repeat EQ 3 %then %let repeat=FIRST;
  %else %if &repeat EQ 4 %then %let repeat=LAST;
  %else %if &repeat EQ 5 %then %let repeat=WORST;
  %else %do;
    %let errflag=1;
    %put &err: (xcatrrmbe) repeat=&repeat not of type MEAN, MEDIAN, FIRST, LAST or WORST;
  %end;


  %if &multiple EQ 1 %then %let multiple=MEAN;
  %else %if &multiple EQ 2 %then %let multiple=MEDIAN;
  %else %if &multiple EQ 3 %then %let multiple=FIRST;
  %else %if &multiple EQ 4 %then %let multiple=LAST;
  %else %if &multiple EQ 5 %then %let multiple=WORST;
  %else %if &multiple EQ 6 %then %let multiple=CLOSEST;
  %else %do;
    %let errflag=1;
    %put &err: (xcatrrmbe) multiple=&multiple not of type MEAN, MEDIAN, FIRST, LAST, WORST or CLOSEST;
  %end;

  %if &errflag %then %goto exit;



  %if not %length(&csbsl) %then %let csbsl=no;
  %let csbsl=%upcase(%substr(&csbsl,1,1));

  %if not %length(&showpats) %then %let showpats=yes;
  %let showpats=%upcase(%substr(&showpats,1,1));

  %if not %length(&trialsft) %then %let trialsft=yes;
  %let trialsft=%upcase(%substr(&trialsft,1,1));

  %if not %length(&debug) %then %let debug=no;
  %let debug=%upcase(%substr(&debug,1,1));


                /************************
                      Create formats
                 ************************/

  proc sort nodupkey data=_lab(keep=study ptno &trtvar &trtdc)
                      out=_pop(keep=study ptno &trtvar &trtdc);
    by study ptno &trtvar &trtdc;
  run;

  *- Create a format to map treatment code to the  -;
  *- decode label for use in the following format. -;
  %mkformat(_pop,&trtvar,&trtdc,$atrfmt,indent=0);

  *- create a format for treatment arm totals -;
  %popfmt(dsin=_pop,trtvar=&trtvar,trtfmt=$atrfmt.,uniqueid=study ptno,
          split=%str( ),msgs=no,indent=4);

  *- list of studies separated by commas -;
  proc sql noprint;
    select distinct study into :studies separated by ", " from _pop;
  quit;

  *- replace last comma in studies list with an "and" -;
  %let studies=%comma2andmac(&studies);





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
  proc sort data=_lab2(keep=study ptno labnm labdttm _fgprev _fgcs 
                           &trtvar &trtdc
                      where=(_fgprev=1))
             out=_bslcs(drop=labdttm);
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
  proc sort data=_lab2(keep=study ptno labgrp labgrpx labnm labnmx labnmor
                                _fgontv _fgcs &trtvar &trtdc 
                      where=(_fgontv=1 and _fgcs in ("H","L") )) 
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
  proc summary nway missing data=_lab2(keep=study ptno labnm labnmx 
                                           labnmor labgrp labgrpx
                                           &trtvar &trtdc _fgontv
                               where=(_fgontv=1));
    class study ptno labnm labnmx labnmor labgrp labgrpx &trtvar &trtdc;
    output out=_ont(drop=_type_ _freq_);
  run;


  *- all on-treatment patients not CS at baseline -;
  data _labn;
    merge _bslcs(in=_a) _ont(in=_b);
    by study ptno labnm &trtvar &trtdc;
    %if "&csbsl" EQ "Y" %then %do;
      if _b;
    %end;
    %else %do;
      if _b and not _a;
    %end;
  run;


  *- count them -;
  proc summary nway missing data=_labn;
    class &trtvar &trtdc  labnm labnmx labgrp labgrpx labnmor;
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


              /*****************************
                 Suppress unwanted columns
               *****************************/

  *- sort ready for a merge with _relvcs -;
  proc sort data=_ontrep2;
    by labnm;
  run;


  *- suppress unwanted columns -;
  data _ontrep3;
    merge _relvcs _ontrep2(in=_b);
    by labnm;
    if _b;
    if not index(_relvcs,"H") then strh=" ";
    if not index(_relvcs,"L") then strl=" ";
  run;


  *- sort ready for proc report -;
  proc sort data=_ontrep3;
    by labgrp labgrpx;
  run;


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
  %if &csbsl NE Y %then %do;
    footnote2 "* &patient.s with no possible clinically significant abnormality at baseline";
  %end;
  %else %do;
    footnote2 "* All &patient.s at risk including patients whose baseline value was abnormal and with non-missing lab values";
  %end;
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

  proc report missing headline headskip nowd split="@" data=_ontrep3 spacing=2;  
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

  %if &debug NE Y %then %do;
    proc datasets nolist;
      delete _pop _bslcs 
             _labn _labntot _ont _ontcs _ontcs2
             _ontrep1 _ontrep2 _ontrep3 _popfmt
             %if %upcase(&inlinder) NE _LAB %then _lab;
      ;
    quit;
  %end;


  %goto skip;
  %exit: %put &err: (xpcsaf) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend xpcsaf;
