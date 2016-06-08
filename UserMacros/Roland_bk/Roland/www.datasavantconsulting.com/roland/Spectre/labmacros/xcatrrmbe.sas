/*<pre><b>
/ Program   : xcatrrmbe.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 09-Feb-2012
/ Purpose   : To QC the XLAB 2 CATRRMBE table
/ SubMacros : 
/ Notes     : This macro uses Roland's utilmacros and clinmacros which must be
/             made available to the SASAUTOS path. These can be downloaded from
/             the web. Google "Roland's SAS macros".
/
/             This macro was designed for use within the CARE/Rage environment.
/
/ Limitations:
/             There is currently no RRMCLASS parameter so Only the standard
/             reference range is implemented and the footnotes have been
/             simplified to reflect this.
/
/ Usage     : %xcatrrmbe(inlinder=linder,analno=3)
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ inlinder          Input LINDER dataset
/ whereli           Where clause to apply to the LINDER data
/ analno            The analno to use
/ showmiss=no       By default, ignore those patients who do not have both
/                   baseline and on-treatment values.
/ trtvar=SORTREG    Treatment variable (default PSORT)
/ trtdc=TRDTSFT     Treatment decode variable (default PTPATT)
/ patient=Patient   What to call the patients
/ bslnlbl=Baseline                      Label for baseline
/ lastlbl=Last value on treatment       Label for last value on treatment
/ trialsft=yes      By default, list the trials in a footnote
/ ------------------- the following parameters are for debugging only ----------
/ msglevel=X        Message level to use inside this macro for notes and 
/                   information written to the log. By default, both Notes and
/                   Information are suppressed. Use msglevel=N or I for more
/                   information.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  09Feb12         New (v1.0)
/=============================================================================*/

%put MACRO CALLED: xcatrrmbe v1.0;


%macro xcatrrmbe(inlinder=,
                  whereli=,
                   analno=,
                 showmiss=no,
                   trtvar=SORTREG,
                    trtdc=TRDTSFT,
                  patient=Patient,
                  bslnlbl=Baseline,
                  lastlbl=Last value on treatment,
                 trialsft=yes,
                 msglevel=X,
                   debug=no
                );

  %local i j key spac err errflag repwidth wherecls spat misstxt studiesx
         popudc anallbl savopts titlepos repno studies repeat muliple
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

  %if not %length(&inlinder) %then %do;
    %let errflag=1;
    %put &err: (xcatrrmbe) No LINDER input dataset specified to inlinder=;
  %end;

  %if %length(&whereli) %then %let whereli=&whereli and;

  %if not %length(&analno) %then %do;
    %let errflag=1;
    %put &err: (xcatrrmbe) No analno specified to analno=;
  %end;

  proc sql noprint;
    select _fgmulti into :multiple from ads.lab(keep=_fgmulti analno
           where=(analno=&analno and not(missing(_fgmulti)))
           obs=1);
    select _fgrept into :repeat from ads.lab(keep=_fgrept analno
           where=(analno=&analno and not(missing(_fgrept)))
           obs=1);
    select anallbl into :anallbl from ads.lab(keep=analno anallbl
           where=(analno=&analno)
           obs=1);
    select popudc into :popudc from ads.lab(keep=analno popudc
           where=(analno=&analno)
           obs=1);
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
  %else %do;
    %let errflag=1;
    %put &err: (xcatrrmbe) multiple=&multiple not of type MEAN, MEDIAN, FIRST, LAST or WORST;
  %end;

  %if &errflag %then %goto exit;


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


                /************************
                      Create formats
                 ************************/

  proc sort nodupkey data=&inlinder(keep=study ptno &trtvar &trtdc analno
                                   where=(analno=&analno))
                      out=_pop(keep=study ptno &trtvar &trtdc);
    by study ptno &trtvar &trtdc;
  run;

  *- Create a format to map treatment code to the  -;
  *- decode label for use in the following format. -;
  %mkformat(_pop,&trtvar,&trtdc,$atrfmt,indent=0);

  *- create a format for treatment arm totals -;
  %popfmt(dsin=_pop,trtvar=&trtvar,trtfmt=$atrfmt.,uniqueid=study ptno,
          split=%str( ),msgs=no);

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


                /**************************
                        Baseline
                 **************************/

  data _labbl;
    set &inlinder(keep=analno study ptno labnm rngflag &trtvar _fgbslv
                 where=(&whereli analno=&analno and _fgbslv=1));
    rename rngflag=_blflag;
    drop _fgbslv analno;
  run;
  proc sort data=_labbl;
    by study ptno &trtvar labnm;
  run;


                /**************************
                   Last value on treatment
                 **************************/

  proc sort data=&inlinder(keep=study ptno &trtvar labnm rngflag _hasbase _haslast
                                labnmx labnmor labgrp labgrpx analno _fglastv
                          where=(&whereli analno=&analno and _fglastv=1))
             out=_lablast2(drop=_fglastv analno);
    by study ptno &trtvar labnm;
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
    class labgrp labgrpx labnmor labnm labnmx &trtvar _flags;
    output out=_labsum(drop=_type_);
  run;


                /**************************
                         Transpose
                 **************************/

  proc transpose data=_labsum out=_labtran(drop=_name_);
    by labgrp labgrpx labnmor labnm labnmx &trtvar;
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

  proc report missing headline headskip nowd split="@" spacing=3 data=_labtran3;  
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
    delete _pop _laball _labtran _labtran2 _labtran3
           _labbl _lablast2 _labsum _popfmt 
           ;
  quit;


  %goto skip;
  %exit: %put &err: (xcatrrmbe) Leaving macro due to problem(s) listed;
  %skip:


  *- restore sas options -;
  options &savopts;

%mend xcatrrmbe;
